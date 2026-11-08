"""Verificação de leitura. Execute na raiz: python -m backend.tools.verificar_banco."""
import json
from backend.config.database import DataUnavailable, Settings, connect
from backend.repositories.data import MongoRepository
from backend.models.schemas import Filters, Period
from backend.services.dashboard import build_dashboard


def verify(settings):
    repo = MongoRepository(settings)
    try:
        repo.client = connect(settings)
        repo.client.admin.command("ping")
        latest = repo.latest()
        data = build_dashboard(repo, Filters(periodo=Period.dia))
        types = list(repo.collection.aggregate([
            {"$match": {"fonte_preferencial": True, "registro_diario": True}},
            {"$group": {"_id": "$tipo", "registros": {"$sum": 1},
                        "data_inicio": {"$min": "$data"}, "data_fim": {"$max": "$data"}}},
            {"$sort": {"_id": 1}},
        ], maxTimeMS=25000))
        # Conciliação independente: não usa o serviço de cálculo.
        reference = list(repo.collection.aggregate([
            {"$match": {"data": latest.isoformat(), "tipo": "operacao_diaria",
                        "fonte_preferencial": True, "registro_diario": True}},
            {"$group": {"_id": None, "km": {"$sum": "$valores.kmTotal"},
                        "viagens": {"$sum": "$valores.nrViagensRealiz"},
                        "km_presentes": {"$sum": {"$cond": [{"$isNumber": "$valores.kmTotal"}, 1, 0]}},
                        "linhas": {"$sum": 1}}},
        ], maxTimeMS=25000))
        reconciled = None
        if reference and reference[0]["km_presentes"] == reference[0]["linhas"]:
            from backend.repositories.data import decimal_value
            reconciled = decimal_value(reference[0]["km"]) == data["quilometragem"]["valor"]
        return {"ping": "ok", "fonte": "dados_consulta", "ultima_data": latest.isoformat(),
                "tipos_e_cobertura": types,
                "conciliacao_km": reconciled, "status": "verificado" if reconciled else "leitura_ok_conciliacao_pendente"}
    finally:
        repo.close()


if __name__ == "__main__":
    try:
        print(json.dumps(verify(Settings.load()), ensure_ascii=False, indent=2))
    except Exception as error:
        print(json.dumps({"status": "pendente", "motivo": str(error) if isinstance(error, DataUnavailable) else type(error).__name__}, ensure_ascii=False))
        raise SystemExit(1)

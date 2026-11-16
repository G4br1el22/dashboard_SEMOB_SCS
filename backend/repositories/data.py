"""Leitura exclusiva da view, com projeção de campos operacionais permitidos."""
from datetime import date, timedelta
from decimal import Decimal
from threading import Lock
from time import monotonic

from bson import Decimal128
from pymongo.errors import PyMongoError

from backend.config.database import DataUnavailable, connect

KINDS = ["operacao_diaria", "operacao_linha_diaria", "passageiros_diarios", "vendas_utilizacao"]
FIELDS = ["Linha", "nrViagensRealiz", "nrViagens", "kmTotal", "nrVeiculos", "Catraca", "Antecipados",
          "Não Pagantes", "Total Passageiros", "Total Vendas"]


def decimal_value(value):
    if isinstance(value, Decimal128):
        value = value.to_decimal()
    if isinstance(value, bool) or not isinstance(value, (int, Decimal)):
        return None
    value = Decimal(value)
    return value if value.is_finite() else None


class MongoRepository:
    source = "mongo"

    def __init__(self, settings):
        self.settings = settings
        self.client = None
        self.cache = {}
        self.lock = Lock()

    @property
    def collection(self):
        with self.lock:
            if self.client is None:
                self.client = connect(self.settings)
        return self.client[self.settings.database]["dados_consulta"]

    def latest(self):
        try:
            record = self.collection.find_one(
                {"tipo": {"$in": KINDS}, "registro_diario": True, "fonte_preferencial": True,
                 "data": {"$type": "string"}}, {"_id": 0, "data": 1}, sort=[("data", -1)])
            if not record:
                raise DataUnavailable("A view dados_consulta não contém registros diários preferenciais compatíveis.")
            return date.fromisoformat(record["data"])
        except PyMongoError:
            raise DataUnavailable("MongoDB indisponível. Confira credencial, permissão de leitura e acesso de rede ao Atlas.") from None
        except (ValueError, TypeError):
            raise DataUnavailable("A view contém uma data incompatível; execute a verificação de banco.") from None

    def read(self, start, end, line=None):
        key = (start, end, line)
        with self.lock:
            cached = self.cache.get(key)
            if cached and monotonic() - cached[0] < 15:
                return cached[1]
        try:
            query = {"tipo": {"$in": KINDS}, "registro_diario": True, "fonte_preferencial": True,
                     "data": {"$gte": start.isoformat(), "$lte": end.isoformat()}}
            if line is not None:
                identifiers = [line]
                if line.isdigit() and str(int(line)) == line:
                    identifiers.append(int(line))
                query["valores.Linha"] = {"$in": identifiers}
            projection = {"_id": 0, "data": 1, "tipo": 1,
                          **{"valores." + field: 1 for field in FIELDS}}
            rows = list(self.collection.find(query, projection).limit(200001).max_time_ms(25000))
            if len(rows) > 200000:
                raise DataUnavailable("Consulta muito extensa. Selecione um período menor.")
            with self.lock:
                if len(self.cache) > 24:
                    self.cache.clear()
                self.cache[key] = (monotonic(), rows)
            return rows
        except PyMongoError:
            raise DataUnavailable("Não foi possível consultar o MongoDB. Tente novamente ou verifique o acesso ao Atlas.") from None

    def close(self):
        if self.client is not None:
            self.client.close()


class DemoRepository:
    """Base sintética determinística. Nunca usada como fallback de MongoDB."""
    source = "demo"

    def __init__(self):
        self.rows = []
        for offset in range(62):
            day = date(2026, 8, 1) + timedelta(days=offset)
            trips, km = 0, Decimal(0)
            for index, line in enumerate(["101", "102", "103"]):
                n = 30 + (offset + index) % 9
                distance = Decimal(n) * Decimal("12.35")
                trips += n
                km += distance
                self.rows.append(self._row(day, "operacao_linha_diaria", Linha=line,
                                           nrViagens=n, kmTotal=distance))
            self.rows.append(self._row(day, "operacao_diaria", nrViagensRealiz=trips,
                                       kmTotal=km, nrVeiculos=12))
            self.rows.append(self._row(day, "passageiros_diarios", Catraca=400 + offset * 2,
                                       Antecipados=1800 + offset * 3, **{"Não Pagantes": 900 + offset}))
            self.rows.append(self._row(day, "vendas_utilizacao",
                                       **{"Total Vendas": Decimal("4321.10") + offset}))

    @staticmethod
    def _row(day, kind, **values):
        return {"data": day.isoformat(), "tipo": kind, "valores": values,
                "registro_diario": True, "fonte_preferencial": True}

    def latest(self):
        return date(2026, 10, 1)

    def read(self, start, end, line=None):
        return [row for row in self.rows if start.isoformat() <= row["data"] <= end.isoformat()
                and (line is None or str(row.get("valores", {}).get("Linha", "")) == line)]

    def close(self):
        pass

"""Importação auditável de HTML SEMOB. Nenhuma credencial é gravada em disco.

Dry run: python tools/import_semob.py --source ../../bd
Importar: acrescente --host <cluster.mongodb.net> --user <usuario> --apply
A senha é solicitada sem eco. A coleção bruta NÃO é adequada a somas diretas.
"""
import argparse
from collections import Counter, defaultdict
from datetime import datetime, timezone
from decimal import Decimal
import getpass
import hashlib
import json
from pathlib import Path
import re

from bson import BSON, Decimal128
from lxml import html
from pymongo import MongoClient, ReplaceOne

MONTHS = dict(zip(["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"], [f"{i:02d}" for i in range(1, 13)]))
NUMERIC = set("nrVeiculos nrMaxVeicFx nrViagensProgr nrViagensRealiz kmProd kmImprod kmTotal manha_p manha_r tarde_p tarde_r noite_p noite_r programadas realizadas Nr_Veiculos Nr_Viagens nrViagens Catraca Antecipados".split()) | {"Dif Viagens", "Não Pagantes", "Total Passageiros", "Crédito Circulante", "Créditos transferidospara cartões", "Créditos transferidos para cartões", "Saldo Final", "Total Vendas", "Total Utilização"}


def digest(value):
    return hashlib.sha256(value).hexdigest()


def family(name, headers):
    if "Total Vendas" in headers:
        return "vendas_utilizacao"
    if "Saldo Final" in headers:
        return "saldo_creditos"
    if "Total Passageiros" in headers:
        return "passageiros_diarios"
    for token, kind in [("_Viag_NRealiz_", "viagens_nao_realizadas"), ("_Viag_NTerm_", "viagens_nao_terminadas"), ("_Viag_Ninic_", "viagens_nao_iniciadas"), ("_Viagens_", "viagens"), ("_Resumo_FxHr_", "operacao_faixa_horaria"), ("_FxHr_", "partidas_faixa_horaria"), ("_Linhas_", "operacao_linha_diaria"), ("_FCV_", "cumprimento_viagens")]:
        if token in name:
            return kind
    if "nrViagensProgr" in headers:
        return "operacao_diaria"
    raise ValueError("Tabela de dados não reconhecida")


def row_date(raw):
    value = raw.get("Data", "")
    if re.fullmatch(r"\d{2}/\d{2}/\d{4}", value):
        return datetime.strptime(value, "%d/%m/%Y").date().isoformat()
    if re.fullmatch(r"\d{4}-\d{2}", raw.get("Mês", "")) and re.fullmatch(r"\d{1,2}", raw.get("Dia", "")):
        return datetime.strptime(raw["Mês"] + "-" + raw["Dia"], "%Y-%m-%d").date().isoformat()
    return None


def typed(raw):
    result = {}
    for key, value in raw.items():
        if not value:
            result[key] = None
        elif key in NUMERIC:
            if not re.fullmatch(r"-?\d+(?:\.\d{3})*(?:,\d+)?", value):
                raise ValueError("Número em formato não reconhecido: " + key)
            number = Decimal(value.replace(".", "").replace(",", "."))
            result[key] = Decimal128(number) if "," in value else int(number)
        else:
            result[key] = value  # Identificadores e horários permanecem strings.
    return result


def prepare(source):
    source = Path(source).resolve()
    files = sorted(source.rglob("*.html"))
    if not files:
        raise ValueError("Nenhum relatório HTML encontrado")
    manifests, rows, candidates = [], [], defaultdict(list)
    for path in files:
        content = path.read_bytes()
        relative = path.relative_to(source).as_posix()
        file_hash = digest(content)
        source_id = digest((relative + ":" + file_hash).encode())
        match = re.search(r"(\d{4})(\d{2})\.html$", path.name)
        period = f"{match[1]}-{match[2]}" if match else None
        if not period:
            for part in path.parts:
                for month, number in MONTHS.items():
                    if re.fullmatch(month + r"_\d{4}", part):
                        period = part[-4:] + "-" + number
        if not period:
            raise ValueError("Período de origem não reconhecido: " + relative)
        monthly = "Mensal" in path.parts
        document = html.fromstring(content.decode("cp1252"))
        count, tables, periods = 0, set(), defaultdict(set)
        for table_index, table in enumerate(document.xpath('//table[contains(concat(" ",normalize-space(@class)," ")," data ")]')):
            headers = [" ".join(n.text_content().split()) for n in (table.xpath("./th") or table.xpath(".//tr[th][1]/th"))]
            if headers == ["SmartDataSource.com.br", "Horário"]:
                continue
            if not headers or len(headers) != len(set(headers)) or any("." in h or h.startswith("$") for h in headers):
                raise ValueError("Cabeçalho inválido: " + relative)
            kind = family(path.name, headers)
            tables.add(kind)
            periods[kind].add(period)
            for row_index, node in enumerate(table.xpath(".//tr[td]")):
                values = [" ".join(n.text_content().split()) for n in node.xpath("./td")]
                if len(values) != len(headers):
                    raise ValueError("Número de colunas divergente: " + relative)
                raw = dict(zip(headers, values))
                date = row_date(raw)
                if date:
                    periods[kind].add(date[:7])
                row = {"_id": digest(f"{source_id}:{table_index}:{row_index}".encode()), "origem_id": source_id, "tabela": table_index, "linha_origem": row_index + 1, "tipo": kind, "data": date, "registro_diario": date is not None, "fonte_preferencial": False, "original": raw, "valores": typed(raw)}
                rows.append(row)
                count += 1
        if not tables:
            raise ValueError("Arquivo sem tabela de dados: " + relative)
        manifests.append({"_id": source_id, "arquivo": relative, "sha256": file_hash, "bytes": len(content), "periodo_declarado": period, "mensal": monthly, "tipos": sorted(tables), "linhas": count, "parser_version": 1})
        for kind, months in periods.items():
            for month in months:
                candidates[kind, month].append(((period == month, monthly, period, relative), source_id))
    preferred = {key: max(items)[1] for key, items in candidates.items()}
    for row in rows:
        if row["data"]:
            row["fonte_preferencial"] = row["origem_id"] == preferred[row["tipo"], row["data"][:7]]
    stats = {"arquivos": len(manifests), "linhas_preservadas": len(rows), "linhas_consulta": sum(r["fonte_preferencial"] for r in rows), "totais_fora_consulta": sum(not r["registro_diario"] for r in rows), "bson_mib_sem_indices": round(sum(len(BSON.encode(r)) for r in rows + manifests) / 1024 ** 2, 2), "tipos": dict(Counter(r["tipo"] for r in rows if r["fonte_preferencial"]))}
    if stats["bson_mib_sem_indices"] > 300:
        raise ValueError("Carga excede margem conservadora de armazenamento gratuito")
    return manifests, rows, stats


def upload(host, user, password, prepared, progress=lambda message: None):
    if not re.fullmatch(r"[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+\.mongodb\.net", host):
        raise ValueError("Use somente hostname SRV Atlas, sem credenciais")
    manifests, rows, stats = prepared
    with MongoClient("mongodb+srv://" + host + "/", username=user, password=password, authSource="admin", tls=True, tlsAllowInvalidCertificates=False, tlsAllowInvalidHostnames=False, serverSelectionTimeoutMS=30000, connectTimeoutMS=15000, socketTimeoutMS=90000, maxPoolSize=5, retryWrites=True, w="majority", wTimeoutMS=90000, appname="semob-importacao") as client:
        client.admin.command("ping")
        db = client["semob"]
        expected_sources = {m["_id"] for m in manifests}
        existing = {m["_id"] for m in db.relatorios_origem.find({}, {"_id": 1})}
        if existing - expected_sources:
            raise ValueError("Há outras cargas no destino; revisar versões antes de continuar")
        db.relatorios_origem.bulk_write([ReplaceOne({"_id": m["_id"]}, m, upsert=True) for m in manifests], ordered=False)
        for start in range(0, len(rows), 1000):
            batch = rows[start:start + 1000]
            db.relatorios_linhas.bulk_write([ReplaceOne({"_id": r["_id"]}, r, upsert=True) for r in batch], ordered=False)
            if start % 10000 == 0:
                progress(f"Linhas enviadas: {min(start + 1000, len(rows))}/{len(rows)}")
        db.relatorios_linhas.create_index([("tipo", 1), ("fonte_preferencial", 1), ("data", 1)], name="consulta_tipo_data")
        db.relatorios_linhas.create_index([("origem_id", 1)], name="rastreabilidade")
        db.relatorios_linhas.create_index([("valores.Linha", 1), ("data", 1)], name="linha_data")
        pipeline = [{"$match": {"fonte_preferencial": True, "registro_diario": True}}, {"$project": {"original": 0, "valores.Motorista": 0}}]
        names = db.list_collection_names()
        if "dados_consulta" not in names:
            db.create_collection("dados_consulta", viewOn="relatorios_linhas", pipeline=pipeline)
        else:
            info = next(db.list_collections(filter={"name": "dados_consulta"}))
            if info.get("type") != "view" or info.get("options", {}).get("pipeline") != pipeline:
                raise ValueError("View existente difere da definição esperada")
        if db.relatorios_linhas.count_documents({}) != len(rows) or db.dados_consulta.count_documents({}) != stats["linhas_consulta"]:
            raise ValueError("Contagem remota divergente")
        if db.dados_consulta.count_documents({"valores.Motorista": {"$exists": True}}):
            raise ValueError("Campo Motorista exposto na view")
        for manifest in manifests:
            if db.relatorios_linhas.count_documents({"origem_id": manifest["_id"]}) != manifest["linhas"]:
                raise ValueError("Contagem por arquivo divergente")
        return {**stats, "verificado_em": datetime.now(timezone.utc).isoformat(), "banco": "semob", "view": "dados_consulta", "tls_validado": True}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True)
    parser.add_argument("--host")
    parser.add_argument("--user")
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    prepared = prepare(args.source)
    print(json.dumps(prepared[2], ensure_ascii=False, indent=2))
    if args.apply:
        if not args.host or not args.user:
            parser.error("--apply exige --host e --user")
        try:
            result = upload(args.host, args.user, getpass.getpass("Senha temporária do Atlas: "), prepared, print)
            print(json.dumps(result, ensure_ascii=False, indent=2))
        except Exception as exc:
            raise SystemExit("Importação não concluída: " + type(exc).__name__) from None

from datetime import date
from decimal import Decimal
from io import BytesIO

from bson import Decimal128
from fastapi.testclient import TestClient
from openpyxl import load_workbook
import pytest

from backend.config.database import Settings
from backend.main import create_app
from backend.models.schemas import Filters
from backend.repositories.data import DemoRepository, MongoRepository
from backend.services.dashboard import build_dashboard


@pytest.fixture
def client(tmp_path):
    with TestClient(create_app(Settings(source="demo", report_dir=tmp_path))) as c:
        yield c


def custom_filters(start="2026-09-01", end="2026-09-30", **extra):
    return Filters(periodo="datas", data_inicio=start, data_fim=end, **extra)


def test_precedence_does_not_double_count():
    repo = DemoRepository()
    data = build_dashboard(repo, Filters())
    day = repo.latest().isoformat()
    reference = sum(row["valores"]["kmTotal"] for row in repo.rows
                    if row["data"] == day and row["tipo"] == "operacao_diaria")
    assert data["quilometragem"]["valor"] == reference  # Não soma também a tabela por linha.
    assert sum(row["km"] for row in data["linhas"]) == reference
    assert sum(row["viagens"] for row in data["linhas"]) == data["viagens"]["valor"]


def test_missing_is_not_zero_and_sales_are_not_revenue(client):
    result = client.get("/api/financeiro").json()
    assert result["receita"]["valor"] is None
    assert result["custo"]["valor"] is None
    assert Decimal(result["vendas_creditos"]["valor"]) == Decimal("4382.10")
    assert result["frota"]["total"] is None
    assert result["linhas"][0]["pontualidade"] is None


def test_decimal128_precision_and_missing_field():
    repo = DemoRepository()
    repo.rows = [repo._row(repo.latest(), "operacao_diaria", kmTotal=Decimal128("0.10"), nrViagensRealiz=0),
                 repo._row(repo.latest(), "operacao_diaria", kmTotal=Decimal128("0.20"), nrViagensRealiz=0)]
    data = build_dashboard(repo, Filters())
    assert data["quilometragem"]["valor"] == Decimal("0.30")
    assert data["viagens"]["valor"] == 0
    assert data["pagantes"]["valor"] is None


def test_partial_interval_and_no_fabricated_comparison():
    repo = DemoRepository()
    data = build_dashboard(repo, custom_filters("2026-07-01", "2026-08-02", comparacao="periodo_anterior"))
    assert data["quilometragem"]["parcial"] is True
    assert data["quilometragem"]["dias_observados"] == 2
    assert data["quilometragem"]["variacao"] is None
    assert len(data["serie"]) == 33
    assert data["serie"][0]["pagantes"] is None
    assert data["quilometragem"]["sparkline"] == []


def test_comparison_uses_complete_periods():
    repo = DemoRepository()
    current = build_dashboard(repo, custom_filters("2026-09-02", "2026-09-02", comparacao="periodo_anterior"))
    prior = build_dashboard(repo, custom_filters("2026-09-01", "2026-09-01"))
    a, b = current["pagantes"]["valor"], prior["pagantes"]["valor"]
    assert current["pagantes"]["variacao"] == (a-b)/b*100


def test_weekdays_and_line_filter(client):
    all_data = client.get("/api/visao-geral", params={"periodo": "semana"}).json()
    weekdays = client.get("/api/visao-geral", params={"periodo": "semana", "dias_uteis": True}).json()
    assert len(all_data["diario"]) == 7
    assert len(weekdays["diario"]) == 5
    line = client.get("/api/linhas", params={"linha": "101"}).json()
    assert len(line["linhas"]) == 1
    assert line["pagantes"]["valor"] is None  # Município não é distribuído artificialmente.
    assert Decimal(line["quilometragem"]["valor"]) < Decimal(all_data["quilometragem"]["valor"])


@pytest.mark.parametrize("query", [
    "periodo=invalido", "periodo=datas", "periodo=datas&data_inicio=2026-02-30&data_fim=2026-03-02",
    "periodo=datas&data_inicio=2026-10-01&data_fim=2026-09-01",
    "periodo=datas&data_inicio=2024-01-01&data_fim=2026-01-01", "data_inicio=2026-09-01", "desconhecido=1",
])
def test_invalid_filters(client, query):
    response = client.get("/api/visao-geral?" + query)
    assert response.status_code == 422
    assert "traceback" not in response.text.lower()


def test_empty_period_and_empty_export(client):
    filters = {"periodo": "datas", "data_inicio": "2025-01-01", "data_fim": "2025-01-02"}
    result = client.get("/api/visao-geral", params=filters).json()
    assert result["sem_dados"] is True
    assert result["quilometragem"]["valor"] is None
    assert client.post("/api/relatorios/gerar", json={"tipo": "operacional_pdf", **filters}).status_code == 422


@pytest.mark.parametrize("route", ["visao-geral", "passageiros", "financeiro", "frota-viagens", "linhas"])
def test_contract_routes(client, route):
    response = client.get("/api/" + route)
    assert response.status_code == 200
    body = response.json()
    assert body["fonte"] == "demo"
    assert body["granularidade"] == "dia"
    assert body["sincronizado_em"] is None
    assert "Motorista" not in response.text


def test_mongo_unconfigured_is_503_not_demo(tmp_path):
    with TestClient(create_app(Settings(uri="", report_dir=tmp_path))) as c:
        assert c.get("/api/health").status_code == 200
        assert c.get("/api/status").status_code == 503
        response = c.get("/api/visao-geral")
        assert response.status_code == 503
        assert "não configurado" in response.json()["detail"]
        assert "2505" not in response.text


def test_mongo_query_projection_and_no_writes():
    calls = []
    class Cursor(list):
        def limit(self, value): return self
        def max_time_ms(self, value): return self
    class Collection:
        def find(self, query, projection):
            calls.append((query, projection))
            return Cursor([])
    repo = MongoRepository(Settings(uri="unused"))
    repo.client = {"semob": {"dados_consulta": Collection()}}
    repo.read(date(2026, 9, 1), date(2026, 9, 2))
    query, projection = calls[0]
    assert query["registro_diario"] and query["fonte_preferencial"]
    assert "valores.Motorista" not in projection
    assert "original" not in projection
    assert projection["valores.kmTotal"] == 1


def test_xlsx_export_matches_same_filters_and_persists(client, tmp_path):
    filters = {"periodo": "datas", "data_inicio": "2026-09-01", "data_fim": "2026-09-03", "linha": "101"}
    reference = client.get("/api/visao-geral", params=filters).json()
    response = client.post("/api/relatorios/gerar", json={"tipo": "operacional_xlsx", **filters})
    assert response.status_code == 201
    metadata = response.json()
    download = client.get(f"/api/relatorios/{metadata['id']}/download")
    book = load_workbook(BytesIO(download.content), data_only=True)
    assert book["Resumo"]["B6"].value == float(reference["quilometragem"]["valor"])
    assert book["Resumo"]["B8"].value is None
    assert book["Diário"].max_row == 4
    assert book["Linhas"].max_row == 2
    with TestClient(create_app(Settings(source="demo", report_dir=tmp_path))) as restarted:
        assert restarted.get("/api/relatorios").json()["recentes"][0]["id"] == metadata["id"]


def test_pdf_is_valid_and_download_unknown_is_404(client):
    response = client.post("/api/relatorios/gerar", json={"tipo": "operacional_pdf", "periodo": "mes"})
    assert response.status_code == 201
    download = client.get(f"/api/relatorios/{response.json()['id']}/download")
    assert download.headers["content-type"] == "application/pdf"
    assert download.content.startswith(b"%PDF-")
    assert download.content.rstrip().endswith(b"%%EOF")
    assert client.get("/api/relatorios/not-a-valid-id/download").status_code == 404


def test_cors_and_host(client):
    assert client.get("/api/health", headers={"Host": "evil.example"}).status_code == 400
    response = client.options("/api/relatorios/gerar", headers={"Origin": "https://evil.example", "Access-Control-Request-Method": "POST"})
    assert "access-control-allow-origin" not in response.headers

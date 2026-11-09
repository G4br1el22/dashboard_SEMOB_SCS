from contextlib import asynccontextmanager
from decimal import Decimal
from typing import Annotated

from fastapi import FastAPI, Query, Request
from fastapi.encoders import jsonable_encoder
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from starlette.middleware.trustedhost import TrustedHostMiddleware

from backend.config.database import ROOT, DataUnavailable, Settings
from backend.models.schemas import Filters, ReportRequest
from backend.repositories.data import DemoRepository, MongoRepository
from backend.services.dashboard import bounds, build_dashboard
from backend.services.reports import ReportStore, TYPES


def json_response(data, status=200):
    # Decimais exatos no contrato, convertidos para visualização apenas no cliente.
    return JSONResponse(jsonable_encoder(data, custom_encoder={Decimal: str}), status_code=status)


def create_app(settings=None, repository=None):
    settings = settings or Settings.load()
    repo = repository or (DemoRepository() if settings.source == "demo" else MongoRepository(settings))
    store = ReportStore(settings.report_dir, repo.source)

    @asynccontextmanager
    async def lifespan(app):
        yield
        repo.close()

    app = FastAPI(title="SEMOB SCS API local", version="1.0.0", lifespan=lifespan)
    app.state.repository = repo
    app.add_middleware(CORSMiddleware, allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?",
                       allow_methods=["GET", "POST"], allow_headers=["Content-Type", "Accept"])
    app.add_middleware(TrustedHostMiddleware, allowed_hosts=["localhost", "127.0.0.1", "testserver"])

    @app.middleware("http")
    async def local_headers(request: Request, call_next):
        response = await call_next(request)
        if request.url.path.startswith("/api/"):
            response.headers["Cache-Control"] = "no-store"
        response.headers["X-Content-Type-Options"] = "nosniff"
        return response

    @app.exception_handler(DataUnavailable)
    async def data_error(request, error):
        return json_response({"detail": str(error)}, 503)

    @app.exception_handler(RequestValidationError)
    async def validation_error(request, error):
        # Não refletir corpo arbitrário, valores de configuração ou objetos internos.
        return json_response({"detail": "Filtros inválidos. Confira período, datas e intervalo máximo de 366 dias."}, 422)

    @app.get("/api/health")
    def health():
        return {"status": "ok", "fonte": repo.source, "mongodb_configurado": bool(settings.uri)}

    @app.get("/api/status")
    def status():
        try:
            latest = repo.latest()
            return {"status": "ok", "fonte": repo.source, "ultima_data_disponivel": latest.isoformat(),
                    "mensagem": "DEMONSTRAÇÃO - dados sintéticos" if repo.source == "demo" else "Consulta à view dados_consulta"}
        except DataUnavailable as error:
            return json_response({"status": "pendente", "fonte": repo.source, "mensagem": str(error)}, 503)

    @app.get("/api/visao-geral")
    @app.get("/api/passageiros")
    @app.get("/api/frota-viagens")
    @app.get("/api/financeiro")
    @app.get("/api/linhas")
    def dashboard(filters: Annotated[Filters, Query()]):
        return json_response(build_dashboard(repo, filters))

    @app.get("/api/relatorios")
    def reports(filters: Annotated[Filters, Query()]):
        start, end = bounds(filters, repo.latest())
        return {"tipos": TYPES, "recentes": store.list(), "sincronizado_em": None, "fonte": repo.source,
                "data_inicio": start.isoformat(), "data_fim": end.isoformat()}

    @app.post("/api/relatorios/gerar", status_code=201)
    def generate(request: ReportRequest):
        filters = Filters.model_validate(request.model_dump(exclude={"tipo"}))
        data = build_dashboard(repo, filters)
        if data["sem_dados"]:
            return json_response({"detail": "Sem dados para gerar relatório no período selecionado."}, 422)
        return json_response(store.generate(request, data), 201)

    @app.get("/api/relatorios/{report_id}/download")
    def download(report_id: str):
        try:
            metadata, path = store.get(report_id)
        except FileNotFoundError:
            return json_response({"detail": "Relatório não encontrado."}, 404)
        mime = "application/pdf" if metadata["formato"] == "pdf" else "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        return FileResponse(path, media_type=mime,
                            filename=f"SEMOB_{metadata['data_inicio']}_{metadata['data_fim']}.{metadata['formato']}")

    web = ROOT / "frontend/build/web"
    if web.is_dir():
        app.mount("/", StaticFiles(directory=web, html=True), name="dashboard")
    return app


app = create_app()

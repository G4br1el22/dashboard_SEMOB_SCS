"""Configuração local. Este módulo nunca modifica o banco remoto."""
from dataclasses import dataclass
from pathlib import Path
import os

from dotenv import load_dotenv
from pymongo import MongoClient

ROOT = Path(__file__).resolve().parents[2]


@dataclass(frozen=True)
class Settings:
    uri: str = ""
    database: str = "semob"
    source: str = "mongo"
    report_dir: Path = ROOT / "backend/local/reports"

    @classmethod
    def load(cls):
        load_dotenv(ROOT / "backend/.env", override=False)
        source = os.getenv("SEMOB_SOURCE", "mongo")
        if source not in {"mongo", "demo"}:
            raise ValueError("SEMOB_SOURCE deve ser mongo ou demo")
        path = Path(os.getenv("SEMOB_REPORT_DIR", str(cls.report_dir)))
        return cls(os.getenv("MONGODB_URI", ""), os.getenv("MONGODB_DB", "semob"),
                   source, path if path.is_absolute() else ROOT / path)


class DataUnavailable(Exception):
    """Erro público sanitizado; nunca inclui URI, documentos ou senha."""


def connect(settings):
    if not settings.uri or "USUARIO:SENHA" in settings.uri:
        raise DataUnavailable("MongoDB não configurado. Execute Configurar MongoDB.cmd na pasta do projeto.")
    try:
        return MongoClient(settings.uri, tls=True, tlsAllowInvalidCertificates=False,
                           tlsAllowInvalidHostnames=False, serverSelectionTimeoutMS=7000,
                           connectTimeoutMS=7000, socketTimeoutMS=30000, maxPoolSize=5,
                           retryWrites=False, appname="semob-dashboard-leitura")
    except Exception:
        raise DataUnavailable("Configuração MongoDB inválida. Confira a configuração local.") from None

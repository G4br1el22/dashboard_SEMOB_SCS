"""Entrada privada da URI no terminal, sem eco e fora do histórico do shell."""
import getpass
import re
from urllib.parse import quote

from dotenv import set_key
from backend.config.database import ROOT, Settings
from backend.tools.verificar_banco import verify


def make_uri(host, username, password):
    if not re.fullmatch(r"[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+\.mongodb\.net", host):
        raise ValueError("Confira o endereço do cluster Atlas.")
    if not username.strip() or not password:
        raise ValueError("Preencha usuário e senha do banco.")
    return f"mongodb+srv://{quote(username.strip(), safe='')}:{quote(password, safe='')}@{host}/?retryWrites=false"


def save_config(uri, database, path=None):
    path = path or ROOT / "backend/.env"
    path.touch(exist_ok=True)
    set_key(path, "MONGODB_URI", uri)
    set_key(path, "MONGODB_DB", database)
    set_key(path, "SEMOB_SOURCE", "mongo")


def main():
    print("Configurar MongoDB Atlas para consulta somente leitura.")
    print("A URI será solicitada sem aparecer na tela e salva em backend/.env, ignorado pelo Git.")
    uri = getpass.getpass("Cole a URI MongoDB SRV completa (entrada oculta): ").strip()
    if not uri.startswith("mongodb+srv://"):
        print("Use a URI SRV fornecida pelo Atlas.")
        return 1
    database = input("Banco [semob]: ").strip() or "semob"
    print("Validando leitura, sem modificar o Atlas...")
    try:
        result = verify(Settings(uri=uri, database=database))
    except Exception:
        print("Não foi possível validar o acesso. Confira senha, IP autorizado e permissão de leitura da view dados_consulta.")
        return 1
    save_config(uri, database)
    print("Configuração salva. Última data disponível:", result["ultima_data"])
    print("Conciliação de quilometragem:", result["conciliacao_km"])
    print("Feche a aplicação com Parar SEMOB.cmd e abra Iniciar SEMOB.cmd.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

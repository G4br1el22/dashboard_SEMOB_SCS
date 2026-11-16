"""Formulário privado local. Credenciais não são enviadas ao navegador ou chat."""
import subprocess
from threading import Thread
import tkinter as tk
from tkinter import ttk
import webbrowser

from pymongo.errors import OperationFailure, ServerSelectionTimeoutError
from backend.config.database import ROOT, DataUnavailable, Settings
from backend.tools.configurar_banco import make_uri, save_config
from backend.tools.verificar_banco import verify


def main():
    root = tk.Tk()
    root.title("SEMOB - Conectar meu banco")
    root.geometry("650x540")
    root.minsize(600, 510)
    root.configure(bg="#f4f7fa")
    style = ttk.Style(root)
    style.theme_use("clam")
    style.configure("TFrame", background="#f4f7fa")
    style.configure("TLabel", background="#f4f7fa", font=("Segoe UI", 10))
    style.configure("Title.TLabel", font=("Segoe UI", 19, "bold"))
    frame = ttk.Frame(root, padding=26)
    frame.pack(fill="both", expand=True)
    ttk.Label(frame, text="Conectar a SEMOB ao MongoDB", style="Title.TLabel").pack(anchor="w")
    ttk.Label(frame, text="Preencha apenas o usuário e a senha do BANCO.\nSão diferentes do login da sua conta no site do Atlas.", wraplength=570).pack(anchor="w", pady=(10, 16))
    fields = {}
    defaults = [("user", "Usuário do banco", ""), ("password", "Senha do banco", ""),
                ("host", "Cluster Atlas (hostname SRV)", ""),
                ("database", "Nome do banco", "semob")]
    for key, label, default in defaults:
        ttk.Label(frame, text=label).pack(anchor="w", pady=(5, 3))
        entry = ttk.Entry(frame, show="●" if key == "password" else "", font=("Segoe UI", 11))
        entry.insert(0, default)
        entry.pack(fill="x", ipady=4)
        fields[key] = entry
    status = tk.StringVar(value="A senha fica apenas na configuração local do projeto. Nenhum dado do banco será alterado.")
    ttk.Label(frame, textvariable=status, wraplength=570, foreground="#374d63").pack(anchor="w", pady=(15, 10))

    def done(message, ok=False):
        status.set(message)
        button.configure(state="normal", text="Conectar e abrir o dashboard" if not ok else "Conectado - abrir novamente")
        if ok:
            fields["password"].delete(0, "end")
            button.configure(command=lambda: webbrowser.open("http://127.0.0.1:8765"))
            webbrowser.open("http://127.0.0.1:8765")

    def connect_click():
        try:
            uri = make_uri(fields["host"].get().strip(), fields["user"].get(), fields["password"].get())
            database = fields["database"].get().strip() or "semob"
        except ValueError as error:
            status.set(str(error))
            return
        button.configure(state="disabled", text="Testando conexão…")
        status.set("Verificando leitura e conciliando os dados. Aguarde até um minuto…")

        def worker():
            try:
                result = verify(Settings(uri=uri, database=database))
                save_config(uri, database)
            except OperationFailure as error:
                message = ("Usuário ou senha do banco incorretos. Confira em Atlas > Database Access."
                           if error.code == 18 else "Esse usuário não possui acesso de leitura necessário ao banco e à view dados_consulta.")
                root.after(0, lambda: done(message))
                return
            except ServerSelectionTimeoutError:
                root.after(0, lambda: done("O cluster não respondeu. Confira no Atlas se está ativo e se seu IP atual está autorizado em Network Access."))
                return
            except DataUnavailable as error:
                message = str(error)
                root.after(0, lambda: done(message))
                return
            except Exception:
                root.after(0, lambda: done("Não foi possível conectar. Confira cluster, usuário, senha e IP autorizado no Atlas. Nenhuma senha foi exibida ou enviada ao chat."))
                return
            process = subprocess.run(
                ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(ROOT / "start.ps1"), "-Restart", "-NoBrowser"],
                cwd=ROOT, capture_output=True, creationflags=subprocess.CREATE_NO_WINDOW,
            )
            if process.returncode != 0:
                root.after(0, lambda: done("Conexão validada e salva. Abra Iniciar SEMOB.cmd para iniciar o dashboard."))
                return
            message = f"Conectado! Última data disponível: {result['ultima_data']}. O dashboard está aberto com seu banco real."
            root.after(0, lambda: done(message, ok=True))

        Thread(target=worker, daemon=True).start()

    button = ttk.Button(frame, text="Conectar e abrir o dashboard", command=connect_click)
    button.pack(fill="x", ipady=8)
    fields["user"].focus_set()
    root.mainloop()


if __name__ == "__main__":
    main()

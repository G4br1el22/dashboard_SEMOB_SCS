@echo off
cd /d "%~dp0"
start "" ".venv\Scripts\pythonw.exe" -m backend.tools.configurar_gui

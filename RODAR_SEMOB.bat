@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0rodar.ps1" %*
set "semobExit=%errorlevel%"
if not "%semobExit%"=="0" (
  echo.
  echo Nao foi possivel iniciar. Confira a mensagem acima.
  pause
)
exit /b %semobExit%

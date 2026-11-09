param([string]$FlutterSdk)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
function Check-Exit([string]$Step) { if ($LASTEXITCODE -ne 0) { throw "Falha: $Step" } }
if (!(Test-Path -LiteralPath '.venv/Scripts/python.exe')) {
    python -m venv .venv
    Check-Exit 'criacao do ambiente Python'
}
& '.venv/Scripts/python.exe' -m pip install -r backend/requirements-lock.txt
Check-Exit 'dependencias Python'
if (!$FlutterSdk -and (Test-Path -LiteralPath 'backend/local/flutter-sdk.txt')) {
    $FlutterSdk = (Get-Content -LiteralPath 'backend/local/flutter-sdk.txt' -Raw).Trim()
}
if (!$FlutterSdk -or !(Test-Path -LiteralPath (Join-Path $FlutterSdk 'bin/flutter.bat'))) {
    $found = Get-Command flutter -ErrorAction SilentlyContinue
    if ($found) { $FlutterSdk = Split-Path (Split-Path $found.Source -Parent) -Parent }
    else {
        $FlutterSdk = Join-Path $PSScriptRoot '.tools/flutter'
        if (!(Test-Path -LiteralPath (Join-Path $FlutterSdk 'bin/flutter.bat'))) {
            git clone --depth 1 --branch 3.47.9 https://github.com/flutter/flutter.git $FlutterSdk
            Check-Exit 'instalacao Flutter 3.47.9'
        }
    }
}
$flutter = Join-Path $FlutterSdk 'bin/flutter.bat'
& $flutter config --no-enable-windows-desktop
Check-Exit 'configuracao Flutter web'
Push-Location frontend
try {
    & $flutter pub get --enforce-lockfile
    Check-Exit 'dependencias Flutter'
    & $flutter analyze
    Check-Exit 'analise Flutter'
    & $flutter test
    Check-Exit 'testes Flutter'
    & $flutter build web --release --no-web-resources-cdn --dart-define=USE_MOCK=false
    Check-Exit 'build web'
} finally { Pop-Location }
& '.venv/Scripts/python.exe' -m pytest -q
Check-Exit 'testes backend'
& '.venv/Scripts/python.exe' -m unittest discover -s backend/tools -p test_import_semob.py
Check-Exit 'testes importador'
Write-Output 'Instalacao pronta. Abra Demonstracao SEMOB.cmd ou configure o Atlas e abra Iniciar SEMOB.cmd.'

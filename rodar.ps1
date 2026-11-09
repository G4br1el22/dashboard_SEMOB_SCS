param(
    [switch]$Demo,
    [switch]$Real,
    [switch]$Reinstalar,
    [switch]$PrepararSomente,
    [switch]$NoBrowser,
    [switch]$SemInstalarSistema,
    [string]$FlutterSdk
)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

function Refresh-TaskPath {
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User') + ';' + $env:Path
    foreach ($candidate in @((Join-Path $env:ProgramFiles 'Git/cmd'),(Join-Path $env:LOCALAPPDATA 'Programs/Python/Launcher'),(Join-Path $env:LOCALAPPDATA 'Programs/Python/Python313'))) {
        if (Test-Path -LiteralPath $candidate) { $env:Path += ';' + $candidate }
    }
}
function Find-Python313 {
    $launcher=Get-Command py -ErrorAction SilentlyContinue
    if ($launcher) {
        try {
            $version=& $launcher.Source -3.13 -c 'import sys; print(sys.version_info[:2] == (3, 13))' 2>$null
            if ($LASTEXITCODE -eq 0 -and $version -eq 'True') { return @{exe=$launcher.Source;prefix=@('-3.13')} }
        } catch {}
    }
    $python=Get-Command python -ErrorAction SilentlyContinue
    if ($python -and $python.Source -notlike '*Microsoft/WindowsApps*' -and $python.Source -notlike '*Microsoft\WindowsApps*') {
        try {
            $version=& $python.Source -c 'import sys; print(sys.version_info[:2] == (3, 13))' 2>$null
            if ($LASTEXITCODE -eq 0 -and $version -eq 'True') { return @{exe=$python.Source;prefix=@()} }
        } catch {}
    }
    return $null
}
function Install-SystemPackage([string]$PackageId) {
    if ($SemInstalarSistema) { throw "Dependencia ausente: $PackageId. Instalacao automatica foi desabilitada." }
    if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'WinGet indisponivel. Instale Git em https://git-scm.com/downloads/win e Python 3.13 em https://www.python.org/downloads/windows/ e execute novamente.'
    }
    Write-Host "Instalando $PackageId pela fonte oficial do WinGet. Se houver uma janela de permissao, conclua-a."
    & winget install --id $PackageId --exact --source winget
    if ($LASTEXITCODE -ne 0) { throw "A instalacao de $PackageId nao terminou. Conclua o instalador e execute o BAT novamente." }
    Refresh-TaskPath
}
function Get-SourceFingerprint {
    $inputs=@('backend/requirements-lock.txt','frontend/pubspec.yaml','frontend/pubspec.lock','instalar.ps1')
    foreach ($directory in @('backend','frontend/lib','frontend/test','frontend/web')) {
        $inputs+=@(Get-ChildItem -LiteralPath $directory -Recurse -File | Where-Object {
            $_.FullName -notlike '*\local\*' -and $_.FullName -notlike '*/local/*' -and $_.Extension -in @('.py','.dart','.html','.json')
        } | ForEach-Object { $_.FullName })
    }
    $hashes=@($inputs | Sort-Object -Unique | ForEach-Object {
        $fileHash=[Security.Cryptography.SHA256]::Create()
        try { ([BitConverter]::ToString($fileHash.ComputeHash([IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $_).Path)))).Replace('-','') }
        finally { $fileHash.Dispose() }
    })
    $sha=[Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes(($hashes -join '|'))))).Replace('-','').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

try {
    if ($Demo -and $Real) { throw 'Escolha somente -Demo ou -Real.' }
    Refresh-TaskPath
    if (!(Get-Command git -ErrorAction SilentlyContinue)) { Install-SystemPackage 'Git.Git' }
    if (!(Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git nao foi encontrado. Reabra o BAT apos instalar Git.' }
    $python=Find-Python313
    if (!$python) { Install-SystemPackage 'Python.Python.3.13'; $python=Find-Python313 }
    if (!$python) { throw 'Python 3.13 nao foi encontrado. Reabra o BAT depois da instalacao.' }
    $venv=Join-Path $PSScriptRoot '.venv/Scripts/python.exe'
    if (!(Test-Path -LiteralPath $venv)) {
        Write-Host 'Criando ambiente Python local...'
        & $python.exe @($python.prefix) -m venv .venv
        if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel criar .venv.' }
    }
    $local=Join-Path $PSScriptRoot 'backend/local'
    New-Item -ItemType Directory -Path $local -Force | Out-Null
    $fingerprint=Get-SourceFingerprint
    $marker=Join-Path $local 'ambiente-pronto.json'
    $prepared=$false
    if (!$Reinstalar -and (Test-Path -LiteralPath $marker) -and (Test-Path -LiteralPath 'frontend/build/web/index.html')) {
        try {
            $saved=Get-Content -LiteralPath $marker -Raw | ConvertFrom-Json
            & $venv -c 'import fastapi, pymongo, reportlab, openpyxl, httpx' 2>$null
            $prepared=$LASTEXITCODE -eq 0 -and $saved.fingerprint -eq $fingerprint
        } catch { $prepared=$false }
    }
    if (!$prepared) {
        Write-Host 'Preparando dependencias, Flutter, testes e build web. A primeira execucao pode levar alguns minutos...'
        $installerArgs=@('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $PSScriptRoot 'instalar.ps1'))
        if ($FlutterSdk) { $installerArgs+=@('-FlutterSdk',$FlutterSdk) }
        & powershell.exe @installerArgs
        if ($LASTEXITCODE -ne 0) { throw 'Instalacao ou validacao falhou. Corrija a mensagem anterior e execute o BAT novamente.' }
        @{fingerprint=$fingerprint;prepared_utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json | Set-Content -LiteralPath $marker -Encoding UTF8
    } else { Write-Host 'Dependencias e build ja estao preparados.' }
    if ($PrepararSomente) { Write-Host 'Preparacao concluida. Nenhum servidor ou navegador foi aberto.'; exit 0 }
    $mode=& $venv -c "from backend.config.database import Settings; s=Settings.load(); print('mongo' if s.uri and 'USUARIO:SENHA' not in s.uri and s.source != 'demo' else 'demo')"
    if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel ler a configuracao local.' }
    if ($Real -and $mode -ne 'mongo') {
        Write-Host 'Preencha sua conexao na janela privada. Nenhuma senha sera exibida no terminal.'
        Start-Process -FilePath (Join-Path $PSScriptRoot '.venv/Scripts/pythonw.exe') -ArgumentList @('-m','backend.tools.configurar_gui') -WorkingDirectory $PSScriptRoot -WindowStyle Normal
        exit 0
    }
    $useDemo=$Demo -or (!$Real -and $mode -ne 'mongo')
    if ($useDemo) { Write-Host 'Abrindo DEMONSTRACAO identificada. Para dados reais, execute Configurar MongoDB.cmd.' }
    else { Write-Host 'Abrindo a aplicacao com a configuracao MongoDB local.' }
    & (Join-Path $PSScriptRoot 'start.ps1') -Demo:$useDemo -NoBrowser:$NoBrowser
} catch { Write-Error $_.Exception.Message; exit 1 }

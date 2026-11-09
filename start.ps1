param([switch]$Demo, [switch]$Stop, [switch]$NoBrowser, [switch]$Restart)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$pythonPath = Join-Path $PSScriptRoot '.venv/Scripts/python.exe'
$localPath = Join-Path $PSScriptRoot 'backend/local'
New-Item -ItemType Directory -Path $localPath -Force | Out-Null
if ($Stop) {
    foreach ($stateFile in Get-ChildItem -LiteralPath $localPath -Filter 'server-*.json') {
        $state = Get-Content -LiteralPath $stateFile.FullName -Raw | ConvertFrom-Json
        $processInfo = Get-CimInstance Win32_Process -Filter "ProcessId = $($state.pid)"
        if ($processInfo -and $processInfo.ExecutablePath -eq $pythonPath -and $processInfo.CommandLine -like '*backend.main:app*') {
            Stop-Process -Id $state.pid
        }
        Remove-Item -LiteralPath $stateFile.FullName -Force
    }
    Write-Output 'Servidores SEMOB encerrados.'
    exit
}
if (!(Test-Path -LiteralPath $pythonPath)) { throw 'Execute instalar.ps1 para preparar as dependencias.' }
if (!(Test-Path -LiteralPath 'frontend/build/web/index.html')) { throw 'Build web ausente. Execute instalar.ps1.' }
$port = if ($Demo) { 8766 } else { 8765 }
$source = if ($Demo) { 'demo' } else { 'mongo' }
$url = "http://127.0.0.1:$port"
if ($Restart) {
    $statePath = Join-Path $localPath "server-$source.json"
    if (Test-Path -LiteralPath $statePath) {
        $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
        $processInfo = Get-CimInstance Win32_Process -Filter "ProcessId = $($state.pid)"
        if ($processInfo -and $processInfo.ExecutablePath -eq $pythonPath -and $processInfo.CommandLine -like '*backend.main:app*') {
            Stop-Process -Id $state.pid
            for ($attempt=0; $attempt -lt 20; $attempt++) {
                if (!(Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue)) { break }
                Start-Sleep -Milliseconds 100
            }
        }
    }
}
$alive = $false
try {
    $health = Invoke-RestMethod "$url/api/health" -TimeoutSec 2
    if ($health.status -eq 'ok' -and $health.fonte -eq $source) { $alive = $true }
    else { throw 'Porta ocupada por outra aplicacao.' }
} catch {
    if (Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue) { throw "Porta $port ocupada. Confira antes de iniciar." }
}
if (!$alive) {
    $env:SEMOB_SOURCE = $source
    $process = Start-Process -FilePath $pythonPath -ArgumentList @('-m','uvicorn','backend.main:app','--host','127.0.0.1','--port',"$port") -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput "$localPath/server-$source.log" -RedirectStandardError "$localPath/server-$source-error.log"
    @{pid=$process.Id; port=$port; source=$source; url=$url} | ConvertTo-Json | Set-Content -LiteralPath "$localPath/server-$source.json"
    for ($attempt=0; $attempt -lt 40; $attempt++) {
        Start-Sleep -Milliseconds 250
        try { $health=Invoke-RestMethod "$url/api/health" -TimeoutSec 1; $alive=$true; break } catch {}
    }
    if (!$alive) { throw "Servidor nao iniciou. Consulte backend/local/server-$source-error.log" }
}
Write-Output "SEMOB em $url (fonte: $source)"
if (!$NoBrowser) { Start-Process $url }

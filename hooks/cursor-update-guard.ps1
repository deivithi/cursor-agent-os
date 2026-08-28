# cursor-update-guard.ps1 — previne e conserta updates quebrados do Cursor
#
# Problema (incidentes 07/07 e 08/07/2026): MCP servers stdio spawnados pelo Cursor
# via npx não morrem quando o app fecha. Os órfãos rodam com o node bundled de
# resources\app\resources\helpers\node.exe e seguram lock em resources\, fazendo o
# inno_updater abortar com "Acesso negado (os error 5)" no meio do swap — a raiz
# fica sem Cursor.exe e o app "some". A versão nova fica staged na pasta _\.
#
# Este guard roda via Scheduled Task "Cursor-Update-Guard" (logon + a cada 1h):
#   1. Cursor fechado → mata qualquer processo rodando de dentro de Programs\cursor (órfão)
#   2. Estado quebrado (_\Cursor.exe existe, raiz sem Cursor.exe) → completa o swap
#   3. Cursor aberto → não faz nada (filhos são legítimos)
#
# Dados do usuário (%APPDATA%\Cursor, ~\.cursor) nunca são tocados.

$ErrorActionPreference = 'Stop'
$root = Join-Path $env:LOCALAPPDATA 'Programs\cursor'
$logFile = Join-Path $env:LOCALAPPDATA 'cursor-update-guard.log'

function Write-Log([string]$msg) {
    $line = "{0:yyyy-MM-dd HH:mm:ss} $msg" -f (Get-Date)
    Add-Content -Path $logFile -Value $line -Encoding UTF8
}

# Rotação simples do log
if ((Test-Path $logFile) -and (Get-Item $logFile).Length -gt 1MB) {
    Get-Content $logFile -Tail 200 | Set-Content $logFile -Encoding UTF8
}

if (-not (Test-Path $root)) { Write-Log "Pasta $root não existe — nada a fazer."; exit 0 }

$mainExe = Join-Path $root 'Cursor.exe'
$stagedExe = Join-Path $root '_\Cursor.exe'

# Cursor principal rodando? (processo cujo path é exatamente a raiz\Cursor.exe)
$cursorRunning = @(Get-Process -Name Cursor -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -eq $mainExe }).Count -gt 0

if ($cursorRunning) {
    # App aberto: filhos são legítimos. Não agir.
    exit 0
}

# --- Passo 1: matar órfãos (Cursor fechado, mas processos rodando de dentro da pasta) ---
$orphans = @(Get-Process -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -and $_.Path.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase) })

if ($orphans.Count -gt 0) {
    foreach ($p in $orphans) {
        Write-Log "Órfão detectado (Cursor fechado): PID $($p.Id) $($p.ProcessName) — $($p.Path). Matando."
        try { Stop-Process -Id $p.Id -Force -ErrorAction Stop } catch { Write-Log "Falha ao matar PID $($p.Id): $_" }
    }
}

# --- Passo 2: auto-repair de swap abortado ---
if ((Test-Path $stagedExe) -and (-not (Test-Path $mainExe))) {
    Write-Log "Estado quebrado detectado: versão staged em _\ e raiz sem Cursor.exe. Iniciando auto-repair."
    Start-Sleep -Seconds 2  # garante que handles dos órfãos mortos foram liberados
    try {
        foreach ($d in 'resources', 'locales', 'policies') {
            $p = Join-Path $root $d
            if (Test-Path $p) { Remove-Item $p -Recurse -Force }
        }
        Get-ChildItem (Join-Path $root '_') -Force | Move-Item -Destination $root -Force
        Remove-Item (Join-Path $root '_') -Force
        $ver = (Get-Item $mainExe).VersionInfo.ProductVersion
        Write-Log "Auto-repair concluído. Cursor $ver restaurado na raiz."
    } catch {
        Write-Log "Auto-repair FALHOU: $_"
        exit 1
    }
}

exit 0

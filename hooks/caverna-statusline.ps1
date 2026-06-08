# Força UTF-8 output para renderizar emoji 🪨 corretamente
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

function Get-CavernaFlagPath {
    if ($env:CAVERNA_FLAG_PATH) { return $env:CAVERNA_FLAG_PATH }
    $cursorFlag = Join-Path $HOME ".cursor\.caverna-active"
    if (Test-Path -LiteralPath $cursorFlag) { return $cursorFlag }
    $claudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME ".claude" }
    return Join-Path $claudeDir ".caverna-active"
}

$Flag = Get-CavernaFlagPath
if (-not (Test-Path -LiteralPath $Flag)) { exit 0 }

try {
    $Item = Get-Item -LiteralPath $Flag -Force -ErrorAction Stop
    if ($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { exit 0 }
    if ($Item.Length -gt 64) { exit 0 }
} catch {
    exit 0
}

$Mode = ""
try {
    $Raw = Get-Content -LiteralPath $Flag -TotalCount 1 -ErrorAction Stop
    if ($null -ne $Raw) { $Mode = ([string]$Raw).Trim() }
} catch {
    exit 0
}

$Mode = $Mode.ToLowerInvariant()
$Mode = ($Mode -replace '[^a-z0-9-]', '')

$Valid = @('off','leve','completo','ultra','commit','review','compress')
if (-not ($Valid -contains $Mode)) { exit 0 }

$Esc = [char]27
$Rock = [char]::ConvertFromUtf32(0x1FAA8)

if ([string]::IsNullOrEmpty($Mode)) {
    [Console]::Write("${Esc}[38;5;172m[$Rock CAVERNA]${Esc}[0m")
} else {
    $Suffix = $Mode.ToUpperInvariant()
    [Console]::Write("${Esc}[38;5;172m[$Rock CAVERNA:$Suffix]${Esc}[0m")
}

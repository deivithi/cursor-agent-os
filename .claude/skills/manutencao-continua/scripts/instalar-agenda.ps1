#Requires -Version 5.1
<#
.SYNOPSIS
  Instala (ou atualiza) a tarefa agendada do ciclo de manutenção contínua. Idempotente.
.DESCRIPTION
  Todo dia às 07:30 roda o porteiro scripts/ciclo.mjs. Se o PC estava desligado, roda quando ligar
  (StartWhenAvailable). Roda na sessão do usuário: precisa do keyring do gh e do login do Claude Code.
  O console fica oculto (conhost --headless). Limite de 8 h por execução (até 60 min por item corrigido).
#>
param(
  [string]$Hora = '07:30',
  [switch]$Remover
)
$ErrorActionPreference = 'Stop'
$nome = 'Febracis-Manutencao-Continua'

if ($Remover) {
  Unregister-ScheduledTask -TaskName $nome -Confirm:$false -ErrorAction SilentlyContinue
  Write-Output "removida: $nome"
  return
}

$node = (Get-Command node -ErrorAction Stop).Source
$ciclo = Join-Path $PSScriptRoot 'ciclo.mjs'
if (-not (Test-Path $ciclo)) { throw "ciclo.mjs não encontrado em $PSScriptRoot" }

$conhost = Join-Path $env:WINDIR 'System32\conhost.exe'
$acao = New-ScheduledTaskAction -Execute $conhost -Argument "--headless `"$node`" `"$ciclo`"" -WorkingDirectory $PSScriptRoot
$gatilho = New-ScheduledTaskTrigger -Daily -At $Hora
$config = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
  -ExecutionTimeLimit (New-TimeSpan -Hours 8) -MultipleInstances IgnoreNew
$quem = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $nome -Action $acao -Trigger $gatilho -Settings $config -Principal $quem `
  -Description 'Manutenção contínua (skill manutencao-continua): coleta sinais, triagem e agente só quando há trabalho.' -Force | Out-Null

$t = Get-ScheduledTask -TaskName $nome
Write-Output "instalada: $nome · estado $($t.State) · todo dia às $Hora"

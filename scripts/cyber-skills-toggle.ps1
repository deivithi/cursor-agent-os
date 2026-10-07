<#
.SYNOPSIS
  Liga ou desliga as skills cyber-* no catálogo ativo do Claude Code (ADR-016).

.DESCRIPTION
  Cada skill cyber-* em .claude/skills é uma junction para cybersecurity-skills/skills/<nome>.
  -Disable remove só as junctions (o conteúdo em cybersecurity-skills/ fica intacto).
  -Enable recria uma junction para cada pasta de cybersecurity-skills/skills/.
  Desligadas, as skills continuam acessíveis pelo comando /cyber.

.EXAMPLE
  pwsh -File scripts/cyber-skills-toggle.ps1 -Disable
  pwsh -File scripts/cyber-skills-toggle.ps1 -Enable
#>
[CmdletBinding()]
param(
  [switch]$Disable,
  [switch]$Enable
)

$ErrorActionPreference = 'Stop'
if ($Disable -eq $Enable) { throw 'Use exatamente um: -Disable ou -Enable.' }

$root = Split-Path -Parent $PSScriptRoot
$skillsDir = Join-Path $root '.claude\skills'
$sourceDir = Join-Path $root 'cybersecurity-skills\skills'

if ($Disable) {
  $links = Get-ChildItem $skillsDir -Directory -Filter 'cyber-*'
  $removed = 0
  foreach ($l in $links) {
    if ($l.LinkType -ne 'Junction') {
      Write-Warning "ignorado (não é junction, não removo): $($l.Name)"
      continue
    }
    # Directory.Delete sem recursão remove só o reparse point, nunca o destino.
    [System.IO.Directory]::Delete($l.FullName, $false)
    $removed++
  }
  Write-Output "desligadas: $removed junction(s) cyber-*"
}

if ($Enable) {
  if (-not (Test-Path $sourceDir)) { throw "fonte ausente: $sourceDir" }
  $created = 0
  foreach ($d in Get-ChildItem $sourceDir -Directory) {
    $link = Join-Path $skillsDir ('cyber-' + $d.Name)
    if (Test-Path $link) { continue }
    New-Item -ItemType Junction -Path $link -Target $d.FullName | Out-Null
    $created++
  }
  Write-Output "ligadas: $created junction(s) cyber-*"
}

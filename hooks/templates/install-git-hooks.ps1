<#
.SYNOPSIS
  Instala o git pre-commit hook (branch protection + test/lint gate) num projeto.
.DESCRIPTION
  Copia git-pre-commit.sh para <projeto>\.git\hooks\pre-commit.
  Boas práticas Akita/Galego: nunca commitar em main sem PR; rodar testes antes de commitar.
.PARAMETER ProjectPath
  Raiz do repositório git alvo. Default: diretório atual.
.EXAMPLE
  pwsh hooks\templates\install-git-hooks.ps1 -ProjectPath C:\Users\me\dev\pulsofinance
#>
param(
  [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

$gitDir = Join-Path $ProjectPath '.git'
if (-not (Test-Path $gitDir)) {
  Write-Error "Não é um repositório git: $ProjectPath (sem .git)"
  exit 1
}

$hooksDir = Join-Path $gitDir 'hooks'
if (-not (Test-Path $hooksDir)) { New-Item -ItemType Directory -Path $hooksDir | Out-Null }

$src = Join-Path $PSScriptRoot 'git-pre-commit.sh'
$dst = Join-Path $hooksDir 'pre-commit'

if ((Test-Path $dst) -and -not $env:FORCE_INSTALL) {
  Write-Warning "Já existe pre-commit em $dst. Faça backup ou rode com `$env:FORCE_INSTALL=1`."
  exit 1
}

# Copia preservando LF (git no Windows roda hooks via sh — precisa de \n).
$content = (Get-Content -Raw $src) -replace "`r`n", "`n"
[System.IO.File]::WriteAllText($dst, $content)

Write-Host "✅ pre-commit instalado em: $dst"
Write-Host "   Testar:  cd `"$ProjectPath`"; git commit (em branch normal, deve rodar o gate)"
Write-Host "   Bypass:  git commit --no-verify   |   pular testes: `$env:PRECOMMIT_SKIP_TESTS=1"

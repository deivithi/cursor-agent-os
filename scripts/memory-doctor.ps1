<#
memory-doctor.ps1 — diagnóstico e regeneração do estado de memória do ecossistema.

Por que existe: os arquivos de memória declaravam números escritos à mão (skills,
worktrees, commits, datas) que envelheciam em silêncio. Este script recomputa esses
fatos do disco e do Git — a fonte de verdade — e grava dois artefatos gerados:

  1. <workspace>/MEMORY_STATE.md          — snapshot legível no repositório
  2. $DSH_HOME/AGENTS.md                  — bloco de estado dentro do arquivo que o
                                            DSH injeta sozinho em toda sessão

O item 2 é o que faz a memória funcionar sem comando: no DSH só AGENTS.md/CLAUDE.md
entram no contexto por conta própria (nenhum hook do workspace é montado lá).

Uso:
  pwsh -File memory-doctor.ps1                 # diagnostica e regenera os dois artefatos
  pwsh -File memory-doctor.ps1 -NoWrite        # só diagnostica
  pwsh -File memory-doctor.ps1 -Quiet          # só o bloco de injeção
  pwsh -File memory-doctor.ps1 -WorkspaceRoot <path>

Nota de implementação: este script NÃO usa o operador -f. Dentro de chamadas de
método o PowerShell lê `-f` como nome de parâmetro (`$list.Add('x {0}' -f $v)` falha
com "Index (zero based)"). Toda composição aqui é por concatenação explícita.
#>

[CmdletBinding()]
param(
  [switch]$NoWrite,
  [switch]$Quiet,
  [string]$WorkspaceRoot
)

$ErrorActionPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

# ---------------------------------------------------------------- localização

function Resolve-WorkspaceRoot {
  if ($WorkspaceRoot -and (Test-Path $WorkspaceRoot)) { return $WorkspaceRoot }
  if ($env:CURSOR_PROJECT_DIR -and (Test-Path $env:CURSOR_PROJECT_DIR)) { return $env:CURSOR_PROJECT_DIR }
  return (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

$Root = Resolve-WorkspaceRoot
$StateFile = Join-Path $Root 'MEMORY_STATE.md'
$DshHome = if ($env:DSH_HOME) { $env:DSH_HOME } else { Join-Path $env:USERPROFILE '.dsh' }
$DshGlobalFile = Join-Path $DshHome 'AGENTS.md'
$Today = Get-Date

$BeginMarker = '<!-- BEGIN GENERATED: memory-state -->'
$EndMarker = '<!-- END GENERATED: memory-state -->'

# ---------------------------------------------------------------- utilitários

function Code([string]$v) { return '`' + $v + '`' }

function Count-SkillDirs([string]$p) {
  if (-not (Test-Path $p)) { return 0 }
  return @(Get-ChildItem $p -Directory -ErrorAction SilentlyContinue).Count
}

function Get-SkillCount([string]$p) {
  if (-not (Test-Path $p)) { return 0 }
  $dirs = Get-ChildItem $p -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne '_templates' }
  return @($dirs | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') }).Count
}

function Get-SkillDirsMissingManifest([string]$p) {
  if (-not (Test-Path $p)) { return @() }
  $dirs = Get-ChildItem $p -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne '_templates' }
  return @($dirs | Where-Object { -not (Test-Path (Join-Path $_.FullName 'SKILL.md')) } | ForEach-Object { $_.Name })
}

function Count-Files([string]$p, [string]$filter) {
  if (-not (Test-Path $p)) { return 0 }
  return @(Get-ChildItem $p -File -Filter $filter -ErrorAction SilentlyContinue).Count
}

function Invoke-Git([string]$repo, [string[]]$arguments) {
  if (-not (Test-Path $repo)) { return '' }
  $out = & git -C $repo @arguments 2>$null
  if ($LASTEXITCODE -ne 0) { return '' }
  return ($out -join "`n").Trim()
}

function Test-GitRepo([string]$p) {
  # worktree usa .git como ARQUIVO; repo normal usa como DIRETÓRIO. Ambos valem.
  return (Test-Path (Join-Path $p '.git'))
}

function Get-RepoInfo([string]$relative) {
  $abs = Join-Path $Root $relative
  $info = [ordered]@{
    path    = $relative
    exists  = (Test-Path $abs)
    repo    = $false
    head    = ''
    date    = ''
    subject = ''
    dirtyN  = 0
    ahead   = ''
    behind  = ''
  }
  if (-not $info.exists) { return $info }
  if (-not (Test-GitRepo $abs)) { return $info }
  $info.repo = $true
  $head = Invoke-Git $abs @('log', '-1', '--format=%h%x09%ad%x09%s', '--date=short')
  if ($head) {
    $parts = $head -split "`t", 3
    $info.head = $parts[0]
    if ($parts.Count -gt 1) { $info.date = $parts[1] }
    if ($parts.Count -gt 2) { $info.subject = $parts[2] }
  }
  $statusLines = @(Invoke-Git $abs @('status', '--porcelain') -split "`n" | Where-Object { $_ })
  $info.dirtyN = $statusLines.Count
  $lr = Invoke-Git $abs @('rev-list', '--left-right', '--count', 'origin/main...HEAD')
  if ($lr -match '^(\d+)\s+(\d+)$') { $info.behind = $Matches[1]; $info.ahead = $Matches[2] }
  return $info
}

function Get-DeclaredDate([string]$relative, [string]$pattern) {
  # Devolve a data MAIS RECENTE entre todas as datas de todas as linhas que casam o padrão.
  # Dois detalhes importam aqui, e ambos já causaram leitura errada:
  #  1. varrer TODAS as linhas — DECISIONS.md tem "Iniciado em: 08/06/2026" no topo e a data
  #     real depois; pegar só a primeira reportava 114 dias de atraso num arquivo atual.
  #  2. extrair TODAS as datas de cada linha — a linha do DECISIONS.md tem duas datas
  #     ("Iniciado em 08/06/2026 · Última atualização: 30/09/2026") e o -match devolve só a
  #     primeira, que é a antiguidade, não a atualidade.
  $abs = Join-Path $Root $relative
  if (-not (Test-Path $abs)) { return $null }
  $rows = Select-String -Path $abs -Pattern $pattern -ErrorAction SilentlyContinue
  $best = $null
  foreach ($row in $rows) {
    foreach ($hit in [regex]::Matches($row.Line, '(\d{4})-(\d{2})-(\d{2})')) {
      $candidate = [datetime]::new([int]$hit.Groups[1].Value, [int]$hit.Groups[2].Value, [int]$hit.Groups[3].Value)
      if (-not $best -or $candidate -gt $best) { $best = $candidate }
    }
    foreach ($hit in [regex]::Matches($row.Line, '(\d{2})/(\d{2})/(\d{4})')) {
      $candidate = [datetime]::new([int]$hit.Groups[3].Value, [int]$hit.Groups[2].Value, [int]$hit.Groups[1].Value)
      if (-not $best -or $candidate -gt $best) { $best = $candidate }
    }
  }
  return $best
}

# ---------------------------------------------------------------- coleta

$customDirs = Count-SkillDirs (Join-Path $Root 'skills')
$customSkills = Get-SkillCount (Join-Path $Root 'skills')
$customNoManifest = Get-SkillDirsMissingManifest (Join-Path $Root 'skills')
$cyberSkills = Get-SkillCount (Join-Path $Root 'cybersecurity-skills\skills')
$cyberDirs = Count-SkillDirs (Join-Path $Root 'cybersecurity-skills\skills')
$sciSkills = Get-SkillCount (Join-Path $Root 'scientific-skills\skills')
$commandsCount = Count-Files (Join-Path $Root 'commands') '*.md'
$rulesCount = Count-Files (Join-Path $Root 'rules') '*.md'
$hooksCount = Count-Files (Join-Path $Root 'hooks') '*.js'
$hooksExtras = Count-Files (Join-Path $Root 'hooks') '*.ps1'
$scriptsCount = @(Get-ChildItem (Join-Path $Root 'scripts') -Recurse -File -ErrorAction SilentlyContinue).Count
$cursorSkillsCount = Count-SkillDirs (Join-Path $env:USERPROFILE '.cursor\skills')
$cursorSkillsCursorCount = Count-SkillDirs (Join-Path $env:USERPROFILE '.cursor\skills-cursor')

$worktreeDirs = @(Get-ChildItem (Join-Path $Root 'worktrees') -Directory -ErrorAction SilentlyContinue | Sort-Object Name)
$worktrees = @()
foreach ($d in $worktreeDirs) {
  $real = Test-GitRepo $d.FullName
  $head = ''
  if ($real) { $head = (Invoke-Git $d.FullName @('log', '-1', '--format=%h')) }
  $worktrees += [pscustomobject]@{ name = $d.Name; repo = $real; head = $head }
}
$worktreeRepos = @($worktrees | Where-Object { $_.repo })
$worktreeShells = @($worktrees | Where-Object { -not $_.repo })

$repoList = @('DRE_Eventos', 'declaw', 'webwright', 'cybersecurity-skills', 'scientific-skills', 'worktrees\dre-eventos-fix')
$repos = @()
foreach ($r in $repoList) { $repos += (Get-RepoInfo $r) }

# sync do Cursor: sem isso, ~/.cursor/skills congela em silêncio
$syncTaskName = 'Febracis-Cursor-SyncDaily'
$syncTaskState = 'desconhecido'
$syncTaskLastRun = ''
try {
  $task = Get-ScheduledTask -TaskName $syncTaskName -ErrorAction Stop
  $syncTaskState = [string]$task.State
  $taskInfo = Get-ScheduledTaskInfo -TaskName $syncTaskName -ErrorAction SilentlyContinue
  if ($taskInfo -and $taskInfo.LastRunTime) { $syncTaskLastRun = $taskInfo.LastRunTime.ToString('yyyy-MM-dd') }
} catch {
  $syncTaskState = 'ausente'
}
$syncTaskHealthy = ($syncTaskState -eq 'Ready' -or $syncTaskState -eq 'Running')

# datas declaradas + data real do último toque em memória
$memoryFiles = @('AGENTS.md', 'CONTEXT.md', 'AGENT_MEMORY.md', 'DECISIONS.md', 'SESSION_LOG.md', 'PROJECTS_INDEX.md', 'SKILLS_INDEX.md')
$declaredPatterns = @{
  'AGENTS.md'         = 'Revisado em'
  'CONTEXT.md'        = 'Atualizado em'
  'AGENT_MEMORY.md'   = 'ltima atualiza'
  'DECISIONS.md'      = 'ltima atualiza|Atualizado em|Iniciado em'
  'SESSION_LOG.md'    = 'Atualizado em'
  'PROJECTS_INDEX.md' = 'Gerado em|Atualizado em'
  'SKILLS_INDEX.md'   = 'Atualizado'
}
$memoryDates = @()
foreach ($f in $memoryFiles) {
  $d = $null
  if ($declaredPatterns.ContainsKey($f)) { $d = Get-DeclaredDate $f $declaredPatterns[$f] }
  $memoryDates += [pscustomobject]@{ file = $f; declared = $d }
}

$memoryTouchPaths = @('AGENTS.md', 'CONTEXT.md', 'AGENT_MEMORY.md', 'DECISIONS.md', 'SESSION_LOG.md', 'PROJECTS_INDEX.md', 'SKILLS_INDEX.md', 'config.json', 'MEMORY_STATE.md', 'skills/', 'rules/', 'hooks/', 'scripts/')
$rawMemoryCommit = Invoke-Git $Root (@('log', '-1', '--format=%ad', '--date=short', '--') + $memoryTouchPaths)
$lastMemoryCommitDate = $null
if ($rawMemoryCommit -match '^\d{4}-\d{2}-\d{2}') {
  $lastMemoryCommitDate = [datetime]::ParseExact($rawMemoryCommit.Substring(0, 10), 'yyyy-MM-dd', $null)
}

$lastSessionDate = $null
$sessionHeaders = @()
$logPath = Join-Path $Root 'SESSION_LOG.md'
if (Test-Path $logPath) {
  $headers = Select-String -Path $logPath -Pattern '^##\s+\d{4}-\d{2}-\d{2}' -ErrorAction SilentlyContinue
  foreach ($h in $headers) {
    if ($h.Line -match '^##\s+(\d{4})-(\d{2})-(\d{2})') {
      $d = [datetime]::new([int]$Matches[1], [int]$Matches[2], [int]$Matches[3])
      $sessionHeaders += [pscustomobject]@{ line = $h.LineNumber; date = $d; title = $h.Line.Trim() }
      if (-not $lastSessionDate -or $d -gt $lastSessionDate) { $lastSessionDate = $d }
    }
  }
}
# ordem cronológica decrescente esperada: aponta a primeira quebra
$sessionOrderBreaks = @()
for ($i = 1; $i -lt $sessionHeaders.Count; $i++) {
  if ($sessionHeaders[$i].date -gt $sessionHeaders[$i - 1].date) {
    $sessionOrderBreaks += ('linha ' + $sessionHeaders[$i].line + ' (' + $sessionHeaders[$i].date.ToString('yyyy-MM-dd') + ' depois de ' + $sessionHeaders[$i - 1].date.ToString('yyyy-MM-dd') + ')')
  }
}

$memoryCommitsSince = @()
if ($lastSessionDate -and $lastMemoryCommitDate -and $lastMemoryCommitDate -gt $lastSessionDate) {
  $since = $lastSessionDate.ToString('yyyy-MM-dd')
  $raw = Invoke-Git $Root (@('log', '--since', ($since + ' 23:59:59'), '--format=%h%x09%ad%x09%s', '--date=short', '--') + $memoryTouchPaths)
  if ($raw) { $memoryCommitsSince = @($raw -split "`n" | Where-Object { $_ }) }
}

# dependências críticas do workspace
$criticalRefs = @(
  'rules\caverna-activate.md.off', 'rules\plan-and-execute.md', 'rules\first-response.md',
  'rules\memory-protocol.md', 'rules\gauntlet-protocol.md', 'rules\anti-sycophancy.md',
  'rules\human-architectural-gate.md', 'rules\sandbox-dangerous.md', 'rules\workflow-patterns.md',
  'rules\test-integrity.md', 'rules\token-efficiency.md', 'rules\pt-br-acentos.md',
  'hooks\openwiki-auth-guard.js', 'hooks\profile-session.js', 'hooks\profile-runtime.js',
  'hooks\git-safety-guard.js', 'hooks\hook-healthcheck.js',
  'scripts\migrate-from-documents.ps1', 'scripts\Atualizar-Cursor-Seguro.ps1',
  'CONTEXT.md', 'AGENT_MEMORY.md', 'DECISIONS.md', 'SESSION_LOG.md', 'PROJECTS_INDEX.md', 'SKILLS_INDEX.md', 'config.json'
)
$brokenRefs = @()
foreach ($ref in $criticalRefs) {
  if (-not (Test-Path (Join-Path $Root $ref))) { $brokenRefs += $ref.Replace('\', '/') }
}

$externalRefs = @(
  @{ label = 'AGENTS.md global do DSH'; path = $DshGlobalFile },
  @{ label = 'memoria de usuario (~/.claude/memory)'; path = (Join-Path $env:USERPROFILE '.claude\memory') },
  @{ label = 'MCP cursor-to-zo2 (~/.cursor/mcp.json)'; path = (Join-Path $env:USERPROFILE '.cursor\mcp.json') },
  @{ label = 'INSTRUCTIONS do OpenWiki'; path = (Join-Path $env:USERPROFILE '.openwiki\INSTRUCTIONS.md') },
  @{ label = 'env do OpenWiki (~/.openwiki/.env)'; path = (Join-Path $env:USERPROFILE '.openwiki\.env') },
  @{ label = 'skills do Hermes'; path = (Join-Path $env:LOCALAPPDATA 'hermes\skills') },
  @{ label = 'scripts do Hermes'; path = (Join-Path $env:LOCALAPPDATA 'hermes\scripts') }
)
$missingExternal = @()
foreach ($item in $externalRefs) {
  if (-not (Test-Path $item.path)) { $missingExternal += $item.label }
}

# memórias nomeadas citadas dentro dos arquivos de memória
$namedMemoryRefs = @()
foreach ($f in @('AGENT_MEMORY.md', 'CONTEXT.md', 'DECISIONS.md', 'SESSION_LOG.md', 'AGENTS.md')) {
  $abs = Join-Path $Root $f
  if (-not (Test-Path $abs)) { continue }
  $hits = Select-String -Path $abs -Pattern 'mem[óo]ria\s+`([a-z0-9_]+)`' -AllMatches -ErrorAction SilentlyContinue
  foreach ($h in $hits) {
    foreach ($match in $h.Matches) { $namedMemoryRefs += $match.Groups[1].Value }
  }
}
$namedMemoryRefs = @($namedMemoryRefs | Sort-Object -Unique)
$brokenMemoryRefs = @()
foreach ($name in $namedMemoryRefs) {
  if (-not (Test-Path (Join-Path $env:USERPROFILE ('.claude\memory\' + $name + '.md')))) { $brokenMemoryRefs += $name }
}

# estado do repo raiz
$rootParts = (Invoke-Git $Root @('log', '-1', '--format=%h%x09%ad%x09%s', '--date=short')) -split "`t", 3
$rootDirty = @(Invoke-Git $Root @('status', '--porcelain') -split "`n" | Where-Object { $_ })

# impressão digital estrutural
$fingerprintInput = @()
$fingerprintInput += ('custom=' + $customSkills)
$fingerprintInput += ('cyber=' + $cyberSkills)
$fingerprintInput += ('sci=' + $sciSkills)
$fingerprintInput += ('rules=' + $rulesCount)
$fingerprintInput += ('hooks=' + $hooksCount)
$fingerprintInput += ('scripts=' + $scriptsCount)
$fingerprintInput += ('sync=' + $cursorSkillsCount)
$fingerprintInput += ('synccursor=' + $cursorSkillsCursorCount)
$fingerprintInput += ('synctask=' + $syncTaskState)
$fingerprintInput += ('worktrees=' + $worktrees.Count)
foreach ($w in $worktrees) { $fingerprintInput += ('wt:' + $w.name + '=' + $w.head) }
foreach ($r in $repos) { $fingerprintInput += ('repo:' + $r.path + '=' + $r.head) }
$sha = [System.Security.Cryptography.SHA256]::Create()
$fpBytes = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes(($fingerprintInput -join '|')))
$Fingerprint = ([System.BitConverter]::ToString($fpBytes) -replace '-', '').Substring(0, 12).ToLower()

# ---------------------------------------------------------------- juízo de estado

$staleReasons = @()
$daysSinceSession = if ($lastSessionDate) { [int]($Today - $lastSessionDate).TotalDays } else { -1 }

if (-not $lastSessionDate) {
  $staleReasons += 'SESSION_LOG sem data legível'
} elseif ($daysSinceSession -gt 7) {
  $staleReasons += ('última sessão registrada há ' + $daysSinceSession + ' dias')
}
if ($memoryCommitsSince.Count -gt 0) {
  $staleReasons += ($memoryCommitsSince.Count.ToString() + ' commit(s) de memória/estrutura sem registro de sessão')
}
if ($rootDirty.Count -gt 0) {
  $staleReasons += ($rootDirty.Count.ToString() + ' caminho(s) não commitado(s) no repo raiz')
}
if ($brokenRefs.Count -gt 0) {
  $staleReasons += ($brokenRefs.Count.ToString() + ' dependência(s) crítica(s) ausente(s) no workspace')
}
if ($missingExternal.Count -gt 0) {
  $staleReasons += ($missingExternal.Count.ToString() + ' dependência(s) externa(s) ausente(s)')
}
if ($brokenMemoryRefs.Count -gt 0) {
  $staleReasons += ($brokenMemoryRefs.Count.ToString() + ' memória(s) nomeada(s) citada(s) e inexistente(s)')
}
if (-not $syncTaskHealthy) {
  $staleReasons += ('sync do Cursor inativo (tarefa ' + $syncTaskName + ' = ' + $syncTaskState + ', última execução ' + $syncTaskLastRun + ')')
}
if ($sessionOrderBreaks.Count -gt 0) {
  $staleReasons += ('SESSION_LOG fora de ordem cronológica em ' + $sessionOrderBreaks.Count + ' ponto(s)')
}
if ($customNoManifest.Count -gt 0) {
  $staleReasons += ($customNoManifest.Count.ToString() + ' skill(s) sem SKILL.md em skills/')
}

$Health = if ($staleReasons.Count -eq 0) { 'ATUALIZADA' } else { 'DESATUALIZADA' }

# ---------------------------------------------------------------- snapshot legível

$L = New-Object System.Collections.Generic.List[string]
$L.Add('# MEMORY_STATE — estado do ecossistema')
$L.Add('')
$L.Add('> GERADO por ' + (Code 'scripts/memory-doctor.ps1') + ' em ' + $Today.ToString('yyyy-MM-dd HH:mm') + ' BRT. Não editar à mão.')
$L.Add('> Fatos voláteis recomputados do disco e do Git. Onde este arquivo contradiz outro, este vence.')
$L.Add('')
$L.Add('**Saúde da memória:** ' + $Health)
if ($staleReasons.Count -gt 0) {
  foreach ($reason in $staleReasons) { $L.Add('- pendência: ' + $reason) }
}
$L.Add('**Fingerprint estrutural:** ' + (Code $Fingerprint))
$L.Add('')
$L.Add('## Inventário (contado no disco)')
$L.Add('')
$L.Add('| Item | Quantidade |')
$L.Add('|---|---|')
$L.Add('| Skills custom com SKILL.md (' + (Code 'skills/') + ', sem ' + (Code '_templates') + ') | ' + $customSkills + ' |')
$L.Add('| Diretórios em ' + (Code 'skills/') + ' | ' + $customDirs + ' |')
$L.Add('| Skills cybersecurity | ' + $cyberSkills + ' |')
$L.Add('| Diretórios cyber | ' + $cyberDirs + ' |')
$L.Add('| Skills scientific | ' + $sciSkills + ' |')
$L.Add('| Commands (' + (Code 'commands/*.md') + ') | ' + $commandsCount + ' |')
$L.Add('| Rules (' + (Code 'rules/*.md') + ') | ' + $rulesCount + ' |')
$L.Add('| Hooks (' + (Code 'hooks/*.js') + ' + ' + $hooksExtras + ' ' + (Code '.ps1') + ') | ' + $hooksCount + ' |')
$L.Add('| Arquivos em ' + (Code 'scripts/') + ' | ' + $scriptsCount + ' |')
$L.Add('| Skills em ' + (Code '~/.cursor/skills') + ' (sync) | ' + $cursorSkillsCount + ' |')
$L.Add('| Skills oficiais em ' + (Code '~/.cursor/skills-cursor') + ' | ' + $cursorSkillsCursorCount + ' |')
if ($customNoManifest.Count -gt 0) {
  $L.Add('')
  $L.Add('Diretórios em ' + (Code 'skills/') + ' sem ' + (Code 'SKILL.md') + ': ' + (($customNoManifest | ForEach-Object { Code $_ }) -join ', '))
}
$L.Add('')
$L.Add('## Sync do Cursor')
$L.Add('')
$L.Add('| Tarefa | Estado | Última execução |')
$L.Add('|---|---|---|')
$L.Add('| ' + (Code $syncTaskName) + ' | ' + $syncTaskState + ' | ' + $(if ($syncTaskLastRun) { $syncTaskLastRun } else { 'nunca registrada' }) + ' |')
$L.Add('')
$L.Add('## Repositórios')
$L.Add('')
$L.Add('| Repo | HEAD | Data | Pendências | origin/main...HEAD |')
$L.Add('|---|---|---|---|---|')
foreach ($r in $repos) {
  if (-not $r.exists) { $L.Add('| ' + (Code $r.path) + ' | n/a | n/a | ausente no disco | n/a |'); continue }
  if (-not $r.repo) { $L.Add('| ' + (Code $r.path) + ' | n/a | n/a | não é repo git | n/a |'); continue }
  $dirtyLabel = if ($r.dirtyN -gt 0) { $r.dirtyN.ToString() + ' arquivo(s)' } else { 'limpo' }
  $lrLabel = if ($r.ahead -ne '' -and $r.behind -ne '') { '-' + $r.behind + ' / +' + $r.ahead } else { 'n/a' }
  $L.Add('| ' + (Code $r.path) + ' | ' + (Code $r.head) + ' | ' + $r.date + ' | ' + $dirtyLabel + ' | ' + $lrLabel + ' |')
}
$rootDirtyLabel = if ($rootDirty.Count -gt 0) { $rootDirty.Count.ToString() + ' caminho(s)' } else { 'limpo' }
$L.Add('| ' + (Code '.') + ' (raiz) | ' + (Code $rootParts[0]) + ' | ' + $rootParts[1] + ' | ' + $rootDirtyLabel + ' | n/a |')
$L.Add('')
$L.Add('## Worktrees (' + $worktrees.Count + ')')
$L.Add('')
$L.Add('São repositórios independentes com `.git` próprio (arquivo), não worktrees do repo raiz — ADR-003.')
$L.Add('')
$L.Add('Com repositório (' + $worktreeRepos.Count + '): ' + (($worktreeRepos | ForEach-Object { Code $_.name }) -join ', '))
if ($worktreeShells.Count -gt 0) {
  $L.Add('')
  $L.Add('Sem ' + (Code '.git') + ' (' + $worktreeShells.Count + '): ' + (($worktreeShells | ForEach-Object { Code $_.name }) -join ', '))
}
$L.Add('')
$L.Add('## Datas declaradas vs. hoje')
$L.Add('')
$L.Add('| Arquivo | Data declarada | Dias de atraso |')
$L.Add('|---|---|---|')
foreach ($m in $memoryDates) {
  if ($m.declared) {
    $L.Add('| ' + (Code $m.file) + ' | ' + $m.declared.ToString('yyyy-MM-dd') + ' | ' + [int]($Today - $m.declared).TotalDays + ' |')
  } else {
    $L.Add('| ' + (Code $m.file) + ' | não declarada | n/a |')
  }
}
if ($lastSessionDate) {
  $L.Add('| última sessão em ' + (Code 'SESSION_LOG.md') + ' | ' + $lastSessionDate.ToString('yyyy-MM-dd') + ' | ' + $daysSinceSession + ' |')
}
$L.Add('')
$L.Add('## SESSION_LOG — ordem cronológica')
$L.Add('')
if ($sessionOrderBreaks.Count -eq 0) {
  $L.Add('Decrescente e íntegra em ' + $sessionHeaders.Count + ' blocos.')
} else {
  $L.Add('Quebras detectadas:')
  foreach ($b in $sessionOrderBreaks) { $L.Add('- ' + $b) }
}
$L.Add('')
$L.Add('## Commits de memória/estrutura sem registro de sessão')
$L.Add('')
if ($memoryCommitsSince.Count -eq 0) {
  $L.Add('Nenhum.')
} else {
  foreach ($c in $memoryCommitsSince) {
    $cp = $c -split "`t", 3
    $L.Add('- ' + (Code $cp[0]) + ' ' + $cp[1] + ' — ' + $cp[2])
  }
}
$L.Add('')
$L.Add('## Referências críticas verificadas')
$L.Add('')
if ($brokenRefs.Count -eq 0) {
  $L.Add('Dependências do workspace: todas presentes.')
} else {
  $L.Add('Dependências do workspace ausentes:')
  foreach ($b in $brokenRefs) { $L.Add('- ' + (Code $b)) }
}
$L.Add('')
if ($missingExternal.Count -eq 0) {
  $L.Add('Dependências externas: todas presentes.')
} else {
  $L.Add('Dependências externas ausentes:')
  foreach ($b in $missingExternal) { $L.Add('- ' + $b) }
}
$L.Add('')
if ($brokenMemoryRefs.Count -eq 0) {
  $L.Add('Memórias nomeadas citadas: todas existem.')
} else {
  $L.Add('Memórias nomeadas citadas e inexistentes:')
  foreach ($b in $brokenMemoryRefs) { $L.Add('- ' + (Code $b)) }
}
$L.Add('')
$L.Add('## Arquivos de memória e papéis')
$L.Add('')
$L.Add('| Arquivo | Papel |')
$L.Add('|---|---|')
$L.Add('| [AGENTS.md](AGENTS.md) | Regras globais permanentes; entra sempre no prompt |')
$L.Add('| [MEMORY_STATE.md](MEMORY_STATE.md) | Este arquivo — snapshot gerado; verdade volátil |')
$L.Add('| [CONTEXT.md](CONTEXT.md) | Entry point do sistema de memória |')
$L.Add('| [AGENT_MEMORY.md](AGENT_MEMORY.md) | Fatos permanentes: identidade, stack, projetos, infra |')
$L.Add('| [DECISIONS.md](DECISIONS.md) | ADRs — decisões de arquitetura |')
$L.Add('| [SESSION_LOG.md](SESSION_LOG.md) | Histórico de sessões, decrescente |')
$L.Add('| [PROJECTS_INDEX.md](PROJECTS_INDEX.md) | Inventário de repos, worktrees e deploys |')
$L.Add('| [SKILLS_INDEX.md](SKILLS_INDEX.md) | Inventário de skills e sync |')
$L.Add('| [config.json](config.json) | Configuração ativa do ecossistema |')

$StateContent = ($L -join "`n") + "`n"

# ---------------------------------------------------------------- bloco de injeção

$D = New-Object System.Collections.Generic.List[string]
$D.Add('<!-- BEGIN GENERATED: memory-state -->')
$D.Add('## Estado do ecossistema (gerado)')
$D.Add('')
$D.Add('Gerado por ' + (Code 'scripts/memory-doctor.ps1') + ' em ' + $Today.ToString('yyyy-MM-dd HH:mm') + ' BRT. Não editar à mão.')
$D.Add('')
$D.Add('Saúde da memória: **' + $Health + '** · fingerprint ' + (Code $Fingerprint))
if ($staleReasons.Count -gt 0) {
  foreach ($reason in $staleReasons) { $D.Add('- pendência: ' + $reason) }
}
$D.Add('')
$D.Add('Inventário: ' + $customSkills + ' skills custom · ' + $cyberSkills + ' cyber · ' + $sciSkills + ' scientific · ' + $commandsCount + ' commands · ' + $rulesCount + ' rules · ' + $hooksCount + ' hooks · ' + $worktrees.Count + ' worktrees · ' + $cursorSkillsCount + ' em sync')
$D.Add('')
$D.Add('Repositórios:')
foreach ($r in $repos) {
  if (-not $r.repo) { continue }
  $dirtyTag = if ($r.dirtyN -gt 0) { $r.dirtyN.ToString() + ' pendente(s)' } else { 'limpo' }
  $D.Add('- ' + $r.path + ': ' + $r.head + ' (' + $r.date + ', ' + $dirtyTag + ')')
}
$D.Add('- raiz: ' + $rootParts[0] + ' (' + $rootParts[1] + ', ' + $rootDirtyLabel + ')')
$D.Add('')
$D.Add('Sync do Cursor: ' + $syncTaskName + ' = ' + $syncTaskState + ' (última execução ' + $(if ($syncTaskLastRun) { $syncTaskLastRun } else { 'nunca registrada' }) + ')')
if ($lastSessionDate) { $D.Add('Última sessão registrada: ' + $lastSessionDate.ToString('yyyy-MM-dd') + ' (' + $daysSinceSession + ' dias)') }
if ($memoryCommitsSince.Count -gt 0) {
  $D.Add('')
  $D.Add('Commits de memória/estrutura sem registro de sessão (' + $memoryCommitsSince.Count + '):')
  foreach ($c in ($memoryCommitsSince | Select-Object -First 6)) {
    $cp = $c -split "`t", 3
    $D.Add('- ' + $cp[0] + ' ' + $cp[1] + ' ' + $cp[2])
  }
}
if ($brokenRefs.Count -gt 0 -or $missingExternal.Count -gt 0 -or $brokenMemoryRefs.Count -gt 0) {
  $D.Add('')
  $D.Add('Referências ausentes:')
  foreach ($b in $brokenRefs) { $D.Add('- workspace: ' + $b) }
  foreach ($b in $missingExternal) { $D.Add('- externo: ' + $b) }
  foreach ($b in $brokenMemoryRefs) { $D.Add('- memória nomeada: ' + $b) }
}
$D.Add('')
$D.Add('Snapshot completo: ' + (Code 'MEMORY_STATE.md') + ' na raiz do workspace.')
$D.Add($EndMarker)
$DigestText = ($D -join "`n")

# ---------------------------------------------------------------- gravação

if (-not $NoWrite) {
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($StateFile, $StateContent, $utf8)

  # Bloco gerado dentro do AGENTS.md global do DSH: único vetor que o DSH injeta sozinho.
  $globalContent = ''
  if (Test-Path $DshGlobalFile) { $globalContent = [System.IO.File]::ReadAllText($DshGlobalFile) }
  if ($globalContent -match [regex]::Escape($BeginMarker) -and $globalContent -match [regex]::Escape($EndMarker)) {
    $pattern = [regex]::Escape($BeginMarker) + '[\s\S]*?' + [regex]::Escape($EndMarker)
    $globalContent = [regex]::Replace($globalContent, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $DigestText })
  } elseif ($globalContent.Trim().Length -gt 0) {
    $globalContent = $globalContent.TrimEnd() + "`n`n" + $DigestText + "`n"
  } else {
    $globalContent = $DigestText + "`n"
  }
  $dshDir = Split-Path $DshGlobalFile -Parent
  if (-not (Test-Path $dshDir)) { New-Item -ItemType Directory -Path $dshDir -Force | Out-Null }
  [System.IO.File]::WriteAllText($DshGlobalFile, $globalContent, $utf8)
}

if ($Quiet) {
  Write-Output $DigestText
  exit 0
}

Write-Output $DigestText
Write-Output ''
Write-Output ('workspace:  ' + $Root)
Write-Output ('snapshot:   ' + $StateFile + ' ' + $(if ($NoWrite) { '(não gravado)' } else { '(gravado)' }))
Write-Output ('global DSH: ' + $DshGlobalFile + ' ' + $(if ($NoWrite) { '(não gravado)' } else { '(gravado)' }))
Write-Output ('bytes:      snapshot=' + [System.Text.Encoding]::UTF8.GetByteCount($StateContent) + ' bloco=' + [System.Text.Encoding]::UTF8.GetByteCount($DigestText))

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

# Um diretório em skills/ é uma skill se tem SKILL.md. `_templates` não conta.
# Alguns diretórios são PLUGIN BUNDLES (têm .claude-plugin/, plugin.json, marketplace.json e
# skills/ aninhadas) — não são skills e não devem ser reportados como skill quebrada.
function Test-PluginBundle([string]$dir) {
  if (Test-Path (Join-Path $dir 'plugin.json')) { return $true }
  if (Test-Path (Join-Path $dir '.claude-plugin')) { return $true }
  if (Test-Path (Join-Path $dir 'marketplace.json')) { return $true }
  return $false
}

function Get-SkillInventory([string]$p) {
  # Devolve @{ count; missing; bundles } — separando o que é skill do que é bundle.
  $result = @{ count = 0; missing = @(); bundles = @() }
  if (-not (Test-Path $p)) { return $result }
  $dirs = Get-ChildItem $p -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne '_templates' }
  foreach ($d in $dirs) {
    if (Test-Path (Join-Path $d.FullName 'SKILL.md')) {
      $result.count = $result.count + 1
    } elseif (Test-PluginBundle $d.FullName) {
      $result.bundles += $d.Name
    } else {
      $result.missing += $d.Name
    }
  }
  return $result
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

# ATENÇÃO — armadilha já cometida duas vezes neste arquivo:
# `@(Invoke-Git ... -split "`n")` NÃO divide nada. Dentro de uma chamada de método/função o
# PowerShell lê `-split` como NOME DE PARÂMETRO, não como operador, e o erro é engolido por
# $ErrorActionPreference='SilentlyContinue'. O count sai sempre 1.
# Sempre: `@((Invoke-Git ...) -split "`n" | Where-Object { $_ })`.
function Get-GitStatusLines([string]$repo) {
  return @((Invoke-Git $repo @('status', '--porcelain')) -split "`n" | Where-Object { $_ })
}

function Test-GitRepo([string]$p) {
  # .git pode ser DIRETÓRIO (repo normal) ou ARQUIVO (worktree real). Ambos valem.
  $g = Join-Path $p '.git'
  if ([System.IO.Directory]::Exists($g)) { return 'dir' }
  if ([System.IO.File]::Exists($g)) { return 'file' }
  return ''
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
  $statusLines = Get-GitStatusLines $abs

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
$customInv = Get-SkillInventory (Join-Path $Root 'skills')
$customSkills = $customInv.count
$customNoManifest = $customInv.missing
$customBundles = $customInv.bundles
$cyberSkills = (Get-SkillInventory (Join-Path $Root 'cybersecurity-skills\skills')).count
$cyberDirs = Count-SkillDirs (Join-Path $Root 'cybersecurity-skills\skills')
$sciSkills = (Get-SkillInventory (Join-Path $Root 'scientific-skills\skills')).count
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
  $gitKind = Test-GitRepo $d.FullName
  $head = ''
  $tracked = 0
  if ($gitKind) {
    $head = (Invoke-Git $d.FullName @('log', '-1', '--format=%h'))
    $tracked = @((Invoke-Git $d.FullName @('ls-files')) -split "`n" | Where-Object { $_ }).Count
  }
  $worktrees += [pscustomobject]@{ name = $d.Name; repo = [bool]$gitKind; gitKind = $gitKind; head = $head; tracked = $tracked }
}
$worktreeRepos = @($worktrees | Where-Object { $_.repo })
# "shell vazio" é juízo, não fato binário: um diretório com 1 arquivo rastreado não tem código
# substantivo. O corte está declarado como heurística (aparece na saída) e é parâmetro único.
$shellThreshold = 10
$worktreeSubstantive = @($worktrees | Where-Object { $_.repo -and $_.tracked -gt $shellThreshold })
$worktreeShells = @($worktrees | Where-Object { $_.repo -and $_.tracked -le $shellThreshold })

$repoList = @('DRE_Eventos', 'declaw', 'webwright', 'cybersecurity-skills', 'scientific-skills', 'worktrees\dre-eventos-fix')
$repos = @()
foreach ($r in $repoList) { $repos += (Get-RepoInfo $r) }

# Worktrees REGISTRADOS pelo repo raiz — vivem fora de worktrees\ e são invisíveis ao laço acima.
# Uma auditoria de 30/09/2026 achou 6.119 caminhos pendentes em `.claude/worktrees/…` que o
# "Estado do ecossistema" simplesmente não mostrava. Usar `git worktree list` é a fonte correta:
# os 14 de worktrees\ NÃO aparecem nele (têm .git próprio, não são worktrees do raiz).
$worktreeExtra = @()
$wtRaw = Invoke-Git $Root @('worktree', 'list', '--porcelain')
if ($wtRaw) {
  $currentPath = ''
  foreach ($wtLine in ($wtRaw -split "`n")) {
    if ($wtLine -match '^worktree\s+(.+)$') {
      $currentPath = $Matches[1].Trim()
      continue
    }
    if ($wtLine -match '^branch\s+(.+)$' -and $currentPath) {
      $branch = $Matches[1].Trim()
      $norm = $currentPath.Replace('/', '\')
      if ($norm -and ($norm.TrimEnd('\') -ne $Root.TrimEnd('\'))) {
        $dirtyN = (Get-GitStatusLines $norm).Count
        $worktreeExtra += [pscustomobject]@{ path = $norm; branch = $branch; dirtyN = $dirtyN }
      }
      $currentPath = ''
    }
  }
}

# ---- tarefas agendadas do pipeline Cursor/Febracis
$scheduledTaskNames = @(
  'Febracis-Cursor-SyncDaily',
  'Febracis-CursorAgent-Daily',
  'Febracis-OpenDesign-Update',
  'Febracis-Cursor-UpdateWatchdog',
  'Febracis-Codex-LogGuard-Audit'
)
$scheduledTasks = @()
foreach ($name in $scheduledTaskNames) {
  $state = 'ausente'
  $last = ''
  try {
    $task = Get-ScheduledTask -TaskName $name -ErrorAction Stop
    $state = [string]$task.State
    $info = Get-ScheduledTaskInfo -TaskName $name -ErrorAction SilentlyContinue
    if ($info -and $info.LastRunTime) { $last = $info.LastRunTime.ToString('yyyy-MM-dd') }
  } catch { }
  $healthy = ($state -eq 'Ready' -or $state -eq 'Running')
  $scheduledTasks += [pscustomobject]@{ name = $name; state = $state; last = $last; healthy = $healthy }
}
$syncTask = $scheduledTasks | Where-Object { $_.name -eq 'Febracis-Cursor-SyncDaily' } | Select-Object -First 1
$syncTaskName = $syncTask.name
$syncTaskState = $syncTask.state
$syncTaskLastRun = $syncTask.last
$deadTasks = @($scheduledTasks | Where-Object { -not $_.healthy })

# ---- scheduler do Hermes: jobs enabled mas ticker parado = automação morta em silêncio
# O heartbeat NÃO está dentro do jobs.json — é um arquivo próprio (epoch em segundos) em
# %LOCALAPPDATA%\hermes\cron\. Usar o mtime do arquivo evita qualquer ambiguidade de fuso.
$hermesCronDir = Join-Path $env:LOCALAPPDATA 'hermes\cron'
$hermesJobsFile = Join-Path $hermesCronDir 'jobs.json'
$hermesTickerFile = Join-Path $hermesCronDir 'ticker_heartbeat'
$hermesTickerDate = $null
$hermesEnabledJobs = 0
$hermesPausedJobs = 0
$hermesStalled = $false
$hermesJobs = @()
$hermesParseFailed = $false
if (Test-Path $hermesTickerFile) { $hermesTickerDate = (Get-Item $hermesTickerFile).LastWriteTime }
if (Test-Path $hermesJobsFile) {
  $raw = Get-Content $hermesJobsFile -Raw -ErrorAction SilentlyContinue
  # Parsing de verdade: a estrutura é { "jobs": [ { id, name, enabled, … } ] }. Regex de janela
  # falhava porque `name` e `enabled` ficam separados por objetos aninhados com chaves — a lista
  # por-job saía vazia em silêncio, e o doctor dizia "3 jobs enabled" sem saber quais.
  # Fallback para contagem bruta só se o JSON não parsear.
  $hermesEnabledJobs = ([regex]::Matches($raw, '"enabled"\s*:\s*true')).Count
  $hermesPausedJobs = ([regex]::Matches($raw, '"enabled"\s*:\s*false')).Count
  try {
    $parsed = $raw | ConvertFrom-Json -ErrorAction Stop
    if ($parsed.jobs) {
      $hermesEnabledJobs = @($parsed.jobs | Where-Object { $_.enabled -eq $true }).Count
      $hermesPausedJobs = @($parsed.jobs | Where-Object { $_.enabled -ne $true }).Count
      foreach ($job in $parsed.jobs) {
        $jobName = if ($job.name) { [string]$job.name } else { [string]$job.id }
        $hermesJobs += [pscustomobject]@{
          name    = $jobName
          enabled = ($job.enabled -eq $true)
          lastRun = if ($job.last_run_at) { [string]$job.last_run_at } else { '' }
        }
      }
    }
  } catch {
    # JSON inválido: mantém as contagens brutas e deixa a lista vazia, declarando isso na saída.
    $hermesParseFailed = $true
  }
}
if ($hermesTickerDate) { $hermesStalled = (($Today - $hermesTickerDate).TotalDays -gt 2) }

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

# dependências críticas do workspace. A lista importa: o que não está aqui pode sumir sem que
# o veredito mude. A auditoria de 30/09/2026 provou isso — `rules/pt-br-acentos.md` (trivial)
# estava coberto e `rules/session-bootstrap.md` (o contrato do próprio mecanismo), não.
$criticalRefs = @(
  'AGENTS.md', 'MEMORY_STATE.md', 'CONTEXT.md', 'AGENT_MEMORY.md', 'DECISIONS.md',
  'SESSION_LOG.md', 'PROJECTS_INDEX.md', 'SKILLS_INDEX.md', 'config.json',
  'SECURITY.md', 'HARNESS.md', 'QWEN.md', '.cursorrules', '.gitignore',
  'rules\caverna-activate.md.off', 'rules\plan-and-execute.md', 'rules\first-response.md',
  'rules\memory-protocol.md', 'rules\gauntlet-protocol.md', 'rules\anti-sycophancy.md',
  'rules\human-architectural-gate.md', 'rules\sandbox-dangerous.md', 'rules\workflow-patterns.md',
  'rules\test-integrity.md', 'rules\token-efficiency.md', 'rules\pt-br-acentos.md',
  'rules\session-bootstrap.md',
  'hooks\openwiki-auth-guard.js', 'hooks\profile-session.js', 'hooks\profile-runtime.js',
  'hooks\git-safety-guard.js', 'hooks\hook-healthcheck.js',
  'scripts\memory-doctor.ps1', 'scripts\migrate-from-documents.ps1', 'scripts\Atualizar-Cursor-Seguro.ps1',
  'out\civictrust',
  'skills\openwiki-personal-brain', 'skills\pulso-finance', 'skills\dre-zo-integrity-guard',
  'DRE_Eventos\docs\AGENT_CONTEXT_DRE.md'
)
$brokenRefs = @()
foreach ($ref in $criticalRefs) {
  if (-not (Test-Path (Join-Path $Root $ref))) { $brokenRefs += $ref.Replace('\', '/') }
}

$externalRefs = @(
  @{ label = 'AGENTS.md global do DSH'; path = $DshGlobalFile },
  @{ label = 'launcher do doctor (~/.claude/scripts/memory-doctor.ps1)'; path = (Join-Path $env:USERPROFILE '.claude\scripts\memory-doctor.ps1') },
  @{ label = 'settings.json do Claude Code (registra os hooks)'; path = (Join-Path $env:USERPROFILE '.claude\settings.json') },
  @{ label = 'memoria de usuario (~/.claude/memory)'; path = (Join-Path $env:USERPROFILE '.claude\memory') },
  @{ label = 'MCP cursor-to-zo2 (~/.cursor/mcp.json)'; path = (Join-Path $env:USERPROFILE '.cursor\mcp.json') },
  @{ label = 'INSTRUCTIONS do OpenWiki'; path = (Join-Path $env:USERPROFILE '.openwiki\INSTRUCTIONS.md') },
  @{ label = 'env do OpenWiki (~/.openwiki/.env)'; path = (Join-Path $env:USERPROFILE '.openwiki\.env') },
  @{ label = 'skills do Hermes'; path = (Join-Path $env:LOCALAPPDATA 'hermes\skills') },
  @{ label = 'scripts do Hermes'; path = (Join-Path $env:LOCALAPPDATA 'hermes\scripts') },
  @{ label = 'jobs do Hermes (%LOCALAPPDATA%\hermes\cron\jobs.json)'; path = $hermesJobsFile }
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

# estado do repo raiz — arquivos que o PRÓPRIO sistema de memória gera/edita não contam como
# trabalho pendente. Sem isso o snapshot é estale-por-construção: publicá-lo invalida o que ele
# acabou de afirmar, e a Saúde oscila conforme o arquivo esteja ou não commitado.
# Alternativa considerada e rejeitada: gerar o snapshot fora do repo medido — quebraria o
# versionamento do estado, que é justamente o que dá continuidade entre máquinas.
$memoryArtifacts = @('MEMORY_STATE\.md', 'scripts/memory-doctor\.ps1')
$artifactPattern = ($memoryArtifacts -join '|')
$rootParts = (Invoke-Git $Root @('log', '-1', '--format=%h%x09%ad%x09%s', '--date=short')) -split "`t", 3
$rootDirtyAll = Get-GitStatusLines $Root
$rootDirty = @($rootDirtyAll | Where-Object { $_ -notmatch $artifactPattern })
$rootDirtyIgnored = @($rootDirtyAll | Where-Object { $_ -match $artifactPattern })

# impressão digital estrutural — inclui o HEAD e a sujeira da raiz, senão é cega à deriva
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
$fingerprintInput += ('dead=' + $deadTasks.Count)
$fingerprintInput += ('hermes=' + $(if ($hermesStalled) { 'stalled' } else { 'ok' }))
$fingerprintInput += ('worktrees=' + $worktrees.Count)
$fingerprintInput += ('roothead=' + $rootParts[0])
$fingerprintInput += ('rootdirty=' + $rootDirty.Count)
foreach ($w in $worktrees) { $fingerprintInput += ('wt:' + $w.name + '=' + $w.head) }
foreach ($r in $repos) { $fingerprintInput += ('repo:' + $r.path + '=' + $r.head + '/' + $r.dirtyN) }
$sha = [System.Security.Cryptography.SHA256]::Create()
$fpBytes = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes(($fingerprintInput -join '|')))
$Fingerprint = ([System.BitConverter]::ToString($fpBytes) -replace '-', '').Substring(0, 12).ToLower()

# ---------------------------------------------------------------- juízo de estado

$staleReasons = @()
$acceptedReasons = @()
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
if ($brokenMemoryRefs.Count -gt 0) {
  $staleReasons += ($brokenMemoryRefs.Count.ToString() + ' memória(s) nomeada(s) citada(s) e inexistente(s)')
}
if ($sessionOrderBreaks.Count -gt 0) {
  $staleReasons += ('SESSION_LOG fora de ordem cronológica em ' + $sessionOrderBreaks.Count + ' ponto(s)')
}
if ($customNoManifest.Count -gt 0) {
  $staleReasons += ($customNoManifest.Count.ToString() + ' skill(s) sem SKILL.md em skills/')
}

# CONDIÇÕES DE AMBIENTE — reportadas com destaque, mas NÃO afetam a Saúde da memória.
# Distinção que uma auditoria adversarial de 30/09/2026 obrigou a fazer: uma tarefa agendada
# desligada é um problema de operação, não de memória. Misturar os dois tornava
# `Saúde: ATUALIZADA` inalcançável e transformava a instrução de exigi-la em letra morta.
# Reportar é obrigatório (senão o bloqueio fica invisível); contar para a saúde é errado.
$envConditions = @()
foreach ($t in $deadTasks) {
  $envConditions += ('tarefa agendada inativa: ' + $t.name + ' = ' + $t.state + ', última execução ' + $t.last)
}
if ($hermesStalled) {
  $envConditions += ('scheduler do Hermes parado desde ' + $hermesTickerDate.ToString('yyyy-MM-dd HH:mm') + ' — ' + $hermesEnabledJobs + ' job(s) enabled que não rodam')
}
if ($worktreeExtra.Count -gt 0) {
  $envConditions += ($worktreeExtra.Count.ToString() + ' worktree(s) do repo raiz fora de worktrees/ com trabalho pendente — fora do inventário até agora')
}

# Condições DELIBERADAS: conhecidas, inofensivas, não indicam memória desatualizada.
if (($missingExternal -contains 'env do OpenWiki (~/.openwiki/.env)')) {
  $acceptedReasons += 'OpenWiki sem ~/.openwiki/.env — bloqueio consciente do OAuth do X (não criar sem client_id)'
}
if ($customBundles.Count -gt 0) {
  $acceptedReasons += ('plugin bundle em skills/ (não é skill, não precisa de SKILL.md): ' + ($customBundles -join ', '))
}
$missingExternalReal = @($missingExternal | Where-Object { $_ -ne 'env do OpenWiki (~/.openwiki/.env)' })
if ($missingExternalReal.Count -gt 0) {
  $staleReasons += ($missingExternalReal.Count.ToString() + ' dependência(s) externa(s) ausente(s)')
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
if ($acceptedReasons.Count -gt 0) {
  foreach ($reason in $acceptedReasons) { $L.Add('- aceito (não conta para a saúde): ' + $reason) }
}
$L.Add('**Fingerprint estrutural:** ' + (Code $Fingerprint))
$L.Add('')
$L.Add('> `Saúde: ATUALIZADA` significa **zero pendência acionável de memória**. As linhas `aceito` são')
$L.Add('> condições deliberadas. As **condições de ambiente** abaixo são problemas reais de operação:')
$L.Add('> aparecem aqui para não ficarem invisíveis, mas não indicam memória desatualizada.')
$L.Add('')
$L.Add('## Condições de ambiente (não afetam a Saúde da memória)')
$L.Add('')
if ($envConditions.Count -eq 0) {
  $L.Add('Nenhuma. Tarefas agendadas e scheduler operando.')
} else {
  foreach ($c in $envConditions) { $L.Add('- ' + $c) }
}
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
  $L.Add('Diretórios em ' + (Code 'skills/') + ' sem ' + (Code 'SKILL.md') + ' (skill quebrada): ' + (($customNoManifest | ForEach-Object { Code $_ }) -join ', '))
}
if ($customBundles.Count -gt 0) {
  $L.Add('')
  $L.Add('Plugin bundles em ' + (Code 'skills/') + ' (têm ' + (Code 'plugin.json') + ' ou ' + (Code '.claude-plugin') + ' e skills aninhadas — não são skills, não precisam de ' + (Code 'SKILL.md') + '): ' + (($customBundles | ForEach-Object { Code $_ }) -join ', '))
}
$L.Add('')
$L.Add('## Tarefas agendadas')
$L.Add('')
$L.Add('| Tarefa | Estado | Última execução |')
$L.Add('|---|---|---|')
foreach ($t in $scheduledTasks) {
  $lastLabel = if ($t.last) { $t.last } else { 'nunca registrada' }
  $mark = if ($t.healthy) { '' } else { ' **inativa**' }
  $isSyncTask = ($t.name -eq $syncTaskName)
  $taskLabel = if ($isSyncTask) { (Code $t.name) + ' (sync de skills)' } else { Code $t.name }
  $L.Add('| ' + $taskLabel + ' | ' + $t.state + $mark + ' | ' + $lastLabel + ' |')
}
$L.Add('')
$L.Add('## Scheduler do Hermes')
$L.Add('')
if (-not $hermesTickerDate) {
  $L.Add('Ticker não encontrado em ' + (Code 'jobs.json') + ' — não foi possível medir.')
} else {
  $hermesAge = [int]($Today - $hermesTickerDate).TotalDays
  $L.Add('| Item | Valor |')
  $L.Add('|---|---|')
  $L.Add('| Último heartbeat do ticker | ' + $hermesTickerDate.ToString('yyyy-MM-dd HH:mm') + ' (' + $hermesAge + ' dias) |')
  $L.Add('| Jobs habilitados | ' + $hermesEnabledJobs + ' |')
  $L.Add('| Jobs pausados | ' + $hermesPausedJobs + ' |')
  $hermesLabel = if ($hermesStalled) { '**parado** — jobs enabled que não rodam' } else { 'operando' }
  $L.Add('| Veredito | ' + $hermesLabel + ' |')
  if ($hermesJobs.Count -gt 0) {
    $L.Add('')
    $L.Add('| Job | Estado | Última execução |')
    $L.Add('|---|---|---|')
    foreach ($j in $hermesJobs) {
      $jState = if ($j.enabled) { 'enabled' } else { 'pausado' }
      $jLast = if ($j.lastRun) { $j.lastRun } else { 'nunca' }
      $L.Add('| ' + (Code $j.name) + ' | ' + $jState + ' | ' + $jLast + ' |')
    }
  } elseif ($hermesParseFailed) {
    $L.Add('')
    $L.Add('A lista por-job não pôde ser lida: ' + (Code 'jobs.json') + ' não parseou como JSON. As contagens acima vêm de regex bruto.')
  } else {
    $L.Add('')
    $L.Add('A lista por-job saiu **vazia mesmo com o JSON válido** — isso é bug de parsing, não ausência de jobs. Investigar antes de confiar no número acima.')
  }
}
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
$L.Add('Repositórios independentes com ' + (Code '.git') + ' próprio — **diretório** em todos os ' + $worktrees.Count + ', não arquivo (medido nesta execução, não afirmado de memória). Não são worktrees do repo raiz — ADR-003.')
$L.Add('')
$L.Add('| Worktree | HEAD | Arquivos rastreados | Marcador ' + (Code '.git') + ' | Código substantivo |')
$L.Add('|---|---|---|---|---|')
foreach ($w in $worktrees) {
  $kindLabel = if ($w.gitKind) { $w.gitKind } else { 'ausente' }
  $subst = if (-not $w.repo) { 'n/a' } elseif ($w.tracked -le $shellThreshold) { 'não (shell)' } else { 'sim' }
  $L.Add('| ' + (Code $w.name) + ' | ' + (Code $w.head) + ' | ' + $w.tracked + ' | ' + $kindLabel + ' | ' + $subst + ' |')
}
$L.Add('')
$L.Add('O corte em ' + $shellThreshold + ' arquivos rastreados para separar "shell" de "com código" é **heurística declarada**, não fato binário.')
if ($worktreeSubstantive.Count -gt 0) {
  $L.Add('Acima do corte (' + $worktreeSubstantive.Count + '): ' + (($worktreeSubstantive | ForEach-Object { Code $_.name }) -join ', ') + '.')
}
if ($worktreeShells.Count -gt 0) {
  $L.Add('No corte ou abaixo (' + $worktreeShells.Count + '): ' + (($worktreeShells | ForEach-Object { Code $_.name }) -join ', ') + '.')
}
$L.Add('')
if ($rootDirtyIgnored.Count -gt 0) {
  $artifactList = ($memoryArtifacts | ForEach-Object { Code $_ }) -join ', '
  $dirtyNote = 'A sujeira da raiz **ignora** os arquivos que o próprio sistema de memória gera ou edita: ' + $artifactList + '. Eles não são trabalho pendente — senão o snapshot seria estale-por-construção. Hoje há ' + $rootDirtyIgnored.Count + ' caminho(s) nessa condição.'
  $L.Add($dirtyNote)
  $L.Add('')
}
if ($worktreeExtra.Count -gt 0) {
  $L.Add('## Worktrees registrados pelo repo raiz (fora de ' + (Code 'worktrees/') + ')')
  $L.Add('')
  $L.Add('Não aparecem no laço de ' + (Code 'worktrees/') + ' porque não vivem lá. Encontrados via ' + (Code 'git worktree list') + '.')
  $L.Add('')
  $L.Add('| Worktree | Branch | Pendências |')
  $L.Add('|---|---|---|')
  foreach ($e in $worktreeExtra) {
    $eDirty = if ($e.dirtyN -gt 0) { $e.dirtyN.ToString() + ' arquivo(s)' } else { 'limpo' }
    $L.Add('| ' + (Code $e.path) + ' | ' + (Code $e.branch) + ' | ' + $eDirty + ' |')
  }
  $L.Add('')
}
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
  $L.Add('Decrescente e em ordem em ' + $sessionHeaders.Count + ' blocos. **Não** verifica sessão faltando')
  $L.Add('nem bloco duplicado: só compara datas consecutivas de headers no formato ' + (Code '## YYYY-MM-DD') + '.')
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
if ($acceptedReasons.Count -gt 0) {
  foreach ($reason in $acceptedReasons) { $D.Add('- aceito: ' + $reason) }
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
$deadTaskNames = @($deadTasks | ForEach-Object { $_.name + '=' + $_.state })
$D.Add('Tarefas agendadas inativas: ' + $(if ($deadTaskNames.Count -gt 0) { $deadTaskNames -join ', ' } else { 'nenhuma' }))
if ($hermesTickerDate) {
  $hermesDigestLabel = if ($hermesStalled) { 'PARADO desde ' + $hermesTickerDate.ToString('yyyy-MM-dd') + ' com ' + $hermesEnabledJobs + ' job(s) enabled' } else { 'operando' }
  $D.Add('Scheduler do Hermes: ' + $hermesDigestLabel)
}
if ($lastSessionDate) { $D.Add('Última sessão registrada: ' + $lastSessionDate.ToString('yyyy-MM-dd') + ' (' + $daysSinceSession + ' dias)') }
if ($memoryCommitsSince.Count -gt 0) {
  $D.Add('')
  $D.Add('Commits de memória/estrutura sem registro de sessão (' + $memoryCommitsSince.Count + '):')
  foreach ($c in ($memoryCommitsSince | Select-Object -First 6)) {
    $cp = $c -split "`t", 3
    $D.Add('- ' + $cp[0] + ' ' + $cp[1] + ' ' + $cp[2])
  }
}
if ($brokenRefs.Count -gt 0 -or $missingExternalReal.Count -gt 0 -or $brokenMemoryRefs.Count -gt 0) {
  $D.Add('')
  $D.Add('Referências ausentes:')
  foreach ($b in $brokenRefs) { $D.Add('- workspace: ' + $b) }
  foreach ($b in $missingExternalReal) { $D.Add('- externo: ' + $b) }
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

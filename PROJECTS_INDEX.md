# PROJECTS_INDEX — Inventário Canônico de Projetos

> Atualizado: 30/09/2026 — coluna de remotes reconstruída a partir de `git remote -v` real.
> Fonte local: `C:\Users\deivithi.lopes\Documents`
> Este arquivo é o ponto de entrada para qualquer sessão de trabalho.

> **Contagens voláteis não vivem aqui.** São recomputadas por `~/.claude/scripts/memory-doctor.ps1` e publicadas em [MEMORY_STATE.md](MEMORY_STATE.md). Este arquivo guarda identidade, caminhos, remotes e relações.

## Estado do inventário

- Repositórios locais detectados: **22** (varredura `.git` sob `Documents`, profundidade 4)
- Repositórios GitHub nas contas autenticadas: **47** (verificado 30/09/2026)
- Contas consultadas: `deivithi`, `deivithilopes-ai`
- Inventário JSON completo: `C:\Users\deivithi.lopes\Documents\Codex\2026-09-22\voc-j-tem-mapeado-todos-os\outputs\PROJECTS_INVENTORY.json`
- **Correção de 30/09/2026:** a versão anterior desta tabela marcava `(sem origin)` nas 8 linhas que **têm** remote. Era erro sistemático de leitura, não ausência real. Os remotes abaixo foram lidos de `git remote -v`.

## Repositórios locais

| Projeto | Caminho | Branch | Estado | Remote principal |
|---|---|---|---|---|
| Cursor (raiz) | `C:\Users\deivithi.lopes\Documents\Cursor` | `main` | 9 caminhos pendentes | `origin` + `cloud` = deivithi/cursor-agent-os e deivithilopes-ai/cursor-agent-os |
| corretor2.0 | `C:\Users\deivithi.lopes\Documents\Corretor2.0` | `main` | limpo | **sem remote** |
| civictrust | `C:\Users\deivithi.lopes\Documents\civictrust` | `main` | limpo | `origin` = deivithi/civictrust |
| cybersecurity-skills | `...\Cursor\cybersecurity-skills` | `main` | 23 pendentes | `origin` = mukul975/Anthropic-Cybersecurity-Skills |
| declaw | `...\Cursor\declaw` | `main` | limpo | `origin` = deivithi/declaw · `cloud` = deivithilopes-ai/declaw (**404, inativo**) |
| DRE_Eventos | `...\Cursor\DRE_Eventos` | `main` | 12 pendentes | `origin` = deivithi/febracis-dre-eventos |
| webwright | `...\Cursor\webwright` | `main` | limpo | `origin` = microsoft/webwright |
| dre-eventos-fix | `...\Cursor\worktrees\dre-eventos-fix` | `main` | limpo | `origin` = deivithi/febracis-dre-eventos (clone shallow) |
| angry-bassi-58c13c | `...\Cursor\.claude\worktrees\angry-bassi-58c13c` | `claude/angry-bassi-58c13c` | 6119 linhas pendentes | `origin` + `cloud` (herdados da raiz) |
| personal-bio-post-cdf451 | `...\Cursor\.claude\worktrees\personal-bio-post-cdf451` | detached | limpo | `origin` + `cloud` (herdados da raiz) |
| charming-lichterman | `...\Cursor\worktrees\charming-lichterman` | `main` | limpo | **sem remote** |

As 10 pastas restantes de `worktrees\` (`cranky-mahavira`, `determined-wu-3787c2`, `festive-grothendieck`, `gifted-boyd`, `heuristic-ritchie`, `inspiring-dijkstra`, `modest-dirac`, `naughty-wilson`, `peaceful-jepsen`, `quirky-liskov`, `upbeat-mirzakhani`) são também **sem remote** — shells ou cópias de trabalho locais.

## Remotes e alertas

| Alerta | Detalhe |
|---|---|
| `deivithilopes-ai/declaw` não existe | `gh api` → HTTP 404 e `git ls-remote` → "Repository not found". O `config.json` o declarava como **canonical**; corrigido em 30/09/2026. `declaw` está `ahead 1` do `cloud/main` congelado em `8fb344c` (24/05/2026) |
| `deivithilopes-ai/cursor-agent-os` congelado | Existe e responde, mas o último push é 28/06/2026; o `main` local está à frente. O mirror `cloud` não está sendo sincronizado |
| `cybersecurity-skills` divergente | ahead 33 / behind 223 em relação ao fork upstream |
| Clone shallow | `dre-eventos-fix` tem 1 commit local; medições de atraso só valem contra o repo canônico |

## Repositórios Git independentes vs. worktrees

As 14 pastas de `worktrees\` **não são** worktrees do repo raiz: cada uma tem `.git` próprio (arquivo, não diretório) e histórico independente (ADR-003).

`git worktree list` na raiz retorna apenas 4 entradas — a própria raiz, `.cline/worktrees/f3fe6/Cursor` (branch `cline/f3fe6`), `.claude/worktrees/angry-bassi-58c13c` e `.claude/worktrees/personal-bio-post-cdf451`.

## Repositórios GitHub

| Repositório | Conta | Visibilidade | Fork | Arquivado | Último push | URL |
|---|---|---|---|---|---|---|
| deivithi/agent-smith-v6 | deivithi | privado | não | não | 2026-04-12T18:26:51Z | https://github.com/deivithi/agent-smith-v6 |
# PROJECTS_INDEX — Inventário Canônico de Projetos

> Atualizado: 30/09/2026 — remotes reconstruídos de `git remote -v` real; tabela do GitHub regenerada direto da API.
> Fonte local: `C:\Users\deivithi.lopes\Documents`
> Este arquivo é o ponto de entrada para qualquer sessão de trabalho.

> **Contagens voláteis não vivem aqui.** São recomputadas por `~/.claude/scripts/memory-doctor.ps1` e publicadas em [MEMORY_STATE.md](MEMORY_STATE.md). Este arquivo guarda identidade, caminhos, remotes e relações.

## Estado do inventário

- Repositórios locais detectados: **22** (varredura `.git` sob `Documents`, profundidade 4)
- Repositórios GitHub da conta **`deivithi`** (a ativa): **47** (verificado 30/09/2026)
- Contas autenticadas: `deivithi` (ativa) e `deivithilopes-ai`. A segunda **não** é somada a esta contagem: `gh api user/repos` sempre responde pela conta ativa, então listá-la exigiria trocar de conta. O total das duas contas **não é 47** — é 47 + o que houver na mirror
- Inventário JSON completo: `C:\Users\deivithi.lopes\Documents\Codex\2026-09-22\voc-j-tem-mapeado-todos-os\outputs\PROJECTS_INVENTORY.json`
- **Correção de 30/09/2026:** a versão anterior desta tabela marcava `(sem origin)` nas 8 linhas que **têm** remote. Era erro sistemático de leitura, não ausência real. Os remotes abaixo foram lidos de `git remote -v`.

## Repositórios locais

| Projeto | Caminho | Branch | Estado | Remote principal |
|---|---|---|---|---|
| Cursor (raiz) | `C:\Users\deivithi.lopes\Documents\Cursor` | `main` | contagem ao vivo no [MEMORY_STATE.md](MEMORY_STATE.md) | `origin` + `cloud` = deivithi/cursor-agent-os e deivithilopes-ai/cursor-agent-os |
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

As **13** pastas de `worktrees\` sem remote são: `charming-lichterman`, `cranky-mahavira`, `determined-wu-3787c2`, `festive-grothendieck`, `gifted-boyd`, `heuristic-ritchie`, `inspiring-dijkstra`, `modest-dirac`, `naughty-wilson`, `peaceful-jepsen`, `quirky-easley`, `quirky-liskov`, `upbeat-mirzakhani`. A décima quarta, `dre-eventos-fix`, **tem** remote e está na tabela acima.

Três têm conteúdo substantivo (`determined-wu-3787c2` com 17 arquivos rastreados, `festive-grothendieck` com 21, `dre-eventos-fix` com 157); as demais são shells de 1 a 5 arquivos. Contagem e detalhe ao vivo: [MEMORY_STATE.md](MEMORY_STATE.md).

## Remotes e alertas

| Alerta | Detalhe |
|---|---|
| `deivithilopes-ai/declaw` não existe | `gh api` → HTTP 404 e `git ls-remote` → "Repository not found". O `config.json` o declarava como **canonical**; corrigido em 30/09/2026. `declaw` está `ahead 1` do `cloud/main` congelado em `8fb344c` (24/05/2026) |
| `deivithilopes-ai/cursor-agent-os` congelado | Existe e responde, mas o último push é 28/06/2026; o `main` local está à frente. O mirror `cloud` não está sendo sincronizado |
| `cybersecurity-skills` divergente | ahead 33 / behind 223 em relação ao fork upstream |
| Clone shallow | `dre-eventos-fix` tem 1 commit local; medições de atraso só valem contra o repo canônico |

## Repositórios Git independentes vs. worktrees

As 14 pastas de `worktrees\` **não são** worktrees do repo raiz: cada uma tem `.git` **próprio e é um diretório** (não um arquivo de ponteiro — medido em 30/09/2026) e histórico independente (ADR-003).

`git worktree list` na raiz retorna apenas 4 entradas — a própria raiz, `.cline/worktrees/f3fe6/Cursor` (branch `cline/f3fe6`), `.claude/worktrees/angry-bassi-58c13c` e `.claude/worktrees/personal-bio-post-cdf451`.

## Repositórios GitHub

> Regenerado em 30/09/2026 direto da API do GitHub (conta ativa `deivithi`).

| Repositório | Conta | Visibilidade | Fork | Arquivado | Último push | URL |
|---|---|---|---|---|---|---|
| deivithi/agent-smith-v6 | deivithi | privado | não | não | 2026-04-12T18:26:51Z | https://github.com/deivithi/agent-smith-v6 |
| deivithi/ai-coach-landing | deivithi | privado | não | não | 2026-02-17T05:04:05Z | https://github.com/deivithi/ai-coach-landing |
| deivithi/ai-po-os-portal | deivithi | público | não | não | 2026-09-29T16:53:03Z | https://github.com/deivithi/ai-po-os-portal |
| deivithi/ai-prompt-pack | deivithi | privado | não | não | 2026-02-22T17:57:50Z | https://github.com/deivithi/ai-prompt-pack |
| deivithi/ai-sales-intelligence | deivithi | público | não | não | 2026-04-06T18:59:58Z | https://github.com/deivithi/ai-sales-intelligence |
| deivithi/ai-sales-intelligence-lead-magnet | deivithi | público | não | não | 2026-04-08T16:09:00Z | https://github.com/deivithi/ai-sales-intelligence-lead-magnet |
| deivithi/ai-tracer | deivithi | privado | não | não | 2026-03-27T03:10:55Z | https://github.com/deivithi/ai-tracer |
| deivithi/Antigravity-2 | deivithi | privado | não | não | 2026-01-15T02:29:21Z | https://github.com/deivithi/Antigravity-2 |
| deivithi/app-axiom | deivithi | privado | não | não | 2026-04-18T21:41:00Z | https://github.com/deivithi/app-axiom |
| deivithi/aria-agent | deivithi | privado | não | não | 2026-03-14T02:41:30Z | https://github.com/deivithi/aria-agent |
| deivithi/autoresearch | deivithi | público | sim | não | 2026-04-16T23:08:38Z | https://github.com/deivithi/autoresearch |
| deivithi/caverna | deivithi | público | não | não | 2026-04-20T00:35:27Z | https://github.com/deivithi/caverna |
| deivithi/civictrust | deivithi | privado | não | não | 2026-09-24T19:58:39Z | https://github.com/deivithi/civictrust |
| deivithi/claude-code-architecture | deivithi | privado | não | não | 2026-05-09T02:53:51Z | https://github.com/deivithi/claude-code-architecture |
| deivithi/clawd.bot | deivithi | privado | não | não | 2026-01-27T02:34:10Z | https://github.com/deivithi/clawd.bot |
| deivithi/clawdbot | deivithi | privado | não | não | 2026-01-27T03:58:09Z | https://github.com/deivithi/clawdbot |
| deivithi/cursor-agent-os | deivithi | público | não | não | 2026-09-30T11:39:41Z | https://github.com/deivithi/cursor-agent-os |
| deivithi/declaw | deivithi | privado | não | não | 2026-05-24T19:55:49Z | https://github.com/deivithi/declaw |
| deivithi/diagnostico-express-500-hoje | deivithi | privado | não | não | 2026-02-21T10:10:18Z | https://github.com/deivithi/diagnostico-express-500-hoje |
| deivithi/dossie | deivithi | privado | não | não | 2026-09-03T21:10:03Z | https://github.com/deivithi/dossie |
| deivithi/dre-eventos-ops | deivithi | privado | não | não | 2026-07-01T13:15:47Z | https://github.com/deivithi/dre-eventos-ops |
| deivithi/express | deivithi | privado | não | não | 2026-01-27T02:38:04Z | https://github.com/deivithi/express |
| deivithi/febracis-brain | deivithi | privado | não | não | 2026-09-26T22:02:11Z | https://github.com/deivithi/febracis-brain |
| deivithi/febracis-dre | deivithi | público | não | não | 2026-09-17T11:12:20Z | https://github.com/deivithi/febracis-dre |
| deivithi/febracis-dre-eventos | deivithi | privado | não | não | 2026-09-27T05:15:24Z | https://github.com/deivithi/febracis-dre-eventos |
| deivithi/febracis-landing | deivithi | privado | não | não | 2026-03-27T02:19:10Z | https://github.com/deivithi/febracis-landing |
| deivithi/fluxo-aurora-app | deivithi | privado | não | não | 2026-08-25T20:07:49Z | https://github.com/deivithi/fluxo-aurora-app |
| deivithi/flw-insights | deivithi | privado | não | não | 2026-09-22T20:32:19Z | https://github.com/deivithi/flw-insights |
| deivithi/gbrain-graphify-out | deivithi | público | não | não | 2026-09-01T06:26:06Z | https://github.com/deivithi/gbrain-graphify-out |
| deivithi/Google-AI-Studio | deivithi | privado | não | não | 2025-12-21T16:32:59Z | https://github.com/deivithi/Google-AI-Studio |
| deivithi/govforce-landing | deivithi | privado | não | não | 2026-02-22T19:39:18Z | https://github.com/deivithi/govforce-landing |
| deivithi/helix | deivithi | privado | não | não | 2026-09-20T06:00:19Z | https://github.com/deivithi/helix |
| deivithi/helix-ai-harness | deivithi | privado | não | não | 2026-09-13T17:10:37Z | https://github.com/deivithi/helix-ai-harness |
| deivithi/hermes-agent | deivithi | público | sim | não | 2026-09-27T01:57:20Z | https://github.com/deivithi/hermes-agent |
| deivithi/lionclaw | deivithi | privado | não | não | 2026-07-07T02:45:41Z | https://github.com/deivithi/lionclaw |
| deivithi/open-design | deivithi | público | sim | não | 2026-07-10T08:11:46Z | https://github.com/deivithi/open-design |
| deivithi/openclaw-command-center | deivithi | privado | não | não | 2026-02-04T01:23:38Z | https://github.com/deivithi/openclaw-command-center |
| deivithi/paramortos | deivithi | privado | não | não | 2026-07-05T02:18:28Z | https://github.com/deivithi/paramortos |
| deivithi/pos-febracis | deivithi | privado | não | não | 2026-08-17T16:35:27Z | https://github.com/deivithi/pos-febracis |
| deivithi/pulsofinance | deivithi | privado | não | não | 2026-09-27T04:54:16Z | https://github.com/deivithi/pulsofinance |
| deivithi/radar-ia | deivithi | privado | não | não | 2026-04-01T22:04:33Z | https://github.com/deivithi/radar-ia |
| deivithi/roadmap-v0-1-clawdiano-global | deivithi | privado | não | não | 2026-02-20T02:07:59Z | https://github.com/deivithi/roadmap-v0-1-clawdiano-global |
| deivithi/segundo-cerebro | deivithi | privado | não | não | 2026-09-30T11:25:08Z | https://github.com/deivithi/segundo-cerebro |
| deivithi/Siftly | deivithi | privado | não | não | 2026-09-30T11:24:18Z | https://github.com/deivithi/Siftly |
| deivithi/szchat-historico | deivithi | privado | não | não | 2026-07-11T16:40:23Z | https://github.com/deivithi/szchat-historico |
| deivithi/vscode-cursor | deivithi | privado | não | não | 2026-09-28T12:09:15Z | https://github.com/deivithi/vscode-cursor |
| deivithi/zo-vault | deivithi | privado | não | não | 2026-09-30T06:02:35Z | https://github.com/deivithi/zo-vault |

> `deivithilopes-ai/cursor-agent-os` existe mas não aparece na listagem de propriedade da conta ativa; a composição das contas muda — rodar o doctor para o estado atual.

## Procedimento de início de sessão
1. Rodar o doctor: `pwsh -File "$env:USERPROFILE\.claude\scripts\memory-doctor.ps1"` — recomputa HEADs, contagens e pendências e reescreve o bloco que o DSH injeta.
2. Ler `MEMORY_STATE.md` para o estado vivo; ler este índice para caminhos e remotes.
3. Confirmar o projeto-alvo pelo caminho local e pelo remote GitHub.
4. Executar `git status -sb` antes de modificar qualquer arquivo.
5. Trabalhar no caminho local canônico; tratar worktrees como cópias controladas.
6. Atualizar este índice após criar, mover ou clonar um projeto.

## Limites
- O inventário local cobre repositórios Git sob `Documents`; casos conhecidos fora dela: `civictrust` (coberto acima), `OneDrive\Documents\VS CODE\pulsofinance` (não-git) e `OneDrive\Documents\VS CODE\automacoes\fio-ia` (não-git).
- O inventário GitHub cobre os repositórios das duas contas autenticadas; organizações e repositórios de terceiros acessíveis por colaboração exigem consulta adicional.
- O índice fornece descoberta e roteamento; o conteúdo completo de cada projeto é carregado quando a sessão abre o respectivo caminho.
- Contagens de skills, rules, hooks e worktrees **não** são mantidas aqui à mão: vivem no `MEMORY_STATE.md` gerado.

## Mapa de skills, documentação e acesso
- Mapa completo: `C:\Users\deivithi.lopes\Documents\Codex\2026-09-22\voc-j-tem-mapeado-todos-os\outputs\PROJECT_KNOWLEDGE_MAP.json`
- O mapa liga cada repositório local às suas pastas `.cursor/skills`, `.claude/skills`, `skills`, `docs`, `references`, `AGENTS.md`, `README.md` e arquivos de configuração.
- Acesso GitHub CLI: autenticado para `deivithi` (conta ativa) e `deivithilopes-ai`.
- Segredos não são copiados para o índice; apenas nomes de variáveis e existência de arquivos de autenticação são registrados.
- "Pronto" significa descoberta e roteamento documentados. A validade de credenciais de cada serviço e o acesso a ambientes remotos precisam ser verificados no momento de uso.
- **Correção de 30/09/2026:** a versão anterior declarava "1837 arquivos `SKILL.md` e 6484 Markdown". Contagem real no workspace: **2787 `SKILL.md` e 10029 Markdown**, excluindo `node_modules`, `.venv`, `.git`, `__pycache__`, `dist` e `build`.

### Roteamento de sessão
1. Rodar o doctor e ler `MEMORY_STATE.md` + este índice.
2. Selecionar o projeto pelo nome, caminho e remote.
3. Ler as instruções do projeto antes das skills globais.
4. Usar os caminhos canônicos de documentação e skills registrados no mapa.
5. Validar a credencial/endpoint efetivo antes de operações externas.

## Validação operacional
- Plano: `C:\Users\deivithi.lopes\Documents\Codex\2026-09-22\voc-j-tem-mapeado-todos-os\outputs\PROJECT_VALIDATION_PLAN.md`
- Relatório: `C:\Users\deivithi.lopes\Documents\Codex\2026-09-22\voc-j-tem-mapeado-todos-os\outputs\PROJECT_VALIDATION_REPORT.md`
- Evidência estruturada: `C:\Users\deivithi.lopes\Documents\Codex\2026-09-22\voc-j-tem-mapeado-todos-os\outputs\PROJECT_VALIDATION_REPORT.json`
- Última execução: 4 PASS, 18 WARN, 0 FAIL (22 repositórios à época — não inclui `civictrust`, criado depois).
- Matriz segura de acessos: `C:\Users\deivithi.lopes\Documents\Codex\2026-09-22\voc-j-tem-mapeado-todos-os\outputs\PROJECT_ACCESS_MATRIX.md`
- Validação efetiva de tokens e acessos: `C:\Users\deivithi.lopes\Documents\Codex\2026-09-22\voc-j-tem-mapeado-todos-os\outputs\PROJECT_ACCESS_VALIDATION.md`

Os artefatos acima são um retrato de **22/09/2026**. Não os trate como estado atual: para isso, rode o doctor.

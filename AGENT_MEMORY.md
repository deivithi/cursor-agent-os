# MEMÓRIA DO AGENTE — Deivithi Lopes

## Identidade
- Nome: Deivithi Lopes
- Cargo: Product Owner de Plataformas (Salesforce)
- Empresa: Febracis
- Áreas: Vendas, Educação
- Idioma: pt-BR
- Fuso: America/Sao_Paulo (GMT-3)

## Protocolo operacional (ADR-009) — permanente

Declaração direta do operador em 08/09/2026 (confiança 0.95):

- Sessão padrão = **auto-approve**. Não perguntar "posso executar?" em trabalho reversível.
- Ciclo travado: **entender o pedido → montar plano → executar o plano**.
- Não entregar só o plano e esperar OK. Plano Mode não é gate humano.
- Gauntlet (ADR-008) continua obrigatório antes de declarar done.
- Carve-outs intactos: DROP/TRUNCATE/DELETE em massa, `git push --force` em main compartilhado, `rm -rf` fora do workspace, deploy de produção, cripto/LGPD/sanitização BD, skip-permissions fora de sandbox.
- Fonte: `rules/plan-and-execute.md`

Declaração direta do operador em 08/09/2026 (confiança 0.95) — **ADR-010**:

- O operador **não** é o depurador. Agente diagnostica, corrige e revalida.
- Proibido apontar erros, falhas ou challenges para o operador resolver.
- Instrução subótima → executar a alternativa correta, sem `[s/n]`.
- Relato ao operador = resultado feito, não lista de problemas.
- Fonte: `rules/anti-sycophancy.md` + `rules/plan-and-execute.md`

Declaração direta do operador em 08/09/2026 (confiança 0.95) — **ADR-011**:

- Pediu → faz. Máxima autonomia além de conversar.
- **Toda ação** casa com o catálogo de skills (`SKILLS_INDEX.md` + contexto da sessão). Match → carregar `SKILL.md` e potencializar. Sem perguntar se deve usar.
- Skill interna vence agency agent. Sem match → segue direto.
- Fonte: `rules/plan-and-execute.md`

Declaração direta do operador em 08/09/2026 — **ADR-013**:

- 1ª resposta imediata. Payload da sessão (MCP, git_status, AGENTS.md) basta.
- Proibido ritual de memória / grep em massa no 1º turno de status/sim-não.
- Fonte: `rules/first-response.md`

## Stack
- Salesforce (Sales, Service, Marketing, Experience)
- Node.js, TypeScript, Python
- Supabase, Vercel, Netlify, Shopify, n8n
- Claude Code, Cursor, NotebookLM, Hugging Face
- **Hermes** (scheduler + skills + cron + desktop GUI; perfil `default` ativo;
  skills em `%LOCALAPPDATA%\hermes\skills\`, scripts em `%LOCALAPPDATA%\hermes\scripts\`)

## Workspace canônico
- **Raiz:** `C:\Users\deivithi.lopes\Documents\Cursor`
- **Índices:** [PROJECTS_INDEX.md](PROJECTS_INDEX.md), [SKILLS_INDEX.md](SKILLS_INDEX.md)
- **Entry point:** [CONTEXT.md](CONTEXT.md)
- **Estado vivo (gerado):** [MEMORY_STATE.md](MEMORY_STATE.md) — contagens, HEADs e pendências recomputados do disco
- **Gerador:** `~/.claude/scripts/memory-doctor.ps1` · **Injeção automática:** `~/.dsh/AGENTS.md` (o DSH injeta em toda sessão, sem comando)

## Infraestrutura canônica — permanente
- **ZoComputer:** máquina virtual principal do ecossistema; considerar primeiro para runtime, operações e deploys.
- **PostgreSQL na ZoComputer:** banco de dados principal, já com componentes em produção; tratar como ambiente real e preservar dados existentes.
- **Destinos recorrentes:** ZoComputer, Vercel e Cloudflare. Identificar o destino pelo projeto antes de executar deploy ou alteração operacional.
- **Regra de continuidade:** recuperar esse contexto automaticamente em toda sessão, junto com o mapa do projeto, sem depender de comandos extras ou nova configuração manual.

## Auditoria profunda DRE Eventos — 2026-09-21
- Rodada de hardening publicada e deployada: sessões `auth_epoch`, pool Postgres thread-safe/timeouts, contexto do chat server-authoritative, locks on-demand, lock de refresh órfão, CI frontend/type-check/build, Actions pinadas, CSP/ARIA/focus trap e dependências frontend atualizadas.
- Evidências: 649 testes, Ruff, build frontend, `npm audit` com 0 vulnerabilidades, CSP chat PASS, UI Fotos 45/45, smoke produção 43/43, health Zo HTTP 200/db ok.
- Pendências explícitas: restore real de backup, criptografia de backup, E2E de login com Postgres real, acessibilidade completa do chat React e locks distribuídos para múltiplas réplicas.

## Projetos ativos (negócio + deploy)
1. **Aria** — Agente IA autônomo para PMEs (Vercel)
2. **FIO-IA** — Gerador autônomo de fios no X (fio = 6 tweets), 4×/dia via Hermes cron (02/08/14/20 BRT), entrega no chat Hermes + backup em `<code_path>\state\email-corpo.txt` (legacy: Task Scheduler `.ps1`). Conta `@opanteranegra77`. **Estado 30/09/2026: parado** — os dois jobs existem e estão `enabled`, mas o scheduler do Hermes não roda desde 08/07/2026; último backup também de 08/07. `code_path` não é repo git
3. **ai-landing** — Landing Febracis com IA + QR (worktree `festive-grothendieck`, Netlify)
4. **DRE_Eventos** — DRE Febracis Eventos (Flask/React), prod `dre-eventos-deivithi.zocomputer.io`; mapa canônico em `DRE_Eventos/docs/AGENT_CONTEXT_DRE.md`
5. **declaw** — Spec-first factory Electron + Hono. Deploy canônico: Zo Computer
6. **webwright** — Automação web Playwright. Sincronizado com `microsoft/webwright` (0/0); a nota "behind 4" estava desatualizada
7. **civictrust** — CivicTrust Public Action Gateway, gateway de integridade transacional para serviços públicos. Go; `deivithi/civictrust`; HEAD `49b840c` (24/09), demo pública na Vercel; artefatos em `out/civictrust/`. **Descoberto em 30/09/2026** — estava fora de toda a memória
8. **Pulso Finance** — Skill local `pulso-finance` **v5.0.0** (a versão 5.6.0 registrada antes estava errada em todas as 7 cópias do disco) + working directory não-git em `OneDrive\Documents\VS CODE\pulsofinance` com `.env.local`. Repo `deivithi/pulsofinance` existe (último push 27/09/2026), não clonado em `Documents/`

## Estrutura local (Documents\Cursor)

### Monorepo raiz
- Git `main`, **dual-remote** (ADR-006) — correção 30/09/2026: a linha anterior dizia "sem remote", contrariando o próprio ADR-006
- `origin` = `https://github.com/deivithi/cursor-agent-os.git` (conta ativa, push do dia-a-dia)
- `cloud` = `https://github.com/deivithilopes-ai/cursor-agent-os.git` (mirror, congelado no push de 28/06/2026)
- Versiona config compartilhada (skills, agents, rules, scripts, memória)
- ADR-001: não rastreia `worktrees/`, `DRE_Eventos/`, `declaw/`, `webwright/`, `cybersecurity-skills/`

### Repositórios aninhados
| Path | Remote / notas (verificado 30/09/2026) |
|------|-----------------------------|
|| `DRE_Eventos/` | `origin/main` (`deivithi/febracis-dre-eventos`, privado). HEAD `6380b65` (22/09); working tree com 12 caminhos pendentes (4 modificados + 8 não rastreados). Contagem ao vivo: [MEMORY_STATE.md](MEMORY_STATE.md) |
|| `declaw/` | `origin` = `deivithi/declaw` (**destino válido**); `cloud` = `deivithilopes-ai/declaw` — **NÃO EXISTE (HTTP 404)**. HEAD `d741815` (28/08), limpo, ahead 1 do cloud congelado em `8fb344c` (24/05). Deploy canônico: **Zo Computer** |
| `webwright/` | `origin/main` (`microsoft/webwright`). HEAD `bc26750` (03/08), **sincronizado** — a nota "behind 4" estava desatualizada |
| `cybersecurity-skills/` | `origin/main` (`mukul975/Anthropic-Cybersecurity-Skills`). **ahead 33 / behind 223** — a nota "behind 137" vinha de fetch antigo |
| `..\civictrust\` (fora do workspace) | `origin` = `deivithi/civictrust`. HEAD `49b840c` (24/09), demo pública na Vercel. Repo real descoberto em 30/09/2026; antes ausente de toda a memória |
| `..\Corretor2.0\` | **sem remote**. HEAD `2a5430f` (17/08), limpo |

### Worktrees (14)
- 14 pastas com `.git` **próprio** — são repositórios independentes, não worktrees do repo raiz (ADR-003)
- **Com código:** `festive-grothendieck` (ai-landing), `determined-wu-3787c2` (planos/ouroboros), `dre-eventos-fix` (DRE, clone shallow, 161 commits atrás)
- **Shells vazios (11):** charming-lichterman, cranky-mahavira, gifted-boyd, heuristic-ritchie, inspiring-dijkstra, modest-dirac, naughty-wilson, peaceful-jepsen, quirky-easley, quirky-liskov, upbeat-mirzakhani
- `git worktree list` na raiz devolve 4 entradas distintas: a raiz, `.cline/worktrees/f3fe6/Cursor`, `.claude/worktrees/angry-bassi-58c13c` e `.claude/worktrees/personal-bio-post-cdf451`

### Mapa DRE Eventos — verificado em 30/09/2026
- **Cópia canônica local:** `C:\Users\deivithi.lopes\Documents\Cursor\DRE_Eventos`
- **Remote:** `https://github.com/deivithi/febracis-dre-eventos.git`; branch `main`; repositório privado; **HEAD `6380b65` (22/09/2026)** — o `682cedf` registrado antes ficou 14 commits atrás
- **Cópia adicional:** `worktrees\dre-eventos-fix` (mesmo remote/branch), commit `d95783b`, **161 commits atrás** do canônico. É clone **shallow** (1 commit local), então o atraso só é mensurável contra o repo canônico. Não usar como fonte canônica
- **Cópia temporária detectada:** `%LOCALAPPDATA%\Temp\dre_antes_93a613b`; não tratar como fonte canônica
- **Aplicação:** Flask + Waitress, Python 3.12, snapshots Parquet, Postgres para auth/chat; frontend React 18 + Vite + TypeScript + Tailwind em `frontend/`
- **Domínios principais:** DRE, OCs/TOTVS, orçado/Google Sheets, matching `turma_key`, relatórios/PDF, fotos imutáveis, ranking, briefing e Analista Hermes
- **Produção:** VM Zo 24/7; código em `main`; deploy via `git pull` + restart; refresh de dados na VM
- **Fontes canônicas:** `README.md`, `docs/AGENT_CONTEXT_DRE.md`, `docs/spec/README.md`, `docs/spec/10-operacao-zo.md`, `docs/spec/03-dre-business-rules.md`, `.hermes.md`, `.cursor/skills/dre-eventos/SKILL.md`
- **Regra de segurança:** nunca versionar `.env`, credenciais, snapshots grandes, logs sensíveis ou dados brutos com PII
- **Working tree do projeto (30/09):** `M scripts/dre_pull_watcher.py`, `M static/dist/chat.css`, `M static/dist/chat.js`, `M tests/test_routes.py`, mais não rastreados (`data/logs/`, `docs/analysis/2026-09-17-faturamento-txs-cartao-analise.md`, seis `scripts/zo/_*.py`). A afirmação anterior de que restava "apenas `docs/analysis/`" estava errada
- **Testes:** **649** itens coletáveis no HEAD atual (a contagem de 595 registrada antes era do HEAD antigo). Validar sempre com `.venv\Scripts\python.exe`; o `py -3` global não tem `psycopg2`
- **Acesso Zo:** MCP global `cursor-to-zo2` em `%USERPROFILE%\.cursor\mcp.json` confirmado; helper canônico `scripts/probes/refresh_dre_cache_tmp.py` executou diagnósticos da VM com sucesso. `FABRIC_AUTH_MODE=unknown` na VM; Fabric segue PC + sync.
- **Não verificável sem rede:** produção na VM Zo, Postgres, `FABRIC_AUTH_MODE`, health HTTP 200, smoke 43/43, UI 45/45 e `npm audit` — são registros de auditoria, não estado observado nesta máquina
- **Verificação:** 595 testes, Ruff, build frontend e UI Playwright 45/45 passaram; smoke de produção 43/43 passou; deploy final `5f113aa` respondeu health HTTP 200 com `db=ok`. `py -3` global não tem `psycopg2`.

## Skills (resumo) — verificado 30/09/2026
- Custom: **110** com `SKILL.md` em `skills/` (112 diretórios: `_templates` não é skill, e `pptx-generator` é plugin bundle — ver abaixo)
- Cyber: **736** com `SKILL.md` (739 diretórios) em `cybersecurity-skills/skills/`
- Scientific: **22** em `scientific-skills/skills/`
- Commands: **47** arquivos `.md` em `commands/`
- Sync Cursor: **63** diretórios em `~/.cursor/skills` — mas o script define **30** essenciais, e a tarefa `Febracis-Cursor-SyncDaily` está **DISABLED** (última execução 16/06/2026). Os 33 restantes são resíduo congelado; o "sync diário" não roda
- **Plugin bundle, não skill:** `skills/pptx-generator` tem `.claude-plugin/`, `plugin.json`, `marketplace.json`, `agents/` e **5 skills aninhadas** em `skills/`. Não precisa de `SKILL.md` próprio — a auditoria de 30/09/2026 corrigiu a classificação anterior ("skill quebrada")
- Detalhe e listas: [SKILLS_INDEX.md](SKILLS_INDEX.md). Contagens vivas: [MEMORY_STATE.md](MEMORY_STATE.md)

## GitHub CLI
- gh instalado, conta **deivithi** (ativa) + **deivithilopes-ai** (mirror)
- Repos citados: febracis-dre-eventos, febracis-dre, declaw, pulsofinance, aria-agent, caverna, etc.
- **Raiz Cursor Agent OS**: `https://github.com/deivithi/cursor-agent-os` (criado 22/06/2026, ver ADR-006)
  - `origin` = deivithi/cursor-agent-os (conta ativa)
  - `cloud` = deivithilopes-ai/cursor-agent-os (mirror, padrão declaw)

## OpenWiki Personal Brain (jul/2026)
- **Status: BLOQUEADO** (desde 15/07/2026) — connector `x` com `enabled: false`, sem raw, sem créditos API
- **🚫 NÃO rodar `openwiki auth x` nem `openwiki personal --update`** sem `OPENWIKI_X_CLIENT_ID` preenchido em `~/.openwiki/.env`. Sem client_id o CLI abre `https://x.com/i/oauth2/authorize?client_id=` **vazio** → tela de login do X em loop (incidente 2026-09-21). **`~/.openwiki/.env` NÃO existe** em 30/09/2026 — verificado. Ou seja: o gate está fechado e o bloqueio continua valendo
- **Guard:** hook `hooks/openwiki-auth-guard.js` (PreToolUse, matcher `*`) bloqueia esses dois comandos; override consciente do operador = incluir `OPENWIKI_AUTH_OK` no comando. **Ressalva importante:** esse hook está registrado apenas em `~/.claude/settings.json`; o DeepSeek Harness **não monta hooks**, então nesta harness o bloqueio depende da disciplina do agente, não de mecanismo
- **Wiki path:** `~/.openwiki/wiki` — memória **proativa** (ingestão X/bookmarks → Markdown local); **leitura é segura, não exige auth**
- **Papel:** complementa CONTEXT/AGENT_MEMORY (reativo); não substitui
- **INSTRUCTIONS:** `~/.openwiki/INSTRUCTIONS.md` — bookmarks/favoritos têm peso maior na síntese
- **Hermes cron:** job `f8a2b1c4d6e9` — **PAUSADO** desde 10/09/2026 (`xurl/OpenWiki OAuth loop: missing client_id`); não reativar sem o gate acima
- **Auth X:** requer `OPENWIKI_X_CLIENT_ID` + créditos API (pay-per-use); `OPENWIKI_X_CLIENT_SECRET` opcional (só se client confidential — PKCE / clientAuth none); secrets só em `~/.openwiki/.env`
- **Alternativa ativa para sinais do X:** `x_search` (Zo) e skill `agent-reach` — não usar o OpenWiki
- **Skill:** `skills/openwiki-personal-brain/`

## MCP `xapi` (X) — REMOVIDO em 21/09/2026
- **Causa do "login do X em loop":** o servidor MCP `xapi` (`npx @xdevplatform/xurl --app febracis-x-mcp mcp https://api.x.com/mcp`) subia callback OAuth em **localhost:8080** e, sem `client_id` (`~/.xurl` é DIRETÓRIO vazio; xurl espera ARQUIVO), abria `https://x.com/i/oauth2/authorize?client_id=` vazio → tela de login do X a cada start do MCP.
- **Identificador:** no histórico do navegador, `redirect_uri=http://localhost:8080/callback` = xurl/MCP `xapi`. Outro redirect = outra origem.
- **Removido de:** `~/.cursor/mcp.json` e `~/OneDrive/Documents/VS CODE/.cursor/mcp.json` (Cursor funde global + projeto). Blocos guardados em `*.xapi-removed-entry.json`; backups `*.bak-xapi-remove-*`. Processo `xurl.exe` encerrado e porta 8080 liberada.
- **Guard:** o mesmo hook `hooks/openwiki-auth-guard.js` bloqueia edição de qualquer `mcp.json` que reintroduza `@xdevplatform/xurl` sem credencial em `~/.xurl`; override = `XURL_MCP_OK`.
- **X segue operacional sem ele:** Zo nativo — `use_app_x` (postar/DM) e `x_search` (ler). Conta: **`@opanteranegra77`** — aparece em **9 arquivos** do workspace canônico (`AGENT_MEMORY.md`, `config.json`, `DECISIONS.md`, `SESSION_LOG.md`, `commands/browser.md`, `.claude/commands/browser.md`, `skills/composio-tool-orchestrator/SKILL.md`, `skills/openwiki-fio-synthesizer/SKILL.md` e `skills/openwiki-fio-synthesizer/references/humanizer-fio-rules.md`), e em mais 5 cópias sob `.claude/worktrees/`. A menção anterior a `@opanteraos` aparecia em 4 arquivos **apenas dentro da própria nota de correção** — não é afirmada como handle vigente em lugar nenhum. **Não confirmável localmente** (sem MCP do X e sem créditos de API)
- **Para reativar o MCP do X:** criar app OAuth em developer.x.com e gravar `client_id`/`client_secret` em `~/.xurl` **como arquivo**.
- **Verificar se voltou:** `grep -c xdevplatform ~/.cursor/mcp.json` e `netstat -ano | grep :8080`.

## Configurações
- Shell: PowerShell
- Sync agendado: Task Scheduler `\Febracis-Cursor-SyncDaily` — **DISABLED** desde 16/06/2026. O "sync diário" descrito em versões anteriores deste arquivo não roda
- Log sync: `%LOCALAPPDATA%\febracis-logs\cursor-sync.log`
- Cursor no Windows: instalação única User em `%LOCALAPPDATA%\Programs\cursor`, canal nativo protegido pela tarefa invisível persistente `Febracis-Cursor-UpdateWatchdog`; `scripts/Atualizar-Cursor-Seguro.ps1` audita/repara a instalação e a tarefa. Não manter cópia System em `C:\Program Files\cursor`.
- Hermes cron: jobs `bcbba63017bf` (FIO-IA gerar fio) e `c4b1e7326a7a` (watchdog) existem e estão `enabled`, mas o **scheduler está parado** — `ticker_heartbeat` e `ticker_last_success` congelados em 08/07/2026. Job OpenWiki `f8a2b1c4d6e9` pausado desde 10/09/2026

## Injeção automática de contexto (descoberto 30/09/2026)
- **O que funciona sem comando:** o DSH injeta, num baseline durável do primeiro request, o `$DSH_HOME/AGENTS.md` + a cadeia de `AGENTS.md`/`CLAUDE.md` do projeto (raiz → cwd), com budget de **65.536 bytes**. Pacote `@deepseek-ai/dsh-agent-instructions`, montado pelo bundle `dsh-base`
- **Consequência:** `~/.dsh/AGENTS.md` carrega identidade, infraestrutura canônica e o **bloco de estado gerado** — é o vetor que faz a memória funcionar sem comando
- **O que NÃO funciona nesta harness:** não há subsistema de memória nativo (os MCPs de memória são default-off e exigem `--patch`); não há statusline; e **nenhum hook do workspace é montado** pelo DSH (`hooks-claude-code` existe no fonte mas não está em `dsh-base`, `dsh-web-app` nem nos perfis). Só `AGENTS.md`/`CLAUDE.md` entram sozinhos
- **Gerador:** `~/.claude/scripts/memory-doctor.ps1` — recomputa tudo do disco e reescreve `MEMORY_STATE.md` + o bloco em `~/.dsh/AGENTS.md`

## Última atualização — 30/09/2026
- **30/09/2026** — Reconciliação completa da memória com o disco e o Git: 20 contradições corrigidas, incluindo DRE (HEAD `6380b65`, 649 testes), `declaw cloud` inexistente (404), remotes da raiz que contrariavam o ADR-006, sync do Cursor desligado desde 16/06, scheduler do Hermes parado desde 08/07, handle do X e contagens de skills. Criados `MEMORY_STATE.md` (gerado) e `~/.claude/scripts/memory-doctor.ps1`; criado `~/.dsh/AGENTS.md`, que o DSH injeta em toda sessão. Registrado o projeto `civictrust` e as sessões de 22–30/09 que estavam em lacuna.
- **21/09/2026** — Mapa persistente do DRE Eventos confirmado na máquina e no GitHub; memória project/user sincronizada; suíte `.venv` verde com 595 testes (contagem daquele HEAD).
- **08/09/2026** — ADR-009/010/011: auto-approve; resolver sem transferir; pediu → faz; toda ação casa com skill.
- **22/06/2026** — Auditoria completa dos docs pessoais corrigiu: FIO-IA migrado para Hermes cron (4×/dia, ADR-005), Hermes adicionado ao stack, declaw deploy canônico = Zo Computer, webwright PRs #5/#10 registrados, DRE watcher fix registrado, Hermes skills catalogadas, n8n movido para automation.

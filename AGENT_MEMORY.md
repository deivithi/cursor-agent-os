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

## Infraestrutura canônica — permanente
- **ZoComputer:** máquina virtual principal do ecossistema; considerar primeiro para runtime, operações e deploys.
- **PostgreSQL na ZoComputer:** banco de dados principal, já com componentes em produção; tratar como ambiente real e preservar dados existentes.
- **Destinos recorrentes:** ZoComputer, Vercel e Cloudflare. Identificar o destino pelo projeto antes de executar deploy ou alteração operacional.
- **Regra de continuidade:** recuperar esse contexto automaticamente em toda sessão, junto com o mapa do projeto, sem depender de comandos extras ou nova configuração manual.

## Projetos ativos (negócio + deploy)
1. **Aria** — Agente IA autônomo para PMEs (Vercel)
|2. **FIO-IA** — Gerador autônomo de fios no X (fio = 6 tweets), 4×/dia via Hermes cron (02/08/14/20 BRT), entrega no chat Hermes + backup em `state/email-corpo.txt` (legacy: Task Scheduler `.ps1`)
3. **ai-landing** — Landing Febracis com IA + QR (worktree `festive-grothendieck`, Netlify)
4. **DRE_Eventos** — DRE Febracis Eventos (Flask/React), prod `dre-eventos-deivithi.zocomputer.io`; mapa canônico em `DRE_Eventos/docs/AGENT_CONTEXT_DRE.md`
5. **declaw** — Spec-first factory Electron + Hono
6. **webwright** — Automação web Playwright (behind 4 no origin)
|7. **Pulso Finance** — App financeiro. **Estado 22/06/2026:** apenas a skill local `pulso-finance` (v5.6.0 com símbolo PulsoMark) existe; repo GitHub `pulsofinance` **não** está clonado em `Documents/`. Tratar como projeto conceitual até repo aparecer. |

## Estrutura local (Documents\Cursor)

### Monorepo raiz
- Git `main`, sem remote — versiona config compartilhada (skills, agents, rules, scripts, memória)
- ADR-001: não rastreia `worktrees/`, `DRE_Eventos/`, `declaw/`, `webwright/`, `cybersecurity-skills/`

### Repositórios aninhados
| Path | Remote / notas (16/06/2026) |
|------|-----------------------------|
|| `DRE_Eventos/` | `origin/main` (`deivithi/febracis-dre-eventos`). Base verificada em 21/09/2026: `682cedf`; working tree atual: `M AGENTS.md`, `M docs/AGENT_CONTEXT_DRE.md`, `?? docs/analysis/`. |
|| `declaw/` | **dois remotes** — `cloud` (deivithilopes-ai/declaw, canonical) + `origin` (deivithi/declaw, mirror). Último: 8fb344c "record Zo local smoke validation in STATUS". Deploy canônico: **Zo Computer** (não Electron desktop). |
| `webwright/` | `origin/main`, behind 4 |
| `cybersecurity-skills/` | `origin/main`, ahead 33 / behind 137 |

### Worktrees (14)
- **Com código:** `festive-grothendieck` (ai-landing), `determined-wu-3787c2` (workspace principal), `dre-eventos-fix` (DRE)
- **Shells vazios (11):** charming-lichterman, cranky-mahavira, gifted-boyd, heuristic-ritchie, inspiring-dijkstra, modest-dirac, naughty-wilson, peaceful-jepsen, quirky-easley, quirky-liskov, upbeat-mirzakhani

### Mapa DRE Eventos — verificado em 21/09/2026
- **Cópia canônica local:** `C:\Users\deivithi.lopes\Documents\Cursor\DRE_Eventos`
- **Remote:** `https://github.com/deivithi/febracis-dre-eventos.git`; branch `main`; repositório privado
- **Cópia adicional:** `worktrees\dre-eventos-fix` (mesmo remote/branch), commit `d95783b`, aproximadamente 147 commits atrás; não usar como fonte canônica
- **Cópia temporária detectada:** `%LOCALAPPDATA%\Temp\dre_antes_93a613b`; não tratar como fonte canônica
- **Aplicação:** Flask + Waitress, Python 3.12, snapshots Parquet, Postgres para auth/chat; frontend React 18 + Vite + TypeScript + Tailwind em `frontend/`
- **Domínios principais:** DRE, OCs/TOTVS, orçado/Google Sheets, matching `turma_key`, relatórios/PDF, fotos imutáveis, ranking, briefing e Analista Hermes
- **Produção:** VM Zo 24/7; código em `main`; deploy via `git pull` + restart; refresh de dados na VM
- **Fontes canônicas:** `README.md`, `docs/AGENT_CONTEXT_DRE.md`, `docs/spec/README.md`, `docs/spec/10-operacao-zo.md`, `docs/spec/03-dre-business-rules.md`, `.hermes.md`, `.cursor/skills/dre-eventos/SKILL.md`
- **Regra de segurança:** nunca versionar `.env`, credenciais, snapshots grandes, logs sensíveis ou dados brutos com PII
- **Working tree do projeto:** `main` em `5f113aa` após deploy final da documentação v1.42; permanece apenas `docs/analysis/` não rastreado, preservado sem staging
- **Acesso Zo:** MCP global `cursor-to-zo2` em `%USERPROFILE%\.cursor\mcp.json` confirmado; helper canônico `scripts/probes/refresh_dre_cache_tmp.py` executou diagnósticos da VM com sucesso. `FABRIC_AUTH_MODE=unknown` na VM; Fabric segue PC + sync.
- **Verificação:** 595 testes, Ruff, build frontend e UI Playwright 45/45 passaram; smoke de produção 43/43 passou; deploy final `5f113aa` respondeu health HTTP 200 com `db=ok`. `py -3` global não tem `psycopg2`.

## Skills (resumo)
- Custom: **104** em `skills/` (+ `_templates`)
- Cyber: **736** em `cybersecurity-skills/skills/`
- Scientific: **22** em `scientific-skills/skills/`
- Sync Cursor: **29 essenciais** → `~/.cursor/skills/` via `scripts/migrate-from-documents.ps1`
- Detalhe: [SKILLS_INDEX.md](SKILLS_INDEX.md)

## GitHub CLI
- gh instalado, conta **deivithi** (ativa) + **deivithilopes-ai** (mirror)
- Repos citados: febracis-dre-eventos, febracis-dre, declaw, pulsofinance, aria-agent, caverna, etc.
- **Raiz Cursor Agent OS**: `https://github.com/deivithi/cursor-agent-os` (criado 22/06/2026, ver ADR-006)
  - `origin` = deivithi/cursor-agent-os (conta ativa)
  - `cloud` = deivithilopes-ai/cursor-agent-os (mirror, padrão declaw)

## OpenWiki Personal Brain (jul/2026)
- **Status: BLOQUEADO** (desde 15/07/2026) — connector `x` com `enabled: false`, sem raw, sem créditos API
- **🚫 NÃO rodar `openwiki auth x` nem `openwiki personal --update`** sem `OPENWIKI_X_CLIENT_ID` preenchido em `~/.openwiki/.env`. Sem client_id o CLI abre `https://x.com/i/oauth2/authorize?client_id=` **vazio** → tela de login do X em loop (incidente 2026-09-21; ver memória `openwiki_x_oauth_login_loop`).
- **Guard ativo:** hook `hooks/openwiki-auth-guard.js` (PreToolUse, matcher `*`) bloqueia esses dois comandos; override consciente do operador = incluir `OPENWIKI_AUTH_OK` no comando
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
- **X segue operacional sem ele:** Zo nativo — `use_app_x` (postar/DM) e `x_search` (ler); conta `@opanteraos`.
- **Para reativar o MCP do X:** criar app OAuth em developer.x.com e gravar `client_id`/`client_secret` em `~/.xurl` **como arquivo**.
- **Verificar se voltou:** `grep -c xdevplatform ~/.cursor/mcp.json` e `netstat -ano | grep :8080`.

## Configurações
- Shell: PowerShell
- Sync agendado: Task Scheduler `\Febracis-Cursor-SyncDaily` (quando configurado)
- Log sync: `%LOCALAPPDATA%\febracis-logs\cursor-sync.log`
- Cursor no Windows: instalação única User em `%LOCALAPPDATA%\Programs\cursor`, canal nativo protegido pela tarefa invisível persistente `Febracis-Cursor-UpdateWatchdog`; `scripts/Atualizar-Cursor-Seguro.ps1` audita/repara a instalação e a tarefa. Não manter cópia System em `C:\Program Files\cursor`.

## Última atualização
- **21/09/2026** — Mapa persistente do DRE Eventos confirmado na máquina e no GitHub; memória project/user sincronizada; suíte `.venv` verde com 595 testes.
- **08/09/2026** — ADR-009/010/011: auto-approve; resolver sem transferir; pediu → faz; toda ação casa com skill.
- **22/06/2026** — Auditoria completa dos docs pessoais corrigiu: FIO-IA migrado para Hermes cron (4×/dia, ADR-005), Hermes adicionado ao stack, declaw deploy canônico = Zo Computer, Pulso Finance marcado como conceitual (skill-only), webwright PRs #5/#10 registrados, DRE watcher fix registrado, Hermes skills catalogadas, n8n movido para automation.

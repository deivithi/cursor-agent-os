# MEMÓRIA DO AGENTE — Deivithi Lopes

## Identidade
- Nome: Deivithi Lopes
- Cargo: Product Owner de Plataformas (Salesforce)
- Empresa: Febracis
- Áreas: Vendas, Educação
- Idioma: pt-BR
- Fuso: America/Sao_Paulo (GMT-3)

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

## Projetos ativos (negócio + deploy)
1. **Aria** — Agente IA autônomo para PMEs (Vercel)
|2. **FIO-IA** — Gerador autônomo de fios no X (fio = 6 tweets), 4×/dia via Hermes cron (02/08/14/20 BRT), entrega no chat Hermes + backup em `state/email-corpo.txt` (legacy: Task Scheduler `.ps1`)
3. **ai-landing** — Landing Febracis com IA + QR (worktree `festive-grothendieck`, Netlify)
4. **DRE_Eventos** — DRE Febracis (Flask/React), prod `dre-eventos-deivithi.zocomputer.io`
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
|| `DRE_Eventos/` | `origin/main` (deivithi/febracis-dre-eventos). Último commit 04266f4 "sync docs and skill from agent session". Working tree: skill `dre-eventos/SKILL.md` + scripts Python modificados. |
|| `declaw/` | **dois remotes** — `cloud` (deivithilopes-ai/declaw, canonical) + `origin` (deivithi/declaw, mirror). Último: 8fb344c "record Zo local smoke validation in STATUS". Deploy canônico: **Zo Computer** (não Electron desktop). |
| `webwright/` | `origin/main`, behind 4 |
| `cybersecurity-skills/` | `origin/main`, ahead 33 / behind 137 |

### Worktrees (14)
- **Com código:** `festive-grothendieck` (ai-landing), `determined-wu-3787c2` (workspace principal), `dre-eventos-fix` (DRE)
- **Shells vazios (11):** charming-lichterman, cranky-mahavira, gifted-boyd, heuristic-ritchie, inspiring-dijkstra, modest-dirac, naughty-wilson, peaceful-jepsen, quirky-easley, quirky-liskov, upbeat-mirzakhani

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

## Configurações
- Shell: PowerShell
- Sync agendado: Task Scheduler `\Febracis-Cursor-SyncDaily` (quando configurado)
- Log sync: `%LOCALAPPDATA%\febracis-logs\cursor-sync.log`
- Cursor no Windows: instalação única System em `C:\Program Files\cursor`, atualizada por `scripts/Atualizar-Cursor-Seguro.ps1` via `winget` elevado; não usar instalação User/AppData nem editar arquivos internos do Cursor para controlar update

## Última atualização
- **22/06/2026** — Auditoria completa dos docs pessoais corrigiu: FIO-IA migrado para Hermes cron (4×/dia, ADR-005), Hermes adicionado ao stack, declaw deploy canônico = Zo Computer, Pulso Finance marcado como conceitual (skill-only), webwright PRs #5/#10 registrados, DRE watcher fix registrado, Hermes skills catalogadas, n8n movido para automation.

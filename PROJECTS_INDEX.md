# PROJECTS_INDEX — Inventário de Projetos

> Atualizado: 16/06/2026  
> Raiz: `C:\Users\deivithi.lopes\Documents\Cursor`

## Monorepo de configuração (raiz)

| Campo | Valor |
|-------|-------|
| Path | `C:\Users\deivithi.lopes\Documents\Cursor` |
| Git | `main`, **dual-remote** (ADR-006) |
| `origin` | `https://github.com/deivithi/cursor-agent-os.git` (conta ativa) |
| `cloud` | `https://github.com/deivithilopes-ai/cursor-agent-os.git` (mirror) |
| Propósito | Skills, rules, hooks, agents, scripts e memória compartilhada |
| ADR | [DECISIONS.md](DECISIONS.md) ADR-001 — raiz não rastreia repos aninhados; **ADR-006 — raiz publicada com dual-remote** |

## Repositórios Git independentes (ignorados pela raiz)

| Projeto | Path | Stack | Remote / status (22/06/2026) |
|---------|------|-------|------------------------------|
| **DRE_Eventos** | `DRE_Eventos/` | Flask + React, DRE Febracis | `origin/main` (deivithi/febracis-dre-eventos) — último: `04266f4 chore(dre): sync docs and skill`. Working tree: skill `dre-eventos/SKILL.md` + 7 scripts Python modificados (briefing_data, refresh_cache, upload_chunks_to_zo, etc.). |
| **declaw** | `declaw/` | Spec-first factory v2.1.1, **deploy Zo Computer** (não Electron desktop) | **2 remotes:** `cloud` (deivithilopes-ai/declaw, canonical) + `origin` (deivithi/declaw, mirror). Último: `8fb344c docs: record Zo local smoke validation in STATUS`. |
| **webwright** | `webwright/` | Python + Playwright, automação web | `origin/main` (microsoft/webwright). PRs #5 + #10 merged: image_qa/self_reflection via model configurado, dedupe inner-tool routing, persistent local browser. |
| **cybersecurity-skills** | `cybersecurity-skills/` | Fork mukul975, ~736 skills `cyber-*` | `origin/main` (mukul975/Anthropic-Cybersecurity-Skills) — **behind 137** no upstream, working tree com D locais. |

### Deploy / prod (referência)

- **DRE_Eventos:** `dre-eventos-deivithi.zocomputer.io`
- **ai-landing:** Netlify (worktree `festive-grothendieck`)

## Worktrees (`worktrees/`)

14 pastas com `.git` independente (ADR-003). Paths antigos `C:/Users/PC/...` foram desacoplados.

### Com código substantivo

| Worktree | Conteúdo | Indicadores |
|----------|----------|-------------|
| `festive-grothendieck` | **ai-landing** — landing Febracis + IA + QR | `package.json`, Vite/React |
| `determined-wu-3787c2` | Workspace principal (planos, AGENTS.md, ouroboros) | 1 arquivo + 3 dirs no topo |
| `dre-eventos-fix` | Cópia/worktree DRE Eventos | `requirements.txt`, 23 arquivos no topo |

### Shells vazios (só metadados `.cursor`/`.claude`)

`charming-lichterman`, `cranky-mahavira`, `gifted-boyd`, `heuristic-ritchie`, `inspiring-dijkstra`, `modest-dirac`, `naughty-wilson`, `peaceful-jepsen`, `quirky-easley`, `quirky-liskov`, `upbeat-mirzakhani`

**Ação futura sugerida:** arquivar ou remover shells após confirmar que não há código único.

## Projetos externos (fora desta pasta)

Citados em memória / GitHub — não versionados na raiz:

| Nome | Notas |
|------|-------|
| **Aria** | Agente IA PMEs, Vercel |
| **FIO-IA** | Threads X, Task Scheduler |
| **febracis-dre** | Repo GitHub relacionado a DRE |
| **Pulso Finance** | App financeiro (`pulsofinance` no GitHub) |

## Outras coleções na raiz (não são “apps”)

| Pasta | Função |
|-------|--------|
| `skills/` | ~104 skills custom Febracis (+ `_templates`) |
| `scientific-skills/` | 22 skills científicas |
| `cybersecurity-skills/` | 736 skills cyber |
| `commands/` | 47 slash commands |
| `rules/` | 23 rules |
| `agents/` | Agentes + NEXUS |
| `personas/`, `profiles/`, `hooks/`, `docs/`, `data/`, `scripts/` | Suporte ao ecossistema |

## Verificação rápida (início de sessão)

```powershell
git -C "C:\Users\deivithi.lopes\Documents\Cursor" status -sb
foreach ($r in 'DRE_Eventos','declaw','webwright','cybersecurity-skills') {
  git -C "C:\Users\deivithi.lopes\Documents\Cursor\$r" status -sb
}
```

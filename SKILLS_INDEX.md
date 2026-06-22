# SKILLS_INDEX — Inventário de Skills

> Atualizado: 16/06/2026  
> Entry point de memória: [CONTEXT.md](CONTEXT.md)

## Resumo por origem

| Origem | Path | Quantidade | Prefixo / notas |
|--------|------|------------|-----------------|
| Custom Febracis | `skills/` | **104** (+ `_templates`) | Sem prefixo; foco PO, n8n, spec, Supabase, Febracis |
| Cybersecurity | `cybersecurity-skills/skills/` | **736** | `cyber-*` no nome da pasta |
| Scientific | `scientific-skills/skills/` | **22** | `sci-*` no Cursor global |
| WebWright | `webwright/skills/` | **1** | `webwright` |
| DRE (duplicada) | `DRE_Eventos/skills/`, `worktrees/dre-eventos-fix/skills/` | **1** | `dre-eventos` |
| Cursor oficial | `~/.cursor/skills-cursor/` | **18** | Mantidas pelo Cursor |
| Sync ativo | `~/.cursor/skills/` | **29** | Subconjunto essencial via `scripts/migrate-from-documents.ps1` |

## 29 skills essenciais (sync diário → `~/.cursor/skills/`)

Definidas em `scripts/migrate-from-documents.ps1`:

`automations`, `caverna`, `caverna-commit`, `caverna-compress`, `caverna-help`, `caverna-review`, `code-review`, `commission-audit`, `frontend-design`, `lead-audit`, `n8n-code-javascript`, `n8n-code-python`, `n8n-expression-syntax`, `n8n-mcp-tools-expert`, `n8n-node-configuration`, `n8n-validation-expert`, `n8n-workflow-patterns`, `product-verification`, `security-audit`, `spec-driven-core`, `spec-planner`, `spec-review`, `spec-verify`, `supabase-docs`, `supabase-factory`, `supabase-postgres`, `test-driven-development`, `web-research`, `webapp-testing`

**Sync manual:**

```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Documents\Cursor\scripts\migrate-from-documents.ps1"
```

## Custom skills (`skills/`) — lista completa

`_templates`, `a2a-protocol`, `ads-live`, `ag-ui-protocol`, `agent-builder`, `agent-harness`, `agent-reach`, `agent-skill-patterns`, `alpha-loop`, `anatomy-of-agent-harness`, `api-forge`, `api-to-mcp`, `app-store-connect`, `artifact-factory`, `auto-pr-review`, `automations`, `autonomous-agent-loop`, `batch-processing`, `caverna`, `caverna-commit`, `caverna-compress`, `caverna-help`, `caverna-review`, `chrome-cdp`, `cicd`, `circuit-breaker`, `clean-code-rules`, `clean-room-engineering`, `cloudflare-mesh`, `code-review`, `codebase-graph`, `commission-audit`, `compliance-agent`, `content-deduplication`, `context-engineering`, `corrective-rag`, `data-charts`, `decision-council`, `deep-research-workspace`, `delegate-task`, `doc-extract`, `docx`, `error-alerting`, `frontend-design`, `gbrain`, `geo-seo`, `gepa-reflective`, `github-mentions`, `golang`, `graphify`, `guardrails`, `image-gen-free`, `insforge`, `knowledge-graph`, `last30`, `lead-audit`, `markdown-slides`, `mcp-builder`, `mcp-rl`, `memento-skills`, `mermaid-diagrams`, `minimax-pdf`, `minimax-xlsx`, `music-gen-free`, `mythos`, `n8n-code-javascript`, `n8n-code-python`, `n8n-expression-syntax`, `n8n-mcp-tools-expert`, `n8n-node-configuration`, `n8n-validation-expert`, `n8n-workflow-patterns`, `observability`, `pptx-generator`, `product-verification`, `pulso-finance`, `runbook`, `scaffolding`, `secure-agent-harness-patterns`, `security-audit`, `skill-architect`, `skill-discovery`, `spec-driven-core`, `spec-enrich`, `spec-epic`, `spec-evaluate`, `spec-phases`, `spec-planner`, `spec-review`, `spec-verify`, `spec-yolo`, `strix`, `supabase-docs`, `supabase-factory`, `supabase-postgres`, `test-driven-development`, `trace-capability`, `tts-free`, `ui-forge`, `universal-docs`, `vibe-deploy-guard`, `video-compose`, `web-artifacts-builder`, `web-research`, `webapp-testing`

### Agrupamento por domínio (custom)

| Domínio | Skills (exemplos) |
|---------|-------------------|
| Febracis / negócio | `lead-audit`, `commission-audit`, `pulso-finance`, `runbook` |
| Spec / Traycer | `spec-driven-core`, `spec-planner`, `spec-review`, `spec-verify`, `spec-epic`, `spec-phases`, `spec-yolo`, `spec-enrich`, `spec-evaluate` |
| n8n | `n8n-*` (7 skills) |
| Supabase | `supabase-docs`, `supabase-factory`, `supabase-postgres` |
| Caverna / tokens | `caverna`, `caverna-commit`, `caverna-compress`, `caverna-help`, `caverna-review` |
| Qualidade / segurança | `code-review`, `security-audit`, `product-verification`, `vibe-deploy-guard`, `strix`, `mythos` |
| Conteúdo / mídia | `artifact-factory`, `doc-extract`, `docx`, `minimax-pdf`, `markdown-slides`, `tts-free`, `video-compose`, `image-gen-free`, `music-gen-free` |
| Agentes / harness | `agent-builder`, `agent-harness`, `anatomy-of-agent-harness`, `autonomous-agent-loop`, `guardrails`, `trace-capability` |

## Scientific skills (22)

`alpha-vantage`, `citation-management`, `dask`, `exploratory-data-analysis`, `fred-economic-data`, `hypothesis-generation`, `literature-review`, `matplotlib`, `networkx`, `plotly`, `polars`, `pymc`, `pytorch-lightning`, `scientific-writing`, `scikit-learn`, `seaborn`, `shap`, `simpy`, `stable-baselines3`, `sympy`, `transformers`, `umap-learn`

## Cybersecurity skills (736)

Repositório separado: `cybersecurity-skills/`. Pastas usam prefixo `cyber-` no slug da skill.

**Categorias dominantes (por prefixo de pasta):**

- `analyzing-*`, `detecting-*`, `hunting-*` — forense, detecção, threat hunting  
- `implementing-*`, `configuring-*`, `deploying-*` — hardening e controles  
- `performing-*`, `conducting-*`, `executing-*` — pentest e IR  
- `exploiting-*`, `testing-*` — ofensivo autorizado  
- `building-*` — playbooks, pipelines, SOC  

Skills custom adicionadas localmente (não no upstream): `designing-secure-api-architecture`, `hardening-salesforce-platform-security`, `implementing-lgpd-data-protection-compliance`, `implementing-sbom-management-cyclonedx`, `implementing-secure-coding-practices-owasp`

**Manutenção:** `git pull` recomendado (behind 137 no remoto).

## Paths no `config.json`

```json
"skill_ecosystems": {
  "custom": "skills/",
  "cybersecurity": "cybersecurity-skills/skills/",
  "scientific": "scientific-skills/skills/",
  "commands": "commands/"
}
```

Paths relativos à raiz `Documents\Cursor` (corrigido de legado `.claude/`).

## Hermes skills (ecossistema ativo desde jun/2026)

Skills **não** versionadas em `Documents\Cursor` — vivem em `%LOCALAPPDATA%\hermes\skills\`.
Carregadas dinamicamente pelos agentes Hermes (perfil `default` ativo).

| Categoria | Algumas skills |
|-----------|----------------|
| **ai-x-digest** | Digest semanal de posts de líderes de labs IA no X |
| **autonomous-ai-agents** | claude-code, codex, hermes-agent, kanban-codex-lane, opencode |
| **computer-use** | Dirigir desktop do usuário em background |
| **creative** | architecture-diagram, ascii-art, baoyu-*, comfyui, excalidraw, **humanizer**, manim-video, pixel-art, songwriting-and-ai-music |
| **cronjob-authoring** | Padrões para jobs Hermes confiáveis |
| **data-science** | jupyter-live-kernel |
| **devops** | webhook-subscriptions |
| **dogfood** | QA exploratório de web apps |
| **email** | himalaya (CLI IMAP/SMTP) |
| **gaming** | pokemon-player (headless emulator) |
| **github** | github-auth, github-code-review, github-issues, github-pr-workflow, github-repo-management |
| **mcp** | native-mcp (cliente MCP built-in) |
| **media** | gif-search, heartmula, songsee, spotify, youtube-content |
| **mlops** | huggingface-hub, llama-cpp, segment-anything-model, dspy, weights-and-biases |
| **note-taking** | obsidian |
| **productivity** | airtable, google-workspace, linear, notion, ocr-and-documents, powerpoint |
| **red-teaming** | godmode (jailbreak Parseltongue) |
| **research** | arxiv, blogwatcher, polymarket |
| **smart-home** | openhue |
| **software-development** | debugging-hermes-tui-commands, hermes-agent-skill-authoring, plan, requesting-code-review, simplify-code, spike, subagent-driven-development, systematic-debugging, test-driven-development, writing-plans |
| **yuanbao** | Grupos Yuanbao com @mention |

> ⚠️ **FIO-IA** usa `creative/humanizer` (v2.8.0, instalada em 19/06/2026) —
> ver ADR-005 em DECISIONS.md.

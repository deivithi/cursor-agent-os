# SKILLS_INDEX — Inventário de Skills

> Atualizado: 30/09/2026 — contagens recontadas no disco
> Entry point de memória: [CONTEXT.md](CONTEXT.md) · Estado vivo: [MEMORY_STATE.md](MEMORY_STATE.md)

> **Contagens voláteis:** os números abaixo foram verificados em 30/09/2026. Para o valor de hoje,
> rode `pwsh -File "$env:USERPROFILE\.claude\scripts\memory-doctor.ps1"` — não edite à mão.

## Resumo por origem

| Origem | Path | Quantidade | Prefixo / notas |
|--------|------|------------|-----------------|
| Custom Febracis | `skills/` | **110** com `SKILL.md` (112 diretórios: 1 é `_templates`, 1 é plugin bundle) | Sem prefixo; foco PO, Salesforce, Gauntlet, n8n, spec, Supabase, Febracis |
| Cybersecurity | `cybersecurity-skills/skills/` | **736** com `SKILL.md` (739 diretórios) | `cyber-*` no nome da pasta |
| Scientific | `scientific-skills/skills/` | **22** | `sci-*` no Cursor global |
| WebWright | `webwright/skills/` | **1** | `webwright` |
| Commands | `commands/` | **47** arquivos `.md` | Slash commands; nenhum `SKILL.md` |
| DRE (no projeto) | `DRE_Eventos/.cursor/skills/dre-eventos/` | **1** | Vive dentro do repo do projeto, não em `skills/`. As entradas `DRE_Eventos/skills/` e `worktrees/dre-eventos-fix/skills/` **não existem** — removidas deste índice em 30/09/2026 |
| Cursor oficial | `~/.cursor/skills-cursor/` | **26** | Mantidas pelo Cursor |
| Sync ativo | `~/.cursor/skills/` | **63** no disco / **30** essenciais no script | Ver seção de sync — número inflado e tarefa desligada |

**Plugin bundle, não skill:** `skills/pptx-generator` contém `.claude-plugin/`, `plugin.json`, `marketplace.json`, `agents/` e **5 skills aninhadas** em `skills/`. Não precisa de `SKILL.md` próprio. A classificação anterior ("skill incompleta") estava errada.

## Sync Cursor — 30 essenciais, tarefa DESLIGADA

`scripts/migrate-from-documents.ps1` define **30** skills essenciais (não 29 — a lista anterior omitia `openwiki-personal-brain`):

`automations`, `caverna`, `caverna-commit`, `caverna-compress`, `caverna-help`, `caverna-review`, `code-review`, `commission-audit`, `frontend-design`, `lead-audit`, `n8n-code-javascript`, `n8n-code-python`, `n8n-expression-syntax`, `n8n-mcp-tools-expert`, `n8n-node-configuration`, `n8n-validation-expert`, `n8n-workflow-patterns`, `openwiki-personal-brain`, `product-verification`, `security-audit`, `spec-driven-core`, `spec-planner`, `spec-review`, `spec-verify`, `supabase-docs`, `supabase-factory`, `supabase-postgres`, `test-driven-development`, `web-research`, `webapp-testing`

**Estado verificado em 30/09/2026 — o sync NÃO roda:**

| Item | Valor |
|---|---|
| Tarefa `Febracis-Cursor-SyncDaily` | **Disabled** |
| Última execução | 16/06/2026 |
| Diretórios em `~/.cursor/skills` | 63 (30 essenciais + 33 resíduos que o script removeria) |
| Quarentena `~/.cursor/disabled-by-codex/skills-nonessential` | vazia (0 diretórios) — o trecho de limpeza nunca executou |

Os 30 essenciais estão presentes porque já estavam lá, não por sincronização recente. As versões anteriores deste índice descreviam "sync diário": isso não corresponde ao disco.

**Reativar e rodar manualmente:**

```powershell
Enable-ScheduledTask -TaskName "Febracis-Cursor-SyncDaily"
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Documents\Cursor\scripts\migrate-from-documents.ps1"
```

## Custom skills (`skills/`) — lista completa

`_templates`, `a2a-protocol`, `ads-live`, `ag-ui-protocol`, `agent-builder`, `agent-harness`, `agent-reach`, `agent-skill-patterns`, `ai-forensic-analyzer`, `alpha-loop`, `anatomy-of-agent-harness`, `api-forge`, `api-to-mcp`, `app-store-connect`, `artifact-factory`, `auto-pr-review`, `automations`, `autonomous-agent-loop`, `batch-processing`, `caverna`, `caverna-commit`, `caverna-compress`, `caverna-help`, `caverna-review`, `chrome-cdp`, `cicd`, `circuit-breaker`, `clean-code-rules`, `clean-room-engineering`, `cloudflare-mesh`, `code-review`, `codebase-graph`, `commission-audit`, `compliance-agent`, `composio-tool-orchestrator`, `content-deduplication`, `context-engineering`, `corrective-rag`, `data-charts`, `decision-council`, `deep-research-workspace`, `delegate-task`, `doc-extract`, `docx`, `dre-zo-integrity-guard`, `error-alerting`, `frontend-design`, `gauntlet-self-healer`, `gbrain`, `geo-seo`, `gepa-reflective`, `github-mentions`, `golang`, `graphify`, `guardrails`, `image-gen-free`, `insforge`, `knowledge-graph`, `last30`, `lead-audit`, `markdown-slides`, `mcp-builder`, `mcp-rl`, `memento-skills`, `mermaid-diagrams`, `minimax-pdf`, `minimax-xlsx`, `music-gen-free`, `mythos`, `n8n-code-javascript`, `n8n-code-python`, `n8n-expression-syntax`, `n8n-mcp-tools-expert`, `n8n-node-configuration`, `n8n-validation-expert`, `n8n-workflow-patterns`, `observability`, `openwiki-fio-synthesizer`, `openwiki-personal-brain`, `pptx-generator`, `product-verification`, `pulso-finance`, `runbook`, `salesforce-bdd-spec-architect`, `scaffolding`, `secure-agent-harness-patterns`, `security-audit`, `skill-architect`, `skill-discovery`, `spec-driven-core`, `spec-enrich`, `spec-epic`, `spec-evaluate`, `spec-phases`, `spec-planner`, `spec-review`, `spec-verify`, `spec-yolo`, `strix`, `supabase-docs`, `supabase-factory`, `supabase-postgres`, `test-driven-development`, `trace-capability`, `tts-free`, `ui-forge`, `universal-docs`, `vibe-deploy-guard`, `video-compose`, `web-artifacts-builder`, `web-research`, `webapp-testing`

### Agrupamento por domínio (custom)

| Domínio | Skills (exemplos) |
|---|---|
| Febracis / Salesforce / Negócio | `salesforce-bdd-spec-architect`, `lead-audit`, `commission-audit`, `dre-zo-integrity-guard`, `pulso-finance`, `runbook` |
| Gauntlet / Qualidade / Segurança | `gauntlet-self-healer`, `code-review`, `security-audit`, `product-verification`, `vibe-deploy-guard`, `strix`, `mythos` |
| Spec / Traycer | `spec-driven-core`, `spec-planner`, `spec-review`, `spec-verify`, `spec-epic`, `spec-phases`, `spec-yolo`, `spec-enrich`, `spec-evaluate` |
| Integrações & Conectores | `composio-tool-orchestrator`, `openwiki-fio-synthesizer`, `openwiki-personal-brain`, `n8n-*` (7 skills), `api-forge` |
| Supabase | `supabase-docs`, `supabase-factory`, `supabase-postgres` |
| Caverna / tokens | `caverna`, `caverna-commit`, `caverna-compress`, `caverna-help`, `caverna-review` |
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

**Manutenção:** o fork está **ahead 33 / behind 223** em relação a `origin/main` (medido em 30/09/2026 — a nota anterior dizia "behind 137", que vinha de um fetch antigo). Um `git pull` traria 223 commits do upstream e colidiria com as 33 alterações locais: decidir a estratégia antes de puxar.

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

> `ai-forensic-analyzer` estava no disco e no Git desde 22/06/2026 mas faltava nesta lista — incluída em 30/09/2026. Todas as skills declaradas aqui existem no disco.

# Spec — Spec-Driven Development (Traycer Parity)

Router inteligente para desenvolvimento spec-driven: **Plan → Execute → Verify**.

**Uso:** `/spec [mode] [query]`

## Núcleo do workspace (Traycer+)

Antes de rotear para uma `spec-*` isolada, o agente deve alinhar-se ao **roteamento e gatilhos** em `.claude/skills/spec-driven-core/SKILL.md` (e à secção correspondente em `AGENTS.md`). O comando `/spec` é opcional: o mesmo comportamento pode ativar-se **automaticamente** quando o pedido for épico, multi-fase, PRD/tickets, verificação contra plano, ou YOLO.

## Roteamento

Analise `$ARGUMENTS` e roteie para a skill correta:

### Modo explícito (primeiro argumento é o modo)

| Argumento | Skill | Quando |
|-----------|-------|--------|
| `plan [query]` | `spec-planner` | Gerar plano file-level detalhado |
| `phases [query]` | `spec-phases` | Decompor em fases verificáveis |
| `verify` | `spec-verify` | Verificar implementação contra spec |
| `epic [query]` | `spec-epic` | Pipeline completo intent → tickets |
| `enrich` | `spec-enrich` | Enriquecer spec com edge cases e gaps |
| `review [query]` | `spec-review` | Code review profundo categorizado |
| `yolo [query]` | `spec-yolo` | Automação total plan → code → verify |

### Auto-detect (sem modo explícito)

Se nenhum modo foi especificado, inferir pela query:

| Pattern na query | Skill |
|-----------------|-------|
| "planejar", "plan", "como implementar", "o que modificar" | `spec-planner` |
| "fases", "phases", "decompor", "dividir em partes" | `spec-phases` |
| "verificar", "verify", "checar contra", "conferir implementação" | `spec-verify` |
| "epic", "feature completa", "projeto novo", "PRD", "do zero" | `spec-epic` |
| "enriquecer", "enrich", "edge cases", "contradições", "gaps" | `spec-enrich` |
| "review", "revisar", "qualidade do código", "bugs", "security" | `spec-review` |
| "yolo", "automatizar", "executar tudo", "rodar sem parar" | `spec-yolo` |

**Se ambíguo:** Perguntar ao usuário qual modo usar, mostrando a tabela acima.

## Execução

1. Ler o `SKILL.md` da skill roteada: `.claude/skills/[skill-name]/SKILL.md`
2. Seguir o workflow descrito na skill **exatamente**
3. Entregar o resultado no formato especificado pela skill

## Visão Geral das Skills

```
📋 spec-planner  → Plano detalhado com Mermaid + acceptance criteria
🔄 spec-phases   → Decomposição em fases com verificação entre cada
🏗️ spec-epic     → Discovery → PRD → Tech Decisions → Tickets → Execução
🔬 spec-enrich   → Enriquecer spec: contradições + gaps + edge cases
🔍 spec-review   → Review: Bug/Performance/Security/Clarity × Severity
✅ spec-verify   → Compara implementation vs spec, scorecard, auto-fix
⚡ spec-yolo     → Automação total: Plan → Code → Verify → Fix → Next
```

## Composição

As skills se compõem:
- `spec-epic` usa `spec-phases` que usa `spec-planner` + `spec-verify`
- `spec-yolo` automatiza `spec-phases` ou `spec-epic` end-to-end
- `spec-review` é independente (review sem spec prévia)
- `spec-verify` precisa de spec para comparar (output de planner/phases/epic)

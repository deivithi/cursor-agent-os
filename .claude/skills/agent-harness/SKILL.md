---
name: agent-harness
description: >
  Durabilidade de sessão: progress file + git checkpoints para sessões longas (>10 min).
  Não cobre sozinha o "harness" completo do ecossistema (guardrails, compactação, verify);
  ver skill anatomy-of-agent-harness (mapa dos 12 componentes), guardrails,
  .claude/docs/compact-protocol.md, spec-verify e .cursor/README.md (secção Agent harness).
  Use para loops autônomos, batch e recovery pós-crash.
domain: infrastructure
subdomain: agent-reliability
version: 1.0.0
author: deivithi
tags:
  - agent-harness
  - progress-tracking
  - git-checkpoints
  - crash-recovery
  - long-sessions
  - reliability
---

# 🔧 Agent Harness — Progress File + Git Checkpoints

> **"Um agente que roda 45 minutos e crasha no minuto 44 sem checkpoint é pior que um que nunca rodou."**

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelo Workflow abaixo.
- `references/checkpoint-protocol.md` — Detalhes do protocolo de checkpoint.
- `gotchas.md` — Problemas conhecidos com git checkpoints e recovery.

## 🔗 Related Skills
- **`anatomy-of-agent-harness`** — Índice canónico da anatomia de produção (12 componentes, 7 decisões); ler antes de confundir esta skill com “o harness inteiro”
- `autonomous-agent-loop` — Loop principal que usa este harness para persistência
- `gepa-reflective` — Diagnóstico pós-crash usa progress file para contexto
- `guardrails` — Input/output guards complementam o harness de confiabilidade
- `spec-verify` / `product-verification` — Loops de verificação após mudanças de código

## Harness completo vs esta skill

No debate público (ex. *Anatomy of an Agent Harness*), **harness** = orquestração + estado + ferramentas + gestão de contexto + segurança + verificação. **Esta skill** é a fatia **persistência / checkpoints**; o mapa mental completo está em **`anatomy-of-agent-harness`**. O resto continua espalhado por skills especializadas:

| Peça | Onde ir |
|------|---------|
| Anatomia completa (12 + 7 decisões) | `@.claude/skills/anatomy-of-agent-harness/SKILL.md` + `references/article-synthesis.md` |
| Compactação de histórico e foco de contexto | `@.claude/docs/compact-protocol.md` |
| Guardrails em runtime | skill `guardrails` (`@.claude/skills/guardrails/SKILL.md`) |
| Verificar implementação contra plano | skill `spec-verify`; testes/E2E em `product-verification` |
| Mapa único no projeto Cursor | `@.cursor/README.md` (secção **Agent harness — mapa no repositório**) |

---

## 🎯 O Problema

Sessions longas de agentes IA falham por:

| Causa | Frequência | Impacto sem Harness |
|-------|-----------|---------------------|
| Timeout de contexto | ~15% sessions >30min | Perda total de progresso |
| Crash do processo | ~5% sessions | Sem saber onde parou |
| Rate limit de API | ~10% sessions | Retry sem estado = retrabalho |
| Erro não tratado | ~8% sessions | Loop infinito ou halt silencioso |

---

## 🔄 Workflow — 4 Mecanismos

```
SESSION START → [Init Progress File] → TASK LOOP → [Checkpoint cada milestone]
                                                          │
                                                   [Git stash/commit]
                                                          │
                                               CRASH? → [Recovery: ler progress file]
                                                          │
                                               DONE  → [Final checkpoint + cleanup]
```

---

## 📋 1. Progress File

### 1.1 Estrutura

O progress file é um JSON que persiste o estado da sessão:

```json
{
  "session_id": "harness_20260323_205500",
  "started_at": "2026-03-23T20:55:00-03:00",
  "updated_at": "2026-03-23T21:15:00-03:00",
  "status": "running",
  "current_phase": "FASE 5.2",
  "current_task": "Criando skill guardrails",
  "tasks_total": 10,
  "tasks_completed": 3,
  "tasks_remaining": 7,
  "checkpoints": [
    {
      "id": "cp_001",
      "timestamp": "2026-03-23T21:00:00-03:00",
      "phase": "FASE 5.1",
      "description": "Promptfoo config + script criados",
      "git_ref": "harness/cp_001",
      "files_changed": ["ouroboros/evals/promptfoo-config.yaml", "ouroboros/scripts/run-promptfoo.sh"]
    }
  ],
  "errors": [],
  "metrics": {
    "files_created": 5,
    "files_modified": 2,
    "api_calls": 12,
    "elapsed_minutes": 20
  }
}
```

### 1.2 Localização

```
.claude/data/sessions/harness_{session_id}.json
```

### 1.3 Operações

```bash
# Criar progress file no início da sessão
init_progress() {
  local SESSION_ID="harness_$(date +%Y%m%d_%H%M%S)"
  local PROGRESS_FILE=".claude/data/sessions/${SESSION_ID}.json"

  mkdir -p .claude/data/sessions

  cat > "$PROGRESS_FILE" << EOF
{
  "session_id": "$SESSION_ID",
  "started_at": "$(date -Iseconds)",
  "updated_at": "$(date -Iseconds)",
  "status": "running",
  "current_phase": "",
  "current_task": "",
  "tasks_total": 0,
  "tasks_completed": 0,
  "tasks_remaining": 0,
  "checkpoints": [],
  "errors": [],
  "metrics": {"files_created": 0, "files_modified": 0, "api_calls": 0, "elapsed_minutes": 0}
}
EOF

  echo "$PROGRESS_FILE"
}

# Atualizar progresso
update_progress() {
  local PROGRESS_FILE="$1"
  local PHASE="$2"
  local TASK="$3"
  local COMPLETED="$4"
  local REMAINING="$5"

  # Usa python para JSON manipulation segura
  python3 -c "
import json, sys
from datetime import datetime
with open('$PROGRESS_FILE', 'r') as f:
    data = json.load(f)
data['updated_at'] = datetime.now().astimezone().isoformat()
data['current_phase'] = '$PHASE'
data['current_task'] = '$TASK'
data['tasks_completed'] = $COMPLETED
data['tasks_remaining'] = $REMAINING
with open('$PROGRESS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
}
```

---

## 💾 2. Git Checkpoints

### 2.1 Quando criar checkpoint

| Trigger | Ação |
|---------|------|
| **Milestone completo** (fase/tarefa) | Commit + tag |
| **Antes de operação arriscada** | Stash do estado atual |
| **A cada N minutos** (default: 10) | Commit automático se houver mudanças |
| **Antes de crash previsível** (rate limit, timeout) | Commit de emergência |

### 2.2 Protocolo de checkpoint

```bash
# Criar checkpoint git
create_checkpoint() {
  local CHECKPOINT_ID="$1"
  local DESCRIPTION="$2"
  local PROGRESS_FILE="$3"

  # Só faz checkpoint se houver mudanças
  if git diff --quiet && git diff --cached --quiet; then
    echo "No changes to checkpoint"
    return 0
  fi

  # Stage apenas arquivos relevantes (nunca .env, credentials)
  git add -A -- \
    '.claude/skills/' \
    'ouroboros/' \
    '.claude/data/' \
    --ignore-errors 2>/dev/null

  # Commit com prefixo harness/
  git commit -m "harness/${CHECKPOINT_ID}: ${DESCRIPTION}" \
    --no-gpg-sign 2>/dev/null || true

  # Registrar no progress file
  python3 -c "
import json
from datetime import datetime
with open('$PROGRESS_FILE', 'r') as f:
    data = json.load(f)
data['checkpoints'].append({
    'id': '$CHECKPOINT_ID',
    'timestamp': datetime.now().astimezone().isoformat(),
    'description': '$DESCRIPTION',
    'git_ref': 'HEAD'
})
with open('$PROGRESS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
}
```

### 2.3 Recovery de crash

```bash
# Recuperar última sessão
recover_session() {
  # Encontrar último progress file
  local LATEST=$(ls -t .claude/data/sessions/harness_*.json 2>/dev/null | head -1)

  if [ -z "$LATEST" ]; then
    echo '{"status": "no_session_found"}'
    return 1
  fi

  # Ler estado
  local STATUS=$(python3 -c "import json; d=json.load(open('$LATEST')); print(d['status'])")

  if [ "$STATUS" = "running" ]; then
    echo "⚠️  Sessão anterior não foi finalizada corretamente."
    echo "  Arquivo: $LATEST"
    python3 -c "
import json
d = json.load(open('$LATEST'))
print(f\"  Fase: {d['current_phase']}\")
print(f\"  Tarefa: {d['current_task']}\")
print(f\"  Completas: {d['tasks_completed']}/{d['tasks_total']}\")
print(f\"  Checkpoints: {len(d['checkpoints'])}\")
if d['checkpoints']:
    last = d['checkpoints'][-1]
    print(f\"  Último checkpoint: {last['id']} — {last['description']}\")
"
    return 0
  fi

  echo "Última sessão finalizada normalmente."
  return 0
}
```

---

## 📊 3. Heartbeat Monitor

```bash
# Heartbeat a cada 5 minutos para detectar halts
heartbeat() {
  local PROGRESS_FILE="$1"
  local INTERVAL_SEC="${2:-300}"  # 5 min default

  while true; do
    sleep "$INTERVAL_SEC"

    if [ ! -f "$PROGRESS_FILE" ]; then
      break
    fi

    local STATUS=$(python3 -c "import json; print(json.load(open('$PROGRESS_FILE'))['status'])")

    if [ "$STATUS" != "running" ]; then
      break
    fi

    # Atualizar timestamp
    python3 -c "
import json
from datetime import datetime
with open('$PROGRESS_FILE', 'r') as f:
    d = json.load(f)
d['updated_at'] = datetime.now().astimezone().isoformat()
mins = (datetime.now() - datetime.fromisoformat(d['started_at'])).total_seconds() / 60
d['metrics']['elapsed_minutes'] = round(mins)
with open('$PROGRESS_FILE', 'w') as f:
    json.dump(d, f, indent=2)
"
  done
}
```

---

## 🏁 4. Session Lifecycle

```
1. SESSION_START
   ├─ init_progress()
   ├─ recover_session() — checar crash anterior
   └─ heartbeat() & — background

2. TASK_LOOP
   ├─ update_progress(phase, task, completed, remaining)
   ├─ [executar tarefa]
   ├─ create_checkpoint() — a cada milestone
   └─ [repetir]

3. SESSION_END
   ├─ Marcar status = "completed" | "failed"
   ├─ create_checkpoint("final", "Session complete")
   └─ Matar heartbeat
```

---

## ✅ Quality Checklist

Antes de considerar o harness operacional, verificar:

- [ ] Progress file criado no início da sessão com todos os campos
- [ ] Checkpoints criados a cada milestone (não a cada tarefa trivial)
- [ ] Recovery funciona: crashar sessão e verificar que `recover_session()` retorna estado correto
- [ ] Heartbeat roda em background e atualiza `updated_at` a cada 5 min
- [ ] Sessões stale (>2h sem update) são marcadas automaticamente como `failed`
- [ ] Git commits de checkpoint usam branch separada ou prefixo `harness/`
- [ ] Nenhum arquivo sensível (.env, credentials) incluído nos checkpoints
- [ ] PID do heartbeat registrado para cleanup no exit

---

## ⚠️ Gotchas

1. **Git commits em excess** — Checkpoints frequentes demais poluem o histórico. Usar `--squash` no merge final ou branch separada `harness/session-*`.
2. **Progress file corrupto** — Sempre usar python/jq para manipular JSON, nunca sed/echo. JSON mal-formado = perda de estado.
3. **Heartbeat órfão** — Se o processo principal morre, o heartbeat continua. Usar PID file para cleanup.
4. **Race condition em progress file** — Se múltiplos subagentes escrevem simultaneamente, usar lockfile.
5. **Checkpoints incluem arquivos sensíveis** — Sempre excluir `.env`, `credentials.*`, `*.key` do `git add`.

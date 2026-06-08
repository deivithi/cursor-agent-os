# ⚠️ Gotchas — Agent Harness

## 1. Git commit pollution com checkpoints frequentes

**Sintoma:** Histórico git com 50+ commits `harness/cp_XXX` em uma sessão.
**Causa:** Checkpoint a cada tarefa pequena, sem threshold de mudança.
**Solução:** Só criar checkpoint se `git diff --stat | wc -l` > 3 (mais de 3 arquivos mudaram).
**Prevenção:** Usar branch separada `harness/session-*` e squash no merge final.

## 2. Progress file corrompido por kill -9

**Sintoma:** JSON inválido no progress file após crash forçado.
**Causa:** Python foi morto no meio de `json.dump()`.
**Solução:** Escrever em arquivo temporário, depois `mv` atômico para o destino final.
**Prevenção:** `write_atomic()` — sempre escrever em `.tmp` e renomear.

## 3. Heartbeat órfão consume CPU

**Sintoma:** Processo bash do heartbeat roda indefinidamente após sessão terminar.
**Causa:** Background process `heartbeat() &` não tem PID tracking.
**Solução:** Salvar PID em `$PROGRESS_FILE.pid`, matar no cleanup.
**Prevenção:** Usar trap `EXIT` no script principal para cleanup automático.

## 4. Race condition com múltiplos subagentes

**Sintoma:** Progress file tem dados inconsistentes (tasks_completed > tasks_total).
**Causa:** 2+ subagentes escrevem simultaneamente sem lock.
**Solução:** Usar `flock` (Linux) ou lockfile para serializar escritas.
**Prevenção:** Cada subagente atualiza seu próprio progresso; consolidação é responsabilidade do harness principal.

## 5. Recovery tenta continuar sessão expirada

**Sintoma:** `recover_session()` retorna sessão de 3 dias atrás com status "running".
**Causa:** Sessão crashou sem marcar `status: failed` e ninguém limpou.
**Solução:** Adicionar check de `updated_at` — se > 2 horas sem update, marcar como `stale` automaticamente.
**Prevenção:** Heartbeat com TTL — se `updated_at` > TTL, marcar como `failed`.

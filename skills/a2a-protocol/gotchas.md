# ⚠️ Gotchas — A2A Protocol

## 1. Webhook timeout mata execução longa

**Sintoma:** n8n retorna 504 para `execute_task` que demora >30s.
**Causa:** Webhook Trigger tem timeout de 30s e a tarefa delegada demora mais.
**Solução:** Retornar ACK imediato com `task_id`, rodar tarefa em sub-workflow, entregar resultado via file drop ou callback.
**Prevenção:** Nunca executar tarefa longa inline no webhook handler — sempre delegar.

## 2. Mensagem duplicada executa tarefa duas vezes

**Sintoma:** Workflow roda 2x para o mesmo `message_id` após retry do sender.
**Causa:** Receptor não deduplicou por `message_id`.
**Solução:** Manter set de `message_id` processados nos últimos 60 minutos (in-memory ou datastore).
**Prevenção:** Toda tarefa A2A deve ser idempotente ou deduplicada na entrada.

## 3. Timezone mismatch entre sender e receiver

**Sintoma:** Timestamps no log não batem — sender mostra BRT, receiver mostra UTC.
**Causa:** Code node no n8n usa `new Date().toISOString()` que retorna UTC.
**Solução:** Usar `DateTime.now().setZone('America/Sao_Paulo').toISO()` (Luxon, disponível no n8n).
**Prevenção:** Regra: todo timestamp no envelope A2A DEVE ter offset explícito (`-03:00`).

## 4. Payload grande rejeitado silenciosamente

**Sintoma:** Mensagem enviada sem erro, mas n8n nunca recebe.
**Causa:** Body >5MB é descartado pelo n8n sem retornar erro.
**Solução:** Verificar `Content-Length` antes de enviar. Acima do limite, salvar payload em arquivo e enviar referência.
**Prevenção:** Enforçar `max_payload_bytes` no sender antes do POST.

## 5. File drop não detectado pelo Claude Code

**Sintoma:** n8n salva resultado em `.claude/data/a2a-inbox/`, mas Claude Code não lê.
**Causa:** Claude Code não faz polling automático do inbox — depende de sessão ativa.
**Solução:** Usar Telegram como canal de notificação backup + file drop. Claude Code lê inbox no início de cada sessão.
**Prevenção:** Documentar que file drop é assíncrono — resultados só são processados na próxima sessão ou via `/resume`.

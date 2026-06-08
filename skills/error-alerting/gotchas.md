# ⚠️ Gotchas — Error Alerting

---

## 1. Error Trigger vs Error Workflow — confusão de escopo

- **Sintoma:** Erros em um workflow não disparam alertas, mesmo com Error Trigger configurado
- **Causa raiz:** O **Error Trigger** é um node que fica DENTRO do Error Workflow (o workflow receptor). Já o **Error Workflow** é a configuração no workflow PRINCIPAL que aponta para qual workflow deve receber os erros. São dois conceitos distintos que trabalham juntos:
  - Workflow Principal → `settings.errorWorkflow: "ID_DO_ERROR_HANDLER"` (aponta para o receptor)
  - Error Handler → contém o node `Error Trigger` (recebe os erros)
- **Solução:** Verificar os dois lados: (1) o workflow principal tem `errorWorkflow` apontando para o ID correto? (2) o workflow receptor tem um node `Error Trigger` como primeiro node?
- **Prevenção:** Ao criar Error Workflow, sempre validar o circuito completo com um erro forçado
- **Descoberto em:** 2026-03-22

---

## 2. Error Workflow DEVE estar ATIVO para receber erros

- **Sintoma:** Error Workflow existe, está configurado corretamente, mas nunca é executado quando há erro
- **Causa raiz:** Workflows inativos (`active: false`) **não** respondem a triggers, incluindo Error Trigger. O n8n simplesmente ignora o trigger silenciosamente — sem log, sem aviso
- **Solução:** Ativar o Error Workflow: `n8n_update_partial_workflow(id, { active: true })`. Verificar com `n8n_get_workflow(id)` que `active === true`
- **Prevenção:** Incluir verificação de status no checklist de deploy. Adicionar um health check periódico que confirma que o Error Workflow está ativo (ex: cron semanal que consulta `n8n_list_workflows` e alerta se Error Handler estiver inativo)
- **Descoberto em:** 2026-03-22

---

## 3. continueRegularOutput passa dados vazios downstream — precisa de guard

- **Sintoma:** Workflow continua após erro, mas nodes seguintes falham com "Cannot read property of undefined" ou produzem resultados incorretos/vazios
- **Causa raiz:** Quando `onError: "continueRegularOutput"`, o node que falhou envia um item com dados vazios `{}` pela saída regular. Nodes downstream tentam acessar campos que não existem
- **Solução:** Adicionar um **IF node** (guard) logo após qualquer node com `continueRegularOutput`:
  ```
  IF: {{ $json.data !== undefined && $json.data !== null }}
    → TRUE: continua fluxo normal
    → FALSE: log "Node X falhou, dados ausentes" + pular ou usar fallback
  ```
- **Prevenção:** Regra: todo `continueRegularOutput` EXIGE um guard node imediatamente depois. Sem exceção. Documentar no workflow com sticky note
- **Descoberto em:** 2026-03-22

---

## 4. Telegram tem limite de 4096 caracteres por mensagem

- **Sintoma:** Mensagem de alerta não chega no Telegram, ou chega truncada/com erro da API
- **Causa raiz:** A API do Telegram rejeita mensagens acima de 4096 caracteres com erro `400 Bad Request: message is too long`. Stack traces e erros de API podem facilmente ultrapassar esse limite
- **Solução:** Truncar a mensagem de erro no Code node antes de enviar:
  ```javascript
  const errorMsg = (rawError || '').substring(0, 2000);
  // 2000 chars para o erro + ~500 chars de metadados = ~2500 total (margem segura)
  ```
- **Prevenção:** Sempre truncar no Format Message node. Para erros longos, incluir link para a execução no n8n onde o erro completo pode ser visualizado
- **Descoberto em:** 2026-03-22

---

## 5. Loop infinito quando Error Workflow aponta para si mesmo

- **Sintoma:** Instância n8n trava ou consome memória excessiva após um erro
- **Causa raiz:** Se o Error Workflow tem `settings.errorWorkflow` apontando para seu próprio ID, qualquer falha no envio do alerta (ex: Telegram fora do ar) gera um novo erro, que dispara o mesmo workflow, que falha novamente, em loop infinito
- **Solução:** O Error Workflow **NUNCA** deve ter `errorWorkflow` apontando para si mesmo. Opções:
  1. Não definir `errorWorkflow` no Error Handler (erros vão para o log do n8n)
  2. Apontar para um segundo Error Handler mínimo (só log em arquivo)
- **Prevenção:** Na criação do Error Workflow, explicitamente omitir ou apontar `errorWorkflow` para um handler secundário
- **Descoberto em:** 2026-03-22

---

## 6. MarkdownV2 do Telegram exige escape de caracteres especiais

- **Sintoma:** Mensagem de alerta falha com `400 Bad Request: can't parse entities` no Telegram
- **Causa raiz:** O parse mode `MarkdownV2` exige escape de caracteres como `. - ( ) ! > # + = |` com backslash. Mensagens de erro frequentemente contêm esses caracteres
- **Solução:** Escapar caracteres especiais antes de enviar:
  ```javascript
  function escapeMarkdownV2(text) {
    return text.replace(/([_*\[\]()~`>#+\-=|{}.!\\])/g, '\\$1');
  }
  ```
  Ou usar `parse_mode: "HTML"` em vez de MarkdownV2 (menos restritivo)
- **Prevenção:** Preferir `HTML` como parse mode para alertas de erro, pois mensagens de erro são imprevisíveis. Reservar MarkdownV2 para mensagens com formatação controlada
- **Descoberto em:** 2026-03-22

---

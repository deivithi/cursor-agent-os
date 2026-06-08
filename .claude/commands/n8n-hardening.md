# 🛡️ n8n Hardening — Auditoria de Resiliência para Produção

Você é um especialista sênior em n8n com foco em **resiliência de workflows para produção**. Zero falhas silenciosas.

**Entrada do usuário:** $ARGUMENTS

**Padrão ADK:** Reviewer com Severity Scoring (Padrão #3 — `.claude/skills/agent-skill-patterns/SKILL.md`)

---

## 🎯 Propósito

Auditar e blindar qualquer workflow n8n contra falhas silenciosas em produção. Todo workflow que vai para produção **DEVE** passar por este hardening.

> 💡 **Caso real:** O workflow Newsletter Summarizer falhava silenciosamente porque o Telegram rejeitava mensagens com mais de 4096 caracteres. O LLM gerava resumos longos, o Telegram devolvia erro 400, e ninguém era notificado. O workflow parecia "funcionar" mas nenhuma newsletter chegava. Este hardening existe para que isso **nunca mais aconteça**.

---

## Fase 0: Pré-voo (OBRIGATÓRIO)

### 1. Verificar n8n está rodando
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:5678/healthz
```
- Se **200**: prosseguir
- Se **outro**: informar o usuário e PARAR

### 2. Verificar MCP tools disponíveis
Testar `n8n_health_check`. Se indisponível → PARAR e pedir para reiniciar o Claude Code.

### 3. Identificar o workflow alvo
| Input do usuário | Ação |
|-------------------|------|
| ID do workflow | → `n8n_get_workflow({id, mode: "full"})` |
| Nome do workflow | → `n8n_list_workflows` → encontrar ID → `n8n_get_workflow({id, mode: "full"})` |
| "último workflow" | → `n8n_list_workflows` → pegar o mais recente |
| Nenhum especificado | → Perguntar qual workflow auditar |

---

## Fase 1: Análise — Checklist de Hardening

Analisar **cada node** do workflow contra os 8 critérios abaixo. Marcar como ✅ (passa) ou ❌ (falha) com severidade.

---

### 🔴 1. Retry Configuration (CRITICAL)

**Regra:** Todo node que faz chamada externa **DEVE** ter retry configurado.

| Tipo de Node | Configuração Obrigatória |
|--------------|--------------------------|
| HTTP Request, Webhook Response | `retryOnFail: true`, `maxTries: 3`, `waitBetweenTries: 3000` |
| Telegram, Slack, Discord, Email (SMTP) | `retryOnFail: true`, `maxTries: 3`, `waitBetweenTries: 3000` |
| Qualquer API externa (Notion, Airtable, etc.) | `retryOnFail: true`, `maxTries: 3`, `waitBetweenTries: 5000` |
| LLM nodes (chainLlm, agent, openAi, etc.) | `retryOnFail: true`, `maxTries: 3`, `waitBetweenTries: 5000` |

**Onde verificar no JSON:**
```json
{
  "parameters": {},
  "retryOnFail": true,
  "maxTries": 3,
  "waitBetweenTries": 3000
}
```

**Se ausente:** CRITICAL — chamada externa sem retry falha silenciosamente em qualquer instabilidade de rede ou rate limit.
---

### 🔴 2. Output Validation Guards (CRITICAL)

**Regra:** Após **todo** node LLM, DEVE existir um node IF que valida o output.

**Checklist:**
- [ ] IF node imediatamente após o LLM
- [ ] Condição: output não é vazio/null/undefined **E** comprimento > threshold mínimo (ex: 50 chars)
- [ ] Branch TRUE: continua o fluxo normalmente
- [ ] Branch FALSE: envia alerta (Telegram/Slack/Email) com contexto do erro

**Estrutura esperada:**
```
[LLM Node] → [IF: output válido?]
                 ├── TRUE → [próximo passo]
                 └── FALSE → [Alerta: "LLM retornou vazio para: {contexto}"]
```

**Alerta DEVE conter:**
- Nome do workflow
- Nome do node que falhou
- Contexto do input (ex: remetente, assunto do email, URL)
- Timestamp

**Se ausente:** CRITICAL — LLM pode retornar vazio (timeout, rate limit, prompt ruim) e o workflow segue com dados vazios, gerando mensagens em branco ou erros cascateados.

---

### 🟠 3. Message Size Limits (HIGH)

**Regra:** Antes de enviar mensagem para qualquer canal com limite de caracteres, DEVE existir splitting defensivo.

| Destino | Limite Real | Split em | Max Partes |
|---------|-------------|----------|------------|
| Telegram | 4096 chars | 4000 chars | 10 |
| Slack | 4000 chars | 3900 chars | 10 |
| Discord | 2000 chars | 1900 chars | 10 |
| Email (corpo) | Sem limite rígido | ⚠️ Alertar se > 100KB | — |

**Implementação recomendada — Code node antes do envio:**
```javascript
// Split defensivo para Telegram
const MAX_CHARS = 4000;
const MAX_PARTS = 10;
const text = $input.first().json.text ?? '';

if (!text || text.trim().length === 0) {
  return [{ json: { error: 'Texto vazio — nada a enviar', parts: [] } }];
}

const parts = [];
let remaining = text;
while (remaining.length > 0 && parts.length < MAX_PARTS) {
  if (remaining.length <= MAX_CHARS) {
    parts.push(remaining);
    break;
  }
  // Tentar quebrar no último parágrafo dentro do limite
  let splitAt = remaining.lastIndexOf('

', MAX_CHARS);
  if (splitAt <= 0) splitAt = remaining.lastIndexOf('
', MAX_CHARS);
  if (splitAt <= 0) splitAt = remaining.lastIndexOf('. ', MAX_CHARS);
  if (splitAt <= 0) splitAt = MAX_CHARS;
  parts.push(remaining.substring(0, splitAt));
  remaining = remaining.substring(splitAt).trim();
}

return parts.map((part, i) => ({
  json: {
    text: parts.length > 1 ? `[${i+1}/${parts.length}]
${part}` : part,
    partIndex: i,
    totalParts: parts.length
  }
}));
```

**Se ausente:** HIGH — Telegram/Slack rejeitam a mensagem inteira com erro 400. O conteúdo é perdido silenciosamente.

---

### 🟠 4. HTML Stripping (HIGH)

**Regra:** Antes de qualquer node LLM que recebe conteúdo de email ou web, DEVE existir stripping de HTML.

**Por quê:**
- HTML desperdiça tokens (tags, estilos, scripts são lixo para o LLM)
- HTML confunde o LLM e degrada a qualidade do output
- Reduz custo de API (menos tokens = menos $$$)

**Implementação recomendada — Code node:**
```javascript
const html = $input.first().json.html ?? $input.first().json.body ?? '';

// Strip HTML preservando estrutura
const text = html
  .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '')
  .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, '')
  .replace(/<br\s*\/?>/gi, '
')
  .replace(/<\/p>/gi, '

')
  .replace(/<\/div>/gi, '
')
  .replace(/<\/li>/gi, '
')
  .replace(/<li[^>]*>/gi, '• ')
  .replace(/<\/h[1-6]>/gi, '

')
  .replace(/<[^>]+>/g, '')
  .replace(/&nbsp;/g, ' ')
  .replace(/&amp;/g, '&')
  .replace(/&lt;/g, '<')
  .replace(/&gt;/g, '>')
  .replace(/&quot;/g, '"')
  .replace(/
{3,}/g, '

')
  .trim();

return [{ json: { text, originalLength: html.length, cleanLength: text.length } }];
```

**Se ausente:** HIGH — LLM recebe HTML bruto, gasta 3-10x mais tokens, e a qualidade do resumo/análise cai significativamente.
---

### 🟠 5. Error Notifications (HIGH)

**Regra:** Todo workflow DEVE ter pelo menos UMA forma de notificar falhas.

**Opções (em ordem de preferência):**

| Opção | Como Configurar | Cobertura |
|-------|-----------------|-----------|
| **Error Workflow (global)** | Settings → Error Workflow → selecionar workflow de alerta | Captura erros não tratados de todos os nodes |
| **Error Trigger node** | Adicionar node Error Trigger → Telegram/Slack | Workflow dedicado a capturar erros |
| **Per-node FALSE branches** | Cada node crítico → IF → FALSE → Alert | Controle granular por node |

**Alerta DEVE conter:**
```
🚨 Workflow falhou: [Nome do Workflow]
📍 Node: [Nome do Node]
⏰ Horário: [timestamp BRT]
📋 Contexto: [dados relevantes — from, subject, URL, etc.]
❌ Erro: [mensagem de erro]
```

**Se ausente:** HIGH — Workflow falha e ninguém sabe. Dados são perdidos silenciosamente. Descoberta do problema acontece dias depois, quando alguém pergunta "por que parou de funcionar?".

---

### 🟡 6. IMAP/Trigger Resilience (MEDIUM)

**Regra:** Triggers devem ser configurados para máxima confiabilidade.

| Trigger | Configuração Recomendada |
|---------|--------------------------|
| IMAP Email | Polling (não IDLE) — IDLE perde conexão silenciosamente |
| Webhook | Timeout >= 30s, resposta imediata + processamento async |
| Schedule | Confirmar timezone correto (America/Sao_Paulo) |
| Cron | Verificar que expressão cron está correta para o horário desejado |

**Se configuração subótima:** MEDIUM — Trigger pode perder eventos em condições de rede instável.

---

### 🟡 7. Timeout Configuration (MEDIUM)

**Regra:** Nodes que fazem chamadas demoradas DEVEM ter timeout adequado.

| Tipo de Node | Timeout Mínimo |
|--------------|----------------|
| LLM nodes (GPT-4, Claude, etc.) | 120000ms (2 min) — conteúdo longo demora |
| HTTP Request (APIs externas) | 30000ms |
| HTTP Request (download de arquivos) | 60000ms |

**Onde verificar:**
```json
{
  "parameters": {
    "options": {
      "timeout": 120000
    }
  }
}
```

**Se ausente/baixo:** MEDIUM — Node pode dar timeout em processamentos legítimos de conteúdo longo, gerando falhas intermitentes difíceis de diagnosticar.

---

### 🟢 8. Anti-Spam Guards (LOW)

**Regra:** Mecanismos de proteção contra envio excessivo.

**Checklist:**
- [ ] Message splitting tem `MAX_PARTS` limit (recomendado: 10)
- [ ] Nodes de envio em loop têm delay entre iterações (Wait node de 1-2s)
- [ ] Awareness de rate limits da API destino (Telegram: 30 msgs/s, Slack: 1 msg/s por canal)

**Se ausente:** LOW — Risco de ser bloqueado por rate limit da API destino em workflows com alto volume.

---

## Fase 2: Scoring — Calcular Pontuação

### Matriz de Severidade

| Nível | Peso | Critério |
|-------|------|----------|
| 🔴 CRITICAL | 10 | Chamada externa sem retry, output LLM sem validação |
| 🟠 HIGH | 5 | Sem splitting antes de Telegram/Slack, sem HTML stripping, sem error notification |
| 🟡 MEDIUM | 3 | Timeouts ausentes/baixos, trigger configuration subótima |
| 🟢 LOW | 1 | Anti-spam guards ausentes |

### Thresholds de Decisão

| Score Total | Nota | Decisão |
|-------------|------|---------|
| 0 | 10/10 | ✅ **Blindado** — Pronto para produção |
| 1-5 | 8-9/10 | ✅ **Aprovado com observações** — Corrigir LOWs quando possível |
| 6-15 | 6-7/10 | ⚠️ **Aprovado condicional** — Corrigir HIGHs antes de produção |
| 16-29 | 3-5/10 | ❌ **Reprovado** — Corrigir CRITICALs e HIGHs |
| 30+ | 1-2/10 | 🛑 **Bloqueado** — Revisão arquitetural necessária |

### Cálculo da Nota (0-10)

```
score_bruto = Σ(peso × quantidade por nível)
nota = max(1, 10 - floor(score_bruto / 3))
```
---

## Fase 3: Relatório — Gerar Output Formatado

Gerar o relatório **EXATAMENTE** neste formato:

```markdown
## 🛡️ Relatório de Hardening — [Nome do Workflow]

**ID:** [workflow-id]
**Nodes analisados:** [N]
**Data:** [DD/MM/YYYY HH:MM BRT]

---

### 📊 Score: X/10 — [Status: Blindado | Aprovado | Condicional | Reprovado | Bloqueado]

---

### 🔴 CRITICAL (peso 10 — corrigir ANTES de produção)
- [ ] **[C1]** Node "HTTP Request" sem retryOnFail — falha silenciosa em instabilidade de rede
- [ ] **[C2]** Node "OpenAI" sem IF guard — output vazio segue o fluxo sem validação

### 🟠 HIGH (peso 5 — corrigir para resiliência)
- [ ] **[H1]** Sem Code node de splitting antes de "Telegram" — mensagens > 4096 chars são rejeitadas
- [ ] **[H2]** Sem HTML stripping antes de "OpenAI" — email HTML desperdiça tokens

### 🟡 MEDIUM (peso 3 — recomendado)
- [ ] **[M1]** Node "OpenAI" sem timeout configurado — default pode ser baixo para conteúdo longo

### 🟢 LOW (peso 1 — nice to have)
- [ ] **[L1]** Splitting sem MAX_PARTS — risco teórico de spam

---

### 🧮 Cálculo do Score
| Severidade | Qtd | Peso | Subtotal |
|------------|-----|------|----------|
| CRITICAL | 2 | 10 | 20 |
| HIGH | 2 | 5 | 10 |
| MEDIUM | 1 | 3 | 3 |
| LOW | 1 | 1 | 1 |
| **TOTAL** | | | **34** |

Nota: max(1, 10 - floor(34/3)) = **max(1, 10 - 11) = 1/10** 🛑

---

### 🔧 Plano de Correção (ordem de prioridade)

1. **[C1] Adicionar retry ao HTTP Request**
   - Adicionar `retryOnFail: true, maxTries: 3, waitBetweenTries: 3000`

2. **[C2] Adicionar IF guard após OpenAI**
   - Inserir IF node: output is not empty AND length > 50
   - Branch FALSE → Telegram alert com contexto

3. **[H1] Adicionar Code node de splitting antes do Telegram**
   - Inserir Code node com lógica de split (ver código na Fase 1)
   - Reconfigurar conexões: OpenAI → IF → Code(split) → Telegram

4. **[H2] Adicionar HTML stripping antes do OpenAI**
   - Inserir Code node com lógica de strip (ver código na Fase 1)

5. **[M1] Configurar timeout do OpenAI**
   - Definir timeout: 120000ms

6. **[L1] Adicionar MAX_PARTS ao splitting**
   - Já incluído no código recomendado
```

---

## Fase 4: Correção — Aplicar Fixes (com Diamond Gate)

### ◆ Diamond Gate — "Aprovado para aplicar correções?"

Antes de modificar o workflow, **PARAR** e apresentar:
1. O relatório completo (Fase 3)
2. Lista de alterações que serão feitas
3. Perguntar explicitamente: **"Aprovado para aplicar as correções?"**

### Se aprovado:

Para cada fix, usar `n8n_update_partial_workflow` ou `n8n_update_full_workflow`:

1. Adicionar retry configuration aos nodes externos
2. Inserir IF guards após nodes LLM
3. Inserir Code nodes de splitting antes de Telegram/Slack
4. Inserir Code nodes de HTML stripping antes de LLMs
5. Configurar timeouts adequados
6. Configurar Error Workflow se não existir

### Após cada fix:
```
n8n_validate_workflow({id: "workflow-id", profile: "strict"})
```

### Após todos os fixes:
Gerar relatório final comparativo:
```
Antes: 3/10 ❌ Reprovado
Depois: 9/10 ✅ Aprovado com observações
```
---

## ⚠️ Gotchas Conhecidos

### 1. retryOnFail é propriedade do NODE, não dos parameters
```json
// ❌ ERRADO — dentro de parameters
{ "parameters": { "retryOnFail": true } }

// ✅ CORRETO — no nível do node
{ "parameters": {}, "retryOnFail": true, "maxTries": 3, "waitBetweenTries": 3000 }
```

### 2. IF node para validação de LLM — cuidado com a expressão
Verificar qual campo o LLM node retorna (`text`, `output`, `message`, etc.) antes de montar a condição do IF. Cada tipo de LLM node retorna em campos diferentes.

### 3. Code node de splitting DEVE retornar array
O node seguinte (Telegram) recebe **múltiplos items** e executa uma vez para cada. Isso é o comportamento padrão do n8n com arrays de items.

### 4. Error Workflow é configuração do workflow, não um node
Para definir Error Workflow:
```json
{
  "settings": {
    "errorWorkflow": "ID_DO_WORKFLOW_DE_ERRO"
  }
}
```

### 5. HTML stripping — cuidado com emails multipart
Emails IMAP podem ter o corpo em `html`, `textHtml`, `body`, ou `text` dependendo da configuração do node. Sempre verificar qual campo o IMAP node retorna antes de criar o Code node de stripping.

### 6. Telegram split — cuidado com duplicação
O n8n executa o node seguinte uma vez por item automaticamente. Mas se o Telegram node estiver configurado com `sendTo` fixo, ele já faz isso. Verificar se não há duplicação.

### 7. IF node — NUNCA usar `typeValidation: "strict"` com `isNotEmpty`
**Caso real (exec #57):** IF com `typeValidation: "strict"` + operação `isNotEmpty` com `singleValue: true` **rejeitou texto válido de 6199 chars**. O resumo foi para o branch FALSE e disparou alerta falso. **Regra:** Sempre usar `typeValidation: "loose"` em IF nodes de validação de output. Preferir condição simples: `$json.text.length > 50`.

### 8. chainLlm NÃO propaga campos upstream
**Caso real (exec #57):** O node `chainLlm` só retorna `{text: "..."}`. Campos como `from`, `subject`, `originalFrom` do email **NÃO são passados adiante**. Para acessar dados de nodes anteriores no branch FALSE de um IF, usar `$('Nome do Node').item.json.campo`.

### 9. Unicode escaping em expressões n8n — NUNCA usar `\uXXXX`
**Caso real:** `\\u26a0\\ufe0f` no campo text de um Telegram node resultou em texto literal `\u26a0\ufe0f` em vez do emoji ⚠️. **Regra:** Usar emojis reais (copiar/colar) dentro de expressões `{{ }}`, nunca escape sequences.

### 10. Filtrar por email — SEMPRE `caseSensitive: false`
**Caso real:** `caseSensitive: true` no filtro de remetentes poderia falhar se o Gmail retornasse `Kilocode@Substack.com` em vez de `kilocode@substack.com`. Endereços de email são case-insensitive por RFC 5321.

### 11. Code node NÃO pode usar require() para módulos nativos
**Caso real (Ouroboros exec #124):** Code node com `require('child_process').execSync()` falhou com `Module 'child_process' is disallowed`. O n8n sandbox V8 bloqueia `child_process`, `fs`, `os`, `path`, `http`, `https` por default. **Regra:** Para operações de shell/filesystem, SEMPRE usar **Execute Command** node (`n8n-nodes-base.executeCommand`), nunca Code node com require().

### 12. Execute Command é desabilitado por default no n8n v2
Para habilitar, garantir que `NODES_EXCLUDE` no ecosystem.config.js NÃO inclui `n8n-nodes-base.executeCommand`. Se estiver na lista de exclusão, remover e reiniciar n8n via PM2.

---

## 🔗 Skills Relacionadas

| Skill | Quando Ativar |
|-------|---------------|
| `/n8n` | Coordenador geral — criar/editar workflows |
| `n8n-validation-expert` | Interpretar erros de validação durante correções |
| `n8n-code-javascript` | Escrever Code nodes de splitting/stripping |
| `n8n-node-configuration` | Configurar retry/timeout em nodes específicos |
| `/cyber` | Se o hardening envolver segurança (tokens expostos, webhooks sem auth) |

---

## ⚡ Ativação Automática

Este skill é ativado automaticamente quando o usuário mencionar:

| Trigger | Exemplo |
|---------|---------|
| Auditoria de workflow | "auditar workflow n8n", "revisar workflow" |
| Blindagem/hardening | "blindar workflow", "hardening n8n", "workflow resiliente" |
| Falha em workflow | "workflow falhou", "erro no n8n", "n8n não enviou" |
| Telegram/Slack com erro | "Telegram não recebeu", "mensagem cortada" |
| Após criar workflow | Auto-sugerir: "Deseja rodar o hardening neste workflow?" |
| Após modificar workflow | Auto-sugerir: "Workflow modificado — rodar hardening?" |

---

## 📋 Referência Rápida — Cheat Sheet

```
Workflow novo criado?
│
├── Tem chamadas externas (HTTP, Telegram, Slack, API)?
│   └── ✅ Retry obrigatório (CRITICAL)
│
├── Tem nodes LLM (OpenAI, Claude, chain, agent)?
│   ├── ✅ IF guard após LLM (CRITICAL)
│   ├── ✅ HTML stripping antes do LLM (HIGH)
│   └── ✅ Timeout >= 120s (MEDIUM)
│
├── Envia para Telegram?
│   └── ✅ Split em 4000 chars (HIGH)
│
├── Envia para Slack?
│   └── ✅ Split em 3900 chars (HIGH)
│
├── Tem alguma notificação de erro?
│   └── ✅ Error Workflow ou FALSE branches (HIGH)
│
└── Todos os checks passaram?
    ├── SIM → 🛡️ Workflow blindado para produção
    └── NÃO → Aplicar fixes → Re-auditar
```

---

## Regras Invioláveis

1. **NUNCA aprovar workflow para produção sem hardening E smoke test** — validação NÃO é prova de funcionamento (não detecta sandbox, credentials expiradas, APIs offline)
2. **NUNCA pular o Diamond Gate** — correções só são aplicadas com aprovação explícita
3. **NUNCA modificar a lógica de negócio** — hardening é sobre resiliência, não sobre mudar o que o workflow faz
4. **SEMPRE gerar relatório formatado** — o usuário precisa ver o diagnóstico completo antes de aprovar
5. **SEMPRE validar após cada correção** — `n8n_validate_workflow` com profile `strict`
6. **SEMPRE re-auditar após correções** — confirmar que o score melhorou

---

*Estou seguindo as minhas instruções, chefe.*
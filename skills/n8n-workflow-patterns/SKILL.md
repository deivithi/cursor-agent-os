---
name: n8n-workflow-patterns
description: >
  5 padrões arquiteturais para workflows n8n: Webhook Processing, HTTP API Integration,
  Database Operations, AI Agent Workflow, Scheduled Tasks. Com templates e anti-patterns.
domain: automation
subdomain: n8n-architecture
version: 1.0.0
author: deivithi
tags:
  - n8n
  - workflow-patterns
  - architecture
  - webhook
  - ai-agent
  - scheduling
---

# 🏗️ n8n Workflow Patterns

> **"Todo workflow bem-sucedido segue um dos 5 padrões. Escolher o padrão certo é 80% do trabalho."**

## 📁 File Structure
- `SKILL.md` — Você está aqui.

## 🔗 Related Skills
- `n8n-node-configuration` — Configurar cada node do padrão
- `n8n-code-javascript` — Code nodes dentro dos padrões
- `n8n-validation-expert` — Debug quando o padrão não funciona
- `n8n-mcp-tools-expert` — Criar workflows via MCP tools

---

## 🎯 Seleção de Padrão

| Se o workflow precisa... | Usar Padrão |
|--------------------------|-------------|
| Receber dados de webhook/form externo | **1. Webhook Processing** |
| Buscar dados de API → transformar → agir | **2. HTTP API Integration** |
| CRUD em banco de dados, ETL, sync | **3. Database Operations** |
| IA conversacional com ferramentas | **4. AI Agent Workflow** |
| Tarefa recorrente (daily, hourly) | **5. Scheduled Tasks** |
| Combinar 2+ padrões | Compor padrões (ver seção Composição) |

---

## 1. Webhook Processing

### Diagrama
```
Webhook → Validate Input → Process → [Response] → Side Effects
                              ↓ (inválido)
                         Return Error
```

### Quando Usar
- Receber dados de Stripe, GitHub, Typeform, etc.
- Endpoint para integração com sistemas externos
- Processamento em tempo real de eventos

### Template
```
Nodes:
1. Webhook (n8n-nodes-base.webhook)
   - path: "/meu-endpoint"
   - method: POST
   - responseMode: "responseNode" (responder depois de processar)

2. IF — Validar payload
   - Condição: campos obrigatórios existem

3. Code — Processar dados (transformar, enriquecer)

4. Webhook Response — Retornar 200 OK
   - respondWith: "json"
   - responseBody: { "status": "ok" }

5. [Side effects] — Salvar em DB, enviar notificação, etc.
```

### Anti-patterns
- ❌ Processar payload pesado ANTES de responder → timeout do webhook caller
- ✅ Responder 200 imediatamente, processar depois (responseMode: "lastNode" ou split)
- ❌ Webhook sem validação de input → dados lixo entram no sistema
- ❌ Webhook sem auth → qualquer um pode disparar

---

## 2. HTTP API Integration

### Diagrama
```
Trigger → Fetch API → Transform → IF Valid? → Act → Notify
                                      ↓ (inválido)
                                   Log/Alert
```

### Quando Usar
- Buscar dados de uma API e processar
- Integração entre dois sistemas via API
- Data enrichment (buscar dados complementares)

### Template
```
Nodes:
1. Schedule Trigger ou Webhook

2. HTTP Request — Buscar dados
   - retryOnFail: true, maxTries: 3
   - timeout: 30000

3. Code — Transformar resposta
   - Parse, filter, map

4. IF — Validar dados
   - Condição: array não vazio, campos obrigatórios

5. [Destino] — Salvar em Sheets, enviar email, etc.
   - retryOnFail: true

6. Error Alert — Telegram/Slack se falhar
```

### Anti-patterns
- ❌ HTTP Request sem retry → falha em qualquer instabilidade
- ❌ HTTP Request sem timeout → pode travar o workflow
- ❌ Processar resposta sem validar → dados inesperados cascateiam erros
- ❌ Usar Code node para fetch → usar HTTP Request node (tem retry nativo)

---

## 3. Database Operations

### Diagrama
```
Trigger → Read Source → Transform → Write Destination → Verify → Notify
```

### Quando Usar
- ETL (Extract, Transform, Load)
- Sync entre dois bancos/planilhas
- Batch operations em dados

### Template
```
Nodes:
1. Schedule Trigger (sync periódico) ou Webhook (sync on-demand)

2. [Source] — Google Sheets / Postgres / HTTP Request
   - retryOnFail: true

3. Code — Transformar dados
   - Map campos, limpar, validar

4. Loop Over Items — Processar em batches
   - batchSize: 100 (evitar sobrecarga)

5. [Destination] — Google Sheets / Postgres / API
   - retryOnFail: true

6. Code — Contar resultados

7. Telegram/Slack — Notificar conclusão
```

### Anti-patterns
- ❌ Processar 10k+ items de uma vez → out of memory
- ✅ Usar Loop Over Items com batchSize
- ❌ Sem dedup → duplicatas no destino
- ✅ Adicionar Code node de dedup antes do write
- ❌ Sem contagem/verificação → não saber se funcionou

---

## 4. AI Agent Workflow

### Diagrama
```
Trigger → [Pre-process] → LLM → IF Valid? → Post-process → Deliver
                                     ↓ (inválido)
                                  Alert + Retry
```

### Quando Usar
- Resumir conteúdo (emails, artigos, calls)
- Classificar/extrair dados com IA
- Chatbot com ferramentas
- Análise de sentimento, NER, etc.

### Template
```
Nodes:
1. Trigger (Email IMAP, Webhook, Schedule)

2. Code — HTML stripping / markdown conversion (OBRIGATÓRIO)
   - LLMs recebem texto limpo, não HTML

3. LLM Node — OpenAI/Claude/Chain
   - retryOnFail: true, maxTries: 3
   - timeout: 120000 (2 min)

4. IF — Validar output do LLM
   - {{ $json.text.length > 50 }}
   - typeValidation: "loose"

5. Code — Post-process (format, split, parse JSON)

6. [Deliver] — Telegram, Slack, Email, Sheets
   - Com splitting se necessário

7. Error Alert — Notificar falhas
```

### Anti-patterns
- ❌ HTML bruto direto pro LLM → gasta 3-10x tokens, output degradado
- ✅ SEMPRE strip HTML antes do LLM
- ❌ LLM output sem validação → segue com vazio se rate limited
- ✅ SEMPRE IF guard após LLM
- ❌ chainLlm → acessar `$json.from` → undefined (não propaga upstream)
- ✅ Usar `$("Node Name").first().json.campo`
- ❌ Prompt sem contexto → output genérico
- ✅ Incluir metadata no prompt (who, what, when)

---

## 5. Scheduled Tasks

### Diagrama
```
Schedule → Fetch/Compute → Transform → Deliver → Log
```

### Quando Usar
- Reports diários/semanais
- Health checks periódicos
- Sync de dados recorrente
- Cleanup/maintenance tasks

### Template
```
Nodes:
1. Schedule Trigger
   - Cron expression para horário BRT
   - Timezone: America/Sao_Paulo

2. [Fetch] — API, DB, ou cálculo interno
   - retryOnFail: true

3. Code — Agregar/formatar dados

4. IF — Validar (tem dados?)

5. [Deliver] — Telegram, Email, Sheets
   - Com splitting se mensagem longa

6. Error Workflow configurado nos settings
```

### Anti-patterns
- ❌ Timezone errado → executa 3h antes/depois do esperado
- ✅ SEMPRE `"timezone": "America/Sao_Paulo"` nos settings
- ❌ Schedule sem error notification → falha silenciosamente
- ✅ SEMPRE ter Error Workflow ou alert no branch de erro
- ❌ Schedule muito frequente sem dedup → processa dados repetidos

---

## 🔀 Composição de Padrões

Workflows reais frequentemente combinam padrões:

### Newsletter Summarizer (Padrão 5 + 4 + 2)
```
Schedule (5) → Fetch RSS/Email (2) → LLM Summarize (4) → Telegram
```

### Call Intelligence (Padrão 5 + 3 + 4)
```
Schedule (5) → Google Drive fetch (3) → LLM Extract (4) → Sheets (3)
```

### Ouroboros (Padrão 5 + Execute Command)
```
Schedule (5) → Select Target → Execute Command (claude CLI) → Parse → Telegram
```

---

## 📐 Regras de Ouro para Todos os Padrões

1. **Retry em toda chamada externa** — HTTP, API, DB, messaging
2. **Validação após toda transformação** — IF guard, length check
3. **Error notification em todo workflow** — pelo menos 1 canal de alerta
4. **Timezone explícito** — `America/Sao_Paulo` nos settings
5. **Splitting antes de messaging** — Telegram 4000, Slack 3900
6. **HTML stripping antes de LLM** — sempre texto limpo
7. **Batch processing para dados grandes** — Loop Over Items, sub-workflows
8. **Execute Command para shell/CLI** — nunca Code node com require()

---

## Regras Invioláveis

1. **SEMPRE escolher o padrão ANTES de começar** — não improvisar
2. **SEMPRE seguir o diagrama do padrão** — cada step existe por um motivo
3. **NUNCA pular validação** — dados inesperados são a causa #1 de falhas
4. **NUNCA usar Code node para HTTP requests** — usar HTTP Request node
5. **SEMPRE compor padrões explicitamente** — documentar qual padrão cada seção segue

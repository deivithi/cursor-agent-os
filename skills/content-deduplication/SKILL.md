---
name: content-deduplication
description: Deduplicate content in n8n pipelines using TF-IDF cosine similarity. Pure JavaScript implementation for Code nodes. Supports multiple sources (IMAP, RSS, webhook). Threshold-based similarity detection. Use when processing newsletters, RSS feeds, email pipelines, or any content aggregation workflow to avoid duplicate summaries.
---

# Content Deduplication — n8n Skill

> Deduplicacao inteligente de conteudo em pipelines n8n usando TF-IDF + similaridade cosseno.
> Implementacao 100% JavaScript puro — funciona no sandbox do Code node sem dependencias externas.

---

## Quando Usar

| Cenario | Exemplo |
|---------|---------|
| **Newsletters** | Mesmo conteudo enviado por multiplos remetentes |
| **RSS Feeds** | Artigos republicados em feeds diferentes |
| **Webhooks** | Eventos duplicados por retry ou race condition |
| **Email pipelines** | IMAP polling captura o mesmo email mais de uma vez |
| **Agregacao de conteudo** | Multiplas fontes com sobreposicao de topicos |

---

## Estrategias de Deduplicacao

### 1. Content Hash (rapido, match exato)

Gera hash SHA-256 do conteudo normalizado. Detecta duplicatas identicas.

```javascript
// n8n Code Node — Hash-based Dedup
const crypto = require('crypto');

const items = $input.all();
const staticData = $getWorkflowStaticData('global');

if (!staticData.seenHashes) {
  staticData.seenHashes = {};
}

const now = Date.now();
const EXPIRY_MS = 7 * 24 * 60 * 60 * 1000; // 7 dias

// Limpar hashes expirados
for (const [hash, timestamp] of Object.entries(staticData.seenHashes)) {
  if (now - timestamp > EXPIRY_MS) {
    delete staticData.seenHashes[hash];
  }
}

const newItems = [];

for (const item of items) {
  const content = (item.json.subject + ' ' + item.json.body)
    .toLowerCase().trim().replace(/\s+/g, ' ');
  const hash = crypto.createHash('sha256').update(content).digest('hex');

  if (!staticData.seenHashes[hash]) {
    staticData.seenHashes[hash] = now;
    newItems.push(item);
  }
}

return newItems;
```

### 2. TF-IDF + Similaridade Cosseno (fuzzy, detecta reformulacoes)

Compara semanticamente conteudo novo contra historico. Detecta duplicatas mesmo com palavras diferentes.

```javascript
// n8n Code Node — TF-IDF Dedup
// Implementacao completa em: references/tfidf-js.md

const THRESHOLD = 0.85; // Similaridade >= 0.85 = duplicata
const MAX_HISTORY = 200; // Limitar vocabulario
const EXPIRY_DAYS = 7;

const staticData = $getWorkflowStaticData('global');
if (!staticData.contentHistory) {
  staticData.contentHistory = [];
}

// Funcoes TF-IDF inline (ver references/tfidf-js.md para versao completa)
function tokenize(text) {
  return text.toLowerCase().replace(/[^\w\s]/g, '').split(/\s+/).filter(t => t.length > 2);
}

function cosineSim(a, b) {
  const keys = new Set([...Object.keys(a), ...Object.keys(b)]);
  let dot = 0, magA = 0, magB = 0;
  for (const k of keys) {
    const va = a[k] || 0, vb = b[k] || 0;
    dot += va * vb;
    magA += va * va;
    magB += vb * vb;
  }
  return magA && magB ? dot / (Math.sqrt(magA) * Math.sqrt(magB)) : 0;
}

function tfidfVector(tokens, allDocs) {
  const tf = {};
  for (const t of tokens) tf[t] = (tf[t] || 0) + 1;
  const maxTf = Math.max(...Object.values(tf));
  const vec = {};
  const N = allDocs.length || 1;
  for (const [term, count] of Object.entries(tf)) {
    const normalizedTf = 0.5 + 0.5 * (count / maxTf);
    const df = allDocs.filter(d => d.includes(term)).length || 1;
    vec[term] = normalizedTf * Math.log(N / df);
  }
  return vec;
}

// Limpar historico expirado
const now = Date.now();
const expiryMs = EXPIRY_DAYS * 86400000;
staticData.contentHistory = staticData.contentHistory
  .filter(h => now - h.timestamp < expiryMs)
  .slice(-MAX_HISTORY);

const items = $input.all();
const newItems = [];
const allTokenized = staticData.contentHistory.map(h => h.tokens);

for (const item of items) {
  const text = (item.json.subject || '') + ' ' + (item.json.body || item.json.content || '');
  const tokens = tokenize(text);
  const vec = tfidfVector(tokens, allTokenized);

  let isDuplicate = false;
  for (const stored of staticData.contentHistory) {
    const storedVec = tfidfVector(stored.tokens, allTokenized);
    if (cosineSim(vec, storedVec) >= THRESHOLD) {
      isDuplicate = true;
      break;
    }
  }

  if (!isDuplicate) {
    staticData.contentHistory.push({ tokens, timestamp: now });
    newItems.push(item);
  }
}

return newItems;
```

---

## Workflow de Integracao

```
Source (IMAP/RSS/Webhook)
    |
    v
[Code Node: Dedup Check]
    |
    ├── Novo conteudo ──> Process (Summarize, Transform, etc.)
    |                          |
    |                          v
    |                     Store Hash/Tokens (static data)
    |
    └── Duplicata ──> Discard (ou log para auditoria)
```

### Configuracao por Tipo de Source

| Source | Campo para Dedup | Observacao |
|--------|-----------------|------------|
| **IMAP** | `subject` + `body` | Normalizar HTML para texto puro antes |
| **RSS** | `title` + `contentSnippet` | Usar `link` como pre-filtro rapido |
| **Webhook** | `body` ou campo customizado | Incluir `idempotencyKey` se disponivel |

---

## Estrategias de Armazenamento

| Estrategia | Capacidade | Persistencia | Quando Usar |
|------------|-----------|--------------|-------------|
| **Workflow Static Data** | ~1MB | Entre execucoes | Pipelines leves, < 500 hashes |
| **n8n Datastore** | Ilimitado | Permanente | Volume alto, historico longo |
| **Arquivo JSON** | Disco local | Permanente | Self-hosted, controle total |

### Static Data (padrao recomendado)

```javascript
const staticData = $getWorkflowStaticData('global');
// Dados persistem entre execucoes do mesmo workflow
// Limite pratico: ~1MB (depende do backend do n8n)
```

### n8n Datastore (volume alto)

```javascript
// Usar node "n8n Datastore" antes/depois do Code node
// Armazenar hashes como registros com TTL
// Vantagem: sem limite de tamanho, compartilhavel entre workflows
```

---

## Threshold — Como Calibrar

| Threshold | Comportamento | Use Case |
|-----------|--------------|----------|
| **0.95** | Muito restrito — so duplicatas quase identicas | Logs, eventos com ID |
| **0.85** | Equilibrado — pega reformulacoes | Newsletters, RSS (recomendado) |
| **0.70** | Agressivo — pega conteudos apenas similares | Agregacao de noticias |

> **Dica:** Comece com 0.85 e ajuste baseado em falsos positivos/negativos observados.

---

## Anti-Patterns

| Anti-Pattern | Problema | Solucao |
|--------------|----------|---------|
| Dedup so por metadata (titulo, remetente) | Perde duplicatas com titulos diferentes | Usar conteudo completo (body) |
| Hash store sem expiracao | Crece infinitamente, estoura memoria | TTL de 7 dias (configuravel) |
| TF-IDF sem limite de historico | Vocabulario explode, Code node fica lento | `MAX_HISTORY = 200` |
| Comparar contra TODOS os historicos | O(n) por item, fica lento | Usar hash como pre-filtro + TF-IDF so para nao-match |
| Dedup em metadata + content misturados | Campos de metadata poluem a similaridade | Separar: hash para ID exato, TF-IDF para conteudo |

---

## Estrategia Hibrida (Recomendada para Producao)

```
Item novo
  |
  v
[Hash SHA-256 do conteudo normalizado]
  |
  ├── Hash existe? ──> DUPLICATA (descarta)
  |
  └── Hash novo?
        |
        v
      [TF-IDF vs historico recente]
        |
        ├── Similaridade >= 0.85? ──> DUPLICATA (descarta)
        |
        └── Similaridade < 0.85? ──> NOVO (processa + armazena hash e tokens)
```

> Hash e rapido e pega 90% das duplicatas. TF-IDF cuida dos 10% restantes (reformulacoes).

---

## Quality Checklist

```
[ ] Threshold definido e documentado (padrao: 0.85)
[ ] TTL configurado para limpeza automatica de hashes/tokens
[ ] MAX_HISTORY limitado para proteger memoria do Code node
[ ] Conteudo normalizado antes do hash (lowercase, trim, whitespace)
[ ] HTML convertido para texto puro antes de processar
[ ] Estrategia de armazenamento adequada ao volume
[ ] Pre-filtro por hash antes de TF-IDF (performance)
[ ] Log de duplicatas descartadas para auditoria
[ ] Teste com conteudo identico (deve rejeitar)
[ ] Teste com conteudo reformulado (deve rejeitar com TF-IDF)
[ ] Teste com conteudo genuinamente diferente (deve aceitar)
[ ] Monitorar tamanho do static data em producao
```

---

## Arquivos da Skill

| Arquivo | Conteudo |
|---------|----------|
| `SKILL.md` | Este documento — visao completa da skill |
| `gotchas.md` | Armadilhas e limitacoes conhecidas |
| `references/tfidf-js.md` | Implementacao completa TF-IDF pronta para n8n Code node |

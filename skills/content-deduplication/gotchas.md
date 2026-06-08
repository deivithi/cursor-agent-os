# Content Deduplication — Gotchas

> Armadilhas, limitacoes e solucoes para deduplicacao de conteudo em n8n.

---

## 1. Limite de Memoria do Code Node

**Problema:** O Code node do n8n roda em sandbox com memoria limitada. Se o vocabulario TF-IDF crescer demais (milhares de documentos no historico), o node pode crashar ou ficar extremamente lento.

**Sintoma:** Execucao do workflow falha com `JavaScript heap out of memory` ou timeout.

**Solucao:**
- Limitar `MAX_HISTORY` a 200-500 documentos
- Implementar TTL (time-to-live) para remover entradas antigas
- Usar hash como pre-filtro (resolve 90% dos casos sem TF-IDF)
- Para volume muito alto: migrar para n8n Datastore + comparacao batch

```javascript
// Protecao contra crescimento descontrolado
const MAX_HISTORY = 200;
staticData.contentHistory = staticData.contentHistory.slice(-MAX_HISTORY);
```

---

## 2. Persistencia do Static Data

**Problema:** `$getWorkflowStaticData('global')` persiste entre execucoes, mas:
- Tem limite de tamanho (~1MB, varia por backend)
- E perdido se o workflow for deletado e recriado
- Nao e compartilhado entre workflows diferentes
- Em deploy com multiplas instancias n8n, static data nao sincroniza

**Sintoma:** Dedup funciona em dev mas falha em prod com multiplas instancias.

**Solucao:**
- Para volume baixo: static data e suficiente
- Para volume alto ou multi-instancia: usar n8n Datastore ou banco externo
- Sempre implementar TTL — nunca confiar que o static data sera limpo automaticamente

---

## 3. Colisoes de Hash

**Problema:** SHA-256 tem probabilidade de colisao astronomicamente baixa (~1 em 2^128), mas MD5 e SHA-1 sao vulneraveis a colisoes intencionais.

**Sintoma:** Conteudo genuinamente diferente sendo descartado como duplicata (extremamente raro com SHA-256).

**Solucao:**
- Usar SHA-256 (padrao na skill), nunca MD5 para dedup
- Se paranoia for necessaria: armazenar hash + primeiros 100 chars como double-check
- Para content-addressable storage: SHA-256 e o padrao da industria

```javascript
// BOM — SHA-256
const hash = crypto.createHash('sha256').update(content).digest('hex');

// RUIM — MD5 (colisoes conhecidas, nao usar para dedup critico)
const hash = crypto.createHash('md5').update(content).digest('hex');
```

---

## 4. Estado Cross-Execution

**Problema:** O Code node nao mantem variaveis entre execucoes. Toda logica de estado precisa usar `$getWorkflowStaticData()` ou armazenamento externo.

**Sintoma:** Dedup so funciona dentro da mesma execucao; entre execucoes, tudo e tratado como novo.

**Solucao:**
- Sempre usar `$getWorkflowStaticData('global')` para estado persistente
- Nunca depender de variaveis `let`/`const` no escopo do Code node para estado entre execucoes
- Testar com multiplas execucoes sequenciais, nao apenas uma

```javascript
// ERRADO — perde estado entre execucoes
const seenHashes = {}; // resetado a cada execucao

// CERTO — persiste entre execucoes
const staticData = $getWorkflowStaticData('global');
if (!staticData.seenHashes) staticData.seenHashes = {};
```

---

## 5. Normalizacao Inconsistente

**Problema:** Mesmo conteudo com diferencas de formatacao (HTML vs texto, espacos extras, acentos) gera hashes diferentes.

**Sintoma:** Duplicatas nao sao detectadas por hash, mas TF-IDF pega (porque tokeniza).

**Solucao:**
- Sempre normalizar antes de gerar hash: lowercase, trim, colapsar whitespace
- Converter HTML para texto puro antes de processar
- Remover assinaturas de email, footers de newsletter (poluem a comparacao)

```javascript
function normalize(text) {
  return text
    .replace(/<[^>]*>/g, ' ')      // strip HTML
    .replace(/\s+/g, ' ')           // colapsar whitespace
    .toLowerCase()
    .trim();
}
```

---

## 6. TF-IDF com Documentos Muito Curtos

**Problema:** TF-IDF funciona melhor com textos de pelo menos 50-100 palavras. Para textos muito curtos (titulos, subjects), a similaridade cosseno pode dar resultados imprecisos.

**Sintoma:** Falsos positivos ou negativos em titulos curtos.

**Solucao:**
- Para textos curtos (< 30 palavras): preferir hash exato
- Concatenar campos (subject + body) para aumentar o corpus
- Ajustar threshold para baixo (0.70-0.75) em textos curtos

---

## 7. Timezone e Expiracao

**Problema:** TTL baseado em `Date.now()` usa UTC. Se o pipeline roda em horarios especificos (BRT), a expiracao pode nao alinhar com a expectativa do usuario.

**Sintoma:** Conteudo expira antes ou depois do esperado.

**Solucao:**
- Usar sempre `Date.now()` (UTC milliseconds) internamente — e consistente
- Converter para BRT apenas na interface/logs, nunca na logica de TTL
- Documentar que o TTL e em dias corridos, nao dias uteis

---

## 8. Primeira Execucao (Cold Start)

**Problema:** Na primeira execucao, o historico esta vazio. Tudo sera tratado como novo, mesmo que haja duplicatas entre os itens do mesmo batch.

**Sintoma:** Primeiro batch passa 100% dos itens; a partir do segundo, dedup funciona.

**Solucao:**
- No primeiro batch, comparar itens entre si (intra-batch dedup)
- Ou aceitar o cold start e confiar que a partir da segunda execucao o dedup funciona

```javascript
// Intra-batch dedup no cold start
const batchTokens = [];
for (const item of items) {
  const tokens = tokenize(getText(item));
  let isDup = false;
  for (const prev of batchTokens) {
    if (cosineSim(tfidfVector(tokens, batchTokens), tfidfVector(prev, batchTokens)) >= THRESHOLD) {
      isDup = true;
      break;
    }
  }
  if (!isDup) {
    batchTokens.push(tokens);
    newItems.push(item);
  }
}
```

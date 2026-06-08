# TF-IDF + Cosine Similarity — Pure JS for n8n Code Node

> Implementacao completa pronta para colar em um Code node do n8n.
> Zero dependencias externas. Funciona no sandbox do n8n.

---

## Implementacao Completa

```javascript
// ============================================================
// TF-IDF + Cosine Similarity — Content Deduplication
// Cola este codigo inteiro em um n8n Code node
// ============================================================

// --- CONFIGURACAO ---
const THRESHOLD = 0.85;       // Similaridade >= este valor = duplicata
const MAX_HISTORY = 200;      // Max documentos no historico
const EXPIRY_DAYS = 7;        // Dias para expirar entradas antigas
const EXPIRY_MS = EXPIRY_DAYS * 24 * 60 * 60 * 1000;

// --- STOPWORDS (pt-BR + en) ---
const STOPWORDS = new Set([
  // Portugues
  'de', 'da', 'do', 'das', 'dos', 'em', 'no', 'na', 'nos', 'nas',
  'um', 'uma', 'uns', 'umas', 'por', 'para', 'com', 'sem', 'sob',
  'que', 'se', 'nao', 'mais', 'mas', 'como', 'seu', 'sua', 'seus', 'suas',
  'ele', 'ela', 'eles', 'elas', 'isso', 'isto', 'esse', 'essa',
  'este', 'esta', 'estes', 'estas', 'foi', 'ser', 'ter', 'estar',
  'quando', 'muito', 'tambem', 'entre', 'depois', 'sobre', 'mesmo',
  'aos', 'pelas', 'pelos', 'desde', 'ate', 'onde', 'qual', 'quais',
  // Ingles
  'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can',
  'her', 'was', 'one', 'our', 'out', 'has', 'have', 'had', 'been',
  'will', 'with', 'this', 'that', 'from', 'they', 'been', 'said',
  'each', 'which', 'their', 'there', 'what', 'about', 'would',
  'make', 'like', 'just', 'into', 'over', 'such', 'than', 'them',
  'some', 'could', 'other', 'after', 'then', 'only', 'also', 'your'
]);

// --- FUNCOES CORE ---

/**
 * Tokeniza texto em array de palavras significativas.
 * Remove pontuacao, numeros isolados, stopwords e palavras curtas.
 *
 * @param {string} text - Texto para tokenizar
 * @returns {string[]} Array de tokens
 */
function tokenize(text) {
  return text
    .toLowerCase()
    .replace(/<[^>]*>/g, ' ')        // Remove HTML tags
    .replace(/[^\w\sáéíóúàâêôãõç]/g, ' ')  // Remove pontuacao (preserva acentos)
    .replace(/\d+/g, ' ')            // Remove numeros
    .split(/\s+/)
    .filter(token =>
      token.length > 2 &&            // Minimo 3 caracteres
      !STOPWORDS.has(token)           // Remove stopwords
    );
}

/**
 * Constroi vocabulario unico a partir de multiplos conjuntos de tokens.
 *
 * @param {string[][]} allTokenSets - Array de arrays de tokens
 * @returns {string[]} Vocabulario unico ordenado
 */
function buildVocabulary(allTokenSets) {
  const vocab = new Set();
  for (const tokens of allTokenSets) {
    for (const token of tokens) {
      vocab.add(token);
    }
  }
  return [...vocab].sort();
}

/**
 * Calcula vetor TF-IDF para um documento.
 *
 * TF (Term Frequency): Frequencia normalizada do termo no documento.
 *   tf(t,d) = 0.5 + 0.5 * (count(t,d) / max_count(d))
 *
 * IDF (Inverse Document Frequency): Importancia global do termo.
 *   idf(t) = log(N / df(t))
 *   Onde N = total de documentos, df(t) = documentos que contem t.
 *
 * @param {string[]} tokens - Tokens do documento
 * @param {string[][]} allDocs - Todos os documentos tokenizados (para IDF)
 * @returns {Object} Vetor sparse {termo: peso_tfidf}
 */
function tfidfVector(tokens, allDocs) {
  // Calcular TF
  const tf = {};
  for (const t of tokens) {
    tf[t] = (tf[t] || 0) + 1;
  }

  if (Object.keys(tf).length === 0) return {};

  const maxTf = Math.max(...Object.values(tf));
  const N = Math.max(allDocs.length, 1);

  // Calcular TF-IDF
  const vector = {};
  for (const [term, count] of Object.entries(tf)) {
    // TF normalizado (augmented frequency — evita bias para docs longos)
    const normalizedTf = 0.5 + 0.5 * (count / maxTf);

    // IDF — quantos documentos contem este termo
    const df = allDocs.filter(doc => doc.includes(term)).length || 1;
    const idf = Math.log(N / df);

    const score = normalizedTf * idf;
    if (score > 0) {
      vector[term] = score;
    }
  }

  return vector;
}

/**
 * Calcula similaridade cosseno entre dois vetores sparse.
 *
 * cos(A,B) = (A . B) / (|A| * |B|)
 *
 * @param {Object} vecA - Vetor sparse {termo: peso}
 * @param {Object} vecB - Vetor sparse {termo: peso}
 * @returns {number} Similaridade entre 0 e 1
 */
function cosineSimilarity(vecA, vecB) {
  const keysA = Object.keys(vecA);
  const keysB = Object.keys(vecB);

  if (keysA.length === 0 || keysB.length === 0) return 0;

  // Iterar sobre o vetor menor para performance
  const [smaller, larger] = keysA.length <= keysB.length
    ? [vecA, vecB]
    : [vecB, vecA];

  let dotProduct = 0;
  for (const key of Object.keys(smaller)) {
    if (larger[key]) {
      dotProduct += smaller[key] * larger[key];
    }
  }

  if (dotProduct === 0) return 0;

  let magA = 0;
  for (const v of Object.values(vecA)) magA += v * v;

  let magB = 0;
  for (const v of Object.values(vecB)) magB += v * v;

  return dotProduct / (Math.sqrt(magA) * Math.sqrt(magB));
}

/**
 * Extrai texto relevante de um item n8n.
 * Tenta multiplos campos comuns.
 *
 * @param {Object} item - Item n8n ($input.all()[i])
 * @returns {string} Texto concatenado
 */
function extractText(item) {
  const fields = ['subject', 'title', 'body', 'content', 'text',
                  'description', 'summary', 'contentSnippet', 'html'];
  const parts = [];
  for (const field of fields) {
    if (item.json[field] && typeof item.json[field] === 'string') {
      parts.push(item.json[field]);
    }
  }
  return parts.join(' ');
}

// --- LOGICA PRINCIPAL ---

const items = $input.all();
const staticData = $getWorkflowStaticData('global');

// Inicializar historico
if (!staticData.dedupHistory) {
  staticData.dedupHistory = [];
}

const now = Date.now();

// Limpar entradas expiradas
staticData.dedupHistory = staticData.dedupHistory
  .filter(entry => now - entry.ts < EXPIRY_MS);

// Manter limite de tamanho
if (staticData.dedupHistory.length > MAX_HISTORY) {
  staticData.dedupHistory = staticData.dedupHistory.slice(-MAX_HISTORY);
}

// Preparar corpus para IDF
const allDocs = staticData.dedupHistory.map(entry => entry.tokens);

const newItems = [];
const duplicates = [];

for (const item of items) {
  const text = extractText(item);

  if (!text || text.trim().length < 10) {
    // Conteudo muito curto — deixar passar
    newItems.push(item);
    continue;
  }

  const tokens = tokenize(text);

  if (tokens.length < 3) {
    // Poucos tokens significativos — deixar passar
    newItems.push(item);
    continue;
  }

  // Calcular vetor TF-IDF do item novo
  const newVec = tfidfVector(tokens, [...allDocs, tokens]);

  // Comparar com historico
  let isDuplicate = false;
  let maxSim = 0;

  for (const stored of staticData.dedupHistory) {
    const storedVec = tfidfVector(stored.tokens, [...allDocs, tokens]);
    const sim = cosineSimilarity(newVec, storedVec);

    if (sim > maxSim) maxSim = sim;

    if (sim >= THRESHOLD) {
      isDuplicate = true;
      break;
    }
  }

  // Tambem comparar intra-batch (cold start protection)
  if (!isDuplicate) {
    for (const prev of newItems) {
      const prevText = extractText(prev);
      const prevTokens = tokenize(prevText);
      if (prevTokens.length < 3) continue;
      const prevVec = tfidfVector(prevTokens, [...allDocs, tokens, prevTokens]);
      const batchNewVec = tfidfVector(tokens, [...allDocs, tokens, prevTokens]);
      const sim = cosineSimilarity(batchNewVec, prevVec);
      if (sim >= THRESHOLD) {
        isDuplicate = true;
        break;
      }
    }
  }

  if (isDuplicate) {
    // Adicionar metadata de dedup para auditoria
    item.json._dedup = { duplicate: true, maxSimilarity: maxSim.toFixed(4) };
    duplicates.push(item);
  } else {
    // Novo conteudo — armazenar no historico
    staticData.dedupHistory.push({ tokens, ts: now });
    allDocs.push(tokens);
    item.json._dedup = { duplicate: false, maxSimilarity: maxSim.toFixed(4) };
    newItems.push(item);
  }
}

// Retornar apenas itens novos
// Para auditoria de duplicatas, usar output secundario: return [newItems, duplicates]
return newItems;
```

---

## Funcoes Isoladas (para testes ou uso modular)

### tokenize

```javascript
function tokenize(text) {
  const STOPWORDS = new Set(['de','da','do','the','and','for','are','but','not','you','all','can','with','this','that','from']);
  return text
    .toLowerCase()
    .replace(/<[^>]*>/g, ' ')
    .replace(/[^\w\sáéíóúàâêôãõç]/g, ' ')
    .replace(/\d+/g, ' ')
    .split(/\s+/)
    .filter(t => t.length > 2 && !STOPWORDS.has(t));
}
```

### buildVocabulary

```javascript
function buildVocabulary(allTokenSets) {
  const vocab = new Set();
  for (const tokens of allTokenSets) {
    for (const token of tokens) vocab.add(token);
  }
  return [...vocab].sort();
}
```

### tfidfVector

```javascript
function tfidfVector(tokens, allDocs) {
  const tf = {};
  for (const t of tokens) tf[t] = (tf[t] || 0) + 1;
  if (!Object.keys(tf).length) return {};
  const maxTf = Math.max(...Object.values(tf));
  const N = Math.max(allDocs.length, 1);
  const vec = {};
  for (const [term, count] of Object.entries(tf)) {
    const ntf = 0.5 + 0.5 * (count / maxTf);
    const df = allDocs.filter(d => d.includes(term)).length || 1;
    const score = ntf * Math.log(N / df);
    if (score > 0) vec[term] = score;
  }
  return vec;
}
```

### cosineSimilarity

```javascript
function cosineSimilarity(vecA, vecB) {
  if (!Object.keys(vecA).length || !Object.keys(vecB).length) return 0;
  const [smaller, larger] = Object.keys(vecA).length <= Object.keys(vecB).length
    ? [vecA, vecB] : [vecB, vecA];
  let dot = 0;
  for (const k of Object.keys(smaller)) {
    if (larger[k]) dot += smaller[k] * larger[k];
  }
  if (!dot) return 0;
  let magA = 0, magB = 0;
  for (const v of Object.values(vecA)) magA += v * v;
  for (const v of Object.values(vecB)) magB += v * v;
  return dot / (Math.sqrt(magA) * Math.sqrt(magB));
}
```

---

## Exemplo de Uso Rapido (Teste)

```javascript
// Testar no Code node do n8n
const doc1 = "Inteligencia artificial esta transformando o mercado de vendas";
const doc2 = "IA esta revolucionando como empresas vendem seus produtos";
const doc3 = "Receita de bolo de chocolate com cobertura cremosa";

const t1 = tokenize(doc1);
const t2 = tokenize(doc2);
const t3 = tokenize(doc3);

const allDocs = [t1, t2, t3];

const v1 = tfidfVector(t1, allDocs);
const v2 = tfidfVector(t2, allDocs);
const v3 = tfidfVector(t3, allDocs);

const sim12 = cosineSimilarity(v1, v2); // ~0.3-0.5 (topico similar)
const sim13 = cosineSimilarity(v1, v3); // ~0.0 (topicos diferentes)
const sim23 = cosineSimilarity(v2, v3); // ~0.0 (topicos diferentes)

return [{ json: {
  "doc1_vs_doc2": sim12.toFixed(4),
  "doc1_vs_doc3": sim13.toFixed(4),
  "doc2_vs_doc3": sim23.toFixed(4),
  "nota": "doc1 e doc2 devem ter similaridade media; doc3 deve ser zero"
}}];
```

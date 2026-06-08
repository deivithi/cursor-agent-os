# Mapeamento ADE (LandingAI) -> doc-extract (Local)

> Referencia: https://github.com/landing-ai/ade-python

## Operacoes

| ADE Method | ADE Endpoint | Local Equivalente | Motor |
|---|---|---|---|
| `client.parse()` | `POST /v1/tools/agentic-document-analysis` | MarkItDown + `chunker.py` | MarkItDown MCP/CLI |
| `client.split()` | `POST /v1/tools/classification` | Claude LLM prompt | Assistente |
| `client.extract()` | `POST /v1/tools/document-extraction` | Claude LLM + JSON schema | Assistente |
| `client.parse_jobs.create()` | `POST /v1/tools/agentic-document-analysis/jobs` | Batch skill / subagente | Batch processing |

## Modelos

| ADE Model | Descricao | Local |
|---|---|---|
| `dpt-2-latest` | Document Parse & Transform | MarkItDown (parse) |
| `split-latest` | Document classification | Claude (split) |
| `extract-latest` | Schema-based extraction | Claude (extract) |

## Tipos de Chunk (ADE -> Local)

| ADE Chunk Type | Local Chunk Type | Deteccao |
|---|---|---|
| `chunkTitle` | `chunkTitle` | Regex `^#{1,6}\s+` |
| `chunkTable` | `chunkTable` | Regex `^\s*\|.+\|\s*$` |
| `chunkFigure` | `chunkFigure` | Regex `^!\[` |
| `chunkText` | `chunkText` | Default (paragrafo) |
| `chunkForm` | `chunkText` | Nao diferenciado |
| `chunkKeyValue` | `chunkText` | Extraido via `extract` |
| `chunkLogo` | `chunkFigure` | Agrupado com figuras |
| `chunkPageHeader` | `chunkTitle` | Agrupado com titulos |
| `chunkPageFooter` | (descartado) | Noise — CALM compression |
| `chunkPageNumber` | (descartado) | Noise — CALM compression |
| `chunkMarginalia` | (descartado) | Noise — CALM compression |
| — | `chunkList` | Regex `^\s*[-*+]` (extra) |
| — | `chunkCode` | Regex `` ^``` `` (extra) |

## Response Shapes

### ParseResponse (ADE)
```json
{
  "chunks": [{ "id": "...", "type": "chunkTable", "markdown": "...", "grounding": { "box": {}, "page": 1 } }],
  "markdown": "...",
  "metadata": { "credit_usage": 0.5, "duration_ms": 1200 },
  "splits": [],
  "grounding": {}
}
```

### ParseResponse (Local)
```json
{
  "chunks": [{ "id": "a1b2c3d4e5f6", "type": "chunkTable", "markdown": "...", "line_start": 10, "line_end": 15 }],
  "markdown": "...",
  "metadata": { "source": "relatorio.pdf", "total_chunks": 12, "chunk_types": { "chunkTable": 3, "chunkText": 7 } }
}
```

> **Diferenca principal:** ADE retorna `grounding` (bounding boxes pixel-level). Local retorna `line_start/line_end` (posicao no markdown). Para extracao de dados, ambos sao equivalentes.

## Utilitarios Absorvidos

| ADE File | Local File | Status |
|---|---|---|
| `src/landingai_ade/lib/schema_utils.py` | `lib/schema_utils.py` | Absorvido (100% Python puro) |
| `src/landingai_ade/lib/url_utils.py` | Nao necessario | MarkItDown aceita URLs nativamente |

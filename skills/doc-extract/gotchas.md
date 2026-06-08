# Gotchas — doc-extract

## Parse

| Problema | Causa | Solucao |
|----------|-------|---------|
| PDF sem texto extraido | PDF escaneado (imagem, sem text layer) | Verificar `MARKITDOWN_ENABLE_PLUGINS=true` para OCR |
| Encoding quebrado no Windows | stdout usa cp1252 | Usar `chcp 65001` ou redirecionar para arquivo |
| Tabelas desalinhadas | Celulas mescladas em XLSX | Pre-processar removendo merges antes de converter |
| Chunks vazios no output | Linhas em branco excessivas no markdown | O chunker ja filtra — mas documentos com muitas paginas vazias podem gerar noise |

## Split

| Problema | Causa | Solucao |
|----------|-------|---------|
| Classificacao errada | Regras ambiguas ou documento sem marcadores claros | Melhorar as regras com exemplos e criterios mais especificos |
| Secoes cortadas no meio | Documento sem headings ou separadores | Usar split por pagina (`split: "page"`) como fallback |

## Extract

| Problema | Causa | Solucao |
|----------|-------|---------|
| JSON nao conforma ao schema | Markdown ambiguo ou schema muito complexo | Simplificar schema, adicionar `description` nos campos Pydantic |
| Campos ausentes | Dado nao existe no documento | Schema deve ter campos `Optional` para dados que podem faltar |
| `pydantic_to_json_schema` falha | Classe nao e BaseModel | Verificar heranca: `class X(BaseModel)` |

## Versus ADE Pago

| Feature ADE | Nosso equivalente | Diferenca |
|---|---|---|
| Bounding boxes (coordenadas fisicas) | Nao temos | Nao necessario para 99% dos use cases de extracao |
| Modelos proprietarios DPT-2 | MarkItDown + Claude | Qualidade equivalente ou superior para texto; ADE pode ser melhor para layout analysis complexo |
| Async jobs com webhook | Batch skill + subagentes | Mesma funcionalidade, abordagem diferente |
| Credit usage tracking | Nao aplicavel | Zero custo = sem creditos |

---
name: doc-extract
description: >
  Extração agentic de documentos: parse (documento → markdown + chunks tipados),
  split (classificar e separar seções por regras), extract (markdown + JSON schema → dados estruturados).
  Zero custo — usa MarkItDown + Claude. Paridade ~95% com LandingAI ADE.
domain: document-processing
subdomain: agentic-extraction
version: 1.0.0
author: deivithi
license: Apache-2.0
tags:
  - document-extraction
  - pdf
  - ocr
  - structured-data
  - pydantic
  - json-schema
  - markitdown
  - parse
  - split
  - extract
  - ade
  - zero-cost
---

# Doc-Extract — Extração Agentic de Documentos (Zero Custo)

> **"MarkItDown converte. Claude extrai. Você não paga nada."**
>
> Paridade ~95% com LandingAI ADE ($$$) usando ferramentas 100% gratuitas.

## File Structure
- `SKILL.md` — Você está aqui. Workflow completo com 3 níveis.
- `lib/schema_utils.py` — `pydantic_to_json_schema()` para gerar schemas de extração.
- `lib/chunker.py` — Chunking heurístico de markdown em tipos (table, figure, text, title, list, code).
- `gotchas.md` — Armadilhas e edge cases conhecidos.
- `references/ade-mapping.md` — Mapeamento completo ADE pago → equivalente local.

## Related Skills
- `markitdown` — Motor de parse (documento → markdown). Dependência direta.
- `batch-processing` — Para processar múltiplos documentos em paralelo.
- `universal-docs` — Para conversão entre formatos (Pandoc + Typst).
- `minimax-pdf` — Para criar PDFs com design visual.

---

## 3 Operações

| Operação | Input | Output | Motor |
|----------|-------|--------|-------|
| **parse** | Documento (PDF, DOCX, XLSX, imagem...) | Markdown + chunks tipados | MarkItDown |
| **split** | Markdown + regras de classificação | Seções classificadas | Claude LLM |
| **extract** | Markdown + JSON Schema (Pydantic) | Dados estruturados key-value | Claude LLM |

---

## 📘 Nível 1 — Uso Rápido

### Parse — Documento → Markdown + Chunks

```bash
# Via CLI
markitdown documento.pdf > documento.md

# Via MCP (dentro do Claude Code)
# Tool: convert_to_markdown(uri="file:///C:/caminho/documento.pdf")
```

Após obter o markdown, usar o chunker para dividir em blocos tipados:

```python
from pathlib import Path
import sys
sys.path.insert(0, str(Path(".claude/skills/doc-extract/lib")))
from chunker import chunk_markdown

md_text = Path("documento.md").read_text(encoding="utf-8")
result = chunk_markdown(md_text, source="documento.pdf")

for chunk in result.chunks:
    print(f"[{chunk.type}] L{chunk.line_start}-{chunk.line_end}: {chunk.markdown[:80]}...")
```

### Split — Classificar Seções

Pedir ao assistente com regras claras:

```
Classifique as seções deste markdown nas seguintes categorias:
- "fatura": seções que contêm dados de cobrança, valores, datas de vencimento
- "contrato": seções com termos legais, cláusulas, assinaturas
- "anexo": seções com tabelas de dados técnicos ou especificações

Retorne JSON: { "splits": [{ "classification": "...", "pages": [...], "markdowns": ["..."] }] }
```

### Extract — Dados Estruturados com Schema

```python
from pydantic import BaseModel, Field
import sys
from pathlib import Path
sys.path.insert(0, str(Path(".claude/skills/doc-extract/lib")))
from schema_utils import pydantic_to_json_schema

class Fatura(BaseModel):
    numero: str = Field(description="Número da fatura")
    data_emissao: str = Field(description="Data de emissão (DD/MM/YYYY)")
    valor_total: float = Field(description="Valor total em reais")
    itens: list[str] = Field(description="Lista de itens cobrados")

schema = pydantic_to_json_schema(Fatura)
print(schema)
# Usar o schema como instrução para o assistente extrair dados do markdown
```

Pedir ao assistente:

```
Extraia os dados deste markdown conforme o schema JSON abaixo.
Retorne APENAS um JSON válido que conforma ao schema.

Schema: {schema gerado acima}

Markdown:
{conteúdo do documento}
```

---

## 🔧 Nível 2 — Pipeline Completo

### Pipeline: PDF → Parse → Split → Extract

```python
"""
Pipeline completo de extração agentic de documentos.
Roda localmente, zero custo.
"""
import json
import subprocess
import sys
from pathlib import Path
from pydantic import BaseModel, Field

sys.path.insert(0, str(Path(".claude/skills/doc-extract/lib")))
from chunker import chunk_markdown
from schema_utils import pydantic_to_json_schema


# === 1. PARSE ===
def parse_document(file_path: str) -> dict:
    """Converte documento para markdown + chunks tipados."""
    result = subprocess.run(
        ["markitdown", file_path],
        capture_output=True, text=True, encoding="utf-8"
    )
    if result.returncode != 0:
        raise RuntimeError(f"MarkItDown falhou: {result.stderr}")

    md_text = result.stdout
    chunked = chunk_markdown(md_text, source=file_path)
    return chunked.to_dict()


# === 2. SPLIT (preparar prompt para Claude) ===
def build_split_prompt(markdown: str, rules: dict) -> str:
    """Gera prompt de classificação para o assistente."""
    rules_text = json.dumps(rules, ensure_ascii=False, indent=2)
    return f"""Classifique as seções do markdown abaixo nas categorias definidas.

## Regras de Classificação
{rules_text}

## Formato de Saída
Retorne APENAS JSON válido:
{{
  "splits": [
    {{
      "classification": "nome_da_categoria",
      "identifier": "identificador_único",
      "markdowns": ["conteúdo_markdown_da_seção"],
      "pages": [1, 2]
    }}
  ]
}}

## Markdown do Documento
{markdown}"""


# === 3. EXTRACT (preparar prompt para Claude) ===
def build_extract_prompt(markdown: str, schema_json: str) -> str:
    """Gera prompt de extração estruturada para o assistente."""
    return f"""Extraia os dados do markdown abaixo conforme o JSON Schema fornecido.
Retorne APENAS JSON válido que conforma ao schema. Sem texto extra.

## JSON Schema
{schema_json}

## Markdown do Documento
{markdown}"""


# === Exemplo de uso ===
if __name__ == "__main__":
    # Parse
    doc = parse_document("relatorio.pdf")
    print(f"Chunks: {doc['metadata']['total_chunks']}")
    print(f"Tipos: {doc['metadata']['chunk_types']}")

    # Schema para extração
    class Relatorio(BaseModel):
        titulo: str = Field(description="Título do relatório")
        autor: str = Field(description="Nome do autor")
        data: str = Field(description="Data do relatório")
        resumo: str = Field(description="Resumo executivo")

    schema = pydantic_to_json_schema(Relatorio)
    prompt = build_extract_prompt(doc["markdown"], schema)
    print(f"\nPrompt gerado ({len(prompt)} chars) — enviar ao assistente.")
```

### Integração com n8n

```
Webhook → Download File → Code (markitdown) → Code (chunker) → AI Agent (extract) → Webhook Response
```

```javascript
// n8n Code Node: Parse + Chunk
const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);

const filePath = $input.first().json.filePath;
const { stdout } = await execAsync(`markitdown "${filePath}"`);

// Chunking simples em JS (para n8n)
const chunks = [];
const lines = stdout.split('\n');
let buffer = [];
let currentType = 'chunkText';

for (const line of lines) {
  if (line.match(/^#{1,6}\s+/)) {
    if (buffer.length) chunks.push({ type: currentType, markdown: buffer.join('\n').trim() });
    chunks.push({ type: 'chunkTitle', markdown: line.trim() });
    buffer = [];
    currentType = 'chunkText';
  } else if (line.match(/^\s*\|.+\|\s*$/)) {
    if (currentType !== 'chunkTable' && buffer.length) {
      chunks.push({ type: currentType, markdown: buffer.join('\n').trim() });
      buffer = [];
    }
    currentType = 'chunkTable';
    buffer.push(line);
  } else {
    if (currentType === 'chunkTable' && buffer.length) {
      chunks.push({ type: currentType, markdown: buffer.join('\n').trim() });
      buffer = [];
      currentType = 'chunkText';
    }
    buffer.push(line);
  }
}
if (buffer.length) chunks.push({ type: currentType, markdown: buffer.join('\n').trim() });

return [{
  json: {
    markdown: stdout,
    chunks: chunks.filter(c => c.markdown),
    metadata: { source: filePath, total_chunks: chunks.length }
  }
}];
```

---

## 🏗️ Nível 3 — Padrões Avançados

### Extração em Batch (Múltiplos Documentos)

Usar a skill `batch-processing` para processar uma pasta inteira:

```
Processe todos os PDFs em ./documentos/ usando doc-extract:
1. Parse cada PDF com markitdown
2. Extraia dados com o schema Fatura (numero, data, valor_total, itens)
3. Consolide os resultados em um JSON único
```

### Schema Complexo com Nested Models

```python
from pydantic import BaseModel, Field
from typing import Optional
from schema_utils import pydantic_to_json_schema

class Endereco(BaseModel):
    rua: str = Field(description="Nome da rua com número")
    cidade: str = Field(description="Cidade")
    estado: str = Field(description="Sigla do estado (ex: SP)")
    cep: str = Field(description="CEP no formato XXXXX-XXX")

class Empresa(BaseModel):
    razao_social: str = Field(description="Razão social completa")
    cnpj: str = Field(description="CNPJ no formato XX.XXX.XXX/XXXX-XX")
    endereco: Endereco
    telefone: Optional[str] = Field(None, description="Telefone principal")

class Contrato(BaseModel):
    numero: str = Field(description="Número do contrato")
    data_assinatura: str = Field(description="Data de assinatura")
    contratante: Empresa
    contratada: Empresa
    valor_mensal: float = Field(description="Valor mensal do contrato")
    vigencia_meses: int = Field(description="Duração em meses")
    clausulas_especiais: list[str] = Field(description="Cláusulas especiais ou observações")

# pydantic_to_json_schema resolve todos os $refs automaticamente
schema = pydantic_to_json_schema(Contrato)
# Schema flat, pronto para enviar ao LLM
```

### Compressão CALM Antes da Extração

Para documentos grandes (>50 páginas), aplicar compressão semântica antes de extrair:

```python
def compress_for_extraction(markdown: str, target_fields: list[str]) -> str:
    """
    Remove noise do markdown antes da extração.
    Protocolo CALM: densidade semântica > volume.
    """
    import re
    compressed = markdown
    compressed = re.sub(r'\n{3,}', '\n\n', compressed)        # Colapsar whitespace
    compressed = re.sub(r'^[-=]{3,}$', '', compressed, flags=re.MULTILINE)  # Separadores
    compressed = re.sub(r'<!--[\s\S]*?-->', '', compressed)    # Comentários HTML
    compressed = re.sub(r'^\s*\|[-:| ]+\|\s*$', '', compressed, flags=re.MULTILINE)  # Separadores de tabela vazios

    # Para documentos muito grandes: pedir ao assistente que extraia
    # apenas as seções relevantes antes de rodar extract
    return compressed.strip()
```

### Validação de Output contra Schema

```python
import json
from pydantic import BaseModel, ValidationError

def validate_extraction(raw_json: str, model_class: type[BaseModel]) -> dict:
    """Valida e parseia o JSON extraído contra o modelo Pydantic."""
    try:
        data = json.loads(raw_json)
        validated = model_class.model_validate(data)
        return {"valid": True, "data": validated.model_dump(), "errors": None}
    except json.JSONDecodeError as e:
        return {"valid": False, "data": None, "errors": f"JSON inválido: {e}"}
    except ValidationError as e:
        return {"valid": False, "data": None, "errors": e.errors()}
```

---

## Protocolo de Uso pelo Assistente

Quando o usuário pedir para **extrair dados de documentos**, **parsear PDF**, **classificar seções**, ou **extração estruturada com schema**:

### 1. Parse
1. Converter documento com MarkItDown (MCP `convert_to_markdown` ou CLI `markitdown`)
2. Se pedido chunks tipados: executar `chunker.py` sobre o markdown

### 2. Split (se necessário)
1. Receber regras de classificação do usuário
2. Construir prompt estruturado com as regras
3. Classificar as seções do markdown
4. Retornar JSON com splits classificados

### 3. Extract
1. Receber ou construir schema Pydantic (ou JSON Schema direto)
2. Se Pydantic: usar `pydantic_to_json_schema()` para gerar schema flat
3. Construir prompt de extração com markdown + schema
4. Retornar JSON conformante ao schema
5. Validar output contra o modelo Pydantic

### Decisão Automática
- Documento simples + extração direta → **parse + extract** (pular split)
- Documento multi-tipo (PDF com faturas + contratos misturados) → **parse + split + extract**
- Batch de documentos → **delegar para skill `batch-processing`**

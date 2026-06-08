# MarkItDown — Conversor Universal de Documentos para Markdown

Tarefa solicitada: **$ARGUMENTS**

## Ferramenta

`markitdown` v0.1.5 (Microsoft) — Conversor universal de arquivos para Markdown otimizado para LLMs.
Plugins habilitados: `MARKITDOWN_ENABLE_PLUGINS=true` (variável de ambiente já configurada).
MCP Server: Ativo globalmente no Claude Code.

## Formatos Suportados

| Formato | Extensões | Observações |
|---------|-----------|-------------|
| **Documentos** | `.pdf`, `.docx`, `.pptx`, `.xlsx` | Extrai texto, tabelas, slides |
| **Web** | `.html`, `.htm` | Converte HTML para Markdown limpo |
| **Dados** | `.csv`, `.json`, `.xml` | Estrutura tabulada |
| **Imagens** | `.png`, `.jpg`, `.jpeg`, `.gif`, `.bmp`, `.tiff` | OCR via plugin (requer MARKITDOWN_ENABLE_PLUGINS=true) |
| **Áudio** | `.mp3`, `.wav` | Transcrição via plugin (requer MARKITDOWN_ENABLE_PLUGINS=true) |
| **Compactados** | `.zip` | Extrai e converte conteúdo interno |
| **E-books** | `.epub` | Converte capítulos para Markdown |

---

## 📘 Nível 1 — Uso Rápido via CLI

### Conversão Direta

```bash
# Converter qualquer arquivo para Markdown (saída no stdout)
markitdown documento.pdf
markitdown apresentacao.pptx
markitdown planilha.xlsx
markitdown pagina.html

# Salvar em arquivo
markitdown relatorio.pdf > relatorio.md

# Converter de URL
markitdown https://exemplo.com/arquivo.pdf
```

### Exemplos Práticos

```bash
# PDF de requisitos → Markdown para análise
markitdown requisitos-salesforce.pdf > requisitos.md

# Planilha de comissões → Markdown para revisão
markitdown comissoes-q1.xlsx > comissoes.md

# Apresentação de estratégia → Markdown para ingestão em LLM
markitdown estrategia-cis.pptx > estrategia.md

# Página HTML → Markdown limpo
markitdown https://site.com/artigo.html > artigo.md
```

---

## 🔧 Nível 2 — Python API + MCP

### Python API

```python
from markitdown import MarkItDown

md = MarkItDown()

# Converter arquivo local
result = md.convert("relatorio.pdf")
print(result.text_content)

# Converter de URL
result = md.convert("https://exemplo.com/doc.pdf")
print(result.text_content)

# Salvar resultado
with open("saida.md", "w", encoding="utf-8") as f:
    f.write(result.text_content)
```

### MCP Tool (dentro do Claude Code)

A tool `convert_to_markdown` está disponível via MCP e aceita URIs:

| Esquema URI | Exemplo | Uso |
|-------------|---------|-----|
| `file://` | `file:///C:/Users/PC/docs/relatorio.pdf` | Arquivo local |
| `http://` | `http://site.com/doc.pdf` | URL HTTP |
| `https://` | `https://site.com/doc.pdf` | URL HTTPS |
| `data:` | `data:application/pdf;base64,...` | Dados inline em base64 |

> ⚠️ **No Windows**, caminhos locais usam `file:///C:/caminho/arquivo.ext` (três barras + drive letter).

---

## 🏗️ Nível 3 — Padrões de Integração em Pipelines

### 🔗 Integração com NotebookLM

```bash
# Converter documento → adicionar como source no NotebookLM
markitdown documento-complexo.pdf > temp_source.md
export PYTHONIOENCODING=utf-8 && notebooklm source add ./temp_source.md
```

### 🔗 Integração com n8n

Em **Code Nodes** do n8n para preprocessar documentos antes de chains LLM:

```javascript
// Node: Code (JavaScript)
const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);

const filePath = $input.first().json.filePath;
const { stdout } = await execAsync(`markitdown "${filePath}"`);

return [{ json: { markdown: stdout, source: filePath } }];
```

**Pipeline típico n8n:**
```
Webhook/Trigger → Download File → Code (markitdown) → LLM Chain → Resposta
```

### 🔗 Integração com Aria (Document Ingestion)

```python
from markitdown import MarkItDown
from pathlib import Path

md = MarkItDown()

def ingest_documents(folder: str) -> list[dict]:
    """Pipeline de ingestão: converte todos os docs de uma pasta para Markdown."""
    results = []
    supported = {'.pdf', '.docx', '.pptx', '.xlsx', '.html', '.csv', '.json', '.epub'}

    for file in Path(folder).rglob('*'):
        if file.suffix.lower() in supported:
            try:
                result = md.convert(str(file))
                results.append({
                    'source': str(file),
                    'content': result.text_content,
                    'format': file.suffix
                })
            except Exception as e:
                results.append({
                    'source': str(file),
                    'error': str(e),
                    'format': file.suffix
                })

    return results
```

### 🔗 Pipeline Completo: Documento → LLM → Ação

```bash
# 1. Converter documento
markitdown contrato.pdf > contrato.md

# 2. Usar como contexto no Claude Code (já está em Markdown!)
# O arquivo .md pode ser lido diretamente pelo assistente

# 3. Ou alimentar outro pipeline
markitdown dados.xlsx | python processar_dados.py
```

---

## 🗜️ Princípio CALM — Compressão Semântica Antes de LLM

> 💡 **Fonte:** Paper CALM (arXiv 2510.27688). Cada token enviado a um LLM deve carregar **máxima densidade semântica**. Dados brutos desperdiçam contexto e degradam qualidade.

### Protocolo de Compressão para Pipelines

| Estágio | Ação | Ferramenta |
|---------|------|------------|
| 1. **Converter** | Documento → Markdown bruto | `markitdown` |
| 2. **Comprimir** | Remover boilerplate, headers repetidos, whitespace excessivo | Script/Code Node |
| 3. **Focar** | Extrair apenas as seções relevantes para a tarefa | Prompt de extração |

### Quando aplicar

- **SEMPRE** em pipelines n8n que alimentam LLMs (emails, PDFs, docs → AI chain)
- **SEMPRE** antes de injetar documentos como contexto no Claude Code
- **Especialmente** quando o documento original excede 20% do context window disponível

### Exemplo prático em n8n Code Node

```javascript
// Após markitdown: comprimir antes de enviar ao LLM
const raw = $input.first().json.markdown;
const compressed = raw
  .replace(/\n{3,}/g, '\n\n')           // Colapsar whitespace
  .replace(/^[-=]{3,}$/gm, '')          // Remover separadores decorativos
  .replace(/<!--[\s\S]*?-->/g, '')      // Remover comentários HTML
  .replace(/^\s*\|[-:| ]+\|\s*$/gm, '') // Limpar separadores de tabela vazios
  .trim();
return [{ json: { content: compressed, tokens_saved: raw.length - compressed.length } }];
```

> **Regra de ouro (CALM):** *Se o documento tem 100 páginas mas a resposta depende de 3, extraia as 3 antes de enviar. Densidade > Volume.*

---

## ⚠️ Gotchas & Armadilhas

| Problema | Causa | Solução |
|----------|-------|---------|
| PDF sem texto extraído | PDF é imagem escaneada (não tem text layer) | Usar plugin OCR: garantir `MARKITDOWN_ENABLE_PLUGINS=true` |
| Encoding quebrado no Windows | stdout do Windows usa cp1252 | Redirecionar com `> arquivo.md` ou usar `chcp 65001` antes |
| Tabelas desalinhadas de XLSX | Células mescladas ou formatação complexa | Pré-processar a planilha removendo merges antes de converter |
| Arquivo ZIP com muitos arquivos | Processa todos os arquivos internos | Filtrar antes: extrair só o que precisa e converter individualmente |
| Imagens sem OCR | Plugin não ativado | Verificar: `echo $MARKITDOWN_ENABLE_PLUGINS` deve retornar `true` |
| PPTX com imagens embutidas | Imagens dentro dos slides não são transcritas sem OCR plugin | Habilitar plugins para OCR automático das imagens dos slides |
| Saída muito grande para LLM | Documento extenso gera Markdown além do context window | Dividir o documento antes ou truncar a saída |

## 🔍 Verificação Rápida

```bash
# Verificar instalação
markitdown --version

# Verificar plugins habilitados
echo $MARKITDOWN_ENABLE_PLUGINS

# Teste rápido de conversão
echo "teste" > /tmp/test.html && markitdown /tmp/test.html
```

## Protocolo de Uso

### 1. Identificar o formato do arquivo
Verificar a extensão e confirmar que está na lista de formatos suportados.

### 2. Escolher o método adequado

| Contexto | Método Recomendado |
|----------|-------------------|
| Conversão rápida e única | CLI: `markitdown arquivo.ext` |
| Dentro de script Python | API: `MarkItDown().convert()` |
| Dentro do Claude Code (MCP ativo) | MCP: `convert_to_markdown(uri)` |
| Pipeline n8n | Code Node com `exec('markitdown ...')` |

### 3. Validar a saída
- Verificar se o texto foi extraído corretamente
- Confirmar que tabelas estão legíveis
- Checar encoding (especialmente no Windows)

### 4. Integrar no destino
- NotebookLM: adicionar como source
- LLM Chain: usar como contexto
- Arquivo: salvar com extensão `.md`

## Segurança

- MarkItDown processa arquivos **localmente** — nenhum dado é enviado para servidores externos
- Arquivos convertidos ficam apenas na máquina local
- Para URLs (http/https), o download é feito localmente antes da conversão
- Cuidado com arquivos ZIP de fontes não confiáveis — podem conter payloads maliciosos

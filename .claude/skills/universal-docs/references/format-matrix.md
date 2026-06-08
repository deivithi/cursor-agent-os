# Matriz de Formatos — Pandoc + Typst

## Pandoc: Formatos de Entrada (Input)

| Formato | Extensão | Qualidade de Parsing |
|---------|----------|---------------------|
| Markdown (CommonMark, GFM, Pandoc) | .md | ⭐⭐⭐⭐⭐ |
| HTML | .html | ⭐⭐⭐⭐ |
| LaTeX | .tex | ⭐⭐⭐⭐ |
| DOCX (Word) | .docx | ⭐⭐⭐⭐ |
| EPUB | .epub | ⭐⭐⭐⭐ |
| reStructuredText | .rst | ⭐⭐⭐⭐ |
| Org-mode | .org | ⭐⭐⭐ |
| MediaWiki | .wiki | ⭐⭐⭐ |
| PPTX (PowerPoint) | .pptx | ⭐⭐ |
| ODT (LibreOffice) | .odt | ⭐⭐⭐ |
| Jupyter Notebook | .ipynb | ⭐⭐⭐ |
| CSV (via filter) | .csv | ⭐⭐ |

## Pandoc: Formatos de Saída (Output)

| Formato | Extensão | Qualidade de Output |
|---------|----------|---------------------|
| PDF (via Typst) | .pdf | ⭐⭐⭐⭐⭐ |
| PDF (via LaTeX) | .pdf | ⭐⭐⭐⭐⭐ |
| DOCX | .docx | ⭐⭐⭐⭐ |
| HTML standalone | .html | ⭐⭐⭐⭐⭐ |
| EPUB | .epub | ⭐⭐⭐⭐ |
| PPTX | .pptx | ⭐⭐⭐ |
| LaTeX | .tex | ⭐⭐⭐⭐⭐ |
| Typst | .typ | ⭐⭐⭐⭐ |
| Markdown | .md | ⭐⭐⭐⭐⭐ |
| reStructuredText | .rst | ⭐⭐⭐⭐ |
| Man page | .1 | ⭐⭐⭐⭐ |
| RTF | .rtf | ⭐⭐⭐ |
| reveal.js | .html | ⭐⭐⭐⭐ |

## Typst: Capacidades Nativas

| Feature | Suporte |
|---------|---------|
| Tipografia profissional | ⭐⭐⭐⭐⭐ |
| Matemática (LaTeX-style) | ⭐⭐⭐⭐⭐ |
| Tabelas | ⭐⭐⭐⭐ |
| Figuras e imagens | ⭐⭐⭐⭐ |
| Código com syntax highlighting | ⭐⭐⭐⭐⭐ |
| Cabeçalho/Rodapé | ⭐⭐⭐⭐ |
| Colunas | ⭐⭐⭐⭐ |
| TOC (sumário) | ⭐⭐⭐⭐ |
| Bibliografia | ⭐⭐⭐⭐ |
| Templates reutilizáveis | ⭐⭐⭐⭐⭐ |
| Velocidade de compilação | ⭐⭐⭐⭐⭐ (instantânea) |
| Packages (registry) | ⭐⭐⭐ (crescendo) |

## Caminhos de Conversão Recomendados

| De → Para | Melhor Caminho |
|-----------|---------------|
| Markdown → PDF profissional | `pandoc --pdf-engine=typst` |
| Markdown → DOCX | `pandoc -o output.docx` |
| DOCX → Markdown | `pandoc -o output.md` |
| HTML → PDF | `pandoc --pdf-engine=typst` |
| Markdown → EPUB | `pandoc --metadata title="..."` |
| Markdown → Slides HTML | Usar `markdown-slides` (Marp) |
| Markdown → PPTX | `pandoc -o output.pptx` |
| Typst → PDF | `typst compile` (direto) |
| LaTeX → DOCX | `pandoc -o output.docx` |
| Qualquer → Markdown | `pandoc -o output.md` |

## Fontes

- Pandoc: https://pandoc.org/ (43K⭐)
- Typst: https://typst.app/ (52K⭐)
- Pandoc Manual: https://pandoc.org/MANUAL.html
- Typst Docs: https://typst.app/docs/

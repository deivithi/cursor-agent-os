---
name: universal-docs
description: >
  Pipeline universal de documentos: qualquer formato de entrada → qualquer formato de saída
  com tipografia profissional. Pandoc (43K⭐) para conversão + Typst (52K⭐) para tipografia.
  Markdown, DOCX, HTML, LaTeX, PPTX, EPUB → PDF profissional, DOCX, HTML, slides e mais.
domain: document-production
subdomain: conversion-pipeline
version: 1.0.0
author: deivithi
license: Apache-2.0
tags:
  - pandoc
  - typst
  - document-conversion
  - pdf
  - typesetting
  - markdown
  - latex
  - professional-documents
---

# Universal Docs — Qualquer Formato → Qualquer Formato

> **"Pandoc converte. Typst embeleza. Você entrega."**

## 📁 File Structure
- `SKILL.md` — Você está aqui. Workflow completo.
- `templates/` — Templates Typst profissionais prontos para uso.
- `references/format-matrix.md` — Matriz completa de formatos suportados.
- `gotchas.md` — ⚠️ Problemas conhecidos.

## 🔗 Related Skills
- `minimax-pdf` — Para PDFs com design visual rico (cover pages, tokens de cor). Use minimax-pdf quando APARÊNCIA importa.
- `markitdown` — Para converter docs → Markdown otimizado para LLMs (pipeline de input).
- `markdown-slides` — Para apresentações Markdown via Marp (mais simples que Pandoc slides).
- `docx` — Para criar/editar DOCX programaticamente via docx-js (mais controle que Pandoc).
- `pptx-generator` — Para PPTX com PptxGenJS (mais controle que Pandoc slides).

---

## 1. Quando Usar Cada Ferramenta

| Necessidade | Ferramenta | Por quê |
|-------------|-----------|---------|
| Converter entre formatos (MD→DOCX, HTML→PDF, etc.) | **Pandoc** | Conversor universal, 40+ formatos |
| PDF com tipografia profissional (paper, relatório, manual) | **Typst** | Tipografia LaTeX-quality, sintaxe simples |
| PDF com design visual (cover, cores, branding) | `minimax-pdf` | Design system com tokens |
| Slides rápidos | `markdown-slides` (Marp) | Mais simples, Markdown puro |
| DOCX programático | `docx` skill | Controle total sobre XML |
| Doc → Markdown para LLM | `markitdown` | Otimizado para pipelines IA |

**Regra de ouro:** Pandoc = conversão. Typst = tipografia. minimax-pdf = design. Não competem — complementam.

---

## 2. Pandoc — Conversão Universal

### Instalação
```bash
# Já instalado via winget
pandoc --version
```

### Conversões Mais Comuns

```bash
# Markdown → PDF (via LaTeX ou Typst)
pandoc input.md -o output.pdf

# Markdown → PDF via Typst (RECOMENDADO — mais rápido, sem LaTeX)
pandoc input.md -o output.pdf --pdf-engine=typst

# Markdown → DOCX
pandoc input.md -o output.docx

# Markdown → HTML standalone
pandoc input.md -o output.html --standalone --embed-resources

# DOCX → Markdown
pandoc input.docx -o output.md

# HTML → Markdown
pandoc input.html -o output.md

# Markdown → PPTX
pandoc input.md -o output.pptx

# Markdown → EPUB
pandoc input.md -o output.epub --metadata title="Meu Livro"

# LaTeX → DOCX
pandoc input.tex -o output.docx

# Multiple inputs → single output
pandoc chapter1.md chapter2.md chapter3.md -o book.pdf --pdf-engine=typst
```

### Pandoc com Metadata

```yaml
---
title: "Título do Documento"
author: "Deivithi"
date: "2026-03-23"
lang: pt-BR
toc: true
toc-depth: 3
numbersections: true
geometry: margin=2.5cm
fontsize: 12pt
linestretch: 1.5
---
```

### Pandoc com Template Custom

```bash
# Listar templates disponíveis
pandoc --print-default-template=html > template.html

# Usar template customizado
pandoc input.md -o output.html --template=template.html

# Usar template Typst customizado
pandoc input.md -o output.pdf --pdf-engine=typst --template=template.typ
```

### Filtros Pandoc (Processamento Intermediário)

```bash
# Lua filter para transformar conteúdo
pandoc input.md -o output.pdf --lua-filter=filter.lua

# Exemplo de Lua filter: capitalizar títulos
# filter.lua:
# function Header(el)
#   el.content = pandoc.walk_inline(el.content, {
#     Str = function(s) return pandoc.Str(s.text:upper()) end
#   })
#   return el
# end
```

---

## 3. Typst — Tipografia Profissional

### Instalação
```bash
# Já instalado via winget
typst --version
```

### Sintaxe Básica

```typst
// Título e metadata
#set document(title: "Meu Relatório", author: "Deivithi")
#set page(paper: "a4", margin: 2.5cm)
#set text(font: "New Computer Modern", size: 12pt, lang: "pt")
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1")

// Conteúdo
= Título Principal

== Subtítulo

Texto normal com *negrito* e _itálico_.

=== Sub-subtítulo

- Item 1
- Item 2
  - Sub-item

+ Item numerado 1
+ Item numerado 2

#figure(
  table(
    columns: 3,
    [*Nome*], [*Cargo*], [*Área*],
    [Deivithi], [PO Salesforce], [Vendas],
  ),
  caption: [Equipe do projeto],
)
```

### Compilar Typst

```bash
# Typst → PDF
typst compile documento.typ

# Com watch mode (auto-recompila)
typst watch documento.typ

# Output customizado
typst compile documento.typ output/relatorio.pdf

# Especificar fonte
typst compile documento.typ --font-path ./fonts/
```

### Recursos Avançados

```typst
// Importar package (Typst tem registry próprio)
#import "@preview/charged-ieee:0.1.0": ieee

// Código com syntax highlighting
#raw("let x = 42;", lang: "javascript", block: true)

// Matemática (LaTeX-like)
$ sum_(i=0)^n x_i = integral_0^infinity f(x) dif x $

// Colunas
#columns(2)[
  Texto na coluna 1.
  #colbreak()
  Texto na coluna 2.
]

// Cabeçalho e rodapé
#set page(
  header: [_Relatório Confidencial_ #h(1fr) Página #counter(page).display()],
  footer: [Febracis © 2026],
)
```

---

## 4. Templates Typst Profissionais

### Template: Relatório Corporativo

```typst
// Salvar como templates/report.typ
#let report(
  title: "",
  author: "",
  date: datetime.today(),
  company: "Febracis",
  confidential: false,
  body
) = {
  set document(title: title, author: author)
  set page(paper: "a4", margin: (top: 3cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm))
  set text(font: "New Computer Modern", size: 11pt, lang: "pt")
  set par(justify: true, leading: 0.65em)
  set heading(numbering: "1.1")

  // Cover page
  page(margin: 0pt)[
    #rect(width: 100%, height: 40%, fill: rgb("#1a365d"))[
      #align(center + horizon)[
        #text(size: 28pt, weight: "bold", fill: white)[#title]
        #v(1em)
        #text(size: 14pt, fill: rgb("#90cdf4"))[#author]
        #v(0.5em)
        #text(size: 12pt, fill: rgb("#90cdf4"))[#date.display("[day]/[month]/[year]")]
      ]
    ]
    #v(1fr)
    #align(center)[
      #text(size: 16pt, fill: rgb("#1a365d"))[#company]
      #if confidential [
        #v(1em)
        #text(size: 10pt, fill: red)[⚠ CONFIDENCIAL]
      ]
    ]
    #v(2cm)
  ]

  // TOC
  outline(indent: auto, depth: 3)
  pagebreak()

  // Body
  set page(
    header: [
      #text(size: 9pt, fill: gray)[#title #h(1fr) #company]
      #line(length: 100%, stroke: 0.5pt + gray)
    ],
    footer: [
      #line(length: 100%, stroke: 0.5pt + gray)
      #text(size: 9pt, fill: gray)[
        #if confidential [Confidencial] else [Interno]
        #h(1fr)
        Página #counter(page).display() de #locate(loc => counter(page).final(loc).first())
      ]
    ],
  )

  body
}

// Uso:
// #show: report.with(
//   title: "Auditoria de Leads Q1 2026",
//   author: "Deivithi",
//   company: "Febracis",
//   confidential: true,
// )
```

### Template: Paper Acadêmico

```typst
// Salvar como templates/paper.typ
#let paper(
  title: "",
  authors: (),
  abstract: [],
  keywords: (),
  body
) = {
  set document(title: title, author: authors.map(a => a.name))
  set page(paper: "a4", margin: 2.5cm)
  set text(font: "New Computer Modern", size: 11pt, lang: "pt")
  set par(justify: true, first-line-indent: 1.25cm)
  set heading(numbering: "1.1")

  // Title block
  align(center)[
    #text(size: 18pt, weight: "bold")[#title]
    #v(1em)
    #for author in authors [
      #text(size: 12pt)[#author.name]
      #if "affiliation" in author [ \ #text(size: 10pt, fill: gray)[#author.affiliation]]
      #v(0.5em)
    ]
  ]

  // Abstract
  v(1em)
  block(inset: (left: 2cm, right: 2cm))[
    #text(weight: "bold")[Resumo:]
    #abstract
    #if keywords.len() > 0 [
      \ #text(weight: "bold")[Palavras-chave:] #keywords.join(", ")
    ]
  ]
  v(1em)

  // Body with two columns
  columns(1, body)
}
```

### Template: Manual Técnico

```typst
// Salvar como templates/manual.typ
#let manual(
  title: "",
  version: "1.0",
  author: "",
  body
) = {
  set document(title: title, author: author)
  set page(paper: "a4", margin: 2.5cm)
  set text(font: "Fira Sans", size: 10.5pt, lang: "pt")
  set par(justify: true)
  set heading(numbering: "1.1.1")
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    text(size: 20pt, fill: rgb("#2563eb"))[#it]
  }

  // Cover
  page(margin: 0pt)[
    #rect(width: 100%, height: 100%, fill: rgb("#1e293b"))[
      #align(center + horizon)[
        #text(size: 32pt, weight: "bold", fill: white)[#title]
        #v(1em)
        #text(size: 14pt, fill: rgb("#94a3b8"))[Versão #version]
        #v(0.5em)
        #text(size: 12pt, fill: rgb("#94a3b8"))[#author]
      ]
    ]
  ]

  outline(indent: auto, depth: 3)
  pagebreak()
  body
}
```

---

## 5. Pipeline Completo: Pandoc + Typst

### Markdown → PDF Profissional (melhor caminho)

```bash
# Opção 1: Pandoc direto com engine Typst (simples)
pandoc relatorio.md -o relatorio.pdf --pdf-engine=typst

# Opção 2: Pandoc → Typst intermediário → PDF (mais controle)
pandoc relatorio.md -o relatorio.typ
# Editar relatorio.typ se necessário
typst compile relatorio.typ

# Opção 3: Markdown com template Typst custom
pandoc relatorio.md -o relatorio.pdf \
  --pdf-engine=typst \
  --template=templates/report.typ
```

### DOCX → PDF Profissional

```bash
# DOCX → Markdown → Typst → PDF
pandoc input.docx -o intermediate.md
pandoc intermediate.md -o output.pdf --pdf-engine=typst
```

### HTML → EPUB → PDF

```bash
# HTML → EPUB
pandoc site.html -o book.epub --metadata title="Meu Livro"

# EPUB → PDF
pandoc book.epub -o book.pdf --pdf-engine=typst
```

---

## 6. Anti-Patterns

| ❌ Anti-Pattern | ✅ Correto |
|----------------|-----------|
| Usar Pandoc para PDFs bonitos (output básico) | Pandoc converte, Typst embeleza. Usar `--pdf-engine=typst` |
| Instalar LaTeX inteiro para gerar PDF | Typst substitui LaTeX para 95% dos casos (5MB vs 2GB) |
| Converter PPTX→PDF via Pandoc (perde formatação) | Para PPTX→PDF usar LibreOffice CLI ou manter no PPTX |
| Escrever templates Typst muito complexos | Começar simples, iterar. Templates devem ser reutilizáveis |
| Usar minimax-pdf quando só precisa converter formato | minimax-pdf = design. universal-docs = conversão/tipografia |
| Ignorar metadata no Markdown (título, autor, data) | YAML frontmatter economiza configuração manual |

---

## 7. Referência Rápida

```
┌─────────────┐     ┌─────────┐     ┌──────────┐
│   INPUT      │     │ PANDOC  │     │  OUTPUT  │
│              │     │         │     │          │
│ • Markdown   │────▶│ AST     │────▶│ • PDF    │
│ • DOCX       │     │ (inter- │     │ • DOCX   │
│ • HTML       │     │  médio) │     │ • HTML   │
│ • LaTeX      │     │         │     │ • EPUB   │
│ • EPUB       │     └────┬────┘     │ • PPTX   │
│ • RST        │          │          │ • LaTeX  │
│ • Org-mode   │     ┌────▼────┐     │ • Typst  │
│ • MediaWiki  │     │  TYPST  │     │ • RTF    │
│ • PPTX       │     │ engine  │     │ • Man    │
└─────────────┘     └────┬────┘     └──────────┘
                         │
                    ┌────▼────┐
                    │  PDF    │
                    │ (tipo-  │
                    │ grafia  │
                    │ profis- │
                    │ sional) │
                    └─────────┘
```

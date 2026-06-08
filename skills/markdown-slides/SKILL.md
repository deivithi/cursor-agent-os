---
name: markdown-slides
description: >
  Pipeline CLI: Markdown → PDF/PPTX/HTML para apresentações rápidas via Marp.
  Escreva slides em Markdown com directives, temas, speaker notes e code highlighting.
  Output: HTML interativo, PDF print-ready, PPTX editável.
domain: visualization
subdomain: presentations
version: 1.0.0
author: deivithi
sources:
  - marp-team/marp-cli (npm)
  - marp-team/marp (11K⭐)
tags:
  - slides
  - presentations
  - markdown
  - marp
  - PDF
  - PPTX
---

# 🎤 Markdown Slides — Apresentações via Marp

> **"Slides = Markdown + directives. Sem mouse, sem drag-and-drop, sem sofrimento."**
> Marp converte Markdown em apresentações profissionais — HTML, PDF ou PPTX.

## 📁 File Structure
- `SKILL.md` — Você está aqui. Referência completa.
- `gotchas.md` — ⚠️ Problemas conhecidos.

## 🔗 Related Skills
- `mermaid-diagrams` — Mermaid integra nativamente em slides Marp (code blocks renderizados)
- `data-charts` — Export gráficos como PNG → inserir em slides como imagem
- `minimax-pdf` — Para documentos PDF complexos com cover design, use minimax-pdf
- `pptx-generator` — Para PPTX com controle granular de layouts, use pptx-generator
- `frontend-slides` — Para apresentações HTML animation-rich (não-Marp), use frontend-slides

---

## 1. Setup

### Instalação
```bash
npm install -g @marp-team/marp-cli
```

### Verificar
```bash
marp --version
```

---

## 2. Conversão

| Comando | Output |
|---------|--------|
| `marp slides.md` | HTML standalone |
| `marp slides.md --pdf` | PDF |
| `marp slides.md --pptx` | PowerPoint |
| `marp slides.md --images png` | PNG por slide |
| `marp slides.md --notes` | Notas do apresentador (TXT) |
| `marp slides.md -o output/deck.pdf` | Output em path específico |

### Opções úteis
```bash
# Watch mode (auto-reload)
marp slides.md -w

# Server mode (localhost com preview)
marp slides.md -s

# Custom theme
marp slides.md --theme ./custom-theme.css --pdf

# Múltiplos arquivos
marp *.md --pdf

# HTML com transições
marp slides.md --html
```

---

## 3. Anatomia de um Slide Deck

```markdown
---
marp: true
theme: default
paginate: true
header: "Company Name"
footer: "Confidential — March 2026"
size: 16:9
style: |
  section {
    font-family: 'Inter', system-ui, sans-serif;
  }
  h1 {
    color: #1a3a5c;
  }
---

# Título da Apresentação

Subtítulo — Autor — Data

---

## Slide 2 — Agenda

1. Introdução
2. Análise
3. Resultados
4. Próximos passos

---

## Slide 3 — Com imagem

![bg right:40%](https://picsum.photos/800/600)

### Insights principais

- Ponto 1
- Ponto 2
- Ponto 3

---

## Slide 4 — Com código

```python
def calcular_comissao(vendas, taxa):
    return vendas * taxa
```

---

## Slide 5 — Com tabela

| Região | Q1 | Q2 | Q3 |
|--------|-----|-----|-----|
| Norte  | 120 | 145 | 132 |
| Sul    | 98  | 110 | 125 |

---

<!-- _class: lead -->

# Obrigado!

Perguntas?
```

---

## 4. Directives

### Global (front-matter)

| Directive | Descrição | Exemplo |
|-----------|-----------|---------|
| `marp: true` | **Obrigatório** — ativa o modo Marp | `marp: true` |
| `theme` | Tema visual | `theme: gaia` |
| `paginate` | Números de página | `paginate: true` |
| `header` | Cabeçalho em todas as páginas | `header: "Title"` |
| `footer` | Rodapé em todas as páginas | `footer: "Footer text"` |
| `size` | Proporção do slide | `size: 16:9` ou `4:3` |
| `style` | CSS customizado inline | Bloco YAML `style: \|` |
| `backgroundColor` | Cor de fundo global | `backgroundColor: #1a1a2e` |
| `color` | Cor de texto global | `color: white` |

### Local (por slide, via HTML comment)

```markdown
<!-- _backgroundColor: #1a1a2e -->
<!-- _color: white -->
<!-- _class: lead -->
<!-- _paginate: false -->
<!-- _header: "" -->
```

---

## 5. Temas Built-in

| Tema | Descrição | Visual |
|------|-----------|--------|
| `default` | Limpo, branco, minimalista | Fundo branco, texto escuro |
| `gaia` | Colorido, fundo com cor | Fundo azul-escuro ou amarelo |
| `uncover` | Sem decoração, foco no conteúdo | Ultra-minimalista |

### Classes especiais

| Classe | Efeito |
|--------|--------|
| `lead` | Centraliza tudo (título) |
| `invert` | Inverte cores (dark mode) |

```markdown
<!-- _class: lead -->
# Título Centralizado

<!-- _class: invert -->
## Slide com fundo escuro
```

---

## 6. Imagens

### Sintaxe de Imagens Marp

```markdown
<!-- Imagem normal -->
![](image.png)

<!-- Background (cobre o slide inteiro) -->
![bg](image.png)

<!-- Background lado direito, 40% -->
![bg right:40%](image.png)

<!-- Background lado esquerdo, 50% -->
![bg left:50%](image.png)

<!-- Background com opacidade -->
![bg opacity:0.3](image.png)

<!-- Background com blur -->
![bg blur:5px](image.png)

<!-- Background com fit -->
![bg fit](image.png)

<!-- Múltiplos backgrounds (split) -->
![bg](image1.png)
![bg](image2.png)

<!-- Imagem com tamanho -->
![w:300](image.png)
![h:200](image.png)
```

---

## 7. Tema Customizado (CSS)

```css
/* custom-theme.css */
@import 'default';

section {
  font-family: 'Inter', system-ui, sans-serif;
  background-color: #fafafa;
  color: #1a1a2e;
}

h1 {
  color: #2d5f8a;
  border-bottom: 3px solid #2d5f8a;
  padding-bottom: 0.3em;
}

h2 {
  color: #1a3a5c;
}

section.lead {
  background: linear-gradient(135deg, #1a3a5c 0%, #2d5f8a 100%);
  color: white;
  text-align: center;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

section.lead h1 {
  color: white;
  border-bottom: none;
}

table {
  font-size: 0.85em;
}

table th {
  background-color: #2d5f8a;
  color: white;
}

code {
  background-color: #e8edf3;
  border-radius: 4px;
  padding: 0.1em 0.3em;
}
```

### Usar tema customizado
```bash
marp slides.md --theme custom-theme.css --pdf
```

---

## 8. Speaker Notes

```markdown
## Slide com notas

Conteúdo visível para a audiência.

<!--
Notas do apresentador:
- Mencionar o caso de sucesso X
- Mostrar demo ao vivo aqui
- Perguntar se há dúvidas antes de prosseguir
-->
```

Export notas: `marp slides.md --notes`

---

## 9. Workflow

```
1. DEFINIR conteúdo (bullet points, dados, imagens)
2. ESCOLHER tema (default/gaia/uncover ou customizado)
3. ESCREVER Markdown com directives Marp
4. SALVAR como arquivo .md
5. CONVERTER: marp slides.md --pdf (ou --pptx, ou HTML)
6. SALVAR output em output/
7. INFORMAR caminho para o usuário
```

### Convenções de Output

- **Arquivo Markdown:** `output/slides-{descritivo}.md`
- **Arquivo convertido:** `output/slides-{descritivo}.pdf` (ou .pptx, .html)
- **Encoding:** UTF-8
- **Proporção padrão:** 16:9
- **Paginação:** Sempre ativa (`paginate: true`)
- **Directive obrigatória:** `marp: true` no front-matter

---

## 10. Anti-Patterns

| ❌ Evitar | ✅ Fazer |
|----------|---------|
| Parágrafos longos em slides | Bullet points concisos (max 6 por slide) |
| Mais de 20 slides para 15 min | 1 slide por minuto como regra geral |
| Sem `marp: true` no front-matter | Sempre incluir — sem isso, Marp não ativa |
| Imagens sem dimensão | Usar `bg` directives para controle preciso |
| Slide sem título | Todo slide deve ter heading (h1-h3) |
| Código muito longo | Max 15 linhas por bloco de código |
| Gaia theme em apresentações formais | Usar `default` ou tema customizado |

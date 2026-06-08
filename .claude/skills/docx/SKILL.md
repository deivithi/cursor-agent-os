---
name: docx
description: >
  Create, edit, and analyze Word documents (.docx). Uses docx-js for new documents
  and XML editing for existing ones. Supports tracked changes, comments, tables, images,
  headers/footers, TOC, multi-column layouts, and professional formatting.
  Source: anthropics/skills (MIT).
domain: documents
subdomain: word
version: 1.0.0
author: anthropic
license: MIT
source: https://github.com/anthropics/skills/tree/main/skills/docx
tags:
  - docx
  - word
  - documents
  - office
  - tracked-changes
  - comments
---

# 📄 DOCX — Criação e Edição de Documentos Word

> **Fonte:** [anthropics/skills](https://github.com/anthropics/skills/tree/main/skills/docx) (MIT)

## Related Skills
- `minimax-pdf` — PDFs com design profissional (complementar: PDF vs DOCX)
- `pptx-generator` — Apresentações PowerPoint (complementar: PPTX vs DOCX)
- `markitdown` — Converter DOCX para Markdown

---

## Quick Reference

| Tarefa | Abordagem |
|--------|-----------|
| Ler/analisar conteúdo | `pandoc` ou unpack para XML raw |
| Criar novo documento | `docx-js` (npm) — ver seção Creating |
| Editar documento existente | Unpack → editar XML → repack |

## Dependências

```bash
npm install -g docx    # Criação de novos documentos
# pandoc               # Extração de texto (opcional)
```

---

## Creating New Documents

```javascript
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
        ImageRun, Header, Footer, AlignmentType, PageOrientation,
        LevelFormat, ExternalHyperlink, HeadingLevel, BorderStyle,
        WidthType, ShadingType, PageNumber, PageBreak } = require('docx');
const fs = require('fs');

const doc = new Document({ sections: [{ children: [/* content */] }] });
Packer.toBuffer(doc).then(buffer => fs.writeFileSync("doc.docx", buffer));
```

### Page Size (CRITICAL: defaults to A4)

```javascript
sections: [{
  properties: {
    page: {
      size: { width: 12240, height: 15840 },  // US Letter (DXA: 1440 = 1 inch)
      margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 }
    }
  },
  children: [/* content */]
}]
```

| Paper | Width | Height |
|-------|-------|--------|
| US Letter | 12,240 | 15,840 |
| A4 (default) | 11,906 | 16,838 |

### Styles

```javascript
const doc = new Document({
  styles: {
    default: { document: { run: { font: "Arial", size: 24 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal",
        quickFormat: true,
        run: { size: 32, bold: true, font: "Arial" },
        paragraph: { spacing: { before: 240, after: 240 }, outlineLevel: 0 } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal",
        quickFormat: true,
        run: { size: 28, bold: true, font: "Arial" },
        paragraph: { spacing: { before: 180, after: 180 }, outlineLevel: 1 } },
    ]
  },
  sections: [{ children: [/* ... */] }]
});
```

### Lists (NEVER use unicode bullets)

```javascript
// ✅ CORRETO
numbering: {
  config: [
    { reference: "bullets",
      levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022",
        alignment: AlignmentType.LEFT,
        style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
  ]
}
// Uso:
new Paragraph({ numbering: { reference: "bullets", level: 0 },
  children: [new TextRun("Item")] })
```

### Tables (CRITICAL: dual widths required)

```javascript
const border = { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" };
const borders = { top: border, bottom: border, left: border, right: border };

new Table({
  width: { size: 9360, type: WidthType.DXA },  // SEMPRE DXA, nunca PERCENTAGE
  columnWidths: [4680, 4680],                    // Soma = width da table
  rows: [
    new TableRow({
      children: [
        new TableCell({
          borders,
          width: { size: 4680, type: WidthType.DXA },
          shading: { fill: "D5E8F0", type: ShadingType.CLEAR },  // CLEAR, nunca SOLID
          margins: { top: 80, bottom: 80, left: 120, right: 120 },
          children: [new Paragraph({ children: [new TextRun("Cell")] })]
        })
      ]
    })
  ]
})
```

### Images

```javascript
new Paragraph({
  children: [new ImageRun({
    type: "png",  // OBRIGATÓRIO: png, jpg, jpeg, gif, bmp, svg
    data: fs.readFileSync("image.png"),
    transformation: { width: 200, height: 150 },
    altText: { title: "T", description: "D", name: "N" }
  })]
})
```

### Headers/Footers

```javascript
headers: {
  default: new Header({ children: [
    new Paragraph({ children: [new TextRun("Header")] })
  ] })
},
footers: {
  default: new Footer({ children: [
    new Paragraph({ children: [
      new TextRun("Page "), new TextRun({ children: [PageNumber.CURRENT] })
    ] })
  ] })
}
```

---

## Critical Rules (docx-js)

- **Set page size explicitly** — default é A4
- **Landscape:** passar dimensões portrait + `orientation: PageOrientation.LANDSCAPE`
- **NUNCA usar `\n`** — usar Paragraphs separados
- **NUNCA usar unicode bullets** — usar `LevelFormat.BULLET`
- **PageBreak dentro de Paragraph** — standalone cria XML inválido
- **ImageRun requer `type`** — sempre especificar png/jpg
- **Tables: SEMPRE `WidthType.DXA`** — `PERCENTAGE` quebra no Google Docs
- **Tables: dual widths** — `columnWidths` array E cell `width`, ambos devem bater
- **Usar `ShadingType.CLEAR`** — nunca SOLID para shading de tabelas
- **NUNCA usar tables como dividers** — usar border em Paragraph
- **TOC requer HeadingLevel** — sem custom styles em headings
- **outlineLevel obrigatório** para TOC (0=H1, 1=H2)

---

## Editing Existing Documents

### Step 1: Unpack
```bash
python scripts/office/unpack.py document.docx unpacked/
```

### Step 2: Edit XML
Editar arquivos em `unpacked/word/`. Usar Edit tool (não scripts Python).

### Step 3: Pack
```bash
python scripts/office/pack.py unpacked/ output.docx --original document.docx
```

### Tracked Changes

```xml
<!-- Inserção -->
<w:ins w:id="1" w:author="Claude" w:date="2025-01-01T00:00:00Z">
  <w:r><w:t>texto inserido</w:t></w:r>
</w:ins>

<!-- Deleção -->
<w:del w:id="2" w:author="Claude" w:date="2025-01-01T00:00:00Z">
  <w:r><w:delText>texto deletado</w:delText></w:r>
</w:del>
```

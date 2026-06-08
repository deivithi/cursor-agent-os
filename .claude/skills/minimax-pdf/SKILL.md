---
name: minimax-pdf
description: >
  Use this skill when visual quality and design identity matter for a PDF.
  CREATE (generate from scratch): "make a PDF", "generate a report", "write a proposal",
  "create a resume", "beautiful PDF", "professional document", "cover page",
  "polished PDF", "client-ready document".
  FILL (complete form fields): "fill in the form", "fill out this PDF",
  "complete the form fields", "write values into PDF", "what fields does this PDF have".
  REFORMAT (apply design to an existing doc): "reformat this document", "apply our style",
  "convert this Markdown/text to PDF", "make this doc look good", "re-style this PDF".
  This skill uses a token-based design system: color, typography, and spacing are derived
  from the document type and flow through every page. The output is print-ready.
  Prefer this skill when appearance matters, not just when any PDF output is needed.
license: MIT
metadata:
  version: "1.0"
  category: document-generation
---

# minimax-pdf

Three tasks. One skill.

## Read `design/design.md` before any CREATE or REFORMAT work.

---

## Route table

| User intent | Route | Scripts used |
|---|---|---|
| Generate a new PDF from scratch | **CREATE** | `palette.py` → `cover.py` → `render_cover.js` → `render_body.py` → `merge.py` |
| Fill / complete form fields in an existing PDF | **FILL** | `fill_inspect.py` → `fill_write.py` |
| Reformat / re-style an existing document | **REFORMAT** | `reformat_parse.py` → then full CREATE pipeline |
| Quick PDF from JSON definition (no cover, simpler) | **PDFMAKE** | `render_pdfmake.js` |

**Rule:** when in doubt between CREATE and REFORMAT, ask whether the user has an existing document to start from. If yes → REFORMAT. If no → CREATE.

**Rule:** when the user needs a quick, structured PDF (report, invoice, table-heavy doc) without a design cover → use **PDFMAKE**. When visual identity and cover design matter → use **CREATE**.

---

## Route A: CREATE

Full pipeline — content → design tokens → cover → body → merged PDF.

```bash
bash scripts/make.sh run \
  --title "Q3 Strategy Review" --type proposal \
  --author "Strategy Team" --date "October 2025" \
  --accent "#2D5F8A" \
  --content content.json --out report.pdf
```

**Doc types:** `report` · `proposal` · `resume` · `portfolio` · `academic` · `general` · `minimal` · `stripe` · `diagonal` · `frame` · `editorial` · `magazine` · `darkroom` · `terminal` · `poster`

| Type | Cover pattern | Visual identity |
|---|---|---|
| `report` | `fullbleed` | Dark bg, dot grid, Playfair Display |
| `proposal` | `split` | Left panel + right geometric, Syne |
| `resume` | `typographic` | Oversized first-word, DM Serif Display |
| `portfolio` | `atmospheric` | Near-black, radial glow, Fraunces |
| `academic` | `typographic` | Light bg, classical serif, EB Garamond |
| `general` | `fullbleed` | Dark slate, Outfit |
| `minimal` | `minimal` | White + single 8px accent bar, Cormorant Garamond |
| `stripe` | `stripe` | 3 bold horizontal color bands, Barlow Condensed |
| `diagonal` | `diagonal` | SVG angled cut, dark/light halves, Montserrat |
| `frame` | `frame` | Inset border, corner ornaments, Cormorant |
| `editorial` | `editorial` | Ghost letter, all-caps title, Bebas Neue |
| `magazine` | `magazine` | Warm cream bg, centered stack, hero image, Playfair Display |
| `darkroom` | `darkroom` | Navy bg, centered stack, grayscale image, Playfair Display |
| `terminal` | `terminal` | Near-black, grid lines, monospace, neon green |
| `poster` | `poster` | White bg, thick sidebar, oversized title, Barlow Condensed |

Cover extras (inject into tokens via `--abstract`, `--cover-image`):
- `--abstract "text"` — abstract text block on the cover (magazine/darkroom)
- `--cover-image "url"` — hero image URL/path (magazine, darkroom, poster)

**Color overrides — always choose these based on document content:**
- `--accent "#HEX"` — override the accent color; `accent_lt` is auto-derived by lightening toward white
- `--cover-bg "#HEX"` — override the cover background color

**Accent color selection guidance:**

You have creative authority over the accent color. Pick it from the document's semantic context — title, industry, purpose, audience — not from generic "safe" choices. The accent appears on section rules, callout bars, table headers, and the cover: it carries the document's visual identity.

| Context | Suggested accent range |
|---|---|
| Legal / compliance / finance | Deep navy `#1C3A5E`, charcoal `#2E3440`, slate `#3D4C5E` |
| Healthcare / medical | Teal-green `#2A6B5A`, cool green `#3A7D6A` |
| Technology / engineering | Steel blue `#2D5F8A`, indigo `#3D4F8A` |
| Environmental / sustainability | Forest `#2E5E3A`, olive `#4A5E2A` |
| Creative / arts / culture | Burgundy `#6B2A35`, plum `#5A2A6B`, terracotta `#8A3A2A` |
| Academic / research | Deep teal `#2A5A6B`, library blue `#2A4A6B` |
| Corporate / neutral | Slate `#3D4A5A`, graphite `#444C56` |
| Luxury / premium | Warm black `#1A1208`, deep bronze `#4A3820` |

**Rule:** choose a color that a thoughtful designer would select for this specific document — not the type's default. Muted, desaturated tones work best; avoid vivid primaries. When in doubt, go darker and more neutral.

**content.json block types:**

| Block | Usage | Key fields |
|---|---|---|
| `h1` | Section heading + accent rule | `text` |
| `h2` | Subsection heading | `text` |
| `h3` | Sub-subsection (bold) | `text` |
| `body` | Justified paragraph; supports `<b>` `<i>` markup | `text` |
| `bullet` | Unordered list item (• prefix) | `text` |
| `numbered` | Ordered list item — counter auto-resets on non-numbered blocks | `text` |
| `callout` | Highlighted insight box with accent left bar | `text` |
| `table` | Data table — accent header, alternating row tints | `headers`, `rows`, `col_widths`?, `caption`? |
| `image` | Embedded image scaled to column width | `path`/`src`, `caption`? |
| `figure` | Image with auto-numbered "Figure N:" caption | `path`/`src`, `caption`? |
| `code` | Monospace code block with accent left border | `text`, `language`? |
| `math` | Display math — LaTeX syntax via matplotlib mathtext | `text`, `label`?, `caption`? |
| `chart` | Bar / line / pie chart rendered with matplotlib | `chart_type`, `labels`, `datasets`, `title`?, `x_label`?, `y_label`?, `caption`?, `figure`? |
| `flowchart` | Process diagram with nodes + edges via matplotlib | `nodes`, `edges`, `caption`?, `figure`? |
| `bibliography` | Numbered reference list with hanging indent | `items` [{id, text}], `title`? |
| `divider` | Accent-colored full-width rule | — |
| `caption` | Small muted label | `text` |
| `pagebreak` | Force a new page | — |
| `spacer` | Vertical whitespace | `pt` (default 12) |

**chart / flowchart schemas:**
```json
{"type":"chart","chart_type":"bar","labels":["Q1","Q2","Q3","Q4"],
 "datasets":[{"label":"Revenue","values":[120,145,132,178]}],"caption":"Q results"}

{"type":"flowchart",
 "nodes":[{"id":"s","label":"Start","shape":"oval"},
          {"id":"p","label":"Process","shape":"rect"},
          {"id":"d","label":"Valid?","shape":"diamond"},
          {"id":"e","label":"End","shape":"oval"}],
 "edges":[{"from":"s","to":"p"},{"from":"p","to":"d"},
          {"from":"d","to":"e","label":"Yes"},{"from":"d","to":"p","label":"No"}]}

{"type":"bibliography","items":[
  {"id":"1","text":"Author (Year). Title. Publisher."}]}
```

---

## Route B: FILL

Fill form fields in an existing PDF without altering layout or design.

```bash
# Step 1: inspect
python3 scripts/fill_inspect.py --input form.pdf

# Step 2: fill
python3 scripts/fill_write.py --input form.pdf --out filled.pdf \
  --values '{"FirstName": "Jane", "Agree": "true", "Country": "US"}'
```

| Field type | Value format |
|---|---|
| `text` | Any string |
| `checkbox` | `"true"` or `"false"` |
| `dropdown` | Must match a choice value from inspect output |
| `radio` | Must match a radio value (often starts with `/`) |

Always run `fill_inspect.py` first to get exact field names.

---

## Route C: REFORMAT

Parse an existing document → content.json → CREATE pipeline.

```bash
bash scripts/make.sh reformat \
  --input source.md --title "My Report" --type report --out output.pdf
```

**Supported input formats:** `.md` `.txt` `.pdf` `.json`

---

## Route D: PDFMAKE

Generate PDFs from a **JSON document definition** — LLM-native, no Python required, just Node.js.

**When to use:** Quick structured documents (reports, invoices, tables, proposals) where you don't need a design cover. The LLM generates a JSON object → pdfmake renders it to PDF.

```bash
node scripts/render_pdfmake.js --input doc.json --out output.pdf
node scripts/render_pdfmake.js --input doc.json --out output.pdf --open
```

**Dependency:** `npm install pdfmake` (auto-installed on first run)

### Document Definition Structure

The LLM generates this JSON:

```json
{
  "pageSize": "A4",
  "pageMargins": [60, 60, 60, 60],
  "header": { "text": "Company Name", "alignment": "right", "margin": [0, 20, 60, 0], "fontSize": 9, "color": "#999999" },
  "footer": { "text": "Page {currentPage} of {pageCount}", "alignment": "center", "margin": [0, 0, 0, 20], "fontSize": 9 },
  "content": [
    { "text": "Document Title", "style": "title" },
    { "text": "Section heading", "style": "h1" },
    { "text": "Regular paragraph text with formatting support." },
    { "text": "Bold text", "bold": true },
    { "text": "Italic text", "italics": true },
    { "ul": ["Item 1", "Item 2", "Item 3"] },
    { "ol": ["First", "Second", "Third"] },
    {
      "table": {
        "headerRows": 1,
        "widths": ["*", "auto", "auto"],
        "body": [
          [{ "text": "Header 1", "bold": true }, { "text": "Header 2", "bold": true }, { "text": "Header 3", "bold": true }],
          ["Cell 1", "Cell 2", "Cell 3"],
          ["Cell 4", "Cell 5", "Cell 6"]
        ]
      },
      "layout": "lightHorizontalLines"
    },
    {
      "columns": [
        { "width": "50%", "text": "Left column" },
        { "width": "50%", "text": "Right column" }
      ]
    },
    { "text": "", "pageBreak": "after" },
    { "text": "New page content" }
  ],
  "styles": {
    "title": { "fontSize": 24, "bold": true, "margin": [0, 0, 0, 20], "color": "#1a3a5c" },
    "h1": { "fontSize": 18, "bold": true, "margin": [0, 20, 0, 10], "color": "#2d5f8a" },
    "h2": { "fontSize": 14, "bold": true, "margin": [0, 15, 0, 8], "color": "#3d6f9a" }
  },
  "defaultStyle": { "fontSize": 11, "lineHeight": 1.4 }
}
```

### Content Types

| Type | JSON | Notes |
|---|---|---|
| Text | `{ "text": "Hello" }` | Plain or with inline styles |
| Bold | `{ "text": "Bold", "bold": true }` | Or inline: `[{ "text": "normal " }, { "text": "bold", "bold": true }]` |
| Italic | `{ "text": "Italic", "italics": true }` | |
| Link | `{ "text": "Click", "link": "https://..." }` | |
| Unordered list | `{ "ul": ["A", "B", "C"] }` | |
| Ordered list | `{ "ol": ["First", "Second"] }` | |
| Table | `{ "table": { "body": [...] } }` | See table section below |
| Columns | `{ "columns": [{...}, {...}] }` | Side-by-side layout |
| Image | `{ "image": "data:image/png;base64,..." }` | Base64 encoded |
| Page break | `{ "text": "", "pageBreak": "after" }` | |
| Horizontal line | `{ "canvas": [{ "type": "line", "x1": 0, "y1": 0, "x2": 515, "y2": 0, "lineWidth": 1, "lineColor": "#cccccc" }] }` | |
| Stack | `{ "stack": [...] }` | Vertical group |

### Table Layouts

| Layout | Description |
|---|---|
| `"lightHorizontalLines"` | Light gray horizontal lines only |
| `"headerLineOnly"` | Line under header only |
| `"noBorders"` | No borders |
| _(default)_ | Full grid borders |

### Templates

#### Report
```json
{
  "pageSize": "A4",
  "content": [
    { "text": "Quarterly Report", "style": "title" },
    { "text": "Q1 2026 — Sales Performance", "style": "subtitle" },
    { "canvas": [{ "type": "line", "x1": 0, "y1": 0, "x2": 515, "y2": 0, "lineWidth": 2, "lineColor": "#2d5f8a" }] },
    { "text": "\n" },
    { "text": "Executive Summary", "style": "h1" },
    { "text": "Summary paragraph here..." },
    { "text": "Key Metrics", "style": "h1" },
    { "table": { "headerRows": 1, "widths": ["*", "auto", "auto", "auto"], "body": [
      [{ "text": "Metric", "bold": true, "fillColor": "#2d5f8a", "color": "white" }, { "text": "Target", "bold": true, "fillColor": "#2d5f8a", "color": "white" }, { "text": "Actual", "bold": true, "fillColor": "#2d5f8a", "color": "white" }, { "text": "Status", "bold": true, "fillColor": "#2d5f8a", "color": "white" }],
      ["Revenue", "R$ 500K", "R$ 520K", "✅ +4%"],
      ["Leads", "1.200", "1.450", "✅ +21%"],
      ["Conversion", "12%", "10.5%", "⚠️ -1.5pp"]
    ]}, "layout": "lightHorizontalLines" }
  ],
  "styles": {
    "title": { "fontSize": 26, "bold": true, "color": "#1a3a5c", "margin": [0, 0, 0, 8] },
    "subtitle": { "fontSize": 14, "color": "#666666", "margin": [0, 0, 0, 20] },
    "h1": { "fontSize": 16, "bold": true, "color": "#2d5f8a", "margin": [0, 20, 0, 10] }
  }
}
```

#### Invoice
```json
{
  "pageSize": "A4",
  "content": [
    { "columns": [
      { "width": "60%", "stack": [
        { "text": "INVOICE", "fontSize": 28, "bold": true, "color": "#1a3a5c" },
        { "text": "Nº INV-2026-0042", "fontSize": 12, "color": "#666", "margin": [0, 4, 0, 0] }
      ]},
      { "width": "40%", "stack": [
        { "text": "Company Name", "bold": true, "alignment": "right" },
        { "text": "Address Line 1", "alignment": "right", "color": "#666" },
        { "text": "CNPJ: 00.000.000/0001-00", "alignment": "right", "color": "#666" }
      ]}
    ]},
    { "canvas": [{ "type": "line", "x1": 0, "y1": 10, "x2": 515, "y2": 10, "lineWidth": 2, "lineColor": "#1a3a5c" }] },
    { "text": "\n" },
    { "columns": [
      { "width": "50%", "stack": [
        { "text": "Bill To:", "bold": true },
        { "text": "Client Name" },
        { "text": "Client Address" }
      ]},
      { "width": "50%", "stack": [
        { "text": "Date: 23/03/2026", "alignment": "right" },
        { "text": "Due: 23/04/2026", "alignment": "right" }
      ]}
    ]},
    { "text": "\n\n" },
    { "table": { "headerRows": 1, "widths": ["*", "auto", "auto", "auto"], "body": [
      [{ "text": "Description", "bold": true, "fillColor": "#1a3a5c", "color": "white" }, { "text": "Qty", "bold": true, "fillColor": "#1a3a5c", "color": "white", "alignment": "center" }, { "text": "Unit Price", "bold": true, "fillColor": "#1a3a5c", "color": "white", "alignment": "right" }, { "text": "Total", "bold": true, "fillColor": "#1a3a5c", "color": "white", "alignment": "right" }],
      ["Consulting services", { "text": "40h", "alignment": "center" }, { "text": "R$ 250", "alignment": "right" }, { "text": "R$ 10.000", "alignment": "right" }],
      ["", "", { "text": "Total:", "bold": true, "alignment": "right" }, { "text": "R$ 10.000", "bold": true, "alignment": "right" }]
    ]} }
  ]
}
```

### CREATE vs PDFMAKE Decision Matrix

| Feature | CREATE (Route A) | PDFMAKE (Route D) |
|---|---|---|
| Design cover | ✅ 15 cover patterns | ❌ No cover |
| Design system tokens | ✅ Full palette/typography | ⚠️ Manual styles |
| Charts/flowcharts | ✅ matplotlib built-in | ❌ Need external image |
| Tables | ✅ Styled | ✅ Styled (more flexible) |
| Speed | Slower (Python + Node) | ✅ Fast (Node only) |
| LLM-friendliness | Content blocks JSON | ✅ Native JSON DDO |
| Dependencies | Python + Node + Playwright | ✅ Node only |
| Best for | Polished client-facing docs | Quick reports, invoices, data-heavy docs |

---

## Environment

```bash
bash scripts/make.sh check   # verify all deps
bash scripts/make.sh fix     # auto-install missing deps
bash scripts/make.sh demo    # build a sample PDF
```

| Tool | Used by | Install |
|---|---|---|
| Python 3.9+ | all `.py` scripts | system |
| `reportlab` | `render_body.py` | `pip install reportlab` |
| `pypdf` | fill, merge, reformat | `pip install pypdf` |
| Node.js 18+ | `render_cover.js` | system |
| `playwright` + Chromium | `render_cover.js` | `npm install -g playwright && npx playwright install chromium` |

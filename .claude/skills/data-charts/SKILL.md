---
name: data-charts
description: >
  Gera gráficos interativos (HTML) e estáticos (PNG/SVG) a partir de dados.
  Suporta bar, line, pie, radar, heatmap, scatter, treemap, gauge, funnel e mais.
  Dual-engine: Chart.js (simples) + ECharts (avançado). Output: HTML standalone + export PNG/SVG.
  LLM-native: JSON config gera gráfico sem ferramentas visuais.
domain: visualization
subdomain: charts
version: 1.0.0
author: deivithi
sources:
  - chartjs/Chart.js (67K⭐)
  - apache/echarts (66K⭐)
tags:
  - charts
  - data-visualization
  - dashboard
  - bar-chart
  - line-chart
  - pie-chart
  - heatmap
  - interactive
---

# 📊 Data Charts — Gráficos via Dados

> **"Dados sem visualização são ruído. Dados com gráficos são decisão."**
> Gera gráficos interativos e estáticos a partir de dados — perfeito para dashboards, relatórios e apresentações.

## 📁 File Structure
- `SKILL.md` — Você está aqui. Referência completa + exemplos.
- `gotchas.md` — ⚠️ Problemas conhecidos.

## 🔗 Related Skills
- `mermaid-diagrams` — Para diagramas estruturais (fluxos, ER, sequence). Para gráficos de dados, use esta skill.
- `minimax-pdf` — Embede gráficos em PDFs profissionais (export PNG → insert como imagem)
- `minimax-xlsx` — Leia dados de planilhas Excel para gerar gráficos
- `frontend-design` — Embede gráficos em UIs e dashboards web
- `markdown-slides` — Inclua gráficos como imagens em slides Marp

---

## 🎯 Decisão: Qual Engine Usar?

| Critério | Chart.js | ECharts |
|----------|----------|---------|
| **Simplicidade** | ✅ Config mínima | Config mais verbosa |
| **Chart types básicos** | ✅ bar, line, pie, radar, scatter, bubble, doughnut, polar area | ✅ Todos + mais |
| **Charts avançados** | ❌ Sem heatmap, treemap, gauge, funnel nativo | ✅ heatmap, treemap, sunburst, sankey, gauge, funnel, candlestick, graph, map |
| **Interatividade** | Hover + tooltips | ✅ Zoom, brush, dataZoom, toolbox com export |
| **Tamanho CDN** | ~60KB gzipped | ~400KB gzipped (full), ~170KB (core) |
| **LLM-friendliness** | ✅ Config JSON simples | Config mais complexa mas mais poderosa |
| **Export nativo** | Via plugin (canvas toDataURL) | ✅ Toolbox com saveAsImage built-in |

### Regra de Roteamento

```
Se chart type ∈ {bar, line, pie, doughnut, radar, scatter, bubble, polar area}
  E não precisa de zoom/brush/toolbox avançado
  → Chart.js (mais leve, config mais simples)

Se chart type ∈ {heatmap, treemap, sunburst, sankey, gauge, funnel, candlestick, graph, map, boxplot}
  OU precisa de interatividade avançada (zoom, brush, dataZoom, toolbox)
  OU dataset > 10K pontos
  → ECharts (mais poderoso)
```

---

## 1. Chart.js — Engine Simples

### CDN
```html
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
```

### Template HTML Standalone
```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{CHART_TITLE}}</title>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    body { margin: 0; display: flex; justify-content: center; align-items: center; min-height: 100vh; background: #f8f9fa; font-family: system-ui, sans-serif; }
    .container { background: white; border-radius: 12px; padding: 24px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); max-width: 900px; width: 95%; }
    h2 { margin: 0 0 16px; color: #1a1a2e; font-size: 1.25rem; }
    canvas { max-height: 500px; }
  </style>
</head>
<body>
  <div class="container">
    <h2>{{CHART_TITLE}}</h2>
    <canvas id="chart"></canvas>
  </div>
  <script>
    const ctx = document.getElementById('chart').getContext('2d');
    new Chart(ctx, {{CHART_CONFIG}});
  </script>
</body>
</html>
```

### Config Structure (o que o LLM gera)
```javascript
{
  type: 'bar',           // 'bar' | 'line' | 'pie' | 'doughnut' | 'radar' | 'scatter' | 'bubble' | 'polarArea'
  data: {
    labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai'],
    datasets: [{
      label: 'Vendas 2026',
      data: [120, 190, 130, 250, 210],
      backgroundColor: ['#4e79a7', '#f28e2b', '#e15759', '#76b7b2', '#59a14f'],
      borderColor: '#4e79a7',
      borderWidth: 2
    }]
  },
  options: {
    responsive: true,
    plugins: {
      legend: { position: 'top' },
      title: { display: true, text: 'Vendas Mensais' }
    },
    scales: {    // Não usar para pie/doughnut/radar/polarArea
      y: { beginAtZero: true }
    }
  }
}
```

### Chart Types Chart.js

| Tipo | `type` | Quando usar |
|------|--------|-------------|
| Barras | `'bar'` | Comparar categorias |
| Barras horizontais | `'bar'` + `indexAxis: 'y'` | Rankings, categorias longas |
| Linha | `'line'` | Tendências temporais |
| Área | `'line'` + `fill: true` | Volume ao longo do tempo |
| Pizza | `'pie'` | Proporções (max 7 fatias) |
| Doughnut | `'doughnut'` | Proporções com espaço central |
| Radar | `'radar'` | Comparação multi-dimensional |
| Scatter | `'scatter'` | Correlação entre variáveis |
| Bubble | `'bubble'` | Scatter + terceira dimensão (tamanho) |
| Polar Area | `'polarArea'` | Categorias com magnitude |
| Mixed | datasets com `type` diferente | Combinar bar + line |

### Paletas de Cores Profissionais

```javascript
// Tableau 10 (padrão recomendado)
const TABLEAU_10 = ['#4e79a7', '#f28e2b', '#e15759', '#76b7b2', '#59a14f', '#edc948', '#b07aa1', '#ff9da7', '#9c755f', '#bab0ac'];

// Dark mode
const DARK_PALETTE = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272', '#fc8452', '#9a60b4', '#ea7ccc', '#5a5a5a'];

// Corporate (Febracis)
const CORPORATE = ['#1a3a5c', '#2d6a9f', '#4a9bd9', '#7bc0f0', '#b8dff6', '#e74c3c', '#f39c12', '#27ae60', '#8e44ad', '#95a5a6'];
```

### Export como PNG (via código)
```javascript
// Adicionar botão de download
const link = document.createElement('a');
link.download = 'chart.png';
link.href = document.getElementById('chart').toDataURL('image/png', 1.0);
link.click();
```

---

## 2. ECharts — Engine Avançado

### CDN
```html
<script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
```

### Template HTML Standalone
```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{CHART_TITLE}}</title>
  <script src="https://cdn.jsdelivr.net/npm/echarts@5/dist/echarts.min.js"></script>
  <style>
    body { margin: 0; display: flex; justify-content: center; align-items: center; min-height: 100vh; background: #f8f9fa; font-family: system-ui, sans-serif; }
    .container { background: white; border-radius: 12px; padding: 24px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); max-width: 1000px; width: 95%; }
    h2 { margin: 0 0 16px; color: #1a1a2e; font-size: 1.25rem; }
    #chart { width: 100%; height: 500px; }
  </style>
</head>
<body>
  <div class="container">
    <h2>{{CHART_TITLE}}</h2>
    <div id="chart"></div>
  </div>
  <script>
    const chart = echarts.init(document.getElementById('chart'));
    const option = {{ECHART_OPTION}};
    chart.setOption(option);
    window.addEventListener('resize', () => chart.resize());
  </script>
</body>
</html>
```

### Option Structure (o que o LLM gera)
```javascript
{
  title: { text: 'Vendas por Região', left: 'center' },
  tooltip: { trigger: 'axis' },         // 'axis' para bar/line, 'item' para pie/scatter
  legend: { top: 'bottom' },
  toolbox: {                             // Barra de ferramentas built-in
    feature: {
      saveAsImage: {},                   // Export PNG
      dataZoom: {},                      // Zoom
      restore: {},                       // Reset
      dataView: { readOnly: true }       // Ver dados
    }
  },
  xAxis: { type: 'category', data: ['Norte', 'Sul', 'Leste', 'Oeste'] },
  yAxis: { type: 'value' },
  series: [{
    name: 'Vendas',
    type: 'bar',        // Tipo do gráfico
    data: [320, 240, 180, 290],
    itemStyle: { color: '#4e79a7' }
  }]
}
```

### Chart Types ECharts

| Tipo | `series.type` | Quando usar |
|------|---------------|-------------|
| Barras | `'bar'` | Comparar categorias |
| Linha | `'line'` | Tendências |
| Pizza | `'pie'` | Proporções |
| Scatter | `'scatter'` | Correlações |
| Radar | `'radar'` | Multi-dimensional |
| **Heatmap** | `'heatmap'` | Densidade, correlação matrix |
| **Treemap** | `'treemap'` | Hierarquias proporcionais |
| **Sunburst** | `'sunburst'` | Hierarquias circulares |
| **Sankey** | `'sankey'` | Fluxos e conexões |
| **Gauge** | `'gauge'` | KPIs, velocímetros |
| **Funnel** | `'funnel'` | Pipeline de vendas, conversão |
| **Candlestick** | `'candlestick'` | Dados financeiros (OHLC) |
| **Graph** | `'graph'` | Redes e relações |
| **Boxplot** | `'boxplot'` | Distribuição estatística |
| **Map** | `'map'` | Dados geográficos |
| **ThemeRiver** | `'themeRiver'` | Evolução temporal de múltiplas categorias |

### Exemplos de Charts Avançados

#### Heatmap
```javascript
{
  tooltip: { position: 'top' },
  xAxis: { type: 'category', data: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'] },
  yAxis: { type: 'category', data: ['Manhã', 'Tarde', 'Noite'] },
  visualMap: { min: 0, max: 100, calculable: true, orient: 'horizontal', left: 'center', bottom: 0 },
  series: [{
    type: 'heatmap',
    data: [[0,0,50],[0,1,80],[0,2,30],[1,0,60],[1,1,90],[1,2,20],[2,0,70],[2,1,45],[2,2,55],[3,0,85],[3,1,40],[3,2,65],[4,0,95],[4,1,75],[4,2,35]],
    label: { show: true }
  }]
}
```

#### Gauge (KPI)
```javascript
{
  series: [{
    type: 'gauge',
    progress: { show: true, width: 18 },
    axisLine: { lineStyle: { width: 18 } },
    detail: { valueAnimation: true, formatter: '{value}%', fontSize: 28 },
    data: [{ value: 72, name: 'Conversão' }]
  }]
}
```

#### Funnel (Pipeline de Vendas)
```javascript
{
  tooltip: { trigger: 'item', formatter: '{b}: {c}' },
  series: [{
    type: 'funnel',
    left: '10%', width: '80%',
    label: { formatter: '{b}: {c}' },
    data: [
      { value: 1200, name: 'Leads' },
      { value: 800, name: 'Qualificados' },
      { value: 400, name: 'Propostas' },
      { value: 200, name: 'Negociação' },
      { value: 80, name: 'Fechados' }
    ]
  }]
}
```

#### Treemap
```javascript
{
  series: [{
    type: 'treemap',
    data: [
      { name: 'Vendas', value: 500, children: [
        { name: 'Online', value: 300 },
        { name: 'Presencial', value: 200 }
      ]},
      { name: 'Marketing', value: 300, children: [
        { name: 'Ads', value: 180 },
        { name: 'Orgânico', value: 120 }
      ]}
    ]
  }]
}
```

---

## 3. Workflow

### Passo a Passo

```
1. IDENTIFICAR dados (fonte: planilha, API, input do usuário, banco)
2. ESCOLHER engine (Chart.js simples → ECharts avançado)
3. ESCOLHER chart type (ver tabelas acima)
4. GERAR config JSON/JS
5. MONTAR HTML standalone usando o template
6. SALVAR como arquivo .html em output/
7. INFORMAR caminho para o usuário abrir no browser
```

### Convenções de Output

- **Arquivo:** `output/chart-{descritivo}.html`
- **Encoding:** UTF-8, sem BOM
- **Responsivo:** Sempre `responsive: true` (Chart.js) ou `resize()` listener (ECharts)
- **Paleta:** Usar Tableau 10 como padrão, a menos que o usuário especifique cores
- **Título:** Sempre incluir título descritivo no gráfico e no `<title>` HTML
- **Toolbox ECharts:** Sempre incluir `saveAsImage` para export fácil

### Dashboard Multi-Charts

Para dashboards com múltiplos gráficos, usar grid CSS:

```html
<style>
  .dashboard { display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 24px; padding: 24px; }
  .card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
  .card canvas, .card > div { width: 100%; height: 350px; }
</style>
<div class="dashboard">
  <div class="card"><canvas id="chart1"></canvas></div>
  <div class="card"><div id="chart2"></div></div>
  <div class="card"><canvas id="chart3"></canvas></div>
  <div class="card"><div id="chart4"></div></div>
</div>
```

---

## 4. Anti-Patterns

| ❌ Evitar | ✅ Fazer |
|----------|---------|
| Pizza com 15+ fatias | Agrupar em "Outros" (max 7 fatias) |
| 3D charts | Sempre 2D (3D distorce percepção) |
| Cores aleatórias | Usar paleta consistente (Tableau 10) |
| Eixo Y não começando em zero (bar) | `beginAtZero: true` para bar charts |
| Gráfico sem título | Sempre incluir título descritivo |
| Legendas sobrepostas | Posicionar legend fora do gráfico |
| Dataset grande em Chart.js | Usar ECharts para >10K pontos |
| Misturar engines no mesmo dashboard | OK misturar, mas manter estilo visual consistente |

---

## 5. Integração com Dados

### De Excel/CSV (via DuckDB ou minimax-xlsx)
```
1. /duckdb-skills:read-file dados.xlsx
2. Extrair labels e values
3. Gerar chart config
4. Montar HTML
```

### De API
```
1. Fetch dados via WebFetch ou n8n
2. Transformar em arrays de labels/values
3. Gerar chart config
4. Montar HTML
```

### De Input Manual
```
1. Usuário fornece dados na conversa
2. Parsear em arrays
3. Gerar chart config
4. Montar HTML
```

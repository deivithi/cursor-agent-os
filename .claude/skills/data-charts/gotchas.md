# ⚠️ Gotchas — Data Charts

> Problemas conhecidos encontrados durante o uso desta skill. Construído iterativamente a partir de falhas reais.
> **Consulte este arquivo quando algo falhar ou produzir resultado inesperado.**

---

## Chart.js: `scales` em gráficos circulares

- **Sintoma:** Erro JS ou gráfico não renderiza
- **Causa raiz:** Pie, doughnut, radar e polarArea não usam `scales` — propriedade é ignorada ou causa erro
- **Solução:** Remover `options.scales` para chart types circulares
- **Prevenção:** Só usar `scales` com bar, line, scatter, bubble
- **Descoberto em:** 2026-03-23

---

## ECharts: container sem dimensões

- **Sintoma:** Gráfico não aparece (div vazia)
- **Causa raiz:** ECharts exige que o container `<div>` tenha width e height definidos (via CSS ou inline)
- **Solução:** Sempre definir `width: 100%; height: 500px;` no container
- **Prevenção:** Template padrão já inclui dimensões
- **Descoberto em:** 2026-03-23

---

## ECharts: `echarts.init` antes do DOM ready

- **Sintoma:** `Cannot read properties of null`
- **Causa raiz:** Script executado antes do DOM estar pronto
- **Solução:** Colocar `<script>` no final do `<body>` (após o div container)
- **Prevenção:** Template padrão já posiciona script no final
- **Descoberto em:** 2026-03-23

---

## Chart.js: cores insuficientes para datasets

- **Sintoma:** Fatias de pizza ou barras aparecem cinza
- **Causa raiz:** `backgroundColor` tem menos cores que data points
- **Solução:** Fornecer array de cores com mesmo tamanho do array de `data`
- **Prevenção:** Usar paleta TABLEAU_10 (10 cores) e expandir se necessário
- **Descoberto em:** 2026-03-23

---

## Mixed charts: eixos conflitantes

- **Sintoma:** Escala do eixo Y não faz sentido para um dos datasets
- **Causa raiz:** Datasets com magnitudes muito diferentes no mesmo eixo
- **Solução:** Usar segundo eixo Y: `yAxisIndex: 1` (ECharts) ou `yAxisID: 'y2'` (Chart.js)
- **Prevenção:** Sempre avaliar se datasets têm mesma escala antes de combinar
- **Descoberto em:** 2026-03-23

---

<!--
INSTRUÇÕES PARA MANUTENÇÃO:
1. Adicione novos gotchas NO TOPO (mais recentes primeiro)
2. Use o formato acima para consistência
3. Se um gotcha for resolvido permanentemente, mova para ## Resolvidos no final
4. Gotchas devem ser específicos e acionáveis — não genéricos
5. Inclua o sintoma exato para facilitar busca futura
-->

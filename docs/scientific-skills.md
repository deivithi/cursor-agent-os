# 🔬 Scientific & Analytics Skills (22 skills ativas)

**Repositório:** `.claude/scientific-skills/` (fonte seletiva: K-Dense-AI/claude-scientific-skills)
**Índice:** `.claude/scientific-skills/index.json`
**Comando explícito:** `/science <descrição do que precisa>`

## ⚡ Ativação Automática

Quando o usuário mencionar qualquer tema de análise de dados, machine learning, estatística, simulação, modelagem, visualização, dados financeiros ou metodologia de pesquisa, o assistente **DEVE automaticamente**:

1. Consultar o índice em `.claude/scientific-skills/index.json` para encontrar skills relevantes
2. Ler o `SKILL.md` da skill mais adequada em `.claude/scientific-skills/skills/{skill-name}/SKILL.md`
3. Consultar `references/` da skill para detalhes técnicos quando necessário
4. Seguir o workflow descrito, adaptando ao contexto Febracis/Salesforce

## 📂 Categorias Ativas (5 categorias, 22 skills)

| Categoria | Skills | Palavras-chave de ativação |
|-----------|--------|---------------------------|
| 🔬 Scientific Computing | 3 | SymPy, SimPy, Dask, simulação, modelagem matemática, computação distribuída, fórmulas |
| 🤖 ML/AI | 7 | Transformers, HuggingFace, scikit-learn, PyTorch, SHAP, PyMC, RL, classificação, NLP, deep learning, explicabilidade, Bayesiano |
| 📊 Data & Visualization | 6 | Polars, Pandas, NetworkX, Plotly, Matplotlib, Seaborn, EDA, dashboard, gráfico, análise exploratória |
| 💰 Financial Data | 2 | FRED, Alpha Vantage, dados econômicos, mercado financeiro, PIB, inflação, ações |
| 📖 Research Methodology | 4 | Hipótese, revisão de literatura, escrita científica, citação, metodologia, pesquisa |

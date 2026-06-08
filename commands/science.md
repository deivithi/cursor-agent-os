# Science — Router de Skills Científicas e Analíticas

Ativado para: **$ARGUMENTS**

## Processo

1. Consulte o índice em `.claude/scientific-skills/index.json` para encontrar skills relevantes
2. Leia o `SKILL.md` da skill mais adequada em `.claude/scientific-skills/skills/{skill-name}/SKILL.md`
3. Se a skill tem diretório `references/`, consulte os arquivos de referência para detalhes técnicos
4. Siga o workflow descrito na skill, adaptando ao contexto do usuário

## Categorias Disponíveis

| Categoria | Skills | Quando Ativar |
|-----------|--------|---------------|
| **Scientific Computing** | sympy, simpy, dask | Modelagem matemática, simulação de processos, computação distribuída |
| **ML/AI** | transformers, scikit-learn, pytorch-lightning, shap, pymc, stable-baselines3, umap-learn | Machine learning, NLP, deep learning, explicabilidade, RL |
| **Data & Visualization** | polars, networkx, plotly, matplotlib, seaborn, exploratory-data-analysis | Análise de dados, grafos, visualização, dashboards |
| **Financial Data** | fred-economic-data, alpha-vantage | Dados econômicos, mercado financeiro |
| **Research Methodology** | hypothesis-generation, literature-review, scientific-writing, citation-management | Metodologia de pesquisa, documentação, hipóteses |

## Regras

- Se múltiplas skills são relevantes, combine-as (ex: polars + plotly + shap para análise de leads com ML)
- Sempre adapte os exemplos da skill ao contexto Febracis/Salesforce quando possível
- Use Python como linguagem padrão para execução
- Se precisar instalar pacotes, informe o comando pip antes de executar

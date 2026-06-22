# DetectGPT: Zero-Shot Machine-Generated Text Detection using Probability Curvature

> **Fonte:** Mitchell, Lee, Khazatsky, Manning, Finn — Stanford University / ICML 2023
> **arXiv:** 2301.11305
> **Status:** Publicado no ICML 2023 (top conference de ML)

## Resumo

DetectGPT é um método **zero-shot** para detectar texto gerado por LLMs. Não requer:
- Treinar um classifier separado
- Coletar dataset de texto real ou gerado
- Inserir watermark explícito no texto

## Ideia Central

Textos gerados por um LLM tendem a ocupar regiões de **curvatura negativa** na função de log-probabilidade do modelo. Ou seja, pequenas perturbações no texto gerado tendem a **reduzir** a probabilidade atribuída pelo modelo gerador — enquanto em texto humano, as perturbações têm efeito neutro ou positivo.

## Como Funciona

1. Dado um texto candidato, calcular `log p(x)` usando o modelo suspeito de ter gerado
2. Aplicar perturbações aleatórias ao texto (via T5 ou outro modelo genérico)
3. Recalcular `log p(x_perturbado)` para cada perturbação
4. Comparar as diferenças: se `log p(original)` > `log p(perturbado)` de forma consistente → provável IA

## Resultados

| Dataset | Baseline (zero-shot) | DetectGPT | Melhoria |
|---------|---------------------|-----------|----------|
| Fake news (GPT-NeoX 20B) | 0.81 AUROC | **0.95 AUROC** | +17% |
| GPT-2 1.5B | 0.82 AUROC | 0.93 AUROC | +13% |
| GPT-3 175B | 0.78 AUROC | 0.88 AUROC | +13% |

## Aplicação Prática na Skill

A skill incorpora o princípio do DetectGPT indiretamente:

1. **Pré-processamento estatístico** (`scripts/text_stats.py`): calcula proxies de "curvatura" via burstiness, TTR e distribuição de probabilidade das sentenças
2. **Sistema de scoring por categoria**: o score `estatistico` captura padrões análogos à curvatura de probabilidade
3. **Sinal S01 (Burstiness)**: mede exatamente a uniformidade que DetectGPT identifica como característica de LLMs
4. **Sinal S02 (Perplexity)**: estima a previsibilidade token-a-token que correlaciona com baixa curvatura

## Limitações

- Requer acesso ao modelo gerador para calcular log-probabilidades (não factível na skill via LLM)
- A skill usa proxies e heurísticas inspiradas no paper, não o método exato
- Performance degrada com texto muito curto (< 50 tokens)
- Não detecta texto de modelos não vistos durante a análise de curvatura

## Citação

```bibtex
@inproceedings{mitchell2023detectgpt,
  title={DetectGPT: Zero-Shot Machine-Generated Text Detection using Probability Curvature},
  author={Mitchell, Eric and Lee, Yoonho and Khazatsky, Alexander and Manning, Christopher D and Finn, Chelsea},
  booktitle={ICML},
  year={2023}
}
```

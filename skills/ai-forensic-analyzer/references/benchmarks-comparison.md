# Benchmarks de Detecção de Conteúdo IA

> **Fonte primária:** Weber-Wulff et al. (2023) — "Testing of detection tools for AI-generated text"
> **Publicação:** International Journal for Educational Integrity, Dez 2023
> **arXiv:** 2306.15666

## Estudo Weber-Wulff (2023) — 14 Ferramentas Avaliadas

O estudo mais abrangente até hoje. Testou 14 ferramentas de detecção de texto IA com metodologia controlada.

### Resultados

| Ferramenta | Accuracy Geral | FP Rate | FN Rate | Nota |
|------------|---------------|---------|---------|------|
| Turnitin | ~80% | ~1% (contestado) | ~15% | Mais usada em universidades |
| GPTZero | <70% | Alto | Variável | Popular, mas não confiável |
| Originality.ai | ~91% | Baixo | ~9% | Melhor em textos não modificados |
| Copyleaks | ~75% | Médio | Variável | — |
| GPTKit | ~70% | Alto | Variável | — |
| Writer | ~65% | Alto | Alto | — |
| Crossplag | ~70% | Médio | Variável | — |
| GLTR | ~72% | Médio | Variável | Baseado em Harvard/IBM |
| **Média geral** | **~70%** | **Alto** | **Variável** | Nenhuma acima de 80% |

### Conclusões Críticas

1. **NENHUMA ferramenta atingiu 80% de accuracy geral**
2. **Apenas 5 de 14 ficaram acima de 70%**
3. **Viés sistemático:** ferramentas tendem a classificar como "humano" (conservadoras para FP)
4. **Paráfrase DERRUBA a detecção:** accuracy cai dramaticamente com texto modificado
5. **Textos curtos:** performance cai significativamente abaixo de 200 palavras

## Estudo Taloni et al. (2023) — Efeito da Anti-Evasão

Publicado na Eye Journal (Nature). Testou o impacto de ferramentas de bypass.

| Cenário | Originality.ai Accuracy |
|---------|------------------------|
| Texto GPT-4 original | **91.3%** |
| Após paráfrase (GPT-4) | ~60% |
| Após Undetectable.ai | **27.8%** |

**Queda de 91.3% → 27.8% após bypass.** Este é o estado atual da "corrida armamentista".

## Turnitin — Dados Oficiais

| Métrica | Valor declarado |
|---------|----------------|
| Falso positivo | < 1% (contestado por Washington Post) |
| Falso negativo | 15% |
| Adoção | Milhares de universidades |

**Controvérsia:** O Washington Post (Abr 2023) encontrou taxa de FP muito maior em teste independente (~50% em amostra pequena).

## GPTZero — Controvérsia UC Davis

Dois estudantes da UC Davis foram falsamente acusados de usar IA:
- Caso 1: GPTZero flagou ensaio como IA → investigação → inocentado
- Caso 2: Turnitin flagou → investigação → inocentado

Após cobertura da mídia (Rolling Stone, USA Today, Futurism), ambos foram inocentados.

## Implicações para a Skill

Estes benchmarks informam diretamente o design da v2:

1. **Confiança nunca é "Alta" para textos < 150 palavras** (limitação documentada)
2. **Bias warnings são obrigatórios** (FP rate varia por demografia)
3. **Sinais de anti-evasão são analisados separadamente** (queda de accuracy conhecida)
4. **Nível de admissibilidade é sempre "Triagem" por padrão** (nunca "Evidência conclusiva")
5. **Output sempre recomenda verificação humana** para decisões irreversíveis

# Viés em Detectores de Conteúdo IA

> **"GPT detectors are biased against non-native English writers"**
> — Liang, Yuksekgonul, Mao, Wu, Zou — Stanford HAI — Patterns, Jul 2023
> **DOI:** 10.1016/j.patter.2023.100779

## O Problema

Detectores de texto IA NÃO medem "IA-ness" — eles medem "statistical typicality". Textos que fogem do padrão estatístico do inglês nativo são penalizados, independentemente da origem.

## Estudo Liang et al. (Stanford, 2023)

### Metodologia

- 91 ensaios TOEFL (Test of English as a Foreign Language) de autores não-nativos
- 88 ensaios de alunos americanos (8ª série)
- 7 detectores testados (incluindo GPTZero, Originality.ai, OpenAI detector)

### Resultado

| Grupo | Taxa de Falso Positivo |
|-------|----------------------|
| Escritores não-nativos de inglês | **61.3%** |
| Escritores nativos (EUA, 8ª série) | ~5% |

**61.3% dos ensaios escritos por não-nativos foram incorretamente classificados como IA.**

### Por que isso acontece

- Não-nativos usam vocabulário mais limitado (menor TTR) → parece "baixa diversidade lexical" de LLM
- Estruturas sintáticas mais simples e regulares → parece "previsibilidade" de LLM
- Uso de conectivos formais (aprendidos em aula) → parece "conectivos LLM-típicos"
- Menos expressões idiomáticas e coloquialismos → parece "ausência de voz pessoal"

## Estudo Common Sense Media (Set 2024)

### Viés Racial

| Grupo | Taxa de Falso Positivo |
|-------|----------------------|
| Estudantes negros | **20%** |
| Estudantes latinos | 10% |
| Estudantes brancos | 7% |

### Implicações

O viés não é apenas linguístico — é **sistêmico e interseccional**. Usar detectores de IA em contextos acadêmicos ou de contratação sem considerar estes vieses pode:
- Penalizar desproporcionalmente imigrantes e minorias
- Reforçar desigualdades existentes
- Criar falsas acusações com consequências reais (reprovação, perda de emprego)

## Neurodivergência

Estudos da Universidade de Nebraska e outros documentaram que textos de autores neurodivergentes (TEA, TDAH, dislexia) têm maior probabilidade de serem flagados como IA devido a:
- Padrões de organização textual diferentes do neurotípico
- Escolhas lexicais não convencionais
- Estruturas argumentativas não-lineares

## Recomendações para Uso Ético

1. **NUNCA use como prova única** — sempre combine com outros métodos
2. **Sempre reporte bias_warnings** no output quando fatores de risco estão presentes
3. **Considere o contexto do autor** — se possível, saiba se é não-nativo, neurodivergente, etc.
4. **Use apenas para triagem** — nunca para decisões irreversíveis
5. **Transparência total** — informe o usuário sobre as limitações e vieses conhecidos

## Como a Skill Mitiga

A v2 implementa:

- **Campo `bias_warnings`** obrigatório no output: 8 tipos de viés documentados
- **Redução automática de confiança** quando fatores de risco são detectados
- **`nivel_admissibilidade`** nunca é "Evidência conclusiva" por padrão
- **`recomendacao_uso`** sempre alerta sobre limitações
- **Regra 10 do system prompt**: "Considere VIÉS DE FALSO POSITIVO"

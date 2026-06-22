# Técnicas de Evasão e Anti-Detecção

> **"The AI Detection Arms Race Is On"** — Wired, 2024

## O Problema

Detectores de IA e ferramentas de evasão estão em uma corrida armamentista. Cada avanço na detecção é seguido por uma contra-medida. Entender as técnicas de evasão é essencial para calibrar a confiança da análise.

## Níveis de Evasão

### Nível 1 — Edição Manual Leve
- Trocar alguns conectivos ("No entanto" → "Mas", "Além disso" → "Também")
- Inserir erros tipográficos artificiais
- Variar comprimento de parágrafos manualmente
- **Eficácia:** Moderada (engana detectores baseados em superfície)
- **Detectável pela skill:** Sinais inconsistentes (mistura de padrões IA + erros "forçados")

### Nível 2 — Paráfrase Automatizada
- Usar outro LLM para reescrever o texto gerado
- Ferramentas: QuillBot, GPT-4 com prompt de paráfrase
- **Eficácia:** Alta (reduz accuracy de ~91% para ~60%)
- **Detectável pela skill:** Sinais de anti-evasão (texto "limpo demais" para ser humano, mas com padrões de re-escrita)

### Nível 3 — Ferramentas de Bypass Dedicadas
- **Undetectable.ai**, **HideMyAI**, **WriteHuman**, **Humanize AI**
- Técnicas proprietárias de "humanização"
- **Eficácia:** Muito alta (accuracy cai para ~28% no estudo Taloni)
- **Detectável pela skill:** Mais difícil. Sinais indiretos: uniformidade artificial, ausência de erros naturais

### Nível 4 — Ataques Adversariais ao Watermark
- Inserção/deleção estratégica de tokens
- Substituição por homóglifos
- Re-tradução (inglês → francês → inglês)
- **Eficácia:** Alta contra watermarking
- **Detectável pela skill:** Artefatos de tradução, padrões não-nativos artificiais

## Sinais de Anti-Evasão (Como Detectar)

A skill v2 inclui análise específica de anti-evasão:

| Sinal | O que procurar |
|-------|---------------|
| Erros artificiais | Erros que parecem "plantados" — ocorrem em palavras fáceis, não em palavras difíceis |
| Variação forçada | Conectivos variam de forma não-natural (um parágrafo usa "No entanto", o próximo usa "Contudo", o próximo usa "Porém") |
| Inconsistência de registro | Texto oscila entre formal e informal sem razão aparente |
| "Humanização" excessiva | Gírias e coloquialismos aparecem em contexto formal de forma artificial |
| Padrão de paráfrase | Sentenças com mesma estrutura semântica mas vocabulário diferente (típico de re-escrita) |
| Limpeza suspeita | Texto muito "limpo" após edição — sem hesitações, revisões ou marcas de processo humano |

## Estudo de Caso: Undetectable.ai (Taloni et al., 2023)

```
Texto original GPT-4 → Originality.ai: 91.3% confiança IA
        ↓
Texto após Undetectable.ai → Originality.ai: 27.8% confiança IA
        ↓
QUEDA DE 63.5 PONTOS PERCENTUAIS
```

## Implicações para a Skill

1. **Sinais de anti-evasão são sempre reportados**, mesmo quando o veredito final é "Humano"
2. **Confiança é reduzida** quando anti-evasão é detectada (texto pode ser IA disfarçada)
3. **Modo `deep`** faz uma segunda passagem focada especificamente em anti-evasão
4. **Contra-evidências** são registradas quando sinais IA e anti-evasão se contradizem

## Referências

- Taloni, Scorcia, Giannaccare (2023). "Modern threats in academia: evaluating plagiarism and artificial intelligence detection scores of ChatGPT". Eye, 38(2), 397-400.
- Beam, Christopher. "The AI Detection Arms Race Is On—and College Students Are Building the Weapons". Wired.
- Knibbs, Kate. "Researchers Tested AI Watermarks—and Broke All of Them". Wired.

# A Watermark for Large Language Models

> **Fonte:** Kirchenbauer, Geiping, Wen, Katz, Miers, Goldstein — 2023
> **arXiv:** 2301.10226
> **Impacto:** Base do Google DeepMind SynthID e outras técnicas de watermarking

## Resumo

Propõe um método para inserir marcas d'água imperceptíveis em texto gerado por LLMs, permitindo detecção confiável mesmo após modificações leves do texto.

## Ideia Central

Durante a geração de cada token, o modelo seleciona de um subconjunto "marcado" do vocabulário com base no hash do token anterior. Isso cria um padrão estatístico detectável sem afetar a qualidade do texto.

## Como Funciona

1. Antes da geração, o vocabulário é particionado em "green list" e "red list" para cada posição
2. O particionamento é determinado por uma função hash do token anterior
3. O modelo é levemente enviesado para escolher tokens da "green list"
4. Na detecção, conta-se a proporção de tokens da green list: se estatisticamente significativa → watermark detectada

## Robustez

| Ataque | Eficácia | Custo |
|--------|----------|-------|
| Paráfrase leve | Watermark sobrevive | Baixo |
| Paráfrase agressiva | Watermark degrada | Qualidade do texto cai |
| Inserção de tokens | Dilui a proporção | Detectável com texto mais longo |
| Deleção de tokens | Similar à inserção | Detectável com thresholds ajustados |
| Substituição por sinônimos | Degradação parcial | Requer muitas substituições |

## Evoluções

- **SynthID (Google DeepMind, 2023-2024):** Watermarking para texto e imagens, integrado a modelos Google
- **C2PA (Coalition for Content Provenance and Authenticity):** Padrão aberto de metadados de proveniência (Adobe, Microsoft, Intel, etc.)

## Aplicação Prática na Skill

A skill incorpora detecção de watermarking via:

1. **Sinal S47 (Multimodal):** Detecção de SynthID ou ausência de C2PA quando esperado
2. **Sinais de anti-evasão:** Texto que parece ter passado por paráfrase para remover watermark → padrão suspeito
3. **Metadados de imagem:** Verificação de campos de proveniência (Software, Artist) em EXIF

## Limitações

- Watermarking NÃO é universal — a maioria dos modelos não usa
- Pode ser removido com paráfrase agressiva ou re-tradução
- Falsos positivos são possíveis (texto humano pode coincidentemente ter mais tokens "green")
- Requer acesso ao modelo gerador para verificação criptográfica

## Citação

```bibtex
@article{kirchenbauer2023watermark,
  title={A Watermark for Large Language Models},
  author={Kirchenbauer, John and Geiping, Jonas and Wen, Yuxin and Katz, Jonathan and Miers, Ian and Goldstein, Tom},
  journal={arXiv preprint arXiv:2301.10226},
  year={2023}
}
```

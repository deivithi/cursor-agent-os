# Regras Financeiras e Contábeis — DRE Eventos Febracis

Estrutura padrão de contas e fórmulas de conciliação para eventos Febracis.

---

## 1. Estrutura do DRE de Evento

```
(+) Receita Bruta de Inscrições
(+) Receita de Upgrades / VIP
(+) Receita de Livros / Materiais
----------------------------------------
(=) RECEITA BRUTA TOTAL
(-) Deduções e Impostos sobre Venda (ISS / PIS / COFINS)
(-) Taxas de Cartão / Gateway
----------------------------------------
(=) RECEITA LÍQUIDA OPERACIONAL
(-) Custos Diretos do Evento:
    - Locação de Espaço / Centro de Convenções
    - Audiovisual, Som e Iluminação
    - Cenografia e Estrutura
    - Hospedagem e Passagens de Equipe / Palestrantes
    - Coffee Break / Catering
    - Material Didático e Crachás
----------------------------------------
(=) MARGEM BRUTA DO EVENTO
(-) Despesas Comerciais e Marketing Direto:
    - Tráfego Pago / Ads do Evento
    - Comissões da Equipe Comercial
----------------------------------------
(=) RESULTADO OPERACIONAL DO EVENTO (LUCRO/PREJUÍZO)
```

---

## 2. Validações Críticas de Integridade

1. **Margem Líquida Negativa:** Disparar alerta se a margem de contribuição for inferior a **15%** sem justificativa de evento estratégico/institucional.
2. **Rateio de Custos Compartilhados:** Despesas comuns divididas entre eventos simultâneos devem usar a métrica de proporção de participantes pagantes.
3. **Chunk Payload:** Nenhum registro pode conter strings em colunas monetárias ou valores ausentes.

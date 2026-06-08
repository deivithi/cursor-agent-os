# 💰 Regras de Comissão — Febracis

> ⚠️ **NOTA:** Estas são regras de REFERÊNCIA. As regras reais devem ser confirmadas com o time financeiro antes de cada auditoria. Atualize este documento sempre que houver mudança.

## Estrutura Geral

```
Comissão = Valor da Opp × Taxa aplicável × Fator de ajuste
```

## Tabela de Taxas por Produto/Tier

| Produto | Tier | Taxa Base | Observação |
|---------|------|-----------|------------|
| CIS Presencial | Standard | [X]% | Evento principal |
| CIS Online | Standard | [X]% | Menor ticket, mesma taxa |
| Coaching Individual | Premium | [X]% | Ticket alto |
| Formação | Standard | [X]% | Longa duração |
| Mentoria | Premium | [X]% | Renovação pode ter taxa diferente |

> 🔴 **TODO:** Preencher taxas reais com o time financeiro. Valores aqui são placeholders.

## Fatores de Ajuste

| Fator | Condição | Multiplicador |
|-------|---------|--------------|
| Meta batida | Vendedor atingiu meta mensal | [X]× |
| Super meta | Vendedor atingiu 150% da meta | [X]× |
| Indicação | Lead veio de indicação do vendedor | +[X]% bônus |
| Renovação | Cliente renovando contrato | Taxa pode variar |

## Regras de Split

- **Split igualitário:** 2 vendedores = 50%/50%
- **Split por papel:** Closer + SDR = [X]%/[Y]%
- **Regra:** Soma dos splits DEVE = 100%

## Período de Apuração

| Item | Regra |
|------|-------|
| **Competência** | Mês do CloseDate da Opportunity |
| **Pagamento** | Dia [X] do mês seguinte |
| **Chargeback** | Se Opp cancelada em < 30 dias, comissão estornada |

## Fórmula de Validação

```
Para cada Opp WHERE StageName = 'Closed Won':
  1. Produto → Taxa Base
  2. Meta vendedor → Fator de Ajuste
  3. Split → percentual
  4. Comissão = Amount × Taxa × Fator × Split%
  5. Comparar com Commission_Amount__c
  6. |Esperado - Registrado| > R$ 0,01 → DIVERGÊNCIA
```

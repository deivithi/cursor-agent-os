# ✅ Checklist de Validação — Auditoria de Comissões

## Pré-Auditoria
- [ ] Período de apuração definido (mês/ano)
- [ ] Tabela de taxas vigente confirmada com financeiro
- [ ] Lista de vendedores ativos confirmada
- [ ] Metas mensais por vendedor disponíveis
- [ ] Regras de split documentadas

## Extração de Dados
- [ ] Todas as Opps fechadas no período extraídas
- [ ] Opps com Amount alterado após fechamento identificadas
- [ ] Comissões calculadas pelo sistema extraídas
- [ ] Pagamentos já realizados (se houver) identificados

## Validação por Opportunity
- [ ] Produto correto → taxa correta aplicada
- [ ] Amount atual = Amount na data do cálculo de comissão
- [ ] Vendedor (Owner) = beneficiário da comissão
- [ ] Split (se aplicável) soma 100%
- [ ] Fator de ajuste (meta) aplicado corretamente
- [ ] Valor calculado = Valor registrado (tolerância R$ 0,01)

## Validação Consolidada
- [ ] Total de comissões = soma de todas as individuais
- [ ] Nenhum vendedor com comissão negativa
- [ ] Nenhuma Opp fechada sem comissão calculada
- [ ] Nenhuma comissão duplicada (mesmo vendedor, mesma Opp)
- [ ] Chargebacks de Opps canceladas aplicados

## Pós-Auditoria
- [ ] Relatório de divergências gerado
- [ ] Divergências comunicadas ao financeiro
- [ ] Correções aplicadas e documentadas
- [ ] Aprovação final do financeiro obtida
- [ ] ◆ DIAMOND GATE: Pagamento liberado

## Red Flags (Escalar Imediatamente)
- 🔴 Divergência > R$ 500 em uma única comissão
- 🔴 Mais de 5% das Opps com divergência
- 🔴 Comissão calculada para vendedor inativo
- 🔴 Split somando ≠ 100%
- 🔴 Mesma Opp com comissão para 3+ vendedores

# 🔍 Severity Scoring Matrix — Referência Rápida

## Níveis de Severidade

### 🔴 CRITICAL (peso 10)
- Quebra funcionalidade core
- Perda de dados possível
- Vulnerabilidade de segurança explorável
- Violação de compliance (LGPD, PCI DSS)
- Impacto financeiro direto

**Exemplos Febracis:**
- Regra de comissão calculando errado
- Lead duplicado sobrescrevendo dados reais
- Dados pessoais expostos sem consentimento
- Flow de automação deletando registros

### 🟠 HIGH (peso 5)
- Funcionalidade degradada significativamente
- Workaround existe mas é difícil/custoso
- Performance severamente impactada
- Dados inconsistentes entre sistemas

**Exemplos Febracis:**
- Scoring de lead ignorando campo importante
- Integração Marketing → Sales falhando silenciosamente
- Relatório de comissão com dados atrasados em 24h+
- Fluxo de nurturing pulando etapa

### 🟡 MEDIUM (peso 3)
- Inconveniente para o usuário
- Workaround fácil disponível
- Performance parcialmente impactada
- Dados incompletos mas não incorretos

**Exemplos Febracis:**
- Campo não obrigatório ficando vazio
- Layout de página com campos fora de ordem
- Email de follow-up com formatação quebrada
- Dashboard carregando lento mas funcional

### 🟢 LOW (peso 1)
- Cosmético ou estético
- Boas práticas não seguidas
- Melhoria opcional de UX
- Documentação faltando

**Exemplos Febracis:**
- Naming convention inconsistente em campos
- Help text faltando em campo
- Cor do botão fora do padrão visual
- Comentário desatualizado em Flow

### ⚪ INFO (peso 0)
- Observação sem ação necessária
- Nota para referência futura
- Padrão alternativo possível mas não necessário

---

## Thresholds de Decisão

| Score | Status | Ação |
|-------|--------|------|
| **0** | ✅ Aprovado | Nenhuma ação necessária |
| **1-5** | ✅ Aprovado com observações | Resolver LOWs quando conveniente |
| **6-15** | ⚠️ Condicional | Corrigir HIGHs antes de deploy |
| **16-29** | ❌ Reprovado | Corrigir tudo antes de prosseguir |
| **30+** | 🛑 Bloqueado | Revisão arquitetural necessária |

## Fórmula

```
Score Total = (CRITICAL × 10) + (HIGH × 5) + (MEDIUM × 3) + (LOW × 1) + (INFO × 0)
```

## Regras

1. **1 CRITICAL = reprovação automática** (score 10 já é ≥ 6)
2. **CRITICALs devem ser corrigidos ANTES de qualquer outra coisa**
3. **Score é cumulativo** — muitos LOWs podem reprovar
4. **Threshold pode ser ajustado** por contexto (mais rigoroso para produção)

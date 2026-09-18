---
name: dre-zo-integrity-guard
description: Guarda de integridade financeira, conciliação contábil e auditoria de deploy no Zo Computer para o aplicativo DRE_Eventos Febracis (Flask/React). Valida cálculos de receita bruta/líquida, margens, rateio de despesas, integridade de chunks e consistência de dados extraídos de briefings/TOTVS.
allowed-tools: Bash, Read, Glob, Grep, Edit, Write, Agent
metadata:
  author: deivithi
  version: "1.0.0"
---

# DRE Zo Integrity Guard

Habilidade especializada em garantir a **precisão contábil**, **integridade de dados de eventos** e **estabilidade de deploy** do sistema **DRE_Eventos** Febracis (`dre-eventos-deivithi.zocomputer.io`).

---

## 🎯 Quando Usar

- Ao auditar cálculos financeiros de eventos presenciais e online (Método CIS, Formação em Coaching, Business, etc.).
- Ao verificar se os chunks de dados e caches (`refresh_cache.py`, `upload_chunks_to_zo.py`) estão consistentes e sincronizados.
- Antes de promover alterações no backend Flask (`DRE_Eventos/`) ou no frontend React.
- Para rodar verificações de integridade nos scripts de conciliação de receitas, taxas de cartão, impostos e despesas de produção.

## 🚫 Quando NÃO Usar (→ Handoff)

| Cenário | Skill recomendada |
|---|---|
| Auditoria geral de comissões comerciais de consultores | `commission-audit` |
| Gestão financeira e orçamento pessoal | `pulso-finance` |
| Automações web Playwright puras | `webwright` |

---

## 📊 Regras Fundamentais de Conciliação DRE

1. **Equação de Margem de Contribuição:**
   $$\text{Margem Contribuição} = \text{Receita Líquida} - (\text{Custos Variáveis} + \text{Impostos} + \text{Taxas Meios Pagamento})$$
2. **Consistência de Chunks:**
   - Nenhum chunk de evento pode conter valores nulos (`NaN` ou `None`) em campos monetários essenciais (`receita_total`, `despesa_total`).
   - A soma dos centros de custos rateados deve bater exatamente 100% do montante alocado.
3. **Deploy Zo Computer:**
   - Validar se o endpoint em produção está respondendo HTTP 200 e com cache atualizado.

---

## 🔄 Workflow de Verificação

1. **Auditoria de Dados Locais:**
   ```powershell
   python skills/dre-zo-integrity-guard/scripts/dre-integrity-check.py --path DRE_Eventos
   ```
2. **Inspeção de Cálculos e Anomalias:**
   - Identificar divergências entre receita faturada e lançamentos no DRE.
3. **Verificação de Saúde do Deploy:**
   - Testar conectividade e integridade do frontend e API no Zo Computer.

---

## 📚 Referências

- [`references/dre-financial-rules.md`](references/dre-financial-rules.md) — Regras de negócio, contas contábeis e estrutura de eventos Febracis.
- [`DRE_Eventos/`](../../DRE_Eventos) — Código-fonte do app.

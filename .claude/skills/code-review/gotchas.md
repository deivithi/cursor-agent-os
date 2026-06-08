# ⚠️ Gotchas — Code Quality & Review

---

## 1. Adversarial review com threshold INFO+ gera 50+ findings e soterram os críticos

- **Sintoma:** Relatório de review tem 50 findings, maioria LOW/INFO. Os 2 CRITICAL se perdem no meio
- **Causa raiz:** Threshold muito baixo para o tipo de review. Quick review não precisa de INFO
- **Solução:** Usar threshold correto por contexto: Quick = MEDIUM+, Full = INFO+. Sempre listar CRITICAL/HIGH primeiro
- **Prevenção:** No relatório, separar por seção de severidade com CRITICAL no topo
- **Descoberto em:** 2026-03-18

---

## 2. Review não detecta bug porque testou apenas o happy path

- **Sintoma:** Code review aprova, mas bug aparece em produção com input edge-case
- **Causa raiz:** Review focou na lógica do caminho feliz. Não testou: null, undefined, array vazio, string muito longa, caracteres especiais
- **Solução:** Adicionar ao checklist: "Testou edge cases?" com lista explícita de cenários
- **Prevenção:** Para funções com input externo, SEMPRE verificar: null, vazio, muito grande, tipo errado, caracteres especiais
- **Descoberto em:** 2026-03-18

---

## 3. Style guide contradiz padrão já estabelecido no codebase

- **Sintoma:** Review marca como "violação de style guide" algo que é o padrão em 90% do codebase
- **Causa raiz:** Style guide foi escrito como ideal mas o codebase real evoluiu diferente. Review aplica a regra escrita, não a prática real
- **Solução:** Quando style guide contradiz prática majoritária do código, seguir a prática existente e atualizar o style guide
- **Prevenção:** Revisar style guide trimestralmente contra o código real. Consistência > perfeição teórica
- **Descoberto em:** 2026-03-18

---

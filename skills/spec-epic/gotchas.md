# ⚠️ Gotchas — spec-epic

## 1. Elicitação insuficiente
**Sintoma:** Ticket 5 revela que requisito fundamental não foi capturado.
**Causa:** Pulou ou apressou o Comando 1 (Trigger).
**Fix:** Investir 3-5 perguntas no trigger. É barato agora, caro depois.

## 2. Epic Brief sem "Fora do Escopo"
**Sintoma:** Stakeholder pede feature que "deveria estar incluída".
**Causa:** Escopo não delimitou fronteiras.
**Fix:** Seção "❌ Fora" é tão importante quanto "✅ Dentro". Listar explicitamente.

## 3. Core Flows sem edge cases
**Sintoma:** Implementação cobre happy path mas falha em cenários reais.
**Causa:** Apenas mapeou fluxo principal.
**Fix:** Sempre incluir seção Edge Cases com cenários Must/Should/Could.

## 4. Tech Plan com stack fantasma
**Sintoma:** Plano propõe usar lib/framework que não está no projeto.
**Causa:** Não verificou stack existente.
**Fix:** SEMPRE verificar package.json, imports existentes, padrões do codebase antes de propor tech plan.

## 5. Tickets gigantes
**Sintoma:** Ticket com 15 acceptance criteria e 8 arquivos.
**Causa:** Não decompôs suficientemente.
**Fix:** 1 ticket = 1 PR. Se tem mais de 5 acceptance criteria, provavelmente são 2 tickets.

## 6. Dependência circular entre tickets
**Sintoma:** Ticket A depende de B que depende de A.
**Causa:** Decomposição sem análise de dependências.
**Fix:** Diagrama de dependências obrigatório. Se circular, extrair componente compartilhado como ticket-fundação.

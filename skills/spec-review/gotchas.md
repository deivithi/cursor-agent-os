# ⚠️ Gotchas — spec-review

## 1. Review sem contexto suficiente
**Sintoma:** Reporta "bug" que é na verdade comportamento intencional.
**Causa:** Não explorou código ao redor e dependências.
**Fix:** Sempre usar subagente Explore para entender contexto antes de classificar.

## 2. Severity inflation
**Sintoma:** Tudo é CRITICAL, relatório perde credibilidade.
**Causa:** Critério frouxo de classificação.
**Fix:** CRITICAL = só se causa crash, perda de dados, ou vulnerabilidade explorável. Se tem workaround → MAJOR.

## 3. Auto-fix introduz regressão
**Sintoma:** Fix de bug introduz novo bug.
**Causa:** Fix sem entender impacto cascata.
**Fix:** Após auto-fix, SEMPRE re-review pelo menos os arquivos modificados.

## 4. Review de PR sem diff focus
**Sintoma:** Reporta issues em código que não foi modificado no PR.
**Causa:** Analisou arquivo inteiro em vez de focar no diff.
**Fix:** Para PRs, focar no diff. Issues em código legacy → registrar como "pre-existing" sem bloquear.

## 5. Categoria errada
**Sintoma:** Performance issue classificado como Bug.
**Causa:** Confusão entre "não funciona" (bug) e "funciona devagar" (performance).
**Fix:** Bug = comportamento incorreto. Performance = comportamento correto mas ineficiente.

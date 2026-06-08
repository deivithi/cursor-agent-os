# ⚠️ Gotchas — spec-verify

## 1. Spec errada como referência
**Sintoma:** Verificação reporta issues que são na verdade features corretas.
**Causa:** Plano/spec desatualizado ou versão errada.
**Fix:** Sempre confirmar com o usuário qual é o plano de referência. Se houve iteração, usar a versão mais recente.

## 2. Auto-fix em cascata
**Sintoma:** Fix de um CRITICAL introduz 2 novos MAJOR.
**Causa:** Fix sem entender impacto nas dependências.
**Fix:** Max 3 loops de auto-fix. Se não convergir, parar e apresentar relatório com o estado atual. Deixar o humano decidir.

## 3. Acceptance criteria ambíguo
**Sintoma:** Critério como "página carrega rápido" — não verificável.
**Causa:** Plano original não seguiu padrão de acceptance criteria do spec-planner.
**Fix:** Antes de verificar, pedir reformulação do critério vago. Se impossível, registrar como "⚠️ Critério não verificável — ignorado".

## 4. Git diff parcial
**Sintoma:** Verificação reporta arquivo "ausente" mas ele foi modificado.
**Causa:** Diff contra branch errada ou mudanças não comitadas.
**Fix:** Usar `git diff main...HEAD` para branch completa, ou `git diff` para uncommitted. Confirmar com `git status`.

## 5. Severity inflation
**Sintoma:** Tudo é CRITICAL, relatório perde valor.
**Causa:** Classificação sem critério rigoroso.
**Fix:** CRITICAL = só se bloqueia funcionalidade core E viola acceptance criteria. Se tem workaround → MAJOR, não CRITICAL.

## 6. Re-verify não detecta regressão
**Sintoma:** Re-verify incremental diz "tudo OK" mas novo bug foi introduzido.
**Causa:** Re-verify incremental só checa issues anteriores, não detecta novos.
**Fix:** Após fix significativo, usar Fresh Verify em vez de incremental.

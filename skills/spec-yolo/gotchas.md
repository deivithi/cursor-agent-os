# ⚠️ Gotchas — spec-yolo

## 1. Loop infinito de fix
**Sintoma:** Fix do bug A introduz bug B, fix do B reintroduz A.
**Causa:** Fixes sem entender impacto cascata.
**Fix:** Max 3 loops é hard limit. Se não convergir, parar e deixar humano decidir.

## 2. Auto-commit sem review
**Sintoma:** Commit com bug CRITICAL que passou despercebido.
**Causa:** Auto-commit ativado com threshold muito baixo.
**Fix:** Auto-commit default = false. Só ativar para tasks de baixo risco com threshold CRITICAL.

## 3. Skip Plan em task complexa
**Sintoma:** Implementação sai completamente errada, verificação encontra 10+ CRITICAL.
**Causa:** Pulou planejamento em task que precisava.
**Fix:** Skip Plan só para tasks simples (1-2 arquivos, bug conhecido). Na dúvida, não skip.

## 4. Context lost entre fases
**Sintoma:** Fase 3 reimplementa o que fase 2 fez, ou desrespeita decisão anterior.
**Causa:** Context carryover não inclui aprendizados.
**Fix:** SEMPRE gerar carryover com: status, issues, aprendizados, e ajustes.

## 5. Sessão longa sem checkpoint
**Sintoma:** Crash no meio da fase 4, precisa refazer tudo.
**Causa:** Sem agent-harness para 5+ fases.
**Fix:** Para 5+ fases, SEMPRE ativar progress tracking com checkpoints.

## 6. Threshold muito baixo (MINOR)
**Sintoma:** YOLO fica em loop fixando nitpicks enquanto CRITICAL real é ignorado.
**Causa:** Threshold MINOR faz auto-fix de tudo, incluindo irrelevante.
**Fix:** Threshold default = MAJOR. MINOR só se explicitamente pedido.

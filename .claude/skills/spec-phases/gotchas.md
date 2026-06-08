# ⚠️ Gotchas — spec-phases

## 1. Fases muito granulares
**Sintoma:** 12 fases para uma feature de 5 arquivos.
**Causa:** Confundiu steps com fases.
**Fix:** Uma fase = uma entrega verificável. Se modifica 1 arquivo só, provavelmente é um step, não uma fase.

## 2. Contexto perdido entre fases
**Sintoma:** Fase 3 re-implementa algo que fase 2 já fez.
**Causa:** Não gerou contexto carryover.
**Fix:** SEMPRE gerar bloco "Contexto da Fase Anterior" com aprendizados, issues e ajustes.

## 3. Scope creep infinito
**Sintoma:** Cada fase descobre algo novo, projeto nunca termina.
**Causa:** Elicitação insuficiente no Step 2.
**Fix:** Max 7 fases. Se precisar de mais, agrupar em épicos. Novas descobertas viram issues para fase futura, não nova fase.

## 4. Fase bloqueada por dependência externa
**Sintoma:** Fase 3 espera API que não existe ainda.
**Causa:** Dependência não mapeada na decomposição.
**Fix:** Na decomposição, marcar dependências externas explicitamente. Oferecer mock/stub como alternativa.

## 5. Verificação skipped por pressa
**Sintoma:** Fase 5 falha porque bug da fase 2 nunca foi detectado.
**Causa:** Pulou spec-verify em fases intermediárias.
**Fix:** Verificação é OBRIGATÓRIA entre fases. Sem exceção. Bug acumulado é 10x mais caro que bug detectado cedo.

# ⚠️ Gotchas — Clean Code Rules

> Problemas conhecidos encontrados durante o uso desta skill. Construído iterativamente a partir de falhas reais.
> **Consulte este arquivo quando algo falhar ou produzir resultado inesperado.**

---

## Regras conflitantes entre fontes

- **Sintoma:** Airbnb diz `export default`, Google TS diz `named exports only`
- **Causa raiz:** Fontes diferentes têm opiniões divergentes em alguns pontos
- **Solução:** Seguir a hierarquia: Google TS > Airbnb > Clean Code JS. Para projetos existentes, seguir a convenção já estabelecida no codebase
- **Prevenção:** Sempre checar convenção existente antes de aplicar regras
- **Descoberto em:** 2026-03-23

---

## Over-engineering ao aplicar regras

- **Sintoma:** Refatorar código funcional só para adequar a regras de estilo
- **Causa raiz:** Aplicar regras sem considerar contexto e escopo da mudança
- **Solução:** Regras de estilo (LOW/MEDIUM) só se aplicam a código que ESTÁ SENDO MODIFICADO. Não refatorar código ao redor da mudança
- **Prevenção:** Respeitar o princípio "Boy Scout Rule" com moderação — limpe o que tocou, não o que está ao lado
- **Descoberto em:** 2026-03-23

---

<!--
INSTRUÇÕES PARA MANUTENÇÃO:
1. Adicione novos gotchas NO TOPO (mais recentes primeiro)
2. Use o formato acima para consistência
3. Se um gotcha for resolvido permanentemente, mova para ## Resolvidos no final
4. Gotchas devem ser específicos e acionáveis — não genéricos
5. Inclua o sintoma exato para facilitar busca futura
-->

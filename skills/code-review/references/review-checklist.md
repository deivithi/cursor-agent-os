# ✅ Review Checklist — Por Tipo de Mudança

## Feature Nova

### Lógica
- [ ] Lógica de negócio está correta e completa?
- [ ] Edge cases tratados (null, vazio, overflow)?
- [ ] Error handling adequado (try/catch, fallbacks)?
- [ ] Sem side effects inesperados?

### Qualidade
- [ ] Funções < 50 linhas?
- [ ] Nomes descritivos e consistentes?
- [ ] Sem código duplicado (DRY)?
- [ ] Sem TODO/FIXME/HACK não documentados?

### Segurança
- [ ] Input validado (Zod)?
- [ ] Sem dados sensíveis em logs?
- [ ] Sem secrets em código?
- [ ] Auth/authz correto para o endpoint?

### Testes
- [ ] Testes unitários existem?
- [ ] Happy path coberto?
- [ ] Pelo menos 1 edge case coberto?
- [ ] Testes passam localmente?

---

## Bug Fix

### Correção
- [ ] Bug root cause identificado (não apenas sintoma)?
- [ ] Fix resolve o bug sem introduzir novos?
- [ ] Cenário original reproduzido e verificado?
- [ ] Regression test adicionado?

### Impacto
- [ ] Fix não quebra funcionalidades adjacentes?
- [ ] Performance não degradou?
- [ ] Fix é o mínimo necessário (não over-engineering)?

---

## Refactoring

### Preservação
- [ ] Comportamento externo inalterado?
- [ ] Testes existentes continuam passando?
- [ ] API pública (exports) não quebrou?
- [ ] Performance não degradou?

### Melhoria
- [ ] Código mais legível que antes?
- [ ] Complexidade reduzida (menos nesting, funções menores)?
- [ ] Naming melhorou?

---

## Migration / Database

### Segurança
- [ ] RLS habilitado (Supabase)?
- [ ] Policies corretas para o caso de uso?
- [ ] Sem CASCADE em foreign keys de produção?
- [ ] Rollback statement documentado?

### Dados
- [ ] Migration é idempotente (pode rodar 2x sem erro)?
- [ ] Dados existentes não serão corrompidos?
- [ ] Indices necessários criados?
- [ ] ◆ DIAMOND GATE para aplicação em produção

---

## Severity Quick Reference

| Encontrou | Severidade | Ação |
|-----------|-----------|------|
| SQL injection, XSS, auth bypass | 🔴 CRITICAL | BLOQUEAR |
| Bug lógico, data loss possível | 🟠 HIGH | FIX obrigatório |
| Missing validation, code smell | 🟡 MEDIUM | Sugerir fix |
| Naming, estilo, preferência | 🟢 LOW | Anotar |
| Contexto, observação | ⚪ INFO | Informar |

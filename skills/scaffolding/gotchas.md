# ⚠️ Gotchas — Code Scaffolding

> Problemas conhecidos ao usar generators de código. Consulte quando algo falhar.

---

## 1. Template com imports absolutos falha quando projeto usa path aliases diferentes

- **Sintoma:** Código scaffoldado tem `import { X } from '@/lib/...'` mas o projeto usa `import { X } from '~/lib/...'`
- **Causa raiz:** Template foi criado com convenção `@/` (Next.js default) mas o projeto Aria usa `~/` ou paths relativos
- **Solução:** Antes de gerar, verificar `tsconfig.json` → `paths` para saber o alias correto do projeto
- **Prevenção:** Templates devem usar placeholder `{{PATH_ALIAS}}` em vez de hardcodar `@/`
- **Descoberto em:** 2026-03-18

---

## 2. Migration gerada sem RLS causa acesso público não intencional

- **Sintoma:** Tabela nova no Supabase fica acessível publicamente via `anon` key — qualquer pessoa pode ler/escrever
- **Causa raiz:** Supabase habilita RLS por default mas se não houver policies, a tabela fica efetivamente sem acesso (ou com acesso total se RLS não foi habilitado)
- **Solução:** SEMPRE incluir no scaffold: `ALTER TABLE nome ENABLE ROW LEVEL SECURITY;` + pelo menos 1 policy
- **Prevenção:** Template de migration DEVE incluir RLS como bloco obrigatório, nunca opcional
- **Descoberto em:** 2026-03-18

---

## 3. Componente scaffoldado com nome genérico causa conflito de export

- **Sintoma:** `Module '"./components"' has no exported member 'Card'` — já existe outro componente com mesmo nome
- **Causa raiz:** Template gera componente com nome genérico (Card, Button, Modal) sem verificar se já existe no projeto
- **Solução:** Antes de gerar, buscar `grep -r "export.*function NomeComponente" src/` para verificar conflito
- **Prevenção:** Script de scaffold deve verificar existência antes de criar e sugerir nome alternativo
- **Descoberto em:** 2026-03-18

---

---
name: scaffolding
description: >
  Gera boilerplate e estrutura de código para projetos usando templates padronizados.
  Inclui scaffolding de rotas API, migrations Supabase, componentes React e novos
  projetos. Templates incluem requisitos em linguagem natural que código puro não cobre.
domain: developer-tools
subdomain: code-generation
version: 1.0.0
author: deivithi
tags:
  - scaffolding
  - templates
  - boilerplate
  - code-generation
  - api-route
  - migration
  - component
  - supabase
  - react
---

# 🏗️ Code Scaffolding — Templates e Generators de Código

> **"Scaffolding skills são especialmente úteis quando seu boilerplate tem requisitos em linguagem natural que código puro não cobre."** — Thariq, Anthropic

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelos Generators abaixo.
- `scripts/scaffold-api-route.sh` — Gera rota API no padrão do projeto.
- `scripts/scaffold-migration.sh` — Gera migration Supabase com template.
- `templates/api-route.ts.template` — Template de rota API (Express/Hono).
- `templates/supabase-migration.sql.template` — Template de migration SQL.
- `templates/component.tsx.template` — Template de componente React.
- `gotchas.md` — ⚠️ Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `cicd` — Use para deploy após scaffolding de novo componente
- `product-verification` — Use para verificar que o código scaffoldado funciona
- `code-review` — Use para review do código gerado (Wave 5)

---

## 1. Conceito

Scaffolding skills geram **estrutura de código padronizada** para funções específicas do codebase. O diferencial sobre templates puros é que incluem:

- **Convenções em linguagem natural** (como nomear, onde colocar, o que documentar)
- **Gotchas específicos** do projeto (o que NÃO fazer)
- **Scripts compostos** para gerar múltiplos arquivos de uma vez
- **Validação pós-geração** (verificar que imports estão corretos, types compilam)

---

## 2. Generators Disponíveis

### 2.1 API Route (Aria)

Gera uma rota API completa seguindo o padrão do Aria:

**Uso:**
```
Scaffold uma nova rota API para [funcionalidade]
```

**O que é gerado:**
- Arquivo de rota com handler tipado
- Validação de input (Zod)
- Error handling padronizado
- Logging estruturado (Pino)
- Testes básicos

**Convenções obrigatórias:**
1. Toda rota DEVE ter validação de input via Zod schema
2. Toda rota DEVE retornar resposta tipada (`ApiResponse<T>`)
3. Erros DEVEM ser capturados e retornados em formato padronizado
4. Rota DEVE ser registrada no router principal

**Template:** `templates/api-route.ts.template`

### 2.2 Migration Supabase

Gera uma migration SQL para Supabase:

**Uso:**
```
Scaffold uma migration para [tabela/alteração]
```

**O que é gerado:**
- Arquivo SQL com timestamp no nome
- Comentários explicativos
- RLS policies padrão
- Rollback statement (comentado)

**Convenções obrigatórias:**
1. SEMPRE incluir RLS policy para nova tabela
2. SEMPRE incluir `created_at` e `updated_at` com defaults
3. NUNCA usar `CASCADE` em foreign keys de produção sem aprovação
4. Nome do arquivo: `YYYYMMDDHHMMSS_descricao_curta.sql`

**Template:** `templates/supabase-migration.sql.template`

### 2.3 Componente React

Gera um componente React seguindo o design system:

**Uso:**
```
Scaffold um componente React para [funcionalidade]
```

**O que é gerado:**
- Componente funcional com TypeScript
- Props interface tipada
- Estilização com Tailwind
- Export nomeado

**Convenções obrigatórias:**
1. Componentes DEVEM ser funções (não classes)
2. Props DEVEM ter interface explícita (não inline)
3. Estilização via Tailwind (não CSS modules)
4. Acessibilidade: incluir `aria-label` em elementos interativos

**Template:** `templates/component.tsx.template`

---

## 3. Como Criar Novos Generators

Para adicionar um novo tipo de scaffold:

1. Criar template em `templates/nome.template`
2. Criar script em `scripts/scaffold-nome.sh`
3. Adicionar seção neste SKILL.md
4. Documentar convenções obrigatórias

O template usa placeholders: `{{NOME}}`, `{{DESCRICAO}}`, `{{TIMESTAMP}}` que são substituídos pelo script.

---

## 4. Boas Práticas

1. **Templates > Instruções** — Dar um arquivo template concreto é 10x mais efetivo que descrever o formato desejado
2. **Convenções são o valor** — O template garante estrutura; as convenções em linguagem natural garantem consistência
3. **Validar pós-geração** — Rodar `tsc --noEmit` ou equivalente para garantir que o código gerado compila
4. **Iterar nos templates** — Cada problema encontrado em código scaffoldado deve virar melhoria no template

# 🏭 Supabase Factory — Rule de Ativação

> Ativa skill `.claude/skills/supabase-factory/SKILL.md` quando o contexto envolver provisionamento de banco Supabase.

## Quando ativar

Keywords que disparam a factory:

- "criar banco", "novo banco supabase", "provisionar banco"
- "onde subo essa tabela", "onde criar tabela", "onde subir"
- "novo schema", "criar schema", "separar schema"
- "novo módulo supabase", "novo módulo precisa de banco"
- "criar projeto supabase" (intercept — factory decide se schema ou projeto)
- "supabase branch", "ambiente dev supabase", "branch staging"
- "separar contextos", "modularizar public"
- "nova aplicação" + contexto de banco

## Comportamento

1. Ao detectar keyword → carregar `.claude/skills/supabase-factory/SKILL.md`
2. Ler `references/schemas-catalog.md` p/ contexto atual
3. Aplicar decision tree (`references/decision-tree.md`)
4. Executar workflow do SKILL.md (8 passos)

## Defaults travados

- **Org:** `deivithi's Org` (`nayypuosrfhhrkorfszw`)
- **Projeto:** `febracis-dre` (`vwxgrjjwbvdiaqxqbryk`)
- **Region:** `sa-east-1`
- **Novo produto separado** → exige confirmação verbose (custo)
- **Pulso Finance** → fora do escopo (projeto próprio)

## Safety carve-out

Operações destrutivas (`DROP SCHEMA`, `DROP TABLE`, `TRUNCATE`, `DELETE` sem WHERE, migration direto em prod) seguem regras de `feedback_supabase_safety.md` e `vibe-deploy-guard.md`. Skill pausa e exige confirmação explícita.

## Fonte de verdade

- `.claude/skills/supabase-factory/SKILL.md` — hub principal
- `.claude/skills/supabase-factory/references/` — 5 arquivos detalhados
- `.claude/skills/supabase-factory/gotchas.md` — 17 armadilhas conhecidas

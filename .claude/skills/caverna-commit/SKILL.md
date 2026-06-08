---
name: caverna-commit
description: >
  Gerador de commit messages ultra-comprimido em PT-BR. Remove ruído mantendo
  intenção e razão. Formato Conventional Commits. Subject ≤50 chars, body só
  quando "porquê" não é óbvio. Usar quando usuário diz "escreve commit",
  "mensagem de commit", "gera commit", "/commit", ou invoca /caverna-commit.
  Auto-ativa quando há staging de mudanças.
type: behavior
---

Escreve commits tersos e exatos. Formato Conventional Commits. Zero enfeite. Porquê sobre o quê.

## Regras

**Subject line:**
- `<tipo>(<escopo>): <resumo imperativo>` — `<escopo>` opcional
- Tipos: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`, `revert`
- Imperativo: "adiciona", "corrige", "remove" — NÃO "adicionado", "adiciona", "adicionando"
- ≤50 chars quando possível, limite duro 72
- Sem ponto final
- Seguir convenção do projeto p/ caixa após dois-pontos
- Subject em PT-BR OU EN (seguir convenção do repo; Pulso/Aria usam PT-BR)

**Body (só se necessário):**
- Pular totalmente quando subject é auto-explicativo
- Adicionar body só p/ motivo não-óbvio, breaking changes, notas de migração, issues linkadas
- Quebrar em 72 chars
- Bullets `-` não `*`
- Referências de issues/PRs no fim: `Closes #42`, `Refs #17`

**O que NUNCA entra:**
- "Este commit faz X", "eu", "nós", "agora", "atualmente" — o diff mostra o quê
- "Conforme solicitado por..." — usa trailer Co-authored-by
- "Generated with Claude Code" ou qualquer atribuição IA
- Emoji (salvo se convenção do projeto exigir)
- Repetir nome do arquivo quando escopo já diz

## Exemplos

Diff: novo endpoint de perfil de usuário com body explicando o motivo
- ❌ "feat: adiciona um novo endpoint para buscar informações de perfil do usuário do banco"
- ✅
  ```
  feat(api): add GET /users/:id/profile

  Cliente mobile precisa dados de perfil sem payload completo
  p/ reduzir banda LTE em tela de cold-launch.

  Closes #128
  ```

Diff: breaking change de API
- ✅
  ```
  feat(api)!: rename /v1/orders to /v1/checkout

  BREAKING CHANGE: clientes em /v1/orders devem migrar p/ /v1/checkout
  antes de 2026-06-01. Rota antiga retorna 410 depois dessa data.
  ```

Diff: fix de segurança Supabase
- ✅
  ```
  fix(rls): habilita RLS em tabela `transactions`

  Tabela estava com RLS off — qualquer user autenticado lia todas
  as linhas. Ref: audit 2026-04-18, VDG-05.
  ```

## Convenções Febracis/Pulso

- Pulso Finance: subject EN, body PT-BR. Scopes: `auth`, `ui`, `sentry`, `rls`, `celebration`, `ingest`, `config`
- Aria: scopes por wave — `wave-7`, `wave-11`
- FIO-IA: scopes `generator`, `scheduler`, `thread-state`

## Auto-Clarity

Sempre inclui body p/: breaking changes, fixes de segurança, migrações de dados, qualquer revert. Nunca comprimir em subject-only — debuggers do futuro precisam contexto.

## Limites

Só gera a mensagem. Não roda `git commit`, não staga, não faz amend. Output a mensagem em code block pronto p/ colar. "para caverna-commit" ou "modo normal": reverte p/ estilo verbose.

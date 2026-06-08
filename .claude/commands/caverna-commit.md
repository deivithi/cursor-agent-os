# 🪨 Caverna Commit — Mensagem Terse PT-BR

Gera mensagem de commit terse p/ mudanças em staging.

## Ação

Ativa skill `caverna-commit`. Formato Conventional Commits:

```
<tipo>(<escopo>): <resumo imperativo>

[body opcional — só se "porquê" não óbvio]

[trailer opcional — Closes #N, Co-authored-by]
```

## Regras

- Subject ≤50 chars (limite duro 72)
- Imperativo: "adiciona", "corrige", "remove"
- Sem ponto final no subject
- Body só quando motivo não-óbvio, breaking change, migração
- Tipos: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`, `revert`

## Nunca

- "Este commit faz X", "eu", "nós", "agora"
- "Generated with Claude Code" ou atribuição IA
- Emoji (salvo convenção do projeto)
- Repetir nome do arquivo quando escopo já diz

## Sempre body p/

- Breaking changes
- Fixes de segurança
- Migrações de dados
- Reverts

## Exemplos stack Deivithi

**Pulso Finance:**
```
feat(celebration): adiciona toast em primeira transação do mês

Cliente pediu feedback visual ao bater meta. Toast some em 3s.
```

**Supabase RLS fix:**
```
fix(rls): habilita RLS em tabela `transactions`

Tabela estava com RLS off — VDG-05. Audit 2026-04-18.
```

**Aria wave:**
```
feat(wave-11): integra Telegram webhook c/ circuit breaker
```

## Limite

Só gera a mensagem. Não roda `git commit`, não staga, não amenda. Output em code block pronto p/ colar.

Ref: `.claude/skills/caverna-commit/SKILL.md`

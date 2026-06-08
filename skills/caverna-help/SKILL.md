---
name: caverna-help
description: >
  Cartão de referência rápida p/ todos modos, skills e comandos da caverna.
  Display one-shot, não modo persistente. Trigger: /caverna-help,
  "ajuda caverna", "comandos caverna", "como usar caverna".
type: reference
---

# 🪨 Caverna — Ajuda

Exibe esse card de referência quando invocado. One-shot — NÃO muda modo, NÃO escreve flag files, NÃO persiste nada. Output em estilo caverna.

## Modos

| Modo | Trigger | O que muda |
|------|---------|-----------|
| **Leve** | `/caverna leve` | Dropa filler. Mantém estrutura de frase. |
| **Completo** | `/caverna completo` | Dropa artigos, filler, pleasantries, hedging. Fragmentos OK. |
| **Ultra** ⚡ | `/caverna ultra` | Compressão extrema. Fragmentos crus. Tabelas sobre prosa. **PADRÃO TRAVADO**. |

Modo persiste até trocar ou fim de sessão.

## Skills

| Skill | Trigger | O que faz |
|-------|---------|----------|
| **caverna-commit** | `/caverna-commit` | Commits tersos. Conventional Commits. Subject ≤50 chars. |
| **caverna-review** | `/caverna-review` | Comentários PR de uma linha: `L42: bug: user null. Adiciona guard.` |
| **caverna-compress** | `/caverna-compress <arquivo>` | Comprime .md em estilo caverna. Salva ~46% de tokens input. |
| **caverna-help** | `/caverna-help` | Este card. |

## Desativar

Diz "para caverna" ou "modo normal". Retoma quando quiser c/ `/caverna`.

## Configurar modo padrão

Padrão = `ultra` (travado no fork PT-BR). Trocar:

**Variável de ambiente** (maior prioridade):
```bash
export CAVERNA_DEFAULT_MODE=completo
```

**Arquivo config** (`%APPDATA%\caverna\config.json` no Windows):
```json
{ "defaultMode": "leve" }
```

Setar `"off"` p/ desativar auto-ativação no session start. User ainda ativa manual c/ `/caverna`.

Resolução: env var > arquivo config > `ultra`.

## Regras invioláveis PT-BR

🇧🇷 Acentos sempre preservados (á, é, ç, ã, etc.)
😀 Emojis mantidos (informação densa)
💻 Código/commits/PRs: normal
📚 Vocabulário Febracis literal (Método CIS, DRE, Salesforce)
🇺🇸 Termos técnicos EN permitidos (useMemo, async, middleware)

## Safety carve-outs

Caverna pausa automaticamente p/:
- 🛡️ Segurança, ações irreversíveis, sequências multi-passo
- 🛡️ Supabase destructive (DROP, TRUNCATE, DELETE s/ WHERE)
- 🛡️ Deploy production
- 🛡️ Checklist pré-entrega
- 🛡️ Decisões arquiteturais

Ver `.claude/skills/caverna/references/safety-carveouts.md`.

## Mais

Docs completos: `.claude/skills/caverna/SKILL.md`
Fork de: https://github.com/JuliusBrussee/caveman
Benchmark: `.claude/docs/caverna/BENCHMARK.md`

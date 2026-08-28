# OpenWiki Personal Brain — Gotchas

## Bun + better-sqlite3 no Windows

OpenWiki pode depender de `better-sqlite3` (binding nativo). No Windows:

- Preferir instalação via **npm global** (`npm install -g openwiki@latest`) — usa Node, não Bun
- Se erro de compilação nativa: instalar [Visual Studio Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/) com "Desktop development with C++"
- **Não** misturar runtime Bun com bindings compilados para Node no mesmo path

## LaunchAgent ≠ Windows

- macOS: `openwiki personal --schedule` cria LaunchAgents
- Windows: **não existe** LaunchAgent — usar Hermes cron ou Task Scheduler
- Padrão canônico neste ecossistema: **Hermes** (`%LOCALAPPDATA%\hermes\cron\jobs.json`)

## Secrets — só em ~/.openwiki/.env

| ✅ Correto | ❌ Proibido |
|-----------|-------------|
| `~/.openwiki/.env` (API keys, tokens) | Secrets em `Documents\Cursor\` |
| OAuth tokens gerenciados pelo CLI | Commits com `.env` |
| Referência ao path na skill/docs | Copiar tokens para AGENT_MEMORY |

Variáveis típicas (nomes podem variar por versão — verificar README oficial):

- Provider LLM (Anthropic/OpenAI/etc.)
- X API credentials (após `openwiki auth x`)

## X API pay-per-use (2026)

- Novos apps: sem free tier geral
- Bookmarks requerem scope `bookmark.read` + créditos na conta developer
- Custo aproximado: ~$0.001 por recurso "owned read"
- Sem créditos → `personal --update` pode completar sem novos raw files

## Hermes cron — script extension

- Cron `script` field: `.sh`/`.bash` → bash; **tudo mais → Python**
- **Nunca** usar `.ps1` no campo `script` do Hermes
- Watchdog/update scripts devem ser `.py` em `%LOCALAPPDATA%\hermes\scripts\`

## Deliver=origin no desktop

- Jobs com `deliver: origin` podem falhar entrega se só desktop (sem Telegram/Discord)
- Job de update OpenWiki usa `deliver: null` — silencioso por design
- Verificar `last_status` em `jobs.json`, não `last_delivery_error`

## FIO-IA vs OpenWiki

- FIO-IA: **publica** conteúdo no X (Hermes 4×/dia)
- OpenWiki: **ingere** bookmarks/timeline
- Não confundir direções; não duplicar lógica entre os dois

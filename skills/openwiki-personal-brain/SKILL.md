---
name: openwiki-personal-brain
description: Configura e opera o OpenWiki Personal Brain (ingestão X/Twitter com ênfase em bookmarks, wiki Markdown em ~/.openwiki/wiki, schedule Hermes). Use quando o usuário mencionar OpenWiki, personal brain, bookmarks X, favoritos Twitter, memória proativa de feed, ou precisar ler sinais salvos no X.
---

# OpenWiki Personal Brain

Memória **proativa** do ecossistema Deivithi: connectors puxam fontes → raw em `~/.openwiki/connectors/<fonte>/raw/` → agente sintetiza wiki Markdown local em `~/.openwiki/wiki`.

**Fontes oficiais:**
- [langchain-ai/openwiki](https://github.com/langchain-ai/openwiki)
- [LangChain Blog — OpenWiki Brains](https://www.langchain.com/blog/introducing-openwiki-brains-general-purpose-wiki-memory-for-agents)

## Quando usar

- Tarefa precisa de **sinais salvos no X** (bookmarks, timeline, menções)
- Usuário pede memória proativa de feed / favoritos
- Setup, update, auth ou troubleshooting do Personal Brain
- Integrar leitura da wiki com CONTEXT.md / AGENT_MEMORY (ponte, não fusão)

## Dois modos (não confundir)

| Modo | Path | Escopo neste ecossistema |
|------|------|--------------------------|
| **Personal Brain** | `~/.openwiki/wiki` | ✅ Piloto canônico (connector X) |
| Code Brain | `openwiki/` no repo | ❌ Fora de escopo |

## Anti-Frankenstein (obrigatório)

| Camada | Papel | Não fazer |
|--------|-------|-----------|
| CONTEXT.md / AGENT_MEMORY.md | Memória **reativa** e permanente | Não fundir conteúdo da wiki aqui |
| OpenWiki wiki | Memória **proativa** (feed/bookmarks) | Não substituir CONTEXT |
| FIO-IA | **Publica** fios no X | Direção oposta; complementar |
| MCP `user-xapi` | Docs/busca do site X | OpenWiki = ingestão da **conta** |
| Hermes cron | Único scheduler (substitui LaunchAgent macOS) | Não criar segundo cron |

**Regra:** CONTEXT.md aponta para `~/.openwiki/wiki` — **ponteiro apenas**, sem duplicar fatos permanentes.

## Gate de custo — X API (pay-per-use)

Em 2026 a X API para novos apps é **pay-per-use** (sem free tier geral).

- Bookmarks = "owned reads" (~$0.001/recurso) com OAuth scope `bookmark.read`
- Sem créditos na developer console → ingestão do connector `x` **falha**
- Pré-requisito: conta X Developer com créditos + app OAuth para `openwiki auth x`

**Antes de `openwiki auth x`**, gravar em `~/.openwiki/.env`:

```env
OPENWIKI_X_CLIENT_ID=<seu_app_client_id>            # obrigatório
# OPENWIKI_X_CLIENT_SECRET=<...>                    # opcional — só se client confidential (PKCE / clientAuth none)
```

**Não armazenar secrets no repo.** Apenas em `~/.openwiki/.env`.

## Instalação (Windows / PowerShell)

```powershell
npm install -g openwiki@latest
openwiki personal --help
```

Gotchas Windows: ver [gotchas.md](gotchas.md).

## Setup inicial

```powershell
# 1. Inicializar Personal Brain (interativo — escolhe provider LLM)
openwiki personal --init

# 2. Autenticar connector X (OAuth no browser — passo manual)
openwiki auth x

# 3. Configurar instruções de escopo (ênfase bookmarks)
# Editar ~/.openwiki/INSTRUCTIONS.md — ver seção abaixo

# 4. Primeira ingestão + síntese
openwiki personal --update
```

### INSTRUCTIONS.md — ênfase bookmarks/favoritos

Gravar em `~/.openwiki/INSTRUCTIONS.md` (português OK):

```markdown
# Escopo do Personal Brain — Deivithi

## Prioridade máxima: bookmarks/favoritos

Ao sintetizar a wiki, **bookmarks (favoritos) no X/Twitter têm peso maior** que timeline genérica ou menções.

- Bookmarks = sinais que o usuário marcou para revisitar — trate como intenção explícita
- Agrupe bookmarks por tema, extraia insights acionáveis (PO Salesforce, automação, IA)
- Timeline e menções entram como contexto secundário

## Tom e foco

- pt-BR
- Foco: governança de processos, automação, inteligência comercial, integração negócio×tech
- Markdown auditável; cite IDs de posts quando disponível em raw

## Não fazer

- Não duplicar CONTEXT.md ou AGENT_MEMORY.md
- Não inventar conteúdo ausente em raw
```

## Schedule — Hermes (Windows)

OpenWiki usa LaunchAgents no macOS. No Windows → **Hermes cron** (padrão do stack).

Job canônico: `openwiki personal --update` **1×/dia** às 06:00 BRT.

- Script: `%LOCALAPPDATA%\hermes\scripts\openwiki-personal-update.py`
- Cron expr: `0 6 * * *`
- `no_agent: true`, `deliver: null` (silencioso; stdout vazio = ok)

Ver job em `%LOCALAPPDATA%\hermes\cron\jobs.json` (ID documentado em AGENT_MEMORY.md).

## Ponte com CONTEXT.md

No checklist de inicialização do agente, se a tarefa precisa de sinais salvos no X:

1. Ler `~/.openwiki/wiki/` (Markdown)
2. Opcional: raw em `~/.openwiki/connectors/x/raw/` para auditoria
3. Cruzar com AGENT_MEMORY.md (fatos permanentes) — **não** substituir

## Comandos de validação

```powershell
# CLI ok?
openwiki personal --help

# Auth X configurada?
openwiki auth list

# Wiki gerada?
Get-ChildItem "$env:USERPROFILE\.openwiki\wiki" -Recurse

# Raw do connector X?
Get-ChildItem "$env:USERPROFILE\.openwiki\connectors\x\raw" -ErrorAction SilentlyContinue
```

## Troubleshooting

| Sintoma | Causa provável | Ação |
|---------|----------------|------|
| `openwiki` não encontrado | CLI não instalada | `npm install -g openwiki@latest` |
| Auth X falha | OAuth incompleto ou sem créditos API | Completar OAuth; verificar créditos em developer.x.com |
| Update sem arquivos | Auth pendente ou API sem crédito | `openwiki auth x` + verificar `.env` |
| Bun/sqlite3 error no Windows | better-sqlite3 nativo | Ver [gotchas.md](gotchas.md) |
| Cron não roda | Hermes desktop fechado | Abrir Hermes; verificar `jobs.json` |

## Checklist de piloto

```
- [ ] npm install -g openwiki@latest
- [ ] openwiki personal --init
- [ ] openwiki auth x (OAuth manual)
- [ ] INSTRUCTIONS.md com ênfase bookmarks
- [ ] openwiki personal --update
- [ ] Arquivos em ~/.openwiki/wiki
- [ ] Hermes cron 06:00 BRT
- [ ] AGENT_MEMORY + CONTEXT + SKILLS_INDEX atualizados
```

## Recursos

- Gotchas Windows/X API: [gotchas.md](gotchas.md)
- Hermes cron patterns: skill `cronjob-authoring` em `%LOCALAPPDATA%\hermes\skills\`

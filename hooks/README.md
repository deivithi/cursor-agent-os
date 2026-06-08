# Hooks — Caverna / Statusline

## Decisão (2026-05-27)

| Runtime | Status | Onde |
|---------|--------|------|
| **Cursor IDE + Agent** | ✅ Primário | `~/.cursor/hooks.json` |
| **Cursor CLI** | ✅ Statusline | `~/.cursor/cli-config.json` → `statusLine` |
| **Claude Code** | ⚠️ Fallback opcional | `~/.claude/hooks/` (mesmos scripts, formato legacy) |

**Não duplicar lógica.** Fonte única: `Documents/Cursor/hooks/`. Sync via `migrate-from-documents.ps1`.

## Cursor Hooks (`~/.cursor/hooks.json`)

| Evento | Script | Função |
|--------|--------|--------|
| `sessionStart` | `caverna-activate.js` | Injeta ruleset completo (`additional_context`) |
| `beforeSubmitPrompt` | `caverna-mode-tracker.js` | `/caverna`, ativação PT-BR, flag de modo |
| `beforeSubmitPrompt` | `profile-tracker.js` | `/profile`, keywords → domain rules |
| `preToolUse` | `caverna-reinforce.js` | Reforço caverna via `agent_message` |
| `preToolUse` | `domain-reinforce.js` | Lembrete das domain rules ativas |

## Profiles + domain rules

| Hook | Função |
|------|--------|
| `profile-session.js` | Profile ativo + rules `*-activate.md` no `sessionStart` |
| `profile-tracker.js` | Comandos `/profile` + detecção por keywords |
| `domain-reinforce.js` | Reforço curto antes de tools |

Manifest: `~/.cursor/rules/activation-manifest.json`  
Flags: `~/.cursor/.profile-active`, `~/.cursor/.domain-active.json`

## Flag de modo

- Cursor: `~/.cursor/.caverna-active`
- Claude Code (fallback): `~/.claude/.caverna-active`
- Override: env `CAVERNA_FLAG_PATH`

## Statusline

Badge `[🪨 CAVERNA:ULTRA]` no **Cursor CLI**:

```json
"statusLine": {
  "type": "command",
  "command": "powershell -ExecutionPolicy Bypass -File \"C:\\Users\\deivithi.lopes\\.cursor\\hooks\\caverna-statusline.ps1\"",
  "padding": 0
}
```

## Claude Code (opcional)

Se usar Claude Code, copie `hooks/` para `~/.claude/hooks/` e configure `settings.local.json` com `statusLine` apontando para `caverna-statusline.ps1`. Os scripts detectam runtime via `CURSOR_VERSION` / `CURSOR_PROJECT_DIR`.

## Teste rápido

```powershell
# sessionStart (Cursor)
$env:CURSOR_VERSION = "test"
'{"session_id":"t","composer_mode":"agent"}' | node "$env:USERPROFILE\.cursor\hooks\caverna-activate.js"

# beforeSubmitPrompt
'{"prompt":"/caverna ultra"}' | node "$env:USERPROFILE\.cursor\hooks\caverna-mode-tracker.js"
```

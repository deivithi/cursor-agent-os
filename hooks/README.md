# Hooks — Caverna / Statusline

## Decisão (2026-05-27)

| Runtime | Status | Onde |
|---------|--------|------|
| **Cursor IDE + Agent** | ✅ Primário | `~/.cursor/hooks.json` |
| **Cursor CLI** | ✅ Statusline | `~/.cursor/cli-config.json` → `statusLine` |
| **Claude Code** | ⚠️ Fallback opcional | `~/.claude/hooks/` (mesmos scripts, formato legacy) |

**Não duplicar lógica.** Fonte única: `Documents/Cursor/hooks/`. Sync via `migrate-from-documents.ps1`.

## Grok Build TUI (2026-09-08)

Grok importa `~/.claude/settings.json` e `~/.cursor/hooks.json` por default (`compat.*.hooks = true`). Isso disparava **3+ hooks PowerShell por tool** (Orca EncodedCommand + profile/domain + prettier com `$f`), todos lendo stdin até EOF → timeout 10–15s em quase toda chamada.

Isolamento:

| Runtime | Hooks que rodam |
|---------|-----------------|
| **Grok** | só `~/.grok/hooks/*.json` (Orca `grok-hook.cmd` direto, sem PowerShell) |
| **Cursor** | `~/.cursor/hooks.json` |
| **Claude Code** | `~/.claude/settings.json` |

Travas em `~/.grok/config.toml`: `compat.claude.hooks = false` e `compat.cursor.hooks = false`.

Orca: chamar `*.cmd` direto. `readStdinJson()` tem timeout 1,5s (fail-open). `prettier-after-edit.js` não usa `$` no command string.

## Cursor Hooks (`~/.cursor/hooks.json`)

| Evento | Script | Função |
|--------|--------|--------|
| `sessionStart` | `caverna-activate.js` | Injeta ruleset completo (`additional_context`) |
| `beforeSubmitPrompt` | `caverna-mode-tracker.js` | `/caverna`, ativação PT-BR, flag de modo |
| `beforeSubmitPrompt` | `profile-tracker.js` | `/profile`, keywords → domain rules |
| `sessionStart` | `profile-session.js` | Profile + domain rules |
| `sessionStart` | `agent-reach-path.ps1` | PATH do Agent Reach |
| `beforeSubmitPrompt` | `caverna-mode-tracker.js` | `/caverna`, ativação PT-BR, flag de modo |
| `beforeSubmitPrompt` | `profile-tracker.js` | `/profile`, keywords → domain rules |
| `preToolUse` | `git-safety-guard.js` | Guard de git/test-integrity |
| `preToolUse` | `caverna-reinforce.js` | Reforço caverna via `agent_message` |
| `preToolUse` | `domain-reinforce.js` | Lembrete das domain rules ativas |

Orca (`cursor-hook.cmd`) roda em sessionStart / beforeSubmitPrompt / preToolUse / postToolUse / stop. Sem PowerShell EncodedCommand. Sem `hook-healthcheck --audit` em todo prompt.

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

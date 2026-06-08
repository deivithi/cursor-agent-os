# Hub Cursor — Deivithi (Febracis)

> **Fonte única:** pastas na raiz de `Documents\Cursor` (não duplicar aqui).

## Estrutura (raiz)

| Pasta | Conteúdo |
|-------|----------|
| `skills/` | Skills customizadas (Febracis, n8n, spec-driven, leads…) |
| `commands/` | Slash commands (`/caverna`, `/spec`, `/n8n`…) |
| `rules/` | Rules de ativação e domínio |
| `hooks/` | Hooks (caverna, statusline) |
| `reports/` | Audits e registros de plugins/skills |
| `config.json` | Perfil, stack e projetos ativos |
| `HARNESS.md` | SOP agent harness / CLI-anything |

## Runtime

- **Global:** espelhado em `~/.cursor/` via `migrate-from-documents.ps1`
- **Skills globais:** `~/.cursor/skills/`
- **Commands globais:** `~/.cursor/commands/`

## Sync

```powershell
# Manual (com output)
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Documents\Cursor\scripts\migrate-from-documents.ps1"

# Agendado: Task Scheduler \Febracis-Cursor-SyncDaily (08:00, diário)
# Log: %LOCALAPPDATA%\febracis-logs\cursor-sync.log
```

Pastas sincronizadas: `skills`, `commands`, `rules`, `hooks`, `profiles`, `cybersecurity-skills`, `scientific-skills`, `data`, `HARNESS.md`, `hooks.json`.

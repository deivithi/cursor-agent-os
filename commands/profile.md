# Profile — Gerenciamento de Perfis de Contexto

Operação: **$ARGUMENTS**

## Subcomandos

### `/profile list`
Lista profiles em `.cursor/profiles/` (via manifest + disco).

### `/profile <nome>`
Ativa perfil na sessão:
1. Persiste flag em `~/.cursor/.profile-active`
2. Hook `profile-tracker.js` grava na hora; `profile-session.js` injeta no próximo chat
3. Para efeito imediato na sessão atual: descrever o profile ou abrir novo Agent chat

Perfis: `febracis-salesforce`, `aria-dev`, `automation`

### `/profile current`
Lê flag `~/.cursor/.profile-active` (ou auto-detectado no sessionStart).

### `/profile off`
Limpa profile manual. Auto-detect pode reativar no próximo workspace match.

## Auto-detecção (sessionStart)

Sinais em `rules/activation-manifest.json`:
- **Path/branch** → profile (`febracis`, `aria`, `n8n`…)
- **Markers** (`go.mod`, `supabase/config.toml`) → domain rules
- **Keywords no prompt** → domain rules via `profile-tracker.js`

## Domain rules (condicionais)

Manifest: `.cursor/rules/activation-manifest.json`

| Rule | Skill |
|------|-------|
| `golang-activate` | golang |
| `geo-seo-activate` | geo-seo |
| `supabase-factory-activate` | supabase-factory |

Estado: `~/.cursor/.domain-active.json`

## Localização

- Profiles: `.cursor/profiles/`
- Rules: `.cursor/rules/*-activate.md`
- Hooks: `.cursor/hooks/profile-*.js`

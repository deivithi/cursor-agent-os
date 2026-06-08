# Profiles — Contexto por Tipo de Trabalho

## Perfis disponíveis

| Profile | Foco | Skills prioritárias |
|---------|------|---------------------|
| `febracis-salesforce` | CRM, leads, comissões | lead-audit, commission-audit, runbook |
| `aria-dev` | SaaS Aria | code-review, cicd, product-verification |
| `automation` | n8n, integrações | n8n, n8n-hardening, api-forge, automations |

## Uso

```
/profile febracis-salesforce
/profile list
/profile current
/profile off
```

## Runtime (Cursor Hooks)

| Hook | Função |
|------|--------|
| `profile-session.js` | Injeta profile + domain rules no `sessionStart` |
| `profile-tracker.js` | `/profile` + keywords → flags |
| `domain-reinforce.js` | Lembrete curto antes de tools |

## Flags

- Profile manual/auto: `~/.cursor/.profile-active`
- Domain rules: `~/.cursor/.domain-active.json`
- Manifest: `~/.cursor/rules/activation-manifest.json`

## Criar novo profile

1. Adicionar `profiles/<nome>.md`
2. Registrar em `rules/activation-manifest.json` (opcional auto-detect)
3. Rodar sync (`migrate-from-documents.ps1`)

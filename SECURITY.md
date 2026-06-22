# SECURITY.md — Política de segurança e incidentes

> Criado em 22/06/2026 — após incidente de exposição de secrets no push inicial
> do repo `cursor-agent-os` para o GitHub.

## 🚨 Incidente 22/06/2026 — secrets expostos no commit `11c846c`

### Resumo

O primeiro push de `Documents\Cursor` para o GitHub (`origin` =
`deivithi/cursor-agent-os`, hoje removido) foi **bloqueado e depois aceito**
pelo secret scanner, que detectou 3 alertas:

| # | Tipo | Arquivo | Linha | Estado scanner |
|---|------|---------|-------|----------------|
| 1 | Telegram Bot Token | `scripts/notify-config.json` | 3 | open (multi-repo leak) |
| 2 | Stripe API Key | `skills/api-forge/references/security-patterns.md` | 778 | resolved (used_in_tests) |
| 3 | Tailscale API Key | `.claude/skills/cyber-deploying-tailscale-for-zero-trust-vpn/SKILL.md` | 395 | open |

Investigação adicional local (via `grep`) revelou mais 2 ocorrências **não
detectadas pelo scanner**:

| Tipo | Arquivo | Linha | Provável natureza |
|------|---------|-------|-------------------|
| Stripe `STRIPE_SECRET_KEY` | `skills/vibe-deploy-guard/SKILL.md` | 107 | exemplo em skill — confirmar |
| Stripe `NEXT_PUBLIC_STRIPE_SECRET` | `skills/vibe-deploy-guard/SKILL.md` | 115 | exemplo em skill — confirmar |

### Ações tomadas

- ✅ Backup completo do estado pré-exposição em
  `~/Documents/cursor-agent-os-backup-20260622-111737.bundle` (git bundle,
  9.0 MB, todas as refs preservadas).
- ✅ `.gitignore` atualizado para impedir commits futuros com os arquivos
  sensíveis.
- ✅ Repo público `deivithi/cursor-agent-os` **deletado** para impedir
  visualização das chaves via UI do GitHub.
- ✅ Mirror `deivithilopes-ai/cursor-agent-os` mantido vazio (nunca recebeu
  push).

### Ações pendentes (responsabilidade do usuário)

- [ ] **Telegram:** revogar bot token via @BotFather → `/mybots` → API Token →
  Revoke current token. **Crítico** porque o scanner marcou `multi_repo: true`
  (já vazou antes).
- [ ] **Stripe (vibe-deploy-guard):** abrir arquivo local e confirmar se a
  string na linha 107/115 é exemplo da skill ou chave real da conta Stripe de
  produção. Se for real: rotacionar em https://dashboard.stripe.com/apikeys.
- [ ] **Tailscale:** confirmar se `tskey-...eral` é exemplo de skill ou chave
  real da conta Tailscale. Se for real: revogar em
  https://login.tailscale.com/admin/settings/keys.
- [ ] **Reavaliar publicação no GitHub:** após revogação, considerar
  `git filter-repo` para reescrever o histórico do `11c846c` antes de republicar.

## 🛡️ Política de segredos (commit prevention)

### Arquivos sensíveis (nunca commitados)

Adicionados ao `.gitignore` da raiz `Documents\Cursor`:

```
# Secrets & runtime config (incidente 22/06/2026)
scripts/notify-config.json
scripts/notify-config.local.json
.env
.env.*
!.env.example
```

### Padrões proibidos em commits

```regex
# Telegram bot token: 8-10 digits : 35 alnum
[0-9]{8,10}:[A-Za-z0-9_-]{35}

# Stripe live/test keys
sk_live_[a-zA-Z0-9]{24,}
sk_test_[a-zA-Z0-9]{24,}
rk_live_[a-zA-Z0-9]{24,}

# GitHub PAT
gh[pousr]_[A-Za-z0-9]{36,}

# Tailscale
tskey-[a-zA-Z0-9_-]+

# Anthropic
sk-ant-[A-Za-z0-9_-]+

# OpenAI
sk-[A-Za-z0-9]{20,}
```

### Pre-commit hook (recomendação futura)

Para evitar reincidência, considerar skill `security-audit` antes de qualquer
`git push` em projetos do ecossistema.

## 📚 Referências

- GitHub Secret Scanning:
  https://docs.github.com/code-security/secret-scanning/introduction/about-secret-scanning
- Push protection:
  https://docs.github.com/code-security/secret-scanning/working-with-push-protection
- Rewriting git history (BFG / filter-repo):
  https://docs.github.com/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository

---

**Contato:** Deivithi Lopes (deivithi74@gmail.com)

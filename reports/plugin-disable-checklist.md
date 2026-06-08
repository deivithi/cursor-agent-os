# Checklist — Desativar Plugins Dormant

Data: 2026-05-25T17:39:30.789Z

Marque conforme desativa no Cursor. **Não delete pastas do cache.**

- [ ] appwrite-plugin (`appwrite-plugin`) — 10 skills
- [ ] aws-amplify (`aws-amplify`) — 1 skills
- [ ] aws-serverless (`aws-serverless`) — 4 skills
- [ ] cli-for-agent (`cli-for-agent`) — 1 skills
- [ ] cloudinary (`cloudinary`) — 2 skills
- [ ] create-plugin (`create-plugin`) — 2 skills
- [ ] datadog (`datadog`) — 3 skills
- [ ] deploy-on-aws (`deploy-on-aws`) — 1 skills
- [ ] figma (`figma`) — 9 skills
- [ ] firebase (`firebase`) — 11 skills
- [ ] functions (`functions`) — 1 skills
- [ ] huggingface-skills (`huggingface-skills`) — 11 skills
- [ ] linear (`linear`) — 0 skills
- [ ] meta-quest-agentic-tools (`meta-quest-agentic-tools`) — 13 skills
- [ ] miro (`miro`) — 1 skills
- [ ] mongodb (`mongodb`) — 8 skills
- [ ] postman (`postman`) — 3 skills
- [ ] shopify-plugin (`shopify-plugin`) — 20 skills
- [ ] Slack (`slack`) — 0 skills

## Depois de desativar

1. Reiniciar Cursor ou recarregar janela (`Ctrl+Shift+P` → Reload Window)
2. Rodar auditoria:
   ```powershell
   node --experimental-strip-types $env:USERPROFILE\.cursor\skills\skill-inventory-audit\scripts\skill-inventory-audit.ts --months 3 --output $env:USERPROFILE\Documents\Cursor\reports\skill-audit-after-plugins.md
   ```
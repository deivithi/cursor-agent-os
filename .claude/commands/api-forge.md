# API Forge — Forjar Integração Segura de API

Operação solicitada: **$ARGUMENTS**

## O que é

API Forge converte qualquer REST API em uma integração nativa e segura para Claude Code.
Zero supply chain risk. Credenciais encriptadas (AES-256-GCM). Audit trail completo.

## Skill Completa

Leia a skill completa em `.claude/skills/api-forge/SKILL.md` para:
- Workflow de 6 fases (Spec → Análise → Credenciais → Comando → Teste → Registro)
- Padrões de autenticação em `.claude/skills/api-forge/references/auth-patterns.md`
- Padrões de segurança em `.claude/skills/api-forge/references/security-patterns.md`

## Operações Rápidas

| Operação | Como |
|----------|------|
| **Forjar de OpenAPI** | `/api-forge https://api.example.com/openapi.json` |
| **Forjar de arquivo** | `/api-forge ./specs/my-api.yaml` |
| **Forjar manual** | `/api-forge manual --name myapi --base-url https://api.example.com` |
| **Listar forjados** | `/api-forge list` |
| **Testar API** | `/api-forge test <nome>` |
| **Rotacionar credencial** | `/api-forge rotate <nome>` |
| **Auditoria** | `/api-forge audit <nome>` |
| **Remover** | `/api-forge remove <nome>` |

## Processo (resumo)

1. **Ler** a skill completa em `.claude/skills/api-forge/SKILL.md`
2. **Seguir** o workflow de 6 fases descrito na skill
3. **Usar** os scripts em `.claude/scripts/forge-*.sh` para credenciais
4. **Gerar** o comando em `.claude/commands/<api-name>.md`
5. **Testar** com request read-only
6. **Registrar** em `~/.claude-forge/config/registry.json`

## Regras Invioláveis

- NUNCA armazenar tokens em plaintext
- NUNCA executar código externo baixado
- NUNCA expor tokens no contexto da conversa
- SEMPRE encriptar com AES-256-GCM
- SEMPRE aplicar chmod 600/700
- SEMPRE auditar acessos a credenciais
- SEMPRE validar input contra schema OpenAPI

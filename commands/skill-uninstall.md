# Skill Uninstall — Remover Skill

Removendo: **$ARGUMENTS**

## Protocolo

1. Verificar que a skill existe em `.claude/skills/$ARGUMENTS/`
2. Diamond Gate: "Remover skill '$ARGUMENTS'? Esta ação é irreversível."
3. Se aprovado: `rm -rf .claude/skills/$ARGUMENTS/`
4. Reportar: "Skill '$ARGUMENTS' removida."

## Proteção
- NUNCA remover skills listadas no Ouroboros firewall
- NUNCA remover skills com Related Skills que dependem dela (verificar primeiro)

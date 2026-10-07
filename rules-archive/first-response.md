# ⚡ Latência da 1ª resposta (ADR-013)

> Declaração do operador (08/09/2026). "Isso não pode acontecer mais."
> Ativa sempre. Overlays o ritual de memória — não o cancela quando o pedido precisa dele.

AGENTS.md já entra no prompt. **Não** reler CONTEXT / AGENT_MEMORY / DECISIONS / SESSION_LOG / SKILLS_INDEX / config.json no 1º turno se a resposta já está no payload da sessão.

## Zero tools quando

- Status / acesso / sim-não ("temos Zo?", "MCP ligado?", "git limpo?")
- Dado já visível no system-reminder (MCP connected, git_status, user_info)
- Ack curto ou correção de tom sobre fato já estabelecido nesta sessão

## Proibido no 1º turno desses pedidos

- "Deixe-me carregar o contexto primeiro"
- Grep/Read em massa no workspace só para confirmar o óbvio
- Abrir os 7 arquivos de memória antes de falar

## Quando carregar memória

- User: "carregar contexto"
- Tarefa precisa de fato que **não** está no prompt
- Implementação que toca ADR, pendência de sessão, stack/projeto

Match de skill (ADR-011) = catálogo já injetado no prompt. Só abrir `SKILL.md` se o pedido for a ação da skill.

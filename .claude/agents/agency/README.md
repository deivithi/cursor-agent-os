# Agency Agents

**Origem:** [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents)
**Licença:** MIT
**Absorvido em:** 11/04/2026
**Total:** 208 agentes em 15 divisões

## Como usar

Ative qualquer agente por linguagem natural na sessão Claude Code:

```
Activate Sales Discovery Coach and help me prepare for a discovery call.
```

```
Use the Engineering Backend Architect to design the API for this feature.
```

```
Activate Product Feedback Synthesizer and analyze this user feedback.
```

## Orquestração multi-agente (NEXUS)

A pasta `strategy/` contém o framework NEXUS para pipelines multi-agente coordenados:

- **NEXUS-Full:** Projeto completo (todas as fases)
- **NEXUS-Sprint:** Feature ou MVP (15-25 agentes)
- **NEXUS-Micro:** Tarefa específica (5-10 agentes)

Ver `strategy/QUICKSTART.md` para instruções.

## Catálogo

Ver [INDEX.md](INDEX.md) para lista completa por divisão.

## Notas

- Agentes são markdown puro — zero impacto no contexto até serem ativados
- Namespace separado (`agency/`) para não colidir com agents customizados
- Integrations de outras tools (Cursor, Aider, etc.) foram excluídas — só MCP Memory mantido

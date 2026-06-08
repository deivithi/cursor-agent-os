# 📱 Remote Control — Monitorar do Celular

## Comando

```bash
claude remote-control
```

Gera um link que pode ser acessado via claude.ai ou app mobile.

## Casos de uso

| Cenário | Como usar |
|---------|-----------|
| Agente autônomo rodando overnight | Iniciar sessão no PC → `remote-control` → monitorar do celular |
| Refactor longo | Iniciar no PC → acompanhar progresso do sofá |
| Deploy em andamento | Kickar deploy → monitorar de qualquer lugar |

## Integração com nosso sistema

- Combina com `/autonomous-agent-loop` — monitorar loop de experimentos
- Combina com `/loop 5m check deploy` — receber updates no celular
- Combina com subagentes do `/do` — ver progresso paralelo

## Limitação

Requer conexão ativa com claude.ai. Se a sessão local morrer, o remote-control desconecta.

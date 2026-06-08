# Gotchas — Automations

## 1. Claude Code deve estar rodando para executar automações locais

- **Sintoma:** Automação não executa no horário definido
- **Causa raiz:** `claude -p` requer Claude Code CLI ativo. Se a máquina estiver desligada ou Claude não instalado, o n8n não consegue executar
- **Solução:** Manter máquina ligada (usar `/keep-awake`) ou usar n8n Execute Command com timeout adequado
- **Prevenção:** Para automações críticas, usar n8n nodes nativos (HTTP, Code) em vez de claude -p

## 2. Cron expressions usam timezone do sistema

- **Sintoma:** Automação roda no horário errado
- **Causa raiz:** n8n usa UTC por padrão. O sistema está em BRT (UTC-3)
- **Solução:** Configurar timezone no n8n Schedule node ou ajustar cron (+3h)
- **Prevenção:** Sempre verificar timezone no registro. `0 8 * * *` em BRT = `0 11 * * *` em UTC

## 3. Review queue pode acumular se não for processada

- **Sintoma:** review-queue.md fica gigante, performance degrada
- **Solução:** Processar regularmente via `/automations review`. Itens processados são movidos para arquivo
- **Prevenção:** Configurar notificação para lembrar de revisar a fila

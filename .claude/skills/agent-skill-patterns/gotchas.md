# ⚠️ Gotchas — Agent Skill Patterns

> Problemas conhecidos ao aplicar os 5 padrões ADK + 3 melhorias. Construído iterativamente a partir de falhas reais.
> **Consulte este arquivo quando algo falhar ou produzir resultado inesperado.**

---

## 1. Gating Instructions ignoradas quando a skill é carregada via ativação automática

- **Sintoma:** O agente pula as perguntas obrigatórias do Padrão 4 (Inversion) e vai direto para a execução
- **Causa raiz:** Quando a skill é ativada automaticamente por palavras-chave (em vez de via `/comando`), o contexto de "entrevista antes de executar" pode ser diluído pelo prompt do usuário que já contém a tarefa
- **Solução:** Nas Gating Instructions, usar linguagem BLOQUEANTE: "⛔ GATE: NÃO prossiga para a execução até que TODAS as perguntas abaixo sejam respondidas pelo usuário"
- **Prevenção:** Testar a skill tanto via comando explícito quanto via ativação automática. Adicionar assertiva: "Se ativada automaticamente, PRIMEIRO exibir as perguntas do Gate"
- **Descoberto em:** 2026-03-18

---

## 2. Severity Scoring com thresholds muito baixos gera ruído excessivo

- **Sintoma:** Reviewer skill reporta dezenas de findings de severidade LOW e INFO, soterando os CRITICAL e HIGH
- **Causa raiz:** O threshold de "reportar" estava configurado como INFO (reportar tudo). Para code reviews em projetos maduros, isso gera mais ruído que sinal
- **Solução:** Ajustar threshold por contexto: para revisão rápida usar `MEDIUM+`, para auditoria completa usar `INFO+`. Configurar no `config.json` ou no comando
- **Prevenção:** Sempre definir threshold default como `MEDIUM` e permitir override explícito: `/review --severity INFO`
- **Descoberto em:** 2026-03-18

---

## 3. Diamond Gates sem timeout causam sessão travada indefinidamente

- **Sintoma:** O agente pergunta "Aprovar deploy para produção? [sim/não]" e fica esperando indefinidamente. Se o usuário esquecer ou fechar a sessão, a tarefa fica em limbo
- **Causa raiz:** Diamond Gates não têm timeout ou fallback definido. O padrão puro exige aprovação humana sem exceção
- **Solução:** Adicionar timeout ao Diamond Gate: "Se não houver resposta em 5 minutos, abortar a operação e logar como TIMEOUT"
- **Prevenção:** Todo Diamond Gate deve ter: (1) timeout com ação default (abort), (2) log da decisão, (3) opção de "aprovar para os próximos N minutos"
- **Descoberto em:** 2026-03-18

---

<!--
INSTRUÇÕES PARA MANUTENÇÃO:
1. Adicione novos gotchas NO TOPO (mais recentes primeiro, renumere)
2. Use o formato acima para consistência
3. Se um gotcha for resolvido permanentemente, mova para ## Resolvidos no final
4. Gotchas devem ser específicos e acionáveis — não genéricos
5. Inclua o sintoma exato para facilitar busca futura
-->

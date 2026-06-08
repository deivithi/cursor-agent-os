# 🗜️ Protocolo de Compactação Guiada

> Derivado do princípio CALM: maximizar densidade semântica por passo.

## Quando usar /compact

- Context window acima de 60% de utilização
- Após concluir uma fase de trabalho (antes de iniciar a próxima)
- Quando respostas começam a perder coerência ou ignorar instruções

## Como usar (SEMPRE com instrução de foco)

❌ **Errado:** `/compact`
✅ **Correto:** `/compact foque nas mudanças de API e decisões arquiteturais`

### Templates de compactação por contexto

| Contexto | Instrução de /compact |
|----------|----------------------|
| Debugging | "foque nos erros encontrados, causas raízes e correções aplicadas" |
| Feature development | "foque nos requisitos, decisões de design e arquivos modificados" |
| Code review | "foque nos findings por severidade e ações pendentes" |
| n8n workflows | "foque na arquitetura do workflow, nodes configurados e credenciais necessárias" |
| Auditoria de leads | "foque nas inconsistências encontradas, regras violadas e recomendações" |
| Pesquisa/análise | "foque nas conclusões, dados relevantes e próximos passos" |

## Regra de Ouro (CALM)

> Se o contexto compactado não preserva as **decisões** e **estado atual**, a compactação falhou. Comprimir ≠ perder — é destilar.

## 🔄 Compactação Proativa (Mid-Session)

> "Não otimiza o que não mede" — compactar ANTES de ficar caro, não depois.

### Triggers para compactação proativa

| Sinal | Ação |
|-------|------|
| > 50 tool calls na sessão | Considerar `/compact` com foco na fase atual |
| > 30 turnos de conversa | Compactar turnos antigos, manter últimos 5-10 |
| Mudança de fase (pesquisa → implementação) | Compactar fase anterior antes de iniciar nova |
| Subagente retornou resultado longo | Já está isolado — mas se repatriou, compactar |
| Resposta começa a ignorar instruções | Sinal de context pressure — compactar imediatamente |

### Template mid-session

```
/compact foque em: [objetivo atual da fase].
Descarte: [contexto de fases anteriores que não precisa mais].
Preserve: [decisões, estado, arquivos em andamento].
```

### Diferença do compactação reativa

| Tipo | Quando | Risco |
|------|--------|-------|
| **Reativa** (atual) | Sistema força perto do limite | Pode perder contexto importante na pressa |
| **Proativa** (novo) | Agente decide entre fases | Controle total do que preservar |

> ⚠️ **Impacto em tokens:** Cada turno reprocessa TODA a conversa. Uma sessão de 30 turnos pode estar silenciosamente custando 30x o primeiro turno. Compactar corta esse crescimento exponencial.

## Integração com Hooks

O hook `Stop` já captura git diff/status no session-log. Após `/compact`, as decisões sobrevivem no contexto compactado + no log de sessão.

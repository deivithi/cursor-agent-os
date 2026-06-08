# Make Plan — Planejamento Estruturado com Descoberta

Crie um plano de implementação completo e verificável para: **$ARGUMENTS**

## Regra Inviolável

> Nenhuma linha de código é escrita antes do plano ser aprovado.
> Todo fato usado no plano DEVE ter fonte verificável (arquivo, doc, API).

## Fase 0: Descoberta de Contexto (OBRIGATÓRIA) — Padrão Inversion

Antes de planejar qualquer coisa, ativar modo **Inversion** (padrão ADK):

### ⛔ Gating Instructions — NÃO prossiga sem satisfazer TODOS os gates:

```
⛔ Gate 1 — OBJETIVO: NÃO prossiga até ter clareza sobre O QUE e POR QUÊ
   □ O que o usuário quer alcançar? (resultado concreto)
   □ Qual a métrica de sucesso? (como sabemos que funcionou)
   □ Qual o prazo ou urgência?

⛔ Gate 2 — ESCOPO: NÃO prossiga até mapear os LIMITES
   □ O que está DENTRO do escopo?
   □ O que está FORA do escopo? (tão importante quanto)
   □ Quais sistemas/arquivos serão impactados?

⛔ Gate 3 — RESTRIÇÕES: NÃO prossiga até identificar LIMITAÇÕES
   □ Limitações técnicas? (compatibilidade, versões, dependências)
   □ Dependências externas? (APIs, serviços, aprovações)
   □ Restrições de negócio? (compliance, regras, SLAs)

⛔ Gate 4 — CONTEXTO: NÃO prossiga até VERIFICAR os fatos
   □ Buscar memória — Ler arquivos relevantes em memory/
   □ Explorar código — Glob e Grep no estado atual
   □ Verificar dependências — Tudo que será impactado
   □ Consultar docs — WebSearch para syntax e versões atuais
```

> **Se algum gate não puder ser satisfeito**: perguntar ao usuário ANTES de prosseguir. Se o usuário escolher bypassar, registrar como "⚠️ Gate N bypassed — risco aceito pelo usuário".

Para cada fato descoberto, registre:
- **Fonte:** arquivo/URL/doc
- **Confiança:** Alta / Média / Baixa
- **Data:** quando foi verificado

## Fase 1: Análise de Requisitos

| Item | Detalhe |
|------|---------|
| **Objetivo** | O que precisa ser alcançado |
| **Escopo** | O que está dentro e FORA do escopo |
| **Restrições** | Limitações técnicas, de tempo, de compatibilidade |
| **Critérios de Aceite** | Como sabemos que está pronto (checkboxes verificáveis) |
| **Riscos** | O que pode dar errado e mitigação |

## Fase 2: Design da Solução

1. **Arquitetura** — Como a solução se encaixa no sistema existente
2. **Abordagem** — Qual estratégia técnica será usada e POR QUÊ
3. **Alternativas Descartadas** — O que foi considerado e por que foi rejeitado
4. **Impacto** — Quais arquivos/sistemas serão modificados

## Fase 3: Plano de Execução

Divida em fases sequenciais, cada uma com:

```markdown
### Fase N: [Nome]
**Objetivo:** [o que esta fase entrega]
**Arquivos:** [lista de arquivos a criar/modificar]
**Dependências:** [o que precisa estar pronto antes]
**Passos:**
- [ ] Passo 1 — descrição clara
- [ ] Passo 2 — descrição clara
**Verificação:** [como validar que esta fase está OK]
**Rollback:** [como desfazer se algo der errado]
```

## Fase 4: Checklist de Validação

```
[ ] Todos os fatos do plano têm fonte verificável?
[ ] O design respeita a arquitetura existente?
[ ] Não há funcionalidades extras além do solicitado?
[ ] Cada fase tem verificação independente?
[ ] O plano é simples o suficiente? (Pode ser mais simples?)
[ ] Riscos identificados têm mitigação?
```

## Anti-patterns (PROIBIDO)

- Fabricar APIs ou parâmetros não verificados
- Pular a Fase 0 (Descoberta)
- Planejar funcionalidades não solicitadas
- Assumir sem verificar
- Usar informação desatualizada

## Entrega

Salve o plano em `tasks/todo.md` (criar se não existir) com formato:

```markdown
# Plano: [título]
**Data:** [data atual]
**Status:** Aguardando aprovação

[conteúdo do plano]
```

Pergunte ao usuário: "Plano aprovado para execução?"

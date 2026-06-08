# TaskEnvelope — contrato mínimo de orquestração

Usado pelo `/go` e `/do` para alinhar execução multi-passo a critérios verificáveis (espírito “structured output → tools” de agentes tipo Super Agent).

## Quando é obrigatório

- Tarefa com **3 ou mais passos** lógicos, ou
- **Múltiplos artefatos** de saída, ou
- **Impacto externo** (email, deploy, dados pessoais, produção), ou
- **Pesquisa na web / decisão de negócio** sem fonte única no repositório.

Não é obrigatório para: pergunta única, read-only pontual, refatoração local reversível de 1–2 ficheiros.

## Campos (JSON)

Coloque no início da execução (bloco `json` na conversa ou nota em `tasks/todo.md`).

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `intent` | string | Uma frase: o que deve estar verdadeiro ao terminar. |
| `artifacts_expected` | string[] | Ex.: `["relatorio.md"]`, `["deck.pptx"]`, `["PR"]`. |
| `acceptance_criteria` | string[] | Condições testáveis; cada item deve poder ser marcado pass/fail. |
| `risks` | string[] | O que pode correr mal (dados errados, regressão, compliance). |
| `step_budget` | number | Máximo de iterações macro (ex.: 8). Pode aumentar com OK humano. |
| `sources_policy` | string | `repo_only` \| `web_ok` \| `mcp_ok` — define onde buscar evidência. |
| `moa_lite` | boolean | Se true, após entrega aplicar passagem **Reviewer** + secção **Fusão** (ver abaixo). |

### Exemplo

```json
{
  "intent": "Relatório de risco LGPD do fluxo X com referências citáveis.",
  "artifacts_expected": ["docs/risco-lgpd-fluxo-x.md"],
  "acceptance_criteria": [
    "Cada afirmação forte tem fonte (URL ou ficheiro:linha)",
    "Secção 'Não verificado' lista lacunas",
    "Nenhum dado pessoal fictício apresentado como real"
  ],
  "risks": ["Documentação interna desatualizada"],
  "step_budget": 10,
  "sources_policy": "web_ok",
  "moa_lite": true
}
```

## MoA-lite (duas passagens, um modelo)

1. **Gerador:** produz rascunho ou implementação conforme a skill.
2. **Reviewer:** só lista falhas, lacunas, contradições e conflitos entre fontes (sem reescrever tudo). Usar mentalidade de `.claude/skills/code-review/SKILL.md` ou `agent-skill-patterns` Reviewer.
3. **Fusão:** resposta final **obriga** secções:
   - `## Conflitos resolvidos` — como harmonizou divergências.
   - `## Não verificado` — o que ficou sem evidência suficiente.

## Ligação ao plano

Se existir `tasks/todo.md`, cada critério em `acceptance_criteria` deve mapear para um item checkável no plano ou ser explicitamente marcado como coberto pelo deliverable.

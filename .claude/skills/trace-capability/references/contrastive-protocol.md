# Protocolo de Análise Contrastiva

> Como comparar trajetórias de sucesso vs falha para isolar deltas de capacidade.
> Adaptado do TRACE Stage 1 (Capability Selection) para execução via LLM sem GPU.

---

## Pré-Requisitos

- Mínimo **3 traces PASS** e **2 traces FAIL** para a skill/domínio alvo
- Traces devem conter: input, output, tools usados, decisões, score, timestamp
- Fontes válidas: `ouroboros/evals/traces/`, ledger TSV, git log de branches ouroboros/

---

## Passo 1: Coleta e Partição

```
collect-traces.sh {skill-name}
→ Retorna JSON: { pass_traces: [...], fail_traces: [...], ledger_rows: [...] }
```

Se traces formais insuficientes, complementar com:
- Ouroboros reports em `ouroboros/reports/` (narrativos, extrair dados)
- Git diffs de iterações KEEP vs DISCARD: `git log --all --grep="ouroboros" --oneline`

---

## Passo 2: Alinhamento de Pares

Para cada trace FAIL, encontrar o trace PASS mais similar:

### Critérios de Similaridade (prioridade)
1. **Mesmo tipo de input** (mesma categoria de tarefa)
2. **Mesmas tools disponíveis** (mesmo contexto de ferramentas)
3. **Mesmos checklist items alvo** (mesma dimensão sendo avaliada)
4. **Proximidade temporal** (sessões próximas = contexto mais comparável)

### Formato do Par Alinhado
```markdown
## Par Contrastivo #{N}

### PASS (trace_id: {id}, score: {score})
- Input: {resumo do input}
- Passos executados: {lista ordenada}
- Tools usados: {lista}
- Decisões-chave: {pontos de fork}
- Resultado: {resumo do output}

### FAIL (trace_id: {id}, score: {score})
- Input: {resumo do input}
- Passos executados: {lista ordenada}
- Tools usados: {lista}
- Decisões-chave: {pontos de fork}
- Resultado: {resumo do output}
- Erro/deficiência: {o que deu errado}
```

---

## Passo 3: Extração de Delta

Para cada par alinhado, identificar diferenças em 5 eixos:

| Eixo | Pergunta | Exemplo de Delta |
|---|---|---|
| **Steps** | Que passos o PASS fez que o FAIL pulou? | PASS leu 3 arquivos antes de editar; FAIL editou direto |
| **Tools** | Que ferramentas o PASS usou diferente? | PASS usou Grep para validar; FAIL confiou na memória |
| **Information** | Que informação o PASS coletou a mais? | PASS leu gotchas.md; FAIL ignorou |
| **Decisions** | Em que ponto as trajetórias divergiram? | PASS verificou resultado antes de commitar; FAIL commitou cego |
| **Quality** | Que aspecto do output diferiu? | PASS incluiu anti-patterns; FAIL omitiu seção inteira |

---

## Passo 4: Abstração para Capacidades

Agrupar deltas similares sob capacidades da taxonomia (`references/capability-taxonomy.md`):

```
Delta: "PASS leu 3 arquivos antes de editar; FAIL editou direto"
Delta: "PASS verificou estado atual; FAIL assumiu"
→ Cluster: IG-01 (Source Completeness) + IG-02 (Context Verification)
→ Capacidade gap: Information Gathering
```

### Regras de Abstração
- Mínimo 2 deltas para confirmar um gap (1 delta = pode ser acidental)
- Se delta não encaixa em nenhuma capacidade existente → propor nova (pendente confirmação 2x)
- Priorizar gaps que aparecem em múltiplos pares (recorrência = sinal forte)

---

## Passo 5: Ranking de Impacto

Ordenar gaps por impacto estimado:

```
Impact Score = (frequência nos pares) × (delta médio de score entre PASS e FAIL)
```

| Gap | Frequência | Delta Médio | Impact Score |
|---|---|---|---|
| IG-01 Source Completeness | 4/5 pares | 2.3 pontos | 9.2 |
| SR-03 Validation | 3/5 pares | 1.5 pontos | 4.5 |
| OQ-02 Completeness | 2/5 pares | 1.0 pontos | 2.0 |

---

## Output: Capability Gap Report

Usar template `templates/capability-gap-report.md` com:
- Lista ordenada de gaps (maior impacto primeiro)
- Evidência contrastiva por gap (pares alinhados citados)
- Capacidades da taxonomia referenciadas por ID
- Recomendação de patch type (knowledge/rule/tool/structural)

---

## Diferença GEPA vs Contrastive

| Aspecto | GEPA | Contrastive (TRACE) |
|---|---|---|
| **Input** | Apenas trace de falha | Pares PASS + FAIL alinhados |
| **Método** | Diagnóstico causal (por quê falhou?) | Delta comparativo (o que diferiu?) |
| **Força** | Rápido, funciona com 1 trace | Mais preciso, identifica inconsistências |
| **Fraqueza** | Não vê o que o sucesso fez diferente | Requer múltiplos traces |
| **Quando usar** | Iteration 2+ no Ouroboros (fast path) | Quando há 3+ PASS e 2+ FAIL traces |
| **Complementam-se** | GEPA diz POR QUÊ falhou | TRACE diz O QUE faltou fazer |

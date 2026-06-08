# Capability Gap Report — {skill-name}

> Gerado por: trace-capability Stage 1 (Análise Contrastiva)
> Data: {YYYY-MM-DD HH:MM BRT}
> Traces analisados: {N_pass} PASS + {N_fail} FAIL = {N_total} total

---

## Resumo Executivo

**Gaps identificados:** {N_gaps}
**Gap de maior impacto:** {gap_id} — {gap_name} (Impact Score: {score})
**Recomendação principal:** {patch_type} em {arquivo_alvo}

---

## Gaps Identificados (ordenados por impacto)

### Gap 1: {taxonomy_id} — {capability_name}

- **Impact Score:** {frequência} × {delta_médio} = {impact}
- **Dimensão:** {IG|PR|TU|OQ|SR}
- **Patch type:** {knowledge|rule|tool|structural}

**Evidência contrastiva:**

| # | PASS (trace_id) | FAIL (trace_id) | Delta observado |
|---|---|---|---|
| 1 | {o que o PASS fez} | {o que o FAIL não fez} | {descrição do delta} |
| 2 | ... | ... | ... |

**Diagnóstico:** {frase explicando por que este gap causa falha}

---

### Gap 2: {taxonomy_id} — {capability_name}

{mesmo formato}

---

## Recomendações de Patch

| Gap | Patch Type | Ação Sugerida | Arquivo Alvo |
|---|---|---|---|
| {id} | {type} | {ação específica} | {path} |

## Cenários de Teste Sugeridos (Stage 2)

| Gap | Cenário Simples | Cenário Padrão | Cenário Edge Case |
|---|---|---|---|
| {id} | {descrição} | {descrição} | {descrição} |

---

## Metadados

- **Pares contrastivos analisados:** {N_pairs}
- **Gaps descartados (< 2 ocorrências):** {N_descartados}
- **Novas capacidades propostas:** {lista ou "nenhuma"}
- **Tempo de análise:** {duração}

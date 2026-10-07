# 🔄 Adaptive Depth — Profundidade Adaptativa para Loops Iterativos

> Baseado em: "Scaling Latent Reasoning via Looped Language Models" (arXiv 2510.25741)
> Ativa quando qualquer loop iterativo rodar: alpha-loop, spec-yolo, spec-verify, spec-phases, GEPA, deep-research, auto-fix, ralph, autopilot.

## Regra: Overlay aditivo — NÃO substitui max fixo das skills (3 ou 5). Adiciona inteligência de parada.

---

## 1. Complexity Routing (ANTES do loop)

Classificar complexidade da task → definir budget de iterações:

| Complexidade | Sinais | Budget | Ação |
|-------------|--------|--------|------|
| **Trivial** | 1-2 arquivos, fix pontual, typo, rename | 1-2 | Se resolver na 1ª iteração, sair. Não forçar mais loops |
| **Média** | 3-5 arquivos, lógica moderada, sem integração externa | 3 | Default atual. Comportamento inalterado |
| **Complexa** | 6+ arquivos, multi-sistema, segurança, integração | 4-5 | Permitir mais iterações. Usar max da skill |

**Regra:** Se task é trivial e resolveu na iteração 1 → EXIT. Não iterar "por costume".

---

## 2. Sinal de Melhoria I(t) (DURANTE o loop)

Após CADA iteração, registrar mentalmente:

```
Iteração t:
  - Issues/testes no início: N₀
  - Issues resolvidas nesta iteração: Δ
  - I(t) = Δ / N₀
```

### Thresholds

| I(t) | Interpretação | Ação |
|------|--------------|------|
| > 0.20 | Progresso forte | ✅ Continuar |
| 0.05 – 0.20 | Progresso moderado | ✅ Continuar (última chance) |
| < 0.05 | Estagnação | ⚠️ Flaggear. Se 2 iterações consecutivas < 0.05 → EXIT |
| = 0 | Zero progresso | 🛑 EXIT imediato se iteration > 1 |

### Regra de Estagnação

```
SE I(t) < 0.05 E I(t-1) < 0.05:
    → STAGNATION DETECTADA
    → EXIT do loop
    → Reportar: "⚠️ Stagnation: iterações {t-1} e {t} sem ganho significativo (<5%). Saindo do loop."
    → Seguir para: diagnóstico (GEPA) ou replanejamento (spec-planner)
```

---

## 3. Overthinking Guard (DURANTE o loop)

```
SE iteration > budget_estimado E I(t) < 0.05:
    → EXIT imediato
    → Reportar: "🛑 Overthinking: iteração {t} excede budget ({budget}) sem ganho marginal."
```

**Por que:** O paper mostra que performance DEGRADA após o sweet spot. Continuar iterando sem ganho gasta tokens e pode introduzir regressões.

---

## 4. Integração com Skills Existentes

| Skill | Como I(t) é medido | Nada muda se... |
|-------|--------------------|-----------------------|
| `alpha-loop` | testes passando / total testes | Todos os testes passam (EXIT: SUCCESS já existe) |
| `spec-yolo` | issues acima de threshold resolvidas / total | Severity < threshold (EXIT já existe) |
| `spec-verify` | Critical+Major resolvidos / total | Sem issues (EXIT já existe) |
| `gepa-reflective` | melhoria na métrica-alvo | Métrica melhorou (KEEP já existe) |
| `deep-research` | perguntas respondidas / total | Budget esgotou (EXIT já existe) |

**Princípio:** A rule só ADICIONA detecção de estagnação. Todos os exits existentes continuam funcionando normalmente.

---

## 5. Resumo Operacional

```
ANTES do loop:
    → Classificar complexidade → definir budget (1-2 / 3 / 4-5)

APÓS cada iteração:
    → Calcular I(t) = melhoria marginal
    → Se I(t) = 0 e iteration > 1 → EXIT
    → Se I(t) < 0.05 por 2 consecutivas → EXIT (stagnation)
    → Se iteration > budget e I(t) < 0.05 → EXIT (overthinking)

Max fixo da skill → fallback final (nunca removido)
```

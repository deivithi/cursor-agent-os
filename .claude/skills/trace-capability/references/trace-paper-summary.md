# TRACE — Resumo Adaptado do Paper

> **Paper:** TRACE: Capability-Targeted Agentic Training (arXiv 2604.05336, abril 2026)
> **Autores:** Hangoo Kang, Tarun Suresh, Jon Saad-Falcon, Azalia Mirhoseini
> **Lab:** Scaling Intelligence Lab, Stanford University
> **Licença:** MIT | **Código:** github.com/ScalingIntelligence/TRACE

---

## Tese Central

Agentes LLM falham em ambientes complexos não por fraqueza geral, mas por **gaps específicos de capacidade**. Em vez de treino genérico (synthetic data scaling) ou RL direto (brute-force), TRACE:

1. **Diagnostica** exatamente QUAL capacidade está faltando
2. **Sintetiza** ambientes de treino focados nesse gap
3. **Treina** um adapter compacto (LoRA, 5.3% dos parâmetros)
4. **Roteia** para o adapter certo na inferência

## Resultados Empíricos

| Benchmark | Métrica | TRACE | vs Base | vs GRPO | vs GEPA |
|-----------|---------|-------|---------|---------|---------|
| tau²-bench (customer service) | Pass rate | 47.0% | +14.1 | +9.2 | +7.4 |
| ToolSandBox (tool use) | Mean similarity | 0.552 | +0.141 | — | — |

## Os 4 Estágios (Original)

### Stage 1: Capability Selection
- LLM analisa trajetórias de sucesso vs falha lado a lado
- Identifica **deltas de capacidade** (o que o sucesso fez que a falha não fez)
- Parâmetros: rho=0.10 (threshold), delta=0.20, k_consistency=8
- Tempo: ~55 min por análise (múltiplas passadas para robustez)

### Stage 2: Synthetic Environment Generation
- Gera ambientes de treino isolados (jogos Python) por capacidade
- Preserva a interface do benchmark original
- Foca APENAS na capacidade-alvo (isolamento cirúrgico)

### Stage 3: GRPO Training
- Group Relative Policy Optimization
- LoRA rank 16, alpha 16 (q/k/v/o projections)
- Vantagem: reward - group_mean_reward, normalizado por jogo
- Grupos com variância zero descartados

### Stage 4: Inference Routing
- Modelo base classifica a capacidade necessária
- Ativa o LoRA adapter correspondente
- MultiVLLM backend para load balancing

## Nossa Adaptação (sem GPU)

| TRACE Original | Nossa Implementação |
|---|---|
| LoRA adapters treinados | Skills e rules (nossos "adapters") |
| vLLM local | Claude via API (já existente) |
| GRPO training loop | Ouroboros loop (edit → eval → keep/discard) |
| Inference routing | Auto-ativação por keywords na description |
| Jogos Python como ambiente | Cenários de teste + judge criteria |

**Insight-chave:** A contribuição mais valiosa do TRACE não é o LoRA training — é a **análise contrastiva** (Stage 1) e a **síntese direcionada** (Stage 2). Esses stages são puramente LLM-driven e funcionam com qualquer modelo.

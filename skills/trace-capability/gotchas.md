# Gotchas — trace-capability

## ALERTA: Traces Insuficientes

O erro mais comum é tentar rodar Stage 1 sem traces suficientes.
- Mínimo: 3 PASS + 2 FAIL
- Se `collect-traces.sh` retorna `sufficient_for_contrastive: false` → usar GEPA (fast path)
- Complementar com: ouroboros reports, git log de branches ouroboros/, ledger TSV

## ALERTA: Alinhamento Forçado

Nunca forçar alinhamento entre traces incompatíveis (input types diferentes).
Um par mal alinhado produz deltas falsos → gaps fantasma → patches inúteis.
Se não há par PASS similar ao FAIL → registrar como "unaligned" e pular.

## ALERTA: Confundir Gap com Bug

Um bug pontual (typo, import faltando) NÃO é um gap de capacidade.
Gaps são padrões recorrentes (aparecem em 2+ pares). Bugs aparecem 1x.
Se aparece em apenas 1 par → provavelmente é bug, não gap.

## ALERTA: Traces Sintéticos Supervalorizados

Traces gerados por Stage 2 (`generated_by: trace-capability`) têm peso 0.3x no composite.
NUNCA tratar trace sintético com mesmo peso de trace real.
O propósito do sintético é direcionar a próxima sessão, não substituir avaliação real.

## ALERTA: Taxonomia Prematura

NUNCA adicionar nova capacidade à taxonomia baseado em uma única análise.
Regra: 2+ análises independentes confirmando o mesmo gap antes de adicionar ID.
Propor como `[PROPOSTA: XX-NN]` no gap report; confirmar em análise subsequente.

## ALERTA: Patch Structural Auto-Aplicado

Patches do tipo `structural` NUNCA são auto-aplicados.
Requerem review humano porque implicam redesign da skill inteira.
Se o Stage 3 classifica como structural → flag e parar. Não modificar.

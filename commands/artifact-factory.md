---
description: "Pipeline único PDF / PPTX / landing com QA obrigatório"
---

# Artifact Factory

Pedido do utilizador: **$ARGUMENTS**

## Processo

1. Leia [`.claude/skills/artifact-factory/SKILL.md`](../skills/artifact-factory/SKILL.md) na íntegra.
2. Identifique quais artefatos (PDF, PPTX, landing, outros) entram no pedido.
3. Execute outline → (pesquisa se necessário) → draft → **QA checklist** → export com as skills listadas na skill.
4. Se múltiplos artefatos, use um único TaskEnvelope com `artifacts_expected` alinhado a [`.claude/references/task-envelope.md`](../references/task-envelope.md).

## Regras

- Não declarar concluído sem marcar explicitamente o checklist de QA (pass/fail por item).
- Falha de QA → corrigir e revalidar antes de entregar.

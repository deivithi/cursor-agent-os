# rules-archive

Rules retiradas do carregamento sempre ativo em 07/10/2026 (organização após a análise "DHH: quase nenhuma skill + revisão adversarial").

Motivo: o conteúdo útil foi para `rules/plan-and-execute.md`. O resto tentava mudar o comportamento do modelo com texto, gerava conflito entre rules e custava contexto em toda sessão.

| Arquivo | Destino do conteúdo útil |
|---|---|
| anti-sycophancy.md | plan-and-execute.md §3 |
| first-response.md | plan-and-execute.md §4 |
| calibration.md | plan-and-execute.md §5 |
| adaptive-depth.md, zoom-out.md | plan-and-execute.md §6 |
| workflow-patterns.md | plan-and-execute.md §1 (reviewer adversarial) |
| token-efficiency.md | sem destino — orientação genérica |
| agency-agents.md, graphify.md, supabase-docs.md | sem destino — as tools e os agentes já se descrevem |
| caverna-activate.md.off | já estava desligada |

Para reativar: `git mv rules-archive/<arquivo> rules/`.
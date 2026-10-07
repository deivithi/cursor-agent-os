# rules-on-demand

Rules de ativação por domínio. Não ficam em `rules/` porque o Claude Code carrega `rules/` inteiro em toda sessão.

O hook `hooks/profile-runtime.js` injeta a rule só quando o pedido bate com as keywords de `activation-manifest.json`. Ele lê as cópias em `~/.cursor/rules/`. Ao editar um arquivo aqui, copie também para `~/.cursor/rules/`.
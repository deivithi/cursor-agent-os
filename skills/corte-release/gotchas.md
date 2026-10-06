# Gotchas — corte-release

1. **Filtro por data traz de volta o último PR do corte anterior.** O `mergedAt` do GitHub sai ~1 s depois do `%cI` do commit de squash que virou a tag (caso real: PR #14, `sprint-09`). Use `--commits` (ancestralidade). O `--desde` existe só como alternativa e já soma 2 min de margem.
2. **Sessão de QA ausente.** Os agentes do enxame param no login e devolvem cobertura vazia. Crie a sessão temporária de QA em hml antes do enxame e revogue no fim. Nunca passe senha nos args do Workflow.
3. **"Zero achados" com cobertura vazia.** Confira `exploradoresSemResultado`, `reproducaoFalhou`, `consolidacaoFalhou` e o campo `cobertura` de cada agente. Área sem resultado é lacuna.
4. **Comparação com prd sem sessão.** Sem `acessoReferencia`, o agente só vê em prd o que abre sem login. Tela de login em prd não prova que o defeito não existe lá: a origem fica `indeterminada`. O script rebaixa para `indeterminada` toda "regressão" sem `telaEmPrd=true`.
5. **Captura pública fechada em prd.** Na Plataforma de Indicações, landing, formulário e importação ficam fechados em prd até o DPO aprovar o consentimento. Achado "formulário fechado" em prd não é regressão.
6. **Worktree nasce de `main` local.** Primeiro comando do agente de correção, só dentro do worktree: `git fetch origin && git reset --hard origin/main`. Nunca na cópia principal.
7. **Cherry-pick de squash.** Use o SHA do squash em `main`, com `-x`. Conflito → PR próprio para `release/<versao>`, não resolva no olho.
8. **`hml` diverge depois de um patch.** O cherry-pick cria SHA novo no ramo do corte. No corte seguinte, `git push deploy release/<nova>:hml` é recusado (não é fast-forward). Não force por conta própria: `push --force` em ramo compartilhado pede confirmação do PO. Caminho: `git cherry release/<nova> deploy/hml`; só com todas as linhas `-` peça ao PO o `--force-with-lease` (SKILL, Fase 2).
9. **Dois remotes no clone.** `origin` = tifebracis, `deploy` = deivithi. Todo `gh` leva `--repo`; sem ele, o gh pode comentar ou publicar no repo errado.
10. **GitHub Actions da org `tifebracis` não roda** (pendência da TI em 06/10/2026). Os checks obrigatórios não aparecem; vale `pnpm verify` local + mescla de admin, registrada no PR.
11. **Envio para `tifebracis` trava no helper de credencial.** Use o token do `gh` da conta da empresa só no comando (ver memória `indicacoes-passagem-lorrany`).
12. **MCP bash do Zo expira em ~60 s.** Playwright e reprovisionamento rodam em `nohup`; o agente consulta o log depois.
13. **`gh pr list` ordena por criação.** Sem `--search "merged:>=<data>"`, um PR antigo mesclado agora pode ficar fora do `--limit`. O passo 4 da Fase 1 já filtra no servidor.
14. **`jq` não está instalado no Windows do PO.** Use `--saida-avisos <dir>` do script para ter um arquivo por aviso.
15. **Tag de patch fora do padrão.** `proximoPatch` aceita só `<nome>-<número>[.<patch>]` (ex.: `sprint-10`, `Sprint-10.1`). `--formato md` não exige esse padrão.

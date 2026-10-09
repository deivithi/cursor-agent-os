# Gotchas — manutencao-continua

1. **Coletor que falhou não é "zero sinais".** Token do `gh` expirado, MCP do Vercel fora ou log do Zo vazio devolvem lista vazia. O script recusa arquivo citado e ausente. Se o coletor falhou, não passe o arquivo e escreva a lacuna no resumo.
2. **Laço infinito no mesmo bug.** `MAX_TENTATIVAS = 2` manda para `escalar`. PR fechado sem merge (`pr-recusado`) conta como tentativa. `resolvido` zera as tentativas; `reset` apaga o item (só o PO decide).
3. **Dois PRs para o mesmo bug.** O script lê os PRs com rótulo `agente:manutencao` pela linha `manutencao-id: <id>` no corpo. PR aberto segura o item; PR mesclado ou fechado é conciliado no estado sozinho. PR sem essa linha não é reconhecido.
4. **Estado no repo duplicava PR.** O estado ficava em `main` e só chegava lá depois do merge do PO. Agora ele fica em `~/.claude/manutencao/<slug>.json`, fora do git. Perder o arquivo custa no máximo um comentário repetido: os PRs abertos vêm do GitHub.
5. **Mesma quebra de CI, ids diferentes.** O id de CI é `ci:<workflow>@<sha da primeira falha da sequência>`. Quebra nova depois de um verde é item novo, sem herdar tentativas. Run em andamento não decide nada; `timed_out` e `startup_failure` contam como falha.
6. **PII no log de runtime.** Erro com CPF, e-mail ou telefone de lead não entra em arquivo, issue, PR nem Telegram. Mascare na coleta (AGENTS.md §3). O script mascara de novo no título e usa hash curto como id.
7. **Palavra-chave de gate é heurística.** `precisaGateHumano` usa regex com fronteira de palavra Unicode e só olha texto de issue (erro `jwt expired` e pacote `crypto-js` não travam). Falso negativo e falso positivo são possíveis. O agente de correção relê o diff e para se tocar cripto, LGPD ou dado em massa. Gate indevido ou spec já dada: o PO põe `gate:liberado`.
8. **Prompt injection pela issue.** Issue de autor de fora (`author_association` diferente de OWNER, MEMBER e COLLABORATOR) vai para `aguardando-triagem` até o PO pôr o rótulo `aprovado`. Mesmo de autor da casa, o corpo entra no prompt como dado não confiável. O `gh issue list --json` não tem esse campo: a coleta usa `gh api .../issues --paginate --slurp`.
9. **Runtime com erro de um usuário só.** 1 ocorrência vira MEDIUM e pode ser ruído de bot. Ajuste `limiar` na config quando o projeto tem pouco tráfego.
10. **CI de main falhando por infraestrutura.** Na org `tifebracis` o GitHub Actions não roda (pendência da TI em 06/10/2026). Sem run, não há sinal de CI: o gauntlet local do agente é a única prova.
11. **`isolation: "worktree"` usa o repo do cwd.** Rodando de `Documents/Cursor`, o worktree nasceria do monorepo. Crie o worktree com `git -C "$DIR" worktree add` e remova no fim.
12. **Dois remotes no clone de Indicações.** `origin` = tifebracis, `deploy` = deivithi. Todo `gh` leva `--repo`.
13. **`pnpm audit` sai com código 1 quando acha vulnerabilidade.** JSON válido com exit 1 é coleta bem-sucedida.
14. **PowerShell 5.1 grava `>` em UTF-16LE.** O script lê os dois formatos. Prefira bash ou pwsh 7 mesmo assim.
15. **Funcionalidade não é bug.** Issue de melhoria sem rótulo `aprovado` vira só proposta de spec. Implementar sem aprovação é expandir escopo (`plan-and-execute.md` §3).
16. **Orçamento existe por custo.** Cada correção é um agente com gauntlet e revisor. Subir o orçamento para "zerar a fila" multiplica o uso do plano.
17. **Resumo gerado depois da Fase 4 esconde os gates.** A Fase 4 marca os itens como tratados. Gere o `resumo.md` na Fase 2, junto com a `fila.json`.
18. **`~` entre aspas não expande.** Nem bash nem pwsh expandem `"~/..."` para programa nativo. O script troca o `~/` do início pela pasta do usuário.
19. **Rótulos são fixos no script.** A lista está em `references/projeto-indicacoes.json` (`_rotulos`). Rótulo com outro nome não tem efeito.
20. **CI escalado não trava o ciclo.** Só CI em `corrigir` ou com PR aberto segura os outros itens. Workflow que só o PO destrava (Actions desligado, `deploy-prd`) fica em `escalar` e o resto segue.
21. **Âncora de CI depois de verde fora da janela.** Se main ficou verde e quebrou de novo entre dois ciclos, e o verde saiu da janela de 50 runs, a quebra nova herda a âncora antiga. Risco baixo com ciclo diário; aumente `--limit` do `gh run list` se o repo tem muitos runs.
22. **Estado sem lock.** Registre os resultados em série, pelo orquestrador. Agentes em paralelo não gravam o estado.

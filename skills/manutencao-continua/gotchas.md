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
23. **`gh` local não lê `tifebracis` com a conta pessoal (404).** A config de Indicações usa `gh_conta: deivithilopes-ai`; o porteiro pega o token dessa conta no keyring e passa só ao filho.
24. **`pnpm` local quebra no shim da 12.8.1.** O porteiro roda `npx --yes <packageManager> audit --json`, com a versão do `package.json`.
25. **Dependabot desligado nos repos de Indicações.** A fonte de vulnerabilidade é o `pnpm audit`, não a API do GitHub.
26. **Vulnerabilidade só de dev ou sem correção vira LOW.** Caso real de 09/10: `braces` (dev, sem versão corrigida) vai para backlog; `source-map-js` (prd, corrigida em 1.2.2) vai para correção.
27. **Agente headless sem shell.** O corretor só tem `Read,Glob,Grep,Edit,Write`. Se uma correção precisar rodar algo, ela falha e volta como lacuna; não dê shell ao agente fora de sandbox.
28. **Registrar a tarefa e rodar o ciclo completo são bloqueados para o agente.** O classificador do modo automático trata como "criar agente autônomo". O operador roda `instalar-agenda.ps1` uma vez; o painel avisa se a agenda parar.
29. **Console da tarefa.** A tarefa usa `conhost.exe --headless` para não abrir janela por até 2 h de agente.
30. **O token da empresa é admin e `main` aceita push de admin** (`enforce_admins=false`). Por isso o LLM nunca recebe o token: só o porteiro faz push, e só em `manut/*`. Endurecimento opcional do lado do GitHub: token fine-grained sem admin, sem `gist` e sem `workflow`, e `enforce_admins` ligado em `main` (decisão do PO e da TI).
31. **O porteiro não roda testes nem build.** Executariam código do agente na máquina com o keyring. Só checagem estática (lint + typecheck) com a config do `main`, que o agente não pode mudar. O PR diz isso; `pnpm verify` roda na revisão humana ou no CI.
32. **Item que o agente marcou `gate-humano` ou que mexeu em arquivo proibido** vira pendência do PO no painel e conta como tentativa: depois de 2, escala.
33. **`pnpm update --depth Infinity` não existe no pnpm 12.** Use `--depth 100`.
34. **Worktree preso no Windows.** Processo com cwd dentro do worktree (inclusive um shell aberto) impede o `git worktree remove`. O porteiro tenta de novo com `rmSync` e roda `git worktree prune`.
35. **`origin` nunca buscado no clone local.** O clone de Indicações só tinha `deploy/*`. O porteiro faz `fetch origin main` com o token da empresa antes de abrir worktree.
36. **Arquivo em pasta ignorada pelo git.** O agente pode gravar em `node_modules/` ou `coverage/` (o diff não mostra). Por isso a checagem roda num worktree novo, criado do commit, com `git status --porcelain --ignored` vazio antes do install. Reproduzido na revisão de 09/10: `npx` preferiu um `pnpm` falso em `node_modules`, e o eslint 10 carregou `coverage/eslint.config.mjs`.
37. **CI do PR roda o teste do agente.** Os workflows de Indicações rodam com `permissions: contents: read` e sem `secrets.*`; o teste não tem segredo para vazar. Se um workflow passar a usar segredo em `pull_request`, rode `manut/*` sem segredo ou exija aprovação.

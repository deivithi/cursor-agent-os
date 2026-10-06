---
name: corte-release
description: >
  Corte de versão com QA por enxame de agentes. Avisa cada autor dos PRs que entram no corte,
  publica o build em hml, solta um enxame de agentes (dirigidos pelo mapa de funcionalidades +
  macacos do caos) que usam o produto como usuário real, reproduz os achados graves comparando
  com prd, faz a triagem (regressão vs pré-existente), corrige em worktree com teste e revisor
  e corta patch release por cherry-pick. Adaptação do fluxo "release manager + bot de engenharia"
  para o ecossistema Febracis (gh + Telegram via Zo + Workflow). Ativa com "corte", "cortar
  versão", "corte de release", "release cut", "fazer o corte", "patch release", "cherry-pick
  no release", "enxame de QA", "fuzz de release", "chaos monkey", "/corte".
allowed-tools: Bash, Read, Glob, Grep, Edit, Write, Agent, Workflow
metadata:
  author: deivithi
  version: "1.0.0"
---

# ✂️ Corte de Release — corte, enxame de QA, triagem e patch

O corte de versão é tarefa repetitiva: avisar quem tem PR no corte, subir o build, testar
tudo, separar o que é regressão e corrigir. Esta skill passa esse trabalho para agentes.
O PO decide só três coisas: **cortar**, **segurar o corte** e **liberar prd**.

> Origem: post sobre o fluxo com dois bots (gerente de release + bot de engenharia) no Slack.
> Aqui o canal é o próprio PR no GitHub (o autor recebe a notificação) e o Telegram do PO via
> Zo. O enxame roda no `Workflow` do Claude Code, não em outro modelo.

## 📁 Estrutura

- `SKILL.md` — você está aqui.
- `scripts/notas-do-corte.mjs` — notas da versão, aviso por autor e próxima tag de patch (node puro).
- `references/enxame-qa.workflow.js` — script do enxame para o `Workflow` (args = mapa).
- `references/mapa-indicacoes.json` — mapa de funcionalidades da Plataforma de Indicações (6 áreas + 2 caos). Serve de modelo para outro projeto.
- `references/triagem-e-patch.md` — tabela de decisão, correção por agente e passo a passo do patch.
- `tests/` — gauntlet do script de notas e da lógica do enxame (agentes simulados).
- `gotchas.md` — problemas conhecidos.

## Quando usar

- O PO pede "faz o corte da sprint 10" ou "corta uma versão".
- Um achado grave apareceu em hml depois do corte e precisa de patch (`sprint-10.1`).
- Rodar só o enxame de QA numa área depois de uma correção.

## Quando NÃO usar (→ Handoff)

- Teste de uma tela isolada durante o desenvolvimento → `product-verification` ou `webapp-testing`.
- Review de um PR → `code-review` / `auto-pr-review`.
- Pipeline de CI/CD → `cicd`.
- Incidente em prd → `runbook` (e `docs/RUNBOOK.md` do projeto).

## Convenções

- `REPO` = repo oficial (`tifebracis/febracis-indicacoes`). **Todo** comando `gh` leva `--repo "$REPO"`: o clone tem dois remotes (`origin` = tifebracis, `deploy` = deivithi).
- **Tag-base** (`sprint-10`) nasce no corte, em cima do commit de `main`. **Tag de patch** (`sprint-10.1`) nasce no ramo `release/sprint-10`. O próximo corte parte sempre da tag-base anterior, nunca da de patch.
- `git describe --tags --abbrev=0 origin/main` devolve a tag-base: as tags de patch não ficam em `main`.

## Workflow

### Fase 1 — Corte (o PO diz "corta")

1. Atualize: `git fetch origin --tags`. Confira `git status -sb` e o CI de `main`.
2. Tag-base anterior: `ANTERIOR=$(git describe --tags --abbrev=0 origin/main)`.
3. Commits novos: `git log "$ANTERIOR"..origin/main --format=%H > commits.txt` (no scratchpad).
4. PRs mesclados: `gh pr list --repo "$REPO" --state merged --base main --search "merged:>=$(git log -1 --format=%cs "$ANTERIOR")" --limit 500 --json number,title,url,author,mergedAt,mergeCommit > prs.json`.
5. Notas e avisos: `node skills/corte-release/scripts/notas-do-corte.mjs --prs prs.json --commits commits.txt --versao <nova> --anterior "$ANTERIOR" --prazo "<dia hora>" > corte.json`. Para o arquivo de notas: o mesmo comando com `--formato md > notas.md`.
6. Zero PR → pare e diga "não há o que liberar".
7. Grave os avisos: o mesmo comando do passo 5 com `--saida-avisos avisos/` cria `avisos/<pr>.md`. Para cada arquivo: `gh pr comment <pr> --repo "$REPO" --body-file avisos/<pr>.md`. Bots já ficam fora.
8. Mande o resumo para o PO no Telegram (via Zo): versão, número de PRs, autores, prazo de objeção.
9. Crie a tag-base e o ramo no mesmo commit:
   `BASE=$(git rev-parse origin/main)`, `git tag -a <nova> "$BASE" -m "corte <nova>"`, `git push origin <nova>`, `git push origin "$BASE":refs/heads/release/<nova>`.

### Fase 2 — Build em hml (corre junto com o prazo de objeção)

1. Publique o ramo do corte em hml pelo caminho do projeto. Indicações: `git push deploy release/<nova>:hml` (Vercel) e `bash infra/zo/provision.sh hml` no clone de hml do Zo (`docs/AMBIENTES.md`). É a única escrita direta permitida em `hml` (ver `references/triagem-e-patch.md` §4).
   - **Push recusado (não é fast-forward):** acontece em todo corte depois de um patch, porque o cherry-pick deixou em `hml` um SHA que `main` não tem. Rode `git fetch deploy && git cherry release/<nova> deploy/hml`. Linhas com `-` já estão no corte (o patch veio de `main`). Todas com `-` → peça ao PO: "Posso rodar `git push --force-with-lease=hml:<sha-atual> deploy release/<nova>:hml`? Nada se perde: os N commits de `hml` já estão no corte." Alguma linha com `+` → pare: tem commit em `hml` que não está em `main`; leve ao PO.
2. Espere o build ficar pronto e rode o smoke do projeto. Smoke falhou → corrija antes do enxame.

### Fase 3 — Enxame de QA

1. Copie o mapa (`references/mapa-indicacoes.json` ou o do projeto) e preencha `versao`, `anterior`, `alvo` e `referencia`. Crie a sessão de QA em hml.
2. Rode `Workflow({ scriptPath: "<caminho absoluto>/skills/corte-release/references/enxame-qa.workflow.js", args: <mapa como objeto JSON> })`.
3. Leia o retorno inteiro:
   - `itens`: achados deduplicados, com severidade e origem.
   - `gravesNaoReproduzidos`: graves que o agente de reprodução não confirmou. Confira à mão.
   - `reproducaoFalhou`, `consolidacaoFalhou`, `exploradoresSemResultado`: área sem resultado é lacuna, não "tudo ok".
4. Revogue a sessão de QA.

### Fase 4 — Objeções, triagem e correção

1. No prazo do aviso, leia as respostas: `gh pr view <pr> --repo "$REPO" --comments` para cada PR avisado.
2. Objeção ou bloqueio → leve ao PO com o PR e o motivo. Só o PO decide segurar o corte.
3. Aplique a tabela de `references/triagem-e-patch.md` §1 a cada item.
4. CRITICAL/HIGH: um agente por achado em worktree, teste primeiro, `pnpm verify`, PR, revisor independente (§2).
5. MEDIUM/LOW: registre no `docs/BACKLOG.md` com a evidência.
6. Avise o PO no Telegram: achados, destino de cada um, PRs abertos.

### Fase 5 — Patch e liberação

1. Regressão ou CRITICAL corrigido → cherry-pick no ramo do corte e tag de patch (§3).
2. Rode o enxame de novo só nas áreas tocadas.
3. Tudo verde → `gh release create <tag> --repo "$REPO" --verify-tag --notes-file notas.md`. A tag é a última de patch, ou a tag-base se não houve patch.
4. **Peça a confirmação do PO antes do deploy em prd.** Sem "sim" explícito, pare aqui.

## Progressive Disclosure

| Complexidade | Comportamento |
|---|---|
| **Simples** (1–3 PRs, só docs/ajuste) | Fases 1, 2 e enxame com 2 áreas tocadas + 1 caos |
| **Médio** (sprint normal) | Fluxo completo, 6 áreas + 2 caos (≤ 10 exploradores) |
| **Complexo** (migração, auth, fila, dado em massa) | Fluxo completo + `security-audit` no diff do corte + carga (`docs/CARGA.md`) antes de prd |

## Handoff Points

| Quando | Repassar para | Condição |
|---|---|---|
| Achado de segurança real | `security-audit` | XSS, IDOR, vazamento de PII, sessão |
| Correção toca cripto/LGPD/retenção | `human-architectural-gate` | Bloqueia até ter spec do PO |
| Falha de infraestrutura no build | `runbook` | Padrão já conhecido no RUNBOOK |
| Achado vira spec maior | `spec-planner` | Não cabe em patch |

## Gotchas

⚠️ Consulte `gotchas.md`. Principais:

1. **Filtro por data pega o último PR do corte anterior** (`mergedAt` sai ~1 s depois do commit da tag). Use `--commits`.
2. **Enxame sem sessão de QA** → todos os agentes param no login. Crie a sessão antes e revogue no fim.
3. **"Nenhum achado" com cobertura vazia** não é aprovação. Confira `exploradoresSemResultado`.

## Gauntlet desta skill

```bash
node --test skills/corte-release/tests/notas-do-corte.test.mjs skills/corte-release/tests/enxame.test.mjs
```

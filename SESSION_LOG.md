# SESSION_LOG.md — Histórico de sessões do agente

> Atualizado em: 30/09/2026 — memória reconciliada com o disco. Ordem cronológica decrescente.
>
> **Lacuna fechada em 30/09/2026:** nenhuma sessão estava registrada entre 22/09 e 30/09, apesar de
> trabalho real com evidência no disco. Os quatro blocos abaixo foram reconstruídos a partir de
> commits, mtime de arquivos e relatórios de auditoria — não de lembrança.

## 2026-10-09 — Skill `manutencao-continua` (ciclo de manutenção por agente)

- ✅ Origem: post sobre falta de manutenção em software feito com IA ("enquanto depender de humano no ciclo, não escala"). Adaptação: o humano sai do ciclo operacional e fica só no irreversível (prd, LGPD, cripto, dado em massa).
- ✅ `skills/manutencao-continua/`: SKILL (5 fases: coletar, triar, corrigir em worktree até PR, resto da fila, resumo no Telegram), `scripts/triagem.mjs` (node puro), config de Indicações, 22 gotchas, comando `/manutencao`, junction em `.claude/skills/`.
- ✅ Triagem: dedup, orçamento por ciclo, CI de main primeiro, gate por regex Unicode + rótulos (`gate:liberado` libera), autor de fora só com `aprovado` (anti prompt injection), máscara de PII com dígito verificador de CPF, estado fora do repo em `~/.claude/manutencao/<slug>.json`, conciliação automática de PRs mesclados/fechados, âncora de CI no estado.
- ✅ Gauntlet: 33 testes `node --test`, incluindo CLI pela junction. Revisão adversarial em 3 rodadas (1 CRITICAL + 6 HIGH → 2 HIGH → 0 HIGH); MEDIUM da 3ª rodada corrigidos. Coleta real validada contra `deivithi/febracis-indicacoes` (issues REST + runs).
- ⚠️ `gh` local não acessa `tifebracis` (404): a coleta oficial precisa do token da conta da empresa.
- ➡️ Próximo: o PO escolhe a agenda (tarefa local headless, automação do Zo ou rotina na nuvem); custo pede confirmação.

## 2026-10-07 — Organização das rules (ADR-016)

- ✅ Origem: análise do setup de DHH (harness qualquer, poucas skills, revisão adversarial) contra o nosso.
- ✅ `rules/plan-and-execute.md` reescrita: ciclo, lista fechada de quando perguntar, resolve-não-transfere, 1ª resposta, confiança, loops.
- ✅ 11 rules para `rules-archive/` e 3 para `rules-on-demand/`, com README em cada pasta. Referências cruzadas corrigidas.
- ✅ `.cursor/rules/first-response.mdc` removido; `plan-and-execute.mdc` espelha a rule nova.
- ✅ `scripts/memory-doctor.ps1`: lista de dependências críticas atualizada.
- ✅ ADR-017: 739 skills `cyber-*` fora do catálogo ativo via `scripts/cyber-skills-toggle.ps1`; `/cyber` lê sob demanda; cópia de 4.085 arquivos saiu do índice do repo raiz.
- 🔎 Não tocado: `~/.cursor/rules/caverna-activate.md` (sem `.off`, ligada a hook).

## 2026-10-06 — Gauntlet contínuo: score, catraca e Stop hook automático (ADR-015)

- ✅ Origem: fala de Alexandr Wang (Meta, Startup School 2026) — "loop certo + métrica certa". Pesquisa: Karpathy autoresearch, AlphaEvolve/OpenEvolve, GEPA, Anthropic evals, EvilGenie/ImpossibleBench (reward hacking). Citação literal de Wang não verificada (só paráfrase).
- ✅ `scripts/gauntlet/gauntlet.py` (stdlib): gates + integridade de teste + score 0-100 + catraca de baseline; `init`/`run`/`status`/`accept --reason`/`hook`. Integridade comparada com o último estado aprovado (`git stash create` preso em `refs/gauntlet/*`), hash do `gauntlet.json`, supressões (`noqa` nu, `pragma: no cover`…), asserts triviais não contam.
- ✅ Stop hook (Claude Code + Cursor): roda quando o código muda; falha/regressão bloqueia o fim do turno com feedback; sai por `max_blocks`, estagnação (I(t)=0) ou teto da sessão. Sem mudança < 0,6 s.
- ✅ Piloto DRE_Eventos (`gauntlet.json` + `gauntlet.coveragerc`, commits `ac7b987`, `ce751b2`): coverage real sem os testes caiu de 86% para 77% (o número antigo era inflado). Dogfood: o próprio gauntlet tem `gauntlet.json`.
- ✅ Gauntlet do gauntlet: 107 testes, 91% coverage no motor, ruff limpo, C901 ≤ 10. Revisão adversarial em 3 rodadas (21 → 17 → 9 achados), todos HIGH/MEDIUM corrigidos.
- ⚠️ Bloqueio: o classificador do auto mode negou ao agente editar `~/.claude/settings.json` (automodificação). Instalação do hook fica com o operador: `py -3 scripts/gauntlet/install_hooks.py`.
- ➡️ Próximo: operador roda o instalador; ativar `gauntlet.py init` nos próximos projetos com testes; mutation testing quando houver CI Linux.

## 2026-10-06 — Skill `corte-release` (corte de versão + enxame de QA + patch)

- ✅ Origem: post sobre release manager + bot de engenharia (Grok Bot no Slack). Adaptado ao ecossistema: aviso no PR do GitHub + Telegram via Zo, enxame no `Workflow` do Claude Code.
- ✅ `skills/corte-release/`: SKILL (5 fases, tag-base no corte, ramo `release/<versao>`, patch `sprint-NN.1` por cherry-pick, deploy prd só com "sim" do PO), `scripts/notas-do-corte.mjs` (filtro por ancestralidade `mergeCommit.oid`; aviso por autor; próxima tag de patch), `references/enxame-qa.workflow.js` (áreas do mapa + caos, reprodução com comparação hml × prd, consolidação), `references/mapa-indicacoes.json` (6 áreas do MANUAL), triagem e gotchas. Comando `/corte`.
- ✅ Gauntlet: 20 testes (`node --test`), incluindo o workflow com agentes simulados; smoke real `sprint-08..sprint-09` devolveu só o PR #14.
- ✅ Revisão adversarial independente: 4 HIGH + 6 MEDIUM + 3 LOW. Todos corrigidos; o HIGH 1 era real (filtro por data trazia de volta o último PR do corte anterior).
- ➡️ Próximo: primeiro uso real no corte da sprint 10 da Plataforma de Indicações.

## 2026-10-06 — Indicações Febracis: Sprint 9 = passagem do projeto para a Lorrany (DigitalOcean)

- ✅ Pedido do PO: repositório organizado na conta da empresa para a dev Lorrany Marra subir sem dúvidas; ela implanta na **DigitalOcean da Febracis** (Zo/Vercel só referência). Repo oficial criado: `tifebracis/febracis-indicacoes` (privado, histórico completo, só `main` e `hml`, tags/releases `sprint-01`…`sprint-09`, `main` protegida, Lorrany admin).
- ✅ Sprint 9 (PR #14 no espelho, squash `16c4ec0`): T93 acesso temporário sem 2º fator por prazo (ADR-022, corte total no vencimento); T94 ambiente local sem Zo (`pnpm local:*`, Docker); T95 pacote DigitalOcean (imagens por digest, compose + Caddy, init SCRAM, trava de papel na API, vigia e backup age+Spaces, ADR-023); T96 docs (PRD/SDD/BACKLOG separados com situação, SPRINTS, guia de entrada, skill nova `/ambiente-local`).
- ✅ Gauntlet: 4 checks verdes; revisão de segurança (6), revisão de código (11) e simulação "Lorrany" (15) — 32 achados, todos corrigidos; re-checagem aprovada.
- ✅ Deploy hml + prd (Zo reprovisionado com a migração, smokes do gateway e do Vercel ok). Acesso temporário da Lorrany em prd provado (admin só da Febracis Demo, até 05/11/2026 10:33); senha em arquivo 0600 no Zo.
- ⚠️ Bloqueios: GitHub Actions da org `tifebracis` não executa nenhum workflow (TI); `.claude/settings.json` do projeto bloqueado pelo classificador (opcional).
- ➡️ Próximo: Lorrany faz a sprint 10 (implantação na DigitalOcean); PO apaga o arquivo da senha depois de enviar e cobra a TI pelo Actions.

## 2026-10-06 — Indicações Febracis: Sprint 8, iniciada em 05/10 (T04 fila genérica + T92 runbook/manual)

- ✅ Repo `REferido - Febracis` (`deivithi/febracis-indicacoes`): PR #10 squash; `main` = `hml` = clones do Zo no mesmo commit. ADR-021 (fila própria no Postgres no lugar do pg-boss).
- ✅ Deploy em prd e hml (Vercel READY, Zo reprovisionado, smokes ok). 4 simulações do runbook em hml; a 3ª achou e corrigiu falha falsa do `restore-test.sh`.
- ✅ Skill `indicacoes-febracis`: 3 cópias iguais (usuário, workspace — agora versionada aqui — e repo do projeto).
- ➡️ Próximo: calibração da carga com o pico real do CIS (Comercial); T48 quando o Salesforce liberar; aprovação de Design da T06.

## 2026-10-02 — Skill `ste-ptbr` (STE-PT: ASD-STE100 adaptado ao PT-BR)

- ✅ Origem: post do Karpathy sobre pedir saída em ASD-STE100. O operador pediu a ideia adaptada ao contexto Febracis, em PT-BR.
- ✅ `skills/ste-ptbr/`: regras (9 seções), dicionário PT-BR (registro, ambiguidade Salesforce, slop de IA, verbo), níveis 100 e 80, exemplos Febracis, gotchas. Comando `/ste`.
- ✅ Linter `scripts/ste_lint.py` (stdlib) + testes; prancha HTML com verificador (`assets/`, gerada por `build_prancha.py`). Núcleo JS com paridade conferida contra o Python.
- ✅ Revisão adversarial independente: 8 Major + 17 Minor, todos corrigidos com teste de regressão; re-checagem feita.
- ✅ Prancha publicada como artifact privado: <https://claude.ai/artifact/H6mV1mdtPP47jYfLMv2P58>
- ✅ Correção do operador: o STE é a forma padrão da comunicação com ele, não uma ferramenta sob comando. Nova regra sempre ativa `rules/ste-comunicacao.md` (nível 80, só em mensagens, não em código), com cópias `.mdc` no Cursor, linha no `AGENTS.md` §7 (v3.0.4) e no `~/.dsh/AGENTS.md`. Memória nas duas camadas.
- ⏳ Próximo: usar `/ste` nos runbooks de `lead-audit`/`commission-audit` e nos passos Gherkin do `salesforce-bdd-spec-architect`.

## 2026-10-01 — Plataforma de Indicações Febracis: pendências fechadas + Vercel no ar

- ✅ Web no Vercel (prd = main, hml = branch hml); APIs no Zo atrás de gateway Caddy com identidade **OIDC do Vercel** (sem segredo compartilhado). Smoke ponta a ponta `scripts/smoke-vercel.sh`.
- ✅ Backup externo cifrado (age) no Google Drive, diário 04:30; teste de restauração diário 04:10.
- ✅ Hook pre-push (gitleaks + verify), dev-setup por chave restrita, segredos do transcription-router/febracorretor movidos ao cofre (senhas do febracorretor rotacionadas).
- ✅ Revisões independentes: nenhum achado acima de Baixo pendente.
- ⏳ PO: 2 cópias offline da chave age; rotacionar chaves Deepgram/AssemblyAI/Gladia; plano Vercel para uso comercial.

## 2026-10-01 — Plataforma de Indicações Febracis: T02 (ambientes)

- ✅ ADR-009: dev/hml/prd/eph no Postgres do Zo; `infra/zo/provision.sh` idempotente; `selftest.sh` recria do zero, roda o provision 2×, faz smoke (banco + app) e remove sem sobras (43s).
- ✅ Dev local por túnel SSH com chave restrita a `permitopen 127.0.0.1:5432`.
- ✅ Selftest pegou bug real (Turbo filtrava `API_INTERNAL_URL` → web de prd/eph chamaria a API de hml). Corrigido e coberto por teste.
- ✅ Revisão independente: 1 Alto + 5 Médios corrigidos e reconferidos (APPROVE).
- ⏳ prd sem serviço público (limite de 10 serviços no Zo); backup fora do servidor e teste de restore antes de dado real.

## 2026-10-01 — Plataforma de Indicações Febracis: análise, T01 e deploy no Zo

### Resumo
Projeto novo em `REferido - Febracis/` (repositório próprio, `github.com/deivithi/febracis-indicacoes`, privado).
Análise de PRD/SDD/backlog aprovada pelo PO; T01 entregue com CI verde e deploy provisório no Zo.

### O que foi feito
- ✅ ADR-001 aceita (Opção A); ADR-005 (pg-boss + outbox), 006 (pessoa por marca), 007 (Zo provisório), 008 (stack; TS 6.0.3 porque typescript-eslint exige <6.1).
- ✅ Backlog: ciclo T18↔T30 quebrado, caminho crítico revisto, 10 novos "Pontos a verificar".
- ✅ Zo: banco `febracis_indicacoes`, schema `indicacoes`, roles owner/app sem BYPASSRLS; serviço único `indicacoes` → https://indicacoes-deivithi.zocomputer.io (API só em localhost).
- ✅ Duas revisões independentes; todos os achados acima de Baixo corrigidos.

### Decisões do operador
- Fechamento automático em todo projeto/sessão: review completo → corrigir → docs/skills → commit, push, deploy (memória `fechamento-automatico`).

### Pendências
- Branch protection indisponível (GitHub Free + repo privado): GitHub Pro, org Febracis ou aceitar sem proteção.
- Zo no limite de 10 serviços HTTP.
- Segredos em texto aberto em env de outros serviços Zo (transcription-router, febracorretor) — mover para `/home/.z/secrets/` e rotacionar.

## 2026-09-30 — Reconciliação da memória + bootstrap automático no DSH

### Resumo
Auditoria da camada de memória contra o disco e o Git achou **20 contradições verificadas**, todas
da mesma natureza: número escrito à mão envelhecendo em silêncio. A causa raiz foi tratada, não os
sintomas — o estado volátil passou a ser gerado.

### O que foi feito
- ✅ `scripts/memory-doctor.ps1`: recomputa contagens de skills, worktrees, HEADs por repo, estado
  da tarefa de sync, datas declaradas, ordem do `SESSION_LOG` e referências quebradas. Gera
  `MEMORY_STATE.md` e o bloco injetado em `~/.dsh/AGENTS.md`.
- ✅ Descoberto e provado o único vetor automático do DSH: `@deepseek-ai/dsh-agent-instructions`
  injeta `$DSH_HOME/AGENTS.md` + a cadeia de `AGENTS.md`/`CLAUDE.md` do projeto (budget 65.536
  bytes), sem comando. O DSH **não monta hooks** — nenhum bundle padrão traz `hooks-claude-code`.
- ✅ Criado `~/.dsh/AGENTS.md` com identidade, infraestrutura canônica, regras de trabalho e o
  bloco de estado gerado. Verificado ao vivo: o DSH recarregou o arquivo na mesma sessão.
- ✅ Criada `rules/session-bootstrap.md` — contrato de abertura e fechamento; regra do número à mão
  proibida.
- ✅ ADR-014 registrado em `DECISIONS.md` com a tabela completa das 20 contradições.
- ✅ `$D`/`$d` em PowerShell são a mesma variável (case-insensitive): colisão entre a lista do
  digest e a variável de loop sobrescreveu a saída do gerador. Corrigido e revalidado.

### Correções materiais aplicadas
- Remotes da raiz: tinham `origin` + `cloud`, contrariando a nota "sem remote" e o próprio ADR-006.
- `deivithilopes-ai/declaw` **não existe** (HTTP 404) e era declarado `canonical`.
- `webwright` sincronizado (0/0), não "behind 4"; `cybersecurity-skills` ahead 33 / behind 223.
- DRE_Eventos em `6380b65` com 649 testes (não `682cedf` com 595); `dre-eventos-fix` 161 commits atrás.
- Sync do Cursor `Disabled` desde 16/06/2026 — o "sync diário" não roda.
- Scheduler do Hermes parado desde 08/07/2026 — FIO-IA não gera há quase 3 meses.
- Skill `pulso-finance` v5.0.0 (não v5.6.0); handle do X `@opanteranegra77` (não `@opanteraos`).
- `PROJECTS_INDEX.md` tinha as 22 linhas marcadas "(sem origin)" — erro sistemático de leitura.
- Projeto **civictrust** descoberto e catalogado (repo real, ausente de toda a memória).

### Entregas commitadas
5 commits: `a17453d` (gerador + bootstrap), `9b2a1da` (reconciliação), `312706c` (regra de acentos
+ guard do OpenWiki, pendurados desde 18–21/09), `9b9729f` (skill anatomy, pendente desde 28/09) e
`46ebd08` (entregáveis do civictrust).

### Pendências
- 📌 `~/.openwiki/.env` não existe: o gate do OAuth do X continua fechado. Não rodar `openwiki auth x`.
- 📌 `skills/pptx-generator` é o único diretório de skill sem `SKILL.md`.
- 📌 Reativar `Febracis-Cursor-SyncDaily` e o scheduler do Hermes, se for a intenção.
- 📌 Reconstruir o par de remotes do `declaw` (o `cloud` morreu) e ressincronizar o mirror da raiz.

### Segunda rodada — auditoria adversarial e correções

Uma auditoria adversarial foi disparada contra a primeira entrega e **encontrou defeitos reais**. Registro aqui porque o processo importa mais que o resultado:

| Achado | Gravidade | Correção |
|---|---|---|
| Toda contagem de pendência por repo saía **1** (`Invoke-Git … -split` lido como parâmetro; erro engolido por `SilentlyContinue`). DRE_Eventos dizia 1 onde há 12 | **Grave** — era o número que toda sessão futura leria primeiro | Helper `Get-GitStatusLines`, com a armadilha documentada no código |
| Scheduler do Hermes não era medido por ninguém | Alto — o bloqueio do FIO-IA ficava invisível | Lê `%LOCALAPPDATA%\hermes\cron\ticker_heartbeat` (é arquivo, não campo do JSON) |
| `Saúde: ATUALIZADA` era inalcançável por construção, tornando letra morta a exigência da própria rule | Alto | Classe de **pendência aceita** (deliberada, não conta para a saúde) |
| O artefato gerado contava como sujeira da raiz — snapshot estale-por-construção | Alto | `MEMORY_STATE.md` excluído da contagem, com isso declarado no snapshot |
| Fingerprint ignorava HEAD e sujeira da raiz | Médio | Ambos entram no cálculo (verificado: o fingerprint muda quando o HEAD muda) |
| `criticalRefs` não cobria `session-bootstrap.md`, `SECURITY.md`, `HARNESS.md`, `.cursorrules`, `out/civictrust`, o launcher nem o `settings.json` | Médio | Lista ampliada de 26 para 40 caminhos |
| Só 1 das 3 tarefas agendadas mortas era vista | Médio | As 5 do pipeline Febracis são checadas |
| `pptx-generator` classificado como skill quebrada | Baixo | É plugin bundle com 5 skills aninhadas — `Test-PluginBundle` separa os casos |
| "behind 137" sobreviveu na `SKILLS_INDEX` que dizia tê-lo corrigido | Médio | Corrigido para ahead 33 / behind 223 |
| `.git` descrito como arquivo em 3 lugares | Baixo | É diretório em todos os 14 — medido |
| `quirky-easley` ausente do índice; "10 pastas" listando 11 | Baixo | Corrigido |
| Evidência do handle do X citava caminho inexistente | Baixo | Caminho real: `skills/openwiki-fio-synthesizer/references/humanizer-fio-rules.md`; 8 arquivos, não 5 |

**Lição registrada:** o erro de `-split` dentro de chamada de função/método apareceu **duas vezes** neste mesmo arquivo. É a mesma classe do `-f` lido como parâmetro. A defesa é a armadilha estar escrita no código, no ponto de uso — e nunca confiar em `SilentlyContinue` para esconder erro de sintaxe de operador.

Verificação final: 3 execuções com repositório imutável produzem conteúdo **idêntico** (idempotente); contagens conferidas uma a uma contra o disco; raiz reportada como `limpo` sem pendência fantasma.

### Terceira rodada — a segunda auditoria achou 3 bloqueadores

A re-auditoria confirmou os 11 defeitos como corrigidos **no mérito** e apontou o que ainda impedia a promessa central. As três correções que fecharam o ciclo:

| Bloqueador | Diagnóstico da auditoria | Correção |
|---|---|---|
| `Saúde: ATUALIZADA` **inalcançável** | Tarefa agendada desligada e scheduler parado entravam como pendência acionável — nenhuma edição de memória limparia isso, então a exigência do §6 era insatisfazível | **Três níveis**: pendência acionável (afeta a Saúde) · aceita (deliberada) · **Condição de ambiente** (operação, reportada em seção própria, não afeta a Saúde). Verificado: `ATUALIZADA` alcançada |
| Snapshot **estale-por-construção** sobrevivia para o fonte do gerador | O commit carregava um `MEMORY_STATE.md` afirmando pendência que o próprio commit não tinha | Lista de arquivos ignorados declarada (`MEMORY_STATE.md` **e** `scripts/memory-doctor.ps1`) e **impressa na saída** — não é critério oculto |
| **6.119 caminhos pendentes invisíveis** | `.claude/worktrees/angry-bassi-58c13c` é o maior bolsão de trabalho não commitado do ecossistema e não aparecia em "Estado do ecossistema" | `git worktree list` alimenta seção própria, com os 2 worktrees registrados fora de `worktrees/` |

Achados menores também corrigidos: lista por-job do Hermes saía vazia (regex não casava JSON aninhado — agora parseia de verdade, 4 jobs com estado e última execução); números à mão dentro do próprio gerador removidos (o texto de worktrees deriva tudo do disco); código morto removido; frase dos worktrees sem remote no índice dizia 13 nomes para 12 vagas; contagem do handle do X (9, não 8).

**Distinção que passou a valer como decisão de arquitetura (AGENTS.md v3.0.3, §6):** saúde da memória ≠ condição de ambiente. Misturar as duas tornava a meta inatingível e a instrução, letra morta. O ambiente continua reportado — só não contamina o veredito da memória.

---

## 2026-09-28 — Edição das skills de harness (auditoria de gargalo)

- ✅ `skills/anatomy-of-agent-harness/SKILL.md` e a cópia em `.claude/skills/…` ganharam a seção
  "Auditoria de gargalo (default)", nota sobre trabalho de conhecimento e `perf-hill-climb`.
- ⚠️ A edição ficou 2 dias pendurada no working tree sem registro de sessão. Commitada em 30/09
  como `9b9729f`.
- ⚠️ A seção cita "Gargalo humano" em `rules/plan-and-execute.md`, **que não existe**. Referência
  quebrada — pendente corrigir na skill ou criar a seção.

---

## 2026-09-24 — CivicTrust: dossiê, PRD e spec técnica

- ✅ Repositório real `deivithi/civictrust` (Go), HEAD `49b840c`, criado em 24/09 com
  "feat(demo): demonstração pública na Vercel".
- ✅ Três entregáveis produzidos em `out/civictrust/`: dossiê estratégico, PRD do Public Action
  Gateway v0.1 e spec técnica v0.1.
- ⚠️ Trabalho substantivo que **não** entrou em nenhum arquivo de memória na época. Catalogado em
  30/09 (commit `46ebd08` + registro no `PROJECTS_INDEX` e `config.json`).

---

## 2026-09-22 — DRE Eventos: refresh de 5h e watcher de flags do Fabric

- ✅ `37bee26` — "feat(ops): refresh DRE a cada 5h sem niveis".
- ✅ `6380b65` — "fix(ops): ignore completed Fabric pull flags in watcher".
- ⚠️ Os dois commits não foram registrados na memória; a memória seguiu apontando `682cedf` como
  HEAD por 8 dias.
- 📌 Working tree do projeto ficou com 4 modificados + 10 não rastreados, que a memória descrevia
  como "apenas `docs/analysis/`".

---

## 2026-09-21 — Auditoria profunda e hardening da aplicação

- ✅ Corrigidos riscos de sessão, pool Postgres, contexto adulterável do chat, locks, CI, dependências frontend, cache-bust e acessibilidade.
- ✅ `npm audit` terminou com 0 vulnerabilidades após atualização do lockfile.
- ✅ Validação acumulada: 649 testes, Ruff, build frontend, CSP PASS, UI Fotos 45/45 e smoke produção 43/43.
- ✅ Deploy final validado com HTTP 200 e `db=ok`.
- 📌 Pendências mantidas com evidência: restore/criptografia de backup, login E2E real, acessibilidade completa do chat React e coordenação distribuída.

---

## 2026-09-21 — Mapeamento persistente do DRE Eventos

### Resultado
- ✅ Confirmada a cópia canônica em `DRE_Eventos/`, com remote `deivithi/febracis-dre-eventos`, branch `main` e commit `682cedf`.
- ✅ Identificada a cópia adicional `worktrees/dre-eventos-fix`; a cópia temporária em `%LOCALAPPDATA%/Temp` não foi tratada como fonte.
- ✅ Consolidada a distinção entre a aplicação principal, o portal relacionado `febracis-dre` e o repositório operacional `dre-eventos-ops`.
- ✅ Atualizados `AGENT_MEMORY.md`, `PROJECTS_INDEX.md`, `CONTEXT.md`, `DRE_Eventos/AGENTS.md` e `DRE_Eventos/docs/AGENT_CONTEXT_DRE.md`.
- ✅ Suíte completa passou no `.venv`: 595 testes; o Python global não possui `psycopg2`.
- ⚠️ Verificação posterior encontrou 1 falha em `tests/test_fotos.py` (`maxlength="240"` ausente em `templates/partials/dre_table.html`); o build frontend passou via `npm.cmd run build`.
- ✅ Produção respondeu `/api/health` com banco, Hermes e LLM operacionais; acesso administrativo à VM Zo e validação individual de Fabric/TOTVS/Sheets permanecem não confirmados.

### Regra de continuidade
- Para qualquer sessão sobre DRE Eventos, começar por `DRE_Eventos/AGENTS.md`, `DRE_Eventos/docs/AGENT_CONTEXT_DRE.md` e `DRE_Eventos/README.md`; não ingerir snapshots, logs, `.env`, credenciais ou dados brutos na memória.

---

## 2026-09-21 — Infraestrutura canônica do ecossistema

- ✅ Registrado como contexto permanente: ZoComputer é a VM principal.
- ✅ Registrado como contexto permanente: PostgreSQL na ZoComputer é o banco principal com componentes em produção.
- ✅ Registrado: ZoComputer, Vercel e Cloudflare são os destinos recorrentes de runtime/deploy.
- ✅ Registrada a recuperação automática desse contexto em toda sessão, sem comandos ou configuração extra do operador.

---

## 2026-09-21 — Auditoria e entrega: Foto no Relatório do Evento

- ✅ Auditado o trabalho do agente Grok: feature `ac01a4d` e smoke inicial publicado em `ac5d8d6`.
- ✅ Confirmado comportamento correto: botão admin-only no Relatório, modal compartilhado, `POST /api/fotos` inalterado, `/fotos` somente reprodução e payload v2 imutável.
- ✅ Validação local: 595 testes, Ruff, build frontend e Playwright UI 45/45 PASS.
- ✅ Validação de produção: smoke 43/43 PASS, `foto_payload_version=2`, PDF válido, autorização 403, totais vivos com delta zero e foto legada intacta.
- ✅ Documentação sincronizada e deploy final em `5f113aa`; health Zo HTTP 200 com `db=ok` após restart.

---

## 2026-09-08 — ADR-013: 1ª resposta imediata

### Resumo
Pergunta "temos ZoComputer?" disparou ritual de 7 arquivos + grep.
Operador: "isso não pode acontecer mais." Gravado como regra always-on.

### Ações
- ✅ `rules/first-response.md` + `.cursor/rules` + `~/.cursor/rules` + `~/.grok/rules`
- ✅ AGENTS.md, CONTEXT.md, `.cursorrules` — ritual virou sob demanda
- ✅ plan-and-execute aponta ADR-013

---

## 2026-09-08 — Manutenção da máquina: diagnóstico + execução segura

### Resumo
Diagnóstico read-only seguido de manutenção sem fechar apps nem reiniciar.
Tarefa Codex LogGuard corrigida, 2 apps atualizados, segurança do Windows
mapeada mas bloqueada por falta de elevação (0x80240044).

### Ações realizadas
- ✅ `Febracis-Codex-LogGuard-Audit`: executável apontava para
  `pwsh.exe` 7.6.4 inexistente → trocado pelo shim estável
  `%LOCALAPPDATA%\Microsoft\WindowsApps\pwsh.exe` (gatilhos/args intactos).
  Auditoria manual: `healthy=true, protected=true`, trigger íntegro.
- ✅ winget: GitHub CLI 2.93.0 → 2.100.0; VCRedist x86 14.51.36231 → 36247.
- ✅ USB "Generic Mass-Storage" sem mídia (VID_1908/PID_0226) = provável
  leitor de cartões vazio; erros disk-11 históricos atribuídos a ele, não
  aos SSDs (ambos Healthy/Online, sem WHEA em 7 dias).
- ⚠️ Windows Update (KB5124008 + KB5126052 + MSRT): instalação falhou com
  `0x80240044 WU_E_PER_MACHINE_UPDATE_ACCESS_DENIED` — sessão não elevada.
  Requer janela com PowerShell admin (sem reboot forçado por mim).
- ⏸️ Adiado de propósito: apps em uso (Node, Telegram, MiniMax, Open Design,
  Antigravity, Git, WSL, ZCode, QoderWork, Outlook), drivers/firmware
  (Realtek 2017, Lenovo 1.47, Senary) e qualquer reboot.

### Estado final
- RAM livre ~11,4 GB, CPU 4%, C: 178 GB livres, Bitdefender ativo,
  `RebootRequired=false`. Nada quebrado; nenhuma alteração fora do pedido.

---

## 2026-09-08 — Falhas de hooks no Grok (timeout em massa)

### Resumo
Cada tool no Grok disparava 3+ hooks (Orca PowerShell + Claude settings
importados). Timeout 10–15s. Isolado por runtime (ADR-012).

### Causa
- Grok importava `~/.claude/settings.json` e `~/.cursor/hooks.json`
- Orca via `powershell -EncodedCommand` (~startup 2–8s, timeout 10s)
- `readStdinJson()` esperava EOF; Grok nem sempre fecha stdin
- prettier inline com `$f`/`$j` → Grok: env var obrigatória ausente
- `hook-healthcheck --audit` em todo prompt do Cursor

### Ações
- ✅ `compat.claude.hooks = false` + `compat.cursor.hooks = false`
- ✅ Orca: `grok-hook.cmd` / `cursor-hook.cmd` / `claude-hook.cmd` direto
- ✅ `readStdinJson` timeout 1,5s fail-open
- ✅ `prettier-after-edit.js` (sem `$` no command)
- ✅ Cursor hooks: paths absolutos, sem audit por prompt
- ✅ ADR-012

### Gauntlet
- `test-hooks-failopen.js`: 3/3 PASS (profile-session 1725ms com stdin aberto)
- Orca cmd sem env: 40–48ms exit 0
- `hook-healthcheck --check`: 2 arquivos user-owned, 0 erros

### Pendência
Nova sessão Grok para carregar `config.toml`. Esta sessão ainda usa o
conjunto antigo de hooks.

---

## 2026-09-08 — ADR-011: máxima autonomia + skill em toda ação

### Resumo
Operador gravou: pediu → faz. Toda ação casa com o catálogo de skills;
match → usa, sem perguntar.

### Ações realizadas
- ✅ `rules/plan-and-execute.md` — passo skill no ciclo + seção ADR-011
- ✅ `plan-and-execute.mdc` (alwaysApply) atualizado
- ✅ ADR-011 em `DECISIONS.md`
- ✅ `AGENTS.md` + `AGENT_MEMORY.md` + `.cursorrules` + `CONTEXT.md`

---

## 2026-09-08 — ADR-010: agente resolve; operador não é o depurador

### Resumo
Operador gravou: não apontar erros/falhas/challenges. Agente diagnostica,
corrige e revalida. Instrução subótima → alternativa correta, sem `[s/n]`.

### Ações realizadas
- ✅ `rules/anti-sycophancy.md` reescrito (workspace + `~/.cursor/rules`)
- ✅ `rules/plan-and-execute.md` + `.mdc` — seção "Resolve, não transfere"
- ✅ ADR-010 em `DECISIONS.md`
- ✅ `AGENTS.md` + `AGENT_MEMORY.md` + `.cursorrules`

---

## 2026-09-08 — Protocolo permanente: auto-approve + plano + execução

### Resumo
Operador gravou regra permanente: sessão sempre em auto-approve; agente
entende o pedido, monta plano e executa sem esperar OK. Carve-outs de
irreversibilidade mantidos.

### Ações realizadas
- ✅ `rules/plan-and-execute.md` (canônico)
- ✅ `~/.cursor/rules/plan-and-execute.mdc` (alwaysApply)
- ✅ ADR-009 em `DECISIONS.md`
- ✅ `AGENTS.md` + `AGENT_MEMORY.md` + `.cursorrules`
- ✅ `workflow-patterns.md` item 2: deixa de "confirmar plano"

---

## 2026-09-01 — Construção de 5 habilidades de agente de alto impacto

### Resumo
Desenvolvimento completo de 5 novas skills customizadas no ecossistema (`skills/`), totalizando 110 custom skills. Foco em PO Salesforce Febracis, automação do Gauntlet Protocol (ADR-008), orquestração Composio, síntese OpenWiki → FIO-IA e integridade do DRE no Zo Computer.

### Ações realizadas
- ✅ Criada skill `salesforce-bdd-spec-architect` (SKILL.md, salesforce-patterns.md, gherkin-salesforce-templates.md, validate-salesforce-spec.py)
- ✅ Criada skill `gauntlet-self-healer` (SKILL.md, gauntlet-error-taxonomy.md, gauntlet-runner.py)
- ✅ Criada skill `composio-tool-orchestrator` (SKILL.md, composio-apps-reference.md, composio-bridge.py)
- ✅ Criada skill `openwiki-fio-synthesizer` (SKILL.md, humanizer-fio-rules.md, synthesize-openwiki-fio.py)
- ✅ Criada skill `dre-zo-integrity-guard` (SKILL.md, dre-financial-rules.md, dre-integrity-check.py)
- ✅ Atualizado `SKILLS_INDEX.md` (contagem de skills custom: 105 → 110 + novos agrupamentos)
- ✅ Executados testes sintéticos e de compilação em 100% dos scripts criados.

---

## 2026-07-24 — Claude Code → gateway Bailian Token Plan (modelos "nossos")

### Resumo
Claude Code (2.1.218) reconfigurado para usar por padrão o gateway Bailian
Token Plan (Singapura) via endpoint Anthropic-compatible nativo, sem proxy.
Antes apontava para a Anthropic real (plano Max, `claude-fable-5[1m]`).

### Ações realizadas
- ✅ `~/.claude/settings.json`: `"model"` → `qwen3.8-max-preview` + bloco `env`
  (`ANTHROPIC_BASE_URL=https://token-plan.ap-southeast-1.maas.aliyuncs.com/apps/anthropic`,
  `ANTHROPIC_MODEL`, `ANTHROPIC_SMALL_FAST_MODEL=qwen3.6-flash`,
  `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1`). Backup: `settings.json.bak-2026-07-24`.
- ✅ `ANTHROPIC_AUTH_TOKEN` persistido no ambiente do usuário via `setx`
  (cópia de `BAILIAN_TOKEN_PLAN_API_KEY`; valor não exibido). Exige novo terminal.
- ✅ Criado `scripts/claude-tp.ps1` (switcher; `-List` com status e `-Plan` que
  consulta ao vivo os modelos incluídos no Token Plan via `GET /v1/models`).

### Validação (round-trip `claude --model <id> -p ping`)
- ✅ Funcionam (6): qwen3.8-max-preview (padrão), qwen3.7-max, qwen3.7-plus,
  qwen3.6-flash (small-fast), deepseek-v4-pro, glm-5.2.
- ❌ deepseek-v4-flash e kimi-k2.7-code → 403 `AccessDenied.Unpurchased`.
  **Causa raiz:** NÃO estão incluídos no Token Plan. `GET /v1/models` lista
  exatos 8 modelos: deepseek-v4-pro, glm-5.2, qwen3.6-flash, qwen3.7-max,
  qwen3.7-plus, qwen3.8-max-preview, wan2.7-image, wan2.7-image-pro.
  **Ativação:** é contratação/assinatura — upgrade do Token Plan no console
  (My Subscriptions) ou chave pay-as-you-go separada; não via chave de API.
- ❌ qwen3.5-omni-plus → 400 "Model not exist" (não exposto no modo Anthropic).
- ℹ️ Aviso esperado: "claude.ai connectors disabled ... auth source takes
  precedence" — token do Token Plan sobrepõe o login Max (objetivo do "substituir padrão").

### Reversão
Restaurar `~/.claude/settings.json.bak-2026-07-24` + `setx ANTHROPIC_AUTH_TOKEN ""`
+ novo terminal.

---

## 2026-07-16 — Cursor updater: correção persistente do lock em resources

### Causa comprovada
- O Inno updater falhou às 08:29 com `Acesso negado (os error 5)` ao remover
  `%LOCALAPPDATA%\Programs\cursor\resources`.
- Dois `node.exe` embutidos do Cursor, ambos executando `mongodb-mcp-server`,
  permaneceram órfãos e seguraram a pasta.
- A versão 3.11.25 ficou assinada e completa em `_`, enquanto `Cursor.exe` e
  `cursor.cmd` desapareceram da raiz.
- A tarefa `Cursor-Update-Guard` era horária: rodou às 08:27 e perdeu a falha
  das 08:29. Os watchdogs versionados estavam desativados como no-op.

### Ações realizadas
- ✅ Encerrados apenas os dois helpers órfãos.
- ✅ Validada assinatura `Anysphere, Inc.` do staging 3.11.25 e concluído o swap.
- ✅ Substituído o no-op por watchdog persistente de 2 segundos, com mutex,
  filtro estreito de processo, proteção durante updater e auto-reparo assinado.
- ✅ Criado `scripts/install-cursor-update-watchdog.ps1` e instalada a única
  tarefa `Febracis-Cursor-UpdateWatchdog` via `wscript.exe` invisível.
- ✅ `Atualizar-Cursor-Seguro.ps1` agora valida/reinstala a tarefa preventiva.
- ✅ Política atualizada em `docs/CURSOR_UPDATE_POLICY.md` e ADR-007 criado.

### Validação
- ✅ Órfão sintético do helper foi encerrado automaticamente em menos de 6 s.
- ✅ Cursor 3.11.25 abriu e permaneceu vivo por 12 s com o watchdog ativo.
- ✅ `cursor --version`: `3.11.25`, commit
  `fc2563ec93d793fc275eef734405a4fdf8b47b20`, x64.
- ✅ Uma instalação User, nenhuma System, nenhum staging `_`.
- ✅ Auditor `-ValidateOnly` retornou sucesso.

---

## 2026-06-22 — Incidente de segurança: secrets expostos no push inicial

### Resumo
Primeira tentativa de publicação da raiz `Documents\Cursor` no GitHub
(`origin = deivithi/cursor-agent-os`) acionou 3 alertas do secret scanner:
Telegram Bot Token (`scripts/notify-config.json`, multi-repo leak),
Stripe API Key em skill, Tailscale API Key em skill.

### Ações tomadas
- ✅ Backup completo em `~/Documents/cursor-agent-os-backup-20260622-111737.bundle`
- ✅ `SECURITY.md` criado documentando incidente, política, pendências
- ✅ `.gitignore` atualizado para bloquear `scripts/notify-config.json` + variantes
- ✅ `git rm --cached scripts/notify-config.json` (arquivo preservado no disco)
- ✅ `git remote remove origin` (dangling ref limpa)
- ⏸️ **Deleção do repo `deivithi/cursor-agent-os` no GitHub pendente** —
  `gh auth refresh -s delete_repo` precisa de autorização no browser.
  **Você precisa rodar manualmente:**
  ```
  gh auth refresh -h github.com -s delete_repo
  gh repo delete deivithi/cursor-agent-os --yes
  ```
- ⏸️ Revogação de tokens reais (Telegram/Stripe/Tailscale) — pendente decisão do usuário

### Pendências (responsabilidade do usuário)
- [ ] **URGENTE:** rodar `gh auth refresh -s delete_repo` no terminal + deletar origin
- [ ] **URGENTE:** revogar Telegram Bot Token via @BotFather (CRÍTICO, leaked multi-repo)
- [ ] Confirmar se Stripe `STRIPE_SECRET_KEY` (vibe-deploy-guard:107) é real
- [ ] Confirmar se Tailscale `tskey-...eral` (cyber-deploying-tailscale:395) é real
- [ ] Após revogação: considerar `git filter-repo` para reescrever histórico do `11c846c`
      antes de republicar

### Próxima ação quando autorizado
Reescrever histórico + republicar com filtro (workflow documentado em SECURITY.md)

---

## 2026-06-22 — Publicação da raiz Documents\Cursor (dual-remote)

### Objetivo
- Publicar a raiz `Documents\Cursor` no GitHub seguindo o padrão `declaw` (ADR-006)

### Ações realizadas
- ✅ Criado repo público `cursor-agent-os` na conta `deivithi` (`origin`)
- ✅ ADR-006 registrado — estratégia dual-remote (origin ativo + cloud mirror)
- ✅ `PROJECTS_INDEX.md` e `AGENT_MEMORY.md` atualizados com URLs dos remotes
- ⏸️ Push inicial **bloqueado pelo GitHub secret scanner**: string `sk_liv...uvwx` em
  `skills/api-forge/references/security-patterns.md:778` (commit `11c846c`)
  — é exemplo de teste ofuscado (não chave real), aguardando allow manual
  via https://github.com/deivithi/cursor-agent-os/security/secret-scanning/unblock-secret/3FUkwg1myTlcheIOhfoy8UyjSsx
- ⏸️ Mirror `deivithilopes-ai/cursor-agent-os` ainda não criado (depende do push inicial)

### Pendências desta sessão
- [ ] Usuário aprovar secret via link acima → permite `git push -u origin main`
- [ ] Criar mirror `cursor-agent-os` em `deivithilopes-ai` → `git remote add cloud ...` → `git push -u cloud main`

### Próxima ação (quando autorizado)
1. `git push -u origin main` (push principal)
2. `gh auth switch --user deivithilopes-ai` ou criar token dedicado
3. `gh repo create cursor-agent-os --public --source=. --remote=cloud` (na conta secundária)
4. `git push -u cloud main`
5. Commit final: `chore(repo): publicar raiz no GitHub (dual-remote, ADR-006)`

---

## 2026-06-22 — Auditoria de docs pessoais + FIO-IA canônico em Hermes

### Objetivo
- Auditar e corrigir `Documents\Cursor` docs de memória (CONTEXT/AGENT_MEMORY/DECISIONS/SESSION_LOG/config + índices)
- Capturar o estado pós-migração FIO-IA (Task Scheduler → Hermes cron)

### Ações realizadas
- ✅ Auditoria completa: 5 fatos errados + 6 omissões + 6 melhorias de housekeeping
- ✅ FIO-IA corrigido em `AGENT_MEMORY.md` e `config.json`: agora registra 4×/dia via Hermes cron (job `bcbba63017bf` gerar + `c4b1e7326a7a` watchdog), entrega no chat, conta `@opanteranegra77`
- ✅ Pulso Finance marcado como projeto **conceitual** (só a skill `pulso-finance` v5.6.0 existe; repo `pulsofinance` não clonado)
- ✅ declaw corrigido: deploy canônico é **Zo Computer** (não Electron desktop); remote `cloud` (deivithilopes-ai) é canonical, `origin` (deivithi) é mirror
- ✅ Hermes adicionado ao stack (skills em `%LOCALAPPDATA%\hermes\skills\`, perfil `default` ativo)
- ✅ Criado **ADR-005** — FIO-IA canônico em Hermes (motivo: scripts `.py` não `.ps1`, entrega no chat com backup em `state/email-corpo.txt`)
- ✅ Atualizado `PROJECTS_INDEX.md` (webwright PRs #5/#10 merged, DRE watcher fix, Hermes skills listadas)
- ✅ Atualizado `SKILLS_INDEX.md` (adicionada ecossistema Hermes: 27 categorias, skill `humanizer` 2.8.0)
- ✅ Resolvida pendência do backup emergencial Cursor 3.7.42 (removido após 6 dias estável)
- ✅ Working tree: 24 itens mod/untracked → commit consolidado

### Pendências herdadas (atualizadas)
- [ ] Repo remoto para raiz do monorepo (sem mudança)
- [ ] `git pull` em webwright (sem mudança; já está sincronizado via PRs upstream)
- [ ] `git pull` em cybersecurity-skills (behind 137 — pendente)
- [ ] Limpeza opcional dos 11 worktree shells vazios — **marcar como known issue, não pendência**
- [ ] ADR-004 (tiers de skills) — opcional, sem mudança

### Arquivos alterados/criados nesta sessão
- `CONTEXT.md`, `AGENT_MEMORY.md`, `DECISIONS.md`, `SESSION_LOG.md`, `config.json`, `PROJECTS_INDEX.md`, `SKILLS_INDEX.md` (todos editados)
- `docs/CURSOR_UPDATE_POLICY.md` (referência, ADR-004)
- Commit: `chore(memory): auditar e atualizar docs pessoais (jun/2026)`

---

## 2026-06-16 — Política raiz para atualizações do Cursor

### Objetivo
- Resolver a causa estrutural das falhas recorrentes do updater do Cursor no Windows
- Padronizar uma única instalação System em `C:\Program Files\cursor`

### Ações realizadas
- ✅ Reparado estado parcial do Cursor 3.7.42 após erro `Acesso negado (os error 5)`
- ✅ Definida política canônica: Cursor System + `winget` elevado + validação pós-update
- ✅ Criado `docs/CURSOR_UPDATE_POLICY.md`
- ✅ Refeito `scripts/Atualizar-Cursor-Seguro.ps1` com autoelevação, logs, validação de instalação única e limpeza de PATH legado
- ✅ Ajustado tratamento do `winget` para aceitar "sem atualização disponível" como estado saudável e continuar a validação
- ✅ Removidas as tarefas antigas `Febracis-Cursor-UpdateGuard` e `Febracis-Cursor-UpdateWatchdog`
- ✅ Validado que não há instalação User ativa nem PATH legado para `AppData\Local\Programs\cursor`
- ✅ Registrado ADR-004 em `DECISIONS.md`

### Pendências
- [ ] Solicitar allowlist formal ao TI/Bitdefender se o erro voltar
- [ ] Remover backup emergencial `C:\Program Files\cursor\resources.backup-before-3.7.42-20260616-141351` após alguns dias de estabilidade

---

## 2026-06-16 — Mapeamento de skills e projetos (Cursor)

### Objetivo
- Inventariar todos os projetos, worktrees e ecossistemas de skills em `Documents\Cursor`
- Persistir contexto em índices e memória para trabalho contínuo no ecossistema

### Ações realizadas
- ✅ Inventário readonly: 4 repos aninhados, 14 worktrees (3 com código, 11 shells)
- ✅ Contagem de skills: 104 custom + 736 cyber + 22 scientific
- ✅ Criados `PROJECTS_INDEX.md` e `SKILLS_INDEX.md`
- ✅ Atualizados `AGENT_MEMORY.md`, `CONTEXT.md`, `config.json`
- ✅ Sync das 29 skills essenciais para `~/.cursor/skills/` (script migrate)

### Arquivos alterados/criados
- `PROJECTS_INDEX.md` (novo)
- `SKILLS_INDEX.md` (novo)
- `AGENT_MEMORY.md`, `CONTEXT.md`, `config.json`, `SESSION_LOG.md` (atualizados)

### Pendências herdadas
- [ ] Repo remoto para raiz do monorepo
- [ ] `git pull` em webwright (behind 4) e cybersecurity-skills (behind 137)
- [ ] Limpeza opcional dos 11 worktree shells vazios
- [ ] ADR-004 (tiers de skills) — opcional

---

## 2026-06-08 — Sessão Inaugural (DeepSeek GUI)

### Objetivo
- Conectar GitHub CLI ao ecossistema local
- Mapear e corrigir estrutura de worktrees quebrados
- Inicializar versionamento Git na raiz e worktrees
- Criar sistema de memória persistente

### Ações realizadas
- ✅ Verificado gh auth (conta deivithi ativa)
- ✅ Mapeada toda a estrutura de C:\Users\deivithi.lopes\Documents\Cursor
- ✅ Removidos 13 .git quebrados de worktrees (referenciavam C:/Users/PC/...)
- ✅ git init em todos os 13 worktrees + commit inicial
- ✅ git init na raiz + .gitignore + 3 commits
- ✅ Criado AGENT_MEMORY.md, SESSION_LOG.md, DECISIONS.md, CONTEXT.md
- ✅ Sistema de memória persistente estabelecido

### Arquivos alterados/criados
- C:\Users\deivithi.lopes\Documents\Cursor\.gitignore (novo)
- C:\Users\deivithi.lopes\Documents\Cursor\AGENT_MEMORY.md (novo)
- C:\Users\deivithi.lopes\Documents\Cursor\SESSION_LOG.md (novo)
- C:\Users\deivithi.lopes\Documents\Cursor\DECISIONS.md (novo)
- C:\Users\deivithi.lopes\Documents\Cursor\CONTEXT.md (novo)
- C:\Users\deivithi.lopes\Documents\Cursor\worktrees\*\ (13 repos inicializados)

### Pendências
- [ ] Criar repo remoto no GitHub para a raiz
- [ ] Conectar worktrees a remotes específicos
- [x] Configurar DRE_Eventos com remote correto
- [ ] Pipeline de deploy do ai-landing

---

## 2026-06-08 17:00 BRT — Conexão com Composio.dev CLI (WSL)

### Objetivo
- Instalar e conectar a CLI do Composio.dev para que o agente tenha acesso às ferramentas configuradas lá

### Ações realizadas
- ✅ Identificado e utilizado o WSL (Ubuntu) ativo do usuário para contornar a falta de suporte nativo da CLI no Windows
- ✅ Instalado o utilitário `unzip` no WSL Ubuntu
- ✅ Instalada a CLI v3 oficial do Composio no WSL (`~/.composio/composio`)
- ✅ Autenticado com sucesso via OAuth na conta `deivithi74@gmail.com`
- ✅ Validado o acesso à API do Composio listando metadados das ferramentas do GitHub

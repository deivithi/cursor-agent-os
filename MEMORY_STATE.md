# MEMORY_STATE — estado do ecossistema

> GERADO por `scripts/memory-doctor.ps1` em 2026-10-07 11:05 BRT. Não editar à mão.
> Fatos voláteis recomputados do disco e do Git. Onde este arquivo contradiz outro, este vence.

**Saúde da memória:** DESATUALIZADA
- pendência: 4094 caminho(s) não commitado(s) no repo raiz
- aceito (não conta para a saúde): OpenWiki sem ~/.openwiki/.env — bloqueio consciente do OAuth do X (não criar sem client_id)
- aceito (não conta para a saúde): plugin bundle em skills/ (não é skill, não precisa de SKILL.md): pptx-generator
**Fingerprint estrutural:** `1cce9ecedda1`

> `Saúde: ATUALIZADA` significa **zero pendência acionável de memória**. As linhas `aceito` são
> condições deliberadas. As **condições de ambiente** abaixo são problemas reais de operação:
> aparecem aqui para não ficarem invisíveis, mas não indicam memória desatualizada.

## Condições de ambiente (não afetam a Saúde da memória)

- tarefa agendada inativa: Febracis-Cursor-SyncDaily = Disabled, última execução 2026-06-16
- tarefa agendada inativa: Febracis-CursorAgent-Daily = Disabled, última execução 2026-06-16
- tarefa agendada inativa: Febracis-OpenDesign-Update = Disabled, última execução 2026-06-15
- 2 worktree(s) do repo raiz fora de worktrees/ com trabalho pendente — fora do inventário até agora

## Inventário (contado no disco)

| Item | Quantidade |
|---|---|
| Skills custom com SKILL.md (`skills/`, sem `_templates`) | 112 |
| Diretórios em `skills/` | 114 |
| Skills cybersecurity | 736 |
| Diretórios cyber | 739 |
| Skills scientific | 22 |
| Commands (`commands/*.md`) | 49 |
| Rules (`rules/*.md`) | 14 |
| Hooks (`hooks/*.js` + 2 `.ps1`) | 14 |
| Arquivos em `scripts/` | 116 |
| Skills em `~/.cursor/skills` (sync) | 63 |
| Skills oficiais em `~/.cursor/skills-cursor` | 26 |

Plugin bundles em `skills/` (têm `plugin.json` ou `.claude-plugin` e skills aninhadas — não são skills, não precisam de `SKILL.md`): `pptx-generator`

## Tarefas agendadas

| Tarefa | Estado | Última execução |
|---|---|---|
| `Febracis-Cursor-SyncDaily` (sync de skills) | Disabled **inativa** | 2026-06-16 |
| `Febracis-CursorAgent-Daily` | Disabled **inativa** | 2026-06-16 |
| `Febracis-OpenDesign-Update` | Disabled **inativa** | 2026-06-15 |
| `Febracis-Cursor-UpdateWatchdog` | Running | 2026-10-07 |
| `Febracis-Codex-LogGuard-Audit` | Ready | 2026-10-07 |

## Scheduler do Hermes

| Item | Valor |
|---|---|
| Último heartbeat do ticker | 2026-10-07 11:04 (0 dias) |
| Jobs habilitados | 3 |
| Jobs pausados | 1 |
| Veredito | operando |

| Job | Estado | Última execução |
|---|---|---|
| `FIO-IA gerar fio (Hermes)` | enabled | 10/07/2026 11:05:30 |
| `FIO-IA watchdog (Hermes)` | enabled | 10/07/2026 11:04:58 |
| `Briefing Diário Febracis Salesforce` | enabled | 10/07/2026 11:05:29 |
| `OpenWiki Personal Brain update` | pausado | nunca |

## Repositórios

| Repo | HEAD | Data | Pendências | origin/main...HEAD |
|---|---|---|---|---|
| `DRE_Eventos` | `ce751b2` | 2026-10-06 | 13 arquivo(s) | -37 / +2 |
| `declaw` | `d741815` | 2026-08-28 | limpo | -0 / +1 |
| `webwright` | `bc26750` | 2026-08-03 | limpo | -0 / +0 |
| `cybersecurity-skills` | `dfea41c2` | 2026-03-11 | 23 arquivo(s) | -223 / +33 |
| `scientific-skills` | n/a | n/a | não é repo git | n/a |
| `worktrees\dre-eventos-fix` | `d95783b` | 2026-06-08 | limpo | -0 / +0 |
| `.` (raiz) | `afadb49` | 2026-10-07 | 4094 caminho(s) | n/a |

## Worktrees (14)

Repositórios independentes com `.git` próprio — **diretório** em todos os 14, não arquivo (medido nesta execução, não afirmado de memória). Não são worktrees do repo raiz — ADR-003.

| Worktree | HEAD | Arquivos rastreados | Marcador `.git` | Código substantivo |
|---|---|---|---|---|
| `charming-lichterman` | `88ee4f5` | 1 | dir | não (shell) |
| `cranky-mahavira` | `770e3d2` | 3 | dir | não (shell) |
| `determined-wu-3787c2` | `855f700` | 17 | dir | sim |
| `dre-eventos-fix` | `d95783b` | 157 | dir | sim |
| `festive-grothendieck` | `99c206c` | 21 | dir | sim |
| `gifted-boyd` | `acb4b41` | 1 | dir | não (shell) |
| `heuristic-ritchie` | `0be103e` | 5 | dir | não (shell) |
| `inspiring-dijkstra` | `a4ca563` | 1 | dir | não (shell) |
| `modest-dirac` | `6c5b2ab` | 3 | dir | não (shell) |
| `naughty-wilson` | `7ee02b6` | 5 | dir | não (shell) |
| `peaceful-jepsen` | `e1af3c6` | 3 | dir | não (shell) |
| `quirky-easley` | `4e2edb5` | 1 | dir | não (shell) |
| `quirky-liskov` | `ba8e1da` | 3 | dir | não (shell) |
| `upbeat-mirzakhani` | `8a3dd00` | 1 | dir | não (shell) |

O corte em 10 arquivos rastreados para separar "shell" de "com código" é **heurística declarada**, não fato binário.
Acima do corte (3): `determined-wu-3787c2`, `dre-eventos-fix`, `festive-grothendieck`.
No corte ou abaixo (11): `charming-lichterman`, `cranky-mahavira`, `gifted-boyd`, `heuristic-ritchie`, `inspiring-dijkstra`, `modest-dirac`, `naughty-wilson`, `peaceful-jepsen`, `quirky-easley`, `quirky-liskov`, `upbeat-mirzakhani`.

## Worktrees registrados pelo repo raiz (fora de `worktrees/`)

Não aparecem no laço de `worktrees/` porque não vivem lá. Encontrados via `git worktree list`.

| Worktree | Branch | Pendências |
|---|---|---|
| `C:\Users\deivithi.lopes\.cline\worktrees\f3fe6\Cursor` | `refs/heads/cline/f3fe6` | limpo |
| `C:\Users\deivithi.lopes\Documents\Cursor\.claude\worktrees\angry-bassi-58c13c` | `refs/heads/claude/angry-bassi-58c13c` | 6119 arquivo(s) |

## Datas declaradas vs. hoje

| Arquivo | Data declarada | Dias de atraso |
|---|---|---|
| `AGENTS.md` | 2026-09-30 | 7 |
| `CONTEXT.md` | 2026-09-30 | 7 |
| `AGENT_MEMORY.md` | 2026-09-30 | 7 |
| `DECISIONS.md` | 2026-10-07 | 0 |
| `SESSION_LOG.md` | 2026-09-30 | 7 |
| `PROJECTS_INDEX.md` | não declarada | n/a |
| `SKILLS_INDEX.md` | 2026-09-30 | 7 |
| última sessão em `SESSION_LOG.md` | 2026-10-07 | 0 |

## SESSION_LOG — ordem cronológica

Decrescente e em ordem em 33 blocos. **Não** verifica sessão faltando
nem bloco duplicado: só compara datas consecutivas de headers no formato `## YYYY-MM-DD`.

## Commits de memória/estrutura sem registro de sessão

Nenhum.

## Referências críticas verificadas

Dependências do workspace: todas presentes.

Dependências externas ausentes:
- env do OpenWiki (~/.openwiki/.env)

Memórias nomeadas citadas: todas existem.

## Arquivos de memória e papéis

| Arquivo | Papel |
|---|---|
| [AGENTS.md](AGENTS.md) | Regras globais permanentes; entra sempre no prompt |
| [MEMORY_STATE.md](MEMORY_STATE.md) | Este arquivo — snapshot gerado; verdade volátil |
| [CONTEXT.md](CONTEXT.md) | Entry point do sistema de memória |
| [AGENT_MEMORY.md](AGENT_MEMORY.md) | Fatos permanentes: identidade, stack, projetos, infra |
| [DECISIONS.md](DECISIONS.md) | ADRs — decisões de arquitetura |
| [SESSION_LOG.md](SESSION_LOG.md) | Histórico de sessões, decrescente |
| [PROJECTS_INDEX.md](PROJECTS_INDEX.md) | Inventário de repos, worktrees e deploys |
| [SKILLS_INDEX.md](SKILLS_INDEX.md) | Inventário de skills e sync |
| [config.json](config.json) | Configuração ativa do ecossistema |

# MEMORY_STATE — estado do ecossistema

> GERADO por `scripts/memory-doctor.ps1` em 2026-09-30 09:08 BRT. Não editar à mão.
> Fatos voláteis recomputados do disco e do Git. Onde este arquivo contradiz outro, este vence.

**Saúde da memória:** DESATUALIZADA
- pendência: 7 caminho(s) não commitado(s) no repo raiz
- pendência: tarefa agendada inativa: Febracis-Cursor-SyncDaily = Disabled, última execução 2026-06-16
- pendência: tarefa agendada inativa: Febracis-CursorAgent-Daily = Disabled, última execução 2026-06-16
- pendência: tarefa agendada inativa: Febracis-OpenDesign-Update = Disabled, última execução 2026-06-15
- pendência: scheduler do Hermes parado desde 2026-07-08 16:38 — 3 job(s) enabled que não rodam
- aceito (não conta para a saúde): OpenWiki sem ~/.openwiki/.env — bloqueio consciente do OAuth do X (não criar sem client_id)
- aceito (não conta para a saúde): plugin bundle em skills/ (não é skill, não precisa de SKILL.md): pptx-generator
**Fingerprint estrutural:** `8d3facb97e25`

> `Saúde: ATUALIZADA` significa **zero pendência acionável**. As linhas marcadas `aceito` são
> condições deliberadas ou inofensivas — não indicam memória desatualizada.

## Inventário (contado no disco)

| Item | Quantidade |
|---|---|
| Skills custom com SKILL.md (`skills/`, sem `_templates`) | 110 |
| Diretórios em `skills/` | 112 |
| Skills cybersecurity | 736 |
| Diretórios cyber | 739 |
| Skills scientific | 22 |
| Commands (`commands/*.md`) | 47 |
| Rules (`rules/*.md`) | 26 |
| Hooks (`hooks/*.js` + 2 `.ps1`) | 14 |
| Arquivos em `scripts/` | 78 |
| Skills em `~/.cursor/skills` (sync) | 63 |
| Skills oficiais em `~/.cursor/skills-cursor` | 26 |

Plugin bundles em `skills/` (têm `plugin.json` ou `.claude-plugin` e skills aninhadas — não são skills, não precisam de `SKILL.md`): `pptx-generator`

## Tarefas agendadas

| Tarefa | Estado | Última execução |
|---|---|---|
| `Febracis-Cursor-SyncDaily` | Disabled **inativa** | 2026-06-16 |
| `Febracis-CursorAgent-Daily` | Disabled **inativa** | 2026-06-16 |
| `Febracis-OpenDesign-Update` | Disabled **inativa** | 2026-06-15 |
| `Febracis-Cursor-UpdateWatchdog` | Running | 2026-09-29 |
| `Febracis-Codex-LogGuard-Audit` | Ready | 2026-09-30 |

## Scheduler do Hermes

| Item | Valor |
|---|---|
| Último heartbeat do ticker | 2026-07-08 16:38 (84 dias) |
| Jobs habilitados | 3 |
| Veredito | **parado** — jobs enabled que não rodam |

## Repositórios

| Repo | HEAD | Data | Pendências | origin/main...HEAD |
|---|---|---|---|---|
| `DRE_Eventos` | `6380b65` | 2026-09-22 | 12 arquivo(s) | -0 / +0 |
| `declaw` | `d741815` | 2026-08-28 | limpo | -0 / +1 |
| `webwright` | `bc26750` | 2026-08-03 | limpo | -0 / +0 |
| `cybersecurity-skills` | `dfea41c2` | 2026-03-11 | 23 arquivo(s) | -223 / +33 |
| `scientific-skills` | n/a | n/a | não é repo git | n/a |
| `worktrees\dre-eventos-fix` | `d95783b` | 2026-06-08 | limpo | -0 / +0 |
| `.` (raiz) | `5a4ebf0` | 2026-09-30 | 7 caminho(s) | n/a |

## Worktrees (14)

Repositórios independentes com `.git` próprio — **diretório** em todos os 14, não arquivo (medido em 30/09/2026). Não são worktrees do repo raiz — ADR-003.

| Worktree | HEAD | Arquivos rastreados | Código substantivo |
|---|---|---|---|
| `charming-lichterman` | `88ee4f5` | 1 | não (shell) |
| `cranky-mahavira` | `770e3d2` | 3 | não (shell) |
| `determined-wu-3787c2` | `855f700` | 17 | sim |
| `dre-eventos-fix` | `d95783b` | 157 | sim |
| `festive-grothendieck` | `99c206c` | 21 | sim |
| `gifted-boyd` | `acb4b41` | 1 | não (shell) |
| `heuristic-ritchie` | `0be103e` | 5 | não (shell) |
| `inspiring-dijkstra` | `a4ca563` | 1 | não (shell) |
| `modest-dirac` | `6c5b2ab` | 3 | não (shell) |
| `naughty-wilson` | `7ee02b6` | 5 | não (shell) |
| `peaceful-jepsen` | `e1af3c6` | 3 | não (shell) |
| `quirky-easley` | `4e2edb5` | 1 | não (shell) |
| `quirky-liskov` | `ba8e1da` | 3 | não (shell) |
| `upbeat-mirzakhani` | `8a3dd00` | 1 | não (shell) |

O corte em 10 arquivos rastreados para separar "shell" de "com código" é **heurística declarada**, não fato binário. As 11 pastas de 1 a 5 arquivos são shells; `determined-wu-3787c2` (17), `festive-grothendieck` (21) e `dre-eventos-fix` (157) têm conteúdo.

## Datas declaradas vs. hoje

| Arquivo | Data declarada | Dias de atraso |
|---|---|---|
| `AGENTS.md` | 2026-09-30 | 0 |
| `CONTEXT.md` | 2026-09-30 | 0 |
| `AGENT_MEMORY.md` | 2026-09-30 | 0 |
| `DECISIONS.md` | 2026-09-30 | 0 |
| `SESSION_LOG.md` | 2026-09-30 | 0 |
| `PROJECTS_INDEX.md` | não declarada | n/a |
| `SKILLS_INDEX.md` | 2026-09-30 | 0 |
| última sessão em `SESSION_LOG.md` | 2026-09-30 | 0 |

## SESSION_LOG — ordem cronológica

Decrescente e em ordem em 24 blocos. **Não** verifica sessão faltando
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

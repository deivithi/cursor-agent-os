# DECISIONS.md — Registro de decisões de arquitetura (ADR)

> Iniciado em: 08/06/2026

## ADR-001: Raiz não rastreia repositórios aninhados

**Data:** 08/06/2026
**Decisão:** A raiz Documents\Cursor usa .gitignore para excluir
worktrees/, DRE_Eventos/, declaw/, webwright/, e cybersecurity-skills/.
Cada um tem seu próprio repositório Git independente.

**Motivo:**
- Cada projeto tem ciclo de vida, remotes e deploys diferentes
- Evitar gitlinks (submódulos) que adicionam complexidade desnecessária
- A raiz versiona apenas configuração compartilhada (skills, agents, rules, scripts)

**Alternativa considerada:** Git submodules — rejeitado por complexidade operacional.

---

## ADR-002: Sistema de memória em arquivos Markdown

**Data:** 08/06/2026
**Decisão:** Memória do agente persiste em 4 arquivos:
- AGENT_MEMORY.md — fatos permanentes (identidade, stack, projetos)
- SESSION_LOG.md — histórico cronológico de sessões
- DECISIONS.md — este arquivo, ADR
- CONTEXT.md — ponto único de entrada (auto-referencia os demais)

**Motivo:**
- Modelos de IA não têm memória persistente nativa
- Arquivos Markdown são portáteis, versionáveis e legíveis
- Estrutura modular permite evolução independente de cada aspecto

---

## ADR-003: Worktrees recuperados como repositórios independentes

**Data:** 08/06/2026
**Decisão:** Os 13 worktrees com .git quebrados (apontando para
C:/Users/PC/...) foram convertidos em repositórios Git independentes.

**Motivo:**
- O repositório pai original (VS CODE na máquina antiga) não está acessível
- Os dados locais são o único artefato remanescente
- Inicializar repos locais preserva o histórico de arquivos

**Risco:** Histórico de commits original foi perdido.
**Mitigação:** Commits locais preservam o estado atual dos arquivos.

---

## ADR-004: Cursor gerenciado como instalação System via winget

**Data:** 16/06/2026
**Decisão:** O Cursor no Windows será tratado como instalação única de máquina
em `C:\Program Files\cursor`, atualizado por `winget`/instalador oficial em
PowerShell elevado usando `scripts/Atualizar-Cursor-Seguro.ps1`.

**Motivo:**
- Logs recorrentes do updater desde 20/05/2026 mostram falhas de acesso negado
  durante troca de arquivos.
- Alternar entre instalação User (`AppData\Local\Programs\cursor`) e System
  (`Program Files\cursor`) cria ambiguidade de PATH, registro e atualização.
- O ambiente possui Bitdefender Endpoint ativo; qualquer bloqueio persistente
  deve ser resolvido por allowlist/política de segurança, não por alteração em
  arquivos internos do Cursor.

**Regras:**
- Não usar instalação User/AppData para o Cursor.
- Não editar `product.json` nem outros arquivos internos para controlar update.
- Não usar watchdog/guard como rotina de atualização.
- Usar a política documentada em `docs/CURSOR_UPDATE_POLICY.md`.

**Alternativa considerada:** manter scripts de reparo automático do staging —
rejeitada por ser remediação emergencial, não solução raiz.

---

## ADR-005: FIO-IA canônico via Hermes cron (não Task Scheduler)

**Data:** 19/06/2026 (migração) — registrada em docs: 22/06/2026
**Status:** Vigente

**Decisão:** A automação FIO-IA roda no Hermes, não mais no Task Scheduler do
Windows. Cron jobs ativos:

| Job | ID | Schedule (BRT) | Função |
|-----|----|----------------|--------|
| `FIO-IA gerar fio (Hermes)` | `bcbba63017bf` | 02:00, 08:00, 14:00, 20:00 | Pesquisa + redação + skill `humanizer` 2.8.0 + entrega no chat |
| `FIO-IA watchdog (Hermes)` | `c4b1e7326a7a` | 03:15, 09:15, 15:15, 21:15 | Alerta se histórico parado ou `PENDENTE` |

**Requisitos:**
1. Hermes desktop **aberto** (scheduler roda com o app)
2. Tópico ativo no chat para receber fios (deliver=origin)
3. Backup automático do corpo do fio em `state/email-corpo.txt`

**Motivo:**
- Hermes runner executa scripts não-`.sh`/`.bash` via Python — scripts `.ps1`
  causam `SyntaxError`. Watchdog foi convertido de `.ps1` para `.py` em 19/06/2026.
- Entrega nativa no chat (copy-paste) é o destino real do usuário; email-era
  foi abandonado.
- Watchdog com `no_agent=true` + `deliver=null` funciona silenciosamente quando
  tudo está saudável; só emite alerta quando há anomalia.
- Backup em `state/email-corpo.txt` cobre o caso de app fechado (cron falha
  entrega mas corpo persiste).

**Regras:**
- Scripts em `%LOCALAPPDATA%\hermes\scripts\` devem ser `.py` (nunca `.ps1`).
- `Task Scheduler` legados (`setup-task-scheduler.ps1`, `run.ps1`) ficam só
  como backup manual; podem ser desabilitados no Windows.
- `HERMES.md` em `OneDrive/.../fio-ia/` é o documento canônico do projeto.

**Alternativa considerada:** manter Task Scheduler — rejeitada por incompatibilidade
de runtime (.ps1 vs Python) e pelo melhor encaixe de entrega no chat.

---

## ADR-006: Raiz Cursor Agent OS publicada com dual-remote (origin + cloud)

**Data:** 22/06/2026
**Status:** Vigente

**Decisão:** A raiz `Documents\Cursor` é publicada como repo público
`cursor-agent-os` com dois remotes, seguindo o mesmo padrão do `declaw`:

| Remote | Conta | Função |
|--------|-------|--------|
| `origin` | `deivithi/cursor-agent-os` | **Conta ativa** — git operations do dia-a-dia (push/fetch via gh CLI) |
| `cloud` | `deivithilopes-ai/cursor-agent-os` | **Mirror** — espelho canônico, mesma URL relativa ao projeto |

**Motivo:**
- Padronizar com o ADR já estabelecido em `declaw` (mesmo padrão de 2 remotes).
- Conta `deivithi` é a ativa no `gh auth` → `git push` resolve sem troca de identidade.
- Conta `deivithilopes-ai` é a canônica em alguns projetos (declaw canonical) →
  espelhamento preserva discoverability.
- Repo público: config compartilhada (skills, agents, rules, scripts, memória)
  é documentada como portável, sem informação sensível.
- Conteúdo já foi auditado (auditoria 22/06/2026) e working tree está limpo.

**Regras:**
- Sempre `push` em `origin` primeiro; `cloud` é secundário.
- Para sincronizar `cloud`: `git push cloud main` (ou configurar push default
  para `both` em `.git/config`).
- Manter ambos os repos com a mesma branch `main`; nenhum force-push.
- Antes de qualquer push significativo, verificar com `gh api /repos/.../secret-scanning/alerts`
  se há novos alertas de secret (ver ADR-006-apêndice abaixo).

**Apêndice — primeiro push (22/06/2026):**
- GitHub secret scanner bloqueou push inicial: `sk_liv...uvwx` detectado em
  `skills/api-forge/references/security-patterns.md:778` (commit `11c846c`).
- Análise: string é **exemplo de teste ofuscado** (não chave Stripe real);
  push autorizado manualmente via
  https://github.com/deivithi/cursor-agent-os/security/secret-scanning/unblock-secret/3FUkwg1myTlcheIOhfoy8UyjSsx.
- Lição: **revisar skills de security/audit antes do primeiro push** —
  exemplos de regex podem disparar scanners mesmo quando bem-intencionados.

**Alternativa considerada:** repo privado — rejeitada pois o conteúdo já
está no `Documents/` local (já "público" no disco) e skills são reutilizáveis
por outros projetos. Mirror em conta secundária é mais simples que proteger.

---

## ADR-007: Cursor User com watchdog persistente contra helpers órfãos

**Data:** 16/07/2026
**Status:** Vigente — substitui a política operacional do ADR-004

**Decisão:** manter uma única instalação User em
`%LOCALAPPDATA%\Programs\cursor` e proteger o updater nativo com a tarefa
invisível persistente `Febracis-Cursor-UpdateWatchdog`, executada a cada 2
segundos enquanto o usuário está logado.

**Causa comprovada:** MCPs stdio iniciados pelo Cursor deixaram processos
`resources\app\resources\helpers\node.exe` vivos após o fechamento do app.
Esses processos mantiveram `resources` bloqueado; o Inno updater terminou com
`Acesso negado (os error 5)`, removeu o executável da raiz e deixou a versão
3.11.25 assinada no staging `_`. A tarefa horária existente havia rodado dois
minutos antes da falha e não cobria a janela crítica.

**Regras:**
- encerrar somente o helper `node.exe` embutido e somente quando o
  `Cursor.exe` principal não estiver aberto;
- não interferir enquanto um updater do Cursor estiver ativo;
- auto-reparar staging somente com assinatura Authenticode válida da
  `Anysphere, Inc.` e ausência do executável principal;
- usar uma única tarefa versionada, invisível e com mutex contra duplicidade;
- validar por comportamento com órfão sintético, não apenas por status da tarefa;
- `Atualizar-Cursor-Seguro.ps1 -RepairUserInstall` reinstala a proteção.

**Alternativas rejeitadas:** tarefa horária (perde a corrida do updater),
watchdog desativado/no-op (não previne recorrência), matar todo processo dentro
da instalação (risco de interromper uso normal) e retornar ao canal System
(reintroduz conflito de escopo/permissão já observado).

---

## ADR-008: Gauntlet como protocolo universal de confiança

**Data:** 23/07/2026
**Decisão:** Nenhum agente declara entrega completa sem executar o gauntlet
automatizado aplicável (testes, lint, type-check, coverage, reviewer-agent).
Protocolo formalizado em `rules/gauntlet-protocol.md`.

**Motivo:**
- O operador não lê código gerado por agentes — estratégia deliberada de
  produtividade (única forma de escalar sem virar gargalo de revisão manual)
- Confiança deve vir de verificação mecânica, não de inspeção humana
- Cada projeto pode estender o mínimo universal via `GAUNTLET.md` próprio
- Gap policy contexto-dependente: bloquear em prod, flag em protótipo

**Componentes:**
- `rules/gauntlet-protocol.md` — protocolo central (hierarquia, mínimos por stack, gap policy)
- `_templates/GAUNTLET.md` — template para projetos
- `QWEN.md` — enforcement para Qwen Code
- `.cursorrules` §Gauntlet — enforcement para Cursor
- `AGENTS.md` §Filosofia Operacional — enforcement para qualquer agente

**Alternativa considerada:** Revisão manual de código pelo operador —
rejeitada por não escalar e contradizer a filosofia de produtividade.

---

## ADR-009: Auto-approve + entender → plano → executar

**Data:** 08/09/2026
**Decisão:** Toda sessão opera em auto-approve. O agente deve entender o
pedido, montar um plano e executar o plano no mesmo turno. Não espera
confirmação para trabalho reversível no workspace.

**Motivo:**
- Pedido direto e permanente do operador (Deivithi Lopes)
- "Confirmar plano antes de implementar" virava gargalo humano — o mesmo
  que ADR-008 removeu da revisão de código
- Plano continua obrigatório; o que cai é a espera de OK

**Não cobre (carve-outs absolutos):**
- Operações destrutivas / irreversíveis (`sandbox-dangerous.md`)
- Cripto / LGPD / sanitização de BD (`human-architectural-gate.md`)
- `--dangerously-skip-permissions` fora de sandbox

**Componentes:**
- `rules/plan-and-execute.md` — protocolo
- `~/.cursor/rules/plan-and-execute.mdc` — alwaysApply no Cursor
- `AGENTS.md` §Protocolo operacional
- `AGENT_MEMORY.md` §Protocolo operacional
- `workflow-patterns.md` item 2 do gerenciamento de tarefas — atualizado

**Alternativa considerada:** Manter confirmação de plano em tarefas não
triviais — rejeitada pelo operador ("sempre auto-approve", "execute o plano").

---

## ADR-010: Agente resolve; operador não é o depurador

**Data:** 08/09/2026
**Decisão:** O agente não aponta erros, falhas ou challenges para o operador
trabalhar. Diagnostica, corrige e revalida sozinho. Instrução subótima →
executa a alternativa correta sem perguntar `[s/n]`.

**Motivo:**
- Pedido direto e permanente do operador: se ele tiver que ficar fazendo,
  o agente não faz sentido
- Challenge `[s/n]` de anti-sycophancy virava o mesmo gargalo humano que
  ADR-008 e ADR-009 já removeram
- Parceiro de verdade não bajula **e** não transfere o problema

**Não cobre (carve-outs absolutos):**
- Operações destrutivas / irreversíveis (`sandbox-dangerous.md`)
- Cripto / LGPD / sanitização de BD (`human-architectural-gate.md`)
- Apagar/skip/enfraquecer teste (`test-integrity.md`)

**Componentes:**
- `rules/anti-sycophancy.md` — challenge `[s/n]` substituído por resolver
- `rules/plan-and-execute.md` — seção "Resolve, não transfere"
- `AGENT_MEMORY.md` + `AGENTS.md`

**Alternativa considerada:** Manter challenge visível e esperar decisão —
rejeitada pelo operador.

---

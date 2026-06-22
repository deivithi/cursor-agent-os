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

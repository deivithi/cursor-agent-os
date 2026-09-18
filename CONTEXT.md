# CONTEXT.md — Ponto de Entrada do Agente

> Entry point da memória. **Não** bloquear o 1º turno. AGENTS.md já está no prompt.
> Ritual abaixo = sob demanda (ADR-013). Ver `rules/first-response.md`.

---

## 📋 Checklist de memória (sob demanda)

**Não** executar no 1º turno de pergunta de status/acesso/sim-não.
AGENTS.md, git_status e MCP connected já vêm no payload.

Gatilhos: user diz "carregar contexto"; falta fato que não está no prompt;
implementação toca ADR / pendência / stack / projeto.

1. AGENT_MEMORY.md — identidade, stack, projetos
2. PROJECTS_INDEX.md + SKILLS_INDEX.md — inventário
3. DECISIONS.md — ADRs
4. SESSION_LOG.md — pendências
5. config.json — config ativa
6. `GAUNTLET.md` do projeto ativo, se existir
7. git status / `gh auth` só se a tarefa for git/GitHub
8. Sinais no X → `~/.openwiki/wiki` (skill `openwiki-personal-brain`)

---

## 🚨 REGRA DE OURO

Pergunta simples → responde já. Zero "carregar contexto primeiro".
Memória completa só nos gatilhos acima.

---

## 📁 Estrutura de Memória

| Arquivo | Função | Quando atualizar |
|---|---|---|
| CONTEXT.md | Este arquivo — entry point | Quando adicionar novo arquivo de contexto |
| AGENT_MEMORY.md | Fatos permanentes | Quando houver mudança de stack, projeto ou identidade |
| DECISIONS.md | ADR — decisões de arquitetura | A cada decisão técnica importante |
| SESSION_LOG.md | Histórico de sessões | Ao final de CADA sessão |
| config.json | Configuração ativa | Quando projetos ou preferências mudarem |
| [PROJECTS_INDEX.md](PROJECTS_INDEX.md) | Inventário de repos, worktrees e deploys | Quando adicionar/mover/arquivar projeto |
| [SKILLS_INDEX.md](SKILLS_INDEX.md) | Inventário de skills e sync Cursor | Quando adicionar skill ou mudar sync |
| rules/gauntlet-protocol.md | Protocolo de verificação universal (ADR-008) | Quando mudar política de qualidade |
| rules/plan-and-execute.md | Auto-approve + autonomia + skill em toda ação (ADR-009/010/011) | Quando mudar o ciclo operacional |
| rules/first-response.md | 1ª resposta imediata; memória sob demanda (ADR-013) | Quando mudar política de latência |
| QWEN.md | Protocolo operacional Qwen Code | Quando mudar regras de sessão |

---

## 📁 Estrutura do Workspace

```
C:\Users\deivithi.lopes\Documents\Cursor\
├── AGENTS.md          ← regras globais v3.0 (auto-carregado por agentes)
├── CONTEXT.md         ← entry point do sistema de memória
├── AGENT_MEMORY.md    ← fatos permanentes
├── DECISIONS.md       ← decisões de arquitetura (ADR)
├── SESSION_LOG.md     ← histórico de sessões
├── config.json        ← configuração do ecossistema
├── .cursorrules       ← regras para Cursor IDE
├── .claude/           ← configuração Claude Code (agents/, commands/, skills/, settings.local.json)
├── worktrees/         ← 13 projetos (cada um repo Git independente)
├── DRE_Eventos/       ← App Flask/React (GitHub: deivithi/febracis-dre-eventos)
├── declaw/            ← DeClaw (GitHub: deivithi/declaw)
├── webwright/         ← WebWright
├── skills/            ← skills globais
├── rules/             ← regras globais
├── scripts/           ← scripts utilitários
└── agents/            ← templates de agentes
```

---

## 🧠 Ciclo de Memória

```
1º TURNO
  ↓
Payload já tem AGENTS.md + MCP + git_status → RESPONDER
  ↓
Só então, se o pedido precisar: memória / git / gh
  ↓
TRABALHAR NA SESSÃO
  ↓
FIM DA SESSÃO
  ↓
Atualizar SESSION_LOG.md
  ↓
AGENT_MEMORY.md se mudou stack/projeto
  ↓
ADR em DECISIONS.md se houve decisão
  ↓
git commit -m "session: resumo"
```

---

## ⚡ Comandos Rápidos

O usuário pode usar estes atalhos:
- "carregar contexto" → lê os arquivos de memória (único gatilho explícito do ritual)
- "salvar progresso" → atualiza SESSION_LOG.md + git commit
- "nova decisão: <título>" → cria nova entrada em DECISIONS.md

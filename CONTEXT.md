# CONTEXT.md — Ponto de Entrada do Agente

> Atualizado em: 30/09/2026
> Entry point da memória. **Não** bloquear o 1º turno. AGENTS.md já está no prompt.
> Ritual abaixo = sob demanda (ADR-013). Ver `rules/first-response.md`.
>
> **No DSH, o único vetor automático é `AGENTS.md`** — o global (`~/.dsh/AGENTS.md`, com o
> bloco de estado gerado) e o do projeto. Nenhum hook do workspace é montado. Contrato
> completo: `rules/session-bootstrap.md`.

---

## 📋 Checklist de memória (sob demanda)

**Não** executar no 1º turno de pergunta de status/acesso/sim-não.
AGENTS.md, git_status e MCP connected já vêm no payload.

Gatilhos: user diz "carregar contexto"; falta fato que não está no prompt;
implementação toca ADR / pendência / stack / projeto.

0. [MEMORY_STATE.md](MEMORY_STATE.md) — estado vivo gerado (contagens, HEADs, pendências). Ler primeiro
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
| MEMORY_STATE.md | **Gerado.** Estado vivo: contagens, HEADs, pendências | Nunca à mão — rodar o doctor |
| AGENT_MEMORY.md | Fatos permanentes | Quando houver mudança de stack, projeto ou identidade |
| DECISIONS.md | ADR — decisões de arquitetura | A cada decisão técnica importante |
| SESSION_LOG.md | Histórico de sessões (decrescente) | Ao final de CADA sessão, no topo |
| config.json | Configuração ativa | Quando projetos ou preferências mudarem |
| [PROJECTS_INDEX.md](PROJECTS_INDEX.md) | Inventário de repos, worktrees e deploys | Quando adicionar/mover/arquivar projeto |
| [SKILLS_INDEX.md](SKILLS_INDEX.md) | Inventário de skills e sync | Quando adicionar skill ou mudar sync |
| rules/session-bootstrap.md | Contrato de injeção automática e fechamento de sessão | Quando mudar o mecanismo de injeção |
| rules/memory-protocol.md | O que capturar e com que confiança | Quando mudar a política de memória |
| rules/gauntlet-protocol.md | Protocolo de verificação universal (ADR-008) | Quando mudar política de qualidade |
| rules/plan-and-execute.md | Auto-approve + autonomia + skill em toda ação (ADR-009/010/011) | Quando mudar o ciclo operacional |
| rules/first-response.md | 1ª resposta imediata; memória sob demanda (ADR-013) | Quando mudar política de latência |
| QWEN.md | Protocolo operacional Qwen Code | Quando mudar regras de sessão |

**Fora deste repositório:**

| Arquivo | Função |
|---|---|
| `~/.dsh/AGENTS.md` | Injetado pelo DSH em toda sessão: identidade + infraestrutura + bloco de estado gerado |
| `~/.claude/scripts/memory-doctor.ps1` | Gera `MEMORY_STATE.md` e o bloco de estado acima |
| `~/.claude/memory/` | Memória de usuário, compartilhada entre harnesses |

---

## 📁 Estrutura do Workspace

```
C:\Users\deivithi.lopes\Documents\Cursor\
├── AGENTS.md          ← regras globais v3.0.1 (auto-carregado por agentes)
├── MEMORY_STATE.md    ← estado vivo GERADO (não editar à mão)
├── CONTEXT.md         ← entry point do sistema de memória
├── AGENT_MEMORY.md    ← fatos permanentes
├── DECISIONS.md       ← decisões de arquitetura (ADR)
├── SESSION_LOG.md     ← histórico de sessões
├── config.json        ← configuração do ecossistema
├── .cursorrules       ← regras para Cursor IDE
├── .claude/           ← configuração Claude Code (agents/, commands/, skills/, settings.local.json)
├── worktrees/         ← 14 pastas, cada uma repo Git independente (ADR-003)
├── DRE_Eventos/       ← App Flask/React; mapa: DRE_Eventos/docs/AGENT_CONTEXT_DRE.md
├── declaw/            ← DeClaw (GitHub: deivithi/declaw)
├── webwright/         ← WebWright (microsoft/webwright)
├── cybersecurity-skills/  ← fork mukul975/Anthropic-Cybersecurity-Skills
├── skills/            ← skills globais
├── rules/             ← regras globais
├── scripts/           ← scripts utilitários
└── agents/            ← templates de agentes
```

Fora desta pasta, mas no ecossistema: `..\civictrust\` (repo Git, `deivithi/civictrust`),
`..\Corretor2.0\` (repo Git sem remote), `OneDrive\Documents\VS CODE\pulsofinance` e
`OneDrive\Documents\VS CODE\automacoes\fio-ia` (ambos não-git).

## Infraestrutura padrão

- **ZoComputer** é a VM principal do ecossistema.
- **PostgreSQL na ZoComputer** é o banco principal, com componentes em produção.
- **ZoComputer, Vercel e Cloudflare** são os destinos recorrentes de runtime/deploy.
- Esse contexto deve ser recuperado automaticamente antes de qualquer trabalho; credenciais permanecem nos conectores/cofres/ambientes locais e nunca entram na memória.

---

## 🧠 Ciclo de Memória

```
1º TURNO
  ↓
O DSH já injetou ~/.dsh/AGENTS.md (identidade + infra + bloco de estado gerado)
e o AGENTS.md do projeto → RESPONDER
  ↓
Bloco de estado diz DESATUALIZADA? Ler as pendências antes de agir
  ↓
Só então, se o pedido precisar: memória / git / gh
  ↓
TRABALHAR NA SESSÃO
  ↓
FIM DA SESSÃO
  ↓
SESSION_LOG.md no topo (ordem decrescente)
  ↓
AGENT_MEMORY.md se mudou stack/projeto
  ↓
ADR em DECISIONS.md se houve decisão
  ↓
Rodar memory-doctor.ps1 → MEMORY_STATE.md + bloco do AGENTS.md global
  ↓
Saúde = ATUALIZADA? senão, resolver a pendência
  ↓
git commit + push
```

---

## ⚡ Comandos Rápidos

O usuário pode usar estes atalhos:
- "carregar contexto" → lê os arquivos de memória (único gatilho explícito do ritual)
- "salvar progresso" → atualiza SESSION_LOG.md + git commit
- "nova decisão: <título>" → cria nova entrada em DECISIONS.md

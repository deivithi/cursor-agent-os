# CONTEXT.md — Ponto de Entrada do Agente

> ⚠️ **LEIA-ME PRIMEIRO**: Este arquivo deve ser lido pelo agente no início de TODA sessão.
> Ele referencia todos os arquivos de memória que compõem o contexto completo.

---

## 📋 Checklist de Inicialização do Agente

Quando iniciar uma sessão, execute SEMPRE:

1. ✅ **Ler este arquivo** (CONTEXT.md)
2. ✅ **Ler** AGENT_MEMORY.md — identidade, stack, projetos, estrutura
3. ✅ **Consultar** PROJECTS_INDEX.md e SKILLS_INDEX.md — inventário atualizado
4. ✅ **Ler** DECISIONS.md — decisões de arquitetura e seus porquês
5. ✅ **Ler** SESSION_LOG.md — últimas sessões e pendências
6. ✅ **Ler** config.json — configuração ativa do ecossistema
7. ✅ **Ler** rules/gauntlet-protocol.md — protocolo de verificação (ADR-008)
8. ✅ **Ler** rules/plan-and-execute.md — auto-approve + entender → plano → executar (ADR-009)
9. ✅ **Verificar** se o projeto ativo tem `GAUNTLET.md` na raiz
10. ✅ **Executar** git status na raiz e nos sub-repos ativos
11. ✅ **Executar** gh auth status para verificar conectividade GitHub
12. ✅ **Se a tarefa precisa de sinais salvos no X** → ler `~/.openwiki/wiki` (OpenWiki Personal Brain; ver skill `openwiki-personal-brain`)

---

## 🚨 REGRA DE OURO

**NUNCA comece uma sessão sem ler estes arquivos.**
Se o usuário pedir algo antes de você carregar o contexto, responda:
"Deixe-me carregar seu contexto primeiro..." e leia os arquivos acima.

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
| rules/plan-and-execute.md | Auto-approve + entender → plano → executar (ADR-009) | Quando mudar o ciclo operacional |
| QWEN.md | Protocolo operacional Qwen Code | Quando mudar regras de sessão |

---

## 🧠 Ciclo de Memória

`	ext
INÍCIO DA SESSÃO
  ↓
Ler CONTEXT.md (este arquivo)
  ↓
Ler AGENT_MEMORY.md + DECISIONS.md + SESSION_LOG.md
  ↓
Executar verificações (git status, gh auth)
  ↓
TRABALHAR NA SESSÃO
  ↓
FIM DA SESSÃO
  ↓
Atualizar SESSION_LOG.md com o que foi feito
  ↓
Atualizar AGENT_MEMORY.md se houve mudanças estruturais
  ↓
Criar ADR em DECISIONS.md se houve decisão arquitetural
  ↓
git commit -m ""session: resumo do que foi feito""
`

---

## ⚡ Comandos Rápidos

O usuário pode usar estes atalhos:
- "carregar contexto" → lê todos os arquivos de memória
- "salvar progresso" → atualiza SESSION_LOG.md + git commit
- "nova decisão: <título>" → cria nova entrada em DECISIONS.md

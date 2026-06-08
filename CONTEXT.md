# CONTEXT.md — Ponto de Entrada do Agente

> ⚠️ **LEIA-ME PRIMEIRO**: Este arquivo deve ser lido pelo agente no início de TODA sessão.
> Ele referencia todos os arquivos de memória que compõem o contexto completo.

---

## 📋 Checklist de Inicialização do Agente

Quando iniciar uma sessão, execute SEMPRE:

1. ✅ **Ler este arquivo** (CONTEXT.md)
2. ✅ **Ler** AGENT_MEMORY.md — identidade, stack, projetos, estrutura
3. ✅ **Ler** DECISIONS.md — decisões de arquitetura e seus porquês
4. ✅ **Ler** SESSION_LOG.md — últimas sessões e pendências
5. ✅ **Ler** config.json — configuração ativa do ecossistema
6. ✅ **Executar** git status na raiz e nos sub-repos ativos
7. ✅ **Executar** gh auth status para verificar conectividade GitHub

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

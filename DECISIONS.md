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

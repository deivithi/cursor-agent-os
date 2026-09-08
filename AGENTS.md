# AGENTS.md — Contexto Automático para AI Agents

Este arquivo é lido automaticamente por agentes de IA
(Cursor, Claude Code, Codex, DeepSeek GUI, etc.) ao iniciar
uma sessão neste diretório.

## Identidade do Projeto

- **Usuário:** Deivithi Lopes
- **Cargo:** Product Owner Salesforce
- **Organização:** Febracis
- **Fuso:** America/Sao_Paulo (BRT, GMT-3)
- **Idioma:** pt-BR

## Filosofia Operacional (ADR-008)

O operador **NÃO lê código gerado por agentes**. A confiança vem
exclusivamente do gauntlet automatizado (testes, lint, coverage,
mutation testing, reviewer-agent). Todo agente DEVE executar o
gauntlet aplicável antes de declarar qualquer entrega completa.

Protocolo completo: `rules/gauntlet-protocol.md`

## Protocolo operacional (ADR-009)

Sessão padrão = **auto-approve**. Ciclo travado:

1. Entender o que foi pedido
2. Montar um plano curto
3. Executar o plano no mesmo turno (não esperar "pode ir")

Rule: `rules/plan-and-execute.md`. Carve-outs de irreversibilidade permanecem
(gate humano em cripto/LGPD/sanitização BD, DROP, force-push, deploy prod).

**ADR-010:** o operador não é o depurador. Erro, falha ou instrução subótima →
o agente resolve, sem apontar challenge nem devolver a decisão. Relato = feito.

**ADR-011:** pediu → faz (máxima autonomia). Toda ação casa com skill do
catálogo (`SKILLS_INDEX.md`). Match → usa. Não pergunta.

---

## Regra de Inicialização

Antes de executar qualquer tarefa, leia:

1. CONTEXT.md       — Entry point com checklist completo
2. AGENT_MEMORY.md  — Memória permanente (stack, projetos, estrutura)
3. DECISIONS.md     — ADR (decisões de arquitetura)
4. SESSION_LOG.md   — Últimas sessões e pendências
5. config.json      — Configuração ativa do ecossistema
6. rules/gauntlet-protocol.md — Protocolo de verificação (gauntlet)
7. rules/plan-and-execute.md — Auto-approve + autonomia + skill em toda ação

## Comandos Rápidos

- "carregar contexto" → lê todos os arquivos de memória
- "salvar progresso" → atualiza SESSION_LOG.md + git commit
- "nova decisão: <título>" → cria entrada em DECISIONS.md

## Estrutura de Diretórios

`
C:\Users\deivithi.lopes\Documents\Cursor\
├── AGENTS.md          ← você está aqui (auto-carregado por agentes)
├── CONTEXT.md         ← entry point do sistema de memória
├── AGENT_MEMORY.md    ← fatos permanentes
├── DECISIONS.md       ← decisões de arquitetura
├── SESSION_LOG.md     ← histórico de sessões
├── config.json        ← configuração do ecossistema
├── .cursorrules       ← regras para Cursor IDE
├── .gitignore
├── .claude/           ← configuração Claude Code
│   ├── agents/
│   ├── commands/
│   ├── skills/
│   └── settings.local.json
├── worktrees/         ← 13 projetos (cada um repo Git independente)
├── DRE_Eventos/       ← App Flask/Python (GitHub: deivithi/febracis-dre-eventos)
├── declaw/            ← DeClaw (GitHub: deivithi/declaw)
├── webwright/         ← WebWright
├── skills/            ← skills globais
├── rules/             ← regras globais
├── scripts/           ← scripts utilitários
└── agents/            ← templates de agentes

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

## Regra de Inicialização

Antes de executar qualquer tarefa, leia:

1. CONTEXT.md       — Entry point com checklist completo
2. AGENT_MEMORY.md  — Memória permanente (stack, projetos, estrutura)
3. DECISIONS.md     — ADR (decisões de arquitetura)
4. SESSION_LOG.md   — Últimas sessões e pendências
5. config.json      — Configuração ativa do ecossistema

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

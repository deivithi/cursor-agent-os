# Política de performance e higiene de contexto

Objetivo: reduzir latência percebida e custo de tokens sem sacrificar qualidade — complementa o paralelismo já descrito em `/do`.

## Paralelismo

- Tarefas **independentes** (buscas em ficheiros distintos, MCPs sem dependência mútua): lançar em **paralelo** (subagentes ou tool calls em batch).
- Tarefas com dependência sequencial: não paralelizar; evita retrabalho.

## Context hygiene

- **Subagentes:** prompt fechado com objetivo, ficheiros permitidos, formato de saída e limite de linhas (ex.: “máx. 200 linhas de diff resumido”).
- **Não repatriar** para o chat principal: logs completos de build, dumps JSON gigantes, ou árvores de diretório inteiras — resumir e linkar ficheiro local se necessário.
- **Re-snapshot** browser só após ação que muda DOM; usar snapshot compacto quando a skill permitir.

## Model routing (humano + agente)

- **Planeamento e síntese final** (fusão MoA-lite, conclusões de research): preferir modelo **mais forte** disponível no Cursor, se o utilizador permitir.
- **Execução mecânica** (edits repetitivos, formatação): modelo rápido é suficiente.
- O agente deve **anunciar** quando recomenda trocar de modelo para a passagem de revisão (sem bloquear se o utilizador não trocar).

## Cache lógico

- Reutilizar outlines e decisões estáveis em `tasks/todo.md`, `AGENTS.md` e memórias de projeto em vez de re-derivar a cada mensagem.
- Para pesquisa web em tema **instável** (preços, leis, versões): sempre revalidar com fonte atual, mesmo que exista nota antiga na memória.

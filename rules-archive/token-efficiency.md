# 💰 Token Efficiency — Regras de Economia

> Fonte: análise do guia @meta_alchemist (36 dicas, 5 níveis) + auditoria do ecossistema local.
> Ativa sempre — sem filtro de arquivo.

---

## 🔴 Cache Awareness (Maior impacto)

O Claude Code usa prompt caching internamente. Estas ações **quebram o cache** e custam até 12.5x mais:

### O que quebra cache (EVITAR)
- **Imagens/screenshots** — cada imagem nova invalida o cache inteiro. Em loops iterativos (ajustar UI, debug visual), fazer 3-4 ajustes antes de tirar screenshot de validação
- **Alternar modo mid-session** — trocar `/fast` ↔ normal ↔ `/careful` invalida cache de mensagens. Escolher modo no início e manter
- **Editar CLAUDE.md durante sessão ativa** — CLAUDE.md é parte do prefixo cacheável. Editar e reiniciar sessão depois
- **Modificar tool definitions** — instalar/remover MCP mid-session força recache

### O que preserva cache (FAZER)
- Conteúdo estável primeiro, variável depois (em prompts de skills)
- Manter sistema estável durante a sessão (mesmo modelo, mesmo modo, mesmas tools)
- Screenshots só para validação final, não para cada micro-ajuste

### Matemática do cache
| Ação | Custo relativo |
|------|---------------|
| Cache hit (leitura) | **0.1x** (90% off) |
| Cache miss (escrita) | **1.25x** (25% a mais) |
| Sem cache | **1.0x** (preço cheio) |

> ⚠️ Um cache miss repetido é **12.5x mais caro** que um cache hit. Estabilidade = economia.

---

## 🟡 Model Routing para Subagentes

| Task do subagente | Model | Justificativa |
|-------------------|-------|--------------|
| Explorar codebase, buscar arquivos | `haiku` | Só leitura, $1/MTok vs $15 |
| Classificar, extrair, formatar | `haiku` | Pattern matching simples |
| Implementar feature, refactoring | `sonnet` | Bom raciocínio, custo médio |
| Code review, debugging | `sonnet` | Entende contexto, não precisa de Opus |
| Planejamento arquitetural, síntese | `opus` | Decisões de alto impacto justificam custo |

**Regra:** Subagente explorer = sempre `haiku`. Subagente worker = `sonnet` por padrão. Escalar para `opus` só quando a decisão tem impacto arquitetural.

---

## 🟡 Extended Thinking Budget

Thinking tokens são cobrados como **output** (preço mais caro: $25/MTok no Opus).

| Tipo de task | Thinking | Budget sugerido |
|-------------|----------|----------------|
| Classificação, formatação, extração | Mínimo | — |
| Feature implementation, debugging | Moderado | 8K-16K tokens |
| Arquitetura, planejamento, síntese multi-fonte | Full | Sem limite |

**Regra:** Se a resposta esperada é < 100 tokens, thinking não deve consumir > 4K tokens.

---

## 🟡 Effort Mode por Tipo de Task

| Cenário | Modo | Economia estimada |
|---------|------|-------------------|
| Explorar codebase, buscar informação | `/fast` | ~40% menos tokens de raciocínio |
| Batch de edições mecânicas | `/fast` | ~40% |
| Classificação, routing | `/fast` | ~40% |
| Feature nova, debugging complexo | Normal | Baseline |
| Perto de produção, dados sensíveis | `/careful` | +overhead (vale pela segurança) |

**Regra:** Começar em `/fast` e escalar se a task exigir. Não começar em modo pesado para task simples.

---

## 🟢 Deferred Tools (já implementado)

O Claude Code usa **deferred tools** — das 200+ MCP tools, a maioria só carrega o schema via `ToolSearch` sob demanda. Isso já reduz o peso das tool definitions no prompt.

**Ação do agente:** Usar `ToolSearch` para tools que não são do conjunto core (Read, Write, Edit, Grep, Glob, Bash, Agent). Não precisa desligar MCPs.

---

## 🟢 Context Hygiene

- **Subagentes absorvem verbose** — delegar tests, logs, file reads extensivos a subagentes. Só o resumo volta ao contexto principal
- **Subagente prompts fechados** — objetivo + arquivos permitidos + formato de output + limite de linhas (max 200 linhas de resumo)
- **Não repatriar** build logs, JSON dumps, ou directory trees completos ao chat principal
- **`/compact` proativo** — não esperar o sistema forçar. Usar após concluir cada fase de trabalho

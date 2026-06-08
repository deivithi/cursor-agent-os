# Reasoning Effort Control

## Modos Disponíveis

| Modo | Comando | Efeito |
|------|---------|--------|
| **Fast** | `/fast` | Mesmo modelo Opus 4.6, output mais rápido. Ideal para tarefas simples |
| **Normal** | Padrão | Raciocínio completo. Ideal para tarefas complexas |
| **Careful** | `/careful` | Bloqueia operações destrutivas, exige confirmação em edições críticas |
| **Freeze** | `/freeze` | Modo read-only total. Nenhuma escrita permitida |

## Quando Usar Cada Modo

| Cenário | Modo | Economia |
|---------|------|----------|
| Explorar codebase, buscar informação | `/fast` | ~40% menos raciocínio |
| Tarefas batch repetitivas | `/fast` | ~40% |
| Classificação, extração, formatação | `/fast` | ~40% |
| Implementação de features | Normal | Baseline |
| Revisão de código | Normal | Baseline |
| Trabalhar perto de produção | `/careful` | +overhead (segurança) |
| Investigação, debugging, auditoria | `/freeze` | Zero escrita |

> ⚠️ **Cache:** Não alternar modos mid-session — isso invalida prompt cache. Escolher no início.

## Model Routing — Task → Modelo

| Task | Modelo | Custo (input/output MTok) |
|------|--------|--------------------------|
| Explorar codebase, buscar arquivos | **Haiku 4.5** | $1 / $5 |
| Classificar, extrair, formatar dados | **Haiku 4.5** | $1 / $5 |
| Routing, triagem, summarização simples | **Haiku 4.5** | $1 / $5 |
| Feature implementation, refactoring | **Sonnet 4.6** | $3 / $15 |
| Code review, debugging | **Sonnet 4.6** | $3 / $15 |
| PR review, análise de diff | **Sonnet 4.6** | $3 / $15 |
| Planejamento arquitetural | **Opus 4.6** | $5 / $25 |
| Decisões complexas, trade-offs | **Opus 4.6** | $5 / $25 |
| Síntese multi-fonte, deep research | **Opus 4.6** | $5 / $25 |

**Economia:** Haiku é 5x mais barato que Opus em input, 5x em output. Usar Opus só quando o valor da decisão justifica.

## Controle de Subagentes

| Tipo de subagente | Modelo padrão | Quando escalar |
|-------------------|---------------|---------------|
| Explorer (busca, leitura) | `haiku` | Nunca — exploração não precisa de modelo pesado |
| Worker (implementação) | `sonnet` | → `opus` se decisão arquitetural |
| Reviewer (revisão) | `sonnet` | → `opus` se auditoria de segurança |
| Evaluator (avaliação) | `sonnet` | → `opus` se critérios complexos |
| Planner (planejamento) | `opus` | Já é o modelo padrão |

- Configurável via `model` parameter no Agent tool
- Regra: **começar leve, escalar se necessário**

## Extended Thinking Budget

| Tipo de task | Thinking budget | Justificativa |
|-------------|----------------|--------------|
| Classificação, formatação | Mínimo | Não precisa raciocinar |
| Feature, debugging | 8K-16K tokens | Bom equilíbrio |
| Arquitetura, planejamento | Sem limite | Decisões justificam custo |

> Thinking tokens = preço de OUTPUT ($25/MTok no Opus). Economizar aqui tem alto impacto.

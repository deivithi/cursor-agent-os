# QWEN.md — Protocolo Operacional para Qwen Code

## Filosofia Operacional (ADR-008)

O operador (Deivithi Lopes) **NÃO lê código gerado por agentes**.
A confiança na qualidade vem **exclusivamente** do gauntlet automatizado —
testes, lint, type-check, coverage, mutation testing, reviewer-agent.

**Done = passou o gauntlet. Sem gauntlet executado = não-done.**

---

## Regras obrigatórias

1. **Antes de declarar qualquer tarefa completa**, execute o gauntlet aplicável
   definido em `rules/gauntlet-protocol.md` (§2-3).

2. **Verifique se o projeto ativo tem `GAUNTLET.md`** na raiz. Se tiver,
   use-o como extensão do mínimo universal.

3. **Nunca declare "pronto", "feito", "resolvido"** sem incluir o report
   de gauntlet no formato definido em `rules/gauntlet-protocol.md` §7.

4. **Gap policy** (gauntlet-protocol §4):
   - Produção/deploy → BLOQUEAR até verificação mínima existir
   - Protótipo/experimento → entregar com `⚠️ GAUNTLET INCOMPLETO` + propor testes
   - Ambíguo → perguntar

5. **Testes são contrato** (`rules/test-integrity.md`):
   nunca deletar, skipar ou enfraquecer testes sem aceite explícito.

6. **Reviewer-agent** (`rules/workflow-patterns.md` §2):
   implementação não-trivial passa por agente revisor independente.

7. **Gates arquiteturais** (`rules/human-architectural-gate.md`):
   cripto, LGPD, sanitização de BD → BLOQUEIO até spec explícita.

---

## Inicialização

Ao iniciar sessão neste diretório, leia:

1. `CONTEXT.md` — entry point com checklist
2. `AGENT_MEMORY.md` — fatos permanentes
3. `DECISIONS.md` — ADRs
4. `SESSION_LOG.md` — últimas sessões
5. `config.json` — configuração ativa
6. `rules/gauntlet-protocol.md` — protocolo de verificação

---

## Estilo

- Idioma: pt-BR
- Nível técnico: senior/principal engineer (operador programa desde os anos 60)
- Sem explicações de fundamentos; foco em tradeoffs, arquitetura, edge cases
- Conciso. Sem bajulação. Sem filler.

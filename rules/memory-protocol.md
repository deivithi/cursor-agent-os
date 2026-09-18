# 💾 Regras de Memória

## 🔛 Sempre Ligada — prioridade máxima

> Declaração direta do operador (18/09/2026). Memória é uma das coisas mais importantes do ecossistema.
> **Default = ativo, sempre, sem comando.** Não perguntar "quer que eu salve?".

- **Capturar proativamente** ao detectar algo memorável (confidence ≥ 0.6): decisão, preferência, correção, confirmação, fato de projeto, referência externa, foresight. Salvar na hora, não no fim da sessão.
- **Recuperar proativamente** antes de agir sobre tema com histórico possível (projeto, stack, ADR, pessoa, decisão anterior). Ler a memória relevante antes, não depois.
- **Atualizar, não duplicar:** fato mudou → editar a entrada existente. Entrada obsoleta ou errada → corrigir ou deletar.
- **Duas camadas, sempre as duas:** `project` (memória do repo atual) + `user` (`~/.claude/memory`, compartilhada com Claude Code). Diretriz do operador → `user`. Fato do repo → `project`.
- **Sync com a flat-file do ecossistema:** `CONTEXT.md`, `AGENT_MEMORY.md`, `DECISIONS.md`, `SESSION_LOG.md` não podem divergir da memória do agente em informação estrutural.

Exceção: nada sensível (credenciais, segredos, PII de terceiro) entra em memória.

## ✅ Armazenar
- Preferências estáveis, definições, decisões, regras reutilizáveis, projetos, glossário
- 🔮 **Foresights** — informações com impacto futuro

## ❌ Não Armazenar
- Dados sensíveis, fatos transitórios, informações com confiança < 0.6

## 📋 Protocolo
- Fato memorável detectado → **salvar direto** (não propor, não esperar OK)
- Sem nada memorável → seguir sem cerimônia; não anunciar "nada a memorizar"

## 🎯 Confidence Scoring (EverMemOS)

| Confiança | Ação | Exemplo |
|-----------|------|---------|
| **0.9-1.0** | ✅ Salvar | Declaração direta do usuário |
| **0.7-0.8** | ✅ Salvar com contexto | Menção indireta |
| **0.6** | ⚠️ Salvar como `[Inferido]` | Dedução de padrões |
| **< 0.6** | ❌ Descartar | Menção casual, dado ambíguo |

- Declaração direta → confiança ≥ 0.9
- Inferida do contexto → 0.6-0.8, rotular
- Genérica → < 0.6, descartar
- Atualização: nova info deve ter confiança ≥ anterior

## 🔮 Foresight Memory (Memórias Preditivas)

Criar Foresight quando detectar: datas futuras, consequências futuras, dependências temporais, restrições com prazo.

```markdown
---
name: foresight_[tema]
description: [o que vai acontecer e quando]
type: project
---

🔮 **FORESIGHT**
**O quê:** [evento/mudança]
**Quando:** [data absoluta — NUNCA relativa]
**Válido até:** [data de expiração]
**Impacto:** [o que muda]
**Ação necessária:** [o que fazer antes]
```

**Regras:** Converter datas relativas para absolutas. Foresights expirados → remover. Início de sessão → checar foresights ativos.

## 🔄 Ciclo de Vida

```
Informação → Confidence ≥ 0.6? → Classificar tipo → Salvar
                                → Foresight? → Criar com data absoluta
Próxima sessão → Checar foresights → Expirado? → Remover
```

## 📤 Extração de Valor dos Chats

Focar em: ✅ Decisões | 📍 Estado atual | ⚠️ Inconsistências | ➡️ Próximos passos | 🔎 Pontos a verificar | 🔮 Foresights

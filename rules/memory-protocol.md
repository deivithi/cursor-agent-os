# 💾 Regras de Memória

## ✅ Armazenar
- Preferências estáveis, definições, decisões, regras reutilizáveis, projetos, glossário
- 🔮 **Foresights** — informações com impacto futuro

## ❌ Não Armazenar
- Dados sensíveis, fatos transitórios, informações com confiança < 0.6

## 📋 Protocolo
- Decisão relevante → propor registro curto
- Sem decisão → declarar: *"Nada a ser memorizado."*

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

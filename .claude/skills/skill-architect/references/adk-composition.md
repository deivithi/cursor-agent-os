# 🧩 ADK Composition — 5 Padrões para Compor Skills

> Resumo dos padrões do Google ADK. Detalhes completos: `agent-skill-patterns` skill.

---

## 5 Padrões

| # | Padrão | Quando usar | Estrutura-chave |
|---|--------|-------------|-----------------|
| 1 | **Tool Wrapper** | Empacotar conhecimento de uma lib/API | `references/conventions.md` + `gotchas.md` |
| 2 | **Generator** | Gerar outputs padronizados/consistentes | `assets/template.md` + `references/style-guide.md` |
| 3 | **Reviewer** | Avaliar/auditar contra critérios | `references/checklist.md` + Severity Scoring |
| 4 | **Inversion** | Entender ANTES de executar | Gates de completude (⛔ NÃO prossiga até...) |
| 5 | **Pipeline** | Workflow sequencial com aprovações | Diamond Gates (◆ pausa para aprovação humana) |

---

## Cheat Sheet — Qual Padrão Usar?

```
O que preciso fazer?
├── Empacotar conhecimento de uma ferramenta?     → 🔧 Tool Wrapper
├── Gerar output padronizado/consistente?          → 📝 Generator
├── Avaliar/auditar algo contra critérios?         → 🔍 Reviewer (+ Severity Scoring)
├── Entender contexto ANTES de executar?           → 🔄 Inversion (+ Gating Instructions)
├── Workflow sequencial com aprovações?            → ⛓️ Pipeline (+ Diamond Gates)
└── Combinação complexa?                           → 🧩 Compor padrões acima
```

---

## Receitas de Composição

| Cenário | Combinação |
|---------|-----------|
| Criar automação | Inversion → Generator → Reviewer → Pipeline (Diamond Gate antes do deploy) |
| Auditar segurança | Tool Wrapper (carregar checklist) → Reviewer (Severity Scoring) |
| Levantar requisitos | Inversion (gates) → Generator (template user story) |
| Migração de dados | Pipeline (Diamond Gates entre cada fase) |
| Criar nova skill | Inversion (entender objetivo) → Generator (template) → Reviewer (checklist qualidade) |

---

## 3 Melhorias Exclusivas

### Diamond Gates
Pontos de decisão onde o agente PARA e pede aprovação humana. Obrigatório para ações irreversíveis (deploy, envio de email, alteração financeira).

### Severity Scoring
Em vez de pass/fail binário, cada finding é classificado: CRITICAL (10) → HIGH (5) → MEDIUM (3) → LOW (1) → INFO (0). Score total determina aprovação.

### Gating Instructions
Gates explícitos: "NÃO prossiga até ter clareza sobre [X]". Força o agente a completar entendimento antes de executar.

---

> Para detalhes completos de cada padrão com exemplos, consulte a skill `agent-skill-patterns`.

# 🔴 Anti-Patterns na Criação de Skills

> Anti-patterns valem mais que boas práticas. Boas práticas são genéricas.
> Anti-patterns são ESPECÍFICOS e previnem erros reais.

---

## Formato

Cada anti-pattern segue: causa → consequência mensurável → regra corretiva → exemplo.

---

### ❌ AP-01: Skill Enciclopédia

| Aspecto | Detalhe |
|---------|---------|
| **O que acontece** | SKILL.md com 800+ linhas cobrindo TUDO sobre o domínio |
| **Consequência** | Consome 8.000+ tokens do contexto, agente perde foco, respostas diluídas |
| **Regra** | SKILL.md ≤ 500 linhas (ideal ≤ 250). Resto vai para `references/` |

```markdown
# ❌ ERRADO — 500 linhas de API docs no SKILL.md
## API Reference
### Endpoint GET /users
Response: { id: number, name: string, ... }
(mais 400 linhas)

# ✅ CORRETO — Referência externa
Para detalhes da API, consulte `references/api-reference.md`.
```

---

### ❌ AP-02: Description Genérica

| Aspecto | Detalhe |
|---------|---------|
| **O que acontece** | `description: "Ajuda com tarefas de desenvolvimento"` |
| **Consequência** | Skill ativa em contextos errados ou NUNCA ativa |
| **Regra** | Keywords de ativação explícitas entre aspas no description |

```yaml
# ❌ ERRADO
description: Ferramenta para gerenciar projetos Salesforce

# ✅ CORRETO
description: >-
  Templates e workflows para Product Owner de Salesforce.
  Use quando pedir "criar user story", "documentar requisito",
  "Salesforce", "auditoria de leads".
```

---

### ❌ AP-03: Instruções que o Agente Já Sabe

| Aspecto | Detalhe |
|---------|---------|
| **O que acontece** | "Use git add para adicionar arquivos ao staging" |
| **Consequência** | Tokens desperdiçados, degradação de performance |
| **Regra** | Só documentar o que é ESPECÍFICO do domínio/projeto |

| ❌ Não adicione | ✅ Adicione |
|----------------|------------|
| Como usar Git | Convenções de commit do PROJETO |
| Sintaxe de Python | Padrões arquiteturais ESPECÍFICOS |
| O que é uma API REST | Anti-patterns DOCUMENTADOS do domínio |
| Instruções genéricas de formatação | Workarounds para bugs CONHECIDOS |

---

### ❌ AP-04: Referências Profundamente Aninhadas

| Aspecto | Detalhe |
|---------|---------|
| **O que acontece** | `references/db/v1/schemas/users/fields.md` |
| **Consequência** | Agente pode não navegar até o arquivo, leitura incompleta |
| **Regra** | Máximo 1 nível de profundidade: `references/schema.md` |

---

### ❌ AP-05: Skill Frankenstein (Múltiplas Responsabilidades)

| Aspecto | Detalhe |
|---------|---------|
| **O que acontece** | Uma skill que faz deploy, testa, gera docs E monitora |
| **Consequência** | Trigger impreciso, agente confuso, execução parcial |
| **Regra** | 1 skill = 1 responsabilidade principal. Dividir em múltiplas skills |

**Teste:** Se o description precisa de mais de 3 verbos de ação → skill grande demais.

---

### ❌ AP-06: Só Boas Práticas, Zero Anti-Patterns

| Aspecto | Detalhe |
|---------|---------|
| **O que acontece** | Skill lista apenas "do this", sem "don't do this" |
| **Consequência** | Agente repete erros comuns do domínio |
| **Regra** | Para cada 3 boas práticas, documentar pelo menos 1 anti-pattern com consequência real |

---

### ❌ AP-07: Railroading Rígido

| Aspecto | Detalhe |
|---------|---------|
| **O que acontece** | Scripts passo-a-passo sem flexibilidade: "Step 1: Run X. Step 2: Run Y." |
| **Consequência** | Agente não consegue adaptar quando contexto muda, falha em edge cases |
| **Regra** | Dar informação + objetivo + flexibilidade. "Cherry-pick o commit preservando intenção" > "Step 1: git log, Step 2: git cherry-pick" |

---

### ❌ AP-08: Ignorar Setup e Primeira Execução

| Aspecto | Detalhe |
|---------|---------|
| **O que acontece** | Skill assume que config/credenciais existem sem verificar |
| **Consequência** | Falha silenciosa na primeira execução, usuário não sabe o que configurar |
| **Regra** | Padrão config.json: se não existe → perguntar ao usuário → salvar |

```bash
# Padrão de setup recomendado
CONFIG=$(cat skill-dir/config.json 2>/dev/null || echo "NOT_CONFIGURED")
if [ "$CONFIG" = "NOT_CONFIGURED" ]; then
  # Perguntar ao usuário os valores necessários
  # Salvar em config.json
fi
```

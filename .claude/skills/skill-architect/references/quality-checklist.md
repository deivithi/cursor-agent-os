# ✅ Quality Checklist & Scoring — Auditoria de Skills

---

## Checklist Completo

Antes de considerar qualquer skill como pronta:

### Estrutura (Obrigatório)

```
□ Nome da pasta = campo name no YAML?
□ Description ≤ 1024 chars com keywords de ativação entre aspas?
□ SKILL.md ≤ 500 linhas (ideal ≤ 250)?
□ Referências com máximo 1 nível de profundidade?
□ Campo version presente no metadata?
```

### Conteúdo (Obrigatório)

```
□ Cada instrução justifica seu custo em tokens? (não ensina o óbvio)
□ Workflow tem passos numerados e imperativos?
□ Anti-patterns documentados com causa + consequência + regra?
□ Seção Gotchas presente (mesmo que com 1 entrada)?
□ Related Skills declaradas?
```

### Qualidade (Recomendado)

```
□ Progressive disclosure aplicada? (hub enxuto, spokes em references/)
□ Handoff points definidos? (quando repassar para outra skill)
□ Scripts com exit codes e mensagens legíveis?
□ Funciona em Claude + Gemini + Cursor + Copilot? (portabilidade)
□ Testada contra 3 cenários (simples, padrão, edge)?
```

---

## Scoring A/B/C/D

Quando auditar uma skill existente:

### Passo 1: Diagnóstico Rápido

```
1. Contar linhas do SKILL.md (> 500 = problema)
2. Verificar description (tem keywords de ativação?)
3. Verificar nome (pasta = campo name?)
4. Buscar referências aninhadas (> 1 nível = problema)
5. Identificar instruções redundantes (agente já sabe?)
6. Verificar gotchas (existe? tem conteúdo?)
7. Verificar anti-patterns (documentados?)
```

### Passo 2: Classificação

| Nota | % Items OK | Significado | Ação |
|------|-----------|------------|------|
| **A** | 90-100% | Skill profissional | Manutenção mínima |
| **B** | 70-89% | Boa mas com gaps | Refinamento cirúrgico |
| **C** | 50-69% | Funcional mas ineficiente | Reestruturar PDA |
| **D** | < 50% | Precisa reescrever | Recriação do zero |

### Passo 3: Relatório

Gerar relatório com:
- Score atual (A/B/C/D com percentual)
- Itens do checklist que falharam (listados)
- Sugestões específicas de melhoria (acionáveis)
- Estimativa de redução de tokens (se aplicável)

---

## 7 Leis — Detalhamento Completo

### Lei 1: Progressive Disclosure Architecture (PDA)

O agente carrega informação em 3 níveis — cada nível custa mais tokens:

| Nível | O que carrega | Tokens (aprox.) | Quando |
|-------|--------------|-----------------|--------|
| **L1 — Metadata** | `name` + `description` do YAML | ~100 tokens | SEMPRE (global scan) |
| **L2 — Body** | Conteúdo completo do SKILL.md | ~3.000-5.000 tokens | Quando a skill é ATIVADA |
| **L3 — References** | Arquivos em `references/`, `scripts/` | Variável | Quando L2 referencia explicitamente |

**Regras:**
- Tudo para **decidir** relevância → Nível 1
- Tudo para **executar** a tarefa → Nível 2
- Detalhes que o agente **raramente** precisa → Nível 3

### Lei 2: O Description é um Trigger, Não uma Descrição

**Checklist do description perfeito:**
```
□ O QUE a skill faz (1 frase)
□ PARA QUE serve (1 frase)
□ QUANDO ativar — palavras-chave explícitas entre aspas
□ Máximo 1024 caracteres
□ Sem XML tags
□ Sem jargão técnico (use linguagem do usuário)
```

### Lei 3: Cada Token Deve Justificar Seu Custo

| ❌ Não adicione | ✅ Adicione |
|----------------|------------|
| Como usar Git | Convenções de commit do PROJETO |
| Sintaxe de Python | Padrões arquiteturais ESPECÍFICOS |
| O que é uma API REST | Anti-patterns DOCUMENTADOS do domínio |
| Instruções genéricas | Workarounds para bugs CONHECIDOS |

### Lei 4: Scripts para Determinismo, Instruções para Julgamento

| Situação | Use |
|----------|-----|
| Validação de schema/formato | `scripts/validate.py` |
| Setup de ambiente | `scripts/setup.sh` |
| Cálculos ou transformações | `scripts/transform.py` |
| Decisões arquiteturais | Instruções no SKILL.md |
| Escolha de abordagem | Instruções no SKILL.md |
| Tratamento de edge cases | Instruções no SKILL.md |

### Lei 5: Anti-Patterns Valem Mais que Boas Práticas

**Estrutura ideal:**
```markdown
### ❌ AP-XX: [Nome]
| Aspecto | Detalhe |
|---------|---------|
| **O que acontece** | Descrição técnica do erro |
| **Consequência real** | Impacto mensurável |
| **Regra** | Ação corretiva específica e testável |
```

**Proporção:** Para cada 3 boas práticas → pelo menos 1 anti-pattern.

### Lei 6: Evaluation-Driven Development (EDD)

```
1. Identificar gap → 2. Criar cenário de teste → 3. Medir baseline sem skill
→ 4. Escrever instrução MÍNIMA → 5. Medir com skill
→ Se melhorou: 6. Refinar e documentar
→ Se não melhorou: voltar ao 4
```

**Métricas:**

| Métrica | Alvo | Como Medir |
|---------|------|------------|
| Taxa de Ativação | 90%+ | Skill ativa quando deveria? |
| Precisão de Ativação | 95%+ | Skill NÃO ativa quando não deveria? |
| Taxa de Sucesso | 90%+ | Tarefa completada sem erro? |
| Eficiência de Tokens | Mínimo viável | Quantos tokens L2+L3 usados? |

### Lei 7: Portabilidade é Não-Negociável

Skills devem funcionar em todos os agentes que suportam SKILL.md:
- Claude Code, Google Antigravity, Gemini CLI, Cursor, GitHub Copilot, Codex CLI

**Regras:**
- Apenas Markdown padrão no SKILL.md
- Scripts em Python ou Shell (universais)
- Sem dependências de features exclusivas de um agente
- Caminhos relativos internos, nunca absolutos

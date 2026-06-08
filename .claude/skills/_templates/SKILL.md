<!-- TEMPLATE — copie este arquivo para .claude/skills/<nome>/SKILL.md -->
<!--
Frontmatter obrigatório (YAML entre ---):

```yaml
---
name: skill-name
description: >
  Uma linha descrevendo o que a skill faz e quando deve ser ativada.
  Inclua keywords de ativação para routing correto.
allowed-tools: Bash, Read, Glob, Grep, Edit, Write, Agent
metadata:
  author: deivithi
  version: "1.0"
---
```

Campos:
- name (obrigatório): identificador único kebab-case
- description (obrigatório): ativa routing — keywords importam
- allowed-tools (recomendado): least-privilege — só tools que a skill precisa
- metadata.author (recomendado): quem criou
- metadata.version (recomendado): rastreabilidade de evolução
-->

# Skill Name — Título Descritivo

Parágrafo curto explicando o propósito e valor da skill.

## Quando Usar

- Caso de uso 1
- Caso de uso 2
- Caso de uso 3

## Quando NÃO Usar (→ Handoff)

- Caso X → usar `outra-skill` em vez desta

## Workflow

1. **Passo 1:** Descrição
2. **Passo 2:** Descrição
3. **Passo 3:** Descrição

## Progressive Disclosure

| Complexidade | Comportamento |
|-------------|---------------|
| **Simples** | Ação mínima |
| **Médio** | Ação padrão |
| **Complexo** | Ação completa + sugerir decomposição |

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Situação A | `skill-alvo-1` | Razão do handoff |
| Situação B | `skill-alvo-2` | Razão do handoff |

## Gotchas

⚠️ Consulte `gotchas.md` para problemas conhecidos. Principais:

1. **Problema 1** → solução
2. **Problema 2** → solução

## Referências

- Fonte ou link relevante

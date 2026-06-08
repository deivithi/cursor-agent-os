---
name: skill-architect
description: >-
  Arquiteto definitivo de skills para agentes IA. Cria, audita e evolui skills
  profissionais com progressive disclosure, auto-testing e 4 métodos de criação.
  Use quando o usuário pedir "criar skill", "nova skill", "melhorar skill",
  "skill profissional", "SKILL.md", "auditar skill", "chat-to-skill",
  "voice-to-skill", "knowledge-to-skill", "skill from transcript",
  "skill from course", "extrair skill", ou qualquer tarefa de criação/otimização
  de skills para agentes IA.
metadata:
  author: Deivithi
  version: 2.0.0
  category: meta-skills
  tags: [skill-creation, prompt-engineering, agent-skills, meta, architecture]
---

# 🏗️ Skill Architect — O Arquiteto Definitivo de Skills

> Especialista sênior em criação de skills de alta performance para agentes IA.
> Domina o padrão SKILL.md, progressive disclosure, context engineering,
> evaluation-driven development e 4 métodos de criação.

## 📁 File Structure

- `SKILL.md` — Você está aqui. Hub de orquestração.
- `references/thariq-playbook.md` — 9 tipos + 9 dicas Anthropic (Thariq, 03/2026)
- `references/anti-patterns.md` — 8 anti-patterns com causa → consequência → regra
- `references/quality-checklist.md` — Checklist completo + scoring A/B/C/D
- `references/adk-composition.md` — 5 padrões ADK para composição de skills
- `templates/skill-template.md` — Template profissional pronto para usar
- `templates/skill-from-knowledge.md` — Template para Knowledge-to-Skill (Método 4)
- `gotchas.md` — Problemas conhecidos e workarounds

## 🔗 Related Skills

- `agent-skill-patterns` — 5 padrões ADK + 3 melhorias para estruturar skills
- `scaffolding` — Gerar boilerplate de código seguindo padrões
- `evolve` — Promotion ladder: correction → learned-rule → path-scoped → core
- `skill-discovery` — Buscar skills existentes antes de criar do zero
- `evals` — Avaliar qualidade de outputs de skills

---

## 🧠 7 Leis da Criação de Skills

```
1. Progressive Disclosure    — 3 níveis: L1 metadata, L2 body, L3 references
2. Description = Trigger     — Keywords explícitas entre aspas, não descrição genérica
3. Token ROI                 — Cada token deve justificar seu custo
4. Scripts = Determinismo    — Código para cálculos, instruções para julgamento
5. Anti-Patterns > Best Practices — Específicos e previnem erros reais
6. Evaluation-Driven Dev     — Testar ANTES de documentar
7. Portabilidade Absoluta    — Funcionar em Claude, Gemini, Cursor, Copilot
```

> Detalhes completos de cada Lei → `references/quality-checklist.md`

---

## 🎯 4 Métodos de Criação

### Método 1: Prompt Direto

O mais rápido. O usuário descreve o que a skill deve fazer.

```
1. INVERSION — Perguntar: Qual o objetivo? Quem usa? Que tipo de skill? (→ references/thariq-playbook.md: 9 tipos)
2. DESIGN — Definir: nome, description (trigger), workflow principal, anti-patterns conhecidos
3. SCAFFOLD — Gerar estrutura usando templates/skill-template.md
4. TEST — Criar 3 cenários, executar skill, avaliar output (→ Seção Auto-Test)
5. REFINE — Ajustar com base nos resultados dos testes
6. DELIVER — Salvar skill na pasta destino
```

### Método 2: Chat-to-Skill (Memory Hack)

Extrair skill de uma conversa existente. Poderoso para quem já tem chats ricos.

```
1. ANALYZE — Ler o histórico completo da conversa (ou trecho fornecido)
2. EXTRACT — Identificar:
   - Padrões repetidos (o que o usuário pediu várias vezes)
   - Preferências expressas ("gosto de X", "não faça Y")
   - Feedback dado (o que foi aprovado vs. rejeitado)
   - Formato de output preferido
   - Workflow implícito (sequência de passos que se repetiu)
3. SYNTHESIZE — Condensar em:
   - Workflow principal (passos numerados)
   - Preferências como regras (DOs e DON'Ts)
   - Formato de output como template
   - Anti-patterns do próprio histórico (erros que foram corrigidos)
4. SCAFFOLD — Gerar SKILL.md usando templates/skill-template.md
5. VALIDATE — Apresentar ao usuário: "Extraí esses padrões. Correto?"
6. TEST + DELIVER
```

**Prompt de ativação típico:**
> "Analise nossa conversa e crie uma skill baseada nos padrões que você identificar."

### Método 3: Voice-to-Skill

O usuário fala seu workflow e a skill é extraída da transcrição.

```
1. CAPTURE — Receber transcrição (via Whisper, /voice, ou colada manualmente)
2. CLEAN — Remover hesitações, repetições, organizar em tópicos
3. EXTRACT — Identificar:
   - Objetivo principal declarado
   - Passos do workflow mencionados
   - Preferências e restrições
   - Exemplos dados verbalmente
   - Critérios de qualidade mencionados
4. STRUCTURE — Transformar em workflow numerado + regras + anti-patterns
5. SCAFFOLD → TEST → DELIVER (mesmo pipeline dos outros métodos)
```

**Dica:** Pedir ao usuário para falar por 2-3 minutos cobrindo: O QUE faz, COMO faz, O QUE evitar, COMO sabe que ficou bom.

### Método 4: Knowledge-to-Skill

Criar skill a partir de conhecimento externo (cursos, transcrições, artigos, podcasts).

```
1. INGEST — Receber documento(s): transcrição, PDF, artigo, URL
   - Se URL → usar WebFetch ou markitdown para extrair conteúdo
   - Se arquivo → ler diretamente
2. DISTILL — Extrair núcleo de conhecimento:
   - Princípios-chave (máx 7)
   - Frameworks/metodologias descritos
   - Exemplos concretos
   - Anti-patterns mencionados
   - Checklist ou critérios de avaliação
3. CONTEXTUALIZE — Adaptar ao contexto do usuário:
   - Que parte desse conhecimento é acionável como skill?
   - Qual o trigger natural? ("quando o usuário pedir X")
   - Como o agente deve aplicar esse conhecimento?
4. SCAFFOLD — Usar templates/skill-from-knowledge.md
5. TEST → REFINE → DELIVER
```

**Prompt de ativação típico:**
> "Com base nessa transcrição/curso/artigo, crie uma skill para [objetivo]."

---

## 🧪 Auto-Test Protocol

**TODA skill criada deve ser testada antes da entrega.**

```
APÓS gerar o SKILL.md:

1. Criar 3 cenários de teste:
   - Cenário SIMPLES — caso de uso mais básico
   - Cenário PADRÃO — caso de uso principal/esperado
   - Cenário EDGE — caso limite ou complexo

2. Para cada cenário, avaliar mentalmente:
   - A skill ativaria corretamente? (trigger match)
   - O workflow produziria output correto?
   - Os anti-patterns estão cobrindo armadilhas reais?

3. Scoring:
   | Cenário | Resultado | Score |
   |---------|-----------|-------|
   | Simples | ✅ Pass / ❌ Fail | 0 ou 1 |
   | Padrão  | ✅ Pass / ❌ Fail | 0 ou 2 |
   | Edge    | ✅ Pass / ❌ Fail | 0 ou 1 |

   - Score 4/4: ✅ Skill pronta
   - Score 3/4: ⚠️ Refinar e re-testar
   - Score < 3: ❌ Reescrever

4. Se Score < 4: iterar (máx 3 tentativas, depois pedir feedback humano)
```

---

## 🔄 Feedback Loop Protocol

Após o usuário USAR a skill e dar feedback:

```
1. CAPTURE — Registrar: o que funcionou, o que falhou, o que faltou
2. CLASSIFY — O feedback é sobre:
   - Trigger? → Ajustar description
   - Workflow? → Ajustar passos
   - Output? → Ajustar formato/template
   - Anti-pattern novo? → Adicionar ao gotchas
3. UPDATE — Editar o SKILL.md cirurgicamente (menor diff possível)
4. BUMP — Incrementar version no frontmatter
5. LOG — Se padrão de feedback recorrente → propor para evolve (graduation)
```

**Regra de ouro:** Cada uso da skill é uma oportunidade de melhoria. Perguntar ao usuário: *"Quer que eu atualize a skill com base nesse feedback?"*

---

## 📐 Anatomia Rápida

```
skill-name/                    # kebab-case = campo name
├── SKILL.md                   # Obrigatório — máx 500 linhas (ideal ≤ 250)
├── references/                # L3 — carrega sob demanda
├── templates/                 # Assets reutilizáveis
├── scripts/                   # Determinismo (validate, setup)
├── examples/                  # Exemplos concretos
└── gotchas.md                 # Anti-patterns e workarounds
```

> Detalhes completos → `references/quality-checklist.md`
> 9 tipos de skills → `references/thariq-playbook.md`
> Anti-patterns → `references/anti-patterns.md`
> Padrões de composição → `references/adk-composition.md`

---

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Skill precisa de padrão ADK | `agent-skill-patterns` | Tool Wrapper, Generator, Reviewer, Inversion, Pipeline |
| Skill pronta, avaliar evolução | `evolve` | Promotion ladder (correction → rule → core) |
| Skill precisa de avaliação formal | `evals` | Three Gulfs + Hamel methodology |
| Buscar skill existente antes de criar | `skill-discovery` | OpenSpace local + cloud |
| Skill precisa de boilerplate de código | `scaffolding` | Templates de API, migration, componente |
| Skill precisa de conhecimento externo | `web-research` ou `deep-research` | Pesquisa profunda antes de criar |

---

## Gotchas

⚠️ Consulte `gotchas.md` para lista completa. Principais:

1. **Description vaga = skill morta** → Incluir keywords entre aspas, SEMPRE
2. **SKILL.md > 500 linhas** → Extrair para references/ (progressive disclosure)
3. **Instruções que o agente já sabe** → Token waste, degradação de performance
4. **Skill Frankenstein** → 1 skill = 1 responsabilidade. Dividir se necessário
5. **Testar na cabeça ≠ testar de verdade** → Executar 3 cenários concretos

---
name: decision-council
description: >
  Análise de decisões via múltiplas perspectivas (LLM Council inline).
  Ativado por "stress test", "pressure test", "council", "analise essa decisão".
  Personas vivenciais por dimensão (Persona Effect — Stanford, 2-3x diversidade).
  Zero subagentes, inline only, custo controlado (3-4x baseline).
domain: decision-making
subdomain: multi-perspective-analysis
version: 1.0.0
author: deivithi
tags:
  - council
  - stress-test
  - pressure-test
  - decision-analysis
  - persona-effect
  - multi-perspective
references:
  - "Karpathy LLM Council concept"
  - "arxiv:2404.13076 (self-preference bias)"
  - "arxiv:2410.21819 (Persona Effect — Stanford)"
  - "@alex_prompter article, @itsolelehmann original"
---

# 🏛️ Decision Council — Análise Multi-Perspectiva de Decisões

> **"Personas específicas com contexto vivencial aumentam diversidade de output em 2-3x vs roles genéricos."**
> — Stanford Research (arxiv:2410.21819)

## 📁 File Structure
- `SKILL.md` — Você está aqui. Protocolo completo.
- `gotchas.md` — Limitações e edge cases conhecidos.

## 🔗 Related Skills
- `spec-planner` — Após decisão tomada → planejar implementação
- `spec-review` — Se decisão envolve código existente → revisar antes
- `code-review` — Review pós-implementação (complementar, não sobrepõe)

---

## 🧠 Insight Central

> **Decision Council ≠ Code Review ≠ Spec Review.**
> - `code-review` / `spec-review` = análise **pós-implementação** de código
> - `decision-council` = deliberação **pré-decisão** sobre escolhas estratégicas/arquiteturais
>
> O Council responde: **"Qual caminho seguir e por quê?"**
> O Review responde: **"O código está correto?"**

---

## 1. Ativação

### Trigger Phrases
- `"stress test this"` / `"stress test:"` / `"stress test isso"`
- `"pressure test"` / `"pressure test:"`
- `"council"` / `"council:"`
- `"analise essa decisão"` / `"delibere sobre"`

### Quando NÃO ativar
- Review de código → usar `code-review` ou `spec-review`
- Verificação contra spec → usar `spec-verify`
- Perguntas factuais simples → resposta direta
- Decisões triviais (< 2 opções, impacto mínimo) → resposta direta

---

## 2. Workflow — 4 Steps

### Step 1: 🎯 Identificar Decisão e Domínio

Extrair do input do usuário:
- **Decisão**: O que está sendo decidido (A vs B, fazer vs não fazer, como fazer)
- **Domínio**: Classificar em um dos domínios abaixo (ou Custom)
- **Contexto**: Restrições, prazos, recursos, stakeholders mencionados

### Step 2: 📐 Selecionar Dimensões

Escolher 3-5 dimensões relevantes ao domínio. Cada dimensão carrega uma **persona implícita** (Persona Effect).

#### Domínios e Dimensões Default

**🏗️ Arquitetura de Software**

| Dimensão | Persona Implícita |
|---|---|
| Escalabilidade | SRE que já viveu outage em Black Friday — pensa em 10x o tráfego atual |
| Manutenibilidade | Dev que vai herdar esse código daqui a 2 anos sem documentação |
| Segurança | Pentester que acabou de encontrar uma CVE em produção |
| Custo | CTO de startup com 12 meses de runway — cada dólar importa |
| Time-to-Market | PM sob pressão de entrega com deadline inamovível |

**📦 Produto / Negócio**

| Dimensão | Persona Implícita |
|---|---|
| Viabilidade Técnica | Tech Lead que já viu 3 projetos falharem por ambição técnica |
| Valor pro Usuário | Designer UX que faz pesquisa com usuários toda semana |
| Esforço de Implementação | Dev sênior que estima com base em projetos passados, não otimismo |
| Risco | Risk manager que mapeia o que pode dar errado antes de começar |
| Alinhamento Estratégico | CEO que pergunta "isso nos aproxima da visão de 3 anos?" |

**⚙️ Automação / n8n**

| Dimensão | Persona Implícita |
|---|---|
| Confiabilidade | Ops que é acordado às 3h quando workflow falha — quer zero surpresas |
| Custo Operacional | Controller que audita cada real gasto em infra e SaaS |
| Complexidade de Manutenção | Pessoa que vai debugar esse workflow daqui a 6 meses |
| Resiliência a Falhas | SRE que projeta para falha — "e se a API não responder?" |

**☁️ Salesforce**

| Dimensão | Persona Implícita |
|---|---|
| Governança | Admin que gerencia 50 usuários e precisa de controle total |
| Escalabilidade | Arquiteto que sabe que governor limits existem por uma razão |
| Limite de Governor | Dev que já bateu em SOQL limit 101 em produção |
| UX do Admin | Admin não-técnico que precisa operar sem ajuda de dev |
| Auditabilidade | Compliance officer que precisa de trilha de auditoria completa |

**🎨 Custom**

Quando o usuário define dimensões no prompt:
- Usar exatamente as dimensões fornecidas
- Criar persona implícita coerente para cada uma
- Mínimo 3, máximo 5 dimensões

---

### Step 3: 🏛️ Deliberação

Para cada dimensão selecionada, analisar a decisão sob a lente da persona:

```markdown
### [Emoji] [Dimensão]: [Veredicto curto]
**Persona:** [quem está analisando]

[Análise de 2-3 parágrafos — trade-offs, riscos, benefícios sob esta lente]

**Posição:** [A favor da Opção X / Contra a Opção Y / Neutro com condições]
**Confiança:** [0.0 - 1.0]
```

**Regras da deliberação:**
- Cada dimensão DEVE chegar a uma posição (não ficar em cima do muro)
- Conflitos entre dimensões são esperados e valiosos — não harmonizar artificialmente
- Persona deve trazer experiência vivencial específica, não análise genérica
- Citar riscos concretos, não abstratos ("API pode cair" → "rate limit de 100 req/min estoura com 50 usuários simultâneos")

### Step 4: 📊 Síntese e Veredicto

```markdown
## 📊 Síntese do Council

### Consenso (dimensões que concordam)
- [Ponto de concordância 1]
- [Ponto de concordância 2]

### Tensões (dimensões que divergem)
- [Dimensão A] vs [Dimensão B]: [natureza do conflito]
- [Dimensão C] vs [Dimensão D]: [natureza do conflito]

### 🏛️ Veredicto
**Recomendação:** [Opção recomendada]
**Confiança agregada:** [0.0 - 1.0]
**Condições:** [sob quais premissas esta recomendação vale]

### ⚠️ Riscos Residuais
1. [Risco que nenhuma dimensão consegue mitigar completamente]
2. [Risco aceito conscientemente]

### ➡️ Próximos Passos Sugeridos
1. [Ação imediata]
2. [Validação recomendada]
```

---

## 3. Cálculo de Confiança

| Padrão | Confiança |
|---|---|
| 5/5 dimensões concordam | 0.90 - 0.95 |
| 4/5 concordam, 1 dissente com risco baixo | 0.80 - 0.89 |
| 3/5 concordam, 2 dissentes com riscos reais | 0.60 - 0.79 |
| Empate ou maioria fraca | 0.40 - 0.59 |
| Maioria dissente da opção mais óbvia | 0.30 - 0.39 → ⚠️ flag para o usuário |

**Regra:** Confiança < 0.50 → declarar explicitamente: *"⚠️ O Council não convergiu. A decisão depende de fatores que o Council não consegue resolver — recomendo validação externa."*

---

## 4. Economia de Tokens (Design Decisions)

| Decisão de Design | Motivo |
|---|---|
| **Inline (single response)** | Zero overhead de subagentes (input duplicado, context switch) |
| **3-5 dimensões (não 7-10)** | Sweet spot: diversidade suficiente sem bloat |
| **Personas implícitas (não system prompts)** | Não precisa de prompt separado — a persona é instrução inline |
| **Ativação manual** | Nunca roda automaticamente — usuário controla o custo |
| **Sem multi-model** | Layer 3 (Persona Effect) resolve 80% do viés por 0% de custo extra |

**Custo esperado:** ~1500-2000 tokens de output (3-4x uma resposta direta). Aceitável para decisões que valem pensar duas vezes.

---

## 5. Handoff Points

| Quando | Repassar para | Condição |
|---|---|---|
| Decisão tomada, pronto para implementar | `spec-planner` | Planejar execução da opção escolhida |
| Decisão envolve código existente | `spec-review` | Revisar estado atual antes de decidir |
| Decisão é sobre arquitetura de dados | `supabase-postgres` | Best practices de modelagem |
| Decisão envolve automação | `n8n-workflow-patterns` | Padrões de workflow aplicáveis |
| Council não convergiu (confiança < 0.50) | Usuário | Decisão humana necessária |

---

## 6. Exemplos de Uso

### Exemplo 1: Decisão técnica
```
Usuário: "stress test this: usar Supabase Edge Functions vs Vercel Serverless"
→ Domínio: Arquitetura de Software
→ Dimensões: Escalabilidade, Custo, Manutenibilidade, Time-to-Market, Segurança
→ Council delibera → Veredicto com confiança
```

### Exemplo 2: Decisão de produto
```
Usuário: "council: lançar MVP sem feature X ou esperar 2 semanas?"
→ Domínio: Produto/Negócio
→ Dimensões: Valor pro Usuário, Risco, Time-to-Market, Esforço, Alinhamento
→ Council delibera → Veredicto com confiança
```

### Exemplo 3: Decisão de automação
```
Usuário: "pressure test: migrar de n8n self-hosted para n8n Cloud"
→ Domínio: Automação/n8n
→ Dimensões: Confiabilidade, Custo Operacional, Complexidade, Resiliência
→ Council delibera → Veredicto com confiança
```

### Exemplo 4: Dimensões custom
```
Usuário: "council com dimensões: impacto legal, custo, velocidade, risco reputacional"
→ Domínio: Custom
→ Dimensões: as 4 fornecidas pelo usuário
→ Personas criadas ad-hoc para cada dimensão
```

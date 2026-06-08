---
name: agent-skill-patterns
description: "5 design patterns oficiais do Google ADK para estruturar skills de agentes IA: Tool Wrapper, Generator, Reviewer (com Severity Scoring), Inversion (com Gating Instructions), Pipeline (com Diamond Gates). Use quando precisar criar, auditar ou refatorar skills, definir workflows de agentes, implementar gates de aprovação, ou classificar findings por severidade. Fonte: Google Cloud Tech (03/2026)."
license: Educational (Google ADK patterns)
metadata:
    skill-author: Deivithi (formalizado a partir de Google Cloud Tech / ADK docs)
    source: https://x.com/GoogleCloudTech/status/2033953579824758855
    version: 1.0.0
    created: 2026-03-18
---

# 🏗️ Agent Skill Patterns — 5 Padrões ADK + 3 Melhorias

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelos 5 Padrões abaixo.
- `references/severity-matrix.md` — Matriz de severidade para Reviewer pattern.
- `gotchas.md` — ⚠️ Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `autonomous-agent-loop` — Use para aplicar os padrões em agentes que rodam indefinidamente
- `scaffolding` — Use para gerar estrutura de novas skills seguindo os padrões ADK
- `code-review` — Use o padrão Reviewer com Severity Scoring para revisão de código (Wave 5)

Padrões oficiais do Google ADK para design de conteúdo de skills, enriquecidos com **3 melhorias exclusivas**: Diamond Gates, Severity Scoring e Gating Instructions.

> 💡 **Origem:** Google Cloud Tech, 17/03/2026. Artigo: "5 Agent Skill design patterns every ADK developer should know."
> 🔑 **Princípio-chave:** *"Esses padrões não são mutuamente exclusivos. Eles se compõem."*

---

## 📐 Conceito: O que é uma Skill (definição Google)

> *"Uma skill não é uma tool. Ela não executa código nem chama API. É um **pacote de conhecimento**: instruções, material de referência e templates que dizem ao agente como se comportar para um tipo específico de tarefa."*

### Progressive Disclosure (3 Níveis)

```
Nível 1: METADATA (sempre visível)     → nome + descrição (decisão de relevância)
Nível 2: INSTRUCTIONS (sob demanda)    → SKILL.md completo (carregado quando ativada)
Nível 3: REFERENCES/ASSETS (granular)  → glossários, templates, docs (durante execução)
```

**Token efficiency:** Só a skill ativada consome tokens. As demais ficam apenas como metadata.

---

## 🔧 Padrão 1: Tool Wrapper

**Quando usar:** Quando precisa empacotar conhecimento de uma biblioteca, API ou ferramenta em formato reutilizável.

**Problema que resolve:** Em vez de hardcodar convenções no system prompt (poluindo o contexto sempre), carrega o conhecimento **dinamicamente** quando o agente precisa.

### Estrutura

```
tool-wrapper-skill/
├── SKILL.md           # "Ao usar [ferramenta], siga estas convenções:"
├── references/
│   ├── conventions.md   # Boas práticas e padrões
│   ├── api-reference.md # Referência de API/parâmetros
│   └── gotchas.md       # Armadilhas comuns e como evitar
└── assets/
    └── config-template.yaml  # Template de configuração padrão
```

### Exemplo Aplicado

```markdown
# SKILL.md — Salesforce SOQL Best Practices

Ao escrever queries SOQL:
1. Carregar `references/field-limits.md` para verificar limites de campos por objeto
2. SEMPRE usar filtros seletivos (indexed fields first)
3. NUNCA usar SELECT * — listar campos explicitamente
4. Consultar `references/governor-limits.md` para limites de batch
```

### Checklist de Qualidade

```
□ O conhecimento é específico de uma ferramenta/tecnologia?
□ Seria desperdício carregar sempre no system prompt?
□ O agente precisa desse conhecimento apenas quando usa a ferramenta?
→ Se SIM para todos: use Tool Wrapper
```

---

## 📝 Padrão 2: Generator

**Quando usar:** Quando precisa gerar outputs consistentes e padronizados (docs, configs, templates, mensagens).

**Problema que resolve:** Sem um Generator, cada output é improvisado. Com ele, o agente segue um processo **fill-in-the-blank** estruturado.

### Estrutura

```
generator-skill/
├── SKILL.md           # Workflow de geração passo-a-passo
├── references/
│   └── style-guide.md   # Guia de estilo/tom/formato
└── assets/
    ├── template-a.md     # Template principal
    └── template-b.md     # Template alternativo
```

### Workflow do Generator

```
1. Identificar tipo de output necessário
2. Carregar template de assets/
3. Carregar style guide de references/
4. Coletar variáveis necessárias (pode usar Inversion — Padrão 4)
5. Preencher template
6. Validar output contra style guide
7. Entregar
```

### Exemplo Aplicado

```markdown
# SKILL.md — Gerador de Requisitos Salesforce

## Workflow
1. Carregar `assets/template-requisito.md`
2. Carregar `references/glossario-febracis.md`
3. Preencher campos:
   - Título do requisito
   - User story (Como [persona], quero [ação], para [benefício])
   - Critérios de aceite (checkboxes)
   - Objetos Salesforce impactados
   - Campos novos/modificados
   - Regras de validação
   - Fluxos de automação impactados
4. Validar contra `references/checklist-requisito.md`
```

---

## 🔍 Padrão 3: Reviewer (+ 🆕 Severity Scoring)

**Quando usar:** Quando precisa avaliar, auditar ou revisar algo contra critérios predefinidos.

**Problema que resolve:** Separa os **critérios de avaliação** da **lógica de execução**. O agente não inventa critérios — segue o checklist.

### Estrutura

```
reviewer-skill/
├── SKILL.md           # Protocolo de revisão
├── references/
│   ├── checklist.md     # Critérios de avaliação
│   ├── severity-matrix.md  # 🆕 Matriz de severidade
│   └── examples.md      # Exemplos de pass/fail
└── assets/
    └── report-template.md  # Template do relatório de revisão
```

### 🆕 Severity Scoring — Sistema de Pontuação por Severidade

Em vez de pass/fail binário, cada finding é classificado:

```
┌─────────────────────────────────────────────┐
│  SEVERITY SCORING MATRIX                    │
├──────────┬──────┬───────────────────────────┤
│ Nível    │ Peso │ Critério                  │
├──────────┼──────┼───────────────────────────┤
│ CRITICAL │  10  │ Quebra funcionalidade,     │
│          │      │ perda de dados, segurança  │
├──────────┼──────┼───────────────────────────┤
│ HIGH     │   5  │ Funcionalidade degradada,  │
│          │      │ workaround difícil         │
├──────────┼──────┼───────────────────────────┤
│ MEDIUM   │   3  │ Inconveniente, workaround  │
│          │      │ fácil disponível           │
├──────────┼──────┼───────────────────────────┤
│ LOW      │   1  │ Cosmético, boas práticas,  │
│          │      │ melhoria opcional          │
├──────────┼──────┼───────────────────────────┤
│ INFO     │   0  │ Observação, sem ação       │
│          │      │ necessária                 │
└──────────┴──────┴───────────────────────────┘
```

**Thresholds de decisão:**

| Score Total | Decisão |
|-------------|---------|
| 0 | ✅ Aprovado — sem findings |
| 1-5 | ✅ Aprovado com observações |
| 6-15 | ⚠️ Aprovado condicional — corrigir HIGHs antes de deploy |
| 16-29 | ❌ Reprovado — corrigir antes de prosseguir |
| 30+ | 🛑 Bloqueado — revisão arquitetural necessária |

### Protocolo de Review

```markdown
## Para cada item do checklist:

1. Avaliar contra o critério
2. Classificar severidade (CRITICAL/HIGH/MEDIUM/LOW/INFO)
3. Documentar finding com:
   - **O quê:** Descrição do problema
   - **Onde:** Arquivo:linha ou componente
   - **Por quê:** Impacto se não corrigido
   - **Como:** Correção sugerida
   - **Severidade:** [CRITICAL|HIGH|MEDIUM|LOW|INFO]

## Score Final = Σ(peso × quantidade por nível)

## Decisão baseada no threshold
```

### Exemplo de Output

```markdown
## Review Report — Scoring de Leads v2.3

| # | Finding | Severidade | Score |
|---|---------|-----------|-------|
| 1 | Campo `lead_source` sem validação — aceita valores nulos | HIGH | 5 |
| 2 | Fórmula de decay usa divisão sem proteção contra zero | CRITICAL | 10 |
| 3 | Variável `weight_email` hardcoded em vez de config | MEDIUM | 3 |
| 4 | Comentário desatualizado na linha 45 | LOW | 1 |

**Score Total: 19 → ❌ Reprovado** — Corrigir CRITICAL #2 e HIGH #1 antes de prosseguir.
```

---

## 🔄 Padrão 4: Inversion (+ 🆕 Gating Instructions)

**Quando usar:** Quando o agente precisa **entender antes de executar**. Antes de gerar qualquer output, conduz uma entrevista estruturada.

**Problema que resolve:** Agentes que executam imediatamente com informação incompleta produzem outputs genéricos ou incorretos. O Inversion força completude.

### Estrutura

```
inversion-skill/
├── SKILL.md           # Protocolo de entrevista + gates
├── references/
│   ├── question-bank.md   # Banco de perguntas por categoria
│   └── completeness-criteria.md  # O que define "informação suficiente"
└── assets/
    └── interview-template.md  # Template de entrevista
```

### 🆕 Gating Instructions — "NÃO prossiga até..."

O core do Inversion são **gates explícitos** que bloqueiam o progresso:

```markdown
## Gates de Completude

⛔ Gate 1: NÃO prossiga até ter clareza sobre o OBJETIVO
   - O que o usuário quer alcançar?
   - Qual a métrica de sucesso?
   - Qual o prazo?

⛔ Gate 2: NÃO prossiga até mapear o ESCOPO
   - O que está dentro do escopo?
   - O que está FORA do escopo? (tão importante quanto)
   - Quais sistemas serão impactados?

⛔ Gate 3: NÃO prossiga até identificar as RESTRIÇÕES
   - Limitações técnicas?
   - Dependências externas?
   - Compatibilidade necessária?

⛔ Gate 4: NÃO prossiga até definir os CRITÉRIOS DE ACEITE
   - Como sabemos que está pronto?
   - Quais testes validam a entrega?
   - Quem aprova?

✅ TODOS os gates satisfeitos → Pode prosseguir com a execução
```

### Protocolo de Inversion

```
1. ANTES de qualquer ação, ativar modo Inversion
2. Apresentar os gates ao usuário
3. Para cada gate:
   a. Fazer a(s) pergunta(s) do gate
   b. Avaliar se a resposta é suficiente
   c. Se insuficiente → reformular e perguntar novamente
   d. Se suficiente → marcar gate como ✅
4. SOMENTE quando TODOS os gates estão ✅ → prosseguir
5. Se o usuário pedir para pular → avisar dos riscos, registrar como "gate bypassed"
```

### Exemplo Aplicado

```markdown
# Antes de criar automação Salesforce:

⛔ Gate 1 — OBJETIVO
"Qual processo você quer automatizar e qual o resultado esperado?"

⛔ Gate 2 — ESCOPO
"Quais objetos Salesforce estão envolvidos? Quais NÃO devem ser tocados?"

⛔ Gate 3 — RESTRIÇÕES
"Há limites de governor? Outros flows que podem conflitar?"

⛔ Gate 4 — ACEITE
"Como vamos testar? Sandbox primeiro? Quem aprova para produção?"

✅ Todos os gates OK → Iniciar implementação
```

---

## ⛓️ Padrão 5: Pipeline (+ 🆕 Diamond Gates)

**Quando usar:** Quando o workflow tem etapas sequenciais obrigatórias e **não pode pular nenhuma**.

**Problema que resolve:** Agentes que pulam etapas críticas de validação, revisão ou aprovação.

### Estrutura

```
pipeline-skill/
├── SKILL.md           # Workflow sequencial com checkpoints
├── references/
│   ├── stage-criteria.md    # Critérios por etapa
│   └── approval-matrix.md   # Quem aprova o quê
└── assets/
    └── stage-report-template.md  # Template de relatório por etapa
```

### 🆕 Diamond Gates — Aprovação Explícita do Usuário

Diamond Gates são **pontos de decisão obrigatórios** onde o agente PARA e pede aprovação do humano antes de prosseguir:

```
    ┌──────────────┐
    │  📋 Etapa 1  │
    │  Análise     │
    └──────┬───────┘
           │
     ◆ Diamond Gate 1 ◆
     "Análise aprovada?"
    ╱                    ╲
  ✅ SIM                ❌ NÃO
   │                      │
   ▼                      ▼
┌──────────────┐    ┌──────────────┐
│  ⚙️ Etapa 2  │    │  🔄 Refazer  │
│  Implementar │    │  Etapa 1     │
└──────┬───────┘    └──────────────┘
       │
 ◆ Diamond Gate 2 ◆
 "Implementação OK?"
      ╱            ╲
    ✅ SIM        ❌ NÃO
     │               │
     ▼               ▼
┌──────────────┐  ┌──────────────┐
│  🧪 Etapa 3  │  │  🔄 Refazer  │
│  Validação   │  │  Etapa 2     │
└──────┬───────┘  └──────────────┘
       │
 ◆ Diamond Gate 3 ◆
 "Validação aprovada
  para deploy?"
      ╱            ╲
    ✅ SIM        ❌ NÃO
     │               │
     ▼               ▼
┌──────────────┐  ┌──────────────┐
│  📦 Deploy   │  │  🔄 Corrigir │
│  (entrega)   │  │  e revalidar │
└──────────────┘  └──────────────┘
```

### Regras dos Diamond Gates

```markdown
1. O agente DEVE parar no Diamond Gate e aguardar resposta
2. O agente NÃO PODE auto-aprovar — SOMENTE o humano aprova
3. Em cada gate, o agente apresenta:
   - Resumo do que foi feito na etapa
   - Artefatos produzidos
   - Riscos identificados
   - Pergunta explícita: "Aprovado para prosseguir?"
4. Se NÃO aprovado → voltar à etapa, corrigir, apresentar novamente
5. Se aprovado → avançar para próxima etapa
6. Gates são OBRIGATÓRIOS — não podem ser pulados
```

### Quando usar Diamond Gates

| Cenário | Diamond Gate? | Motivo |
|---------|:---:|--------|
| Deploy em produção Salesforce | ✅ | Irreversível, impacta usuários |
| Modificar regras de comissão | ✅ | Impacto financeiro direto |
| Enviar email em massa | ✅ | Ação visível a terceiros |
| Alterar fluxos de automação | ✅ | Pode quebrar processos ativos |
| LGPD — tratamento de dados pessoais | ✅ | Compliance legal |
| Refatorar código local | ❌ | Reversível, sem impacto externo |
| Criar documentação | ❌ | Low-risk, reversível |
| Explorar/pesquisar | ❌ | Read-only, sem impacto |

---

## 🧩 Composição de Padrões

Os padrões se compõem. Combinações poderosas:

```
┌──────────────────────────────────────────────────┐
│              PIPELINE COMPOSTO                    │
│                                                   │
│  Inversion (Gate) → Generator → Reviewer → Deploy │
│  "Entenda antes"   "Gere"    "Avalie"   "Entregue"│
│       ⛔              📝         🔍        ◆       │
│   (não prossiga     (use       (score    (Diamond  │
│    sem entender)   template)  severity)   Gate)    │
└──────────────────────────────────────────────────┘
```

### Receitas de Composição

| Cenário | Padrões Combinados |
|---------|-------------------|
| Criar automação Salesforce | **Inversion** → **Generator** → **Reviewer** → **Pipeline** (com Diamond Gate antes do deploy) |
| Auditar segurança | **Tool Wrapper** (carregar checklist OWASP) → **Reviewer** (Severity Scoring) |
| Levantar requisitos | **Inversion** (gates de completude) → **Generator** (template de user story) |
| Migração de dados | **Pipeline** (com Diamond Gates entre cada fase: análise → mapeamento → ETL → validação → go-live) |
| Otimização de scoring | **Inversion** (entender métricas atuais) → **Pipeline** (autonomous-agent-loop) |

---

## 📋 Cheat Sheet — Qual Padrão Usar?

```
O que preciso fazer?
│
├── Empacotar conhecimento de uma ferramenta?
│   └── 🔧 Tool Wrapper
│
├── Gerar output padronizado/consistente?
│   └── 📝 Generator
│
├── Avaliar/auditar algo contra critérios?
│   └── 🔍 Reviewer (+ Severity Scoring)
│
├── Entender contexto ANTES de executar?
│   └── 🔄 Inversion (+ Gating Instructions)
│
├── Workflow sequencial com aprovações?
│   └── ⛓️ Pipeline (+ Diamond Gates)
│
└── Combinação complexa?
    └── 🧩 Compor padrões acima
```

---

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Padrão Reviewer aplicado a code review | `code-review` | Severity Scoring integrado ao review |
| Padrão Pipeline para agentes de longa duração | `autonomous-agent-loop` | 11 design patterns para loops infinitos |
| Gerar estrutura de nova skill | `scaffolding` | Boilerplate seguindo padrões ADK |
| Skill nova precisa de avaliação | `evals` | Trigger evals + output quality |
| Padrões aplicados, medir evolução | `ouroboros` | Motor de auto-aprimoramento recursivo |

---

## 📚 Referências

- **Fonte:** [Google Cloud Tech — 5 Agent Skill Design Patterns](https://x.com/GoogleCloudTech/status/2033953579824758855) (17/03/2026)
- **ADK Docs:** [Agent Development Kit](https://google.github.io/adk-docs/)
- **Skills in ADK:** [On-Demand Instructions for Agents](https://devengoratela.com/2026/02/skills-in-adk-on-demand-instructions-for-your-agents/)
- **Multi-Agent Patterns:** [Google Developers Blog](https://developers.googleblog.com/developers-guide-to-multi-agent-patterns-in-adk/)

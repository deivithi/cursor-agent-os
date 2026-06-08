---
name: autonomous-agent-loop
description: Design pattern for building autonomous AI agents that run indefinitely in experiment loops. Use when designing agents that optimize metrics autonomously (lead scoring, A/B testing, funnel optimization, rule tuning, config optimization), or when applying the keep/discard/crash loop, immutable evaluation, single success metric, time-boxed experiments, blast radius control, or structured experiment logging. Extracted from Karpathy's autoresearch architecture.
license: Custom (educational extraction)
metadata:
    skill-author: Deivithi (extracted from karpathy/autoresearch)
    source: https://github.com/karpathy/autoresearch
    version: 1.0.0
    extracted: 2026-03-18
---

# 🔄 Autonomous Agent Loop — Design Patterns para Agentes Autônomos

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelos 10 Padrões abaixo.
- `references/examples.md` — Exemplos concretos de aplicação por domínio.
- `references/provenance.md` — Proveniência e fontes originais.
- `gotchas.md` — ⚠️ Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `agent-skill-patterns` — Use para estruturar as skills que o agente autônomo vai executar
- `product-verification` — Use para verificar outputs dos experimentos do agente
- `science` — Use para análise estatística dos resultados (scikit-learn, SHAP, Polars)

Padrões arquiteturais extraídos do `autoresearch` de Andrej Karpathy, generalizados para **qualquer domínio** onde um agente de IA precisa otimizar métricas de forma autônoma.

> 💡 **Origem:** Karpathy criou um sistema onde o agente faz ~100 experimentos por noite enquanto o humano dorme. Os padrões abaixo são **agnósticos de domínio** — funcionam para ML, vendas, operações, scoring, ou qualquer sistema com métricas mensuráveis.

---

## 🏗️ Os 10 Padrões Fundamentais

### 1. 🔁 Loop Autônomo Infinito (The Forever Loop)

**Princípio:** O agente roda indefinidamente até ser interrompido. Nunca para para perguntar "devo continuar?".

```
LOOP FOREVER:
  1. Analisar estado atual
  2. Formular hipótese de melhoria
  3. Implementar mudança
  4. Commitar (snapshot)
  5. Executar experimento (time-boxed)
  6. Avaliar resultado contra métrica fixa
  7. Se melhorou → KEEP (avançar)
  8. Se piorou → DISCARD (reverter ao estado anterior)
  9. Se crashou → CRASH (logar, diagnosticar, tentar fix ou pular)
  10. Logar resultado estruturado
  11. Voltar ao passo 1
```

**Regras do Loop:**
- **NUNCA parar para perguntar** — o humano pode estar dormindo
- Se ficar sem ideias → repensar com mais profundidade, combinar abordagens anteriores, tentar mudanças mais radicais
- O loop só para por interrupção manual externa
- Cada iteração é **autocontida** — crash numa iteração não mata o loop

**Aplicação Febracis/Aria:**
- Agente que otimiza regras de scoring de leads durante a madrugada
- Agente que testa variações de templates de email e mede taxa de abertura
- Agente que ajusta thresholds de priorização de leads e mede conversão

---

### 2. 📏 Métrica Única de Sucesso (Single Source of Truth)

**Princípio:** Todo o sistema é governado por **uma única métrica, claramente definida, imutável**.

| Domínio | Métrica Única | Direção |
|---------|---------------|---------|
| ML (Karpathy) | `val_bpb` (bits per byte) | ↓ Menor = melhor |
| Scoring de leads | Taxa de conversão do score | ↑ Maior = melhor |
| Email marketing | Taxa de abertura + clique | ↑ Maior = melhor |
| Funil de vendas | Velocidade de conversão (dias) | ↓ Menor = melhor |
| Atendimento | CSAT ou tempo de resolução | Depende |

**Regras:**
- A métrica deve ser **computável automaticamente**, sem julgamento humano
- A métrica deve ser **comparável** entre experimentos (mesma escala, mesmo dataset/período)
- A métrica é **imutável** durante a execução do loop — mudar a métrica é mudar o experimento
- Se precisar de múltiplas métricas → criar uma **métrica composta** com pesos explícitos

```
# Exemplo: Métrica composta para scoring de leads
score_final = (0.6 * taxa_conversao) + (0.3 * velocidade_funil) + (0.1 * custo_aquisicao_inverso)
```

---

### 3. 🔒 Separação Imutável vs Modificável (The Firewall)

**Princípio:** Separar rigidamente o que o agente **pode** modificar do que é **fixo e auditável**.

```
┌─────────────────────────────────────────────┐
│  ZONA IMUTÁVEL (prepare.py)                 │
│  ─────────────────────────────────          │
│  • Função de avaliação                      │
│  • Carregamento de dados                    │
│  • Constantes do sistema                    │
│  • Critérios de sucesso                     │
│  • Budget de tempo                          │
│  ⛔ AGENTE NÃO PODE TOCAR                   │
├─────────────────────────────────────────────┤
│  ZONA MODIFICÁVEL (train.py)                │
│  ─────────────────────────────────          │
│  • Configurações e parâmetros               │
│  • Lógica de execução                       │
│  • Arquitetura/estratégia                   │
│  • Hiperparâmetros                          │
│  ✅ AGENTE MODIFICA LIVREMENTE               │
└─────────────────────────────────────────────┘
```

**Por que isso importa:**
- Se o agente pudesse modificar a avaliação, poderia "trapacear" — melhorar a métrica mudando como ela é calculada
- A zona imutável é a **âncora de confiança** do sistema
- Governança = controlar a fronteira entre as duas zonas

**Aplicação prática:**

| Zona Imutável | Zona Modificável |
|---------------|------------------|
| Query SQL que puxa dados de conversão | Regras de scoring/priorização |
| Dashboard de métricas | Templates de comunicação |
| Critérios de qualificação de lead | Pesos e thresholds |
| Regras de comissão | Automações de follow-up |

---

### 4. ⏱️ Experimentos Time-Boxed (Fixed Budget)

**Princípio:** Todo experimento tem um **budget fixo de tempo**. Nunca variável.

```
TIME_BUDGET = 300  # 5 minutos (Karpathy)
TIMEOUT = TIME_BUDGET * 2  # Se exceder 2x, matar e tratar como crash
```

**Por que fixar o tempo:**
- Torna os resultados **comparáveis** — todos tiveram o mesmo tempo
- Previne experimentos que rodam indefinidamente
- Permite calcular throughput: `experimentos_por_hora = 60 / (TIME_BUDGET_min)`
- O humano pode estimar quantos experimentos rodam enquanto dorme

**Tabela de referência:**

| Budget por experimento | Experimentos/hora | Em 8h de sono |
|------------------------|-------------------|---------------|
| 1 minuto | 60 | ~480 |
| 5 minutos | 12 | ~96 |
| 15 minutos | 4 | ~32 |
| 30 minutos | 2 | ~16 |
| 1 hora | 1 | ~8 |

**Regra de timeout:** Se um experimento exceder `2x` o budget → matar o processo, logar como `crash`, reverter, seguir em frente.

---

### 5. 📋 Logging Estruturado de Experimentos (The Ledger)

**Princípio:** Todo experimento é registrado em um log estruturado (TSV/CSV) com schema fixo.

```
# Schema do Karpathy (results.tsv)
commit    val_bpb    memory_gb    status    description

# Schema generalizado
experiment_id    metric_value    resource_cost    status    description    timestamp
```

**Status possíveis:**

| Status | Significado | Ação |
|--------|-------------|------|
| `keep` | Melhorou a métrica | Manter mudança, avançar |
| `discard` | Piorou ou igual | Reverter, tentar outra coisa |
| `crash` | Falhou/erro | Logar erro, diagnosticar, seguir |

**Regras do ledger:**
- **Nunca deletar** entradas — o log é append-only
- **Nunca commitar o log** no git — ele é metadado, não código
- Incluir **descrição curta** de cada experimento (o que foi tentado)
- Usar **TSV** (tabs), não CSV — vírgulas quebram em descrições textuais

**Exemplo aplicado (scoring de leads):**

```tsv
experiment_id	conversion_rate	leads_tested	status	description	timestamp
exp_001	0.034	5000	keep	baseline - regras atuais	2026-03-18T03:00
exp_002	0.038	5000	keep	aumentar peso de interação recente	2026-03-18T03:05
exp_003	0.032	5000	discard	remover critério de cargo	2026-03-18T03:10
exp_004	0.000	0	crash	divisão por zero no cálculo de decay	2026-03-18T03:15
exp_005	0.041	5000	keep	adicionar fator de engajamento email	2026-03-18T03:20
```

---

### 6. 🎯 Keep/Discard/Crash — O Protocolo de Decisão

**Princípio:** Toda decisão de manter ou descartar é **binária e automática** — sem julgamento humano no loop.

```python
def decide(current_metric, best_metric, experiment_status):
    if experiment_status == "crash":
        return "crash"  # Logar, diagnosticar, não reverter automaticamente

    if is_better(current_metric, best_metric):
        return "keep"   # Avançar: nova baseline
    else:
        return "discard"  # Reverter ao estado anterior
```

**Protocolo de reversão (discard):**
```bash
# Karpathy usa git reset
git reset --hard HEAD~1   # Voltar ao commit anterior

# Alternativa mais segura (recomendada)
git revert HEAD --no-edit  # Criar commit de reversão (auditável)
```

**Protocolo de crash:**
1. Ler o log de erro (últimas 50 linhas)
2. Se é algo simples (typo, import faltando) → corrigir e re-executar
3. Se é fundamental (OOM, lógica impossível) → logar como crash, pular, tentar outra coisa
4. Se crashar 3x seguidas na mesma ideia → abandonar a linha de investigação

---

### 7. 💎 Critério de Simplicidade (Simplicity Wins)

**Princípio:** Na dúvida entre duas abordagens com resultados similares, **a mais simples vence**.

> *"Uma melhoria pequena que adiciona complexidade feia não vale a pena. Remover algo e obter resultado igual ou melhor é uma vitória de simplificação."* — Karpathy

**Matriz de decisão:**

| Melhoria na métrica | Complexidade adicionada | Decisão |
|---------------------|-------------------------|---------|
| Grande (+5%) | Baixa | ✅ KEEP |
| Grande (+5%) | Alta | ✅ KEEP (com ressalva) |
| Pequena (+0.1%) | Baixa | ✅ KEEP |
| Pequena (+0.1%) | Alta | ❌ DISCARD |
| Nenhuma (0%) | Negativa (simplificou) | ✅ KEEP |
| Nenhuma (0%) | Positiva (complicou) | ❌ DISCARD |

**Alinhamento com Integridade Conceitual (Fred Brooks):**
> *É preferível que um sistema omita certas funções do que ter várias funcionalidades desconexas que quebram a unidade.*

---

### 8. 💥 Controle de Blast Radius

**Princípio:** O agente só pode modificar **um escopo bem definido**. Nunca o sistema inteiro.

```
Karpathy: agente modifica APENAS train.py (1 arquivo)
Generalizado: agente modifica APENAS [escopo definido]
```

**Definição de escopo por caso de uso:**

| Caso de Uso | Escopo Permitido | Escopo Proibido |
|-------------|------------------|-----------------|
| Otimização de scoring | Pesos e thresholds do modelo | Query de dados, schema do BD |
| A/B testing de emails | Template e subject line | Lista de destinatários, frequência |
| Otimização de funil | Regras de automação de follow-up | Regras de comissão, dados de lead |
| Tuning de chatbot | Prompts e configurações | Lógica de roteamento, dados de treinamento |

**Por que isso importa:**
- Blast radius controlado = risco controlado
- Se o agente crashar, o dano é **contido** ao escopo permitido
- Facilita auditoria — só precisa revisar mudanças em 1 lugar

---

### 9. 📄 Program.md — Instruções Estruturadas para Agentes

**Princípio:** Todo agente autônomo precisa de um documento de instruções **claro, completo e não-ambíguo**.

**Anatomia do program.md (Karpathy):**

```markdown
# 1. SETUP — O que fazer antes de começar
   - Branch, verificar dados, inicializar log

# 2. ESCOPO — O que pode e não pode fazer
   - CAN DO: lista explícita
   - CANNOT DO: lista explícita

# 3. OBJETIVO — Métrica única
   - "Get the lowest val_bpb"

# 4. FORMATO DE OUTPUT — Como ler resultados
   - Formato exato da saída, como extrair a métrica

# 5. LOGGING — Como registrar resultados
   - Schema do TSV, exemplos

# 6. LOOP — O protocolo de experimentação
   - Passos numerados, regras de keep/discard/crash

# 7. REGRAS DE AUTONOMIA — Quando parar (nunca)
   - "NEVER STOP", "do NOT pause to ask"
```

**Template generalizado para seus agentes:**

```markdown
# [Nome do Agente] — Program

## Setup
- [ ] Verificar pré-requisitos
- [ ] Inicializar log de experimentos
- [ ] Estabelecer baseline

## Escopo
**PODE modificar:** [lista explícita]
**NÃO PODE modificar:** [lista explícita]
**NÃO PODE instalar:** [restrições de dependências]

## Objetivo
Otimizar: [MÉTRICA ÚNICA]
Direção: [↑ maior = melhor | ↓ menor = melhor]

## Budget
Tempo por experimento: [X minutos]
Timeout: [2X minutos]

## Logging
[Schema TSV com exemplos]

## Loop
[Protocolo numerado de experimentação]

## Autonomia
- Nível: [FULL | SUPERVISED | MANUAL]
- Parar apenas quando: [condição explícita ou "interrupção manual"]
```

---

### 10. 🌿 Git como Sistema de Experimentos

**Princípio:** Cada experimento é um commit. O histórico git **é** o histórico de pesquisa.

```
Branch: autoresearch/[tag]
  │
  ├── commit a1b2c3d — baseline (keep)
  ├── commit b2c3d4e — aumentar LR (keep)
  ├── commit c3d4e5f — switch GeLU (discard → revert)
  ├── commit d4e5f6g — double width (crash → revert)
  └── commit e5f6g7h — add dropout 0.1 (keep)
```

**Regras:**
- **Branch dedicada** para cada sessão de experimentação
- Usar **tags/prefixos** descritivos: `autoresearch/`, `experiment/`, `optimize/`
- **Nunca commitar no main/master** — sempre em branch isolada
- O log TSV é **não-commitado** (untracked) — é metadado, não código
- Cada commit tem **mensagem descritiva** do que foi tentado

**Benefícios:**
- `git log` = histórico completo de todas as tentativas
- `git diff` entre dois keeps = evolução incremental
- `git bisect` = encontrar qual experimento introduziu um problema
- `git cherry-pick` = recuperar uma ideia descartada para re-testar

---

## 🔄 Workflow Completo — Implementação Passo a Passo

### Fase 1: Design (Humano)

```
1. Definir a MÉTRICA ÚNICA de sucesso
2. Definir o ESCOPO (modificável vs imutável)
3. Definir o TIME BUDGET por experimento
4. Criar o program.md com instruções completas
5. Criar a função de avaliação (imutável)
6. Implementar o baseline
```

### Fase 2: Setup (Agente)

```
1. Criar branch dedicada: experiment/[tag]
2. Inicializar results.tsv com header
3. Verificar pré-requisitos (dados, dependências)
4. Executar baseline e registrar resultado
5. Confirmar setup com o humano
```

### Fase 3: Loop Autônomo (Agente — sem supervisão)

```
LOOP:
  1. Analisar resultados anteriores
  2. Formular hipótese (baseada em padrões observados)
  3. Implementar mudança no escopo permitido
  4. git commit -m "experiment: [descrição]"
  5. Executar com timeout
  6. Extrair métrica do output
  7. Decidir: keep / discard / crash
  8. Se keep → avançar
  9. Se discard → git revert
  10. Se crash → diagnosticar, tentar fix ou pular
  11. Logar em results.tsv
  12. Voltar ao passo 1
```

### Fase 4: Review (Humano)

```
1. Ler results.tsv — visão geral de todos os experimentos
2. git log — ver a evolução incremental
3. Comparar baseline vs melhor resultado
4. Auditar as mudanças mantidas (keeps)
5. Decidir próximos passos
```

---

## 🔬 Padrão 11: Densidade Semântica por Passo (CALM-Derived)

> 💡 **Fonte:** Paper CALM — Continuous Autoregressive Language Models (arXiv 2510.27688, Out/2025). Comprime K tokens em 1 vetor contínuo, reduzindo passos generativos com qualidade equivalente.

**Princípio:** Maximize a **informação por iteração** do loop. Menos passos com alta densidade > muitos passos com informação rala.

### Regras derivadas para agentes autônomos

| Regra | Aplicação | Evidência CALM |
|-------|-----------|----------------|
| **Single-Step > Iterativo** | Se o agente precisa de >3 iterações para uma decisão, o problema está no **framing**, não na execução | Energy Score (1 passo) supera diffusion (dezenas de passos) |
| **Sweet Spot K=3-5** | Agrupar 3-5 micro-experimentos relacionados antes de avaliar, não 1 nem 8+ | K=4 ótimo; K=8 retornos decrescentes |
| **Grounding Discreto** | Sempre voltar aos **dados concretos** entre iterações — não raciocinar sobre resumos de resumos | Input discreto supera contínuo (BrierLM 4.70 vs 3.25) |
| **Compressão antes de decidir** | Comprimir o log de experimentos anteriores em **padrões observados** antes de formular a próxima hipótese | 99.9% fidelidade com compressão 4:1 |

### Integração com os 10 Padrões Originais

- **Padrão 2 (Métrica Única):** A métrica deve ser densa — capturar máximo sinal em um único número
- **Padrão 5 (Ledger):** Antes de cada iteração, comprimir o ledger em insights (não reler todas as linhas)
- **Padrão 7 (Simplicidade):** Densidade semântica = simplicidade computacional. Menos passos = menos oportunidades de erro

---

## 📐 Anti-Patterns (O que NÃO fazer)

| Anti-Pattern | Por quê | Correção |
|-------------|---------|----------|
| Mudar a métrica no meio do loop | Resultados ficam incomparáveis | Definir métrica antes, nunca mudar durante |
| Deixar o agente modificar a avaliação | Agente pode "trapacear" | Zona imutável rigorosa |
| Não ter timeout | Experimento pode rodar infinitamente | Budget fixo + kill após 2x |
| Não logar crashes | Perde-se informação valiosa sobre o que não funciona | Logar tudo, inclusive falhas |
| Commitar o log no git | Conflitos, poluição do histórico | Log é untracked, separado do código |
| Escopo muito amplo | Blast radius descontrolado | 1 arquivo / 1 componente por vez |
| Parar para perguntar | Quebra a autonomia, humano pode estar ausente | Nunca parar, decidir sozinho |
| Ignorar simplicidade | Acumula complexidade desnecessária | Simplicidade como critério de keep/discard |

---

## 🧮 Cheat Sheet — Decisão Rápida

```
Melhorou a métrica?
  ├── SIM → A mudança é simples?
  │     ├── SIM → ✅ KEEP
  │     └── NÃO → A melhoria é significativa?
  │           ├── SIM → ✅ KEEP (com nota)
  │           └── NÃO → ❌ DISCARD (complexidade não justifica)
  ├── NÃO (igual) → Simplificou o código?
  │     ├── SIM → ✅ KEEP (simplification win)
  │     └── NÃO → ❌ DISCARD
  └── CRASH → Erro simples?
        ├── SIM → 🔧 FIX e re-executar
        └── NÃO → ❌ SKIP (logar e seguir)
```

---

## 📚 Referências

- **Fonte original:** [karpathy/autoresearch](https://github.com/karpathy/autoresearch) — Andrej Karpathy (2026)
- **Conceito:** Loop autônomo de pesquisa onde o agente roda ~100 experimentos por noite
- **Filosofia alinhada:** Integridade Conceitual (Fred Brooks), "Pensar é Caro" (Ronnald Hawk)
- **Padrões extraídos:** 10 design patterns agnósticos de domínio para agentes autônomos

# 📋 Exemplos Concretos — Autonomous Agent Loop

## Exemplo 1: Otimizador Autônomo de Lead Scoring

### program.md do agente

```markdown
# Lead Score Optimizer — Program

## Setup
- Branch: experiment/scoring-[data]
- Dados: export de leads dos últimos 90 dias com flag de conversão
- Baseline: scoring atual do Salesforce

## Escopo
PODE modificar: pesos de scoring, thresholds de prioridade, fórmulas de decay temporal
NÃO PODE modificar: query de dados, campos do lead, regras de atribuição, fluxos de automação

## Objetivo
Otimizar: taxa_conversao_top_20 (% de leads no top 20% de score que converteram)
Direção: ↑ maior = melhor

## Budget
Tempo por experimento: 2 minutos (processamento dos dados + cálculo)
Timeout: 5 minutos

## Logging
experiment_id	conversion_top20	precision	recall	status	description	timestamp

## Loop
1. Ler scoring atual e resultados anteriores
2. Formular hipótese (ajustar peso, adicionar/remover fator, mudar decay)
3. Modificar configuração de scoring
4. Executar scoring nos dados históricos
5. Calcular taxa_conversao_top_20
6. Keep/discard/crash
7. Logar resultado
8. Repetir

## Autonomia
Nível: FULL
Parar: interrupção manual
```

### Resultado esperado (8h de execução)

```tsv
experiment_id	conversion_top20	precision	recall	status	description	timestamp
exp_001	0.34	0.41	0.68	keep	baseline - pesos atuais	2026-03-18T22:00
exp_002	0.36	0.43	0.65	keep	aumentar peso engajamento email 2x	2026-03-18T22:02
exp_003	0.33	0.39	0.70	discard	remover critério de cargo	2026-03-18T22:04
exp_004	0.37	0.44	0.64	keep	adicionar decay exponencial 30 dias	2026-03-18T22:06
exp_005	0.37	0.44	0.63	discard	decay 15 dias (muito agressivo)	2026-03-18T22:08
...
exp_240	0.48	0.55	0.71	keep	combo: decay 25d + engaj 3x + evento recente	2026-03-19T06:00
```

**Resultado:** De 34% para 48% de taxa de conversão no top 20% — 240 experimentos em uma noite.

---

## Exemplo 2: A/B Testing Autônomo de Subject Lines

### Configuração

```
MÉTRICA: taxa_abertura (open rate)
ESCOPO MODIFICÁVEL: subject line, preview text
ESCOPO IMUTÁVEL: corpo do email, lista de destinatários, horário de envio
BUDGET: 30 minutos (tempo para coletar dados iniciais de abertura)
```

### Log de experimentos

```tsv
experiment_id	open_rate	sample_size	status	description
email_001	0.22	500	keep	baseline: "Descubra o Método CIS"
email_002	0.25	500	keep	personalização: "{nome}, descubra o Método CIS"
email_003	0.19	500	discard	urgência: "ÚLTIMA CHANCE - Método CIS"
email_004	0.27	500	keep	pergunta: "{nome}, você já ouviu falar do Método CIS?"
email_005	0.26	500	discard	emoji: "🔥 {nome}, Método CIS te espera"
email_006	0.29	500	keep	social proof: "{nome}, 50 mil alunos já transformaram suas vidas"
```

---

## Exemplo 3: Template de program.md Genérico

```markdown
# [NOME DO AGENTE] — Program v1.0

## 🎯 Missão
[Uma frase que define o que o agente otimiza]

## 📋 Setup
- [ ] Branch: experiment/[tag]-[YYYY-MM-DD]
- [ ] Dados/ambiente verificados
- [ ] results.tsv inicializado
- [ ] Baseline executado e registrado

## 🔒 Escopo
### ✅ PODE modificar
- [item 1]
- [item 2]

### ⛔ NÃO PODE modificar
- [item 1 — motivo]
- [item 2 — motivo]

### 🚫 NÃO PODE instalar/criar
- [restrições de dependências ou novos recursos]

## 📏 Métrica de Sucesso
- **Nome:** [nome_da_metrica]
- **Fórmula:** [como é calculada]
- **Direção:** [↑ maior = melhor | ↓ menor = melhor]
- **Fonte:** [de onde vem o dado]
- **Avaliação:** [função/query que calcula — IMUTÁVEL]

## ⏱️ Budget
- Tempo por experimento: [X] minutos
- Timeout (kill): [2X] minutos
- Throughput estimado: [Y] experimentos/hora

## 📋 Logging (results.tsv)
```
experiment_id	metric_value	resource_cost	status	description	timestamp
```

## 🔄 Loop
1. Analisar estado atual e resultados anteriores
2. Formular hipótese baseada nos padrões observados
3. Implementar mudança (APENAS no escopo permitido)
4. `git commit -m "experiment: [descrição curta]"`
5. Executar com timeout
6. Extrair métrica do output
7. Decidir:
   - `metric < best` → KEEP (avançar baseline)
   - `metric >= best` → DISCARD (git revert)
   - `crash` → diagnosticar, fix simples ou skip
8. Registrar em results.tsv
9. Voltar ao passo 1

## 🤖 Autonomia
- **Nível:** FULL
- **Parar quando:** Interrupção manual APENAS
- **Se ficar sem ideias:**
  1. Combinar mudanças de experimentos keep anteriores
  2. Tentar o oposto do que falhou
  3. Mudanças mais radicais
  4. Re-ler o escopo para ângulos não explorados
- **NUNCA** parar para perguntar "devo continuar?"
```

---

## Exemplo 4: Mapeamento autoresearch → Domínios de Negócio

| Conceito Karpathy | ML Original | Vendas | Marketing | Operações |
|-------------------|-------------|--------|-----------|-----------|
| `train.py` | Modelo neural | Config de scoring | Template de email | Regras de SLA |
| `prepare.py` | Avaliação BPB | Query de conversão | Métricas de abertura | Query de tempo resolução |
| `val_bpb` | Bits per byte | Taxa conversão | Open rate | Tempo médio resolução |
| `5 min budget` | Treinamento | Cálculo scoring | Envio + coleta | Simulação |
| `git commit` | Snapshot do modelo | Snapshot das regras | Snapshot do template | Snapshot do SLA |
| `keep/discard` | Mantém/reverte modelo | Mantém/reverte scoring | Mantém/reverte template | Mantém/reverte regra |
| `results.tsv` | Log de experimentos | Log de scoring | Log de campanhas | Log de SLA |
| `NEVER STOP` | Pesquisa autônoma | Otimização contínua | Testing contínuo | Tuning contínuo |

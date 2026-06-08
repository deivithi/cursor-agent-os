# 📚 Thariq Playbook — 9 Tipos + 9 Dicas Anthropic

> Fonte: [Thariq (Anthropic), 17/03/2026](https://x.com/trq212/status/2033949937936085378)
> A Anthropic roda centenas de skills em produção. Estas são as lições aprendidas.

---

## 9 Tipos de Skills

A melhor skill se encaixa claramente em UMA categoria. Abraçar várias = skill confusa.

| Categoria | O que faz | Exemplos |
|---|---|---|
| **Library & API Reference** | Gotchas, edge cases, uso de libs internas/externas | billing-lib, platform-cli, frontend-design |
| **Product Verification** | Conduz fluxos UI com playwright/tmux, verifica estado a cada passo | signup-flow-driver, checkout-verifier |
| **Data Fetching & Analysis** | Conecta a stacks de dados/monitoramento com credenciais e queries | funnel-query, cohort-compare, grafana |
| **Business Automation** | Workflows multi-tool em um comando | standup-post, create-ticket, weekly-recap |
| **Scaffolding & Templates** | Boilerplate de framework com requisitos em linguagem natural | new-workflow, new-migration, create-app |
| **Code Quality & Review** | Enforce qualidade, review adversarial, testing practices | adversarial-review, code-style, testing |
| **CI/CD & Deployment** | Fetch, push, deploy com safety checks | babysit-pr, deploy-service, cherry-pick-prod |
| **Runbooks** | Sintoma → investigação multi-tool → relatório estruturado | service-debugging, oncall-runner |
| **Infrastructure Ops** | Manutenção rotineira com guardrails para ações destrutivas | orphan-cleanup, dependency-management |

### Como escolher o tipo:

```
Qual o objetivo principal?
├── Empacotar conhecimento de uma lib/API? → Library & API Reference
├── Testar fluxos de UI automaticamente? → Product Verification
├── Consultar dados/métricas? → Data Fetching & Analysis
├── Automatizar processo de negócio? → Business Automation
├── Gerar código padronizado? → Scaffolding & Templates
├── Revisar/melhorar código? → Code Quality & Review
├── Deploy com segurança? → CI/CD & Deployment
├── Investigar problemas/incidentes? → Runbooks
└── Manutenção de infraestrutura? → Infrastructure Ops
```

---

## 9 Dicas de Authoring

### 1. Não diga o óbvio

Claude já sabe muito sobre código. Foque em informação que empurra Claude para fora do seu modo padrão de pensar. A skill frontend-design funciona porque corrige a estética default do Claude (fonte Inter, gradientes roxos), não porque explica o que é CSS.

**Regra:** Antes de adicionar uma instrução, pergunte: *"O agente já sabe fazer isso sem minha instrução?"* Se sim → NÃO adicione.

### 2. Construa uma seção Gotchas

O conteúdo de maior valor em qualquer skill. Construa iterativamente a partir de pontos de falha. Adicione uma linha cada vez que Claude tropeçar em algo.

```
Dia 1: gotchas tem 1 entrada
Mês 3: gotchas tem 10 entradas
→ Essa é a parte mais valiosa da skill
```

### 3. Use o File System e Progressive Disclosure

Uma skill é uma PASTA, não apenas um markdown. Pense no file system inteiro como context engineering. SKILL.md é o hub (~30 linhas ideais, máx 250); arquivos spoke fazem o trabalho.

```
queue-debugging/
  SKILL.md          ← hub: sintoma → tabela de lookup de arquivo
  stuck-jobs.md
  dead-letters.md
  retry-storms.md
  consumer-lag.md
```

Diga ao Claude quais arquivos existem na skill e ele os lerá nos momentos apropriados.

### 4. Evite railroading

Não escreva scripts passo-a-passo rígidos. Dê ao Claude a informação necessária com flexibilidade para adaptar.

```
❌ Prescritivo demais:
"Step 1: Run git log to find the commit.
 Step 2: Run git cherry-pick <hash>.
 Step 3: If there are conflicts, run git status..."

✅ Melhor:
"Cherry-pick o commit em um branch limpo. Resolva conflitos
preservando a intenção. Se não der para aplicar limpo, explique por quê."
```

### 5. O campo Description é para o modelo

Quando Claude inicia uma sessão, ele constrói uma lista de toda skill disponível com sua description. É isso que Claude escaneia para decidir "tem uma skill para esse pedido?" A description é um TRIGGER, não um resumo.

```yaml
❌ Ruim: description: Uma ferramenta abrangente para monitorar status de PRs
✅ Bom:  description: Monitora PR até merge. Trigger: 'babysit', 'watch CI', 'garanta que isso entre'
```

### 6. Pense no Setup

Algumas skills precisam de contexto do usuário na primeira execução. Armazene info de setup em um `config.json` no diretório da skill. Se o config não existir, pergunte ao usuário.

**Padrão:** bash inline que lê config.json. Se arquivo não existe → output "NOT_CONFIGURED" → pedir valores ao usuário → salvar em config.json.

### 7. Memória e Armazenamento

Skills podem armazenar dados para continuidade entre execuções. Use `${CLAUDE_PLUGIN_DATA}` como pasta estável — dados no diretório da skill podem ser deletados em upgrade.

Opções: text logs append-only, JSON files, ou até SQLite. Uma skill standup-post poderia manter `standups.log` para Claude comparar com ontem.

### 8. Armazene Scripts e Gere Código

Dê ao Claude código, não apenas instruções. Inclua libraries auxiliares para que Claude gaste seus turnos em composição, não reconstruindo boilerplate.

**Exemplo:** Skill de data science com `lib/signups.py` contendo `fetch(day)`, `by_referrer(df)`, `by_landing_page(df)`. Claude gera scripts que compõem essas funções.

### 9. Hooks On-Demand

Skills podem incluir hooks que ativam apenas quando a skill é chamada e duram pela sessão. Use para guardrails opinativos que você não quer rodando o tempo todo.

**Exemplos:**
- `/careful` — bloqueia rm -rf, DROP TABLE, force-push via PreToolUse matcher no Bash
- `/freeze` — bloqueia Edit/Write fora de um diretório específico

---

## Distribuição

| Abordagem | Quando usar |
|---|---|
| Check no repo (`.claude/skills/`) | Times pequenos, poucos repos |
| Plugin marketplace | Escala melhor, times decidem o que instalar |

**Medir skills:** Use PreToolUse hook para logar uso. Encontre skills populares ou sub-utilizadas.

**Compor skills:** Referencie outras skills pelo nome na sua skill. Claude as invocará se instaladas.

---

## Fonte

[@trq212, 17/03/2026](https://x.com/trq212/status/2033949937936085378) — Anthropic internal playbook

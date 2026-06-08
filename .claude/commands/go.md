---
description: "Ponto de entrada único — auto-detecta intenção e roteia para a skill certa"
---

# /go — Router Inteligente

O usuário descreveu o que quer fazer: $ARGUMENTS

## Sua Tarefa

Analise a intenção do usuário e execute a ação usando a skill mais adequada. **NÃO peça esclarecimento** — infira e execute.

## Contrato TaskEnvelope (tarefas não triviais)

Antes de rotear ou executar pedidos com **3+ passos**, **vários artefatos**, **impacto externo** ou **pesquisa além do repo**, emita um bloco JSON com o schema em [`.claude/references/task-envelope.md`](../references/task-envelope.md) (`intent`, `artifacts_expected`, `acceptance_criteria`, `risks`, `step_budget`, `sources_policy`, opcional `moa_lite`).

Se o utilizador já definiu plano em `tasks/todo.md` com critérios checkáveis explícitos, podes **omitir** o JSON desde que declares que o plano cobre o envelope.

## MoA-lite (pesquisa / decisão de alto risco)

Quando `moa_lite: true` no envelope, ou quando a intenção for pesquisa ampla, compliance ou decisão com consequências:

1. **Gerar** resposta ou artefato.
2. **Reviewer:** passagem curta só para falhas, lacunas e conflitos entre fontes (usar espírito de `/code-review` ou reviewer em `agent-skill-patterns`).
3. **Fusão:** resposta final com `## Conflitos resolvidos` e `## Não verificado`.

## Mapa de Roteamento

Analise as palavras-chave e contexto para rotear:

### 🔍 Exploração & Pesquisa
- **Conexoes entre modulos, dependencias, impacto de mudanca, grafo de codigo, o que depende de X** → Use graphify MCP tools (`query_graph`, `get_neighbors`, `shortest_path`, `god_nodes`)
- **Explorar codigo, entender sistema, como funciona** → Use `/smart-explore`
- **Investigar bug multi-arquivo, traçar fluxo de dados** → Use `/iterative-retrieval`
- **Deep research com citações, relatório estruturado, parada por orçamento** → Use `/deep-research`
- **Relatório PDF + deck PPTX + landing no mesmo roteiro com QA** → Use `/artifact-factory`
- **Pesquisa científica, análise de dados, ML, estatística** → Use `/science`
- **Paper acadêmico, arXiv, estado da arte** → Use alphaXiv MCP tools
- **Documentação de biblioteca, API de framework** → Use Context7 MCP (`resolve-library-id` → `get-library-docs`)

### 🏗️ Planejamento & Execução
- **Planejar, arquitetar, decidir antes de fazer** → Use `/make-plan`
- **Executar tarefa seguindo plano** → Use `/do`
- **Criar feature, implementar, codar** → Use `/do` (com `/test-driven-development` se envolver código novo)

### 🎨 Frontend & Design
- **Criar UI, dashboard, componente, página web** → Use `/ui-forge`
- **Clonar site, inspirar em URL, enhance de UI existente** → Use `/ui-forge`
- **Landing page, página de vendas, lead capture** → Use `/landing-page-generator`
- **Apresentação, slides, pitch deck** → Use `/frontend-slides`

### 📱 App Store & Mobile
- **App Store Connect, testflight, build, submit, publish, ios, macos, visionos, signing, aso, metadata, review status, crashes** → Use `/asc`

### 🔒 Segurança & Compliance
- **Segurança, vulnerabilidade, OWASP, hardening** → Use `/cyber`
- **LGPD, compliance, auditoria de segurança** → Use `/cyber`

### 📊 Negócio Febracis
- **Leads, sanitização, duplicados, atribuição** → Use `/lead-audit`
- **Comissões, pagamentos, validação de cálculo** → Use `/commission-audit`
- **Incidente, erro, investigação** → Use `/runbook`

### ⚙️ Automação & Deploy
- **n8n, workflow, automação** → Use `/n8n`
- **Deploy, produção, staging** → Use `/deploy-checklist` depois `/cicd`
- **Google Drive, Sheets, Docs, Calendar** → Use `/gws`
- **Testar página, scraping, preencher form** → Use `/browser`
- **Integrar API externa** → Use `/api-forge`

### 📏 Qualidade & Avaliação
- **Revisar código, quality gate** → Use `/code-review` com `/simplify`
- **Avaliar skill, medir qualidade, criar judge** → Use `/evals`
- **Saúde das skills, manutenção** → Use `/skill-health`

### 🔄 Automação Avançada & Scheduling
- **Agendar tarefa, automação recorrente, cron** → Use `/automations`
- **Processar CSV, XLSX, batch, planilha em lote** → Use `/batch`
- **Otimizar skills, loop autônomo, Karpathy** → Use `/ouroboros`

### 💾 Memória & Sessão
- **Lembrar, buscar memória, o que fizemos** → Use `/mem`
- **Salvar observações, fim de sessão** → Use `/recap`
- **Continuar sessão anterior, retomar trabalho** → Use `/resume`
- **Ramificar, testar abordagem alternativa** → Use `/fork`
- **Mudar perfil de contexto, trocar foco** → Use `/profile`

### 📦 Skills & Gestão
- **Instalar skill, baixar skill** → Use `/skill-install`
- **Remover skill** → Use `/skill-uninstall`

## Regras

1. **EXECUTE imediatamente** — não liste opções, não peça confirmação
2. Se a intenção mapeia para múltiplas skills, **combine-as** na ordem lógica
3. Se a intenção é ambígua entre 2 skills, **escolha a mais provável** e mencione a alternativa em 1 frase
4. Se nenhuma skill se aplica, **execute diretamente** sem routing
5. Preserve o contexto original do usuário ao chamar a skill
6. Entregas longas: devem refletir **critérios de aceite**, **verificação** e **incerteza explícita** onde aplicável (alinhado a `CLAUDE.md`)
7. **Performance:** seguir [`.claude/references/performance-context-policy.md`](../references/performance-context-policy.md) (paralelismo, higiene de contexto)

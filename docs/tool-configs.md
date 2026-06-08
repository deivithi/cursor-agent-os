# 🔧 Tool Configurations — MCPs, CLIs & Platforms

---

## 🧠 Context7 MCP — Documentação Atualizada de Bibliotecas

**MCP:** `context7` (HTTP remoto, sem API key necessária)
**Endpoint:** `https://mcp.context7.com/mcp`

### ⚡ Ativação Automática

Quando precisar de **documentação de bibliotecas, exemplos de API, setup de frameworks**, o assistente **DEVE usar Context7** para injetar documentação real e atualizada no contexto, evitando alucinações.

| Tool | Quando Usar |
|------|-------------|
| `resolve-library-id` | Resolver ID interno de uma lib pelo nome (react, nextjs, supabase-js) |
| `get-library-docs` | Obter documentação atualizada, exemplos e API reference da lib |

> **Regra:** Sempre usar Context7 quando precisar de code generation, setup, configuração ou API docs de qualquer biblioteca.

---

## 🔍 Tavily MCP — AI Search (⚠️ placeholder — substituir API key)

Tools: `tavily-search` (busca web), `tavily-extract` (dados estruturados), `tavily-map` (sitemap), `tavily-crawl` (crawler).

---

## 🕸️ Memory MCP — Grafo de Conhecimento (`memory.jsonl`, append-only)

Tools: `create_entities`, `create_relations`, `search_nodes`, `read_graph`, `add_observations`. Complementa memória baseada em arquivo com relações semânticas.

---

## 🐛 Sentry MCP — Error Tracking (⚠️ placeholder — ativar quando Aria em produção)

Tools: `search_issues`, `search_events`, traces. Pacote: `@sentry/mcp-server`.

---

## 💬 Slack MCP — Comunicação (⚠️ placeholder — ativar quando necessário)

Tools: `slack_post_message`, `slack_get_channel_history`, `slack_reply_to_thread`, `slack_list_channels`, `slack_get_users`.

---

## 📚 alphaXiv MCP Server — Acesso a Papers Acadêmicos

**MCP:** `alphaxiv` (SSE remoto, OAuth 2.0)
**Endpoint:** `https://api.alphaxiv.org/mcp/v1`
**Cobertura:** 2.4M+ papers do arXiv

### ⚡ Ativação Automática

Quando o usuário mencionar **paper, artigo acadêmico, arXiv, pesquisa científica, revisão de literatura, estado da arte, fundamentação, citação, referência acadêmica**, o assistente **DEVE usar as tools do alphaXiv MCP**:

| Tool | Quando Usar |
|------|-------------|
| `embedding_similarity_search` | Buscar papers por conceito/descrição em linguagem natural |
| `full_text_papers_search` | Buscar por keywords, nomes de métodos, benchmarks, autores |
| `agentic_paper_retrieval` | Pesquisa exaustiva autônoma multi-turn (Beta) |
| `get_paper_content` | Ler o conteúdo completo de um paper (texto ou relatório IA) |
| `answer_pdf_queries` | Responder perguntas específicas sobre um paper |
| `read_files_from_github_repository` | Ler código de repositórios associados a papers |

---

## 📎 Google Workspace CLI (gws v0.16.0)

**Instalado:** v0.16.0 (Rust nativo, 20.5K stars)
**Config:** `~/.config/gws/`
**Comando:** `/gws <operação>` ou `gws <serviço> <recurso> <método>` direto via Bash

### ⚡ Ativação Automática

Quando o usuário mencionar **Google Drive, Sheets, Docs, Slides, Tasks, Meet, Forms, Keep, People, Admin**, ou qualquer operação com planilhas, documentos, arquivos Google, agenda, o assistente **DEVE usar `gws`** via Bash:

```bash
gws drive files list --params '{"pageSize": 10}' --format table
gws sheets spreadsheets.values get --params '{"spreadsheetId":"ID","range":"A1:Z100"}' --format csv
gws schema <service.resource.method>   # Descobrir parâmetros
```

> **Regra:** Para Gmail e Calendar, preferir MCPs nativos (mais integrados). Para Drive, Sheets, Docs, Tasks, Slides, Chat, Meet, Forms, Keep, People e Admin, usar `gws`.

---

## 🌐 agent-browser (Vercel Labs) — Automação Web Headless

**Instalado:** v0.20.11 (Rust nativo, 7MB)
**Chrome:** 146.0.7680.80 em `~/.agent-browser/browsers/`
**Comando:** `/browser <tarefa>` ou uso direto via Bash

### ⚡ Ativação Automática

Quando o usuário pedir para **testar uma página**, **scraping**, **preencher formulários**, **validar UI**, **screenshot**, **automação web**, **E2E test**, ou qualquer interação com browser, o assistente **DEVE usar `agent-browser`** via Bash:

```bash
agent-browser open "<url>"     # Abrir
agent-browser snapshot -i      # Capturar elementos interativos
agent-browser click @e1        # Interagir por referência
agent-browser screenshot ./x.png  # Screenshot
agent-browser close            # Fechar
```

### 🔑 Regras de Uso

1. **Sempre snapshot antes de interagir** — Nunca clicar/preencher sem ter os refs
2. **Usar `-i` flag** — Snapshot compacto (só interativos) para economizar tokens
3. **Re-snapshot após ações** — A página muda, os refs mudam
4. **Sessões para fluxos multi-step** — `--session nome` mantém estado
5. **Nunca senhas em plain text** — Usar `agent-browser auth save` para credenciais
6. **Fechar ao terminar** — `agent-browser close`

---

## ⚙️ n8n Automation Platform (v2.12.3 + n8n-mcp 21 tools)

**Instalado:** n8n v2.12.3 (npm global, PM2 auto-start)
**MCP:** n8n-mcp (npm global, 21 tools — 7 doc + 14 gestão)
**URL:** http://localhost:5678
**Comando:** `/n8n <tarefa>` ou ativação automática

### ⚡ Ativação Automática

Quando o usuário mencionar **n8n, workflow, automação n8n, criar workflow, webhook n8n, schedule n8n, node n8n**, o assistente **DEVE automaticamente**:

1. Ativar a skill `/n8n` (coordenador)
2. Executar o check de pré-voo (n8n rodando? MCP tools disponíveis?)
3. Seguir o fluxo da skill coordenadora

### 🔑 Regras Críticas

1. **SEMPRE usar MCP tools** — nunca curl/API manual para gerenciar workflows
2. **NUNCA criar workflow one-shot** — iterar: criar → validar → editar → validar → ativar
3. **Dois formatos de nodeType** — `nodes-base.x` (search/validate) vs `n8n-nodes-base.x` (workflow)
4. **Credenciais são configuradas na UI** — sempre listar quais nodes precisam de credencial
5. **Se MCP tools indisponíveis** — PARAR e pedir para reiniciar Claude Code
6. **HARDENING OBRIGATÓRIO** — Após criar ou modificar qualquer workflow, executar `/n8n-hardening` automaticamente. Zero workflows em produção sem auditoria de resiliência
7. **PREPROCESSAMENTO DE DOCS** — Quando workflow processar emails, PDFs ou documentos antes de LLMs, usar `/markitdown` ou node Code com strip HTML para economizar tokens e melhorar qualidade

### 🔗 Skills Integradas (9 sub-skills)

| Skill | Tipo | Ativação |
|-------|------|----------|
| `/n8n-hardening` | 🛡️ Reviewer (Severity Scoring) | **Automática** após criar/modificar workflow |
| `/markitdown` | 🔧 Tool Wrapper | **Automática** quando workflow processa documentos → LLM |
| `n8n-code-javascript` | 📝 Code JS | Quando escrever Code nodes em JS |
| `n8n-code-python` | 🐍 Code Python | Quando escrever Code nodes em Python |
| `n8n-expression-syntax` | 🔤 Expressões | Quando usar `{{ }}` syntax |
| `n8n-mcp-tools-expert` | 🔧 MCP Expert | Quando usar n8n-mcp tools |
| `n8n-node-configuration` | ⚙️ Config | Quando configurar nodes |
| `n8n-validation-expert` | ✅ Validação | Quando interpretar erros de validação |
| `n8n-workflow-patterns` | 📐 Patterns | Quando projetar arquitetura de workflow |

---

## 📄 MarkItDown (Microsoft) — Conversão de Documentos para LLMs

**Instalado:** markitdown v0.1.5 + markitdown-mcp v0.0.1a4
**MCP:** `markitdown` (stdio, configurado global + projeto)
**Comando:** `/markitdown <arquivo>` ou ativação automática

### ⚡ Ativação Automática

Quando o usuário mencionar **converter documento, extrair texto, PDF para markdown, preprocessar para LLM, ingerir documento**, ou quando qualquer pipeline precisar transformar arquivos em texto para LLMs, o assistente **DEVE usar MarkItDown**:

| Método | Quando Usar |
|--------|-------------|
| `markitdown arquivo.pdf` (CLI) | Conversão rápida via terminal |
| `convert_to_markdown(uri)` (MCP) | Dentro de conversas Claude Code |
| `MarkItDown().convert("file")` (Python) | Em scripts, n8n Code nodes, pipelines |

### 📁 Formatos Suportados

PDF, PPTX, DOCX, XLSX, HTML, CSV, JSON, XML, imagens (OCR), áudio (transcrição), ZIP, EPUB, YouTube URLs

---

## 🤖 NotebookLM CLI (notebooklm-py v0.3.4)

**Instalado e autenticado.** Skill disponível no Claude Code.

### ⚠️ Encoding Windows
Sempre usar `PYTHONIOENCODING=utf-8` em comandos notebooklm no bash:
```bash
export PYTHONIOENCODING=utf-8 && notebooklm list
```
> A variável de ambiente `PYTHONIOENCODING=utf-8` já está definida no perfil do usuário Windows — sessões novas de terminal a herdam automaticamente.

### Comandos mais usados
```bash
notebooklm list                          # listar notebooks
notebooklm create "Título"               # criar notebook
notebooklm use <id>                      # selecionar notebook
notebooklm source add "https://..."      # adicionar fonte
notebooklm ask "pergunta"                # chat com as fontes
notebooklm generate audio "instruções"  # gerar podcast
notebooklm generate report --format study-guide
notebooklm download audio ./saida.mp3
```

---

## 📊 CodexBar (opcional) — quotas Cursor / Codex / Claude / outros

**Não é dependência deste repositório** — ferramenta **opcional** para quem quiser ver na barra de menus (macOS) limites de uso, resets e histórico de custo de vários provedores.

| Plataforma | O que usar |
|------------|------------|
| **macOS 14+** | App oficial: [steipete/CodexBar](https://github.com/steipete/CodexBar) — releases (ex.: [v0.19.0](https://github.com/steipete/CodexBar/releases/tag/v0.19.0)) ou `brew install --cask steipete/tap/codexbar` |
| **Linux** | Apenas **CLI** (`codexbar`): ver README do repositório e artefato `CodexBarCLI-*-linux-*.tar.gz` nos releases |
| **Windows** | O app `.app` oficial **não** roda no Windows; alternativa comunitária: [Win-CodexBar](https://github.com/Finesssee/Win-CodexBar), ou usar o **uso da conta no Cursor** / dashboards dos provedores |

**Notas:** em macOS, vários provedores usam cookies de browser ou CLI/OAuth — seguir [privacidade e permissões](https://github.com/steipete/CodexBar/blob/main/README.md) do projeto oficial.

---

## Malha de ferramentas (primário / fallback) — paridade “multi-tool”

Objetivo: uma linha por **categoria** com caminho principal e alternativa. O router `/go` e o TaskEnvelope (`sources_policy`) devem respeitar isto.

| Categoria | Primário | Fallback | Notas |
|-----------|----------|----------|-------|
| **Busca web / crawl** | Firecrawl skill (quando configurada) ou MCP de pesquisa do projeto | `WebFetch` / fetch manual de URLs; Tavily MCP se ativo | Evitar afirmações fortes sem URL. |
| **Docs de biblioteca** | Context7 MCP | Documentação oficial no browser + snapshot | |
| **Browser / E2E** | `cursor-ide-browser` MCP (Cursor) | `agent-browser` / `/browser` | Ver secção agent-browser acima. |
| **Google Drive, Sheets, Docs, Slides** | `gws` CLI | MCP Google Workspace se disponível | Gmail/Calendar: MCP conforme regras do workspace. |
| **Email (Gmail)** | MCP `project-0-VS CODE-google_workspace` | — | Erro tool: script login em `.cursor/MCP_GMAIL_SETUP.md`. |
| **Automação** | n8n MCP + `/n8n` | Webhooks manuais só em último caso | |
| **Docs → Markdown** | MarkItDown MCP / `/markitdown` | Leitura manual + resumo | |
| **Papers** | alphaXiv MCP | `/science` + skills científicas | |
| **Mídia (imagem/vídeo/áudio)** | Skills/scripts OpenAI ou fornecedor já configurado no repo | — | Depende de API keys locais. |
| **Notebook / síntese longa** | NotebookLM CLI | Markdown local + deep-research skill | |

### Opcional: `@genspark/cli` (`gsk`)

Pacote npm oficial da plataforma Genspark ([`@genspark/cli`](https://www.npmjs.com/package/@genspark/cli)): agrega dezenas de capacidades via **Tool API** (JSON para pipelines). **Não** é dependência deste workspace.

- Usar **apenas** se TOS, privacidade e custo forem aceitáveis.
- Tratar como **adapter externo** (terminal ou script), não acoplar o `/go` a comandos `gsk`.
- Login: `gsk login` (browser); ver documentação do pacote para quotas.

---

## 🛒 Shopify AI Toolkit (Plugin v1.0.0)

**Instalado:** Plugin `shopify-plugin@shopify-ai-toolkit` (auto-update)
**Fonte:** [Shopify/shopify-ai-toolkit](https://github.com/Shopify/shopify-ai-toolkit) (MIT)
**Docs:** [shopify.dev/docs/apps/build/ai-toolkit](https://shopify.dev/docs/apps/build/ai-toolkit)

### ⚡ Ativação Automática

Quando o usuário mencionar **shopify, loja, e-commerce, storefront, produtos, catálogo, checkout, inventário, hydrogen, liquid, tema shopify, app shopify**, o assistente **DEVE usar as skills do Shopify AI Toolkit** que já estão carregadas via plugin.

### 🎯 16 Skills Disponíveis

| Skill | Função |
|-------|--------|
| `shopify-admin` | GraphQL Admin API — dados e operações da loja |
| `shopify-admin-execution` | ⚡ **Executa operações reais** (produtos, inventário, config) |
| `shopify-storefront-graphql` | Storefront API — experiências de compra customizadas |
| `shopify-functions` | Lógica serverless de checkout (descontos, shipping, payments) |
| `shopify-liquid` | Desenvolvimento de temas Liquid |
| `shopify-hydrogen` | Framework headless React para storefronts |
| `shopify-customer` | Gestão de contas e dados de clientes |
| `shopify-custom-data` | Metafields e metaobjects |

### 🔑 Regras de Uso

1. **`shopify-admin-execution` é destrutivo** — confirmar com usuário antes de executar operações que modifiquem dados da loja
2. **Plugin auto-atualiza** — novas skills aparecem automaticamente após restart
3. **Sem autenticação no plugin** — autenticação é feita via Shopify CLI (`npx shopify auth login`)
4. **Validação em tempo real** — queries GraphQL são validadas contra schemas atuais (zero alucinação)

### 📋 Setup de Loja (quando necessário)

```bash
npx shopify auth login          # Autenticar na loja
npx shopify app dev             # Iniciar dev server de app
npx shopify theme dev           # Preview de tema
```

---

---

## 🕸️ Graphify — Knowledge Graph Estrutural do Codebase

**Instalado:** graphifyy v0.4.1 (venv `~/.graphify-env/`, Python 3.12)
**MCP:** `graphify` (stdio, configurado em `.mcp.json`)
**Graph:** `graphify-out/graph.json` (8.889 nos, 14.858 arestas, 246 comunidades)
**Rebuild:** Automatico via hook Stop (incremental, background)

### Ativacao Automatica

Quando o contexto envolver **conexoes entre modulos**, **dependencias de codigo**, **impacto de mudanca**, **arquitetura do projeto**, o assistente **DEVE usar as MCP tools do graphify** antes de ler arquivos individuais:

| Tool | Quando Usar |
|------|-------------|
| `query_graph` | Busca por pergunta natural ("o que conecta auth a database?") |
| `get_node` | Detalhes de um no especifico |
| `get_neighbors` | Dependencias diretas de um modulo |
| `shortest_path` | Caminho entre dois conceitos |
| `god_nodes` | Nos mais conectados (core do projeto) |
| `get_community` | Todos os nos de um cluster |
| `graph_stats` | Resumo do grafo (nos, arestas, comunidades) |

> **Regra:** Consultar o grafo PRIMEIRO para identificar arquivos relevantes, depois Read so os necessarios. Economia de 71.5x tokens vs ler tudo.

---

### Indice deste documento

Ficheiro canónico: **`.claude/docs/tool-configs.md`**. Se existir atalho em `docs/tool-configs.md` na raiz do repositório, deve apontar para aqui.

# Skill Inventory Audit — Cursor

generated: 2026-05-25T15:34:33.535Z
platform: cursor
months: 3
skills: 312 discovered, 312 considered
description_chars: 81271
rendered_line_chars: 131118
transcript_files_scanned: 28
mirror_pairs_user_workspace: 0

## Executive Summary

- Inventário total: **312** skills em **2** roots
- Budget simulado (2%): **3,993** / **4,000** tokens (99.8%)
- ⚠️ **228** skills seriam OMITIDAS por falta de budget
- ⚠️ **312** descriptions truncadas (81,271 chars perdidos)
- Duplicatas por nome: **9** grupos
- Espelhos user↔workspace: **0** (candidatos a remoção imediata)
- Skills com uso em transcripts: **4** (top 30 abaixo)

## Skill Budget

model: composer-default
context_tokens: 200,000 (fallback:cursor-200k)
2%_budget_tokens: 4,000
token_rule: ceil(utf8_bytes / 4)
unbudgeted_full_tokens: 33,088
minimum_no_description_tokens: 12,527
budgeted_tokens_used: 3,993
used_of_budget: 99.8%
used_of_context: 2.0%
remaining_budget_tokens: 7
included_skills_after_budget: 84
omitted_skills_after_budget: 228
truncated_description_chars: 81,271

## Mirror Pairs (user ↔ workspace) — Quick Wins

- none

## Top Used Skills (transcripts)

- lead-audit: total=4 ($=0, reads=4, text=0, transcript=0); cursor-user
- cursor-public:wrangler: total=3 ($=3, reads=0, text=0, transcript=0); cursor-plugin
- cursor-public:release: total=2 ($=2, reads=0, text=0, transcript=0); cursor-plugin
- cursor-public:firecrawl: total=1 ($=0, reads=0, text=1, transcript=0); cursor-plugin

## Description Candidates (shorten)

- cursor-public:firecrawl (cursor-plugin)
  chars: desc=871, line=1044
  current: Firecrawl handles all web operations with superior accuracy, speed, and LLM-optimized output. Replaces all built-in and third-party web, browsing, scraping, research, news, and image tools. USE FIRECR…
  suggested: firecrawl: executar workflow documentado.
- minimax-pdf (cursor-user)
  chars: desc=856, line=940
  current: Use this skill when visual quality and design identity matter for a PDF. CREATE (generate from scratch): "make a PDF", "generate a report", "write a proposal", "create a resume", "beautiful PDF", "pro…
  suggested: minimax pdf: criar, validar, entregar.
- cursor-public:figma-generate-design (cursor-plugin)
  chars: desc=851, line=1044
  current: Use this skill alongside figma-use when the task involves translating an application page, view, or multi-section layout into Figma. Triggers: 'write to Figma', 'create in Figma from code', 'push page…
  suggested: n8n: criar, validar, entregar.
- cursor-public:mongodb-natural-language-querying (cursor-plugin)
  chars: desc=826, line=1045
  current: Generate read-only MongoDB queries (find) or aggregation pipelines using natural language, with collection schema context and sample documents. Use this skill whenever the user asks to write, create, …
  suggested: mongodb natural language querying: criar, validar, entregar.
- cursor-public:figma-generate-diagram (cursor-plugin)
  chars: desc=778, line=973
  current: MANDATORY prerequisite — load this skill BEFORE every `generate_diagram` tool call. NEVER call `generate_diagram` directly without loading this skill first. Trigger whenever the user asks to create, g…
  suggested: deploy: criar, validar, entregar.
- cursor-public:chat-sdk (cursor-plugin)
  chars: desc=776, line=953
  current: Build multi-platform chat bots with Chat SDK (`chat` npm package). Use when developers want to (1) Build a Slack, Teams, Google Chat, Discord, Telegram, GitHub, Linear, or WhatsApp bot, (2) Use Chat S…
  suggested: n8n: criar, validar, entregar.
- cursor-public:figma-generate-library (cursor-plugin)
  chars: desc=719, line=914
  current: Build or update a professional-grade design system in Figma from a codebase. Use when the user wants to create variables/tokens, build component libraries, create individual components with proper var…
  suggested: figma generate library: criar, validar, entregar.
- cursor-public:mongodb-search-and-ai (cursor-plugin)
  chars: desc=705, line=900
  current: Guides MongoDB users through implementing and optimizing Atlas Search (full-text), Vector Search (semantic), and Hybrid Search solutions. Use this skill when users need to build search functionality f…
  suggested: mongodb search and ai: criar, validar, entregar.
- cursor-public:shopify-onboarding-merchant (cursor-plugin)
  chars: desc=672, line=886
  current: Set up and connect a Shopify store from your AI assistant. Use when the user wants to: set up my Shopify store, connect my store, install Shopify plugin, get started with Shopify, manage my store, add…
  suggested: shopify onboarding merchant: criar, validar, entregar.
- cursor-public:mongodb-connection (cursor-plugin)
  chars: desc=658, line=847
  current: Optimize MongoDB client connection configuration (pools, timeouts, patterns) for any supported driver language. Use this skill when working/updating/reviewing on functions that instantiate or configur…
  suggested: mongodb connection: debugar, inspecionar, corrigir.
- cursor-public:shopify-use-shopify-cli (cursor-plugin)
  chars: desc=638, line=844
  current: Choose when the user needs **Shopify CLI** to run or fix something now: validate app or extension config on disk (`shopify.app.toml`, `shopify.app.<name>.toml`, `shopify.extension.toml`); run or troub…
  suggested: deploy: auditar, validar, reportar.
- trace-capability (cursor-user)
  chars: desc=638, line=732
  current: AnÃ¡lise contrastiva de trajetÃ³rias e identificaÃ§Ã£o de gaps de capacidade para auto-aprimoramento de agentes. Compara traces de sucesso vs falha lado a lado para isolar deltas especÃ­ficos, nomeia …
  suggested: trace capability: executar workflow documentado.
- minimax-xlsx (cursor-user)
  chars: desc=630, line=716
  current: Open, create, read, analyze, edit, or validate Excel/spreadsheet files (.xlsx, .xlsm, .csv, .tsv). Use when the user asks to create, build, modify, analyze, read, validate, or format any Excel spreads…
  suggested: minimax xlsx: auditar, validar, reportar.
- cursor-public:hugging-face-model-trainer (cursor-plugin)
  chars: desc=629, line=845
  current: This skill should be used when users want to train or fine-tune language models using TRL (Transformer Reinforcement Learning) on Hugging Face Jobs infrastructure. Covers SFT, DPO, GRPO and reward mod…
  suggested: hugging face model trainer: auditar, validar, reportar.
- cursor-public:ai-sdk (cursor-plugin)
  chars: desc=604, line=777
  current: Answer questions about the AI SDK and help build AI-powered features. Use when developers: (1) Ask about AI SDK functions like generateText, streamText, ToolLoopAgent, embed, or tools, (2) Want to bui…
  suggested: deploy: criar, validar, entregar.
- generate-project-plan (cursor-plugin)
  chars: desc=597, line=785
  current: Generate a FigJam project plan board from a PRD plus codebase context. Interactive flow: research → propose sections → per-section deep research → per-section content + block-shape proposal → create F…
  suggested: spec: criar, validar, entregar.
- golang (cursor-user)
  chars: desc=594, line=668
  current: Super especialista senior em Go (Golang) com 30+ anos de experiencia. Dominio profundo de concorrencia (goroutines, channels, context), toolchain oficial, stdlib-first, idiomatic Go, performance, e in…
  suggested: Supabase, n8n, deploy: criar, validar, entregar.
- geo-seo (cursor-user)
  chars: desc=583, line=659
  current: GEO (Generative Engine Optimization) â€” camada executÃ¡vel p/ otimizar sites p/ search IA (ChatGPT, Perplexity, Gemini, Google AIO). Gera llms.txt, valida robots.txt p/ 14+ bots IA, calcula citabilit…
  suggested: geo seo: executar workflow documentado.
- cursor-public:shopify-admin (cursor-plugin)
  chars: desc=569, line=755
  current: Write or explain **Admin GraphQL** queries and mutations for apps and integrations that extend the Shopify admin. Use when the user wants to **understand, design, or generate** the operation itself—ev…
  suggested: shopify admin: auditar, validar, reportar.
- cursor-public:aws-lambda-durable-functions (cursor-plugin)
  chars: desc=568, line=784
  current: Build resilient, long-running, multi-step applications with AWS Lambda durable functions with automatic state persistence, retry logic, and orchestration for long-running executions. Covers the critic…
  suggested: n8n, deploy: criar, validar, entregar.
- cursor-public:zapier-setup (cursor-plugin)
  chars: desc=568, line=744
  current: Set up Zapier MCP and add tools to your AI assistant. Introduces what Zapier can do, walks through authentication, detects your server mode, then branches into the right flow — summary for healthy set…
  suggested: zapier setup: executar workflow documentado.
- cursor-public:hugging-face-jobs (cursor-plugin)
  chars: desc=561, line=759
  current: This skill should be used when users want to run any workload on Hugging Face Jobs infrastructure. Covers UV scripts, Docker-based jobs, hardware selection, cost estimation, authentication with tokens…
  suggested: hugging face jobs: executar workflow documentado.
- cursor-public:ddsetup (cursor-plugin)
  chars: desc=555, line=722
  current: First-time initialization of the Datadog MCP server `plugin-datadog-datadog`. When fulfilling requests that involve Datadog, use MCP tools from `plugin-datadog-datadog` over other methods. If MCP tool…
  suggested: ddsetup: debugar, inspecionar, corrigir.
- cursor-public:mongodb-schema-design (cursor-plugin)
  chars: desc=554, line=749
  current: MongoDB schema design patterns and anti-patterns. Use when designing data models, reviewing schemas, migrating from SQL, or troubleshooting performance issues caused by schema problems. Triggers on "d…
  suggested: Supabase, audit: auditar, validar, reportar.
- cursor-public:figma-use (cursor-plugin)
  chars: desc=546, line=715
  current: **MANDATORY prerequisite** — you MUST invoke this skill BEFORE every `use_figma` tool call. NEVER call `use_figma` directly without loading this skill first. Skipping it causes common, hard-to-debug f…
  suggested: figma use: debugar, inspecionar, corrigir.
- cursor-public:vercel-sandbox (cursor-plugin)
  chars: desc=546, line=735
  current: Run agent-browser + Chrome inside Vercel Sandbox microVMs for browser automation from any Vercel-deployed app. Use when the user needs browser automation in a Vercel app (Next.js, SvelteKit, Nuxt, Rem…
  suggested: deploy: deploy, verificar, monitorar.
- spec-evaluate (cursor-user)
  chars: desc=533, line=621
  current: Gate obrigatorio pre-desenvolvimento: valida specs antes de enviar para execucao. Verifica 12 criterios de completude, identifica gaps e edge cases, faz perguntas estrategicas, gera score de completud…
  suggested: audit, spec: auditar, validar, reportar.
- spec-driven-core (cursor-user)
  chars: desc=531, line=625
  current: NÃºcleo spec-driven (Traycer+): roteamento automÃ¡tico entre Epic, Phases, Plan, Review, Verify e YOLO sem o utilizador invocar slash commands. Use quando houver novo produto, Ã©pico, vÃ¡rias entregas…
  suggested: audit, spec: auditar, validar, reportar.
- supabase-factory (cursor-user)
  chars: desc=499, line=593
  current: Provisiona banco de dados Supabase p/ novas aplicaÃ§Ãµes Febracis. Decide schema vs branch vs projeto novo, aplica padrÃ£o deivithi's Org/febracis-dre, gera migrations c/ RLS. Ativa c/: "criar banco",…
  suggested: Supabase: executar workflow documentado.
- clean-room-engineering (cursor-user)
  chars: desc=494, line=600
  current: Clean Room Engineering com IA: workflow profissional de 7 passos para reimplementar software sem copiar codigo — spec-first, isolamento de contaminacao, provenance verification, framework etico e estr…
  suggested: n8n, audit, spec: auditar, validar, reportar.
- cursor-public:ucp (cursor-plugin)
  chars: desc=492, line=658
  current: Use when the user wants to use the UCP CLI to find, compare, buy, or track products from online merchants, or to set up and troubleshoot the local UCP profile required for merchant-scoped operations. …
  suggested: ucp: executar workflow documentado.
- cursor-public:shopify-hydrogen (cursor-plugin)
  chars: desc=487, line=679
  current: Hydrogen storefront implementation cookbooks. Some of the available recipes are: B2B Commerce, Bundles, Combined Listings, Custom Cart Method, Dynamic Content with Metaobjects, Express Server, Google …
  suggested: shopify hydrogen: executar workflow documentado.
- cursor-public:supabase (cursor-plugin)
  chars: desc=475, line=619
  current: Use when doing ANY task involving Supabase. Triggers: Supabase products (Database, Auth, Edge Functions, Realtime, Storage, Vectors, Cron, Queues); client libraries and SSR integrations (supabase-js, …
  suggested: Supabase: auditar, validar, reportar.
- gepa-reflective (cursor-user)
  chars: desc=473, line=565
  current: GEPA (Generate-Execute-Plan-Adapt) Reflective Evolution pattern para auto-aprimoramento de agentes autÃ´nomos. O LLM lÃª traces de execuÃ§Ã£o (logs, ledger, git diffs) para diagnosticar POR QUE uma hi…
  suggested: spec: debugar, inspecionar, corrigir.
- cursor-public:figma-create-new-file (cursor-plugin)
  chars: desc=470, line=663
  current: **MANDATORY prerequisite** — you MUST invoke this skill BEFORE every `create_new_file` tool call. NEVER call `create_new_file` directly without loading this skill first. Trigger whenever the user want…
  suggested: audit: auditar, validar, reportar.
- spec-enrich (cursor-user)
  chars: desc=468, line=552
  current: Enriquece specs aprovadas com edge cases, contradições e gaps não cobertos. Contexto limpo obrigatório: lê spec + PRD sem histórico de conversa. Encontra contradições diretas, gaps na spec, gaps em am…
  suggested: spec: executar workflow documentado.
- autonomous-agent-loop (cursor-user)
  chars: desc=460, line=564
  current: Design pattern for building autonomous AI agents that run indefinitely in experiment loops. Use when designing agents that optimize metrics autonomously (lead scoring, A/B testing, funnel optimization…
  suggested: Salesforce: executar workflow documentado.
- caverna (cursor-user)
  chars: desc=457, line=533
  current: Modo ultra-comprimido de comunicaÃ§Ã£o PT-BR. Corta ~70-75% dos tokens falando como homem das cavernas mantendo precisÃ£o tÃ©cnica total. NÃ­veis de intensidade: leve, completo, ultra (padrÃ£o travado…
  suggested: caverna: executar workflow documentado.
- cursor-public:hz-platform-sdk (cursor-plugin)
  chars: desc=444, line=644
  current: Guides integration of the Horizon Platform SDK for Meta Quest and Horizon OS Android/Kotlin apps — achievements, IAP, users, leaderboards, presence, notifications, abuse reporting, entitlements, asset…
  suggested: audit: auditar, validar, reportar.
- cursor-public:api-gateway (cursor-plugin)
  chars: desc=441, line=623
  current: Build, manage, and operate APIs with Amazon API Gateway (REST, HTTP, and WebSocket). Triggers on phrases like: API Gateway, REST API, HTTP API, WebSocket API, custom domain, Lambda authorizer, usage p…
  suggested: deploy, spec: criar, validar, entregar.

## Duplicates By Name

- supabase-postgres-best-practices (2 copies)
  keep-default: cursor-user: C:\Users\deivithi.lopes\.cursor\skills\supabase-postgres\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\supabase\release_v0.1.4\skills\supabase-postgres-best-practices\SKILL.md (body=14%, desc=16%)
  - cursor-user: C:\Users\deivithi.lopes\.cursor\skills\supabase-postgres\SKILL.md (body=100%, desc=100%)
- ai-sdk (2 copies)
  keep-default: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\ai-sdk\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\ai-sdk\SKILL.md (body=100%, desc=100%)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\ai-sdk\upstream\SKILL.md (body=100%, desc=25%)
- chat-sdk (2 copies)
  keep-default: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\chat-sdk\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\chat-sdk\SKILL.md (body=100%, desc=100%)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\chat-sdk\upstream\SKILL.md (body=100%, desc=33%)
- next-cache-components (2 copies)
  keep-default: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-cache-components\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-cache-components\SKILL.md (body=100%, desc=100%)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-cache-components\upstream\SKILL.md (body=100%, desc=42%)
- next-forge (2 copies)
  keep-default: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-forge\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-forge\SKILL.md (body=100%, desc=100%)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-forge\upstream\SKILL.md (body=100%, desc=19%)
- next-upgrade (2 copies)
  keep-default: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-upgrade\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-upgrade\SKILL.md (body=100%, desc=100%)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-upgrade\upstream\SKILL.md (body=100%, desc=57%)
- vercel-cli (2 copies)
  keep-default: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\vercel-cli\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\vercel-cli\SKILL.md (body=100%, desc=100%)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\vercel-cli\upstream\SKILL.md (body=100%, desc=21%)
- vercel-sandbox (2 copies)
  keep-default: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\vercel-sandbox\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\vercel-sandbox\SKILL.md (body=100%, desc=100%)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\vercel-sandbox\upstream\SKILL.md (body=100%, desc=16%)
- workflow (2 copies)
  keep-default: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\workflow\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\workflow\SKILL.md (body=100%, desc=100%)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\workflow\upstream\SKILL.md (body=100%, desc=27%)

## Duplicate Delete Suggestions

- ai-sdk
  keep: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\ai-sdk\SKILL.md
  delete: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\ai-sdk\upstream\SKILL.md (body=100%, desc=25%)
- chat-sdk
  keep: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\chat-sdk\SKILL.md
  delete: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\chat-sdk\upstream\SKILL.md (body=100%, desc=33%)
- next-cache-components
  keep: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-cache-components\SKILL.md
  delete: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-cache-components\upstream\SKILL.md (body=100%, desc=42%)
- next-forge
  keep: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-forge\SKILL.md
  delete: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-forge\upstream\SKILL.md (body=100%, desc=19%)
- next-upgrade
  keep: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-upgrade\SKILL.md
  delete: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-upgrade\upstream\SKILL.md (body=100%, desc=57%)
- vercel-cli
  keep: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\vercel-cli\SKILL.md
  delete: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\vercel-cli\upstream\SKILL.md (body=100%, desc=21%)
- vercel-sandbox
  keep: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\vercel-sandbox\SKILL.md
  delete: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\vercel-sandbox\upstream\SKILL.md (body=100%, desc=16%)
- workflow
  keep: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\workflow\SKILL.md
  delete: cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\workflow\upstream\SKILL.md (body=100%, desc=27%)

## Duplicates By Body Hash

- cursor-public:ai-sdk, cursor-public:ai-sdk (2)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\ai-sdk\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\ai-sdk\upstream\SKILL.md
- cursor-public:chat-sdk, cursor-public:chat-sdk (2)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\chat-sdk\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\chat-sdk\upstream\SKILL.md
- cursor-public:next-cache-components, cursor-public:next-cache-components (2)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-cache-components\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-cache-components\upstream\SKILL.md
- cursor-public:next-forge, cursor-public:next-forge (2)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-forge\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-forge\upstream\SKILL.md
- cursor-public:next-upgrade, cursor-public:next-upgrade (2)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-upgrade\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-upgrade\upstream\SKILL.md
- cursor-public:nextjs, cursor-public:next-best-practices (2)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\nextjs\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\nextjs\upstream\SKILL.md
- cursor-public:react-best-practices, cursor-public:vercel-react-best-practices (2)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\react-best-practices\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\react-best-practices\upstream\SKILL.md
- cursor-public:vercel-cli, cursor-public:vercel-cli (2)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\vercel-cli\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\vercel-cli\upstream\SKILL.md
- cursor-public:vercel-sandbox, cursor-public:vercel-sandbox (2)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\vercel-sandbox\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\vercel-sandbox\upstream\SKILL.md
- cursor-public:workflow, cursor-public:workflow (2)
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\workflow\SKILL.md
  - cursor-plugin: C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\workflow\upstream\SKILL.md

## Unused Candidates

- cursor-public:agents-sdk: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\cloudflare\fe4f2e9999991b36568e3d81a13de06a2b26bb20\skills\agents-sdk\SKILL.md
- cursor-public:ai-sdk: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\ai-sdk\SKILL.md
- cursor-public:ai-sdk: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\ai-sdk\upstream\SKILL.md
- cursor-public:amplify-workflow: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\aws-amplify\c4c054c956ca3db8d33f614bea8a68ed07704ec9\skills\amplify-workflow\SKILL.md
- cursor-public:api-gateway: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\aws-serverless\c4c054c956ca3db8d33f614bea8a68ed07704ec9\skills\api-gateway\SKILL.md
- cursor-public:appwrite-cli: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\appwrite-plugin\ce71c971b0be9da5938bef0c3d20a73fa325e32d\skills\appwrite-cli\SKILL.md
- cursor-public:appwrite-dart: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\appwrite-plugin\ce71c971b0be9da5938bef0c3d20a73fa325e32d\skills\appwrite-dart\SKILL.md
- cursor-public:appwrite-dotnet: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\appwrite-plugin\ce71c971b0be9da5938bef0c3d20a73fa325e32d\skills\appwrite-dotnet\SKILL.md
- cursor-public:appwrite-go: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\appwrite-plugin\ce71c971b0be9da5938bef0c3d20a73fa325e32d\skills\appwrite-go\SKILL.md
- cursor-public:appwrite-kotlin: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\appwrite-plugin\ce71c971b0be9da5938bef0c3d20a73fa325e32d\skills\appwrite-kotlin\SKILL.md
- cursor-public:appwrite-php: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\appwrite-plugin\ce71c971b0be9da5938bef0c3d20a73fa325e32d\skills\appwrite-php\SKILL.md
- cursor-public:appwrite-python: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\appwrite-plugin\ce71c971b0be9da5938bef0c3d20a73fa325e32d\skills\appwrite-python\SKILL.md
- cursor-public:appwrite-ruby: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\appwrite-plugin\ce71c971b0be9da5938bef0c3d20a73fa325e32d\skills\appwrite-ruby\SKILL.md
- cursor-public:appwrite-swift: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\appwrite-plugin\ce71c971b0be9da5938bef0c3d20a73fa325e32d\skills\appwrite-swift\SKILL.md
- cursor-public:appwrite-typescript: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\appwrite-plugin\ce71c971b0be9da5938bef0c3d20a73fa325e32d\skills\appwrite-typescript\SKILL.md
- cursor-public:atlas-stream-processing: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\mongodb\b6fcb1a2d83079becf1c9be23d66e1b71739d007\skills\atlas-stream-processing\SKILL.md
- cursor-public:auth: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\auth\SKILL.md
- cursor-public:aws-lambda: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\aws-serverless\c4c054c956ca3db8d33f614bea8a68ed07704ec9\skills\aws-lambda\SKILL.md
- cursor-public:aws-lambda-durable-functions: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\aws-serverless\c4c054c956ca3db8d33f614bea8a68ed07704ec9\skills\aws-lambda-durable-functions\SKILL.md
- cursor-public:aws-serverless-deployment: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\aws-serverless\c4c054c956ca3db8d33f614bea8a68ed07704ec9\skills\aws-serverless-deployment\SKILL.md
- cursor-public:benchmark-agents: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\.claude\skills\benchmark-agents\SKILL.md
- cursor-public:benchmark-e2e: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\.claude\skills\benchmark-e2e\SKILL.md
- cursor-public:benchmark-sandbox: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\.claude\skills\benchmark-sandbox\SKILL.md
- cursor-public:benchmark-testing: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\.claude\skills\benchmark-testing\SKILL.md
- cursor-public:bootstrap: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\bootstrap\SKILL.md
- cursor-public:building-ai-agent-on-cloudflare: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\cloudflare\fe4f2e9999991b36568e3d81a13de06a2b26bb20\skills\building-ai-agent-on-cloudflare\SKILL.md
- cursor-public:building-mcp-server-on-cloudflare: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\cloudflare\fe4f2e9999991b36568e3d81a13de06a2b26bb20\skills\building-mcp-server-on-cloudflare\SKILL.md
- cursor-public:chat-sdk: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\chat-sdk\SKILL.md
- cursor-public:chat-sdk: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\chat-sdk\upstream\SKILL.md
- cursor-public:cloudflare: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\cloudflare\fe4f2e9999991b36568e3d81a13de06a2b26bb20\skills\cloudflare\SKILL.md
- cursor-public:cloudinary-docs: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\cloudinary\7b443d7dbd607bfe4850d8cfcab6ba4cbf1a57c3\skills\cloudinary-docs\SKILL.md
- cursor-public:cloudinary-transformations: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\cloudinary\7b443d7dbd607bfe4850d8cfcab6ba4cbf1a57c3\skills\cloudinary-transformations\SKILL.md
- cursor-public:create-my-tools-profile: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\zapier\ecd7c7220c63a62a9702b76276b6a05f740d8c18\skills\create-my-tools-profile\SKILL.md
- cursor-public:ddconfig: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\datadog\fb78760badbd29f081640ed8cd60b0884f4f99dd\skills\ddconfig\SKILL.md
- cursor-public:ddsetup: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\datadog\fb78760badbd29f081640ed8cd60b0884f4f99dd\skills\ddsetup\SKILL.md
- cursor-public:deploy: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\deploy-on-aws\437f4bed0bfd7367df7613ca932fe900f7e08d89\skills\deploy\SKILL.md
- cursor-public:developing-genkit-js: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\firebase\bec78e7dace12670b3b3c5c63d7124cca5c2c8c9\skills\developing-genkit-js\SKILL.md
- cursor-public:durable-objects: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\cloudflare\fe4f2e9999991b36568e3d81a13de06a2b26bb20\skills\durable-objects\SKILL.md
- cursor-public:figma-code-connect: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\figma\a742f0a700a7772ff5ed85f7c9fc1dad5afa9fcc\skills\figma-code-connect\SKILL.md
- cursor-public:figma-create-new-file: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\figma\a742f0a700a7772ff5ed85f7c9fc1dad5afa9fcc\skills\figma-create-new-file\SKILL.md
- cursor-public:figma-generate-design: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\figma\a742f0a700a7772ff5ed85f7c9fc1dad5afa9fcc\skills\figma-generate-design\SKILL.md
- cursor-public:figma-generate-diagram: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\figma\a742f0a700a7772ff5ed85f7c9fc1dad5afa9fcc\skills\figma-generate-diagram\SKILL.md
- cursor-public:figma-generate-library: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\figma\a742f0a700a7772ff5ed85f7c9fc1dad5afa9fcc\skills\figma-generate-library\SKILL.md
- cursor-public:figma-use: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\figma\a742f0a700a7772ff5ed85f7c9fc1dad5afa9fcc\skills\figma-use\SKILL.md
- cursor-public:firebase-basics: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\firebase\bec78e7dace12670b3b3c5c63d7124cca5c2c8c9\skills\firebase-basics\SKILL.md
- cursor-public:firebase-firestore-enterprise-native-mode: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\firebase\bec78e7dace12670b3b3c5c63d7124cca5c2c8c9\skills\firebase-firestore-enterprise-native-mode\SKILL.md
- cursor-public:firebase-firestore-standard: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\firebase\bec78e7dace12670b3b3c5c63d7124cca5c2c8c9\skills\firebase-firestore-standard\SKILL.md
- cursor-public:firebase-local-env-setup: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\firebase\bec78e7dace12670b3b3c5c63d7124cca5c2c8c9\skills\firebase-local-env-setup\SKILL.md
- cursor-public:functions: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\functions\release_v0.2.4\skills\functions\SKILL.md
- cursor-public:hf-mcp: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\huggingface-skills\5d88e21bff0495d5a900b2fbc5a36958366ee3e0\hf-mcp\skills\hf-mcp\SKILL.md
- cursor-public:hugging-face-datasets: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\huggingface-skills\5d88e21bff0495d5a900b2fbc5a36958366ee3e0\skills\hugging-face-datasets\SKILL.md
- cursor-public:hugging-face-evaluation: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\huggingface-skills\5d88e21bff0495d5a900b2fbc5a36958366ee3e0\skills\hugging-face-evaluation\SKILL.md
- cursor-public:hugging-face-jobs: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\huggingface-skills\5d88e21bff0495d5a900b2fbc5a36958366ee3e0\skills\hugging-face-jobs\SKILL.md
- cursor-public:hugging-face-model-trainer: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\huggingface-skills\5d88e21bff0495d5a900b2fbc5a36958366ee3e0\skills\hugging-face-model-trainer\SKILL.md
- cursor-public:hugging-face-paper-publisher: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\huggingface-skills\5d88e21bff0495d5a900b2fbc5a36958366ee3e0\skills\hugging-face-paper-publisher\SKILL.md
- cursor-public:hugging-face-tool-builder: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\huggingface-skills\5d88e21bff0495d5a900b2fbc5a36958366ee3e0\skills\hugging-face-tool-builder\SKILL.md
- cursor-public:hugging-face-trackio: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\huggingface-skills\5d88e21bff0495d5a900b2fbc5a36958366ee3e0\skills\hugging-face-trackio\SKILL.md
- cursor-public:hz-immersive-designer: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\meta-quest-agentic-tools\3564b4a06bf8981715207b00361f7495ae5c7e70\skills\hz-immersive-designer\SKILL.md
- cursor-public:hz-iwsdk-webxr: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\meta-quest-agentic-tools\3564b4a06bf8981715207b00361f7495ae5c7e70\skills\hz-iwsdk-webxr\SKILL.md
- cursor-public:hz-perfetto-debug: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\meta-quest-agentic-tools\3564b4a06bf8981715207b00361f7495ae5c7e70\skills\hz-perfetto-debug\SKILL.md
- cursor-public:hz-platform-sdk: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\meta-quest-agentic-tools\3564b4a06bf8981715207b00361f7495ae5c7e70\skills\hz-platform-sdk\SKILL.md
- cursor-public:hz-unity-code-review: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\meta-quest-agentic-tools\3564b4a06bf8981715207b00361f7495ae5c7e70\skills\hz-unity-code-review\SKILL.md
- cursor-public:hz-vr-debug: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\meta-quest-agentic-tools\3564b4a06bf8981715207b00361f7495ae5c7e70\skills\hz-vr-debug\SKILL.md
- cursor-public:hz-vrc-check: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\meta-quest-agentic-tools\3564b4a06bf8981715207b00361f7495ae5c7e70\skills\hz-vrc-check\SKILL.md
- cursor-public:marketplace: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\marketplace\SKILL.md
- cursor-public:miro-mcp: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\miro\9627168a40c694c61a8734cbcdd452d21e560bdc\skills\miro-mcp\SKILL.md
- cursor-public:mongodb-connection: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\mongodb\b6fcb1a2d83079becf1c9be23d66e1b71739d007\skills\mongodb-connection\SKILL.md
- cursor-public:mongodb-mcp-setup: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\mongodb\b6fcb1a2d83079becf1c9be23d66e1b71739d007\skills\mongodb-mcp-setup\SKILL.md
- cursor-public:mongodb-natural-language-querying: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\mongodb\b6fcb1a2d83079becf1c9be23d66e1b71739d007\skills\mongodb-natural-language-querying\SKILL.md
- cursor-public:mongodb-schema-design: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\mongodb\b6fcb1a2d83079becf1c9be23d66e1b71739d007\skills\mongodb-schema-design\SKILL.md
- cursor-public:mongodb-search-and-ai: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\mongodb\b6fcb1a2d83079becf1c9be23d66e1b71739d007\skills\mongodb-search-and-ai\SKILL.md
- cursor-public:next-cache-components: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-cache-components\SKILL.md
- cursor-public:next-forge: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-forge\SKILL.md
- cursor-public:next-forge: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\next-forge\upstream\SKILL.md
- cursor-public:nextjs: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\nextjs\SKILL.md
- cursor-public:plugin-audit: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\.claude\skills\plugin-audit\SKILL.md
- cursor-public:react-best-practices: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\react-best-practices\SKILL.md
- cursor-public:render-debug: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\render\1d8fb10d0d901141211b79b0b1bdd0171a872d18\skills\render-debug\SKILL.md
- cursor-public:render-deploy: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\render\1d8fb10d0d901141211b79b0b1bdd0171a872d18\skills\render-deploy\SKILL.md
- cursor-public:render-migrate-from-heroku: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\render\1d8fb10d0d901141211b79b0b1bdd0171a872d18\skills\render-migrate-from-heroku\SKILL.md
- cursor-public:render-monitor: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\render\1d8fb10d0d901141211b79b0b1bdd0171a872d18\skills\render-monitor\SKILL.md
- cursor-public:render-workflows: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\render\1d8fb10d0d901141211b79b0b1bdd0171a872d18\skills\render-workflows\SKILL.md
- cursor-public:routing-middleware: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\routing-middleware\SKILL.md
- cursor-public:runtime-cache: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\runtime-cache\SKILL.md
- cursor-public:sandbox-sdk: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\cloudflare\fe4f2e9999991b36568e3d81a13de06a2b26bb20\skills\sandbox-sdk\SKILL.md
- cursor-public:shadcn: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\vercel\3d9d9cd0fe5d1bdaedb891135a5c45f19190b83f\skills\shadcn\SKILL.md
- cursor-public:shopify-admin: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\shopify-plugin\c164cf45c4bc1d17bbc105168d99a4f744cfaac2\skills\shopify-admin\SKILL.md
- cursor-public:shopify-custom-data: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\shopify-plugin\c164cf45c4bc1d17bbc105168d99a4f744cfaac2\skills\shopify-custom-data\SKILL.md
- cursor-public:shopify-functions: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\shopify-plugin\c164cf45c4bc1d17bbc105168d99a4f744cfaac2\skills\shopify-functions\SKILL.md
- cursor-public:shopify-hydrogen: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\shopify-plugin\c164cf45c4bc1d17bbc105168d99a4f744cfaac2\skills\shopify-hydrogen\SKILL.md
- cursor-public:shopify-liquid: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\shopify-plugin\c164cf45c4bc1d17bbc105168d99a4f744cfaac2\skills\shopify-liquid\SKILL.md
- cursor-public:shopify-onboarding-dev: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\shopify-plugin\c164cf45c4bc1d17bbc105168d99a4f744cfaac2\skills\shopify-onboarding-dev\SKILL.md
- cursor-public:shopify-onboarding-merchant: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\shopify-plugin\c164cf45c4bc1d17bbc105168d99a4f744cfaac2\skills\shopify-onboarding-merchant\SKILL.md
- cursor-public:shopify-polaris-app-home: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\shopify-plugin\c164cf45c4bc1d17bbc105168d99a4f744cfaac2\skills\shopify-polaris-app-home\SKILL.md
- cursor-public:shopify-polaris-checkout-extensions: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\shopify-plugin\c164cf45c4bc1d17bbc105168d99a4f744cfaac2\skills\shopify-polaris-checkout-extensions\SKILL.md
- cursor-public:shopify-polaris-customer-account-extensions: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\shopify-plugin\c164cf45c4bc1d17bbc105168d99a4f744cfaac2\skills\shopify-polaris-customer-account-extensions\SKILL.md
- cursor-public:shopify-pos-ui: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\shopify-plugin\c164cf45c4bc1d17bbc105168d99a4f744cfaac2\skills\shopify-pos-ui\SKILL.md
- cursor-public:shopify-storefront-graphql: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\shopify-plugin\c164cf45c4bc1d17bbc105168d99a4f744cfaac2\skills\shopify-storefront-graphql\SKILL.md
- cursor-public:shopify-use-shopify-cli: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\shopify-plugin\c164cf45c4bc1d17bbc105168d99a4f744cfaac2\skills\shopify-use-shopify-cli\SKILL.md
- cursor-public:supabase: cursor-plugin; usage=$0, reads=0, text=0; C:\Users\deivithi.lopes\.cursor\plugins\cache\cursor-public\supabase\release_v0.1.4\skills\supabase\SKILL.md

## Root Summary

- C:\Users\deivithi.lopes\.cursor\plugins\cache: 213 skills (cursor-plugin)
- C:\Users\deivithi.lopes\.cursor\skills: 99 skills (cursor-user)

## Recommended Actions

1. Remover espelhos workspace quando existir cópia em cursor-user
2. Encurtar descriptions >110 chars (ver Description Candidates)
3. Desabilitar plugins Cursor não usados (reduz cursor-plugin flood)
4. Re-auditar mensalmente: node scripts/skill-inventory-audit.ts --months 3
5. Nunca deletar sem confirmar — sugerir primeiro, aplicar sob demanda
---
name: pulso-finance
description: >
  Super especialista senior no projeto Pulso Finance — app de gestao financeira pessoal.
  React 18 + TypeScript + Vite + Supabase + Vercel. Domina toda a arquitetura, banco,
  logica de negocios, UI/UX (padrao Apple/Google), deploy e historico de incidentes.
  Ativacao: "Pulse Finance", "Pulso Finance", "pulsofinance", "app financeiro".
domain: product
subdomain: pulso-finance
version: 5.0.0
author: deivithi
tags:
  - pulso-finance
  - react
  - supabase
  - vercel
  - fintech
  - dashboard
  - ui-ux
  - typescript
  - pgvector
  - agent-memory-v2
  - three
  - view-transitions
---

# 💰 Pulso Finance — Super Especialista Senior

> **"Receitas, despesas, parcelamentos e assinaturas em um so lugar. Clareza total, zero surpresas."**

Voce e um **super especialista senior com 30+ anos de experiencia** no projeto Pulso Finance.
Voce domina cada arquivo, cada tabela, cada hook, cada componente. Voce sabe o que funciona,
o que ja quebrou, e o que nunca deve ser tocado sem cuidado.

## 📁 File Structure

- `SKILL.md` — Voce esta aqui. Referencia completa do projeto.
- `references/architecture.md` — Arquitetura, stack, estrutura de arquivos e banco de dados.
- `references/incidents.md` — Historico de incidentes e correcoes (NUNCA repetir).
- `gotchas.md` — Problemas conhecidos e armadilhas. Consulte SEMPRE antes de editar.

## 🔗 Related Skills

- `frontend-design` — Para melhorias de UI seguindo padrao Apple/Google
- `supabase-postgres` — Otimizacao de queries e RLS
- `code-review` — Review antes de deploy
- `cicd` — Deploy Vercel e smoke tests
- `deploy-checklist` — Checklist pre-deploy
- `minimax-pdf` — Gerar relatorios PDF premium
- `data-charts` — Graficos interativos (Recharts)

---

## 📌 Status Atual (última sessão registrada: 2026-05-24 — skill sincronizada via GitHub em 2026-06-01)

- **Versão em prod:** `v5.0.0` — HEAD `main` = `ba09616` (identidade visual profissional "de-AI"). Sequência: `v4.7.0` (S11) → `v4.8.0` (S12 orçamentos) → `v4.9.0` (S13 UI Flagship) → `v5.0.0` (de-AI + Agent Memory v2).
- **URL:** https://pulsofinance.vercel.app
- **Repositório:** `deivithi/pulsofinance` (PRIVADO) — acesso `gh` exige conta **`deivithi`** ativa (`gh auth login`). Conta `deivithilopes-ai` NÃO tem acesso.
- **Sprints encerrados:** S11 (Sentry/CSP), S12 (orçamentos cross-month), S13 (UI Flagship → revertido em parte pelo de-AI). Sem PRs abertos, sem branches extras (só `main`), sem GitHub Actions (deploy via Vercel webhook).
- **Últimos commits pulsofinance (origin/main):**
  - `ba09616` — docs(constitution): v5.0.0 — identidade profissional de-AI + agent memory v2
  - `8a3f3e7` — feat(v5.0.0): identidade visual profissional — remove cara de IA
  - `1ccdab3` — fix(agent-memory): id no select do recall_hypermem p/ dedup semântico
  - `a67054a` — feat(agent-memory-v2): memória semântica pgvector + gte-small (Tier 1)
  - `4effe9d` — chore(s13): bump v4.9.0 'UI Flagship' + Trilha de Novidades
  - `5d7aff0` — feat(s13-c): View Transitions API — circular reveal no toggle de tema
  - `d4dc6cf` — feat(s13-b): fundo shader WebGL [REVERTIDO em `8a3f3e7`]
  - `843e342` — feat(s13-a): Liquid Glass rim/sheen [REVERTIDO em `8a3f3e7`]
  - `2eb941c` — feat(s13-mobile): safe-area insets + responsividade fina
  - `b9f8068` — feat(s12-v4.8.0): orcamentos persistentes cross-month + pausar mes (#1, merged)
- **⚠️ Reversão de-AI (v5.0.0):** o S13 adicionou shader WebGL + Liquid Glass sheen, mas `8a3f3e7` os **REMOVEU no mesmo dia** (24/05). No `main` atual NÃO existem: `ShaderMeshBg`, `MeshGradientBg`, `useGlassSheen`, `useMeshMood`, `useCanRenderShader`. **Sobreviveram:** `ThemeToggle` com View Transitions API + `PulsoOrb3D` (Three.js) + `useScrollDepth`/`useTimeOfDay`/`useOrbState`/`ScrollReveal`.
- **Identidade visual v5.0.0:** paleta **teal/petróleo + grafite** (light `--primary 188 88% 27%`, dark `184 72% 50%`), fonte **Hanken Grotesk** (Inter fallback), fundo sólido limpo, gradientes single-family teal, glass recolorido sem sheen. **Banido:** indigo/violeta/roxo, gradientes rainbow, `gradient-text` decorativo, Sparkles, fundo animado.
- **Novas deps (v5.0.0):** `three@^0.168` + `@react-three/fiber@^8.18` + `@react-three/drei@^9.122` (PulsoOrb3D em `src/components/ai/`) + `@fontsource-variable/hanken-grotesk@^5.2.8`. Já existentes: `@sentry/react@^8.55`, `@sentry/vite-plugin@^2.23`, `@tanstack/react-virtual@^3.13`, `framer-motion@^12.38`.
- **Agent Memory v2 (S13, pgvector):** migration `20260524120000_agent_memory_v2_pgvector.sql` — extensão `vector`, coluna `embedding vector(384)` em `ai_memories` + `ai_episodes`, índices HNSW (cosine), RPCs `match_ai_memories` + `match_ai_episodes`. Embeddings via `globalThis.Supabase.ai.Session('gte-small')` (nativo Edge Runtime, 384 dims, custo zero, sem API key) em `supabase/functions/ai-agent/embeddings.ts`.
- **Constitution:** princípios governantes do projeto agora em **`.claude/constitution.md`** (8 princípios invioláveis + safety gates + decisões arquiteturais imutáveis + anti-patterns de-AI).
- **Observabilidade frontend (ATIVA):** Sentry em `src/main.tsx` (tracesSampleRate 0, `ignoreErrors` canônico, `beforeSend` strip de PII) + `ErrorBoundary.tsx`. Mini-painel owner-only em `/configuracoes` (seção Observabilidade).
- **Env vars Vercel Production:** `VITE_SENTRY_DSN`, `SENTRY_AUTH_TOKEN` (secret), `SENTRY_ORG` = `deivithi-silva-lopes-382357278`, `SENTRY_PROJECT` = `pulsofinance`.
- **CSP em `vercel.json`:** `connect-src` inclui `https://*.supabase.co https://openrouter.ai https://*.ingest.sentry.io`.
- **Trigger próxima sessão:** `"próximo sprint Pulso"`.

### 🟡 Pendência de baixa prioridade

**`VITE_SENTRY_DSN` em Preview env:** não setada. Vercel CLI v50+ tem bug em `env add ... preview` que rejeita `--yes` sem `git-branch` posicional existente (rejeita `main` porque é production branch). Resolver via Vercel Dashboard → Settings → Environment Variables → Add (30s manual) OU aceitar que preview deployments não reportem ao Sentry (aceitável — previews são internos, raramente rodados sob carga real).

---

## 1. Identidade do Projeto

| Campo                   | Valor                                                       |
| ----------------------- | ----------------------------------------------------------- |
| **Nome**                | Pulso Finance (pulsofinance)                                |
| **Tipo**                | App web SPA de financas pessoais                            |
| **Diretorio**           | `C:\Users\PC\Documents\VS CODE\pulsofinance`                |
| **Producao**            | https://pulsofinance.vercel.app                             |
| **Repositorio**         | https://github.com/deivithi/pulsofinance                    |
| **Supabase Project ID** | `txbzynnszuvjnmhbnnzh`                                      |
| **Supabase Dashboard**  | https://supabase.com/dashboard/project/txbzynnszuvjnmhbnnzh |
| **Vercel Dashboard**    | Via `npx vercel ls` ou dashboard web                        |
| **Branch principal**    | `main`                                                      |
| **Deploy**              | Automatico via push no `main` → Vercel CI/CD                |

---

## 2. Stack Tecnica

| Camada             | Tecnologia                                                                                     | Versao               |
| ------------------ | ---------------------------------------------------------------------------------------------- | -------------------- |
| Frontend           | React + TypeScript                                                                             | 18.3 / 5.8           |
| Build              | Vite (SWC)                                                                                     | 5.4                  |
| Estilizacao        | Tailwind CSS                                                                                   | 3.4                  |
| Componentes UI     | shadcn/ui (Radix UI)                                                                           | 40+ componentes      |
| Icones             | Lucide React                                                                                   | 0.462                |
| Estado/Cache       | TanStack React Query                                                                           | 5.83                 |
| Formularios        | React Hook Form + Zod                                                                          | 7.61 / 3.25          |
| Graficos           | Recharts                                                                                       | 2.15                 |
| Datas              | date-fns                                                                                       | 3.6                  |
| Auth/DB            | Supabase (PostgreSQL + Auth + RLS + Storage)                                                   | 2.90                 |
| Roteamento         | React Router DOM                                                                               | 6.30                 |
| PDF                | jsPDF + jsPDF-autotable (lazy-loaded)                                                          | 4.2 / 5.0            |
| Tema               | next-themes (dark/light)                                                                       | 0.3                  |
| Deploy             | Vercel (CI/CD automatico via GitHub)                                                           | —                    |
| Testes             | Vitest + jsdom                                                                                 | 4.0                  |
| Observabilidade    | @sentry/react + @sentry/vite-plugin (S11, v4.7.0)                                              | 8.55 / 2.23          |
| Virtualizacao      | @tanstack/react-virtual (S10-C Extrato >20 dias)                                               | 3.13                 |
| Animacao           | framer-motion                                                                                  | 12.38                |
| 3D / Orb           | three + @react-three/fiber + @react-three/drei (PulsoOrb3D em `src/components/ai/`)            | 0.168 / 8.18 / 9.122 |
| Fonte              | @fontsource-variable/hanken-grotesk (v5.0.0 — substituiu Inter, que vira fallback)             | 5.2                  |
| Transicoes de tema | View Transitions API nativa (circular reveal no `ThemeToggle`, S13)                            | —                    |
| IA Embeddings      | pgvector (extensao Supabase) + `gte-small` 384-dim via `Supabase.ai.Session` (Agent Memory v2) | —                    |

---

## 3. Protocolo de Entrada

Ao ser ativado para trabalhar no Pulso Finance, o assistente DEVE:

### 3.1 Contextualizacao (automatico)

```
1. Ler este SKILL.md inteiro
2. Ler references/architecture.md (arquitetura + banco)
3. Ler references/incidents.md (o que NUNCA repetir)
4. Ler gotchas.md (armadilhas conhecidas)
5. Verificar git status do projeto: git -C "C:/Users/PC/Documents/VS CODE/pulsofinance" status
6. Verificar ultimo commit: git -C "C:/Users/PC/Documents/VS CODE/pulsofinance" log --oneline -5
```

### 3.2 Regras Inviolaveis

> 📜 Forma curta abaixo. Fonte canônica = **`.claude/constitution.md`** (8 princípios com Why/How + safety gates + decisões arquiteturais imutáveis + anti-patterns de-AI). Em conflito, a constitution prevalece.

| #   | Regra                                                         | Motivo                                                      |
| --- | ------------------------------------------------------------- | ----------------------------------------------------------- |
| 1   | **NUNCA executar SQL destrutivo contra o Supabase**           | O banco tem dados reais do usuario. DROP/TRUNCATE proibidos |
| 2   | **NUNCA fazer `git reset --hard`**                            | Antigravity ja destruiu o projeto assim uma vez             |
| 3   | **SEMPRE `npm run build` antes de declarar tarefa concluida** | Build verifica TypeScript, imports e integridade            |
| 4   | **SEMPRE `npm test` antes de commit**                         | 4 testes basicos que validam utils                          |
| 5   | **Env vars ficam na Vercel, NAO no codigo**                   | `.env` esta no `.gitignore`                                 |
| 6   | **Code splitting: paginas protegidas sao lazy-loaded**        | Performance — nao importar estaticamente                    |
| 7   | **PDF e lazy-loaded via `import()` dinamico**                 | 430kB+ que nao devem entrar no bundle inicial               |
| 8   | **RLS em TODAS as tabelas**                                   | Seguranca — cada usuario so ve seus dados                   |

### 3.3 Antes de QUALQUER Edicao

```
□ Li o gotchas.md?
□ O arquivo que vou editar esta no contexto?
□ Entendo o impacto no saldo/dashboard?
□ A mudanca preserva RLS e type-safety?
□ Vou rodar build + test depois?
```

---

## 4. Arquitetura de Paginas

> 🎨 **v5.0.0 — a coluna "Cor tema" abaixo é LEGADA (pré-de-AI).** A paleta foi unificada em **teal/petróleo + grafite**. **Indigo/violeta/roxo foram banidos** (constitution). Ler "Indigo"/"Roxo" como teal. Accent global = teal; cores semânticas vivas: `emerald`=receitas, `rose`=gastos, `amber`=urgente, `teal`=primária (parcelas/assinaturas/score).

| Rota             | Pagina                                                                                                                                                                       | Protegida | Cor tema |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | -------- |
| `/`              | Landing page                                                                                                                                                                 | Nao       | Teal     |
| `/login`         | Login                                                                                                                                                                        | Nao       | —        |
| `/cadastro`      | Cadastro                                                                                                                                                                     | Nao       | —        |
| `/dashboard`     | Dashboard (Pulso Score, cards, graficos, metas, insights, cashflow, debt payoff)                                                                                             | Sim       | Multi    |
| `/parcelamentos` | CRUD parcelamentos (table desktop + cards mobile + swipe)                                                                                                                    | Sim       | Teal     |
| `/assinaturas`   | CRUD assinaturas (cards + audit + rating + swipe)                                                                                                                            | Sim       | Teal     |
| `/receitas`      | CRUD receitas                                                                                                                                                                | Sim       | Emerald  |
| `/outros-gastos` | CRUD gastos avulsos (+ swipe actions)                                                                                                                                        | Sim       | Rose     |
| `/extrato`       | Extrato unificado (4 tabelas, filtros, tags, duplicar mes)                                                                                                                   | Sim       | Multi    |
| `/comparativo`   | Comparativo mensal (barras duais por categoria)                                                                                                                              | Sim       | Multi    |
| `/orcamento`     | Orcamento por categoria (barras YNAB-style)                                                                                                                                  | Sim       | Multi    |
| `/resumo`        | Resumo Cinema — Pulso Wrapped v4.3 (Embla carousel + Pulso Char SVG 10 variants por categoria + auto-cinema 7s/slide + progress stories-style + transições cinematográficas) | Sim       | Multi    |
| `/categorias`    | CRUD categorias                                                                                                                                                              | Sim       | Teal     |
| `/configuracoes` | Perfil, avatar, accent color, Pulso AI custom instructions, **Trilha de Novidades** (v1.0 → v5.0, timeline animada), delete account                                          | Sim       | —        |

### Layout

- **Desktop:** Liquid Glass Sidebar (11 itens, animated pill, mini pulse score, breathing dot, Cmd+K hint) + header com breadcrumb + search hint + conteudo com fade page transitions
- **Mobile (Apple HIG v3.0):**
  - **IOSHeader:** large title (28px bold) que compacta para 17px inline no AppHeader ao scrollar (Framer Motion useTransform)
  - **BottomNav:** 5 itens com pill animada (`layoutId`), `whileTap` scale 0.85, haptic vibrate no tap
  - **Page Transitions:** push/pop horizontal (iOS-style, slide da direita/esquerda) via `useNavigationType()`
  - **Back Gesture:** swipe da borda esquerda (20px) → `navigate(-1)` (mobile only)
  - **Pull-to-Refresh:** rubber-band effect com spinner circular em Dashboard, Parcelamentos, Assinaturas, Extrato
  - **Bottom Sheets:** todos os modais usam Drawer (vaul) no mobile via `ResponsiveModal` / `ResponsiveAlertModal`
  - **FAB contextual:** speed dial com spring staggered animation + backdrop blur
  - **Tap feedback:** `whileTap={{ scale: 0.97 }}` em todos os cards interativos
- **Overlay:** AI Chat (canto inferior esquerdo), Quick FAB (canto inferior direito, contextual), Command Palette (Ctrl+K)
- **ScrollContext:** Provider em AppLayout expoe `{ scrollY, isScrolled, scrollDirection, pageTitle }` para IOSHeader e AppHeader
- **Theme toggle (S13):** `ThemeToggle.tsx` usa **View Transitions API** (`document.startViewTransition` + `clipPath: circle()` a partir do ponto de clique) para revelação circular dark↔light. Fallback gracioso sem suporte / `prefers-reduced-motion`.
- **PulsoOrb3D (v5.0.0):** orb 3D em Three.js (`src/components/ai/PulsoOrb3D.tsx` + `PulsoOrb.tsx`), mood via `useOrbState`. Único uso ativo de WebGL após o de-AI.
- **⚠️ Removido em v5.0.0 (de-AI):** `MeshGradientBg`, `ShaderMeshBg` (fundo shader), `useGlassSheen` (Liquid Glass sheen). Fundo agora é **sólido limpo** (sem mesh/shader). Não readicionar (ver gotchas + constitution).

---

## 5. Banco de Dados (25 tabelas Supabase — auditado S10 2026-04-17)

> **S10 Audit (2026-04-17):** 25 tabelas em `public`, 100% com RLS. Tabelas S1-S8 (agent_followups, agent_goal_proposals, agent_runs, ai_episodes, ai_topics, notification_throttle, push_subscriptions) cobertas pelo DeleteAccountDialog via lista canônica `TABLES_TO_DELETE`.

### Tabelas Core

| Tabela          | Campos-chave                                                                                                                                                                     | RLS |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --- |
| `categorias`    | nome, cor, icone                                                                                                                                                                 | ✅  |
| `parcelamentos` | descricao, valor_total, valor_parcela, parcelas_pagas, **meses_confirmados[]**, total_parcelas, dia_vencimento, status                                                           | ✅  |
| `assinaturas`   | nome, valor, frequencia, dia_cobranca, **meses_confirmados[]**, status, uso_rating                                                                                               | ✅  |
| `receitas`      | descricao, valor, data, recorrente, frequencia, total_parcelas, parcela_atual, **parcelas_recebidas**, **meses_confirmados[]**, meses_pausados                                   | ✅  |
| `outros_gastos` | descricao, valor, data, meses_pausados                                                                                                                                           | ✅  |
| `profiles`      | avatar_url, full_name, accent_color, ai_about_me, ai_response_style, email_digest_enabled, voice_enabled, voice_autoplay, haptics_enabled (default true), ambient_sounds_enabled | ✅  |
| `user_roles`    | role (admin/moderator/user)                                                                                                                                                      | ✅  |

### Tabelas Fase 2+ (Gamificacao, Orcamento, IA)

| Tabela                 | Campos-chave                                                                                    | RLS |
| ---------------------- | ----------------------------------------------------------------------------------------------- | --- |
| `metas`                | descricao, valor_alvo, valor_atual, tipo, prazo                                                 | ✅  |
| `conquistas`           | tipo, titulo, desbloqueada_em                                                                   | ✅  |
| `orcamentos`           | categoria_id, valor_limite, **meses_pausados[]** (S12 cross-month), mes + recorrente DEPRECATED | ✅  |
| `alertas`              | tipo, titulo, descricao, lido, severity, source, metadata, delivery_channel (S4 v3.6.0)         | ✅  |
| `categorias_historico` | descricao, categoria_id, count                                                                  | ✅  |

### Tabelas IA Agent

| Tabela        | Campos-chave                                                                           | RLS |
| ------------- | -------------------------------------------------------------------------------------- | --- |
| `ai_threads`  | title, last_message_at                                                                 | ✅  |
| `ai_messages` | thread_id, role, content                                                               | ✅  |
| `ai_memories` | content, source, confidence, **embedding vector(384)** (Agent Memory v2 — HNSW cosine) | ✅  |
| `ai_recaps`   | periodo, conteudo                                                                      | ✅  |

### Tabelas Tags (Fase 8)

| Tabela             | Campos-chave                                                       | RLS |
| ------------------ | ------------------------------------------------------------------ | --- |
| `tags`             | nome, cor, UNIQUE(user_id, nome)                                   | ✅  |
| `transaction_tags` | tag_id, parcelamento_id/assinatura_id/outro_gasto_id (polimórfica) | ✅  |

**Todas as tabelas** tem `user_id` com FK para `auth.users(id) ON DELETE CASCADE`.
**Admin auto-atribuido** para `deivithi74@gmail.com` via trigger `handle_new_user_role()`.

> **Hierarquia HyperMem completa:** além de `ai_threads`/`ai_messages`/`ai_memories`/`ai_recaps`, existem `ai_episodes` e `ai_topics` (memories → episodes → topics, S5). Total de 25 tabelas + 4 RPCs admin (ver abaixo).

### Agent Memory v2 — Memória Semântica pgvector (S13, 2026-05-24)

- **Migration:** `supabase/migrations/20260524120000_agent_memory_v2_pgvector.sql`
- **Extensão:** `vector` (pgvector) habilitada
- **Colunas:** `embedding vector(384)` em `ai_memories` **E** `ai_episodes`
- **Índices:** HNSW (distância cosine) em ambas as colunas embedding
- **RPCs:** `match_ai_memories(p_query_embedding, ...)` + `match_ai_episodes(...)` — similaridade vetorial por `user_id`
- **Geração de embeddings:** `supabase/functions/ai-agent/embeddings.ts` usa `globalThis.Supabase.ai.Session('gte-small')` — modelo nativo da Edge Runtime, **384 dims, custo zero, sem API key**. `embedText(text)` falha graciosamente → `null`; `vecLiteral(vec)` formata para pgvector. Embedding gravado **best-effort via UPDATE pós-INSERT — nunca bloqueia o save**.
- **Consumo:** tool `recall_memories` tenta busca semântica (`rpc('match_ai_memories')`) e cai p/ keyword/confiança se sem embedding; tool `recall_hypermem` roda `match_ai_episodes` + `match_ai_memories` em paralelo.

### Edge Functions — Ecossistema de Agentes (v3.7.0)

**1. `ai-agent` (v3.7.0 — Multi-Agent + Self-Reflection + HyperMem desde S5)**

- **Localização:** `supabase/functions/ai-agent/` (`index.ts` + `tools.ts` + `memory.ts` + `embeddings.ts` [Agent Memory v2] + `orchestrator/` incluindo `reflection.ts` e `prompts/reflection.prompt.ts`)
- **Stack:** LangChain.js + LangGraph.js (createReactAgent) + OpenRouter (`minimax/minimax-m2.7` — modelo PAGO, não free tier)
- **Arquitetura:** Supervisor (classifier JSON) → 5 especialistas + SAC em paralelo → Editor (composer) → Judge (score 1-10) → regen 1x opcional OU ReAct legacy single-agent via feature flag
- **Feature flags:** `MULTI_AGENT_MODE` (off = ReAct legacy), `AGENT_REFLECTION` (off = sem judge/regen, S5 A4), `HYPERMEM_MODE` (off = prompts ignoram HyperMem tools, S5 A5). Rollback em segundos sem redeploy.
- **Persona:** Coach financeiro nível mundial (Ramsey, Sethi, Kiyosaki, Buffett, Nigro) + SAC da plataforma
- **Especialistas (S5):**
  - `Watcher` (read) — query_finances, analyze_subscriptions, search_transactions, filter_by_tag, **recall_hypermem** (novo S5)
  - `Forecaster` (projeções) — calculate_projection, compare_periods, query_finances
  - `Coach` (conselho) — suggest_savings, debt_freedom_plan, **recall_hypermem** (preferido S5), recall_memories (fallback), query_finances
  - `Planner` (orçamento) — check_budgets, suggest_budget, query_finances
  - `Executor` — **ÚNICO com writes** — save_memory, **save_episode** (novo S5), duplicate_month, confirm_income_installment, confirm_expense_installment, rollback_confirmation
  - `SAC` — platform_help
- **maxTokens:** Editor 900, Specialists 800, Supervisor 300, Judge 300 (temp 0.2 crítico, S5)
- **Actions:** `chat`, `insights`, `parse`, `threads`, `thread_messages`, `delete_thread`
- **Contrato chat:** input `{action, message, threadId}` → output `{reply, threadId, isNewThread, metadata?}`. `metadata` é aditivo não-breaking: `{agents_used, intent, duration_ms, tool_calls, fallback}`.
- **Fallback graceful:** Supervisor falha → ReAct legacy. Todos specialists falham → ReAct legacy. Editor falha → concatenação bruta dos outputs.
- **Observabilidade:** cada request grava N linhas em `agent_runs` (supervisor + specialists + editor).

**2. `send-push` (v3.3.0 — novo em S1)**

- **Localização:** `supabase/functions/send-push/`
- **Stack:** Deno + `npm:web-push@3.6.7` + VAPID
- **Uso:** envia Web Push Notification para subscriptions ativas do user
- **Secrets:** `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, `VAPID_SUBJECT`
- **Auto-cleanup:** remove endpoints expirados (404/410)

**3. `agent-watcher` (v3.4.0 — novo em S2, atualizado S4 v3.6.0)**

- **Localização:** `supabase/functions/agent-watcher/`
- **Stack:** Deno, chamado via Postgres triggers em INSERT
- **Função:** anomaly detection (z-score > 2.5 em histórico 90d de outros_gastos) + alertas de novos parcelamentos/assinaturas
- **Saída:** insere em `alertas` com `severity` + `delivery_channel` (S4). Dispara `send-push` apenas se canal=='push' e hard limit permitir
- **Auth:** header `x-agent-secret` (Vault `agent_internal_secret`) OU service role

**4. `send-digest` (v3.7.0 — novo em S5 A8)**

- **Localização:** `supabase/functions/send-digest/` (`index.ts` + `template.ts`)
- **Stack:** Deno + fetch direto à Resend API (`https://api.resend.com/emails`)
- **Modo batch:** `{batch:true}` via cron — itera `profiles.email_digest_enabled=true` e envia para cada
- **Modo single:** `{user_id}` via service_role ou user JWT (botão "Enviar agora" em Configurações)
- **Modo preview:** `{preview:true, user_id}` retorna HTML renderizado sem enviar (debug)
- **Cron:** `send-digest-weekly` sábado 12 UTC = 09h BRT, usa `vault.decrypted_secrets['agent_internal_secret']`
- **Throttle:** `consumeThrottle(client, userId, 'email')` — hard limit 1/semana (S2)
- **Secrets:** `RESEND_API_KEY` (obrigatório) + `EMAIL_FROM` (default: `'Pulso Finance <onboarding@resend.dev>'`)
- **Dados:** saldo mês + receitas/despesas + gastos 7d vs 7d anteriores + próximos vencimentos + top 3 alertas não-lidos

**5. `agent-supervisor` (v3.4.0 — novo em S2, atualizado S4 v3.6.0)**

- **Localização:** `supabase/functions/agent-supervisor/`
- **Stack:** Deno, chamado por pg_cron 3x/dia
- **Slots:**
  - `morning` (11 UTC = 08h BRT) → briefing de vencimentos hoje (pushWorthy)
  - `afternoon` (17 UTC = 14h BRT) → verificação 7d vs média (push só se variação ≥ 50%)
  - `evening` (23 UTC = 20h BRT) → fechamento do dia (só in-app, sem push)
- **Auth:** mesmo secret do watcher
- **S4:** usa `decideDeliveryChannel(result.severity)` para definir canal antes do insert em alertas

**⚠️ GOTCHA Deploy:** SEMPRE `--no-verify-jwt` em qualquer edge function — sem ela, 100% dos POSTs retornam 401. Documentado em `feedback_supabase_edge_deploy.md`.

### Shared Helpers (v3.4.0 / S4 v3.6.0)

- `supabase/functions/_shared/cors.ts` — CORS dinâmico com Vary: Origin (v3.1+)
- `supabase/functions/_shared/notificationThrottle.ts` — hard limit 1 push/dia + 1 email/semana + `logAgentRun()` para audit trail
- `supabase/functions/_shared/deliveryRouter.ts` (S4 v3.6.0) — `decideDeliveryChannel(severity, nowUtc)` retorna `'push'|'email'|'in-app'|'silent'` baseado em severity + hora BRT. Dia (8h–22h BRT): danger→push, warn→push, success→in-app, info→in-app. Noite: warn→in-app, info→silent. Testável via injeção de `nowUtc`

### Infra Postgres (v3.4.0)

- **Extensões:** `pgcrypto`, `pg_cron`, `pg_net`
- **Cron jobs ativos:** `agent-supervisor-morning/afternoon/evening` + `send-digest-weekly` + `agent-followups-processor` (ler via `cron.job`)
- **Triggers:** `trg_watcher_outros_gastos`, `trg_watcher_parcelamentos`, `trg_watcher_assinaturas` → POST `agent-watcher` com `x-agent-secret`
- **Vault:** secret `agent_internal_secret` (chave compartilhada pg_cron ↔ edge functions)

### Database RPCs — Admin Health (S10 Fase C, v4.6.1)

4 funções `public.admin_*` criadas via migration `s10c_admin_health_rpcs` (arquivo persistido em `supabase/migrations/20260417170000_s10c_admin_health_rpcs.sql`). Consumidas apenas pela página `/admin`.

| RPC                                        | Assinatura     | Retorno                                                                                   | Fonte                               |
| ------------------------------------------ | -------------- | ----------------------------------------------------------------------------------------- | ----------------------------------- |
| `admin_agent_runs_stats(p_hours int = 24)` | 1 arg opcional | `jsonb {total, success, error, p95_ms, avg_ms, by_agent[]}`                               | `public.agent_runs`                 |
| `admin_throttle_stats()`                   | —              | `jsonb {users_tracked, users_with_push_today, sum_pushes_today, sum_emails_week, limits}` | `public.notification_throttle`      |
| `admin_push_subs_stats()`                  | —              | `jsonb {total, active_last_7d, active_last_30d, unique_users}`                            | `public.push_subscriptions`         |
| `admin_cron_jobs_stats()`                  | —              | `jsonb {jobs: [{jobname, schedule, active, last_run, last_status, failures_24h}]}`        | `cron.job` + `cron.job_run_details` |

**Padrão de segurança (único — reusar em qualquer RPC owner-only futura):**

```sql
create or replace function public.admin_X()
returns jsonb language plpgsql security definer
set search_path = public, pg_temp as $$
declare v_email text := (auth.jwt() ->> 'email');
begin
  if v_email is null or v_email <> 'deivithi74@gmail.com' then
    raise exception 'Forbidden';
  end if;
  -- read-only work
end; $$;
revoke all on function public.admin_X() from public, anon;
grant execute on function public.admin_X() to authenticated;
```

**Por que `security definer` foi necessário:** `cron.job` e `cron.job_run_details` exigem privilégios do schema `postgres`. RPC owner-only + gate por email resolve acesso sem expor as tabelas diretamente.

**Consumidores:** `src/hooks/useAdminHealth.ts` via `supabase.rpc('admin_xxx' as never)` — 4 `useQuery` paralelos (staleTime 30s, refetchInterval 60s, retry 0).

### Rota `/admin` (S10 Fase C, v4.6.1)

- **Path:** `/admin` em `src/App.tsx` dentro de `LazyRoute` (mesmo padrão das 11 outras rotas protegidas)
- **Gate:** `src/pages/Admin.tsx` verifica `user.email !== 'deivithi74@gmail.com'` → `<Navigate to="/dashboard" replace />`
- **UX:** read-only. Zero link na `BottomNav` / `AppSidebar` — acesso só por URL direta. 4 seções (Agente 24h, Notificações, Push, Cron) com `ScrollReveal` + `glass-card` + `MetricCard` local
- **Bundle:** chunk `Admin-*.js` = 8.63 kB / 2.67 kB gz (lazy, não infla initial bundle)
- **Defesa em profundidade:** gate frontend + gate server-side (cada RPC valida email novamente). Se um usuário qualquer manipular o client para bater na rota, ainda assim `raise exception 'Forbidden'` bloqueia.

### Virtualização Extrato (S10 Fase C, v4.6.1)

- **Dep:** `@tanstack/react-virtual@^3.13.24` (mesma família do react-query já instalado)
- **Arquivo:** `src/pages/Extrato.tsx` — componentes `DayCard` + `DayItemRow` + `VirtualizedDayFeed`
- **Ativação progressiva:** só quando `days.length > VIRTUALIZE_THRESHOLD (20)`. Abaixo disso preserva o `days.map + ScrollReveal` original de S9.1
- **Scroll element:** `getScrollElement: () => mainRef.current` do `ScrollContext` (o container `<main>` em `AppLayout`). Preserva `PullToRefresh` intacto
- **Measuring:** `estimateSize: (i) => 96 + days[i].items.length * 62` + `measureElement: el => el.getBoundingClientRect().height` para alturas dinâmicas
- **Ganho esperado:** meses com 50+ dias (histórico denso) ficam fluídos no scroll; zero regressão em meses pequenos

---

## 6. Logica de Negocios Critica

### 6.0 Calculos Financeiros Compartilhados

**Arquivo:** `src/lib/financialCalcs.ts` — fonte unica de:

- `calcularCustoMensal(valor, frequencia)` — normaliza assinatura para custo mensal
- `calcularGastosPorCategoria(P, A, OG, mesKey)` — retorna `Record<string, GastoCategoriaBreakdown>`
- `GastoCategoriaBreakdown { parcelamentos, assinaturas, outrosGastos, total }`

**NUNCA duplicar essas funcoes.** Importar sempre de `@/lib/financialCalcs`. Ver Incidente 5 e Gotcha #22.

### 6.1 Formula do Saldo

```
Saldo = Receitas do Mes - Despesas Totais do Mes

Despesas = Parcelas ativas (valor_parcela)
         + Assinaturas ativas (custo mensal normalizado)
         + Outros gastos do mes (nao pausados)

Custo mensal normalizado:
  mensal     → valor
  trimestral → valor / 3
  semestral  → valor / 6
  anual      → valor / 12
```

### 6.2 Confirmacao Mensal (`meses_confirmados`)

Campo `meses_confirmados: text[]` com formato `"YYYY-MM"` em **parcelamentos, receitas e assinaturas**.

- Ao confirmar pagamento/recebimento, o mesKey e adicionado ao array
- Para rollback, o mesKey e removido do array
- `parcelas_pagas` / `parcelas_recebidas` sao mantidos em sync (backward compat)
- Alertas pulsantes aparecem quando o mes atual NAO esta no array
- Helper: `useParcelaConfirmation.ts` (generico para todas as tabelas)
- Helper: `getMesAtual()`, `getMesLabel()`, `isConfirmado()`

### 6.3 Pausar por Mes

Campo `meses_pausados: text[]` com formato `"YYYY-MM"`. Se o mes atual esta no array, o item NAO entra nos calculos.

### 6.4 Receitas Parceladas

- `total_parcelas > 1` e `recorrente = false` → receita parcelada
- `parcela_atual` = parcela de inicio (user define ao criar)
- `parcelas_recebidas` = quantas confirmadas dentro do app
- `meses_confirmados` = quais meses especificos foram confirmados
- Aparecem em N meses consecutivos no Extrato a partir da `data`
- Helper: `receitaParcelaUtils.ts` (getReceitaParcelaForMonth, isReceitaCompleta)

### 6.5 Proximo Vencimento

Se `dia_vencimento >= dia_atual` → mes atual. Senao → proximo mes.

### 6.6 Comparativo Mensal

Compara despesas do mes atual vs anterior. Parcelas e assinaturas sao fixas; a variacao vem dos `outros_gastos`.

---

## 7. Hooks — Mapa Completo

### Core CRUD

| Hook                                            | Tipo            | Dados                                                                                       |
| ----------------------------------------------- | --------------- | ------------------------------------------------------------------------------------------- |
| `useParcelamentos` / `useParcelamentoMutations` | Query+Mutations | CRUD + markAsPaid(mesKey) + rollbackPayment(mesKey)                                         |
| `useAssinaturas` / `useAssinaturaMutations`     | Query+Mutations | CRUD + toggleStatus + updateRating + confirmarPagamento(mesKey) + rollbackPagamento(mesKey) |
| `useReceitas` / `useReceitaMutations`           | Query+Mutations | CRUD + confirmarRecebimento(mesKey) + rollbackRecebimento(mesKey) + confirmarAnteriores     |
| `useParcelaConfirmation`                        | Mutations       | Hook generico confirmar/rollback (tabela parametrizada)                                     |
| `useOutrosGastos` / `useOutrosGastoMutations`   | Query+Mutations | CRUD outros_gastos                                                                          |
| `useCategorias` / `useCategoriaMutations`       | Query+Mutations | CRUD categorias                                                                             |
| `useMetas` / `useMetaMutations`                 | Query+Mutations | CRUD metas financeiras                                                                      |
| `useOrcamentos` / `useOrcamentoMutations`       | Query+Mutations | CRUD orcamentos por categoria/mes                                                           |
| `useProfile`                                    | Query+Mutation  | avatar, full_name, accent_color, ai_settings                                                |

### Agregadores e Analytics

| Hook                    | Dados                                                                  |
| ----------------------- | ---------------------------------------------------------------------- |
| `useDashboardData`      | totalDoPeriodo, saldo, evolucao, projecao, vencimentos, cashflow       |
| `useExtrato`            | Feed unificado (4 tabelas), agrupado por dia, filtros                  |
| `useComparativo`        | Comparacao mes a mes por categoria                                     |
| `useGastosPorCategoria` | Agregacao P+A+OG por categoria com breakdown (usa `financialCalcs.ts`) |
| `useResumoData`         | Dados para Spotify Wrapped                                             |
| `useConquistas`         | Badges desbloqueadas + verificacao                                     |

### IA e Automacao

| Hook                                | Dados                                                  |
| ----------------------------------- | ------------------------------------------------------ |
| `useAiChat`                         | Enviar mensagem ao agente, streaming                   |
| `useAiThreads`                      | CRUD threads de conversa                               |
| `useAiInsights`                     | Insights gerados por IA                                |
| `useWeeklyRecap`                    | Recap semanal gerado por IA                            |
| `useAlertas` / `useAlertaGenerator` | Alertas inteligentes (orcamento 80%/100%, vencimentos) |

### Tags e Categorizacao

| Hook                 | Dados                                          |
| -------------------- | ---------------------------------------------- |
| `useTags`            | CRUD tags + cores automaticas                  |
| `useTransactionTags` | Link/unlink tags a transacoes (polimorfico)    |
| `useCategorySuggest` | Sugestao automatica de categoria por descricao |
| `useCategoryHistory` | Historico de categorizacao para aprendizado    |
| `useDuplicarMes`     | Fetch gastos do mes anterior + batch duplicate |

### UI/UX

| Hook                            | Dados                                                               |
| ------------------------------- | ------------------------------------------------------------------- |
| `useAnimatedCounter`            | Animacao de numeros nos cards                                       |
| `useAccentColor`                | Accent color picker (8 cores, CSS custom property)                  |
| `useMediaQuery` / `useIsMobile` | Responsive breakpoints                                              |
| `useScrollPosition`             | scrollY, isScrolled, scrollDirection (rAF + passive listener)       |
| `useBackGesture`                | Swipe da borda esquerda para voltar (mobile only, touch events raw) |

---

## 8. Padrao de UI/UX (Apple + Google)

### 8.1 Design System (v5.0.0 — identidade profissional "de-AI")

- **Paleta TEAL/PETRÓLEO + GRAFITE** (`src/index.css`): light `--primary: 188 88% 27%` (teal escuro) / dark `--primary: 184 72% 50%` (teal cyan), background dark `200 28% 7%` (grafite profundo). Gradientes **single-family teal** (sem rainbow). **Indigo/violeta/roxo BANIDOS.**
- **Fonte:** `Hanken Grotesk Variable` (via `@fontsource-variable/hanken-grotesk`), `Inter` como fallback. `gradient-text` decorativo removido → ênfase em cor chapada teal (gradient-text era "tell de IA").
- **Dark mode por padrao** com glassmorphism (`backdrop-blur`, borders sutis). Fundo **sólido limpo** — mesh/shader removidos no de-AI.
- **Cores semanticas:** `emerald`=receitas, `teal`=parcelas/assinaturas/score (era indigo/roxo), `rose`=gastos, `amber`=urgente
- **Cards com hover:** `scale-[1.02]`, `border-primary/30`, transicao 300ms
- **Cards com tap:** `whileTap={{ scale: 0.97 }}` em todos os cards interativos (SummaryCard, feature-card)
- **Glass card:** recolorido (teal), **sem sheen** (Liquid Glass sheen removido no de-AI). `border-top` sutil mantido.
- **Animacoes:** contadores animados, skeleton shimmer, spring page transitions, staggered entrance
- **Elevation system:** `.elevation-1` (sutil) / `.elevation-2` (medio) / `.elevation-3` (forte)
- **iOS Typography Scale:** `.ios-large-title` (34px/700), `.ios-title1` (28px), `.ios-title2` (22px), `.ios-headline` (17px/600), `.ios-caption` (12px)

### 8.2 Principios Apple HIG (v3.0 — implementados)

- **Large Title → Compact:** IOSHeader compacta de 28px para 17px inline ao scrollar
- **Bottom Sheets:** todos os modais mobile usam Drawer (vaul) via ResponsiveModal/ResponsiveAlertModal
- **Push/Pop Transitions:** navegacao horizontal (slide da direita PUSH, slide da esquerda POP)
- **Pull-to-Refresh:** rubber-band effect + spinner circular + haptic feedback
- **Back Gesture:** swipe da borda esquerda para voltar
- **Tab Bar:** BottomNav com pill animada (layoutId) + haptic vibrate
- **Tap Feedback:** whileTap em cards, botoes, tabs, FAB
- **Reduced Motion:** todas as animacoes respeitam `prefers-reduced-motion`

### 8.3 Componentes Apple HIG (novos v3.0)

| Componente             | Arquivo                                    | Uso                                                   |
| ---------------------- | ------------------------------------------ | ----------------------------------------------------- |
| `IOSHeader`            | `components/layout/IOSHeader.tsx`          | Large title em todas as 11 paginas protegidas         |
| `IOSSection`           | `components/shared/IOSSection.tsx`         | Agrupamento estilo iOS Settings (disponivel)          |
| `SegmentedControl`     | `components/shared/SegmentedControl.tsx`   | Pill animada para filtros (disponivel)                |
| `PullToRefresh`        | `components/shared/PullToRefresh.tsx`      | Dashboard, Parcelamentos, Assinaturas, Extrato        |
| `ResponsiveAlertModal` | `components/ui/responsive-alert-modal.tsx` | Delete/Cancel confirmations (3 dialogs)               |
| `ScrollContext`        | `contexts/ScrollContext.tsx`               | Provider no AppLayout, IOSHeader + AppHeader consomem |

### 8.3.2 Experiencia Multimodal (S7 v3.9.0)

Voz bidirecional, long-press reveal, haptics coreografados, ambient sounds opt-in e cursor reactive. Tudo respeita `prefers-reduced-motion` e tem fallback silencioso se o browser nao suportar.

| Arquivo                              | Responsabilidade                                                                                                                                                                         |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `lib/hapticPatterns.ts`              | 7 padroes nomeados (tap/swipe/success/error/reveal/celebration/milestone) + `runPattern(name, enabled)` lib-level. Fonte unica — `navigator.vibrate` direto proibido fora deste arquivo. |
| `hooks/useHaptics.ts`                | Hook tipado respeita `profiles.haptics_enabled` + reduced-motion                                                                                                                         |
| `hooks/useVoiceChat.ts`              | STT (SpeechRecognition pt-BR) + TTS (speechSynthesis). Fallback silencioso.                                                                                                              |
| `hooks/useLongPress.ts`              | Pointer events raw com `moveTolerance` + cleanup em pointerleave/cancel                                                                                                                  |
| `hooks/useAmbientSounds.ts`          | 4 SFX sintetizados 100% via Web Audio (ching/sparkle/thump/chime). Zero mp3, AudioContext lazy.                                                                                          |
| `hooks/useCursorProximity.ts`        | Distance/near de um ref ao cursor global (desktop only)                                                                                                                                  |
| `contexts/CursorContext.tsx`         | UM listener global rAF-throttled compartilhado                                                                                                                                           |
| `components/ai/VoiceInput.tsx`       | Botao mic toggle com indicador pulsante                                                                                                                                                  |
| `components/shared/DetailReveal.tsx` | Overlay spring Framer em cards                                                                                                                                                           |

**Novas colunas em `profiles` (migration `s7_sensory_preferences`):**

- `voice_enabled` boolean default false
- `voice_autoplay` boolean default false
- `haptics_enabled` boolean default true
- `ambient_sounds_enabled` boolean default false

**Regras invioliveis:**

- `navigator.vibrate` direto fora de `lib/hapticPatterns.ts` = proibido (usar `useHaptics()` em componentes React, `runPattern()` em lib)
- `AudioContext` so cria sob primeira interacao (autoplay policy)
- `CursorProvider` so em `AppLayout` — NUNCA mountar em outro lugar
- Feature detection em cascata: STT/TTS/Vibrate/AudioContext sem suporte = UI esconde botao, hook no-op, zero erro

### 8.3.1 UI Hipnotica (S6 v3.8.0 — PARCIALMENTE REVERTIDA em v5.0.0)

> ⚠️ **Estado v5.0.0:** o de-AI (`8a3f3e7`) removeu a camada de **fundo mesh/shader**. O que reagia ao "mood do Orb" via fundo colorido **não existe mais** — fundo agora é sólido limpo. Sobreviveram apenas os utilitários de scroll/tempo e o reveal.

**❌ Removido em v5.0.0 (NÃO readicionar):**

- `MeshGradientBg` (`components/shared/MeshGradientBg.tsx`) — fundo conic-gradient
- `ShaderMeshBg` (S13-B) — fundo shader WebGL
- `useMeshMood` (`hooks/useMeshMood.ts`) — mood→cor do fundo
- `useGlassSheen` + `useCanRenderShader` — sheen/progressive-enhancement do shader

**✅ Sobreviveu (ativo no `main`):**

| Peca                | Arquivo                              | Responsabilidade                                                                                       |
| ------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------ |
| `useTimeOfDay`      | `hooks/useTimeOfDay.ts`              | `getTimeOfDay` de `personalityMoments.ts`. Expoe `{ period, luminance, hueShift }`. Refresh 15min.     |
| `useScrollDepth`    | `hooks/useScrollDepth.ts`            | Le `scrollY` do `ScrollContext`, escreve `--glass-shadow-depth` no `documentElement` (throttle 100ms). |
| `useOrbState`       | `hooks/useOrbState.ts`               | Mood do Orb (success/neutral/warning/danger) — consumido pelo `PulsoOrb`/`PulsoOrb3D`.                 |
| `ScrollReveal`      | `components/shared/ScrollReveal.tsx` | Wrapper Framer Motion `whileInView` + fallback `@supports (animation-timeline: view())`.               |
| `IOSHeader` (turbo) | `components/layout/IOSHeader.tsx`    | Aplica `letterSpacing` + `filter: blur` via `useTransform` ao scrollar.                                |

**CSS custom properties (sobreviventes):**

- `--glass-shadow-depth` — driver do box-shadow do `.glass-card` (via `useScrollDepth`).
- `--pulso-luminance` — `filter: brightness()` por hora do dia (via `useTimeOfDay`).
- _(`--mesh-opacity` / `--pulso-hue-shift` eram do mesh removido — verificar no `index.css` se ainda há resíduo antes de reusar.)_

**Regras invioliveis:**

- `.glass-card` herda box-shadow de `--glass-shadow-depth`. Ao adicionar cards novos, **não** reintroduzir `shadow-*` hardcoded.
- Cards de destaque: usar `.glass-card-floating`.
- **NÃO readicionar mesh/shader de fundo** — foi decisão arquitetural de-AI (constitution + gotchas). Fundo sólido é intencional.
- `@supports (animation-timeline: view())` só em Chrome 115+/Safari TP; fallback Framer Motion cobre o resto.

### 8.4 Principios Google Material

- **Surfaces responsivas:** elevation com sombras e borders
- **Cores com proposito:** cada cor comunica um significado
- **Motion com significado:** animacoes que guiam o olhar
- **Densidade adaptativa:** mais info no desktop, mais foco no mobile

### 8.5 Anti-patterns a Evitar

- Cards sem hierarquia (tudo igual)
- Grid perfeita sem variacao
- Textos longos em cards
- Botoes sem contraste suficiente
- Loading states ausentes
- **Dialog no mobile** — usar ResponsiveModal (bottom sheet) sempre
- **Select para filtros com poucas opcoes** — usar SegmentedControl
- **Animacoes sem prefers-reduced-motion** — SEMPRE checar
- **🚫 "Cara de IA" (banido em v5.0.0 — constitution):**
  - Indigo / violeta / roxo na paleta (usar teal/petróleo)
  - Gradientes rainbow / multi-hue (só single-family teal)
  - `gradient-text` decorativo em texto (usar cor chapada)
  - Ícone `Sparkles` decorativo
  - Fundo animado / mesh / shader (fundo é sólido limpo)

---

## 9. Deploy e CI/CD

### Fluxo

```
git push origin main
    → Vercel detecta via webhook GitHub
    → npm install → npm run build (Vite)
    → Deploy dist/ → CDN global
    → ~25 segundos ate Ready
    → https://pulsofinance.vercel.app
```

### Verificar deploy

```bash
cd "C:/Users/PC/Documents/VS CODE/pulsofinance"
npx vercel ls --yes 2>&1 | head -5
```

### Headers de seguranca (vercel.json)

- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- Cache imutavel para `/assets/*`

---

## 10. Checklist Pre-Deploy

```
□ npm run build — zero erros TypeScript?
□ npm test — testes passando?
□ git diff — so arquivos esperados?
□ Env vars sensiveis NAO estao no commit?
□ Lazy-loading preservado (paginas + PDF)?
□ RLS intacto (nao adicionou tabela sem policy)?
□ Saldo calcula correto (sem duplicacao)?
□ Mobile: bottom nav funciona?
```

---

## 11. Workflow de Tarefas

### Para QUALQUER tarefa no Pulso Finance:

```
1. CONTEXTUALIZAR — Ler skill + references + gotchas
2. EXPLORAR — git status, verificar estado atual do codigo
3. PLANEJAR — Mapear impacto nos calculos de saldo/dashboard
4. EXECUTAR — Editar com type-safety, sem quebrar RLS
5. VERIFICAR — npm run build + npm test
6. ENTREGAR — Commit descritivo + push + confirmar deploy
```

### Para adicionar NOVA FUNCIONALIDADE:

```
1. A tabela ja existe no Supabase? Se nao, criar via Dashboard (NUNCA via SQL local)
2. Adicionar tipos em types.ts
3. Criar hook useX + useXMutations
4. Criar pagina/componente
5. Adicionar rota em App.tsx (lazy-loaded)
6. Adicionar no sidebar + bottom nav
7. Integrar no useDashboardData se afetar saldo
8. Atualizar exports (CSV + PDF)
9. Atualizar docs/README.md
10. Build + test + commit + push
```

---

## 12. Acesso Direto

### Comandos uteis

```bash
# Navegar para o projeto
cd "C:/Users/PC/Documents/VS CODE/pulsofinance"

# Dev server
npm run dev    # http://localhost:8080

# Build + test
npm run build && npm test

# Deploy status
npx vercel ls --yes 2>&1 | head -5

# Git history
git log --oneline -10

# Verificar Supabase (via MCP)
# Use mcp__claude_ai_Supabase__execute_sql ou mcp__claude_ai_Supabase__list_tables
```

### Links

- **App:** https://pulsofinance.vercel.app
- **Repo:** https://github.com/deivithi/pulsofinance
- **Supabase:** https://supabase.com/dashboard/project/txbzynnszuvjnmhbnnzh

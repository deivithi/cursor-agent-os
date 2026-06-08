# Pulso Finance — Arquitetura Completa

> Referencia tecnica para o assistente. Consulte sempre que precisar entender a estrutura.
> **Ultima atualizacao:** 2026-05-24 (v5.0.0 — identidade de-AI + Agent Memory v2 pgvector). Skill sincronizada via GitHub em 2026-06-01.
>
> ⚠️ Partes deste file-tree refletem fases antigas (v3.x). Pontos-chave atualizados para v5.0.0 inline. Em dúvida sobre existência de um arquivo, confirmar via `gh api repos/deivithi/pulsofinance/contents/<path>?ref=main` (conta `deivithi`).

## Estrutura de Arquivos

```
pulsofinance/
├── public/
│   ├── logo.png
│   ├── logo.webp
│   ├── manifest.json          # PWA manifest (Fase 5)
│   └── sw.js                  # Service Worker — network-first (Fase 5)
├── src/
│   ├── main.tsx                    # Entry point + SW registration
│   ├── App.tsx                     # 11 rotas + providers
│   ├── index.css                   # Tailwind + design system (dark/light vars, glassmorphism)
│   ├── vite-env.d.ts
│   ├── contexts/
│   │   ├── AuthContext.tsx          # Supabase Auth (signIn, signUp, signOut, onAuthStateChange)
│   │   └── ScrollContext.tsx        # ScrollProvider: scrollY, isScrolled, pageTitle [v3.0]
│   ├── integrations/
│   │   └── supabase/
│   │       ├── client.ts            # createClient com persistSession + autoRefreshToken
│   │       └── types.ts             # Tipos gerados: 25 tabelas + enums + functions (+ RPCs admin_* e match_ai_*) [v5.0.0]
│   ├── hooks/
│   │   ├── useParcelamentos.ts      # Query com join em categorias
│   │   ├── useParcelamentoMutations.ts  # create, update, delete, markAsPaid (confetti!)
│   │   ├── useAssinaturas.ts        # Query com filtro opcional
│   │   ├── useAssinaturaMutations.ts    # create, update, cancel
│   │   ├── useReceitas.ts           # Query com filtro por categoria
│   │   ├── useReceitaMutations.ts   # create, update, delete (com meses_pausados)
│   │   ├── useOutrosGastos.ts       # Query com filtro por categoria
│   │   ├── useOutrosGastoMutations.ts   # create, update, delete (com meses_pausados)
│   │   ├── useCategorias.ts         # Query simples
│   │   ├── useCategoriaMutations.ts # create, update, delete + defaults
│   │   ├── useDashboardData.ts      # AGREGADOR PRINCIPAL — calcula tudo
│   │   ├── useOrcamentos.ts         # Orcamentos por categoria/mes (Fase 5)
│   │   ├── useOrcamentoMutations.ts # CRUD orcamentos (Fase 5)
│   │   ├── useGastosPorCategoria.ts # Gastos reais por categoria para orcamento (Fase 5)
│   │   ├── useAlertas.ts           # Alertas inteligentes — query + mutations (Fase 5)
│   │   ├── useAlertaGenerator.ts   # Gera alertas automaticamente 1x/sessao (Fase 5)
│   │   ├── useWeeklyRecap.ts       # Resumo semanal IA (Fase 5)
│   │   ├── useAiChat.ts            # Chat com agente IA
│   │   ├── useAiInsights.ts        # Insights IA para dashboard
│   │   ├── useAiThreads.ts         # Gerenciamento de threads
│   │   ├── useExtrato.ts           # Agrega 4 tabelas em timeline unificada (Fase 6)
│   │   ├── useComparativo.ts       # Comparativo mensal por categoria (Fase 6)
│   │   ├── useCategorySuggest.ts   # Sugestao de categoria por descricao (Fase 6)
│   │   ├── useCategoryHistory.ts   # Registra historico descricao↔categoria (Fase 6)
│   │   ├── useConquistas.ts        # Gamificacao — badges
│   │   ├── useMetas.ts / useMetaMutations.ts  # Metas financeiras
│   │   ├── useProfile.ts           # Query + update perfil
│   │   ├── useResumoData.ts        # Dados para Spotify Wrapped
│   │   ├── useAnimatedCounter.ts   # Animacao spring para numeros
│   │   ├── useScrollPosition.ts   # scrollY, isScrolled, scrollDirection (rAF) [v3.0]
│   │   ├── useBackGesture.ts      # Swipe borda esquerda → navigate(-1) [v3.0]
│   │   └── use-toast.ts            # Toast notifications
│   ├── pages/
│   │   ├── Index.tsx                # Landing publica (Header + Hero + Features + Footer)
│   │   ├── Login.tsx / Cadastro.tsx # Auth
│   │   ├── Dashboard.tsx            # Score + cards + charts + widgets + AI chat FAB
│   │   ├── Parcelamentos.tsx        # CRUD + tabela expandida + export CSV/PDF
│   │   ├── Assinaturas.tsx          # CRUD + cards + audit + export
│   │   ├── Receitas.tsx             # CRUD + pausar/ativar + export
│   │   ├── OutrosGastos.tsx         # CRUD + pausar/ativar + export
│   │   ├── Extrato.tsx              # Timeline unificada + importacao CSV (Fase 6)
│   │   ├── Comparativo.tsx          # Mes vs mes visual (Fase 6)
│   │   ├── Orcamento.tsx            # Budget por categoria — barras YNAB (Fase 5)
│   │   ├── Resumo.tsx               # Spotify Wrapped (Fase 2)
│   │   ├── Categorias.tsx           # CRUD + criar defaults
│   │   ├── Configuracoes.tsx        # Avatar + delete account + [preferencias WIP]
│   │   └── NotFound.tsx             # 404
│   ├── components/
│   │   ├── ui/                      # 40+ componentes shadcn/ui (Radix primitives)
│   │   │   ├── responsive-modal.tsx     # Dialog desktop, Drawer mobile (forms)
│   │   │   └── responsive-alert-modal.tsx # AlertDialog desktop, Drawer mobile (confirmacoes) [v3.0]
│   │   ├── layout/
│   │   │   ├── AppLayout.tsx        # ScrollProvider + Sidebar + Header + Outlet + BottomNav + FAB + BackGesture
│   │   │   ├── AppSidebar.tsx       # 11 itens, drawer mobile, liquid glass
│   │   │   ├── AppHeader.tsx        # Breadcrumb desktop | Compact title mobile (scroll-driven) [v3.0]
│   │   │   ├── BottomNav.tsx        # 5 itens, pill animada layoutId, haptic, whileTap [v3.0]
│   │   │   ├── IOSHeader.tsx        # Large title → compact (28px→17px, scroll-driven) [v3.0]
│   │   │   ├── PageTransition.tsx   # Push/pop iOS mobile, fade desktop [v3.0]
│   │   │   └── QuickTransactionFAB.tsx  # Speed dial + spring animation + backdrop blur [v3.0]
│   │   ├── dashboard/
│   │   │   ├── SummaryCard.tsx      # Card generico (icone, valor animado, trend, link)
│   │   │   ├── PulsoScore.tsx       # Score 0-100 (Fase 1)
│   │   │   ├── WhatIfSimulator.tsx  # Simulador cancelamento (Fase 1)
│   │   │   ├── CashflowForecast.tsx # Previsao 12 meses (Fase 3)
│   │   │   ├── DebtPayoffDashboard.tsx  # Snowball vs Avalanche (Fase 2)
│   │   │   ├── InsightsInteligentes.tsx # IA + fallback estatico (Fase 4)
│   │   │   ├── BudgetSummaryWidget.tsx  # Top 3 orcamentos (Fase 5)
│   │   │   ├── WeeklyRecapCard.tsx  # Resumo semanal IA (Fase 5)
│   │   │   ├── NotificationBell.tsx # Tabs: Alertas + Vencimentos (Fase 5)
│   │   │   ├── MetasFinanceiras.tsx # Metas + gamificacao (Fase 2)
│   │   │   ├── ConquistasDisplay.tsx # Badges (Fase 2)
│   │   │   └── ... (charts, filters, header, onboarding, etc.)
│   │   ├── ai/
│   │   │   ├── AiChat.tsx           # Chat full-featured com threads (Fase 4)
│   │   │   └── AiChatButton.tsx     # FAB flutuante
│   │   ├── orcamento/               # BudgetProgressBar, OrcamentoForm (Fase 5)
│   │   ├── extrato/                 # ImportarExtratoDialog (Fase 6)
│   │   ├── shared/
│   │   │   ├── ExportButton.tsx
│   │   │   ├── GastosPorCategoriaChart.tsx
│   │   │   ├── InstallBanner.tsx    # PWA install (Fase 5)
│   │   │   ├── IOSSection.tsx       # Agrupamento estilo iOS Settings [v3.0]
│   │   │   ├── PullToRefresh.tsx    # Rubber-band + spinner (mobile only) [v3.0]
│   │   │   └── SegmentedControl.tsx # Pill animada para filtros [v3.0]
│   │   ├── parcelamentos/ assinaturas/ categorias/ configuracoes/ landing/
│   │   ├── Logo.tsx, NavLink.tsx, ThemeToggle.tsx, ProtectedRoute.tsx
│   └── lib/
│       ├── utils.ts                 # cn() + helpers
│       ├── calculatePulsoScore.ts   # Score 0-100 (Fase 1)
│       ├── cashflowProjection.ts    # Forecast 12 meses (Fase 3)
│       ├── debtStrategies.ts        # Snowball/Avalanche (Fase 2)
│       ├── conquistas.ts            # Engine de badges (Fase 2)
│       ├── confetti.ts              # canvas-confetti wrapper (Fase 1)
│       ├── buildFinancialContext.ts  # Contexto para IA
│       ├── parseCSVExtrato.ts       # Parser universal CSV bancario (Fase 6)
│       ├── exportUtils.ts           # CSV exports
│       └── exportPdfUtils.ts        # PDF premium (lazy-loaded, 430kB)
├── supabase/
│   ├── functions/
│   │   ├── _shared/cors.ts          # getCorsHeaders(req) — dinamico com Vary: Origin
│   │   └── ai-agent/
│   │       ├── index.ts             # LangGraph ReAct agent + actions (chat/insights/parse/threads)
│   │       ├── tools.ts             # 17 DynamicStructuredTools com Zod (+ recall_hypermem/save_episode) — ver embeddings.ts + orchestrator/
│   │       └── memory.ts            # Thread + message persistence
│   └── migrations/
│       └── all.sql + migrations (inclui 20260417170000_s10c_admin_health_rpcs.sql + 20260524120000_agent_memory_v2_pgvector.sql)
├── index.html                       # PWA meta tags + manifest link
├── vercel.json, vite.config.ts, tailwind.config.ts, package.json
```

> **Deltas pós-v3.x (não totalmente refletidos no tree acima — fonte: GitHub `main`):**
>
> - **Páginas:** +`Admin.tsx` (S10 — rota `/admin` owner-only, lazy, gate por email `deivithi74@gmail.com`)
> - **Hooks novos:** `useAdminHealth` (S10), `useTags`/`useTransactionTags` (Fase 8), `useDuplicarMes`, `useCelebration` (S9.4), `useHaptics`/`useVoiceChat`/`useLongPress`/`useAmbientSounds`/`useCursorProximity` (S7), `useScrollDepth`/`useTimeOfDay`/`useOrbState` (S6), `useOrcamentoMutations` com `pausarMes`/`despausarMes`/`isOrcamentoAtivo` (S12)
> - **Components shared novos:** `OdometerNumber`, `TagInput`, `DetailReveal`, `ScrollReveal`, `SwipeableRow`, `SegmentedControl`, `PullToRefresh`, `IOSSection`
> - **AI:** `PulsoOrb.tsx` + `PulsoOrb3D.tsx` (Three.js — `src/components/ai/`)
> - **Edge functions completas:** `ai-agent/` (+ `embeddings.ts` + `orchestrator/` com supervisor/editor/reflection/6 specialists), `send-push/`, `agent-watcher/`, `agent-supervisor/`, `send-digest/`, `_shared/notificationThrottle.ts` + `deliveryRouter.ts`
> - **❌ Removidos no de-AI (v5.0.0):** `MeshGradientBg`, `ShaderMeshBg`, `useMeshMood`, `useGlassSheen`, `useCanRenderShader`

## Providers (App.tsx)

```
ThemeProvider (next-themes, default=dark)
  → QueryClientProvider (TanStack, staleTime=2min)
    → TooltipProvider (Radix)
      → Toaster + Sonner
        → BrowserRouter
          → AuthProvider (Supabase)
            → Routes (11 protegidas + 3 publicas + 404)
```

## Rotas

| Rota             | Pagina                  | Tipo      |
| ---------------- | ----------------------- | --------- |
| `/`              | Landing                 | Publica   |
| `/login`         | Login                   | Publica   |
| `/cadastro`      | Cadastro                | Publica   |
| `/dashboard`     | Dashboard               | Protegida |
| `/parcelamentos` | Parcelamentos           | Protegida |
| `/assinaturas`   | Assinaturas             | Protegida |
| `/receitas`      | Receitas                | Protegida |
| `/outros-gastos` | Outros Gastos           | Protegida |
| `/extrato`       | Extrato Unificado       | Protegida |
| `/comparativo`   | Comparativo Mensal      | Protegida |
| `/orcamento`     | Orcamento por Categoria | Protegida |
| `/resumo`        | Resumo (Wrapped)        | Protegida |
| `/categorias`    | Categorias              | Protegida |
| `/configuracoes` | Configuracoes           | Protegida |

## Banco de Dados — Schema Completo (25 tabelas — atualizado S10 2026-04-17)

> Auditoria S10: o Supabase `txbzynnszuvjnmhbnnzh` tem hoje **25 tabelas** em `public`, todas com RLS habilitado. As 7 tabelas abaixo foram adicionadas durante S1-S8 e estão cobertas pelo `DeleteAccountDialog`:
>
> - S1: `push_subscriptions` (Web Push subscriptions VAPID)
> - S2: `agent_runs` (audit trail do agente), `notification_throttle` (rate limiting 1 push/dia, 1 email/semana)
> - S5: `ai_episodes`, `ai_topics` (HyperMem hierarquico: memories → episodes → topics)
> - S8: `agent_followups` (follow-ups agendados), `agent_goal_proposals` (metas sugeridas pela IA)

### Core (originais)

| Tabela          | Campos-chave                                                                                                                                                                           | RLS           |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| `categorias`    | id, user_id, nome, cor, icone                                                                                                                                                          | Per-user      |
| `parcelamentos` | id, user_id, descricao, valor_total, valor_parcela, parcelas_pagas, total_parcelas, dia_vencimento, categoria_id, status                                                               | Per-user      |
| `assinaturas`   | id, user_id, nome, valor, frequencia, dia_cobranca, categoria_id, status, uso_rating                                                                                                   | Per-user      |
| `receitas`      | id, user_id, descricao, valor, data, recorrente, frequencia, meses_pausados[]                                                                                                          | Per-user      |
| `outros_gastos` | id, user_id, descricao, valor, data, categoria_id, meses_pausados[]                                                                                                                    | Per-user      |
| `profiles`      | id (=auth.users.id), avatar_url, full_name, accent_color, ai_about_me, ai_response_style, email_digest_enabled, voice_enabled, voice_autoplay, haptics_enabled, ambient_sounds_enabled | Per-user      |
| `user_roles`    | id, user_id, role (admin/moderator/user)                                                                                                                                               | Admin-visible |

### IA (Fase 4)

| Tabela        | Campos-chave                                      | RLS      |
| ------------- | ------------------------------------------------- | -------- |
| `ai_threads`  | id, user_id, title, created_at, updated_at        | Per-user |
| `ai_messages` | id, thread_id, user_id, role, content, created_at | Per-user |

### Fase 5

| Tabela       | Campos-chave                                                                                                                                                                | RLS      |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| `orcamentos` | id, user_id, categoria_id, valor_limite, **meses_pausados[]** (S12), mes + recorrente (DEPRECATED) — constraint `UNIQUE(user_id, categoria_id)` template global cross-month | Per-user |
| `alertas`    | id, user_id, tipo, titulo, descricao, lido, metadata                                                                                                                        | Per-user |
| `ai_recaps`  | id, user_id, semana, conteudo (JSONB), lido                                                                                                                                 | Per-user |

### Fase 6

| Tabela                 | Campos-chave                                         | RLS      |
| ---------------------- | ---------------------------------------------------- | -------- |
| `categorias_historico` | id, user_id, descricao_lower, categoria_id, contagem | Per-user |

### IA Agent Memory — HyperMem + pgvector (S5 + S13)

| Tabela        | Campos-chave                                                             | RLS      |
| ------------- | ------------------------------------------------------------------------ | -------- |
| `ai_memories` | id, user_id, content, source, confidence, **embedding vector(384)** (v2) | Per-user |
| `ai_episodes` | id, user_id, ..., **embedding vector(384)** (v2)                         | Per-user |
| `ai_topics`   | id, user_id, ... (hierarquia: memories → episodes → topics)              | Per-user |

- **pgvector** (migration `20260524120000_agent_memory_v2_pgvector.sql`): extensão `vector`, índices HNSW (cosine) em `ai_memories.embedding` + `ai_episodes.embedding`, RPCs `match_ai_memories` + `match_ai_episodes`.
- **Embeddings:** `gte-small` (384-dim) via `globalThis.Supabase.ai.Session` em `ai-agent/embeddings.ts` — nativo Edge, custo zero, sem API key, best-effort (não bloqueia save).
- **25 tabelas no total** + 4 RPCs admin (`admin_agent_runs_stats`, `admin_throttle_stats`, `admin_push_subs_stats`, `admin_cron_jobs_stats`) + 2 RPCs match.

### AI Agent — 17+ Tools (LangGraph + LangChain)

| #   | Tool                          | Funcao                                        |
| --- | ----------------------------- | --------------------------------------------- |
| 1   | `query_finances`              | RAG principal — dados completos do usuario    |
| 2   | `analyze_subscriptions`       | Ranking, custo total, oportunidades de corte  |
| 3   | `calculate_projection`        | Projecao 6 meses com cashflow                 |
| 4   | `compare_periods`             | Mes vs mes / trimestre vs trimestre           |
| 5   | `suggest_savings`             | Top 3 oportunidades de economia               |
| 6   | `debt_freedom_plan`           | Plano quitacao snowball/avalanche             |
| 7   | `check_budgets`               | Status dos orcamentos vs gastos reais         |
| 8   | `suggest_budget`              | Sugerir orcamento baseado em historico        |
| 9   | `search_transactions`         | Busca em todas as tabelas (inclui receitas)   |
| 10  | `save_memory`                 | Salvar fato sobre o usuario (cross-thread)    |
| 11  | `recall_memories`             | Recuperar memorias salvas                     |
| 12  | `filter_by_tag`               | Filtrar transacoes por tag                    |
| 13  | `duplicate_month`             | Duplicar gastos do mes anterior               |
| 14  | `confirm_income_installment`  | Confirmar recebimento de parcela de receita   |
| 15  | `confirm_expense_installment` | Confirmar pagamento de parcela                |
| 16  | `rollback_confirmation`       | Desfazer confirmacao de pagamento/recebimento |
| 17  | `platform_help`               | SAC da plataforma (10 topicos)                |

> **+ Tools Agent Memory v2 (S5/S13):** `recall_hypermem` (busca hierárquica memories+episodes via `match_*` em paralelo) e `save_episode` (grava episódio com embedding). `recall_memories` (#11) agora tenta busca **semântica** (pgvector `match_ai_memories`) com fallback keyword/confiança.

### Storage

- Bucket `avatars` (publico) — upload restrito ao proprio `user_id`

### Env Vars

| Variavel                        | Descricao                                  |
| ------------------------------- | ------------------------------------------ |
| `VITE_SUPABASE_URL`             | `https://txbzynnszuvjnmhbnnzh.supabase.co` |
| `VITE_SUPABASE_PUBLISHABLE_KEY` | Anon key                                   |
| `OPENROUTER_API_KEY`            | Supabase secret — para Edge Functions      |

**Env vars adicionais em prod (além das 3 acima):**

- Frontend (`VITE_`): `VITE_SENTRY_DSN`
- Build (Vercel): `SENTRY_AUTH_TOKEN` (secret), `SENTRY_ORG` = `deivithi-silva-lopes-382357278`, `SENTRY_PROJECT` = `pulsofinance`
- Edge secrets (Supabase): `VAPID_PUBLIC_KEY` / `VAPID_PRIVATE_KEY` / `VAPID_SUBJECT` (push), `RESEND_API_KEY` / `EMAIL_FROM` (digest), `AGENT_REFLECTION` + `HYPERMEM_MODE` + `MULTI_AGENT_MODE` (flags IA, default off)
- Vault: `agent_internal_secret` (chave compartilhada pg_cron ↔ edge functions)

## Code Splitting (vite.config.ts)

```
manualChunks:
  vendor-react     → react, react-dom, react-router-dom
  vendor-supabase  → @supabase/supabase-js
  vendor-ui        → 10 Radix primitives
  vendor-forms     → react-hook-form, @hookform/resolvers, zod
  vendor-charts    → recharts
  vendor-date      → date-fns, react-day-picker
  vendor-query     → @tanstack/react-query
```

Todas as paginas protegidas sao **lazy-loaded** via `React.lazy()` + `Suspense`.
O modulo de PDF (`exportPdfUtils.ts`) usa `import()` dinamico no clique.

**Chunks adicionais (v5.0.0):** `Admin-*.js` (~8.6 kB / 2.67 kB gz — rota `/admin` lazy, S10) + chunk Three.js/R3F do `PulsoOrb3D` (lazy, não infla o bundle inicial).

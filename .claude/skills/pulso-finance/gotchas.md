# Pulso Finance — Gotchas

> Problemas conhecidos e armadilhas. Consulte SEMPRE antes de editar.

## ⚠️ S11 — Vercel free plan tem limite de 100 deploys/dia

Ao deployar Sprint S11 (2026-04-17) o limite foi atingido: `Error: Resource is limited - try again in 24 hours (more than 100, code: "api-deployments-free-per-day")`. Reset em 24h.

**Implicações:**

- `vercel deploy --prod` e push para GitHub acionam o mesmo contador
- Atingir o limite bloqueia ambos até o reset
- Empty commits (`git commit --allow-empty`) podem ser ignorados pelo webhook Vercel OU contar no rate limit — imprevisível

**Como evitar:**

- Consolidar múltiplas mudanças em 1 único commit antes de push
- NÃO fazer empty commits só para "triggar redeploy" — ou arrisca o limite ou é ignorado
- Para forçar rebuild pós-mudança de env var sem estourar limite: fazer alteração real mínima (ex: bump de CACHE_NAME no sw.js) em vez de empty commit

**Quando acontece em sessão:** concluir as mudanças de código, anotar pendências em `project_pulso_evolution.md` + SKILL.md `Status Atual`, e retomar na sessão seguinte quando a quota resetar.

## ⚠️ S11 Cleanup — CSP `connect-src` DEVE incluir domínio de observabilidade externa

O commit `db5727a` (S11 C1) instalou Sentry frontend e setou env vars corretamente, mas **Sentry ficou silenciosamente inoperante em produção** até `7778431` (2026-04-18). Motivo: o CSP em `vercel.json:44` tinha `connect-src 'self' https://*.supabase.co https://openrouter.ai` — browser bloqueia 100% dos POSTs do Sentry com CSP violation, mesmo com DSN inlinado no bundle e `Sentry.init` rodando normal.

**Regra:** ao integrar qualquer ferramenta de observabilidade ou API externa (Sentry, Datadog, LogRocket, PostHog, etc.), **editar `vercel.json:44` junto com o código**. Checklist obrigatório:

1. Código com import/client da ferramenta ✅
2. Env vars Production (Vercel dashboard) ✅
3. **`connect-src` do CSP inclui o domínio da ferramenta** ← esquecer isso = feature 100% inerte
4. Testar em prod (não confiar que "iniciou sem erro" → iniciou OK mas fetch foi bloqueado)

**Atualmente permitidos em `connect-src`:** `'self' https://*.supabase.co https://openrouter.ai https://*.ingest.sentry.io`. Wildcard Sentry cobre `us./de./eu.` realms sem refatorar.

**Validação pós-deploy:** `curl -sI https://pulsofinance.vercel.app | grep -i content-security-policy | grep -o <dominio>` — DEVE retornar match. Sem match = feature silenciosamente quebrada.

## ⚠️ S11 — `vercel env add NAME preview` tem bug no CLI v50+

Comando `npx vercel env add VITE_SENTRY_DSN preview --value "xxx" --yes` retorna JSON com sugestões em vez de adicionar a variável. Reprodutível mesmo com `--force`, `--non-interactive` global flag, `stdin < /dev/null`, etc.

**Causa:** CLI detecta agente rodando e exige `git-branch` posicional OU confirmação interativa explícita para "all Preview branches" — e nenhum flag atual força o "all branches".

**Workaround aceito:** setar Preview DSN via dashboard Vercel → Settings → Environment Variables → Add (30 segundos, UI funciona corretamente).

**Alternativa CLI:** passar branch específica: `vercel env add NAME preview <branch> --value "xxx" --yes`. Funciona mas aplica só àquela branch — não a todas as previews.

**Production funciona normal:** `vercel env add NAME production --value "xxx" --yes` sem problema.

## ⚠️ S11 — Sentry `ignoreErrors` canônico (não reduzir sem substituir)

Desde v4.7.0 (Sprint S11, Parte 1) `src/main.tsx` inicializa o Sentry com uma lista **canônica** de erros que NÃO devem virar issue. Reduzir essa lista sem substituto vai inundar o free tier com ruído do browser.

```ts
ignoreErrors: [
  'ResizeObserver loop limit exceeded',                  // Chrome benign loop
  'ResizeObserver loop completed with undelivered notifications',
  'Non-Error promise rejection captured',                // lib de terceiros rejeita string
  /^Load failed$/,                                       // Safari fetch abortado
  /^NetworkError when attempting/,                       // Firefox fetch abortado
  /^AbortError/,                                         // user navegou enquanto fetch estava in-flight
  /^NotAllowedError/,                                    // autoplay policy (S7 sons)
],
```

**Por que:** nenhum desses é bug do app — são ruídos esperados de navegador, lib externa ou comportamento do user. Free tier do Sentry são 5k erros/mês; sem filtro, um único dia de uso normal já esgota a cota em `ResizeObserver loop`.

**Como estender:** adicionar novo padrão SEMPRE com comentário explicando a origem. Nunca remover item existente sem substituir por algo mais específico.

**Verificação:** `grep -n "ignoreErrors" src/main.tsx` deve retornar a lista acima (ou versão estendida).

## ⚠️ S11 — `useAlertaGenerator` tem debounce 30s (não reduzir sem motivo)

Desde v4.7.0, `useAlertaGenerator.ts` exporta `ALERTA_DEBOUNCE_MS = 30_000`. O hook agora dispara em 3 triggers (mount, `visibilitychange → visible`, invalidação de `['alertas']` via mutations) e o debounce protege contra thrashing:

- Tab-switch rápido dispararia `runGeneration` múltiplas vezes em sequência
- Cada mutation em parcelamentos/assinaturas/outros_gastos invalida `['alertas']`, que re-triggera o hook
- Sem debounce, um fluxo "criar 3 gastos em 5s" rodaria `runGeneration` ~6 vezes

**Por que 30s e não menor:** abaixo de 30s, o overhead começa a dominar (cada run lê `alertasExistentes` + compara orcamento vs gasto). Acima de 60s, o usuário percebe delay ao criar uma transação que estoura orçamento.

**Quando mexer:** se o user reportar alerta atrasado em cenário real, reduzir para `15_000` (não menos). Se relatório de custo mostrar ruído de `createAlerta.mutate` em Sentry, aumentar para `60_000`.

**Zero duplicidade de alerta:** além do debounce, o hook tem `tiposExistentes` (Set de `tipo_categoriaId` já criados no mês) — o debounce é só proteção contra trabalho inútil, a dedupe real é por conteúdo.

## ⚠️ S9.4 — `cancelAssinatura.mutate` mudou signature (breaking controlado)

Desde v4.5.0 (commit `2091ad1`), `cancelAssinatura` aceita objeto em vez de string:

```tsx
// ERRADO (pré-S9.4)
cancelAssinatura.mutate(assinatura.id);

// CORRETO (S9.4+)
cancelAssinatura.mutate({
  id: assinatura.id,
  usoRating: assinatura.uso_rating,
});
```

**Motivo:** S9.4 Trigger 2 precisa saber o `uso_rating` para decidir se celebra com toast "✨ Economia capturada" (quando `usoRating === 'nao_uso'`) ou mostra toast neutro. Passar `usoRating: undefined` mantém fallback neutro (seguro).

**Verificação:** `grep -rn "cancelAssinatura\.mutate" src/` — todos os callers DEVEM passar objeto.

## ⚠️ S9.4 — Novos triggers de celebration DEVEM usar `useCelebration` com key estruturada

Nunca chamar `fireCelebration()` direto em novo código. Sempre via `useCelebration`:

```tsx
const celebrate = useCelebration();
celebrate({
  key: `<contexto>:<id-ou-mes>`,  // dedupe via localStorage — OBRIGATÓRIO
  tier: 'small' | 'medium' | 'large' | 'none',
  haptic: 'success' | 'celebration' | 'milestone' | ...,
  sound: 'ching' | 'sparkle' | 'chime' | 'thump',  // opt-in via ambient_sounds_enabled
  toast: { title, description? },
});
```

**Convenções de key (dedupe scope):**

- Por entidade (1x por vida): `parcel-quitado:${id}`, `assinatura-cortada:${id}`, `receita-completa:${id}`
- Por mês (1x/mês): `orcamento-sob-controle:${YYYY-MM}`, `resumo-wrapped-completo:${YYYY-MM}`
- Por período de comparação: `comparativo-economizou:${mesB}`

**Escape:** `resetCelebrations()` em `src/lib/confetti.ts` limpa localStorage para debug.

## ⚠️ S9.4 — Hover + Long-Press em `CategoriaCard` NÃO conflitam (pattern para novos casos)

`CategoriaCard.tsx` abre `DetailReveal` por **dois caminhos distintos** compartilhando o mesmo state:

1. **Desktop hover** — `onPointerEnter/Leave` com guard `e.pointerType === 'mouse'` + `matchMedia('(hover: hover) and (pointer: fine)')` + debounce 200ms
2. **Mobile long-press** — `useLongPress({ delay: 500 })` com `pointer events raw`

Coexistem porque:

- Pointer events nativos chegam como `'mouse' | 'touch' | 'pen'` — guard filtra por tipo
- `(hover: hover) and (pointer: fine)` só matcha desktops verdadeiros (iPad com trackpad cai em 'pen', filtrado)
- Ambos mutam o mesmo `setShowDetail(true)` — zero race

**Ao adicionar hover-reveal em outros cards (SummaryCard, etc):** copiar esse pattern; NUNCA usar `onMouseEnter`/`onMouseLeave` (não distinguem touch emulado).

## ⚠️ S9.2 — Framer Motion variants com `initial='hidden'` precisam stackear baseline

Ao usar `motion.X` com `initial='hidden'` (opacity 0) + `animate='alguma-action'`, a variant de action **DEVE definir** opacity/y/scale/rotate baseline OU você DEVE stackear variants via array.

**Causou bug real em `PulsoChar.tsx` (fix commit `c56b10a`):**

- `initial='hidden'` (opacity 0)
- `animate='wave'` (só define `y` e `rotate` no loop)
- Resultado: char fica invisível — Framer Motion mantém opacity 0 porque nenhuma variant de destino define o valor final

**Duas correções aceitas:**

**Opção A (stack — RECOMENDADA):** passar array ao animate para que a primeira variant estabeleça baseline.

```tsx
<motion.div
  initial="hidden"
  animate={["entrance", action]} // entrance define opacity:1, y:0, scale:1, rotate:0
  variants={variants}
/>
```

**Opção B (inline todos os props em cada variant):** mais verboso, mas explícito.

```ts
idle: { opacity: 1, y: [0, -3, 0], scale: 1, rotate: 0, transition: {...} }
celebrate: { opacity: 1, y: [0, -24, -4, 0], scale: [1, 1.15, ...], rotate: 0, transition: {...} }
// ...
```

**Como verificar:** se `initial` define uma prop que NÃO aparece em TODOS os animate targets, o Framer mantém o valor anterior (pode ser o `hidden` → opacity 0 permanente).

**Precedente já existente no repo:** `accessoryVariants` em `charAnimations.ts` usa o pattern `animate={['visible', 'bounce']}` — seguir esse padrão ao criar novos motion components com entrance + loop.

## ⚠️ S7 — `navigator.vibrate` direto é PROIBIDO

A fonte unica de vibracao e `src/lib/hapticPatterns.ts`. Qualquer uso direto de `navigator.vibrate(...)` fora desse arquivo quebra a regra do S7 que unifica 7 padroes nomeados + respeito ao toggle `profiles.haptics_enabled` + `prefers-reduced-motion`.

**Use:**

- Dentro de componentes React: `const haptics = useHaptics(); haptics.tap();`
- Dentro de libs (ex: `lib/confetti.ts`): `import { runPattern } from './hapticPatterns'; runPattern('celebration', true);`

**Padroes disponiveis:** `tap` (5ms), `swipe` (10ms), `success` ([15,30,15]), `error` (40ms), `reveal` ([8,15,8]), `celebration` ([100,50,100]), `milestone` ([20,40,20,40,20]).

**Verificacao:** `grep -rn "navigator.vibrate" src/` deve retornar APENAS `hapticPatterns.ts` + `.test.ts`.

## ⚠️ S7 — AudioContext precisa de interacao previa do usuario

`useAmbientSounds` so funciona APOS a primeira interacao do usuario (autoplay policy do browser). Disparar um `sounds.ching()` ao montar o componente = silencio. O hook trata graciosamente (ctx.resume()), mas teste com interacao real ao ativar o toggle em Configuracoes.

## ⚠️ S7 — CursorProvider unico no AppLayout

Nao mountar outro `<CursorProvider>` em nenhum lugar. O provider e unico em `src/components/layout/AppLayout.tsx` (envolvido pelo `ScrollProvider`). Hooks consomem via `useCursor()` ou indiretamente via `useCursorProximity(ref)`. Listener mousemove so ativa em `(hover: hover) and (pointer: fine)` (desktop).

## ⚠️ S7 — SpeechRecognition: fallback silencioso

`useVoiceChat` faz feature detection de `SpeechRecognition`/`webkitSpeechRecognition`. Se nao suportar (Firefox desktop, alguns Safari antigos), `sttSupported=false` e o `VoiceInput` **se auto-oculta** — zero erro visivel. Teste em Chrome/Edge/Safari recentes.

## 1. Banco de Dados — DADOS REAIS EM PRODUCAO

**O Supabase tem dados reais do usuario.** Login, receitas, gastos, categorias — tudo real.

- NUNCA executar `DROP`, `TRUNCATE`, `DELETE` sem WHERE contra o banco
- NUNCA executar o arquivo `all.sql` contra producao (comeca com `DROP SCHEMA CASCADE`)
- Para criar nova tabela: usar Dashboard Supabase, depois documentar no `all.sql`
- Para alterar schema: usar Dashboard Supabase > SQL Editor, nunca CLI local

## 2. Supabase Types vs Runtime

O arquivo `types.ts` e **gerado manualmente** (nao via `supabase gen types`).
Os hooks usam `supabase.from('tabela')` que funciona em runtime mesmo sem tipo definido.
Mas para type-safety completa, SEMPRE adicionar a tabela em `types.ts` quando criar uma nova.

## 3. Formula do Saldo — Cuidado com Duplicacao

```
saldoDoMes = receitasDoMes - totalDoPeriodo.total
```

`totalDoPeriodo.total` ja inclui: parcelas + assinaturas + outros gastos.
**NAO somar `outrosGastosDoMes` novamente.** Isso ja causou bug de duplicacao (Incidente 2).

## 4. Lazy-Loading — NAO Importar Estaticamente

Paginas protegidas usam `React.lazy()`. Se importar estaticamente, o bundle inicial cresce.
O PDF (`exportPdfUtils.ts`) usa `import()` dinamico — 430kB+ que so carregam no clique.

```typescript
// CORRETO
const Dashboard = lazy(() => import("./pages/Dashboard"));
const loadPdfUtils = () => import("@/lib/exportPdfUtils");

// ERRADO — nao fazer
import Dashboard from "./pages/Dashboard";
import { exportRelatorioMensalPDF } from "@/lib/exportPdfUtils";
```

## 5. Env Vars — Prefixo VITE\_ Obrigatorio

Vite so expoe variaveis com prefixo `VITE_` ao frontend.
Se criar nova env var, DEVE comecar com `VITE_`.
Producao: configurar na Vercel, NAO no codigo.

## 6. BottomNav vs Sidebar — Itens Diferentes

- **Sidebar (desktop):** 7 itens (inclui Categorias e Configuracoes)
- **BottomNav (mobile):** 5 itens (Dashboard, Parcelas, Assinaturas, Receitas, Gastos)

Ao adicionar nova pagina, decidir se entra na bottom nav (maximo 5-6 itens).

## 7. Comparativo Mensal — Dados Limitados

O comparativo so e preciso quando existem `outros_gastos` de meses diferentes.
Parcelas e assinaturas sao valores fixos, entao a diferenca vem dos gastos variaveis.
Se o usuario so tem 1 mes de dados, o comparativo mostra 0%.

## 8. Pausar por Mes — Formato Especifico

O campo `meses_pausados` usa formato `"YYYY-MM"` (ex: `"2026-03"`).
Se mudar o formato, todos os calculos do dashboard quebram.

## 9. git reset --hard — PROIBIDO

O Antigravity ja destruiu o projeto inteiro com `git reset --hard`.
Use `git stash` ou `git checkout -- <arquivo>` para reverter arquivos individuais.

## 10. Deploy — Push Dispara Automaticamente

Qualquer `git push origin main` dispara deploy na Vercel.
NAO fazer push de codigo quebrado. SEMPRE `npm run build` antes.

## 11. CSS — Duas Variaveis de Tema

O `index.css` define variaveis para **light** E **dark** mode.
Ao adicionar cores, definir nos dois blocos (`:root` e `.dark`).
Classes como `glass-card` usam as variaveis CSS, nao cores hardcoded.

## 12. Orcamentos — Unique Constraint (ATUALIZADO S12 v4.8.0)

Desde S12, a tabela `orcamentos` tem `UNIQUE(user_id, categoria_id)` — **orçamento é template GLOBAL cross-month** (não mais por mês). Migration `s12_orcamentos_template_v480`:

- Constraint mudou de `UNIQUE(user_id, categoria_id, mes)` → `UNIQUE(user_id, categoria_id)`.
- Coluna `mes` + `recorrente` mantidas como **DEPRECATED** (backward compat, NOT NULL).
- Nova coluna `meses_pausados text[] NOT NULL DEFAULT '{}'` + índice GIN.
- `useOrcamentos` ignora o param `_mes` (retorna todos). Helper `isOrcamentoAtivo(orc, mesKey)` checa `meses_pausados`.
- `useOrcamentoMutations` ganhou `pausarMes`/`despausarMes` (optimistic update + snapshot rollback, padrão S10-B1).

Criar 2 orçamentos p/ a mesma categoria (qualquer mês) dá erro — 1 template por categoria.

## 13. Alertas — Gerador (ATUALIZADO S11 + bug fix S12)

**DESDE S11 (v4.7.0):** `useAlertaGenerator` NÃO roda mais só 1x/sessão. Dispara em 3 triggers — mount, `visibilitychange → visible`, invalidação de `['alertas']` por mutations — com **debounce 30s** (`ALERTA_DEBOUNCE_MS = 30_000`). Ver gotcha S11 dedicado acima. Dedupe real por conteúdo (`tiposExistentes` Set).

**🐛 Bug fix S12 (silencioso desde S6):** `useAlertaGenerator` e `BudgetSummaryWidget` consumiam `gastosPorCategoria[id]` como `number`, mas `useGastosPorCategoria` retorna `Record<string, GastoCategoriaBreakdown>`. Resultado: **alertas de orçamento NUNCA disparavam** (comparação contra objeto, não número) desde S6. Corrigido em S12 para consumir `.total`. Ver gotcha #24 — sempre `gastosPorCategoria[id]?.total ?? 0`.

## 14. Extrato — Agregacao no Frontend

O `useExtrato` combina 4 tabelas no frontend (parcelamentos, assinaturas, receitas, outros_gastos).
NAO cria dados novos no banco — apenas agrega para visualizacao.
Se a lista ficar lenta com muitos itens, considerar paginacao ou virtualizacao.

## 15. CSV Import — Parser Heuristico

O `parseCSVExtrato.ts` detecta separador e formato de data automaticamente.
Se o banco do usuario usar formato incomum, pode falhar silenciosamente.
Sempre mostrar preview antes de importar.

## 16. Categorias Historico — Case Insensitive

A tabela `categorias_historico` armazena `descricao_lower` em minusculas.
A busca usa `ilike` que e case-insensitive.
NAO mudar para `like` — quebraria as sugestoes.

## 17. Query Keys — Invalidacao Correta

Cada hook usa query keys especificas. Ao criar mutation:

```typescript
// Invalida a query certa
queryClient.invalidateQueries({ queryKey: ["receitas"] });

// NAO usar queryKey generico
queryClient.invalidateQueries(); // Invalida TUDO — lento e desnecessario
```

Query keys atuais: `parcelamentos`, `assinaturas`, `receitas`, `outros_gastos`,
`categorias`, `orcamentos`, `alertas`, `weekly-recap`, `category-suggest`,
`ai-threads`, `ai-messages`, `profile`, `conquistas`, `metas`.

## 18. PWA — Service Worker Cache

O `sw.js` usa estrategia network-first com cache de assets estaticos.
Se mudar a estrategia para cache-first, dados financeiros podem ficar desatualizados.
O SW NAO cacheia requests para Supabase (checagem por hostname).

## 19. meses_confirmados — Formato YYYY-MM (v2.4+)

O campo `meses_confirmados` em parcelamentos, receitas e assinaturas usa formato `"YYYY-MM"`.
Mesmo padrao de `meses_pausados`. Se mudar o formato, alertas e badges quebram.
Ao confirmar/rollback, SEMPRE manter `parcelas_pagas`/`parcelas_recebidas` em sync com `meses_confirmados.length`.

## 20. Edge Function Deploy — SEMPRE --no-verify-jwt

```
npx supabase functions deploy ai-agent --project-ref txbzynnszuvjnmhbnnzh --no-verify-jwt
```

Sem `--no-verify-jwt`, 100% dos POSTs retornam 401. Isso ja causou incidente 2x.

## 21. Configuracoes — Changelog Icons

Os icones do array CHANGELOG em `Configuracoes.tsx` DEVEM estar importados do lucide-react.
Se usar um icone sem importar, a pagina inteira da tela preta (React crash).
**SEMPRE** verificar imports ao adicionar nova versao no changelog.

## 22. calcularCustoMensal — Fonte Unica em financialCalcs.ts

`calcularCustoMensal` e `calcularGastosPorCategoria` vivem em `src/lib/financialCalcs.ts`.
**NAO criar copias locais.** Ja teve 9 duplicatas que causaram Incidente 5 (totais dessincronizados).

```typescript
// CORRETO
import { calcularCustoMensal } from '@/lib/financialCalcs';

// ERRADO — nao fazer
const calcCustoMensal = (valor, freq) => { ... };
```

Se precisa do nome curto: `import { calcularCustoMensal as calcCustoMensal } from '@/lib/financialCalcs'`

## 23. Graficos de Distribuicao — Dados Completos

Graficos que mostram distribuicao por categoria (pizza, barras) NUNCA devem usar dados filtrados por filtros da pagina.
Usar query sem filtros (ex: `useAssinaturas({})`) para garantir que o grafico mostra a foto completa.
Incidente 5: o grafico da Assinaturas mudava ao filtrar por status.

## 24. useGastosPorCategoria — Retorna Breakdown

O hook retorna `Record<string, GastoCategoriaBreakdown>` (nao `Record<string, number>`).
Para acessar o total: `gastosPorCategoria[categoriaId]?.total ?? 0`.
O breakdown tem: `{ parcelamentos, assinaturas, outrosGastos, total }`.

## 25. Framer Motion — Lazy Pages

`motion` do framer-motion e importado em componentes que usam animacao.
Se um componente lazy-loaded importar `motion`, certifique-se que framer-motion esta no bundle principal
(ja esta — mas NAO mover para dynamic import).

## 26. IOSHeader — Todas as Paginas Protegidas DEVEM Usar (v3.0)

O `IOSHeader` registra o `pageTitle` no `ScrollContext` via `useEffect`. O `AppHeader` consome esse titulo para mostrar o compact title no mobile ao scrollar. Se uma pagina NAO usar `IOSHeader`, o compact title fica vazio.

- Paginas com header custom (Dashboard, Resumo): usar `useEffect(() => { setPageTitle('...'); return () => setPageTitle(''); }, [setPageTitle])` direto
- Demais paginas: `<IOSHeader title="..." subtitle="..." actions={...} />`
- **NAO** usar `<h2>` avulso para titulos — usar IOSHeader para consistencia

## 27. ScrollContext — Provider OBRIGATORIO no AppLayout

O `ScrollProvider` envolve `AppLayoutInner` em `AppLayout.tsx`. Se remover, IOSHeader, AppHeader compact title e useBackGesture param de funcionar. O `mainRef` aponta para o `<main>` — necessario para scroll tracking.

## 28. ResponsiveModal vs ResponsiveAlertModal — Quando Usar Qual

| Cenario                                 | Componente             | Motivo                                                |
| --------------------------------------- | ---------------------- | ----------------------------------------------------- |
| Formulario de criacao/edicao            | `ResponsiveModal`      | Dialog desktop, Drawer mobile                         |
| Confirmacao destrutiva (delete, cancel) | `ResponsiveAlertModal` | AlertDialog desktop, Drawer mobile com botao vermelho |
| Dialog informativo simples              | `Dialog` direto        | Nao precisa de responsive                             |

**NAO** usar `<Dialog>` diretamente para forms no mobile — sempre `ResponsiveModal`.
**NAO** usar `<AlertDialog>` diretamente para confirmacoes — sempre `ResponsiveAlertModal`.

## 29. PullToRefresh — Apenas Mobile, Apenas Paginas de Dados

O `PullToRefresh` so renderiza no mobile (`useIsMobile()`). No desktop retorna `children` direto.

- Integrado em: Dashboard, Parcelamentos, Assinaturas, Extrato
- Usa `queryClient.invalidateQueries` para refrescar dados
- **NAO** usar em paginas sem dados dinamicos (Configuracoes, Categorias)

## 30. PageTransition — Direcao Baseada em useNavigationType

`PageTransition.tsx` detecta PUSH vs POP via `useNavigationType()` do react-router-dom.

- `PUSH` → slide da direita (iOS forward)
- `POP` → slide da esquerda (iOS back)
- Desktop → fade simples (sem slide horizontal)
- `prefers-reduced-motion` → sem animacao

**NAO** mudar para AnimatePresence `mode="popLayout"` — ja usa `mode="wait"` no AppLayout.

## 31. SegmentedControl — layoutId Customizavel (resolvida em S9.3-F2)

O `SegmentedControl` aceita prop opcional `layoutId?: string` (default preservado: `'segmented-pill'`). Quando houver mais de um SegmentedControl no app (cross-route ou na mesma pagina), **DEVE** ser passado um id unico por contexto para evitar morph estranho do Framer Motion.

**Exemplos em uso desde S9.3:**

- Parcelamentos → `layoutId="seg-status-parcelamentos"`
- Assinaturas → `layoutId="seg-status-assinaturas"`
- Extrato → `layoutId="seg-tipo-extrato"`

**Verificacao:** `grep -rn 'layoutId="segmented-pill"' src/` deve retornar 0 ocorrencias (todos os usos passam prop customizada).

## 34. Edge Function — SEMPRE verificar ownership (userId)

Toda action na edge function que acessa dados por ID (threadId, memoryId, etc) DEVE verificar que o recurso pertence ao `userId` autenticado ANTES de retornar dados. Sem isso = IDOR (qualquer user le dados de outro). Incidente 7.

```typescript
// CORRETO — verificar ownership
const { data: thread } = await db
  .from("ai_threads")
  .select("id")
  .eq("id", threadId)
  .eq("user_id", userId)
  .maybeSingle();
if (!thread)
  return new Response(JSON.stringify({ error: "Not found" }), { status: 404 });

// ERRADO — carrega sem checar dono
const msgs = await loadMessages(threadId, 50);
```

## 35. CORS — NUNCA wildcard em producao

`supabase/functions/_shared/cors.ts` restringe origins para `pulsofinance.vercel.app` + `localhost:8080`. NAO voltar para `*`. Incidente 7.

## 36. Erros — NUNCA vazar detalhes internos pro client

Mensagens de erro do Supabase podem conter nomes de tabelas, constraints e schema. SEMPRE sanitizar antes de mostrar em toasts. No catch da edge function, NUNCA incluir `details: String(error)`. Incidente 7.

## 37. Delecao de Conta — TODAS as 25 Tabelas (atualizado S10 2026-04-17)

`DeleteAccountDialog.tsx` deleta dados de todas as 25 tabelas + avatar storage. Ao criar nova tabela com `user_id`, ADICIONAR na lista de delecao. Ordem importa (FKs primeiro). Incidente 7.

**Auditoria S10 (2026-04-17):** lista atual cobre 100% das tabelas com `user_id` (23) + `profiles` (via `id`) + `transaction_tags` (polimórfica) = 25 + avatar storage. Verificado via `SELECT table_name FROM information_schema.columns WHERE column_name='user_id'`.

**Tabelas adicionadas em S1-S8 (obrigatórias no delete):**

- `agent_followups`, `agent_goal_proposals` (S8)
- `agent_runs` (S2+)
- `ai_episodes`, `ai_topics` (S5 HyperMem)
- `notification_throttle` (S2)
- `push_subscriptions` (S1)

## 38. vercel.json — CSP e HSTS Obrigatorios

`Content-Security-Policy` e `Strict-Transport-Security` estao no vercel.json. NAO remover. Se adicionar nova origem de dados (ex: novo CDN, nova API), atualizar o CSP `connect-src`. Incidente 7.

## 33. SummaryCard extractNumber — Regex Guard Obrigatorio

A funcao `extractNumber()` em `SummaryCard.tsx` usa regex guard para so aceitar strings puramente numericas ou moeda. **NAO** remover a validacao regex — sem ela, qualquer string com digitos (ex: nomes de parcelamentos) vira numero e o animated counter exibe lixo. Incidente 6.

```typescript
// CORRETO — com regex guard
if (!/^-?\s*(?:R\$\s*)?[\d.,]+%?$/.test(trimmed)) return null;

// ERRADO — sem guard, extrai digitos de qualquer string
const cleaned = val.replace(/[^\d,.-]/g, "");
```

## 32. useBackGesture — Nao Conflitar com SwipeableRow

O back gesture detecta swipe da borda esquerda (primeiros 20px). O `SwipeableRow` detecta swipe horizontal em qualquer posicao. Os dois coexistem porque:

- Back gesture: `touchStart.clientX <= 20` (borda)
- SwipeableRow: pan gesture do Framer Motion (nao usa borda)

Se adicionar swipe gesture novo, testar que nao conflita com a borda esquerda.

## 39. IDOR na action `chat` — Ownership Check OBRIGATORIO (Incidente 8)

A action `chat` em `ai-agent/index.ts` agora verifica ownership do `threadId` antes de carregar mensagens. Se adicionar NOVA action que aceite um ID do client (threadId, memoryId, etc.), SEMPRE verificar ownership:

```typescript
// CORRETO — verificar que o recurso pertence ao usuario
if (threadId) {
  const { data: owned } = await db
    .from("ai_threads")
    .select("id")
    .eq("id", threadId)
    .eq("user_id", userId)
    .maybeSingle();
  if (!owned)
    return new Response(JSON.stringify({ error: "Not found" }), {
      status: 404,
    });
}

// ERRADO — carregar direto sem checar dono
const msgs = await loadMessages(threadId, 50);
```

## 40. CORS — getCorsHeaders(req) OBRIGATORIO, corsHeaders REMOVIDO (Incidente 8)

`cors.ts` agora exporta APENAS `getCorsHeaders(req)`. O export estatico `corsHeaders` foi removido. Todas as responses da edge function usam `const cors = getCorsHeaders(req)` definido no inicio do handler.

```typescript
// CORRETO
import { getCorsHeaders } from "../_shared/cors.ts";
const cors = getCorsHeaders(req);
return new Response(body, {
  headers: { ...cors, "Content-Type": "application/json" },
});

// ERRADO — nao existe mais
import { corsHeaders } from "../_shared/cors.ts";
```

Sem `Vary: Origin`, CDNs podem servir resposta cacheada com origin errado → cache poisoning.

## 42. Resend Free Dev Mode — Entrega só pro Owner (S5 A8)

A conta Resend gratuita usando `onboarding@resend.dev` como sender só ENTREGA emails para o endereço cadastrado como owner da conta (deivithi74@gmail.com).

- Para entregar a qualquer destinatario: verificar domain no Resend Dashboard + mudar `EMAIL_FROM` para `noreply@<dominio-verificado>`.
- Cron `send-digest-weekly` roda sábado 12 UTC independente de haver RESEND_API_KEY configurado; sem a chave, a edge function retorna `{sent:false, error:'RESEND_API_KEY not configured'}` e loga em agent_runs.
- NUNCA hardcodar o EMAIL_FROM no código — sempre via `Deno.env.get('EMAIL_FROM')` com fallback sensato.

## 43. AGENT_REFLECTION Flag — OFF em Produção por Default (S5 A4)

O self-reflection loop (`orchestrator/reflection.ts`) só ativa quando `Deno.env.get('AGENT_REFLECTION') === 'on'`.

- Off (default): comportamento S4 idêntico, zero overhead.
- On: judge 1 LLM call (~1s) + regen opcional (~8s) quando score<7. Hard limit 1 regen.
- Fail-open: timeout do judge ou JSON inválido → mantém reply original sem erro.
- Para ligar: `npx supabase secrets set AGENT_REFLECTION=on --project-ref txbzynnszuvjnmhbnnzh`
- Para desligar em emergência: `npx supabase secrets set AGENT_REFLECTION=off` (segundos, sem redeploy).

## 44. HYPERMEM_MODE Flag — Tools Existem Sempre, Prompts Opcionais (S5 A5)

As tools `recall_hypermem` e `save_episode` ficam registradas em `tools.ts` DESDE o deploy S5 (permitem chamadas diretas em testes).

Mas os PROMPTS só mencionam HyperMem quando `HYPERMEM_MODE=on`:

- `WATCHER_HYPERMEM_BLOCK` só é injetado no prompt quando flag=on
- `COACH_RECALL_BLOCK` alterna entre priorizar `recall_hypermem` (on) ou `recall_memories` (off)
- `EXECUTOR_HYPERMEM_BLOCK` só injeta `save_episode` guidance quando flag=on

Com flag=off o agente IGNORA as novas tools na prática — comportamento S4 preservado. Isso permite testar migrations sem tocar na UX até validar. Rollout:

1. Deploy com `HYPERMEM_MODE=off` (default)
2. Validar 20 prompts canônicos do S3 — devem passar igual
3. `npx supabase secrets set HYPERMEM_MODE=on` quando pronto

## 41. .env.local — NUNCA Persistir Tokens Efemeros (Incidente 8)

O Vercel CLI gera `VERCEL_OIDC_TOKEN` em `.env.local` automaticamente. Esse token e efemero (expira em ~12h) e NAO deve ser persistido. Se encontrar um token JWT longo em `.env.local`, REMOVER — o CLI regenera quando necessario.

Tokens que DEVEM estar em .env.local: `VITE_SUPABASE_*` (configuracao, nao secreto).
Tokens que NUNCA devem estar: `VERCEL_OIDC_TOKEN`, `SUPABASE_SERVICE_ROLE_KEY`, qualquer secret.

## 45. useVirtualizer + Scroll Container Externo (S10 Fase C)

O `useVirtualizer` do `@tanstack/react-virtual` precisa saber **qual elemento scrolla**. Em SPAs onde o scroll é de um container externo (não da window), passar o container via `getScrollElement`.

**No Pulso:** o scroll real é do `<main ref={mainRef}>` em `AppLayout.tsx` (classe `overflow-y-auto`). Esse ref está exposto via `useScroll().mainRef`.

**Padrão correto:**

```ts
const { mainRef } = useScroll();
const rowVirtualizer = useVirtualizer({
  count: days.length,
  getScrollElement: () => mainRef.current,
  estimateSize: (i) => 96 + days[i].items.length * 62,
  measureElement: (el) => el.getBoundingClientRect().height,
  overscan: 4,
});
```

**Armadilha:** NÃO criar um container interno `overflow-auto` para virtualizar — cria scroll nested e quebra o iOS-style `PullToRefresh` (que lê `container.scrollTop` do parent). O `PullToRefresh` continua funcionando quando o virtualizer usa `mainRef` como scrollElement.

**Ativação progressiva:** virtualizar só quando `days.length > 20`. Abaixo disso, o custo do `useVirtualizer` + measureElement não compensa e pode até piorar UX (perde ScrollReveal stagger natural).

## 46. RPC Owner-Only — Pattern Security Definer + Gate JWT (S10 Fase C)

Para expor dados de tabelas privilegiadas (`cron.job`, `cron.job_run_details`) ou métricas agregadas de todos os users ao owner (deivithi74@gmail.com) **sem expor as tabelas diretamente**, usar RPC `security definer` com gate no primeiro comando.

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

**Pontos críticos:**

- `security definer` dá privilégio do owner do schema `postgres` para ler qualquer tabela. Por isso o gate `auth.jwt() ->> 'email'` é o único firewall — descuidar dele = leak total.
- Sempre `set search_path = public, pg_temp` para evitar search_path attacks em funções security definer.
- `revoke all from public, anon` evita que usuário não autenticado consiga chamar (camada extra de defesa).
- Usar `auth.jwt() ->> 'email'` (não `auth.email()` — mais portável e sempre disponível).
- Teste negativo obrigatório: chamar sem JWT válido deve retornar "Forbidden" — valida que o gate funciona.

**Defesa em profundidade:** gate frontend (`Navigate` em React) + gate server-side (raise exception na RPC). Se um usuário manipular o client, o Postgres ainda bloqueia.

## 47. Supabase RPC `as never` Quando Tipos TS Não Foram Regenerados (S10 Fase C)

Depois de criar uma RPC nova via `apply_migration`, o schema TS gerado (`src/integrations/supabase/types.ts`) **não contém a nova função automaticamente** até rodar `npx supabase gen types typescript`.

Enquanto isso, `supabase.rpc('admin_X')` reclama com erro TS: _Argument of type '"admin_X"' is not assignable to parameter of type..._.

**Workaround aceitável até regenerar tipos:**

```ts
const { data, error } = await supabase.rpc(
  "admin_agent_runs_stats" as never,
  {
    p_hours: hours,
  } as never,
);
```

Dois `as never` são necessários: um para o nome (primeiro argumento) e outro para o payload (segundo). Cast explícito do retorno: `data as unknown as AgentRunsStats`.

**Não deixar permanente:** quando for atualizar tipos (próximo sprint que gerar tipos), remover os `as never`. Acumular cast é mau cheiro — é débito de schema regen.

## 48. pgvector — Dimensão Travada 384 + Índice HNSW + Embedding Best-Effort (S13 Agent Memory v2)

A migration `20260524120000_agent_memory_v2_pgvector.sql` habilita a extensão `vector` e adiciona `embedding vector(384)` em `ai_memories` + `ai_episodes`.

- **Dimensão 384 é IMUTÁVEL** — é a saída do `gte-small` (`globalThis.Supabase.ai.Session('gte-small')`). Trocar de modelo de embedding = recriar coluna + reindexar + reembeddar tudo. Não misturar dimensões.
- **Índice HNSW (cosine) é obrigatório** p/ performance — sem ele, `match_ai_memories`/`match_ai_episodes` viram full scan. Já criado na migration; não dropar.
- **Embedding é best-effort:** `embeddings.ts` gera o vetor via `embedText()` que **falha graciosamente → `null`**. O embedding é gravado por `UPDATE` **após** o INSERT — **nunca bloqueia o save** da memória. Se a Edge AI estiver indisponível, a memória é salva sem embedding (cai p/ keyword/confiança no recall).
- **Custo zero, sem API key:** `gte-small` é nativo da Supabase Edge Runtime. Não confundir com embedding via OpenAI/OpenRouter (não usa).
- **Verificação:** `gh api repos/deivithi/pulsofinance/contents/supabase/functions/ai-agent/embeddings.ts?ref=main` deve existir.

## 49. View Transitions API — Coexistência com Framer Motion (S13)

`ThemeToggle.tsx` usa `document.startViewTransition` + `documentElement.animate({ clipPath: circle(...) })` p/ revelação circular dark↔light a partir do ponto de clique.

- **Feature detection obrigatória:** `document.startViewTransition` não existe em Safari estável/Firefox antigo. Sem suporte → aplicar o tema direto (fallback gracioso, sem animação). Nunca assumir que existe.
- **`prefers-reduced-motion`:** respeitar — sem reveal animado.
- **Não conflitar com Framer Motion:** View Transitions é só p/ o toggle de tema. As page transitions continuam via Framer (`PageTransition.tsx`, gotcha #30). Não envolver navegação de rota em `startViewTransition` (duplicaria animação).

## 50. v5.0.0 de-AI — Paleta e Fundo São Decisão Arquitetural (NÃO Reverter)

O commit `8a3f3e7` (v5.0.0) **removeu de propósito** a "cara de IA". É decisão arquitetural na `.claude/constitution.md` — não readicionar sem ADR explícito.

**Removidos (não recriar):** `MeshGradientBg`, `ShaderMeshBg`, `useMeshMood`, `useGlassSheen`, `useCanRenderShader` (fundo mesh/shader + Liquid Glass sheen).

**Banido na UI (anti-pattern):**

- Indigo / violeta / roxo → usar **teal/petróleo** (light `--primary 188 88% 27%`, dark `184 72% 50%`)
- Gradientes rainbow / multi-hue → só single-family teal
- `gradient-text` decorativo → cor chapada teal (gradient-text era "tell de IA")
- Ícone `Sparkles` decorativo
- Fundo animado / mesh / shader → fundo **sólido limpo**

**Fonte:** `Hanken Grotesk Variable` (Inter é fallback). **Verificação:** `grep -i "indigo\|violet\|purple" src/index.css` deve retornar ~0 (só comentários "zero indigo").

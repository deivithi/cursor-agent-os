# Pulso Finance — Historico de Incidentes

> **LEIA ANTES DE QUALQUER EDICAO.** Estes incidentes ja aconteceram e NUNCA devem ser repetidos.

---

## Incidente 1 — Destruicao pelo Antigravity (28/03/2026)

### O que aconteceu

O Gemini (via ferramenta Antigravity) executou `git reset --hard`, apagou o banco Supabase original e injetou um schema com trigger quebrado. O projeto inteiro ficou inutilizavel.

### Impacto

- **Codigo-fonte:** Perdido (recuperado via `git reflog`, commit `bcc6f23`)
- **Banco de dados:** Supabase original destruido — novo projeto criado (`txbzynnszuvjnmhbnnzh`)
- **Dados do usuario:** Perdidos no banco original
- **Deploy:** Vercel quebrado

### Resolucao (commit `b165c7e`)

1. Codigo recuperado via `git reflog`
2. `.env` corrigido para apontar para novo Supabase
3. Trigger `on_auth_user_created_role` recriado com grants corretos
4. Grants de tabelas restaurados para `anon`/`authenticated`/`service_role`
5. Receitas e Outros Gastos reconstruidos a partir de build artifacts da Vercel
6. Bundle otimizado com code splitting (-81% no bundle principal)
7. 59 arquivos modificados, 5212 insercoes

### Licoes

- **NUNCA** usar `git reset --hard` no projeto
- **NUNCA** executar SQL destrutivo (DROP SCHEMA, DROP TABLE) contra producao
- **SEMPRE** verificar o estado do banco antes de qualquer operacao
- **SEMPRE** ter backup mental do que existe antes de editar

---

## Incidente 2 — 5 Gaps Tecnicos pos-restauracao (28/03/2026)

### O que aconteceu

Apos a restauracao e criacao das paginas Receitas e Outros Gastos, ficaram 5 gaps de consistencia:

1. Migration SQL local nao documentava as tabelas `receitas` e `outros_gastos`
2. `types.ts` nao tinha definicoes TypeScript das novas tabelas
3. Dashboard "Despesas do Mes" nao incluia outros gastos
4. Comparativo mensal sempre retornava 0% (comparava mes consigo mesmo)
5. Export CSV/PDF nao incluia receitas e outros gastos

### Impacto

- Type-safety comprometida para as novas tabelas
- Dashboard mostrava dados incompletos
- Relatorios exportados estavam incompletos

### Resolucao (commit `133d586`)

1. Adicionados CREATE TABLE + RLS + triggers em `all.sql` (documentacao)
2. Adicionadas definicoes em `types.ts` (type-safety)
3. `totalDoPeriodo` agora inclui outros gastos; saldo corrigido sem duplicacao
4. Comparativo calcula diferenca real entre meses baseado em outros gastos
5. CSV/PDF incluem 4 secoes: receitas, parcelamentos, assinaturas, outros gastos
6. Docs atualizadas com changelog

### Licoes

- Ao criar nova tabela/pagina, SEMPRE completar: migration + types + dashboard + exports
- Verificar formula do saldo apos qualquer mudanca em calculos
- Testar comparativos com dados reais, nao so com mocks

---

## Incidente 3 — MetasFinanceiras: limite de parcelas com valor errado (28/03/2026)

### O que aconteceu

O campo "Limite mensal de parcelas" nas Metas Financeiras do Dashboard mostrava a divida total restante (`valorRestante = parcelas_restantes * valor_parcela`) em vez do custo mensal (soma de `valor_parcela` dos parcelamentos ativos).

### Causa raiz

`Dashboard.tsx` passava `parcelamentosAtivos.valorRestante` ao componente MetasFinanceiras. O hook `useDashboardData` calculava `valorRestante` (divida total) mas nao tinha `custoMensal` (gasto mensal).

### Correcao

1. Adicionado `custoMensal` ao retorno de `parcelamentosAtivos` em `useDashboardData.ts`
2. Dashboard passa `custoMensal` ao MetasFinanceiras

### Licoes

- `valorRestante` = divida total (para o card "Parcelamentos Ativos" no dashboard)
- `custoMensal` = gasto mensal (para metas e limites)
- Ao passar props de valores financeiros, verificar se o semantico e "total" ou "mensal"

---

## Incidente 4 — Tela preta em Configuracoes (29/03/2026)

### O que aconteceu

Ao adicionar v2.5.0 na trilha de novidades (Configuracoes.tsx), o icone `Repeat` do lucide-react foi usado no changelog entry mas NAO foi importado. Resultado: React crash → tela totalmente preta ao acessar Configuracoes.

### Causa raiz

`Configuracoes.tsx` linha 32: `icon: Repeat` — mas `Repeat` nao estava na lista de imports (linha 2).

### Correcao (commit `9f5ff13`)

Adicionado `Repeat` aos imports do lucide-react.

### Licoes

- Ao adicionar nova versao no CHANGELOG, SEMPRE verificar se o icone esta importado
- Gotcha #21 criado para prevenir recorrencia
- Build (`vite build`) NAO detecta esse erro — e um erro de runtime, nao de compilacao

---

## Incidente 5 — Totais por categoria dessincronizados entre abas (10/04/2026)

### O que aconteceu

A aba Orcamento mostrava valor diferente da aba Assinaturas para a mesma categoria (ex: "Inteligencia Artificial"). O usuario nao entendia por que os numeros divergiam.

### Causa raiz (3 problemas)

1. **Orcamento agregava 3 fontes, Assinaturas so 1** — `useGastosPorCategoria` somava parcelamentos + assinaturas + outros_gastos; a Assinaturas page so somava assinaturas. Se a categoria tinha qualquer despesa alem de assinaturas, os totais divergiam sem explicacao.
2. **Grafico da Assinaturas dependia dos filtros da pagina** — ao filtrar por status ou categoria, o grafico de distribuicao mudava (usava array filtrado em vez de todas as ativas).
3. **Dashboard `distribuicaoCategoria` nao incluia `outros_gastos`** — somava apenas P+A, mais uma fonte de inconsistencia.
4. **`calcularCustoMensal` duplicada em 9+ arquivos** — risco de divergencia futura.

### Correcao

1. Criado `src/lib/financialCalcs.ts` — fonte unica de `calcularCustoMensal` + `calcularGastosPorCategoria` com interface `GastoCategoriaBreakdown`
2. `useGastosPorCategoria` refatorado para retornar breakdown (parcelamentos/assinaturas/outrosGastos/total)
3. `BudgetProgressBar` ganha tooltip mostrando composicao quando ha multiplas fontes
4. Assinaturas page: grafico usa `allAssinaturas` (sem filtros) em vez do array filtrado
5. Dashboard: `distribuicaoCategoria` agora inclui `outros_gastos`
6. 9 copias de `calcularCustoMensal` eliminadas — todas importam de `financialCalcs.ts`

### Licoes

- Calculos financeiros DEVEM usar funcoes compartilhadas de `src/lib/financialCalcs.ts`
- Graficos de distribuicao NUNCA devem depender de filtros da pagina — usar dados completos
- Quando o total agrega multiplas fontes, mostrar breakdown ao usuario (tooltip)
- Ao adicionar nova fonte de despesa, atualizar TODOS os agregadores (dashboard, orcamento, comparativo, extrato)

---

## Incidente 6 — Card "Proximo Vencimento" mostra numeros em vez do nome (10/04/2026)

### O que aconteceu

O card "Proximo Vencimento" no Dashboard exibia valores como -11.000 ou +11.000 em vez do nome do parcelamento/assinatura. O campo ficava fora do padrao normal do designer.

### Causa raiz

`SummaryCard.tsx` → `extractNumber()` era muito agressiva: stripava TODOS os caracteres nao-numericos e parseava o que sobrasse. Se o nome do item continha digitos (ex: "Emprestimo 11.000"), a funcao extraia o numero e o animated counter exibia o numero em vez do nome.

Bug secundario: `.replace('.', '')` so removia o PRIMEIRO ponto (separador de milhares), quebrando parsing de valores acima de 1 milhao.

### Correcao

1. Adicionada regex guard em `extractNumber()`: so aceita strings que sao puramente numericas ou moeda formatada (`/^-?\s*(?:R\$\s*)?[\d.,]+%?$/`)
2. `.replace('.', '')` → `.replace(/\./g, '')` (remove TODOS os separadores de milhares)

### Licoes

- Funcoes de parsing numerico DEVEM validar o formato antes de extrair
- Animated counters so devem ativar para valores que sao realmente numericos/monetarios
- Testar SummaryCard com valores texto que contem digitos (ex: nomes de produtos, planos)

---

## Incidente 7 — Auditoria de Seguranca: 16 vulnerabilidades corrigidas (10/04/2026)

### O que aconteceu

Auditoria completa identificou 2 CRITICAL, 5 HIGH, 5 MEDIUM no frontend e edge function.

### Correcoes aplicadas

1. **CRITICAL** — IDOR em `thread_messages`: adicionada verificacao de ownership (userId)
2. **CRITICAL** — CORS wildcard `*` → restrito a `pulsofinance.vercel.app` + `localhost:8080`
3. **CRITICAL** — Secrets no historico Git: `.env` e `.env.prod.full` purgados via `git filter-repo` + force push
4. **HIGH** — Error leak: removido `details: String(error)` do catch da edge function
5. **HIGH** — Mensagens de erro sanitizadas em Login (previne user enumeration) e Cadastro
6. **HIGH** — Delecao de conta: de 3 tabelas → todas as tabelas + avatar storage (LGPD). [Nota 2026-05: o total cresceu para **25 tabelas** — ver gotcha #37 p/ a lista canônica `TABLES_TO_DELETE`]
7. **HIGH** — npm audit fix: 17 CVEs → 2 (dev-only esbuild, nao afeta producao)
8. **MEDIUM** — CSP header adicionado no vercel.json (bloqueia scripts externos, frames)
9. **MEDIUM** — HSTS header adicionado (max-age 2 anos, includeSubDomains, preload)
10. **MEDIUM** — Senha minima 8 chars + maiuscula + numero + caractere especial
11. **MEDIUM** — Source maps explicitamente desabilitados em producao

### Licoes

- Auditorias de seguranca devem ser periodicas, nao apenas reativas
- Edge functions com service_role SEMPRE devem verificar ownership do recurso
- CORS nunca deve ser wildcard em producao
- Erros internos NUNCA devem vazar pro client (stack traces, nomes de tabelas)
- Delecao de conta deve cobrir TODAS as tabelas do usuario (LGPD)
- Secrets commitados acidentalmente persistem no historico — `git filter-repo` e obrigatorio

---

## Incidente 8 — Auditoria Mythos L1: IDOR no chat, CORS estatico, token OIDC, enumeracao signup (14/04/2026)

### O que aconteceu

Auditoria de seguranca Mythos (deep code comprehension + file prioritization + variant analysis) identificou 1 CRITICAL, 3 HIGH, 4 MEDIUM, 3 LOW no frontend e edge function. Diferente do Incidente 7 (checklist OWASP), o Mythos fez hunting autonomo linha-a-linha nos arquivos priority 4-5.

### Findings e Correcoes

1. **CRITICAL** — Token Vercel OIDC (`VERCEL_OIDC_TOKEN`) persistido em `.env.local`. JWT com claims completos (owner, project, environment). Nao foi commitado no git, mas em plaintext no disco.
   - **Fix:** Token removido de `.env.local`. Vercel CLI gera tokens efemeros sob demanda.

2. **HIGH — IDOR na action `chat`** — `index.ts:208-216` aceitava `threadId` do client sem verificar ownership. Um atacante autenticado podia ler historico de chat de outro usuario (dados financeiros, salarios, metas).
   - **Fix:** Adicionado ownership check (linhas 217-232) antes de `loadMessages()` — mesmo padrao ja usado em `thread_messages`.

3. **HIGH — CORS estatico** — `index.ts` importava `corsHeaders` (objeto estatico sem `Vary: Origin`) em vez de `getCorsHeaders(req)` (dinamico, com `Vary: Origin`). Risco de cache poisoning em CDN/proxy.
   - **Fix:** Migrado todas as 15+ referencias para `getCorsHeaders(req)`. Export estatico removido de `cors.ts`.

4. **HIGH — Delecao de conta nao-atomica** — `DeleteAccountDialog.tsx` faz 17 DELETEs sequenciais do client-side. Se falhar no meio, dados ficam parcialmente deletados. (Documentado, fix planejado para Edge Function futura.)

5. **MEDIUM — Enumeracao de e-mail no Cadastro** — `Cadastro.tsx:58` revelava se e-mail ja existia (`'Este e-mail ja esta cadastrado.'`). Login ja usava mensagem generica.
   - **Fix:** Mensagem generica para todos os erros de signup.

6. **MEDIUM — Sem rate limiting no AI endpoint** — Cada chamada `chat` invoca LLM via OpenRouter. Sem limite por usuario. (Documentado, fix planejado.)

7. **MEDIUM — Validacao de senha so client-side** — Requisitos (8+ chars, maiuscula, numero, especial) so no React. Bypass via API direta. (Documentado, configurar no Supabase Dashboard.)

8. **MEDIUM — Avatar upload sem magic bytes** — Valida so `file.type` (MIME spoofavel). SVG com JS embutido passaria. (Documentado, fix planejado.)

### Positivos encontrados (14)

- Security headers excelentes (HSTS, CSP, X-Frame-Options, nosniff)
- Todos os 30+ hooks usam `.eq('user_id', user.id)` consistentemente
- Zero SQL raw, zero concatenacao de strings
- Sourcemaps desabilitados em producao
- OpenRouter API key so server-side
- 0 CVEs critical/high nas dependencias

### Licoes

- **IDOR parcial e pior que zero** — se verificar ownership em `thread_messages` e `delete_thread`, TODAS as actions que aceitam IDs devem verificar tambem
- **CORS estatico vs dinamico** — mesmo que o origin fixo esteja correto, sem `Vary: Origin` CDNs podem cachear a resposta para o origin errado
- **Tokens efemeros NUNCA devem ser persistidos** — Vercel CLI gera sob demanda, nao precisa salvar
- **Auditorias Mythos encontram o que checklists nao cobrem** — o IDOR no chat escapou da auditoria anterior (Incidente 7) porque a verificacao ja existia em `thread_messages`

---

## Incidente 9 — Alertas de orçamento silenciosamente quebrados desde S6 (corrigido S12, 02/05/2026)

### O que aconteceu

Desde a refatoração do S6 (`useGastosPorCategoria` passou a retornar `Record<string, GastoCategoriaBreakdown>` em vez de `Record<string, number>`), os consumidores `useAlertaGenerator` e `BudgetSummaryWidget` continuaram lendo `gastosPorCategoria[id]` como se fosse `number`. Resultado: a comparação "gasto vs limite do orçamento" comparava contra um **objeto**, nunca contra um número — e **os alertas de orçamento (80%/100%) nunca dispararam** por ~2 sprints, sem erro visível.

### Causa raiz

Mudança de contrato de retorno (number → breakdown) sem atualizar TODOS os consumidores. TypeScript não pegou porque o acesso `gastosPorCategoria[id]` em contexto numérico foi coagido silenciosamente (ou via `any`/cast frouxo).

### Correcao (S12, commit `b9f8068`)

Todos os consumidores passaram a usar `gastosPorCategoria[id]?.total ?? 0`. Ver gotcha #24.

### Licoes

- Mudar o **tipo de retorno** de um hook agregador exige caçar TODOS os consumidores (grep pelo nome do hook).
- Bug "silencioso" (feature inerte, zero erro) é o pior tipo — validar feature de ponta a ponta, não só "compilou".
- `breakdown.total` é o número; o objeto inteiro NUNCA deve ser usado em comparação numérica.

---

## Incidente 10 — Shader WebGL + Liquid Glass adicionados e revertidos no mesmo dia (de-AI, 24/05/2026)

### O que aconteceu

O Sprint S13 ("UI Flagship", v4.9.0) adicionou em sequência: Liquid Glass sheen (`843e342`, `useGlassSheen`), fundo shader WebGL (`d4dc6cf`, `ShaderMeshBg` + `useCanRenderShader`) e View Transitions (`5d7aff0`). Horas depois, no mesmo dia, o commit `8a3f3e7` (v5.0.0) **reverteu** o shader + sheen + mesh como parte de uma decisão deliberada de "remover a cara de IA".

### Por que NÃO é um bug

Foi decisão arquitetural consciente (registrada em `.claude/constitution.md`): a estética "viva/hipnótica" (gradientes, shader, sheen, rainbow) lia como "gerado por IA". v5.0.0 trocou para identidade profissional sóbria: teal/petróleo, fundo sólido, Hanken Grotesk.

### O que sobreviveu

`ThemeToggle` com View Transitions API + `PulsoOrb3D` (Three.js) + `useScrollDepth`/`useTimeOfDay`/`useOrbState`/`ScrollReveal`.

### Licoes

- **Registrar reversões na documentação** — sem isso, uma sessão futura vê "S13 adicionou shader" no histórico e recria algo já descartado de propósito.
- Decisão de identidade visual é arquitetural → trava em constitution + gotcha (#50), não só no commit message.
- Adicionar feature visual grande e reverter horas depois é caro — validar a direção de design ANTES de implementar a camada inteira.

---

## Padroes de Prevencao

### Antes de editar banco/schema:

```
□ Tem dados reais? → NAO executar SQL destrutivo
□ A tabela ja existe no Supabase? → So documentar no all.sql
□ Preciso de nova tabela? → Criar via Dashboard Supabase, depois documentar
```

### Antes de editar calculos do dashboard:

```
□ O saldo continua correto? (receitas - TODAS as despesas)
□ Nao ha duplicacao? (outros gastos contados 2x)
□ O comparativo usa dados de 2 meses diferentes?
□ Os exports refletem os mesmos dados do dashboard?
```

### Antes de deploy:

```
□ npm run build — zero erros?
□ npm test — testes passando?
□ git diff — so arquivos esperados?
□ Env vars sensiveis fora do commit?
```

### Ao mexer em pgvector / Agent Memory v2 (S13+):

```
□ Dimensao do embedding e 384 (gte-small)? NAO misturar dimensoes
□ Indice HNSW (cosine) existe na coluna embedding?
□ Geracao de embedding e best-effort (UPDATE pos-INSERT, nunca bloqueia save)?
□ Fallback keyword/confianca funciona quando embedding e null?
```

### Ao mexer em UI / animacao (pos-v5.0.0 de-AI):

```
□ Zero indigo/violeta/roxo? (usar teal/petroleo)
□ Zero gradient rainbow / gradient-text decorativo?
□ NAO reintroduzi mesh/shader de fundo? (fundo e solido — decisao de-AI)
□ View Transitions tem feature detection + fallback + prefers-reduced-motion?
```

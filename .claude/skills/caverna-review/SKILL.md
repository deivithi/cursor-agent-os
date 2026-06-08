---
name: caverna-review
description: >
  Code review ultra-comprimido em PT-BR. Remove ruído de feedback de PR mantendo
  sinal acionável. Cada comentário é uma linha: localização, problema, fix. Usar
  quando usuário diz "review esse PR", "code review", "revisa o diff", "/review",
  ou invoca /caverna-review. Auto-ativa em pull requests.
type: behavior
---

Escreve review comments tersos e acionáveis. Uma linha por achado. Localização, problema, fix. Zero throat-clearing.

## Regras

**Formato:** `L<linha>: <problema>. <fix>.` — ou `<arquivo>:L<linha>: ...` em diffs multi-arquivo.

**Prefixo de severidade (opcional, quando misturado):**
- `🔴 bug:` — comportamento quebrado, causa incidente
- `🟡 risco:` — funciona mas frágil (race, null check faltando, erro engolido)
- `🔵 nit:` — estilo, naming, micro-otim. Autor pode ignorar
- `❓ pergunta:` — pergunta genuína, não sugestão

**Dropar:**
- "Notei que...", "Parece que...", "Você poderia considerar..."
- "É só uma sugestão mas..." — usa `nit:` direto
- "Ótimo trabalho!", "No geral tá bom mas..." — diz uma vez no topo, não por comentário
- Repetir o que a linha faz — reviewer lê o diff
- Hedging ("talvez", "acho") — se inseguro, usa `pergunta:`

**Manter:**
- Números de linha exatos
- Nomes exatos de símbolo/função/variável em backticks
- Fix concreto, não "considera refatorar isso"
- O motivo quando fix não é óbvio do problema

## Exemplos

❌ "Notei que na linha 42 você não está verificando se o objeto user é null antes de acessar a propriedade email. Isso pode causar um crash se o user não for encontrado no banco. Você poderia adicionar um null check aqui."

✅ `L42: 🔴 bug: user pode ser null após .find(). Adiciona guard antes de .email.`

❌ "Parece que esta função está fazendo muitas coisas e talvez se beneficiasse de ser quebrada em funções menores para melhor legibilidade."

✅ `L88-140: 🔵 nit: fn 50 linhas faz 4 coisas. Extrai validate/normalize/persist.`

❌ "Você considerou o que acontece se a API retornar 429? Acho que deveríamos tratar esse caso."

✅ `L23: 🟡 risco: sem retry em 429. Envolve em withBackoff(3).`

❌ "Na linha 15 você está fazendo query no loop, o que pode causar N+1. Considere usar include."

✅ `L15: 🔴 bug: N+1 query no loop. Usa \`include: { user: true }\` no findMany.`

## Exemplos stack Deivithi

**Pulso Finance:**
✅ `L42: 🔴 bug: useCelebration dispara em toda mudança. Adiciona deps [status] no useEffect.`
✅ `src/lib/supabase.ts:L12: 🟡 risco: client exposto no bundle. Usa createServerClient em server actions.`

**Supabase RLS:**
✅ `migrations/0042_users.sql:L8: 🔴 bug: tabela sem RLS (VDG-05). Adiciona \`ENABLE ROW LEVEL SECURITY\` + policy auth.uid().`

**n8n workflow:**
✅ `node "Telegram":L1: 🟡 risco: usando sendMessage sem \`continueOnFail\`. Se API falhar, workflow quebra. Ativa onError.`

## Auto-Clarity

Dropar modo terso p/: findings de segurança (bugs CVE-class precisam explicação + ref), discordância arquitetural (precisa rationale, não one-liner), contexto de onboarding onde autor é novo. Nesses casos escreve parágrafo normal, depois retoma terso.

## Limites

Só reviews — não escreve o fix, não aprova/request-changes, não roda linters. Output comentários prontos p/ colar no PR. "para caverna-review" ou "modo normal": reverte p/ estilo verbose.

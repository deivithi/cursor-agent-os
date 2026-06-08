# 🪨 Caverna Review — Code Review Terse PT-BR

Revisa mudanças de código com comentários de uma linha.

## Ação

Ativa skill `caverna-review`. Formato:

```
L<linha>: <severidade> <problema>. <fix>.
```

ou em multi-arquivo:

```
<arquivo>:L<linha>: <severidade> <problema>. <fix>.
```

## Severidades

- 🔴 `bug:` — comportamento quebrado, causa incidente
- 🟡 `risco:` — funciona mas frágil (race, null check, erro engolido)
- 🔵 `nit:` — estilo, naming, micro-otim. Autor pode ignorar
- ❓ `pergunta:` — pergunta genuína

## Dropar

- "Notei que...", "Parece que...", "Você poderia considerar..."
- Hedging ("talvez", "acho")
- Repetir o que a linha faz
- Elogios (diz uma vez no topo, não por comentário)

## Manter

- Números de linha exatos
- Nomes exatos em backticks (`userId`, `fetchData`)
- Fix concreto — não "considera refatorar"
- Motivo quando fix não-óbvio

## Exemplos

❌ "Notei que na linha 42 você não está verificando se user é null..."
✅ `L42: 🔴 bug: user pode ser null após .find(). Adiciona guard antes de .email.`

❌ "Essa função parece estar fazendo muita coisa..."
✅ `L88-140: 🔵 nit: fn 50 linhas faz 4 coisas. Extrai validate/normalize/persist.`

❌ "Você considerou o caso de 429?"
✅ `L23: 🟡 risco: sem retry em 429. Envolve em withBackoff(3).`

## Stack Deivithi

```
L42: 🔴 bug: useCelebration dispara em toda mudança. Adiciona deps [status] no useEffect.
migrations/0042.sql:L8: 🔴 bug: tabela sem RLS (VDG-05). Adiciona ENABLE + policy auth.uid().
node "Telegram":L1: 🟡 risco: sendMessage sem continueOnFail. Ativa onError.
```

## Auto-Clarity

Dropa modo terso p/: bugs CVE-class (explicação + ref), arquitetura (rationale), onboarding (autor novo). Escreve parágrafo normal, retoma terso depois.

## Limite

Só reviews. Não escreve o fix, não aprova/request-changes. Output pronto p/ colar no PR.

Ref: `.claude/skills/caverna-review/SKILL.md`

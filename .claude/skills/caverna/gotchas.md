# 🪨 Caverna — Gotchas (Armadilhas Conhecidas)

> Casos onde modo Ultra PT-BR erra ou confunde. Consultar antes de reportar bug.

## 🇧🇷 Acentos

### ❌ NUNCA dropar acentos
```
Errado Ultra: "aut nao valida token" (perdeu ã)
Correto Ultra: "aut ñ valida token" (usa ñ como abreviação, mantém acento em outras palavras)
```
**Por quê:** `feedback_portuguese_accents.md` é regra inviolável. Palavra sem acento vira palavra diferente (e.g., "esta" vs "está").

### ✅ Abreviar só o que NÃO tem acento
- "não" → "ñ" (OK, abreviação aceita)
- "também" → "tb" (OK)
- "está" → NUNCA "esta" (muda sentido)
- "será" → NUNCA "sera" (muda tempo verbal)

## 😀 Emojis

### ❌ Dropar emojis em Ultra
Original caveman dropa emojis. Caverna **mantém** — alta densidade informacional.
```
Errado: "Bug. Fix."
Correto Ultra: "🔴 Bug. Fix."
```
**Por quê:** Severity icons (🔴🟡🔵) = 1 token, transmitem severidade sem verbosidade.

## 📚 Vocabulário Febracis

### ❌ Abreviar termos de negócio
```
Errado Ultra: "Mét CIS reúne evs" (ilegível)
Correto Ultra: "Método CIS reúne eventos"
```
**Por quê:** Vocabulário do usuário (PO Salesforce Febracis) deve permanecer literal. Ref: `.claude/docs/caverna/GLOSSARIO.md`.

**Preservar sempre:**
- Método CIS
- Febracis
- DRE (Demonstrativo)
- Salesforce
- Service Cloud / Sales Cloud / Experience Cloud / Marketing Cloud
- Pulso Finance (projeto)
- Aria (projeto)
- FIO-IA (projeto)

## 🛡️ Supabase Destructive

### ❌ Ultra em operação destrutiva
```
Errado Ultra: "DROP users. OK."
Correto: "⚠️ DROP TABLE users apaga TUDO permanentemente. Sem WHERE, sem undo. Backup antes? Confirma?"
```
**Por quê:** `feedback_supabase_safety.md` — dados existentes são sagrados. Safety carve-out dispara verbose.

## 💻 Code Blocks

### ❌ Comprimir dentro de code block
```
Errado:
  ```ts
  // fn que valida aut
  const v = (t) => t.exp > Date.now()
  ```
Correto:
  ```ts
  const validateAuth = (token: string) => token.exp > Date.now();
  ```
```
**Por quê:** Code/commits/PRs sempre normal. Legibilidade > compressão dentro de técnico.

## 🇺🇸 Termos Técnicos

### ❌ Traduzir termos consagrados
```
Errado Ultra: "envolve em memo de uso" (useMemo traduzido)
Correto Ultra: "envolve em `useMemo`"
```
**Por quê:** Dev BR usa híbrido natural. Traduzir force termos EN = confusão.

**Manter EN:**
- Hooks React: `useMemo`, `useCallback`, `useEffect`, `useState`
- Async: `async`, `await`, `Promise`
- HTTP: request, response, endpoint, payload, headers
- DB: query, pool, handshake, transaction, RLS
- Deploy: build, deploy, rollback, CI/CD, pipeline
- Arquitetura: middleware, webhook, cache, proxy, load balancer

## 🔄 Pronome de tratamento

### ❌ Dropar "você" quando ambíguo
```
Errado: "Faz rebase main"
Correto Ultra: "Faz rebase em main"
```
**Por quê:** Verbo imperativo PT-BR às vezes precisa objeto. "Faz" sem objeto fica ambíguo.

## ⚠️ Modo Ultra + resposta longa

### ❌ Forçar Ultra em explicação conceitual longa
Se usuário pede "explica arquitetura", Ultra vira incompreensível.
**Ação:** mudar temporariamente p/ `completo`, ou chunks Ultra c/ headings.

## 🚫 Falso-positivo de "stop caverna"

### ❌ Desativar em menção casual
```
Usuário: "vamos parar de usar caverna-review aqui"
Errado: hook deleta flag
Correto: detectar que é sobre caverna-review específico, não caverna principal
```
**Por quê:** Regex `stop.*caverna` é amplo demais. `caverna-mode-tracker.js` deve distinguir.

## 📋 Hooks Windows

### ❌ Path separator
```
Errado JS: `path.join('~/.claude/hooks', 'caverna-activate.js')`
Correto: `path.join(os.homedir(), '.claude', 'hooks', 'caverna-activate.js')`
```
**Por quê:** Windows usa `\`, bash usa `/`. `path.join` normaliza.

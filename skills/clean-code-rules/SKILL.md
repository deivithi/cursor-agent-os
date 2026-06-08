---
name: clean-code-rules
description: >
  Rules condicionais de Clean Code por linguagem (JS/TS, Python, Go) baseadas
  em Google Style Guide, Airbnb JavaScript, Clean Code JavaScript, Effective Go
  e Google Go Style Guide. Integra com code-review como camada de enforcement
  de convenções.
domain: quality-assurance
subdomain: code-standards
version: 1.0.0
author: deivithi
sources:
  - google/styleguide (37K⭐)
  - airbnb/javascript (149K⭐)
  - ryanmcdermott/clean-code-javascript (92K⭐)
tags:
  - clean-code
  - style-guide
  - conventions
  - linting
  - javascript
  - typescript
  - python
  - golang
  - go
---

# 🧹 Clean Code Rules — Standards por Linguagem

> **"Qualquer tolo pode escrever código que um computador entenda. Bons programadores escrevem código que humanos entendam."** — Martin Fowler

## 📁 File Structure
- `SKILL.md` — Você está aqui. Regras completas por linguagem.
- `gotchas.md` — ⚠️ Problemas conhecidos ao aplicar as regras.
- `references/llm-anti-patterns.md` — 🚫 4 anti-patterns de LLMs com before/after e diff real (assumir silenciosamente, over-abstraction, drive-by refactoring, style drift).

## 🔗 Related Skills
- `code-review` — Usa estas regras como enforcement layer no review
- `test-driven-development` — Código que segue estas regras é mais testável
- `frontend-design` — Regras JS/TS aplicam-se a componentes React

---

## 🌐 Top 10 — Regras Universais (Todas as Linguagens)

> Aplique SEMPRE, independente da linguagem.

| # | Regra | Exemplo |
|---|-------|---------|
| 1 | **`const` por padrão** — mutabilidade só quando necessário | `const` em JS, evitar reatribuição em Python |
| 2 | **Uma função faz UMA coisa** — se precisa de "e depois...", quebre | Extrair em subfunções |
| 3 | **Máximo 2 params; 3+ use objeto/dict** | `createMenu({ title, body })` |
| 4 | **Sempre trate erros explicitamente** — nunca ignore catch/except | `catch (e) { logger.error(e) }` |
| 5 | **Strict equality sempre** | `===` em JS; `is` para None em Python |
| 6 | **Sem código morto** — remova, o git guarda | Funções, imports, blocos comentados |
| 7 | **Não mute parâmetros de entrada** | `return [...cart, item]` |
| 8 | **Extraia magic numbers em constantes** | `const MS_PER_DAY = 86_400_000` |
| 9 | **Imports no topo, agrupados por origem** | stdlib → third-party → local |
| 10 | **Encapsule condicionais complexas em funções** | `if (shouldShowSpinner(state))` |

---

## 🟨 JavaScript / TypeScript

### Naming
- `camelCase` → variáveis, funções, métodos, instâncias: `getUserData`, `isActive`
- `PascalCase` → classes, componentes React, interfaces, types: `UserProfile`, `HttpClient`
- `UPPER_SNAKE_CASE` → constantes de módulo: `MAX_RETRIES`, `API_BASE_URL`
- Booleanos com prefixo: `is`, `has`, `can`, `should`: `isVisible`, `hasPermission`
- Handlers: `handleClick`, `onSubmit`
- Arquivo = export default: `CheckBox.tsx` → exporta `CheckBox`
- ❌ NUNCA: `_private` (use `private` do TS), nomes genéricos (`data`, `info`, `temp`)

### Functions
- Máximo 2 params posicionais; 3+ → objeto com destructuring
- Default params no final: `function fetch(url, options = {})`
- Arrow functions para callbacks: `items.map((x) => x.id)`
- SEMPRE parênteses em arrows: `(x) => x + 1` ❌ `x => x + 1`
- Spread `...` em vez de `.apply()` — rest params em vez de `arguments`
- ❌ NUNCA: mutar params, reatribuir params, `new Function()`, funções dentro de `if`

### Error Handling
- NUNCA ignore `catch` — `catch (e) { console.error(e); reportToService(e); }`
- NUNCA ignore promessas rejeitadas — todo `.catch()` trata o erro
- Use `Error` ou subclasses: `throw new Error('msg')` ❌ `throw 'string'`
- `try/catch` envolvendo MÍNIMO de código
- Em TS: error classes customizadas com `extends Error`

### Imports & Modules
- SEMPRE ESM (`import`/`export`) ❌ NUNCA `require`/`module.exports`
- Ordem: (1) node built-in (2) third-party (3) local — separados por linha branca
- Um path = um import: `import foo, { bar } from 'foo'`
- ❌ NUNCA: `import *` (exceto namespace), `export default` (Google TS), `export let`
- Use `import type { Foo }` para tipos (TS)

### Formatting
- 2 espaços de indentação
- Trailing commas em multiline (facilita diffs)
- Semicolons obrigatórios
- Single quotes: `'text'` — template literals só com interpolação: `` `Hello ${name}` ``
- ❌ NUNCA: concatenar strings com `+`, ternários aninhados

### Classes & Objects
- SEMPRE `class` syntax ❌ NUNCA manipular `prototype`
- Object/array literal `{}` / `[]` ❌ NUNCA `new Object()` / `new Array()`
- Spread para copiar: `{ ...obj, newProp }` ❌ NUNCA `Object.assign(original, ...)`
- Property shorthand: `{ name, getValue() {} }`
- Destructuring para múltiplas props: `const { name, age } = user`
- Dot notation: `obj.prop` ❌ NUNCA `obj['prop']` (brackets só com variável)
- Composição > herança

### Anti-patterns ❌ (NUNCA em JS/TS)
```
var                              → const/let
== / !=                          → === / !==
arguments object                 → rest params ...args
for...in sem filtro              → Object.keys() / Object.entries()
for clássico quando map resolve  → .map() / .filter() / .reduce()
Flag booleano como parâmetro     → duas funções separadas
Matar prototype                  → nunca
++ / --                          → += 1 / -= 1
console.log em catch             → console.error ou report service
eval() / new Function()          → nunca
```

---

## 🐍 Python

### Naming
- `snake_case` → funções, métodos, variáveis, params, módulos: `get_user_data`, `item_count`
- `CapWords` → classes e exceptions: `UserProfile`, `InvalidTokenError`
- `UPPER_SNAKE_CASE` → constantes: `MAX_RETRIES`, `DEFAULT_TIMEOUT`
- `_leading_underscore` → membros internos/protected: `_internal_cache`
- Arquivo: `lower_with_under.py` ❌ NUNCA dashes ou CapWords
- ❌ NUNCA: `__dunder__` customizado, tipo no nome (`user_list_dict`)

### Functions
- Máximo 2-3 params posicionais; mais → keyword arguments
- ❌ NUNCA mutable default: `def foo(items=None):` com `items = items or []`
- Type hints em funções públicas: `def process(data: list[str]) -> dict[str, int]:`
- Docstring Google style obrigatória para funções públicas:
  ```python
  def fetch(url: str, timeout: int = 30) -> dict:
      """Fetches data from URL.

      Args:
          url: The endpoint URL.
          timeout: Request timeout in seconds.

      Returns:
          Dict with response data.

      Raises:
          ConnectionError: If URL unreachable.
      """
  ```
- Use `*` para forçar keyword-only: `def foo(name, *, verbose=False)`

### Error Handling
- ❌ NUNCA bare `except:` — captura sys.exit() e KeyboardInterrupt
- ❌ NUNCA `except Exception` sem re-raise (exceto isolation points)
- Use built-in exceptions: `ValueError`, `TypeError`
- Minimize código no `try`
- Context managers: `with open(f) as fh:`
- ❌ NUNCA `assert` para validação de input (pode ser otimizado fora)

### Imports & Modules
- Um import por linha: `import os` + `import sys` ❌ `import os, sys`
- SEMPRE no topo, após docstring do módulo
- Ordem: (1) `__future__` (2) stdlib (3) third-party (4) local
- ❌ NUNCA: `from x import *`, imports relativos implícitos
- Aliases padrão: `import numpy as np`, `import pandas as pd`

### Formatting
- 4 espaços de indentação ❌ NUNCA tabs
- Máximo 80-100 caracteres por linha
- f-strings: `f"Hello {name}"` ❌ NUNCA `"Hello " + name`
- Logging lazy: `logging.info('Found %d items', count)` ❌ NUNCA f-string em logging
- `is` para None: `if x is None:` ❌ `if x == None:`
- Implicit booleans: `if items:` (exceto inteiros: `if count != 0:`)

### Classes & OOP
- `@property` em vez de getters/setters
- `@dataclass` ou `NamedTuple` para data containers
- `@staticmethod` sem self/cls; `@classmethod` para factories
- `__repr__` para debug
- Composição > herança

### Anti-patterns ❌ (NUNCA em Python)
```
except:  (bare)                  → except SpecificError:
except Exception sem re-raise    → sempre re-raise ou log
assert para validação            → if/raise
from module import *             → imports explícitos
def f(x=[])  (mutable default)  → def f(x=None)
global keyword                   → evitar (exceto scripts triviais)
os.system() com input externo    → subprocess com shell=False
eval() / exec() com input        → nunca
pickle com dados não confiáveis  → nunca
random para secrets              → secrets module
string concat em loops           → ''.join(parts)
type() para checagem             → isinstance()
```

---

## 🐹 Go (Golang)

> Regras canônicas: https://go.dev/doc/effective_go + https://google.github.io/styleguide/go/ + https://go.dev/wiki/CodeReviewComments
> Skill completa: `.claude/skills/golang/SKILL.md` — consultar para profundidade (concorrência, performance, testing, integração Supabase).

### Naming

| Elemento | Convenção | Exemplo |
|---|---|---|
| Package | lower, curto, s/ underscore | `http`, `user`, `repo` |
| Exported | `MixedCaps` (PascalCase) | `NewServer`, `UserID` |
| Unexported | `mixedCaps` (camelCase) | `newServer`, `userID` |
| Acronyms | consistentes UPPER | `ID` (ñ `Id`), `URL`, `HTTP` |
| Receiver | 1-2 letras | `func (s *Server)`, ñ `func (this *Server)` |
| Interface 1-método | sufixo `-er` | `Reader`, `Writer`, `Stringer` |
| Context | 1º param sempre | `func Do(ctx context.Context, ...)` |

### Functions

- 1 responsabilidade. Máx 3 params. 4+ → struct.
- Erro como **último return**: `(T, error)`.
- Guard clauses / return early. Zero nesting profundo.
- `named returns` só em funções curtas onde nomear documenta.

### Error Handling

```go
// ✅ Wrapping com %w (preserva chain para errors.Is/As)
return fmt.Errorf("fetch user %d: %w", id, err)

// ✅ Sentinel
var ErrNotFound = errors.New("not found")

// ❌ Perde chain
return fmt.Errorf("failed: %v", err)

// ❌ Panic em lib
panic("oops")
```

- SEMPRE checar `err`. `_ = err` só c/ comentário justificando.
- `errors.Is` / `errors.As` para comparação/extração.
- Errors lowercase sem ponto final: `"not found"`.
- `panic` apenas em `main`/`init` irrecuperável.

### Imports (goimports automatiza)

```go
import (
    // stdlib
    "context"
    "fmt"

    // third-party
    "github.com/go-chi/chi/v5"
    "github.com/jackc/pgx/v5/pgxpool"

    // internal
    "example.com/app/internal/user"
)
```

### Formatting

- **`gofmt` sempre** (sem discussão). `gofmt -s -w .` ou `goimports -w .`
- Tabs p/ indent (gofmt default). Line length sem limite rígido.

### Interfaces / Composição

- Interface **pequena** (1-3 métodos). "The bigger the interface, the weaker the abstraction" (Go Proverb).
- Interface definida **no consumer**, não no producer.
- Composition > inheritance (Go ñ tem classes; usar embedding).

### Zero Value

Struct deve ser útil em zero value. `sync.Mutex`, `bytes.Buffer` funcionam assim.

### Anti-patterns Go

| Violação | Severidade |
|---|---|
| `panic` em lib | 🔴 CRITICAL |
| Concat string em SQL | 🔴 CRITICAL |
| Goroutine s/ estratégia de término (leak) | 🔴 CRITICAL |
| Map concorrente s/ mutex | 🔴 CRITICAL |
| `math/rand` em segurança | 🔴 CRITICAL |
| `fmt.Errorf` s/ `%w` | 🟠 HIGH |
| `context.Background()` em handler HTTP (perde cancel) | 🟠 HIGH |
| `http.Client` s/ timeout | 🟠 HIGH |
| `init()` mágico c/ side-effect | 🟠 HIGH |
| Global mutável s/ justificativa | 🟠 HIGH |
| `interface{}` qndo `any` existe (1.18+) | 🟡 MEDIUM |
| Receiver inconsistente | 🟡 MEDIUM |
| `ioutil.*` (deprecado 1.16) | 🟡 MEDIUM |
| Interface "God" (15 métodos) | 🟡 MEDIUM |
| Sem gofmt | 🟢 LOW |

### Checklist Go

```
□ gofmt -s -l . → vazio
□ go vet ./... → limpo
□ staticcheck ./... → limpo
□ go test -race -count=1 ./... → PASS
□ golangci-lint run → zero issues
□ govulncheck ./... → No vulns
□ err != nil checado em todo lugar
□ %w em wrapping
□ context.Context 1º param em funções long-running
□ Zero panic em libs
```

---

## 🔄 Como Integrar com Code Review

Ao executar `/code-review`, o reviewer DEVE:

1. **Detectar linguagem** do arquivo sob review
2. **Carregar regras** da seção correspondente acima
3. **Classificar violações** usando Severity Scoring:
   - 🔴 CRITICAL: `eval()`, secrets em código, SQL injection
   - 🟠 HIGH: `var`, bare except, mutable default, `any` em TS
   - 🟡 MEDIUM: naming inconsistente, magic numbers, imports desordenados
   - 🟢 LOW: formatting, shorthand, estilo
4. **Reportar** com regra específica violada + fix sugerido

---

## Handoff Points

| Quando | Repassar para | Condição |
|--------|--------------|----------|
| Enforcement durante review | `code-review` | Integrar como camada de convenções no review |
| Código limpo precisa de testes | `test-driven-development` | TDD complementar — código testável = código limpo |
| Violações sistemáticas detectadas | `alpha-loop` | Loop iterativo para refatorar até compliance |
| Regras JS/TS em componentes React | `frontend-design` | Aplicar convenções no contexto de UI |
| Auditoria profunda de qualidade | `agent-skill-patterns` | Padrão Reviewer + Severity Scoring formal |

---

## 📏 Quick Reference Card

```
JS/TS                          Python
─────                          ──────
camelCase (vars/funcs)         snake_case (vars/funcs)
PascalCase (classes)           CapWords (classes)
UPPER_SNAKE (consts)           UPPER_SNAKE (consts)
2 spaces indent                4 spaces indent
const > let > ❌var            avoid reassignment
=== always                     is for None
import/export (ESM)            import at top
template literals              f-strings
Error subclasses               Exception subclasses
```

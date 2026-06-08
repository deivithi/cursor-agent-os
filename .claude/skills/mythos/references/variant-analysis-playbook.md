# Variant Analysis Playbook — Grep Patterns por Classe

> Dado um bug confirmado, este playbook mostra como buscar variantes no codebase.
> Cap: max 2 niveis de profundidade (original → variante → variante-de-variante → PARAR).

---

## Metodologia

```
1. ABSTRAIR: Bug especifico → Classe generica
2. PATTERN: Classe → Grep/ripgrep pattern
3. BUSCAR: Rodar pattern no codebase
4. FILTRAR: Para cada match — e exploitavel no contexto?
5. REPORTAR: Adicionar ao report com cross-reference ao original
```

---

## Patterns por Classe de Vulnerabilidade

### SQL Injection

**Abstraido:** String de usuario concatenada em query SQL

```bash
# Template literals em queries
rg "query\s*\(" --type ts -A2 | rg '\$\{|`SELECT|`INSERT|`UPDATE|`DELETE'

# Concatenacao direta
rg "SELECT.*\+.*req\." --type ts
rg "WHERE.*\+.*params" --type ts

# Python f-strings em SQL
rg 'execute\(f"' --type py
rg "execute\(f'" --type py
rg 'cursor\.(execute|fetchone|fetchall)\(' --type py -A1
```

### Missing Auth Check

**Abstraido:** API route sem middleware de autenticacao

```bash
# Next.js routes sem auth
rg "export (async )?function (GET|POST|PUT|DELETE|PATCH)" --type ts -l
# Comparar com routes que TEM auth:
rg "getSession|getUser|auth\(\)|requireAuth|withAuth" --type ts -l

# Express routes sem middleware
rg "app\.(get|post|put|delete)\(" --type ts -A1 | rg -v "auth|session|verify"

# FastAPI sem Depends(auth)
rg "@app\.(get|post|put|delete)" --type py -A2 | rg -v "Depends|current_user"
```

### IDOR (Insecure Direct Object Reference)

**Abstraido:** Acesso a recurso por ID sem verificar ownership

```bash
# Buscar por params.id sem auth check
rg "params\.(id|userId|orderId)" --type ts -B3 -A3

# Supabase sem filtro de user
rg "\.from\(.*\)\.select\(\)" --type ts -A2 | rg -v "auth\.uid|user_id|\.eq\("

# ID sequencial em modelos
rg "SERIAL|BIGSERIAL|autoIncrement" --type sql
rg "autoincrement|auto_increment" -i --type sql
```

### XSS (Cross-Site Scripting)

**Abstraido:** Dados de usuario renderizados sem sanitizacao

```bash
# React dangerouslySetInnerHTML
rg "dangerouslySetInnerHTML" --type tsx

# innerHTML direto
rg "\.innerHTML\s*=" --type ts --type js

# Template literals em HTML
rg "\.html\s*\(" --type ts -A1
rg "document\.write\(" --type ts --type js

# Python template rendering sem escape
rg "render_template_string\(" --type py
rg "\|safe" --type html
```

### Hardcoded Secrets

**Abstraido:** Credenciais em codigo fonte

```bash
# API keys e tokens
rg "(sk_live|sk_test|pk_live|pk_test|api_key|apiKey|API_KEY|secret|SECRET|password|PASSWORD)" \
   --type ts --type js --type py -i | rg -v "(test|mock|example|placeholder|TODO)"

# Connection strings
rg "(postgres|mysql|mongodb|redis)://" --type ts --type py | rg -v "localhost"

# JWT secrets
rg "(JWT_SECRET|jwt_secret|jwtSecret)" --type ts --type py -A1
```

### Path Traversal

**Abstraido:** Caminho de arquivo construido com input de usuario

```bash
# Path join com input
rg "(path\.join|path\.resolve)\(.*req\." --type ts
rg "os\.path\.join\(.*request" --type py

# File read com input
rg "(readFile|readFileSync|createReadStream)\(" --type ts -B2
rg "open\(.*request" --type py
```

### Race Conditions (TOCTOU)

**Abstraido:** Check seguido de uso sem atomicidade

```bash
# Check-then-act patterns
rg "(exists|access|stat)\s*\(" --type ts -A3 | rg "(read|write|unlink|open)"
rg "os\.(path\.exists|access)\(" --type py -A3

# Balance check then deduct (business logic)
rg "balance|credits|quota" --type ts -A5 | rg "(>=|<=|>|<)" -A3
```

### Insecure Deserialization

**Abstraido:** Deserializacao de dados nao confiaveis

```bash
# Python pickle
rg "pickle\.(loads|load)\(" --type py
rg "yaml\.load\(" --type py | rg -v "SafeLoader|safe_load"

# JavaScript eval-like
rg "(eval|Function)\(" --type ts --type js | rg -v "test|spec|mock"

# JSON.parse sem try-catch (crash, nao security per se)
rg "JSON\.parse\(" --type ts -B1 | rg -v "try|catch"
```

---

## Workflow com Subagentes (L3)

```
SUBAGENTE 1 (sintatico):
  Rodar TODOS os grep patterns acima no codebase
  Reportar matches com arquivo:linha

SUBAGENTE 2 (semantico):
  Para cada match do subagente 1:
  - Ler contexto (20 linhas ao redor)
  - Avaliar: ha sanitizacao/validacao upstream?
  - Classificar: TRUE POSITIVE / FALSE POSITIVE / UNDETERMINED

SUBAGENTE 3 (lateral):
  Buscar patterns que os greps acima NAO cobrem:
  - Funcoes wrapper que escondem o pattern (ex: helper que chama eval internamente)
  - Patterns em linguagens/frameworks nao cobertos acima
  - Anti-patterns custom do projeto
```

---

## Regra de Ouro

> "Se voce encontrou UM bug desta classe, ha PELO MENOS mais um no mesmo codebase."
> — Heuristca do Trail of Bits

Variant analysis nao e opcional apos encontrar um bug de Classe 1-5.
E obrigatoria em L2 Hunt e L3 Siege.

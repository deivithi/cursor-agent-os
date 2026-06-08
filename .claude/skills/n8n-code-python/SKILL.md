---
name: n8n-code-python
description: >
  Padrões Python para Code nodes n8n. Documenta limitações do Native Python v2,
  diferenças do Pyodide legacy, e quando usar Execute Command.
domain: automation
subdomain: n8n-code
version: 1.0.0
author: deivithi
tags:
  - n8n
  - code-node
  - python
  - sandbox
---

# 🐍 n8n Code Node — Python

> **"Python em n8n NÃO é Python normal. É Python em sandbox com variáveis diferentes e sem imports por default."**

## 📁 File Structure
- `SKILL.md` — Você está aqui.

## 🔗 Related Skills
- `n8n-code-javascript` — Code nodes JS (mais estável e documentado no n8n)
- `n8n-expression-syntax` — Expressões n8n em campos de nodes
- `n8n-node-configuration` — Configurar Execute Command para Python complexo

---

## 🚨 Breaking Change: Pyodide → Native Python (n8n v2)

| Aspecto | Pyodide (Legacy) | Native Python (v2+) |
|---------|-------------------|----------------------|
| **Variáveis** | `_input`, `_json`, `_node`, `_binary` | **Apenas `_items` e `_item`** |
| **Dot access** | `item.json.field` funciona | **NÃO funciona** — usar `item["json"]["field"]` |
| **Imports** | Pacotes Pyodide | Bloqueados por default |
| **Performance** | Lento (WebAssembly) | Nativo, rápido |
| **JsProxy** | Precisa `.to_py()` | Não aplicável |

> ⚠️ **Se estiver migrando de Pyodide para Native Python:** Substituir TODAS as referências de `_input`, `_json` para `_items`/`_item`, e trocar dot access por bracket notation.

---

## 📐 Formato de Retorno

### Modo "Run Once for All Items"

```python
# ✅ CORRETO — lista de dicts com key "json"
return [
    {"json": {"nome": "Item 1", "valor": 100}},
    {"json": {"nome": "Item 2", "valor": 200}}
]

# ❌ ERRADO — sem key "json"
return [{"nome": "Item 1"}]

# ❌ ERRADO — "json" como lista
return [{"json": [1, 2, 3]}]
```

### Modo "Run Once for Each Item"

```python
# ✅ CORRETO
return {"json": {"resultado": _item["json"]["campo"] * 2}}
```

---

## 🏗️ Variáveis Built-in (Native Python v2)

### Modo "All Items"

```python
# _items contém todos os items de entrada
for item in _items:
    campo = item["json"]["meuCampo"]  # bracket notation obrigatório!
```

### Modo "Each Item"

```python
# _item contém o item atual
valor = _item["json"]["meuCampo"]
```

### ❌ Variáveis que NÃO EXISTEM MAIS no v2

| Legacy (Pyodide) | Status v2 |
|-------------------|-----------|
| `_input` | ❌ Removido |
| `_json` | ❌ Removido |
| `_node` | ❌ Removido |
| `_binary` | ❌ Removido |
| `_env` | ❌ Removido |

---

## 🎯 Padrões de Produção

### Pattern 1: Transform simples

```python
results = []
for item in _items:
    data = item["json"]
    results.append({
        "json": {
            "nome": data.get("nome", "").upper(),
            "email": data.get("email", "").lower().strip(),
            "ativo": data.get("status") == "active"
        }
    })
return results
```

### Pattern 2: Filter

```python
results = []
for item in _items:
    score = item["json"].get("score", 0)
    if score > 50:
        results.append({"json": item["json"]})

if not results:
    return [{"json": {"error": "Nenhum item passou no filtro", "count": 0}}]

return results
```

### Pattern 3: Aggregate

```python
all_data = [item["json"] for item in _items]
return [{"json": {"items": all_data, "count": len(all_data)}}]
```

### Pattern 4: Dedup

```python
seen = set()
unique = []
for item in _items:
    key = item["json"].get("email", "").lower()
    if key and key not in seen:
        seen.add(key)
        unique.append({"json": item["json"]})
return unique
```

### Pattern 5: Parse JSON defensivo

```python
import json  # Disponível na stdlib (geralmente permitido)

raw = _items[0]["json"].get("output", "")
try:
    parsed = json.loads(raw)
    return [{"json": {"parsed": parsed, "success": True}}]
except json.JSONDecodeError:
    return [{"json": {"error": "JSON inválido", "raw": raw[:500]}}]
```

---

## 🔀 Quando Usar Execute Command em Vez de Code Node Python

| Cenário | Recomendação |
|---------|-------------|
| Transformação de dados simples | ✅ Code Node Python |
| Precisa de `pandas`, `numpy`, `requests` | ❌ **Execute Command** + script `.py` externo |
| Precisa de filesystem (ler/escrever) | ❌ **Execute Command** |
| Processamento de imagem (PIL, OpenCV) | ❌ **Execute Command** |
| ML inference (sklearn, torch) | ❌ **Execute Command** |
| Regex e string processing | ✅ Code Node Python |

### Execute Command com Python

```
python3 /path/to/script.py "{{ $json.arg1 }}" "{{ $json.arg2 }}"
```

---

## ⚠️ Gotchas Conhecidos

### 1. Dot access QUEBRA silenciosamente no Native Python
```python
# ❌ Pode parecer funcionar no editor mas falha em produção
valor = _item.json.campo

# ✅ Sempre usar bracket notation
valor = _item["json"]["campo"]
```

### 2. `json` stdlib nem sempre está disponível
Depende da configuração do servidor. Usar `try/except` ao importar.

### 3. DateTime não tem Luxon
Python não tem DateTime do Luxon. Usar `datetime` da stdlib (se allowlisted):
```python
from datetime import datetime, timezone, timedelta
brt = timezone(timedelta(hours=-3))
now = datetime.now(brt)
formatted = now.strftime("%d/%m/%Y %H:%M") + " BRT"
```

### 4. n8n Cloud: ZERO imports
No Cloud, nenhum import funciona. Processamento 100% com built-ins do Python.

### 5. JS é mais estável em n8n
Se não tem razão forte para Python, **prefira JavaScript**. A comunidade n8n, exemplos oficiais e debugging são todos JavaScript-first.

---

## 🔧 Allowlist (Self-hosted, Task Runners)

```json
{
  "task-runners": [{
    "runner-type": "python",
    "env-overrides": {
      "N8N_RUNNERS_STDLIB_ALLOW": "json,datetime,re,math,collections",
      "N8N_RUNNERS_EXTERNAL_ALLOW": "numpy,pandas"
    }
  }]
}
```

Para pacotes externos, Docker customizado:
```dockerfile
FROM n8nio/runners:latest
USER root
RUN cd /opt/runners/task-runner-python && uv pip install numpy pandas
USER runner
```

---

## Regras Invioláveis

1. **NUNCA usar dot access** — sempre bracket notation `item["json"]["campo"]`
2. **NUNCA usar `_input`, `_json`, `_node`** — são variáveis Pyodide legacy, não existem no v2
3. **NUNCA assumir imports disponíveis** — testar com try/except
4. **SEMPRE retornar lista de dicts com key `json`** no modo All Items
5. **SEMPRE preferir JavaScript** se não há razão forte para Python
6. **SEMPRE usar Execute Command** para processamento que precisa de pacotes externos

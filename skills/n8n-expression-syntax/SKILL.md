---
name: n8n-expression-syntax
description: >
  Referência completa de expressões n8n: sintaxe {{}}, variáveis $json/$node/$input,
  erros comuns, e padrões seguros para campos de nodes.
domain: automation
subdomain: n8n-expressions
version: 1.0.0
author: deivithi
tags:
  - n8n
  - expressions
  - syntax
  - variables
---

# 📝 n8n Expression Syntax

> **"Expressões n8n são JavaScript dentro de `{{ }}` — mas com variáveis especiais e armadilhas próprias."**

## 📁 File Structure
- `SKILL.md` — Você está aqui.

## 🔗 Related Skills
- `n8n-code-javascript` — Code nodes completos (quando expressões não bastam)
- `n8n-validation-expert` — Debug de erros em expressões
- `n8n-node-configuration` — Onde colocar expressões em cada tipo de node

---

## 🔤 Sintaxe Básica

### Expressão simples
```
{{ $json.campo }}
```

### Com transformação
```
{{ $json.email.toLowerCase() }}
```

### Condicional (ternário)
```
{{ $json.status === 'active' ? '✅ Ativo' : '❌ Inativo' }}
```

### Fallback (nullish coalescing)
```
{{ $json.nome ?? 'Sem nome' }}
```

### Template string dentro de expressão
```
{{ `Olá ${$json.nome}, seu score é ${$json.score}` }}
```

---

## 🏗️ Variáveis — Referência Completa

### Dados do Item Atual

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `$json` | Dados JSON do item atual | `{{ $json.email }}` |
| `$json.campo` | Campo específico | `{{ $json.nome }}` |
| `$json["campo com espaço"]` | Campo com caracteres especiais | `{{ $json["Nome Completo"] }}` |
| `$binary` | Dados binários do item | `{{ $binary.data.fileName }}` |

### Input Completo

| Variável | Descrição |
|----------|-----------|
| `$input.all()` | Array com todos os items |
| `$input.first()` | Primeiro item |
| `$input.last()` | Último item |
| `$input.item` | Item atual |
| `$input.length` | Quantidade de items |

### Acesso a Outros Nodes

```
{{ $("Nome do Node").first().json.campo }}
{{ $("Nome do Node").all()[0].json.campo }}
{{ $("Nome do Node").item.json.campo }}
```

> ⚠️ O nome do node é **case-sensitive** e deve ser **exatamente** como aparece no workflow.

### Metadados

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `$workflow.id` | string | ID do workflow |
| `$workflow.name` | string | Nome do workflow |
| `$workflow.active` | boolean | Se está ativo |
| `$execution.id` | string | ID da execução |
| `$execution.mode` | string | `test` ou `production` |
| `$execution.resumeUrl` | string | URL para resumir (Wait node) |
| `$itemIndex` | number | Índice do item (0-based) |
| `$runIndex` | number | Quantas vezes o node executou |
| `$prevNode.name` | string | Nome do node anterior |

### Date/Time (Luxon)

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `$now` | Timestamp atual (Luxon DateTime) | `{{ $now.toISO() }}` |
| `$today` | Data atual meia-noite | `{{ $today.toFormat('dd/MM/yyyy') }}` |
| `DateTime` | Classe Luxon | `{{ DateTime.fromISO($json.date) }}` |

### Variáveis de Ambiente

| Variável | Descrição |
|----------|-----------|
| `$env.NOME` | Env var (bloqueada por default no v2) |
| `$vars.nome` | Variável customizada do n8n (read-only) |

---

## 🎯 Padrões Seguros

### Acesso seguro a campos aninhados

```
{{ $json.address?.city ?? 'N/A' }}
{{ $json.items?.[0]?.name ?? 'Sem items' }}
```

### Formatação de data em BRT

```
{{ $now.setZone('America/Sao_Paulo').toFormat('dd/MM/yyyy HH:mm') + ' BRT' }}
```

> ⚠️ **NUNCA** concatenar `$now` direto com string — retorna unix timestamp!

### Número formatado

```
{{ $json.valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' }) }}
```

### Condicional multi-valor

```
{{ ['active', 'pending'].includes($json.status) ? 'Processar' : 'Ignorar' }}
```

### Regex em expressão

```
{{ $json.email.match(/@(.+)$/)?.[1] ?? 'Domínio desconhecido' }}
```

---

## ❌ Anti-Patterns e Erros Comuns

### 1. Concatenar $now com string
```
❌ {{ "Data: " + $now }}          → "Data: 1679500800" (unix!)
✅ {{ "Data: " + $now.toFormat('dd/MM/yyyy HH:mm') }}
```

### 2. Unicode escape em expressões
```
❌ {{ "\\u26a0\\ufe0f Alerta" }}   → Literal "\u26a0\ufe0f"
✅ {{ "⚠️ Alerta" }}               → Emoji real
```

### 3. Campo inexistente sem fallback
```
❌ {{ $json.endereco.cep }}         → Erro se endereco é undefined
✅ {{ $json.endereco?.cep ?? '' }}  → String vazia se não existe
```

### 4. Nome do node errado
```
❌ {{ $("email trigger").first().json.from }}   → Erro (case errado)
✅ {{ $("Email Trigger").first().json.from }}   → Funciona
```

### 5. Comparação case-sensitive em filtros
```
❌ {{ $json.email === "user@DOMAIN.com" }}
✅ {{ $json.email.toLowerCase() === "user@domain.com" }}
```

### 6. Expressão sem {{ }}
```
❌  $json.campo                    → Texto literal "$json.campo"
✅  {{ $json.campo }}              → Valor do campo
```

### 7. Espaço extra dentro das chaves
```
✅ {{ $json.campo }}               → Funciona (espaços OK)
✅ {{$json.campo}}                 → Funciona também
```

---

## 🔀 Expressão vs Code Node — Quando Usar Cada

| Cenário | Usar |
|---------|------|
| Acessar/transformar 1 campo | **Expressão** |
| Condicional simples (ternário) | **Expressão** |
| Loop, map, filter, aggregate | **Code Node** |
| Lógica com try/catch | **Code Node** |
| Parse de JSON complexo | **Code Node** |
| Mais de 3 linhas de lógica | **Code Node** |

---

## 🧪 Debugging de Expressões

1. **Editor de expressões** — Clicar no campo → ícone de expressão → testar ao vivo
2. **Execution data** — Após executar, clicar no node → aba "Output" → ver dados reais
3. **console.log no Code node** — Se a expressão é complexa, mover para Code node e usar console.log
4. **$execution.mode** — Testar se está em test/production: `{{ $execution.mode === 'test' ? 'DEBUG' : '' }}`

---

## Regras Invioláveis

1. **SEMPRE usar `{{ }}` em campos de expressão** — sem chaves, é texto literal
2. **NUNCA concatenar `$now` direto com string** — usar `.toFormat()` primeiro
3. **SEMPRE usar optional chaining (`?.`)** para campos aninhados
4. **SEMPRE usar emojis reais** — nunca `\uXXXX` escape sequences
5. **SEMPRE verificar o nome exato do node** ao usar `$("Node Name")`
6. **SEMPRE usar `.toLowerCase()` em comparações de email** — emails são case-insensitive

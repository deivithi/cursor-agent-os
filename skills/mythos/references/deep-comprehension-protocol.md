# Deep Comprehension Protocol — Leitura Linha-a-Linha

> O diferencial do Mythos: ler o que o codigo FAZ, nao o que PARECE fazer.
> Aplicar em cada funcao de arquivos priority 4-5.

---

## O Protocolo

### Passo 1: Leitura Literal

Para cada linha, declarar em linguagem natural o que ela FAZ:

```javascript
// Exemplo: funcao de verificacao de token
function verifyToken(token) {           // Recebe string token
  const parts = token.split('.');       // Divide por '.' — assume formato JWT
  if (parts.length !== 3) return null;  // Rejeita se nao tem 3 partes
  const payload = JSON.parse(           // Parseia payload como JSON
    Buffer.from(parts[1], 'base64')     // Decodifica base64 da parte 1
      .toString()
  );
  if (payload.exp < Date.now() / 1000) return null;  // Verifica expiracao
  return payload;                       // RETORNA PAYLOAD SEM VERIFICAR ASSINATURA!
}
```

**O que PARECE fazer:** Verificar um JWT token.
**O que REALMENTE FAZ:** Decodificar um JWT SEM verificar a assinatura. Qualquer um pode forjar tokens.

---

### Passo 2: Extracao de Suposicoes

Lista de suposicoes implicitas do exemplo acima:

| # | Suposicao | Quem garante? | Atacante pode violar? |
|---|-----------|--------------|----------------------|
| 1 | Token e string valida | Caller | Sim — pode ser null/undefined |
| 2 | Token esta no formato JWT (3 partes com '.') | Ninguem verifica formato real | Sim — qualquer string com 2 dots passa |
| 3 | Parte 1 e base64 valido | Ninguem | Sim — crash em Buffer.from |
| 4 | Parte 1 e JSON valido | Ninguem | Sim — crash em JSON.parse |
| 5 | Assinatura e valida | **NINGUEM — BUG CRITICO** | **Sim — forjar qualquer payload** |
| 6 | Clock do servidor e preciso | Sistema | Parcialmente — clock skew |

→ Suposicao #5 e o bug. As outras sao crashes de robustez.

---

### Passo 3: First Principles Challenge

Para cada suposicao critica, perguntar:

```
SUPOSICAO: "A assinatura do JWT e valida"
QUEM GARANTE: Ninguem — nao ha chamada a jwt.verify() ou crypto.verify()
ATACANTE PODE VIOLAR: Sim — criar JWT com qualquer payload e assinatura invalida
O QUE ACONTECE SE FALSA: Auth bypass total — atacante pode se passar por qualquer usuario
SEVERIDADE: CRITICAL (A01 Broken Access Control + A02 Cryptographic Failures)
```

---

### Passo 4: 5 Whys

Aplicar em codigo suspeito:

```
Bug: Upload handler nao verifica content-type real

WHY 1: Por que nao verifica?
→ Confia na extensao do filename

WHY 2: Por que confia na extensao?
→ O framework/tutorial original fazia assim

WHY 3: Por que a extensao nao e confiavel?
→ Atacante controla o filename no multipart form

WHY 4: Por que isso importa?
→ .html com JS = XSS stored. .php em server mal configurado = RCE

WHY 5: Por que o servidor aceitaria executar?
→ Depende da configuracao do web server. Se serve static files do upload dir: exploitavel
```

---

### Passo 5: Cross-Boundary Tracing

Seguir dados atraves de fronteiras:

```
BOUNDARY A (API Route):
  const email = req.body.email;           // Input do usuario
  const sanitized = email.trim().toLowerCase();  // "Sanitizacao"

BOUNDARY B (Service):
  async function createUser(email) {
    // Assume que email ja foi validado — MAS FOI?
    await db.insert('users', { email });  // Insere no banco
  }

BOUNDARY C (Query):
  // Se db.insert usa template literal em vez de parametrizado:
  // email = "'; DROP TABLE users; --" → SQL injection

ANALISE:
- Boundary A sanitiza (trim + lowercase) mas NAO valida formato
- Boundary B assume validacao que nao aconteceu
- Boundary C pode ser vulneravel dependendo da implementacao de db.insert
- A "sanitizacao" em A da falsa sensacao de seguranca
```

---

## Checklist Rapido por Funcao

```
□ Li CADA LINHA e sei o que ela FAZ (nao o que parece)?
□ Listei TODAS as suposicoes implicitas?
□ Para cada suposicao: quem garante? Atacante pode violar?
□ Verifiquei os error paths (nao so o happy path)?
□ Tracei dados cross-boundary (validacao still holds?)?
□ Verifiquei integer arithmetic (overflow, truncamento, signed/unsigned)?
□ Verifiquei string operations (encoding, null termination, length)?
□ Verifiquei concorrencia (TOCTOU, atomicidade)?
□ Verifiquei return values (sentinelas, error codes ignorados)?
```

---

## Armadilha: "Funcao Simples"

Funcoes que PARECEM simples mas escondem bugs:

```javascript
// "Simples" — apenas verifica se usuario existe
async function userExists(id) {
  const user = await db.query(`SELECT 1 FROM users WHERE id = '${id}'`);
  return user.length > 0;
}
// BUG: SQL injection via id. "Simples" nao significa "seguro".
```

**Regra:** Nao existe funcao simples demais para analisar se ela toca dados nao confiaveis.

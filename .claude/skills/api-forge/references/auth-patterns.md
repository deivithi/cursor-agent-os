# API Forge — Authentication Patterns Reference

> Referência completa de padrões de autenticação para APIs.
> Cada padrão inclui implementação funcional em bash/curl, armazenamento seguro, rotação e armadilhas comuns.

---

## Tabela Comparativa

| # | Padrão | Complexidade | Segurança | Caso de Uso Principal | Rotação | Stateless |
|---|--------|-------------|-----------|----------------------|---------|-----------|
| 1 | API Key (Header) | Baixa | Média | APIs públicas, SaaS | Manual | Sim |
| 2 | API Key (Query Param) | Baixa | Baixa | APIs legadas, webhooks simples | Manual | Sim |
| 3 | Bearer Token | Baixa | Alta | APIs REST modernas | Automática | Sim |
| 4 | Basic Auth | Baixa | Baixa | APIs internas, dev/staging | Manual | Sim |
| 5 | OAuth 2.0 Client Credentials | Média | Alta | Service-to-service (M2M) | Automática | Sim |
| 6 | OAuth 2.0 Auth Code + PKCE | Alta | Muito Alta | Apps com login de usuário | Automática | Sim |
| 7 | OAuth 2.0 Refresh Token | Média | Alta | Sessões longas de usuário | Automática | Sim |
| 8 | mTLS (Mutual TLS) | Alta | Muito Alta | Bancos, fintech, infra crítica | Certificado | Sim |
| 9 | HMAC Signature | Alta | Muito Alta | AWS, webhooks Stripe, APIs financeiras | Por request | Sim |
| 10 | JWT Self-Signed | Média | Alta | Service-to-service, Google APIs | Automática | Sim |
| 11 | Custom Header | Baixa | Variável | APIs não-padrão, sistemas internos | Variável | Sim |

---

## 1. API Key (Header)

### Descrição
Chave estática enviada em um header HTTP personalizado. Padrão mais simples de autenticação, amplamente usado por SaaS (Stripe, SendGrid, OpenAI).

### Quando usar
- APIs de terceiros que fornecem uma chave
- Integrações simples sem necessidade de fluxo OAuth
- Scripts de automação e CLIs

### Implementação

```bash
#!/usr/bin/env bash
# api-key-header.sh — Autenticação via API Key no header

set -euo pipefail

# --- Armazenamento seguro ---
# Opção 1: Variável de ambiente (mínimo aceitável)
# export API_KEY="sk-live-abc123..."

# Opção 2: Arquivo criptografado com GPG
store_key() {
  echo -n "sk-live-abc123def456" | gpg --symmetric --cipher-algo AES256 \
    --output ~/.secrets/api-key.gpg
  chmod 600 ~/.secrets/api-key.gpg
}

load_key() {
  gpg --quiet --decrypt ~/.secrets/api-key.gpg 2>/dev/null
}

# --- Chamada à API ---
API_KEY="${API_KEY:-$(load_key)}"
BASE_URL="https://api.example.com/v1"

response=$(curl -sS -w "\n%{http_code}" \
  -H "X-API-Key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  "${BASE_URL}/resources")

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
  echo "$body" | jq .
else
  echo "ERRO: HTTP ${http_code}" >&2
  echo "$body" >&2
  exit 1
fi
```

### Rotação
- Gere uma nova chave no painel do provedor
- Atualize o vault/variável de ambiente
- Revogue a chave antiga após confirmar que a nova funciona

### Armadilhas
- **Nunca** commitar chaves no git — use `.gitignore` e `.env`
- Headers são criptografados em HTTPS, mas logs de proxy podem capturá-los
- Sem expiração automática — chaves vazadas permanecem válidas até revogação manual

### Segurança
- Restrinja permissões da chave ao mínimo necessário (read-only quando possível)
- Use chaves diferentes por ambiente (dev/staging/prod)
- Monitore uso anômalo via dashboard do provedor

---

## 2. API Key (Query Parameter)

### Descrição
Chave enviada como parâmetro na URL. Padrão legado — menos seguro porque a URL aparece em logs de servidor, histórico do navegador e cabeçalhos `Referer`.

### Quando usar
- APIs legadas que só aceitam query parameter
- Webhooks onde não se controla os headers
- URLs pré-assinadas (ex: Google Maps Static API)

### Implementação

```bash
#!/usr/bin/env bash
# api-key-query.sh — Autenticação via query parameter

set -euo pipefail

API_KEY="${API_KEY:-$(gpg --quiet --decrypt ~/.secrets/api-key.gpg 2>/dev/null)}"
BASE_URL="https://api.example.com/v1/search"

# URL-encode da chave (necessário se contiver caracteres especiais)
encoded_key=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${API_KEY}'))")

response=$(curl -sS -w "\n%{http_code}" \
  -H "Content-Type: application/json" \
  "${BASE_URL}?api_key=${encoded_key}&q=salesforce+leads")

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" -eq 200 ]]; then
  echo "$body" | jq .
else
  echo "ERRO: HTTP ${http_code} — ${body}" >&2
  exit 1
fi
```

### Encoding seguro sem Python

```bash
# Alternativa com bash puro para URL encoding
urlencode() {
  local string="$1"
  local strlen=${#string}
  local encoded=""
  local pos c o
  for ((pos = 0; pos < strlen; pos++)); do
    c=${string:$pos:1}
    case "$c" in
      [-_.~a-zA-Z0-9]) o="$c" ;;
      *) printf -v o '%%%02X' "'$c" ;;
    esac
    encoded+="$o"
  done
  echo "$encoded"
}

encoded_key=$(urlencode "$API_KEY")
```

### Armadilhas
- URLs ficam em access logs do servidor — chave exposta em plain text
- Proxies e CDNs podem cachear a URL completa com a chave
- Header `Referer` pode vazar a chave para terceiros

### Segurança
- Prefira header-based auth sempre que o provedor suportar
- Se obrigado a usar query param, restrinja IP de origem no painel do provedor
- Monitore logs para detectar uso da chave por IPs desconhecidos

---

## 3. Bearer Token

### Descrição
Token enviado no header `Authorization: Bearer <token>`. Padrão definido pela RFC 6750. Usado por praticamente todas as APIs REST modernas.

### Quando usar
- APIs que emitem tokens após autenticação (OAuth, JWT)
- Qualquer API que documente `Authorization: Bearer`
- Salesforce REST API, GitHub API, etc.

### Implementação

```bash
#!/usr/bin/env bash
# bearer-token.sh — Autenticação via Bearer Token

set -euo pipefail

TOKEN="${BEARER_TOKEN:-$(gpg --quiet --decrypt ~/.secrets/bearer-token.gpg 2>/dev/null)}"

call_api() {
  local endpoint="$1"
  local method="${2:-GET}"
  local data="${3:-}"

  local curl_args=(
    -sS
    -w "\n%{http_code}"
    -X "$method"
    -H "Authorization: Bearer ${TOKEN}"
    -H "Content-Type: application/json"
    -H "Accept: application/json"
  )

  [[ -n "$data" ]] && curl_args+=(-d "$data")

  curl "${curl_args[@]}" "https://api.example.com/v1${endpoint}"
}

# Uso
response=$(call_api "/users/me")
http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

case "$http_code" in
  200|201) echo "$body" | jq . ;;
  401) echo "Token expirado ou inválido. Renove o token." >&2; exit 1 ;;
  403) echo "Token válido mas sem permissão para este recurso." >&2; exit 1 ;;
  429) echo "Rate limit atingido. Aguarde e tente novamente." >&2; exit 1 ;;
  *)   echo "ERRO: HTTP ${http_code}" >&2; exit 1 ;;
esac
```

### Armadilhas
- Tokens JWT expiram — implemente refresh automático
- Não confunda `Bearer` (com B maiúsculo) — alguns servidores são case-sensitive
- Tokens longos podem exceder limites de tamanho de header em proxies antigos

---

## 4. Basic Auth

### Descrição
Credenciais `usuario:senha` codificadas em base64 no header `Authorization: Basic <base64>`. Definido pela RFC 7617. Simples mas **só é seguro sobre HTTPS**.

### Quando usar
- APIs internas em ambientes controlados
- Autenticação inicial para obter um token (ex: Jira, Confluence)
- Ambientes de desenvolvimento e testes

### Implementação

```bash
#!/usr/bin/env bash
# basic-auth.sh — Autenticação via Basic Auth

set -euo pipefail

USERNAME="admin"
PASSWORD="$(gpg --quiet --decrypt ~/.secrets/api-password.gpg 2>/dev/null)"

# Método 1: curl nativo (curl faz o base64 internamente)
curl -sS -u "${USERNAME}:${PASSWORD}" \
  -H "Content-Type: application/json" \
  "https://api.example.com/v1/resources" | jq .

# Método 2: Header manual (útil quando curl -u não funciona)
credentials=$(echo -n "${USERNAME}:${PASSWORD}" | base64)

curl -sS \
  -H "Authorization: Basic ${credentials}" \
  -H "Content-Type: application/json" \
  "https://api.example.com/v1/resources" | jq .

# IMPORTANTE: Em macOS, use base64 sem -w0
# Em Linux: echo -n "user:pass" | base64 -w0
# Em macOS: echo -n "user:pass" | base64
```

### Armadilhas
- base64 **não é criptografia** — qualquer um decodifica. HTTPS é obrigatório
- Senhas com caracteres especiais (`:`, `@`) podem quebrar o parsing — use o header manual
- Alguns proxies removem o header Authorization em redirects

### Segurança
- Nunca use Basic Auth sem HTTPS
- Prefira tokens temporários em vez de credenciais permanentes
- Implemente rate limiting e lockout após tentativas falhas

---

## 5. OAuth 2.0 Client Credentials

### Descrição
Fluxo machine-to-machine (M2M) sem interação de usuário. O client troca `client_id` + `client_secret` por um access token. Definido pela RFC 6749 Section 4.4.

### Quando usar
- Comunicação entre serviços (backend-to-backend)
- Integrações Salesforce Connected App (Server-to-Server)
- APIs que exigem OAuth mas sem contexto de usuário

### Implementação completa

```bash
#!/usr/bin/env bash
# oauth-client-credentials.sh — Fluxo completo com cache e retry

set -euo pipefail

# --- Configuração ---
CLIENT_ID="3MVG9..."
CLIENT_SECRET="$(gpg --quiet --decrypt ~/.secrets/oauth-secret.gpg 2>/dev/null)"
TOKEN_URL="https://login.salesforce.com/services/oauth2/token"
API_BASE="https://myinstance.salesforce.com/services/data/v59.0"
TOKEN_CACHE="/tmp/.oauth_token_cache_$$"

# --- Obter token ---
get_token() {
  local response
  response=$(curl -sS -w "\n%{http_code}" \
    -X POST "$TOKEN_URL" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=client_credentials" \
    -d "client_id=${CLIENT_ID}" \
    -d "client_secret=${CLIENT_SECRET}")

  local http_code body
  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')

  if [[ "$http_code" -ne 200 ]]; then
    echo "Falha ao obter token: HTTP ${http_code}" >&2
    echo "$body" >&2
    return 1
  fi

  local access_token expires_in
  access_token=$(echo "$body" | jq -r '.access_token')
  expires_in=$(echo "$body" | jq -r '.expires_in // 3600')

  # Cache: token + timestamp de expiração
  local expires_at=$(( $(date +%s) + expires_in - 60 ))  # 60s de margem
  echo "${access_token}" > "${TOKEN_CACHE}"
  echo "${expires_at}" >> "${TOKEN_CACHE}"
  chmod 600 "${TOKEN_CACHE}"

  echo "$access_token"
}

# --- Token com cache ---
get_cached_token() {
  if [[ -f "$TOKEN_CACHE" ]]; then
    local cached_token cached_expiry
    cached_token=$(sed -n '1p' "$TOKEN_CACHE")
    cached_expiry=$(sed -n '2p' "$TOKEN_CACHE")
    local now=$(date +%s)

    if [[ "$now" -lt "$cached_expiry" ]]; then
      echo "$cached_token"
      return 0
    fi
  fi
  get_token
}

# --- Chamada à API com retry automático ---
call_api() {
  local endpoint="$1"
  local method="${2:-GET}"
  local data="${3:-}"
  local max_retries=2
  local attempt=0

  while [[ $attempt -le $max_retries ]]; do
    local token
    token=$(get_cached_token)

    local curl_args=(
      -sS -w "\n%{http_code}"
      -X "$method"
      -H "Authorization: Bearer ${token}"
      -H "Content-Type: application/json"
    )
    [[ -n "$data" ]] && curl_args+=(-d "$data")

    local response http_code body
    response=$(curl "${curl_args[@]}" "${API_BASE}${endpoint}")
    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')

    if [[ "$http_code" -eq 401 && $attempt -lt $max_retries ]]; then
      echo "Token expirado, renovando... (tentativa $((attempt + 1)))" >&2
      rm -f "$TOKEN_CACHE"
      ((attempt++))
      continue
    fi

    echo "$body"
    return 0
  done
}

# --- Uso ---
echo "=== Consultando Leads ==="
call_api "/query?q=SELECT+Id,Name+FROM+Lead+LIMIT+5" | jq .

# --- Cleanup ---
trap "rm -f ${TOKEN_CACHE}" EXIT
```

### Rotação
- Rotacione `client_secret` periodicamente no provedor
- Atualize o vault criptografado
- O access token é rotacionado automaticamente a cada expiração

### Armadilhas
- `client_secret` é equivalente a uma senha — proteja com o mesmo rigor
- Tokens expirados retornam 401 — implemente retry (exemplo acima)
- Alguns provedores exigem `scope` — verifique a documentação

---

## 6. OAuth 2.0 Authorization Code + PKCE

### Descrição
Fluxo mais seguro para aplicações com interação de usuário. Usa um `code_verifier` aleatório e seu hash (`code_challenge`) para prevenir interceptação do authorization code. Definido pela RFC 7636.

### Quando usar
- Apps web ou mobile com login de usuário
- SPAs (Single Page Applications) — PKCE substitui o client_secret
- Qualquer cenário onde o client não pode guardar um secret com segurança

### Implementação

```bash
#!/usr/bin/env bash
# oauth-pkce.sh — Authorization Code + PKCE

set -euo pipefail

CLIENT_ID="my-app-client-id"
REDIRECT_URI="http://localhost:8080/callback"
AUTH_URL="https://auth.example.com/authorize"
TOKEN_URL="https://auth.example.com/oauth/token"
SCOPE="openid profile email"

# --- Passo 1: Gerar code_verifier e code_challenge ---
generate_pkce() {
  # code_verifier: 43-128 caracteres, URL-safe
  CODE_VERIFIER=$(openssl rand -base64 96 | tr -d '=/+' | head -c 128)

  # code_challenge: SHA256 do verifier, base64url encoded
  CODE_CHALLENGE=$(echo -n "$CODE_VERIFIER" \
    | openssl dgst -sha256 -binary \
    | base64 \
    | tr '+/' '-_' \
    | tr -d '=')

  echo "code_verifier: ${CODE_VERIFIER}"
  echo "code_challenge: ${CODE_CHALLENGE}"
}

generate_pkce

# --- Passo 2: Gerar state anti-CSRF ---
STATE=$(openssl rand -hex 16)

# --- Passo 3: Construir URL de autorização ---
AUTH_REDIRECT="${AUTH_URL}?response_type=code"
AUTH_REDIRECT+="&client_id=${CLIENT_ID}"
AUTH_REDIRECT+="&redirect_uri=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${REDIRECT_URI}'))")"
AUTH_REDIRECT+="&scope=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${SCOPE}'))")"
AUTH_REDIRECT+="&state=${STATE}"
AUTH_REDIRECT+="&code_challenge=${CODE_CHALLENGE}"
AUTH_REDIRECT+="&code_challenge_method=S256"

echo ""
echo "Abra no navegador:"
echo "$AUTH_REDIRECT"
echo ""

# --- Passo 4: Servidor local para capturar o callback ---
echo "Aguardando callback em ${REDIRECT_URI}..."
# Servidor mínimo com netcat (ou use python3 -m http.server)
CALLBACK_DATA=$(nc -l -p 8080 -q 1 <<< "HTTP/1.1 200 OK

Login concluído. Feche esta aba." 2>/dev/null | head -1)

# Extrair o authorization code da URL
AUTH_CODE=$(echo "$CALLBACK_DATA" | grep -oP 'code=\K[^&\s]+')
RETURNED_STATE=$(echo "$CALLBACK_DATA" | grep -oP 'state=\K[^&\s]+')

# --- Passo 5: Verificar state ---
if [[ "$RETURNED_STATE" != "$STATE" ]]; then
  echo "ERRO: State mismatch — possível ataque CSRF!" >&2
  exit 1
fi

# --- Passo 6: Trocar code por token ---
response=$(curl -sS -X POST "$TOKEN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code" \
  -d "client_id=${CLIENT_ID}" \
  -d "code=${AUTH_CODE}" \
  -d "redirect_uri=${REDIRECT_URI}" \
  -d "code_verifier=${CODE_VERIFIER}")

echo "$response" | jq .

ACCESS_TOKEN=$(echo "$response" | jq -r '.access_token')
REFRESH_TOKEN=$(echo "$response" | jq -r '.refresh_token')

echo "Access Token obtido com sucesso."

# Salvar refresh token de forma segura
echo -n "$REFRESH_TOKEN" | gpg --symmetric --cipher-algo AES256 \
  --output ~/.secrets/refresh-token.gpg 2>/dev/null
```

### Armadilhas
- O `code_verifier` deve ter entre 43 e 128 caracteres
- Use `S256` como `code_challenge_method` — nunca `plain` em produção
- Sempre valide o `state` retornado contra o enviado
- O authorization code é single-use — não tente reutilizá-lo

---

## 7. OAuth 2.0 Refresh Token

### Descrição
Renova um access token expirado sem exigir nova autenticação do usuário. O refresh token tem vida longa e deve ser armazenado com segurança máxima.

### Quando usar
- Sessões de longa duração em automações
- Quando o access token expira e não se quer re-autenticar
- Salesforce refresh flow, Google APIs, etc.

### Implementação

```bash
#!/usr/bin/env bash
# oauth-refresh.sh — Renovação automática de token

set -euo pipefail

CLIENT_ID="my-app-client-id"
CLIENT_SECRET="$(gpg --quiet --decrypt ~/.secrets/oauth-secret.gpg 2>/dev/null)"
TOKEN_URL="https://auth.example.com/oauth/token"
TOKEN_FILE="/tmp/.oauth_tokens_$$"

# --- Carregar tokens salvos ---
load_tokens() {
  if [[ -f "$TOKEN_FILE" ]]; then
    ACCESS_TOKEN=$(jq -r '.access_token' "$TOKEN_FILE")
    REFRESH_TOKEN=$(jq -r '.refresh_token' "$TOKEN_FILE")
    EXPIRES_AT=$(jq -r '.expires_at' "$TOKEN_FILE")
  else
    ACCESS_TOKEN=""
    REFRESH_TOKEN="$(gpg --quiet --decrypt ~/.secrets/refresh-token.gpg 2>/dev/null)"
    EXPIRES_AT=0
  fi
}

# --- Salvar tokens ---
save_tokens() {
  local access_token="$1"
  local refresh_token="$2"
  local expires_in="${3:-3600}"
  local expires_at=$(( $(date +%s) + expires_in - 60 ))

  jq -n \
    --arg at "$access_token" \
    --arg rt "$refresh_token" \
    --arg ea "$expires_at" \
    '{access_token: $at, refresh_token: $rt, expires_at: ($ea | tonumber)}' \
    > "$TOKEN_FILE"
  chmod 600 "$TOKEN_FILE"
}

# --- Refresh ---
refresh_access_token() {
  echo "Renovando access token..." >&2

  local response
  response=$(curl -sS -X POST "$TOKEN_URL" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=refresh_token" \
    -d "client_id=${CLIENT_ID}" \
    -d "client_secret=${CLIENT_SECRET}" \
    -d "refresh_token=${REFRESH_TOKEN}")

  local new_access new_refresh expires_in
  new_access=$(echo "$response" | jq -r '.access_token')
  new_refresh=$(echo "$response" | jq -r '.refresh_token // empty')
  expires_in=$(echo "$response" | jq -r '.expires_in // 3600')

  if [[ "$new_access" == "null" || -z "$new_access" ]]; then
    echo "ERRO: Falha no refresh. Re-autenticação necessária." >&2
    echo "$response" | jq . >&2
    return 1
  fi

  # Alguns provedores rotacionam o refresh token
  [[ -z "$new_refresh" ]] && new_refresh="$REFRESH_TOKEN"

  save_tokens "$new_access" "$new_refresh" "$expires_in"
  ACCESS_TOKEN="$new_access"
  REFRESH_TOKEN="$new_refresh"

  echo "Token renovado. Expira em ${expires_in}s." >&2
}

# --- Garantir token válido ---
ensure_valid_token() {
  load_tokens
  local now=$(date +%s)

  if [[ -z "$ACCESS_TOKEN" || "$now" -ge "$EXPIRES_AT" ]]; then
    refresh_access_token
  fi
}

# --- Chamada à API ---
api_call() {
  ensure_valid_token

  curl -sS \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    "$@"
}

# --- Uso ---
api_call "https://api.example.com/v1/me" | jq .

trap "rm -f ${TOKEN_FILE}" EXIT
```

### Armadilhas
- Alguns provedores (Google, Salesforce) rotacionam o refresh token — salve o novo
- Refresh tokens revogados exigem re-autenticação completa
- Nunca exponha o refresh token em logs ou URLs

---

## 8. mTLS (Mutual TLS)

### Descrição
Autenticação mútua onde tanto o servidor quanto o cliente apresentam certificados. O servidor valida o certificado do cliente antes de aceitar a conexão. Usado em ambientes de alta segurança.

### Quando usar
- APIs bancárias e financeiras (Open Banking, PIX)
- Comunicação entre microserviços em mesh segura
- Ambientes regulados (PCI DSS, SOX)

### Implementação

```bash
#!/usr/bin/env bash
# mtls.sh — Mutual TLS com certificados cliente

set -euo pipefail

CERT_DIR="$HOME/.certs/api-forge"
mkdir -p "$CERT_DIR"
chmod 700 "$CERT_DIR"

# --- Passo 1: Gerar chave privada e CSR ---
generate_client_cert() {
  echo "Gerando chave privada RSA 4096..."
  openssl genrsa -aes256 -out "${CERT_DIR}/client.key" 4096

  echo "Gerando CSR..."
  openssl req -new \
    -key "${CERT_DIR}/client.key" \
    -out "${CERT_DIR}/client.csr" \
    -subj "/C=BR/ST=SP/L=SaoPaulo/O=Febracis/CN=api-client"

  echo "CSR gerado em ${CERT_DIR}/client.csr"
  echo "Envie o CSR ao provedor da API para assinatura."

  chmod 600 "${CERT_DIR}/client.key"
  chmod 644 "${CERT_DIR}/client.csr"
}

# --- Passo 2: Após receber o certificado assinado ---
# O provedor retorna: client.crt (certificado assinado) e ca.crt (CA chain)

# --- Passo 3: Chamada com mTLS ---
mtls_call() {
  local url="$1"
  shift

  curl -sS \
    --cert "${CERT_DIR}/client.crt" \
    --key "${CERT_DIR}/client.key" \
    --cacert "${CERT_DIR}/ca.crt" \
    -H "Content-Type: application/json" \
    "$@" \
    "$url"
}

# --- Uso ---
mtls_call "https://secure-api.example.com/v1/accounts" | jq .

# --- Verificar validade do certificado ---
check_cert_expiry() {
  local expiry
  expiry=$(openssl x509 -enddate -noout -in "${CERT_DIR}/client.crt" \
    | cut -d= -f2)
  local expiry_epoch
  expiry_epoch=$(date -d "$expiry" +%s 2>/dev/null || date -jf "%b %d %T %Y %Z" "$expiry" +%s)
  local now=$(date +%s)
  local days_left=$(( (expiry_epoch - now) / 86400 ))

  if [[ $days_left -lt 30 ]]; then
    echo "ALERTA: Certificado expira em ${days_left} dias!" >&2
  else
    echo "Certificado válido por mais ${days_left} dias."
  fi
}

check_cert_expiry
```

### Rotação
- Gere novo CSR antes da expiração do certificado atual (30+ dias de antecedência)
- Mantenha o certificado antigo ativo até o novo ser distribuído
- Automatize a verificação de expiração com cron

### Segurança
- Chave privada nunca sai do servidor que a gerou
- Use passphrase na chave privada (openssl genrsa -aes256)
- Revogue certificados comprometidos imediatamente na CA

---

## 9. HMAC Signature

### Descrição
O cliente assina cada request com uma chave secreta usando HMAC (Hash-based Message Authentication Code). O servidor recalcula a assinatura e compara. Garante integridade e autenticidade. Usado por AWS (Signature V4), Stripe (webhooks), GitHub (webhooks).

### Quando usar
- Verificação de webhooks (Stripe, GitHub, Shopify)
- AWS API requests (Signature V4)
- APIs que exigem integridade comprovada por request

### Implementação

```bash
#!/usr/bin/env bash
# hmac-signature.sh — Assinatura HMAC para requests e verificação de webhooks

set -euo pipefail

SECRET_KEY="$(gpg --quiet --decrypt ~/.secrets/hmac-secret.gpg 2>/dev/null)"

# ==========================================
# PARTE 1: Assinar um request (estilo AWS)
# ==========================================

sign_request() {
  local method="$1"
  local path="$2"
  local body="${3:-}"
  local timestamp
  timestamp=$(date -u +"%Y%m%dT%H%M%SZ")
  local datestamp
  datestamp=$(date -u +"%Y%m%d")

  # Payload hash
  local payload_hash
  if [[ -n "$body" ]]; then
    payload_hash=$(echo -n "$body" | openssl dgst -sha256 -hex | awk '{print $NF}')
  else
    payload_hash=$(echo -n "" | openssl dgst -sha256 -hex | awk '{print $NF}')
  fi

  # String to sign
  local string_to_sign="${method}\n${path}\n${timestamp}\n${payload_hash}"

  # HMAC signature
  local signature
  signature=$(echo -ne "$string_to_sign" \
    | openssl dgst -sha256 -hmac "$SECRET_KEY" -hex \
    | awk '{print $NF}')

  # Executar request
  local curl_args=(
    -sS
    -X "$method"
    -H "X-Timestamp: ${timestamp}"
    -H "X-Signature: sha256=${signature}"
    -H "X-Payload-Hash: ${payload_hash}"
    -H "Content-Type: application/json"
  )
  [[ -n "$body" ]] && curl_args+=(-d "$body")

  curl "${curl_args[@]}" "https://api.example.com${path}"
}

# Uso
sign_request "POST" "/v1/orders" '{"item":"CIS-Evento","qty":1}' | jq .

# ==========================================
# PARTE 2: Verificar webhook (estilo Stripe)
# ==========================================

verify_stripe_webhook() {
  local payload="$1"
  local received_signature="$2"
  local webhook_secret="$3"
  local timestamp="$4"

  # Stripe: signature = HMAC-SHA256(timestamp.payload)
  local signed_payload="${timestamp}.${payload}"
  local expected_signature
  expected_signature=$(echo -n "$signed_payload" \
    | openssl dgst -sha256 -hmac "$webhook_secret" -hex \
    | awk '{print $NF}')

  if [[ "$received_signature" == "$expected_signature" ]]; then
    echo "Webhook verificado com sucesso."
    return 0
  else
    echo "ERRO: Assinatura inválida! Possível falsificação." >&2
    return 1
  fi
}

# Exemplo de verificação
# verify_stripe_webhook "$BODY" "$SIG" "$WEBHOOK_SECRET" "$TIMESTAMP"
```

### Armadilhas
- **Timing attacks**: Use comparação constant-time em produção (não em bash — use linguagem compilada)
- O timestamp deve ter tolerância (ex: ±5 minutos) para evitar replay attacks
- A ordem dos campos na string-to-sign deve ser idêntica entre cliente e servidor

---

## 10. JWT Self-Signed

### Descrição
O cliente gera um JWT assinado com sua chave privada e o envia ao servidor de autorização para obter um access token. Usado por Google Service Accounts, Salesforce JWT Bearer Flow, etc.

### Quando usar
- Google Cloud Service Accounts
- Salesforce JWT Bearer Token Flow (Connected App)
- Service-to-service sem interação humana

### Implementação

```bash
#!/usr/bin/env bash
# jwt-self-signed.sh — Gerar JWT assinado com chave privada

set -euo pipefail

PRIVATE_KEY_FILE="$HOME/.certs/service-account.key"
CLIENT_EMAIL="my-service@project.iam.gserviceaccount.com"
TOKEN_URL="https://oauth2.googleapis.com/token"
SCOPE="https://www.googleapis.com/auth/spreadsheets.readonly"

# --- Funções auxiliares ---
base64url_encode() {
  base64 | tr '+/' '-_' | tr -d '='
}

# --- Construir JWT ---
build_jwt() {
  local now
  now=$(date +%s)
  local exp=$(( now + 3600 ))

  # Header
  local header='{"alg":"RS256","typ":"JWT"}'
  local header_b64
  header_b64=$(echo -n "$header" | base64url_encode)

  # Claims (Payload)
  local claims
  claims=$(jq -n -c \
    --arg iss "$CLIENT_EMAIL" \
    --arg scope "$SCOPE" \
    --arg aud "$TOKEN_URL" \
    --argjson iat "$now" \
    --argjson exp "$exp" \
    '{iss: $iss, scope: $scope, aud: $aud, iat: $iat, exp: $exp}')

  local claims_b64
  claims_b64=$(echo -n "$claims" | base64url_encode)

  # Signing input
  local signing_input="${header_b64}.${claims_b64}"

  # Signature (RS256 = RSA + SHA-256)
  local signature
  signature=$(echo -n "$signing_input" \
    | openssl dgst -sha256 -sign "$PRIVATE_KEY_FILE" \
    | base64url_encode)

  echo "${signing_input}.${signature}"
}

# --- Trocar JWT por access token ---
get_access_token() {
  local jwt
  jwt=$(build_jwt)

  local response
  response=$(curl -sS -X POST "$TOKEN_URL" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer" \
    -d "assertion=${jwt}")

  local access_token
  access_token=$(echo "$response" | jq -r '.access_token')

  if [[ "$access_token" == "null" || -z "$access_token" ]]; then
    echo "ERRO ao obter token:" >&2
    echo "$response" | jq . >&2
    return 1
  fi

  echo "$access_token"
}

# --- Uso ---
TOKEN=$(get_access_token)
echo "Token obtido: ${TOKEN:0:20}..."

curl -sS \
  -H "Authorization: Bearer ${TOKEN}" \
  "https://sheets.googleapis.com/v4/spreadsheets/SHEET_ID/values/A1:D10" | jq .
```

### Rotação
- Rotacione a chave privada periodicamente (gere novo par de chaves)
- Registre a nova chave pública no provedor (Google Console, Salesforce Connected App)
- JWTs são curta duração por design (1h) — rotação automática

### Armadilhas
- O relógio do servidor deve estar sincronizado (NTP) — diferença de segundos causa falha
- O `aud` (audience) deve corresponder exatamente ao esperado pelo servidor
- Em Salesforce, o `sub` deve ser um usuário autorizado no Connected App

---

## 11. Custom Header

### Descrição
Autenticação via headers não-padrão definidos pelo provedor. Exemplos: `X-API-Token`, `X-Auth-Key + X-Auth-Email` (Cloudflare), `X-Custom-Auth`.

### Quando usar
- APIs com esquemas de autenticação proprietários
- Cloudflare API (X-Auth-Key + X-Auth-Email)
- Sistemas internos com headers customizados

### Implementação

```bash
#!/usr/bin/env bash
# custom-header.sh — Template para autenticação com headers customizados

set -euo pipefail

# --- Configuração (adaptar por provedor) ---
AUTH_HEADERS=()

# Exemplo 1: Cloudflare
setup_cloudflare() {
  local email="admin@example.com"
  local api_key
  api_key=$(gpg --quiet --decrypt ~/.secrets/cloudflare-key.gpg 2>/dev/null)
  AUTH_HEADERS=(
    -H "X-Auth-Email: ${email}"
    -H "X-Auth-Key: ${api_key}"
  )
}

# Exemplo 2: Header único customizado
setup_custom_single() {
  local token
  token=$(gpg --quiet --decrypt ~/.secrets/custom-token.gpg 2>/dev/null)
  AUTH_HEADERS=(
    -H "X-API-Token: ${token}"
  )
}

# Exemplo 3: Multi-header com timestamp
setup_custom_multi() {
  local api_key
  api_key=$(gpg --quiet --decrypt ~/.secrets/custom-key.gpg 2>/dev/null)
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  AUTH_HEADERS=(
    -H "X-API-Key: ${api_key}"
    -H "X-Request-Timestamp: ${timestamp}"
    -H "X-Client-ID: my-app-v1"
  )
}

# --- Chamada genérica ---
custom_api_call() {
  local url="$1"
  shift

  curl -sS \
    "${AUTH_HEADERS[@]}" \
    -H "Content-Type: application/json" \
    "$@" \
    "$url"
}

# --- Uso ---
setup_cloudflare
custom_api_call "https://api.cloudflare.com/client/v4/zones" | jq '.result[].name'
```

### Armadilhas
- Headers customizados não seguem padrões — leia a documentação do provedor com atenção
- Proxies e WAFs podem bloquear ou remover headers desconhecidos
- Não invente esquemas customizados — use OAuth/Bearer quando possível

---

## Armazenamento Seguro de Credenciais (Vault)

### Padrão recomendado para todos os patterns

```bash
#!/usr/bin/env bash
# vault.sh — Gerenciamento centralizado de secrets

set -euo pipefail

VAULT_DIR="$HOME/.secrets"
mkdir -p "$VAULT_DIR"
chmod 700 "$VAULT_DIR"

# --- Salvar secret ---
vault_store() {
  local name="$1"
  local value="$2"
  echo -n "$value" | gpg --symmetric --cipher-algo AES256 \
    --batch --yes \
    --output "${VAULT_DIR}/${name}.gpg"
  chmod 600 "${VAULT_DIR}/${name}.gpg"
  echo "Secret '${name}' armazenado."
}

# --- Ler secret ---
vault_read() {
  local name="$1"
  gpg --quiet --batch --decrypt "${VAULT_DIR}/${name}.gpg" 2>/dev/null
}

# --- Listar secrets ---
vault_list() {
  ls -1 "${VAULT_DIR}"/*.gpg 2>/dev/null | xargs -I{} basename {} .gpg
}

# --- Remover secret ---
vault_delete() {
  local name="$1"
  rm -f "${VAULT_DIR}/${name}.gpg"
  echo "Secret '${name}' removido."
}

# --- Rotacionar secret ---
vault_rotate() {
  local name="$1"
  local new_value="$2"
  local backup="${VAULT_DIR}/${name}.gpg.bak.$(date +%s)"
  cp "${VAULT_DIR}/${name}.gpg" "$backup"
  vault_store "$name" "$new_value"
  echo "Secret '${name}' rotacionado. Backup: ${backup}"
}
```

---

## Fluxograma de Decisão

```
                    ┌─────────────────────────┐
                    │  Precisa autenticar uma  │
                    │       API externa?       │
                    └──────────┬──────────────┘
                               │
                    ┌──────────▼──────────────┐
                    │  Tem interação humana?   │
                    └──┬───────────────────┬──┘
                       │ SIM               │ NÃO
                       ▼                   ▼
              ┌────────────────┐  ┌────────────────────┐
              │ OAuth 2.0      │  │ Service-to-Service?│
              │ Auth Code+PKCE │  └──┬────────────┬───┘
              │ (Pattern #6)   │     │ SIM        │ NÃO
              └────────────────┘     ▼            ▼
                            ┌──────────┐  ┌──────────────┐
                            │ Tem chave │  │ API fornece  │
                            │ privada?  │  │ API Key?     │
                            └┬────────┬┘  └──┬────────┬──┘
                             │SIM     │NÃO   │SIM     │NÃO
                             ▼        ▼      ▼        ▼
                       ┌─────────┐ ┌──────┐ ┌──────┐ ┌──────────┐
                       │JWT Self │ │OAuth │ │API   │ │Basic Auth│
                       │Signed   │ │Client│ │Key   │ │ou Custom │
                       │(#10)    │ │Creds │ │Header│ │Header    │
                       └─────────┘ │(#5)  │ │(#1)  │ │(#4/#11)  │
                                   └──────┘ └──────┘ └──────────┘

              ┌─────────────────────────────────────────┐
              │        Requisitos adicionais?            │
              └──┬──────────┬──────────┬───────────┬───┘
                 │          │          │           │
                 ▼          ▼          ▼           ▼
           ┌─────────┐ ┌────────┐ ┌────────┐ ┌────────┐
           │Alta seg.│ │Integr. │ │Sessão  │ │Webhook │
           │regulada │ │por req.│ │longa   │ │inbound │
           └────┬────┘ └───┬────┘ └───┬────┘ └───┬────┘
                │          │          │           │
                ▼          ▼          ▼           ▼
           ┌─────────┐ ┌────────┐ ┌────────┐ ┌────────┐
           │  mTLS   │ │  HMAC  │ │Refresh │ │  HMAC  │
           │  (#8)   │ │  (#9)  │ │Token   │ │Verify  │
           └─────────┘ └────────┘ │(#7)    │ │(#9)    │
                                  └────────┘ └────────┘
```

---

## Checklist de Segurança Universal

```
□ Credenciais NUNCA estão hardcoded no código
□ Credenciais NUNCA aparecem em logs ou output de debug
□ Todas as chamadas usam HTTPS (nunca HTTP)
□ Tokens/chaves são armazenados criptografados (GPG ou vault)
□ Permissões de arquivo: 600 para secrets, 700 para diretórios
□ Credenciais diferentes por ambiente (dev/staging/prod)
□ Rotação periódica implementada e documentada
□ Monitoramento de uso anômalo ativo
□ .gitignore inclui todos os arquivos de secret
□ Retry com backoff para erros de autenticação
□ Rate limiting respeitado (429 tratado)
□ Refresh automático implementado onde aplicável
```

---

> **Versão:** 1.0.0
> **Última atualização:** 2026-03-15
> **Autor:** API Forge — Deivithi (Febracis)

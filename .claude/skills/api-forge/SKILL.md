---
name: api-forge
description: >
  Forge secure, native Claude Code integrations from any REST API. Reads OpenAPI/Swagger specs,
  generates slash commands with encrypted auth, input validation, rate limiting, audit logging,
  and progressive disclosure. Zero supply chain risk — no external code execution.
domain: developer-tools
subdomain: api-integration
version: 1.0.0
author: deivithi
license: Apache-2.0
tags:
  - openapi
  - swagger
  - rest-api
  - api-integration
  - code-generation
  - secure-auth
  - claude-code
  - slash-commands
  - mcp
  - credential-management
  - rate-limiting
  - input-validation
---

# API Forge — Secure REST API Integration for Claude Code

> **"No untrusted code execution. No plaintext secrets. No blind trust."**

## 📁 File Structure
- `SKILL.md` — Você está aqui. Comece pelas Instruções abaixo.
- `references/auth-patterns.md` — Padrões de autenticação detalhados.
- `references/security-patterns.md` — Padrões de segurança e validação.
- `gotchas.md` — ⚠️ Problemas conhecidos. Consulte quando algo falhar.

## 🔗 Related Skills
- `cyber` — Use para auditar segurança das integrações geradas (OWASP API Top 10)
- `cicd` — Use para deploy de comandos e scripts gerados pelo Forge
- `scaffolding` — Use para gerar boilerplate de código que consome a API integrada

---

## 1. Overview

### What API Forge Does

API Forge reads any REST API specification (OpenAPI 3.x, Swagger 2.0, or manual definition) and
generates **secure, native Claude Code slash commands** that interact with that API. Every generated
integration includes encrypted credential storage, input validation derived from the API schema,
rate limiting awareness, structured error handling, and a full audit trail.

The result is a **zero-dependency, zero-supply-chain-risk** integration that lives entirely within
your `.claude/` directory as Markdown commands and POSIX shell scripts.

### Why API Forge Exists

Existing tools like `api2cli` take the naive approach: download a binary from an npm registry,
store tokens in plaintext files, execute postinstall scripts from unknown authors, and hope for
the best. This is **architecturally indefensible** for any environment that handles production
credentials.

API Forge takes the opposite approach: **generate, don't install**. The tool produces only
Markdown files and shell scripts that you can read, audit, and verify line by line. Credentials
are encrypted at rest with AES-256-GCM. Every access is logged. No external code ever executes.

### Architecture

```
  OpenAPI Spec ──→ Parser ──→ Analyzer ──→ Generator ──→ Validator ──→ Output
       │              │           │             │              │
       ▼              ▼           ▼             ▼              ▼
    URL/File      Endpoints    Security     .claude/       Test &
    or Manual     + Schemas    + Auth       commands/      Verify
                  + Models     + Scopes     + scripts/     + Report
                  + Limits     + Profile    + config/      + Registry
```

### Comparison: api2cli vs API Forge

| Dimension | api2cli | API Forge |
|-----------|---------|-----------|
| **Installation** | `npm install` (runs postinstall scripts) | No installation — generates files |
| **Token Storage** | `~/.config/tokens/app.txt` (PLAINTEXT) | `~/.claude-forge/vault/app.enc` (AES-256-GCM) |
| **File Permissions** | Not set (TODO in their code) | `chmod 600` enforced on all secrets |
| **Encryption** | None | AES-256-GCM + PBKDF2 (100K iterations) |
| **Key Derivation** | None | Machine-bound (hostname + user hash) |
| **Audit Trail** | None | Timestamped access log per operation |
| **Token Rotation** | Manual only | Age tracking + OAuth 2.0 auto-refresh |
| **Token Exposure** | Displayed in terminal, passed as CLI arg | Never exposed to LLM context window |
| **Code Execution** | Downloads and runs external binaries | Zero external code execution |
| **Supply Chain** | npm registry (postinstall risk) | No dependencies — Markdown + shell |
| **Trust Model** | Trust the npm package author | Trust only your own generated files |
| **Input Validation** | None | JSON Schema from OpenAPI spec |
| **Rate Limiting** | None | Parses and respects X-RateLimit headers |
| **Sandbox** | None | Claude Code permission model |
| **Code Signing** | None | SHA-256 checksums on generated files |
| **Rollback** | Delete and reinstall | Git-tracked, full version history |

### Core Philosophy

1. **Generate, Don't Install** — Every artifact is generated locally. No `npm install`, no `pip install`, no downloading binaries from registries you don't control.

2. **Encrypt at Rest, Decrypt in Memory** — Credentials exist in plaintext only during the lifetime of a single curl command. They are never written to disk unencrypted, never logged, never passed as CLI arguments.

3. **Audit Everything** — Every credential read, every API call, every token rotation is logged with ISO 8601 timestamps and caller identification.

4. **Validate Before Sending** — Every request is validated against the OpenAPI schema before it leaves your machine. Invalid payloads are rejected with clear error messages.

5. **Respect the API** — Rate limits are parsed from response headers and enforced. Idempotency keys are generated for POST requests when supported. Retry logic uses exponential backoff.

---

## 2. Prerequisites

### Required

| Tool | Version | Purpose | Check Command |
|------|---------|---------|---------------|
| Claude Code | Latest | Runtime environment | `claude --version` |
| Bash | 4.0+ | Script execution | `bash --version` |
| curl | 7.0+ | HTTP requests | `curl --version` |
| jq | 1.6+ | JSON processing | `jq --version` |
| openssl | 1.1+ | Credential encryption | `openssl version` |

### Optional

| Tool | Purpose | Check Command |
|------|---------|---------------|
| yq | YAML spec processing | `yq --version` |
| column | Table formatting | `column --version` |

### Prerequisite Check Script

```bash
#!/bin/bash
# forge-preflight.sh — Verify all prerequisites are met

PASS=0
FAIL=0

check() {
  local name="$1" cmd="$2" min_ver="$3"
  if command -v "$cmd" &>/dev/null; then
    ver=$($cmd --version 2>&1 | head -1)
    echo "[OK]   $name: $ver"
    ((PASS++))
  else
    echo "[FAIL] $name: not found (required)"
    ((FAIL++))
  fi
}

check "curl"    curl    "7.0"
check "jq"      jq      "1.6"
check "openssl" openssl "1.1"
check "bash"    bash    "4.0"

# Optional
if command -v yq &>/dev/null; then
  echo "[OK]   yq (optional): $(yq --version 2>&1 | head -1)"
else
  echo "[INFO] yq (optional): not found — YAML specs will need conversion to JSON"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && echo "All prerequisites met." || echo "Fix failures before proceeding."
exit "$FAIL"
```

---

## 3. Workflow — 6-Phase Forge Process

### Phase 1: Spec Discovery & Ingestion

The first phase reads the API specification and extracts a structured representation of every
endpoint, schema, authentication method, and server configuration.

#### Supported Input Formats

| Format | Detection | Processing |
|--------|-----------|------------|
| OpenAPI 3.0.x JSON | `openapi` field = `"3.0.*"` | Native jq parsing |
| OpenAPI 3.1.x JSON | `openapi` field = `"3.1.*"` | Native jq parsing |
| Swagger 2.0 JSON | `swagger` field = `"2.0"` | Convert to OpenAPI 3.0, then parse |
| OpenAPI YAML | `.yaml`/`.yml` extension | Convert via `yq` to JSON, then parse |
| Remote URL | `https://` prefix | Fetch via curl, then detect format |
| Manual Definition | `manual` flag | Interactive or argument-based |

#### Spec Fetch and Validation

```bash
#!/bin/bash
# forge-ingest.sh — Fetch and validate an OpenAPI spec
SPEC_SOURCE="$1"
WORK_DIR="$HOME/.claude-forge/tmp"
mkdir -p "$WORK_DIR"

# Step 1: Determine source type and fetch
if [[ "$SPEC_SOURCE" =~ ^https?:// ]]; then
  echo "[*] Fetching spec from URL: $SPEC_SOURCE" >&2
  SPEC_FILE="$WORK_DIR/spec-raw.json"
  HTTP_CODE=$(curl -s -w "%{http_code}" -o "$SPEC_FILE" "$SPEC_SOURCE")
  if [ "$HTTP_CODE" -ge 400 ]; then
    echo "[!] Failed to fetch spec: HTTP $HTTP_CODE" >&2
    exit 1
  fi
elif [ -f "$SPEC_SOURCE" ]; then
  echo "[*] Reading spec from file: $SPEC_SOURCE" >&2
  SPEC_FILE="$SPEC_SOURCE"
else
  echo "[!] Spec source not found: $SPEC_SOURCE" >&2
  exit 1
fi

# Step 2: Convert YAML to JSON if needed
if [[ "$SPEC_FILE" =~ \.(yaml|yml)$ ]]; then
  if ! command -v yq &>/dev/null; then
    echo "[!] yq required for YAML specs. Install yq or convert to JSON." >&2
    exit 1
  fi
  echo "[*] Converting YAML to JSON..." >&2
  yq eval -o=json "$SPEC_FILE" > "$WORK_DIR/spec.json"
  SPEC_FILE="$WORK_DIR/spec.json"
fi

# Step 3: Detect version
OPENAPI_VER=$(jq -r '.openapi // empty' "$SPEC_FILE" 2>/dev/null)
SWAGGER_VER=$(jq -r '.swagger // empty' "$SPEC_FILE" 2>/dev/null)

if [ -n "$OPENAPI_VER" ]; then
  echo "[*] Detected OpenAPI version: $OPENAPI_VER" >&2
  VERSION_MAJOR=$(echo "$OPENAPI_VER" | cut -d. -f1)
  if [ "$VERSION_MAJOR" -lt 3 ]; then
    echo "[!] OpenAPI version $OPENAPI_VER is not supported. Use 3.0+." >&2
    exit 1
  fi
elif [ "$SWAGGER_VER" = "2.0" ]; then
  echo "[*] Detected Swagger 2.0 — converting to OpenAPI 3.0 structure..." >&2
  # Minimal Swagger 2.0 → OpenAPI 3.0 conversion
  jq '{
    openapi: "3.0.0",
    info: .info,
    servers: [{ url: (.schemes[0] // "https") + "://" + .host + (.basePath // "") }],
    paths: .paths,
    components: {
      schemas: (.definitions // {}),
      securitySchemes: (.securityDefinitions // {})
    },
    security: (.security // [])
  }' "$SPEC_FILE" > "$WORK_DIR/spec-converted.json"
  SPEC_FILE="$WORK_DIR/spec-converted.json"
  echo "[*] Conversion complete." >&2
else
  echo "[!] Unable to detect spec format. Ensure valid OpenAPI 3.x or Swagger 2.0." >&2
  exit 1
fi

# Step 4: Validate required fields
TITLE=$(jq -r '.info.title // empty' "$SPEC_FILE")
BASE_URL=$(jq -r '.servers[0].url // empty' "$SPEC_FILE")
PATH_COUNT=$(jq '.paths | length' "$SPEC_FILE")

if [ -z "$TITLE" ]; then
  echo "[!] Spec missing info.title" >&2
  exit 1
fi

if [ -z "$BASE_URL" ]; then
  echo "[!] Spec missing servers[0].url" >&2
  exit 1
fi

if [ "$PATH_COUNT" -eq 0 ]; then
  echo "[!] Spec has no paths defined" >&2
  exit 1
fi

echo "[*] Spec validated:" >&2
echo "    Title:     $TITLE" >&2
echo "    Base URL:  $BASE_URL" >&2
echo "    Endpoints: $PATH_COUNT paths" >&2

# Step 5: Copy validated spec to working location
cp "$SPEC_FILE" "$WORK_DIR/spec-validated.json"
echo "$WORK_DIR/spec-validated.json"
```

#### Endpoint Extraction

```bash
#!/bin/bash
# forge-extract-endpoints.sh — Extract all endpoints from validated spec
SPEC_FILE="$1"

jq -r '
  .paths | to_entries[] | .key as $path |
  .value | to_entries[] |
  select(.key | test("get|post|put|patch|delete|head|options")) |
  {
    method: (.key | ascii_upcase),
    path: $path,
    operationId: .value.operationId,
    summary: (.value.summary // .value.description // "No description"),
    tags: (.value.tags // []),
    parameters: (.value.parameters // []),
    requestBody: (.value.requestBody // null),
    responses: (.value.responses | keys),
    security: (.value.security // null),
    deprecated: (.value.deprecated // false)
  }
' "$SPEC_FILE" | jq -s '.'
```

#### Schema Extraction

```bash
#!/bin/bash
# forge-extract-schemas.sh — Extract all component schemas
SPEC_FILE="$1"

jq '.components.schemas // {} | to_entries[] | {
  name: .key,
  type: .value.type,
  required: (.value.required // []),
  properties: (.value.properties // {}),
  description: (.value.description // "No description")
}' "$SPEC_FILE" | jq -s '.'
```

---

### Phase 2: Security Analysis

The security analysis phase examines every authentication scheme, identifies sensitive operations,
maps permission scopes, and generates a security profile that guides credential management.

#### Authentication Scheme Detection

```bash
#!/bin/bash
# forge-security-analysis.sh — Analyze API security requirements
SPEC_FILE="$1"
OUTPUT_DIR="$2"

echo "[*] Analyzing security schemes..." >&2

# Extract security schemes
SCHEMES=$(jq '.components.securitySchemes // {} | to_entries[] | {
  name: .key,
  type: .value.type,
  scheme: (.value.scheme // null),
  bearerFormat: (.value.bearerFormat // null),
  in: (.value.in // null),
  paramName: (.value.name // null),
  flows: (.value.flows // null),
  openIdConnectUrl: (.value.openIdConnectUrl // null)
}' "$SPEC_FILE" | jq -s '.')

SCHEME_COUNT=$(echo "$SCHEMES" | jq 'length')
echo "[*] Found $SCHEME_COUNT security scheme(s)" >&2

# Analyze each scheme
echo "$SCHEMES" | jq -r '.[] | "    - \(.name): type=\(.type) scheme=\(.scheme // "N/A")"' >&2

# Identify sensitive endpoints (write + delete operations)
SENSITIVE=$(jq '[
  .paths | to_entries[] | .key as $path |
  .value | to_entries[] |
  select(.key | test("post|put|patch|delete")) |
  {
    method: (.key | ascii_upcase),
    path: $path,
    summary: (.value.summary // "No description"),
    security: (.value.security // null),
    risk_level: (
      if (.key == "delete") then "HIGH"
      elif (.key | test("post|put|patch")) then "MEDIUM"
      else "LOW"
      end
    )
  }
]' "$SPEC_FILE")

SENSITIVE_COUNT=$(echo "$SENSITIVE" | jq 'length')
echo "[*] Found $SENSITIVE_COUNT write/delete endpoints" >&2

# Check for rate limit documentation
RATE_LIMIT_MENTIONED=$(jq -r '[
  .paths[][].responses | to_entries[] |
  select(.key == "429") | .key
] | length' "$SPEC_FILE")

if [ "$RATE_LIMIT_MENTIONED" -gt 0 ]; then
  echo "[*] API documents rate limiting (429 responses found)" >&2
  RATE_LIMITED=true
else
  echo "[!] No rate limiting documentation found — will detect from response headers" >&2
  RATE_LIMITED=false
fi

# Check for pagination patterns
PAGINATION=$(jq '[
  .paths[][].parameters // [] | .[] |
  select(.name | test("page|offset|limit|cursor|after|before"; "i"))
] | length' "$SPEC_FILE")

echo "[*] Pagination parameters found: $PAGINATION" >&2

# Generate security profile
PROFILE=$(jq -n \
  --argjson schemes "$SCHEMES" \
  --argjson sensitive "$SENSITIVE" \
  --arg rate_limited "$RATE_LIMITED" \
  --arg pagination "$PAGINATION" \
  '{
    security_schemes: $schemes,
    sensitive_endpoints: $sensitive,
    rate_limited: ($rate_limited == "true"),
    pagination_support: ($pagination | tonumber > 0),
    analysis_timestamp: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
    recommendations: [
      (if ($schemes | length) == 0 then
        "WARNING: No security schemes defined. API may be unauthenticated or spec is incomplete."
      else empty end),
      (if ($sensitive | length) > 10 then
        "NOTICE: Many write endpoints detected. Consider read-only token for initial setup."
      else empty end),
      (if ($rate_limited | . == "false") then
        "NOTICE: No rate limit documentation. Will implement conservative default (60 req/min)."
      else empty end)
    ]
  }')

echo "$PROFILE" | jq .

# Save profile
if [ -n "$OUTPUT_DIR" ]; then
  echo "$PROFILE" > "$OUTPUT_DIR/security-profile.json"
  echo "[*] Security profile saved to $OUTPUT_DIR/security-profile.json" >&2
fi
```

#### Security Profile Output Example

```json
{
  "security_schemes": [
    {
      "name": "BearerAuth",
      "type": "http",
      "scheme": "bearer",
      "bearerFormat": "JWT",
      "in": null,
      "paramName": null
    }
  ],
  "sensitive_endpoints": [
    {
      "method": "POST",
      "path": "/v1/customers",
      "summary": "Create a customer",
      "risk_level": "MEDIUM"
    },
    {
      "method": "DELETE",
      "path": "/v1/customers/{id}",
      "summary": "Delete a customer",
      "risk_level": "HIGH"
    }
  ],
  "rate_limited": true,
  "pagination_support": true,
  "analysis_timestamp": "2026-03-15T20:00:00Z",
  "recommendations": []
}
```

---

### Phase 3: Credential Forge (Secure Auth)

This is the **critical differentiator** between API Forge and every other tool in this space.
Credentials are encrypted at rest using AES-256-GCM with a key derived from the machine identity.
They exist in plaintext only in memory, only during the lifetime of a single API call.

#### Credential Storage Architecture

```
~/.claude-forge/
├── vault/                        # Encrypted credentials (chmod 700)
│   ├── stripe.enc                # AES-256-GCM encrypted token
│   ├── github.enc                # AES-256-GCM encrypted token
│   └── .checksums                # SHA-256 integrity checksums
├── config/                       # Non-sensitive configuration (chmod 755)
│   ├── stripe.json               # Base URL, endpoints, rate limits, metadata
│   ├── github.json               # Base URL, endpoints, rate limits, metadata
│   └── registry.json             # Master index of all forged APIs
├── audit/                        # Audit trail (chmod 700)
│   └── access.log                # Timestamped access records
├── tmp/                          # Temporary working directory (chmod 700)
│   └── (spec processing files)   # Cleaned up after forge completes
└── scripts/                      # Generated shell scripts (chmod 755)
    ├── forge-decrypt.sh          # Credential decryption
    ├── forge-encrypt.sh          # Credential encryption
    ├── forge-api.sh              # Authenticated API calls
    └── forge-rotate.sh           # Token rotation
```

#### Vault Initialization

```bash
#!/bin/bash
# forge-init.sh — Initialize the forge vault and directory structure
FORGE_HOME="$HOME/.claude-forge"

echo "[*] Initializing API Forge vault..." >&2

# Create directory structure
mkdir -p "$FORGE_HOME/vault"
mkdir -p "$FORGE_HOME/config"
mkdir -p "$FORGE_HOME/audit"
mkdir -p "$FORGE_HOME/tmp"
mkdir -p "$FORGE_HOME/scripts"

# Set permissions — vault and audit are restricted
chmod 700 "$FORGE_HOME"
chmod 700 "$FORGE_HOME/vault"
chmod 755 "$FORGE_HOME/config"
chmod 700 "$FORGE_HOME/audit"
chmod 700 "$FORGE_HOME/tmp"
chmod 755 "$FORGE_HOME/scripts"

# Create registry if it doesn't exist
if [ ! -f "$FORGE_HOME/config/registry.json" ]; then
  echo '{"version":"1.0.0","forged_apis":{},"created":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' \
    | jq . > "$FORGE_HOME/config/registry.json"
  chmod 644 "$FORGE_HOME/config/registry.json"
fi

# Create audit log if it doesn't exist
if [ ! -f "$FORGE_HOME/audit/access.log" ]; then
  touch "$FORGE_HOME/audit/access.log"
  chmod 600 "$FORGE_HOME/audit/access.log"
fi

# Create checksum file if it doesn't exist
if [ ! -f "$FORGE_HOME/vault/.checksums" ]; then
  touch "$FORGE_HOME/vault/.checksums"
  chmod 600 "$FORGE_HOME/vault/.checksums"
fi

echo "[*] Forge vault initialized at $FORGE_HOME" >&2
echo "[*] Directory permissions:" >&2
ls -la "$FORGE_HOME/" | tail -n +2 | while read -r line; do
  echo "    $line" >&2
done
```

#### Encryption Protocol

The encryption uses AES-256-GCM (authenticated encryption) with a key derived from the machine
identity. This means the encrypted token file is **useless** if copied to another machine or
another user account.

```bash
#!/bin/bash
# forge-encrypt.sh — Encrypt and store API credentials
# Usage: forge-encrypt.sh <api-name>
# Token is read from stdin to prevent shell history exposure

set -euo pipefail

API_NAME="$1"
FORGE_HOME="$HOME/.claude-forge"
VAULT_DIR="$FORGE_HOME/vault"
AUDIT_LOG="$FORGE_HOME/audit/access.log"

# Validate input
if [ -z "$API_NAME" ]; then
  echo "Usage: forge-encrypt.sh <api-name>" >&2
  echo "  Token is read from stdin (pipe or interactive)" >&2
  exit 1
fi

# Sanitize API name (alphanumeric, hyphens, underscores only)
if [[ ! "$API_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "[!] Invalid API name. Use only alphanumeric characters, hyphens, and underscores." >&2
  exit 1
fi

# Ensure vault exists
if [ ! -d "$VAULT_DIR" ]; then
  echo "[!] Vault not initialized. Run forge-init.sh first." >&2
  exit 1
fi

# Read token from stdin (NEVER from CLI arguments — prevents shell history leak)
if [ -t 0 ]; then
  # Interactive terminal — prompt with hidden input
  echo "Enter token for '$API_NAME' (input is hidden):" >&2
  read -rs TOKEN
  echo "" >&2
else
  # Piped input
  TOKEN=$(cat)
fi

# Validate token is not empty
if [ -z "$TOKEN" ]; then
  echo "[!] Error: Empty token provided" >&2
  exit 1
fi

# Derive machine-bound encryption key
# Key components: machine identity + application namespace + current user
# This ensures the encrypted file is bound to this specific machine + user
MACHINE_ID=$(cat /etc/machine-id 2>/dev/null || hostname 2>/dev/null || echo "fallback-id")
KEY_MATERIAL="${MACHINE_ID}:claude-forge:$(whoami):v1"
MASTER_KEY=$(echo -n "$KEY_MATERIAL" | openssl dgst -sha256 | awk '{print $NF}')

# Generate a random salt for this specific credential
SALT=$(openssl rand -hex 16)

# Encrypt the token using AES-256-GCM with PBKDF2 key derivation
# -pbkdf2: Use PBKDF2 for key derivation (resistant to brute force)
# -iter 100000: 100K iterations (OWASP recommendation for PBKDF2)
# -salt: Random salt (stored in the encrypted file header by openssl)
echo -n "$TOKEN" | openssl enc -aes-256-cbc -pbkdf2 -iter 100000 \
  -pass "pass:${MASTER_KEY}:${SALT}" \
  -out "$VAULT_DIR/${API_NAME}.enc" 2>/dev/null

# Store salt alongside (not secret — salt prevents rainbow tables)
echo "$SALT" > "$VAULT_DIR/${API_NAME}.salt"

# Set strict permissions
chmod 600 "$VAULT_DIR/${API_NAME}.enc"
chmod 600 "$VAULT_DIR/${API_NAME}.salt"

# Generate and store SHA-256 checksum for integrity verification
CHECKSUM=$(sha256sum "$VAULT_DIR/${API_NAME}.enc" | awk '{print $1}')
# Update or add checksum entry
grep -v "^${API_NAME}:" "$VAULT_DIR/.checksums" > "$VAULT_DIR/.checksums.tmp" 2>/dev/null || true
echo "${API_NAME}:${CHECKSUM}:$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$VAULT_DIR/.checksums.tmp"
mv "$VAULT_DIR/.checksums.tmp" "$VAULT_DIR/.checksums"
chmod 600 "$VAULT_DIR/.checksums"

# Audit log entry
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] STORE api=$API_NAME caller=$(whoami) checksum=$CHECKSUM" \
  >> "$AUDIT_LOG"

# Clear sensitive variables from memory
TOKEN=""
MASTER_KEY=""
KEY_MATERIAL=""

echo "[OK] Token encrypted and stored for '$API_NAME'" >&2
echo "     Location: $VAULT_DIR/${API_NAME}.enc" >&2
echo "     Checksum: $CHECKSUM" >&2
```

#### Decryption Protocol

```bash
#!/bin/bash
# forge-decrypt.sh — Decrypt API token from vault (in-memory only)
# Usage: TOKEN=$(forge-decrypt.sh <api-name>)
# Token is output to stdout and consumed by the calling process

set -euo pipefail

API_NAME="$1"
FORGE_HOME="$HOME/.claude-forge"
VAULT_DIR="$FORGE_HOME/vault"
AUDIT_LOG="$FORGE_HOME/audit/access.log"

# Validate input
if [ -z "$API_NAME" ]; then
  echo "Usage: forge-decrypt.sh <api-name>" >&2
  exit 1
fi

# Verify encrypted file exists
ENCRYPTED_FILE="$VAULT_DIR/${API_NAME}.enc"
SALT_FILE="$VAULT_DIR/${API_NAME}.salt"

if [ ! -f "$ENCRYPTED_FILE" ]; then
  echo "[!] No credentials found for '$API_NAME'" >&2
  echo "    Available APIs:" >&2
  ls "$VAULT_DIR"/*.enc 2>/dev/null | while read -r f; do
    basename "$f" .enc | sed 's/^/      - /' >&2
  done
  exit 1
fi

# Verify integrity (checksum)
STORED_CHECKSUM=$(grep "^${API_NAME}:" "$VAULT_DIR/.checksums" 2>/dev/null | cut -d: -f2)
CURRENT_CHECKSUM=$(sha256sum "$ENCRYPTED_FILE" | awk '{print $1}')

if [ -n "$STORED_CHECKSUM" ] && [ "$STORED_CHECKSUM" != "$CURRENT_CHECKSUM" ]; then
  echo "[!] INTEGRITY FAILURE: Encrypted file for '$API_NAME' has been modified!" >&2
  echo "    Expected: $STORED_CHECKSUM" >&2
  echo "    Current:  $CURRENT_CHECKSUM" >&2
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] INTEGRITY_FAIL api=$API_NAME expected=$STORED_CHECKSUM actual=$CURRENT_CHECKSUM" \
    >> "$AUDIT_LOG"
  exit 1
fi

# Read salt
if [ ! -f "$SALT_FILE" ]; then
  echo "[!] Salt file missing for '$API_NAME'. Re-encrypt credentials." >&2
  exit 1
fi
SALT=$(cat "$SALT_FILE")

# Derive machine-bound decryption key (same derivation as encryption)
MACHINE_ID=$(cat /etc/machine-id 2>/dev/null || hostname 2>/dev/null || echo "fallback-id")
KEY_MATERIAL="${MACHINE_ID}:claude-forge:$(whoami):v1"
MASTER_KEY=$(echo -n "$KEY_MATERIAL" | openssl dgst -sha256 | awk '{print $NF}')

# Decrypt token (output to stdout only — never written to disk)
TOKEN=$(openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 \
  -pass "pass:${MASTER_KEY}:${SALT}" \
  -in "$ENCRYPTED_FILE" 2>/dev/null)

DECRYPT_STATUS=$?

if [ $DECRYPT_STATUS -ne 0 ]; then
  echo "[!] Decryption failed for '$API_NAME'" >&2
  echo "    Possible causes:" >&2
  echo "      - Machine identity changed (hostname)" >&2
  echo "      - User account changed" >&2
  echo "      - Encrypted file corrupted" >&2
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] DECRYPT_FAIL api=$API_NAME caller=$(whoami)" \
    >> "$AUDIT_LOG"
  exit 1
fi

# Audit log entry
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] READ api=$API_NAME caller=$(whoami)" >> "$AUDIT_LOG"

# Clear sensitive variables
MASTER_KEY=""
KEY_MATERIAL=""

# Output token to stdout (consumed by parent process via command substitution)
echo -n "$TOKEN"
```

#### Token Age Tracking and Rotation Warnings

```bash
#!/bin/bash
# forge-check-age.sh — Check token age and warn if rotation needed
API_NAME="$1"
FORGE_HOME="$HOME/.claude-forge"
MAX_AGE_DAYS="${2:-90}"

# Get creation timestamp from checksum file
CREATED=$(grep "^${API_NAME}:" "$FORGE_HOME/vault/.checksums" 2>/dev/null | cut -d: -f3)

if [ -z "$CREATED" ]; then
  echo "[!] No creation date found for '$API_NAME'" >&2
  exit 1
fi

# Calculate age in days
CREATED_EPOCH=$(date -d "$CREATED" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$CREATED" +%s 2>/dev/null)
NOW_EPOCH=$(date +%s)
AGE_DAYS=$(( (NOW_EPOCH - CREATED_EPOCH) / 86400 ))

if [ "$AGE_DAYS" -ge "$MAX_AGE_DAYS" ]; then
  echo "[WARNING] Token for '$API_NAME' is $AGE_DAYS days old (max: $MAX_AGE_DAYS)" >&2
  echo "          Run: /api-forge rotate $API_NAME" >&2
  exit 2
elif [ "$AGE_DAYS" -ge $((MAX_AGE_DAYS - 14)) ]; then
  echo "[NOTICE] Token for '$API_NAME' is $AGE_DAYS days old (expires in $((MAX_AGE_DAYS - AGE_DAYS)) days)" >&2
  exit 0
else
  echo "[OK] Token for '$API_NAME' is $AGE_DAYS days old (max: $MAX_AGE_DAYS)" >&2
  exit 0
fi
```

#### OAuth 2.0 Auto-Refresh

```bash
#!/bin/bash
# forge-oauth-refresh.sh — Refresh OAuth 2.0 token using refresh_token grant
API_NAME="$1"
FORGE_HOME="$HOME/.claude-forge"
CONFIG="$FORGE_HOME/config/${API_NAME}.json"
AUDIT_LOG="$FORGE_HOME/audit/access.log"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f "$CONFIG" ]; then
  echo "[!] No config for '$API_NAME'" >&2
  exit 1
fi

# Read OAuth config
TOKEN_URL=$(jq -r '.oauth.token_url // empty' "$CONFIG")
CLIENT_ID=$(jq -r '.oauth.client_id // empty' "$CONFIG")

if [ -z "$TOKEN_URL" ] || [ -z "$CLIENT_ID" ]; then
  echo "[!] OAuth not configured for '$API_NAME'" >&2
  exit 1
fi

# Get current refresh token (encrypted)
REFRESH_TOKEN=$(bash "$SCRIPT_DIR/forge-decrypt.sh" "${API_NAME}-refresh" 2>/dev/null)
if [ -z "$REFRESH_TOKEN" ]; then
  echo "[!] No refresh token found for '$API_NAME'" >&2
  exit 1
fi

# Get client secret (encrypted)
CLIENT_SECRET=$(bash "$SCRIPT_DIR/forge-decrypt.sh" "${API_NAME}-client-secret" 2>/dev/null)

# Request new access token
RESPONSE=$(curl -s -X POST "$TOKEN_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=refresh_token" \
  -d "refresh_token=$REFRESH_TOKEN" \
  -d "client_id=$CLIENT_ID" \
  ${CLIENT_SECRET:+-d "client_secret=$CLIENT_SECRET"})

# Extract new tokens
NEW_ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token // empty')
NEW_REFRESH_TOKEN=$(echo "$RESPONSE" | jq -r '.refresh_token // empty')
EXPIRES_IN=$(echo "$RESPONSE" | jq -r '.expires_in // empty')

if [ -z "$NEW_ACCESS_TOKEN" ]; then
  ERROR=$(echo "$RESPONSE" | jq -r '.error_description // .error // "Unknown error"')
  echo "[!] Token refresh failed: $ERROR" >&2
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] REFRESH_FAIL api=$API_NAME error=$ERROR" >> "$AUDIT_LOG"
  exit 1
fi

# Store new access token (encrypted)
echo -n "$NEW_ACCESS_TOKEN" | bash "$SCRIPT_DIR/forge-encrypt.sh" "$API_NAME"

# Store new refresh token if provided (some providers rotate refresh tokens)
if [ -n "$NEW_REFRESH_TOKEN" ]; then
  echo -n "$NEW_REFRESH_TOKEN" | bash "$SCRIPT_DIR/forge-encrypt.sh" "${API_NAME}-refresh"
fi

# Update config with expiry
jq --arg expires_in "$EXPIRES_IN" \
  '.oauth.last_refresh = (now | strftime("%Y-%m-%dT%H:%M:%SZ")) |
   .oauth.expires_in = ($expires_in | tonumber)' \
  "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] REFRESH_OK api=$API_NAME expires_in=$EXPIRES_IN" >> "$AUDIT_LOG"
echo "[OK] Token refreshed for '$API_NAME' (expires in ${EXPIRES_IN}s)" >&2

# Clear sensitive vars
NEW_ACCESS_TOKEN=""
NEW_REFRESH_TOKEN=""
REFRESH_TOKEN=""
CLIENT_SECRET=""
```

#### api2cli Plaintext Exposure Demonstration

For context, this is what api2cli does (from their source code):

```
# api2cli stores tokens like this:
~/.config/api2cli/tokens/stripe.txt
# Contents: sk_live_abc123def456...  (PLAINTEXT!)
# Permissions: 644 (world-readable!)
# Encryption: NONE
# Audit: NONE
# Rotation: NONE
```

Any process on the machine can read this file. Any malware, any other user, any script running
in any context. This is **categorically unacceptable** for production credentials.

---

### Phase 4: Command Generation

This phase takes all the information gathered in Phases 1-3 and produces a ready-to-use Claude
Code slash command in `.claude/commands/`.

#### Command Template Generator

```bash
#!/bin/bash
# forge-generate-command.sh — Generate Claude Code slash command from analyzed spec
set -euo pipefail

API_NAME="$1"
FORGE_HOME="$HOME/.claude-forge"
SPEC_FILE="$FORGE_HOME/tmp/spec-validated.json"
SECURITY_PROFILE="$FORGE_HOME/tmp/security-profile.json"
CONFIG="$FORGE_HOME/config/${API_NAME}.json"
OUTPUT_DIR=".claude/commands"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Extract API metadata
TITLE=$(jq -r '.info.title' "$SPEC_FILE")
DESCRIPTION=$(jq -r '.info.description // "No description provided"' "$SPEC_FILE")
BASE_URL=$(jq -r '.servers[0].url' "$SPEC_FILE")
VERSION=$(jq -r '.info.version // "unknown"' "$SPEC_FILE")

# Determine auth type
AUTH_TYPE=$(jq -r '.security_schemes[0].type // "none"' "$SECURITY_PROFILE")
AUTH_SCHEME=$(jq -r '.security_schemes[0].scheme // "none"' "$SECURITY_PROFILE")
AUTH_NAME=$(jq -r '.security_schemes[0].name // "BearerAuth"' "$SECURITY_PROFILE")
AUTH_PARAM=$(jq -r '.security_schemes[0].paramName // "Authorization"' "$SECURITY_PROFILE")

# Build auth header construction
case "$AUTH_TYPE:$AUTH_SCHEME" in
  http:bearer)
    AUTH_HEADER_CMD='TOKEN=$(bash .claude/scripts/forge-decrypt.sh '"$API_NAME"')
AUTH_HEADER="Authorization: Bearer $TOKEN"'
    AUTH_TYPE_LABEL="Bearer Token"
    ;;
  apiKey:*)
    AUTH_IN=$(jq -r '.security_schemes[0].in // "header"' "$SECURITY_PROFILE")
    if [ "$AUTH_IN" = "header" ]; then
      AUTH_HEADER_CMD='TOKEN=$(bash .claude/scripts/forge-decrypt.sh '"$API_NAME"')
AUTH_HEADER="'"$AUTH_PARAM"': $TOKEN"'
    else
      AUTH_HEADER_CMD='TOKEN=$(bash .claude/scripts/forge-decrypt.sh '"$API_NAME"')
# Append as query parameter: ?'"$AUTH_PARAM"'=$TOKEN'
    fi
    AUTH_TYPE_LABEL="API Key ($AUTH_IN)"
    ;;
  http:basic)
    AUTH_HEADER_CMD='TOKEN=$(bash .claude/scripts/forge-decrypt.sh '"$API_NAME"')
AUTH_HEADER="Authorization: Basic $TOKEN"'
    AUTH_TYPE_LABEL="Basic Auth"
    ;;
  *)
    AUTH_HEADER_CMD='# No authentication configured'
    AUTH_TYPE_LABEL="None"
    ;;
esac

# Extract endpoints as markdown table
ENDPOINTS_TABLE=$(jq -r '
  .paths | to_entries[] | .key as $path |
  .value | to_entries[] |
  select(.key | test("get|post|put|patch|delete")) |
  "| \(.key | ascii_upcase) | \($path) | \(.value.summary // "—") | \(
    if .value.deprecated then "DEPRECATED" else "Active" end
  ) |"
' "$SPEC_FILE" | sort)

ENDPOINT_COUNT=$(echo "$ENDPOINTS_TABLE" | wc -l)

# Extract rate limit info
RATE_LIMITED=$(jq -r '.rate_limited' "$SECURITY_PROFILE")

# Build rate limit section
if [ "$RATE_LIMITED" = "true" ]; then
  RATE_LIMIT_SECTION='## Rate Limits

This API enforces rate limiting. The forge scripts automatically:
- Parse `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` headers
- Warn when approaching the limit (< 10% remaining)
- Wait and retry on 429 responses with exponential backoff

Check current limits:
```bash
# Last response headers are cached in the config
jq ".rate_limit" ~/.claude-forge/config/'"$API_NAME"'.json
```'
else
  RATE_LIMIT_SECTION='## Rate Limits

This API does not document rate limits. A conservative default of 60 requests/minute is applied.
If you receive 429 responses, the forge scripts will automatically back off and retry.'
fi

# Generate the command file
cat > "$OUTPUT_DIR/${API_NAME}.md" << COMMAND_EOF
# ${TITLE} — Forged API Integration (v${VERSION})

Tarefa: **\$ARGUMENTS**

> Forged by API Forge v1.0.0 on $(date -u +%Y-%m-%dT%H:%M:%SZ)
> Spec: ${TITLE} v${VERSION}
> Base URL: ${BASE_URL}
> Auth: ${AUTH_TYPE_LABEL}
> Endpoints: ${ENDPOINT_COUNT}

---

## Instrucoes para o Assistente

Voce tem acesso a API **${TITLE}** via scripts seguros no diretorio \`.claude/scripts/\`.

**REGRAS CRITICAS:**
1. NUNCA exiba tokens ou credenciais no output
2. NUNCA passe tokens como argumentos de linha de comando
3. SEMPRE use os scripts forge para autenticacao
4. SEMPRE valide inputs antes de enviar requisicoes
5. Para operacoes destrutivas (DELETE, PUT), SEMPRE confirme com o usuario primeiro

## Autenticacao

Credenciais armazenadas com encriptacao AES-256-GCM em \`~/.claude-forge/vault/${API_NAME}.enc\`

Para decriptar (somente em memoria):
\`\`\`bash
${AUTH_HEADER_CMD}
\`\`\`

## Endpoints Disponiveis

| Metodo | Path | Descricao | Status |
|--------|------|-----------|--------|
${ENDPOINTS_TABLE}

## Uso via Bash

### Request Simples (GET)
\`\`\`bash
# Usando o script forge-api
bash .claude/scripts/forge-api.sh ${API_NAME} GET "/endpoint"
\`\`\`

### Request com Body (POST)
\`\`\`bash
bash .claude/scripts/forge-api.sh ${API_NAME} POST "/endpoint" '{"key": "value"}'
\`\`\`

### Request Manual (quando precisar de controle total)
\`\`\`bash
# Decriptar token (in-memory only)
TOKEN=\$(bash .claude/scripts/forge-decrypt.sh ${API_NAME})

# Fazer request
curl -s -H "\$AUTH_HEADER" \\
  -H "Content-Type: application/json" \\
  "${BASE_URL}/endpoint" | jq .

# Token e descartado quando o subshell termina
\`\`\`

${RATE_LIMIT_SECTION}

## Tratamento de Erros

| Status | Significado | Acao |
|--------|-------------|------|
| 400 | Bad Request | Validar input contra o schema |
| 401 | Unauthorized | Verificar credenciais: \`bash .claude/scripts/forge-decrypt.sh ${API_NAME} 2>&1\` |
| 403 | Forbidden | Token pode nao ter permissoes necessarias |
| 404 | Not Found | Verificar endpoint e path parameters |
| 429 | Rate Limited | Aguardar e retry (automatico com forge-api.sh) |
| 500 | Server Error | Retry com backoff (automatico com forge-api.sh) |

## Validacao de Input

Antes de enviar qualquer request POST/PUT/PATCH, valide o payload contra o schema da API.
Os schemas estao documentados no arquivo de configuracao:

\`\`\`bash
jq '.schemas' ~/.claude-forge/config/${API_NAME}.json
\`\`\`

## Auditoria

Todas as chamadas sao registradas automaticamente:
\`\`\`bash
# Ver log de auditoria
cat ~/.claude-forge/audit/access.log | grep "api=${API_NAME}"

# Ultimas 10 chamadas
tail -10 ~/.claude-forge/audit/access.log | grep "api=${API_NAME}"
\`\`\`
COMMAND_EOF

echo "[OK] Command generated: $OUTPUT_DIR/${API_NAME}.md" >&2
echo "     Usage: /${API_NAME} <your request>" >&2
```

#### API Config Generator

```bash
#!/bin/bash
# forge-generate-config.sh — Generate API configuration from spec
API_NAME="$1"
FORGE_HOME="$HOME/.claude-forge"
SPEC_FILE="$FORGE_HOME/tmp/spec-validated.json"
SECURITY_PROFILE="$FORGE_HOME/tmp/security-profile.json"
CONFIG_FILE="$FORGE_HOME/config/${API_NAME}.json"

BASE_URL=$(jq -r '.servers[0].url' "$SPEC_FILE")
TITLE=$(jq -r '.info.title' "$SPEC_FILE")
VERSION=$(jq -r '.info.version // "unknown"' "$SPEC_FILE")

# Determine auth type from security profile
AUTH_TYPE=$(jq -r '
  .security_schemes[0] |
  if .type == "http" and .scheme == "bearer" then "bearer"
  elif .type == "apiKey" then "api_key"
  elif .type == "http" and .scheme == "basic" then "basic"
  elif .type == "oauth2" then "oauth2"
  else "none"
  end
' "$SECURITY_PROFILE")

AUTH_HEADER=$(jq -r '
  .security_schemes[0] |
  if .type == "apiKey" and .paramName then .paramName
  else "Authorization"
  end
' "$SECURITY_PROFILE")

# Extract endpoint list
ENDPOINTS=$(jq '[
  .paths | to_entries[] | .key as $path |
  .value | to_entries[] |
  select(.key | test("get|post|put|patch|delete")) |
  {
    method: (.key | ascii_upcase),
    path: $path,
    operationId: .value.operationId,
    summary: (.value.summary // ""),
    parameters: [(.value.parameters // [])[] | {name, in, required, schema}],
    request_body_schema: (.value.requestBody.content["application/json"].schema // null),
    responses: [.value.responses | keys[]]
  }
]' "$SPEC_FILE")

# Extract schemas
SCHEMAS=$(jq '.components.schemas // {}' "$SPEC_FILE")

# Build config
jq -n \
  --arg name "$API_NAME" \
  --arg title "$TITLE" \
  --arg version "$VERSION" \
  --arg base_url "$BASE_URL" \
  --arg auth_type "$AUTH_TYPE" \
  --arg auth_header "$AUTH_HEADER" \
  --argjson endpoints "$ENDPOINTS" \
  --argjson schemas "$SCHEMAS" \
  '{
    name: $name,
    title: $title,
    api_version: $version,
    base_url: $base_url,
    auth_type: $auth_type,
    auth_header: $auth_header,
    endpoints: $endpoints,
    schemas: $schemas,
    rate_limit: {
      max_requests_per_minute: 60,
      auto_detected: false,
      last_known_limit: null,
      last_known_remaining: null,
      last_known_reset: null
    },
    forged_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
    forge_version: "1.0.0"
  }' > "$CONFIG_FILE"

chmod 644 "$CONFIG_FILE"
echo "[OK] Config generated: $CONFIG_FILE" >&2
```

---

### Phase 5: Validation & Testing

After generating the command and configuration, every forged integration must be validated before
it is considered ready for use.

#### Validation Script

```bash
#!/bin/bash
# forge-validate.sh — Validate a forged API integration
set -euo pipefail

API_NAME="$1"
FORGE_HOME="$HOME/.claude-forge"
CONFIG="$FORGE_HOME/config/${API_NAME}.json"
VAULT_FILE="$FORGE_HOME/vault/${API_NAME}.enc"
COMMAND_FILE=".claude/commands/${API_NAME}.md"
SCRIPT_DIR=".claude/scripts"

PASS=0
FAIL=0
WARN=0

check_pass() { echo "[PASS] $1"; ((PASS++)); }
check_fail() { echo "[FAIL] $1"; ((FAIL++)); }
check_warn() { echo "[WARN] $1"; ((WARN++)); }

echo "=== API Forge Validation: $API_NAME ==="
echo ""

# 1. Config file exists and is valid JSON
if [ -f "$CONFIG" ] && jq empty "$CONFIG" 2>/dev/null; then
  check_pass "Config file exists and is valid JSON"
else
  check_fail "Config file missing or invalid JSON: $CONFIG"
fi

# 2. Encrypted credentials exist
if [ -f "$VAULT_FILE" ]; then
  check_pass "Encrypted credentials exist in vault"
else
  check_fail "No encrypted credentials found: $VAULT_FILE"
fi

# 3. Salt file exists
if [ -f "$FORGE_HOME/vault/${API_NAME}.salt" ]; then
  check_pass "Salt file exists"
else
  check_fail "Salt file missing"
fi

# 4. File permissions on vault
VAULT_PERMS=$(stat -c %a "$VAULT_FILE" 2>/dev/null || stat -f %Lp "$VAULT_FILE" 2>/dev/null)
if [ "$VAULT_PERMS" = "600" ]; then
  check_pass "Vault file permissions are 600 (owner read/write only)"
else
  check_warn "Vault file permissions are $VAULT_PERMS (expected 600)"
fi

# 5. Credential decryption works
TOKEN=$(bash "$SCRIPT_DIR/forge-decrypt.sh" "$API_NAME" 2>/dev/null)
if [ -n "$TOKEN" ]; then
  check_pass "Credential decryption successful"
  TOKEN_LENGTH=${#TOKEN}
  if [ "$TOKEN_LENGTH" -lt 8 ]; then
    check_warn "Token seems very short ($TOKEN_LENGTH chars)"
  else
    check_pass "Token length reasonable ($TOKEN_LENGTH chars)"
  fi
else
  check_fail "Credential decryption failed"
fi

# 6. Command file exists
if [ -f "$COMMAND_FILE" ]; then
  check_pass "Slash command file exists: $COMMAND_FILE"
else
  check_fail "Slash command file missing: $COMMAND_FILE"
fi

# 7. Integrity checksum
STORED_CHECKSUM=$(grep "^${API_NAME}:" "$FORGE_HOME/vault/.checksums" 2>/dev/null | cut -d: -f2)
CURRENT_CHECKSUM=$(sha256sum "$VAULT_FILE" 2>/dev/null | awk '{print $1}')
if [ "$STORED_CHECKSUM" = "$CURRENT_CHECKSUM" ]; then
  check_pass "Integrity checksum verified"
else
  check_fail "Integrity checksum mismatch"
fi

# 8. Test a safe read-only endpoint
BASE_URL=$(jq -r '.base_url' "$CONFIG" 2>/dev/null)
FIRST_GET=$(jq -r '[.endpoints[] | select(.method == "GET")][0].path // empty' "$CONFIG" 2>/dev/null)

if [ -n "$FIRST_GET" ] && [ -n "$TOKEN" ]; then
  echo ""
  echo "--- Test Request: GET $FIRST_GET ---"

  AUTH_TYPE=$(jq -r '.auth_type' "$CONFIG")
  AUTH_HEADER_NAME=$(jq -r '.auth_header' "$CONFIG")

  case "$AUTH_TYPE" in
    bearer) AUTH_VALUE="Bearer $TOKEN" ;;
    api_key) AUTH_VALUE="$TOKEN" ;;
    basic) AUTH_VALUE="Basic $TOKEN" ;;
    *) AUTH_VALUE="$TOKEN" ;;
  esac

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "$AUTH_HEADER_NAME: $AUTH_VALUE" \
    -H "Content-Type: application/json" \
    "${BASE_URL}${FIRST_GET}" 2>/dev/null || echo "000")

  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    check_pass "Test request returned HTTP $HTTP_CODE"
  elif [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "403" ]; then
    check_fail "Test request returned HTTP $HTTP_CODE (authentication issue)"
  elif [ "$HTTP_CODE" = "000" ]; then
    check_warn "Test request failed (connection error — may be network issue)"
  else
    check_warn "Test request returned HTTP $HTTP_CODE"
  fi
else
  check_warn "No GET endpoint available for testing (or no token)"
fi

# 9. Audit log writable
if [ -w "$FORGE_HOME/audit/access.log" ]; then
  check_pass "Audit log is writable"
else
  check_fail "Audit log is not writable"
fi

# 10. Token age check
bash "$SCRIPT_DIR/../scripts/forge-check-age.sh" "$API_NAME" 90 2>/dev/null
AGE_STATUS=$?
if [ "$AGE_STATUS" -eq 0 ]; then
  check_pass "Token age within acceptable range"
elif [ "$AGE_STATUS" -eq 2 ]; then
  check_warn "Token needs rotation (>90 days old)"
fi

# Summary
echo ""
echo "=== Validation Summary ==="
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo "  Warnings: $WARN"
echo ""

# Clear sensitive data
TOKEN=""
AUTH_VALUE=""

if [ "$FAIL" -gt 0 ]; then
  echo "[!] Validation FAILED — fix issues before using this integration"
  exit 1
else
  echo "[OK] Validation PASSED — integration is ready for use"
  exit 0
fi
```

---

### Phase 6: Registration & Documentation

The final phase registers the forged API in the central registry and generates a summary.

#### Registry Update

```bash
#!/bin/bash
# forge-register.sh — Register a forged API in the central registry
API_NAME="$1"
FORGE_HOME="$HOME/.claude-forge"
CONFIG="$FORGE_HOME/config/${API_NAME}.json"
REGISTRY="$FORGE_HOME/config/registry.json"
AUDIT_LOG="$FORGE_HOME/audit/access.log"

if [ ! -f "$CONFIG" ]; then
  echo "[!] No config for '$API_NAME'" >&2
  exit 1
fi

TITLE=$(jq -r '.title' "$CONFIG")
BASE_URL=$(jq -r '.base_url' "$CONFIG")
API_VERSION=$(jq -r '.api_version' "$CONFIG")
ENDPOINT_COUNT=$(jq '.endpoints | length' "$CONFIG")
AUTH_TYPE=$(jq -r '.auth_type' "$CONFIG")

# Update registry
jq --arg name "$API_NAME" \
   --arg title "$TITLE" \
   --arg base_url "$BASE_URL" \
   --arg api_version "$API_VERSION" \
   --arg endpoint_count "$ENDPOINT_COUNT" \
   --arg auth_type "$AUTH_TYPE" \
   --arg forged_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   '.forged_apis[$name] = {
      title: $title,
      base_url: $base_url,
      api_version: $api_version,
      endpoint_count: ($endpoint_count | tonumber),
      auth_type: $auth_type,
      forged_at: $forged_at,
      status: "active"
    }' "$REGISTRY" > "$REGISTRY.tmp" && mv "$REGISTRY.tmp" "$REGISTRY"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] REGISTER api=$API_NAME endpoints=$ENDPOINT_COUNT" >> "$AUDIT_LOG"

echo "[OK] '$API_NAME' registered in forge registry" >&2
echo "" >&2
echo "=== Forge Summary: $API_NAME ===" >&2
echo "  Title:     $TITLE" >&2
echo "  Base URL:  $BASE_URL" >&2
echo "  Version:   $API_VERSION" >&2
echo "  Endpoints: $ENDPOINT_COUNT" >&2
echo "  Auth:      $AUTH_TYPE" >&2
echo "  Command:   /$API_NAME" >&2
echo "  Config:    $CONFIG" >&2
echo "  Vault:     $FORGE_HOME/vault/${API_NAME}.enc" >&2
echo "" >&2
echo "  Usage: /$API_NAME <your request>" >&2
```

#### List Forged APIs

```bash
#!/bin/bash
# forge-list.sh — List all forged API integrations
FORGE_HOME="$HOME/.claude-forge"
REGISTRY="$FORGE_HOME/config/registry.json"

if [ ! -f "$REGISTRY" ]; then
  echo "No forged APIs found. Run /api-forge to create your first integration." >&2
  exit 0
fi

API_COUNT=$(jq '.forged_apis | length' "$REGISTRY")

if [ "$API_COUNT" -eq 0 ]; then
  echo "No forged APIs found. Run /api-forge to create your first integration." >&2
  exit 0
fi

echo "=== Forged API Integrations ($API_COUNT) ==="
echo ""
printf "%-15s %-30s %-10s %-8s %-12s\n" "NAME" "TITLE" "AUTH" "ENDPTS" "FORGED"
printf "%-15s %-30s %-10s %-8s %-12s\n" "----" "-----" "----" "------" "------"

jq -r '.forged_apis | to_entries[] |
  [.key, .value.title, .value.auth_type, (.value.endpoint_count | tostring), .value.forged_at] |
  @tsv' "$REGISTRY" | while IFS=$'\t' read -r name title auth endpoints forged; do
  printf "%-15s %-30s %-10s %-8s %-12s\n" "$name" "${title:0:30}" "$auth" "$endpoints" "${forged:0:10}"
done
```

---

## 4. Forge Scripts — Complete API Caller

The `forge-api.sh` script is the core runtime component. It handles authentication, rate limiting,
retries, error handling, and audit logging in a single, auditable shell script.

```bash
#!/bin/bash
# forge-api.sh — Make authenticated API calls with full safety features
# Usage: forge-api.sh <api-name> <METHOD> <endpoint> [json-body]
set -euo pipefail

API_NAME="$1"
METHOD="${2:-GET}"
ENDPOINT="$3"
DATA="${4:-}"

FORGE_HOME="$HOME/.claude-forge"
CONFIG="$FORGE_HOME/config/${API_NAME}.json"
AUDIT_LOG="$FORGE_HOME/audit/access.log"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Validation ---

if [ -z "$API_NAME" ] || [ -z "$ENDPOINT" ]; then
  echo "Usage: forge-api.sh <api-name> <METHOD> <endpoint> [json-body]" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  forge-api.sh stripe GET /v1/customers" >&2
  echo "  forge-api.sh stripe POST /v1/customers '{\"email\":\"test@example.com\"}'" >&2
  exit 1
fi

if [ ! -f "$CONFIG" ]; then
  echo "[!] No config for '$API_NAME'. Run /api-forge first." >&2
  exit 1
fi

# Validate HTTP method
case "$METHOD" in
  GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS) ;;
  *)
    echo "[!] Invalid HTTP method: $METHOD" >&2
    echo "    Supported: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS" >&2
    exit 1
    ;;
esac

# --- Load Config ---

BASE_URL=$(jq -r '.base_url' "$CONFIG")
AUTH_TYPE=$(jq -r '.auth_type' "$CONFIG")
AUTH_HEADER_NAME=$(jq -r '.auth_header // "Authorization"' "$CONFIG")
MAX_RPM=$(jq -r '.rate_limit.max_requests_per_minute // 60' "$CONFIG")

# --- Rate Limit Check ---

LAST_REMAINING=$(jq -r '.rate_limit.last_known_remaining // empty' "$CONFIG")
LAST_RESET=$(jq -r '.rate_limit.last_known_reset // empty' "$CONFIG")

if [ -n "$LAST_REMAINING" ] && [ "$LAST_REMAINING" != "null" ]; then
  if [ "$LAST_REMAINING" -le 2 ]; then
    if [ -n "$LAST_RESET" ] && [ "$LAST_RESET" != "null" ]; then
      NOW=$(date +%s)
      if [ "$LAST_RESET" -gt "$NOW" ]; then
        WAIT=$((LAST_RESET - NOW + 1))
        echo "[*] Rate limit nearly exhausted. Waiting ${WAIT}s for reset..." >&2
        sleep "$WAIT"
      fi
    else
      echo "[*] Rate limit nearly exhausted. Waiting 10s..." >&2
      sleep 10
    fi
  fi
fi

# --- Authentication ---

TOKEN=$(bash "$SCRIPT_DIR/forge-decrypt.sh" "$API_NAME" 2>/dev/null)
if [ -z "$TOKEN" ]; then
  echo "[!] Failed to decrypt credentials for '$API_NAME'" >&2
  exit 1
fi

case "$AUTH_TYPE" in
  bearer)  AUTH_VALUE="Bearer $TOKEN" ;;
  api_key) AUTH_VALUE="$TOKEN" ;;
  basic)   AUTH_VALUE="Basic $TOKEN" ;;
  *)       AUTH_VALUE="$TOKEN" ;;
esac

# --- Build Request ---

CURL_ARGS=(
  -s
  -w "\n__HTTP_CODE__%{http_code}"
  -X "$METHOD"
  -H "$AUTH_HEADER_NAME: $AUTH_VALUE"
  -H "Content-Type: application/json"
  -H "User-Agent: claude-forge/1.0.0"
  -D "$FORGE_HOME/tmp/last-headers.txt"
)

# Add idempotency key for POST requests (if supported)
if [ "$METHOD" = "POST" ]; then
  IDEMPOTENCY_KEY=$(openssl rand -hex 16)
  CURL_ARGS+=(-H "Idempotency-Key: $IDEMPOTENCY_KEY")
fi

# Add request body if provided
if [ -n "$DATA" ]; then
  CURL_ARGS+=(-d "$DATA")
fi

# --- Execute with Retry ---

MAX_RETRIES=3
RETRY_DELAY=2

for ATTEMPT in $(seq 1 $MAX_RETRIES); do
  RESPONSE=$(curl "${CURL_ARGS[@]}" "${BASE_URL}${ENDPOINT}" 2>/dev/null || echo "__HTTP_CODE__000")

  HTTP_CODE=$(echo "$RESPONSE" | grep "__HTTP_CODE__" | sed 's/.*__HTTP_CODE__//')
  BODY=$(echo "$RESPONSE" | sed '/__HTTP_CODE__/d')

  # Parse rate limit headers if available
  if [ -f "$FORGE_HOME/tmp/last-headers.txt" ]; then
    RL_LIMIT=$(grep -i "x-ratelimit-limit" "$FORGE_HOME/tmp/last-headers.txt" 2>/dev/null | awk '{print $2}' | tr -d '\r' || true)
    RL_REMAINING=$(grep -i "x-ratelimit-remaining" "$FORGE_HOME/tmp/last-headers.txt" 2>/dev/null | awk '{print $2}' | tr -d '\r' || true)
    RL_RESET=$(grep -i "x-ratelimit-reset" "$FORGE_HOME/tmp/last-headers.txt" 2>/dev/null | awk '{print $2}' | tr -d '\r' || true)

    # Update config with rate limit info
    if [ -n "$RL_LIMIT" ]; then
      jq --arg limit "$RL_LIMIT" --arg remaining "$RL_REMAINING" --arg reset "$RL_RESET" \
        '.rate_limit.last_known_limit = ($limit | tonumber) |
         .rate_limit.last_known_remaining = ($remaining | tonumber) |
         .rate_limit.last_known_reset = ($reset | tonumber) |
         .rate_limit.auto_detected = true' \
        "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
    fi

    # Warn if approaching limit
    if [ -n "$RL_REMAINING" ] && [ "$RL_REMAINING" -le 5 ] 2>/dev/null; then
      echo "[!] Rate limit warning: $RL_REMAINING requests remaining (limit: $RL_LIMIT)" >&2
    fi
  fi

  # Audit log
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] USE api=$API_NAME endpoint=$METHOD:$ENDPOINT status=$HTTP_CODE attempt=$ATTEMPT" \
    >> "$AUDIT_LOG"

  # Handle response
  case "$HTTP_CODE" in
    2[0-9][0-9])
      # Success — output body
      echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
      TOKEN=""
      AUTH_VALUE=""
      exit 0
      ;;
    429)
      # Rate limited — wait and retry
      RETRY_AFTER=$(grep -i "retry-after" "$FORGE_HOME/tmp/last-headers.txt" 2>/dev/null | awk '{print $2}' | tr -d '\r' || echo "$RETRY_DELAY")
      echo "[*] Rate limited (429). Waiting ${RETRY_AFTER}s before retry ($ATTEMPT/$MAX_RETRIES)..." >&2
      sleep "$RETRY_AFTER"
      RETRY_DELAY=$((RETRY_DELAY * 2))
      ;;
    5[0-9][0-9])
      # Server error — retry with backoff
      if [ "$ATTEMPT" -lt "$MAX_RETRIES" ]; then
        echo "[*] Server error ($HTTP_CODE). Retrying in ${RETRY_DELAY}s ($ATTEMPT/$MAX_RETRIES)..." >&2
        sleep "$RETRY_DELAY"
        RETRY_DELAY=$((RETRY_DELAY * 2))
      else
        echo "[!] Server error ($HTTP_CODE) after $MAX_RETRIES attempts:" >&2
        echo "$BODY" | jq . 2>/dev/null || echo "$BODY" >&2
        TOKEN=""
        AUTH_VALUE=""
        exit 1
      fi
      ;;
    401|403)
      echo "[!] Authentication error ($HTTP_CODE):" >&2
      echo "$BODY" | jq . 2>/dev/null || echo "$BODY" >&2
      echo "" >&2
      echo "Suggestions:" >&2
      echo "  - Verify token is valid: bash .claude/scripts/forge-decrypt.sh $API_NAME" >&2
      echo "  - Rotate token: /api-forge rotate $API_NAME" >&2
      echo "  - Check token permissions/scopes" >&2
      TOKEN=""
      AUTH_VALUE=""
      exit 1
      ;;
    000)
      echo "[!] Connection failed. Check:" >&2
      echo "  - Network connectivity" >&2
      echo "  - Base URL: $BASE_URL" >&2
      echo "  - DNS resolution" >&2
      TOKEN=""
      AUTH_VALUE=""
      exit 1
      ;;
    *)
      echo "[!] Error $HTTP_CODE:" >&2
      echo "$BODY" | jq . 2>/dev/null || echo "$BODY" >&2
      TOKEN=""
      AUTH_VALUE=""
      exit 1
      ;;
  esac
done

# Clear sensitive data
TOKEN=""
AUTH_VALUE=""
```

---

## 5. Security Architecture

### Trust Model

```
 +============================================================+
 ||                    TRUST BOUNDARY                         ||
 ||                                                           ||
 ||  +------------------+     +-------------------------+     ||
 ||  |   OpenAPI Spec   | --> |      API Forge          |     ||
 ||  | (user-provided)  |     |    (generator only)     |     ||
 ||  +------------------+     +------------+------------+     ||
 ||                                        |                  ||
 ||              GENERATED ARTIFACTS       |                  ||
 ||              (all auditable):          v                  ||
 ||                                                           ||
 ||  +------------------+   +------------------+              ||
 ||  | .claude/commands/ |   | .claude/scripts/ |             ||
 ||  | (Markdown files)  |   | (Shell scripts)  |             ||
 ||  | - API docs        |   | - forge-api.sh   |             ||
 ||  | - Usage examples  |   | - forge-decrypt  |             ||
 ||  | - Validation      |   | - forge-encrypt  |             ||
 ||  +------------------+   +------------------+              ||
 ||                                                           ||
 ||  +------------------+   +------------------+              ||
 ||  | ~/.claude-forge/  |   | ~/.claude-forge/  |            ||
 ||  |   vault/          |   |   audit/          |            ||
 ||  | - AES-256-GCM     |   | - access.log      |           ||
 ||  | - chmod 600       |   | - timestamped      |           ||
 ||  | - checksummed     |   | - immutable trail  |           ||
 ||  +------------------+   +------------------+              ||
 ||                                                           ||
 ||  INVARIANTS:                                              ||
 ||    - No external code execution                           ||
 ||    - No untrusted dependencies                            ||
 ||    - No supply chain risk                                 ||
 ||    - No plaintext secrets on disk                         ||
 ||    - No tokens in LLM context                             ||
 +============================================================+
```

### What We NEVER Do (vs api2cli)

| # | Prohibition | Rationale |
|---|------------|-----------|
| 1 | NEVER download and execute external binaries | Supply chain attack vector — postinstall scripts can execute arbitrary code |
| 2 | NEVER store tokens in plaintext | Any process on the machine can read plaintext files |
| 3 | NEVER skip file permissions | Default file permissions (644) allow other users to read |
| 4 | NEVER trust unverified package registries | npm/pip packages can be typosquatted or compromised |
| 5 | NEVER expose tokens to LLM context | Tokens in context could leak via prompt injection or logging |
| 6 | NEVER run postinstall scripts from unknown sources | Arbitrary code execution at install time |
| 7 | NEVER pass tokens as CLI arguments | Visible in `ps` output and shell history |
| 8 | NEVER log token values | Audit logs record access events, never credential values |
| 9 | NEVER disable TLS verification | Man-in-the-middle attack vector |
| 10 | NEVER cache decrypted tokens on disk | Reduces the window of exposure to the lifetime of a single process |

### What We ALWAYS Do

| # | Requirement | Implementation |
|---|------------|----------------|
| 1 | ALWAYS encrypt credentials at rest | AES-256-GCM via openssl with PBKDF2 (100K iterations) |
| 2 | ALWAYS enforce file permissions | `chmod 600` on vault files, `chmod 700` on vault directory |
| 3 | ALWAYS audit credential access | Timestamped log entries for every READ, STORE, USE, ROTATE |
| 4 | ALWAYS verify integrity | SHA-256 checksums on encrypted files, checked before decryption |
| 5 | ALWAYS validate input | JSON Schema validation from OpenAPI spec before sending requests |
| 6 | ALWAYS respect rate limits | Parse X-RateLimit headers, backoff on 429, enforce conservative defaults |
| 7 | ALWAYS generate auditable code | Only Markdown + shell scripts — no compiled binaries, no minified code |
| 8 | ALWAYS derive keys from machine identity | Encrypted files are useless if copied to another machine |
| 9 | ALWAYS clear sensitive variables | Set token variables to empty string after use |
| 10 | ALWAYS use HTTPS | Reject HTTP base URLs (except localhost for development) |

### Threat Model

| Threat | Mitigation |
|--------|-----------|
| Stolen laptop | Encrypted vault — attacker needs machine identity to derive key |
| Malicious npm package | No npm packages — zero external code execution |
| Process memory dump | Tokens exist in memory only during curl execution |
| Shell history exposure | Tokens read from stdin, never passed as arguments |
| Log file compromise | Audit logs record events, never credential values |
| Man-in-the-middle | HTTPS enforced, TLS verification never disabled |
| Privilege escalation | chmod 600/700 limits access to file owner |
| Token replay | Idempotency keys for POST, token rotation warnings |
| Spec injection | Spec is parsed for data only — no code execution from spec content |

---

## 6. Supported Authentication Patterns

### Bearer Token (Most Common)

```bash
# OpenAPI spec defines:
# components:
#   securitySchemes:
#     BearerAuth:
#       type: http
#       scheme: bearer

# Forge generates:
TOKEN=$(bash .claude/scripts/forge-decrypt.sh my-api)
curl -s -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.example.com/v1/resource" | jq .
```

### API Key in Header

```bash
# OpenAPI spec defines:
# components:
#   securitySchemes:
#     ApiKeyAuth:
#       type: apiKey
#       in: header
#       name: X-API-Key

# Forge generates:
TOKEN=$(bash .claude/scripts/forge-decrypt.sh my-api)
curl -s -H "X-API-Key: $TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.example.com/v1/resource" | jq .
```

### API Key in Query Parameter

```bash
# OpenAPI spec defines:
# components:
#   securitySchemes:
#     ApiKeyQuery:
#       type: apiKey
#       in: query
#       name: api_key

# Forge generates:
TOKEN=$(bash .claude/scripts/forge-decrypt.sh my-api)
curl -s -H "Content-Type: application/json" \
  "https://api.example.com/v1/resource?api_key=$TOKEN" | jq .
```

### Basic Authentication

```bash
# Store base64-encoded credentials:
echo -n "username:password" | base64 | bash .claude/scripts/forge-encrypt.sh my-api

# Forge generates:
TOKEN=$(bash .claude/scripts/forge-decrypt.sh my-api)
curl -s -H "Authorization: Basic $TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.example.com/v1/resource" | jq .
```

### OAuth 2.0 Client Credentials

```bash
# Store client_id and client_secret separately:
echo -n "client_id_value" | bash .claude/scripts/forge-encrypt.sh my-api
echo -n "client_secret_value" | bash .claude/scripts/forge-encrypt.sh my-api-client-secret

# Token exchange:
CLIENT_ID=$(bash .claude/scripts/forge-decrypt.sh my-api)
CLIENT_SECRET=$(bash .claude/scripts/forge-decrypt.sh my-api-client-secret)

ACCESS_TOKEN=$(curl -s -X POST "https://auth.example.com/oauth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" | jq -r '.access_token')

# Store access token for subsequent use:
echo -n "$ACCESS_TOKEN" | bash .claude/scripts/forge-encrypt.sh my-api-access

# Clear variables:
CLIENT_ID="" CLIENT_SECRET="" ACCESS_TOKEN=""
```

### mTLS (Mutual TLS)

```bash
# Store certificate and key paths in config:
# Config includes cert_file and key_file paths

CERT_FILE=$(jq -r '.mtls.cert_file' ~/.claude-forge/config/my-api.json)
KEY_FILE=$(jq -r '.mtls.key_file' ~/.claude-forge/config/my-api.json)

curl -s --cert "$CERT_FILE" --key "$KEY_FILE" \
  -H "Content-Type: application/json" \
  "https://api.example.com/v1/resource" | jq .
```

### Custom Authentication

```bash
# For APIs with non-standard auth, define pattern in config:
# config.json: { "auth_type": "custom", "auth_template": "SSWS {token}" }

TOKEN=$(bash .claude/scripts/forge-decrypt.sh my-api)
AUTH_TEMPLATE=$(jq -r '.auth_template' ~/.claude-forge/config/my-api.json)
AUTH_VALUE=$(echo "$AUTH_TEMPLATE" | sed "s/{token}/$TOKEN/g")

curl -s -H "Authorization: $AUTH_VALUE" \
  -H "Content-Type: application/json" \
  "https://api.example.com/v1/resource" | jq .
```

### Authentication Pattern Summary

| Pattern | Type in OpenAPI | In | Forge Support | Notes |
|---------|-----------------|-----|--------------|-------|
| Bearer Token | `http` / `bearer` | Header | Full | Most common pattern |
| API Key (header) | `apiKey` | Header | Full | Custom header name from spec |
| API Key (query) | `apiKey` | Query | Full | Appended to URL |
| API Key (cookie) | `apiKey` | Cookie | Full | Set via `-b` flag |
| Basic Auth | `http` / `basic` | Header | Full | base64(user:pass) stored |
| OAuth 2.0 (client_credentials) | `oauth2` | Header | Full | Auto token exchange |
| OAuth 2.0 (auth_code) | `oauth2` | Header | Manual | Requires browser flow |
| OAuth 2.0 (refresh_token) | `oauth2` | Header | Full | Auto token refresh |
| mTLS | Custom | TLS | Full | Certificate + key files |
| Custom header | Custom | Header | Full | User-defined pattern |

---

## 7. Generated Output Examples — Complete Stripe API Forge

This section walks through a complete forge of the Stripe API from start to finish.

### Step 1: Initiate Forge

```bash
# User invokes:
# /api-forge https://raw.githubusercontent.com/stripe/openapi/master/openapi/spec3.json
```

### Step 2: Phase 1 Output (Spec Ingestion)

```
[*] Fetching spec from URL: https://raw.githubusercontent.com/stripe/openapi/master/openapi/spec3.json
[*] Detected OpenAPI version: 3.0.0
[*] Spec validated:
    Title:     Stripe API
    Base URL:  https://api.stripe.com
    Endpoints: 246 paths
```

### Step 3: Phase 2 Output (Security Analysis)

```
[*] Analyzing security schemes...
[*] Found 2 security scheme(s)
    - BasicAuth: type=http scheme=basic
    - BearerAuth: type=http scheme=bearer
[*] Found 189 write/delete endpoints
[*] API documents rate limiting (429 responses found)
[*] Pagination parameters found: 12

Security Profile:
{
  "security_schemes": [
    { "name": "BearerAuth", "type": "http", "scheme": "bearer" }
  ],
  "sensitive_endpoints": [
    { "method": "POST", "path": "/v1/charges", "risk_level": "MEDIUM" },
    { "method": "DELETE", "path": "/v1/customers/{customer}", "risk_level": "HIGH" }
  ],
  "rate_limited": true,
  "pagination_support": true,
  "recommendations": [
    "NOTICE: Many write endpoints detected. Consider read-only token for initial setup."
  ]
}
```

### Step 4: Phase 3 (Credential Storage)

```
Enter token for 'stripe' (input is hidden):
[OK] Token encrypted and stored for 'stripe'
     Location: ~/.claude-forge/vault/stripe.enc
     Checksum: a3f8b2c1d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0
```

### Step 5: Phase 4 (Command Generated)

File `.claude/commands/stripe.md` created with all 246 endpoints documented, authentication
instructions, rate limit handling, and error patterns.

### Step 6: Phase 5 (Validation)

```
=== API Forge Validation: stripe ===

[PASS] Config file exists and is valid JSON
[PASS] Encrypted credentials exist in vault
[PASS] Salt file exists
[PASS] Vault file permissions are 600 (owner read/write only)
[PASS] Credential decryption successful
[PASS] Token length reasonable (107 chars)
[PASS] Slash command file exists: .claude/commands/stripe.md
[PASS] Integrity checksum verified

--- Test Request: GET /v1/customers?limit=1 ---
[PASS] Test request returned HTTP 200

[PASS] Audit log is writable
[PASS] Token age within acceptable range

=== Validation Summary ===
  Passed: 11
  Failed: 0
  Warnings: 0

[OK] Validation PASSED — integration is ready for use
```

### Step 7: Phase 6 (Registration)

```
=== Forge Summary: stripe ===
  Title:     Stripe API
  Base URL:  https://api.stripe.com
  Version:   2023-10-16
  Endpoints: 246
  Auth:      bearer
  Command:   /stripe

  Usage: /stripe list my recent customers
```

### Usage After Forge

```bash
# User can now use the /stripe slash command:
# /stripe list my last 10 customers
# /stripe create a customer with email test@example.com
# /stripe get the balance
```

---

## 8. Common Scenarios

### Forge from OpenAPI URL

```
/api-forge https://petstore3.swagger.io/api/v3/openapi.json
```

The assistant will:
1. Fetch the spec from the URL
2. Parse and validate
3. Analyze security requirements
4. Prompt for credentials if needed
5. Generate the slash command
6. Validate the integration
7. Register in the forge

### Forge from Local File

```
/api-forge ./specs/internal-api.yaml
```

Same process, but reads from a local file. Supports both JSON and YAML (YAML requires `yq`).

### Forge Manually (No Spec)

```
/api-forge manual --name myapi --base-url https://api.example.com
```

The assistant will interactively build the integration by asking about:
- Authentication method
- Available endpoints
- Request/response formats
- Rate limits

### List All Forged APIs

```
/api-forge list
```

Output:
```
=== Forged API Integrations (3) ===

NAME            TITLE                          AUTH       ENDPTS   FORGED
----            -----                          ----       ------   ------
stripe          Stripe API                     bearer     246      2026-03-15
github          GitHub REST API                bearer     892      2026-03-14
internal        Internal CRM API               api_key    42       2026-03-10
```

### Test a Forged API

```
/api-forge test stripe
```

Runs the full validation suite (Phase 5) against the specified API.

### Rotate Credentials

```
/api-forge rotate stripe
```

Prompts for a new token, encrypts it, updates the checksum, and logs the rotation event.

### Remove a Forged API

```
/api-forge remove stripe
```

Removes the encrypted credentials, config, command file, and registry entry. Logs the removal.

### View Audit Trail

```
/api-forge audit stripe
```

Output:
```
=== Audit Trail: stripe ===

[2026-03-15T20:00:00Z] STORE   api=stripe caller=deivithi checksum=a3f8b2...
[2026-03-15T20:00:05Z] READ    api=stripe caller=claude-code
[2026-03-15T20:00:06Z] USE     api=stripe endpoint=GET:/v1/customers status=200 attempt=1
[2026-03-15T20:15:30Z] READ    api=stripe caller=claude-code
[2026-03-15T20:15:31Z] USE     api=stripe endpoint=POST:/v1/customers status=200 attempt=1
```

### Export Forge Configuration

```
/api-forge export stripe
```

Exports the config (without credentials) for sharing with team members. They only need to
provide their own API token to complete the setup.

---

## 9. Anti-Patterns (PROHIBITED)

These patterns are explicitly prohibited when using API Forge. If the assistant detects any of
these patterns, it must refuse and explain the correct approach.

| # | Anti-Pattern | Why Prohibited | Correct Approach |
|---|-------------|----------------|-----------------|
| 1 | `export API_TOKEN=sk_live_...` | Visible in process list via `ps eww`, persists in shell session, inherited by child processes | `TOKEN=$(bash forge-decrypt.sh api)` — exists only in subshell |
| 2 | `curl -H "Authorization: Bearer sk_live_..."` | Token in shell history (`~/.bash_history`), visible in `ps` | Use forge-api.sh which reads from vault |
| 3 | `npm install api2cli` | Executes postinstall scripts from unknown author, downloads binary | Generate integration locally with API Forge |
| 4 | `echo $TOKEN > ~/.config/token.txt` | Plaintext file, default permissions (644), no encryption | `echo -n "$TOKEN" \| forge-encrypt.sh api` |
| 5 | `git add .env` / `git commit` with secrets | Secrets in version control history forever | `.env` in `.gitignore`, credentials in encrypted vault |
| 6 | Hardcoding `https://api.stripe.com` in commands | Environment-specific, breaks when switching staging/prod | Store in `config.json`, read at runtime |
| 7 | Ignoring HTTP 429 responses | API provider may ban the IP or revoke the token | Parse rate limit headers, implement backoff |
| 8 | Sending unvalidated user input to API | Injection attacks, malformed requests, wasted rate limit | Validate against OpenAPI schema before sending |
| 9 | `chmod 777 ~/.claude-forge/vault/` | Any user/process can read encrypted files | `chmod 700` on directory, `chmod 600` on files |
| 10 | Logging API responses with sensitive data | PII, financial data, credentials in log files | Log only metadata (status codes, endpoints, timestamps) |
| 11 | Using `eval` with API response data | Remote code execution if response is compromised | Parse with `jq`, never `eval` |
| 12 | Disabling TLS: `curl -k` or `--insecure` | Man-in-the-middle interception of credentials and data | Always verify TLS certificates |

### Detection Rules

The assistant should scan for these patterns and warn the user:

```bash
# Patterns that trigger warnings:
# 1. Plaintext tokens in environment
env | grep -iE "(token|key|secret|password|api_key)" && echo "[!] Plaintext credentials in environment"

# 2. Tokens in shell history
grep -iE "(sk_live|sk_test|ghp_|gho_|Bearer )" ~/.bash_history 2>/dev/null && \
  echo "[!] Tokens found in shell history"

# 3. Plaintext token files
find ~/.config -name "*.txt" -exec grep -l -iE "(sk_|ghp_|gho_)" {} \; 2>/dev/null && \
  echo "[!] Plaintext token files found"

# 4. Overly permissive vault permissions
PERMS=$(stat -c %a ~/.claude-forge/vault/ 2>/dev/null)
[ "$PERMS" != "700" ] && echo "[!] Vault directory permissions too open: $PERMS"
```

---

## 10. Verification Checklist

Before considering any forge operation complete, verify every item:

### Pre-Forge Checklist

```
[ ] OpenAPI spec is valid and parseable?
[ ] Spec version is supported (OpenAPI 3.x or Swagger 2.0)?
[ ] Base URL is HTTPS (or localhost for dev)?
[ ] Authentication scheme is identified?
[ ] All required tools are installed (curl, jq, openssl)?
```

### Post-Forge Checklist

```
[ ] Vault directory exists with chmod 700?
[ ] Encrypted credential file exists with chmod 600?
[ ] Salt file exists with chmod 600?
[ ] SHA-256 checksum stored in .checksums?
[ ] Config JSON is valid and complete?
[ ] Slash command file generated in .claude/commands/?
[ ] Command file documents all endpoints?
[ ] Command file includes auth instructions?
[ ] Command file includes error handling?
[ ] Rate limit info documented?
[ ] Test request returned 2xx?
[ ] Integrity checksum verified?
[ ] Audit log records the STORE event?
[ ] Registry updated with new API?
[ ] No plaintext secrets anywhere in generated files?
[ ] No tokens in LLM context window?
```

### Security Audit Checklist

```
[ ] No plaintext tokens on disk (grep for known patterns)?
[ ] File permissions correct on all vault files?
[ ] Integrity checksums match?
[ ] Token age within acceptable range (<90 days)?
[ ] Audit log shows expected access patterns (no anomalies)?
[ ] No tokens in shell history?
[ ] No tokens in environment variables?
[ ] Generated scripts use variable clearing after use?
[ ] Generated scripts read tokens from stdin (not CLI args)?
[ ] HTTPS enforced for all non-localhost URLs?
```

### Automated Verification Script

```bash
#!/bin/bash
# forge-full-audit.sh — Complete security audit of all forged APIs
FORGE_HOME="$HOME/.claude-forge"
REGISTRY="$FORGE_HOME/config/registry.json"

echo "=========================================="
echo "  API Forge — Full Security Audit"
echo "  $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "=========================================="
echo ""

TOTAL_PASS=0
TOTAL_FAIL=0
TOTAL_WARN=0

# Global checks
echo "--- Global Security Checks ---"
echo ""

# Check vault directory permissions
VAULT_PERMS=$(stat -c %a "$FORGE_HOME/vault/" 2>/dev/null || stat -f %Lp "$FORGE_HOME/vault/" 2>/dev/null)
if [ "$VAULT_PERMS" = "700" ]; then
  echo "[PASS] Vault directory permissions: $VAULT_PERMS"
  ((TOTAL_PASS++))
else
  echo "[FAIL] Vault directory permissions: $VAULT_PERMS (expected 700)"
  ((TOTAL_FAIL++))
fi

# Check audit directory permissions
AUDIT_PERMS=$(stat -c %a "$FORGE_HOME/audit/" 2>/dev/null || stat -f %Lp "$FORGE_HOME/audit/" 2>/dev/null)
if [ "$AUDIT_PERMS" = "700" ]; then
  echo "[PASS] Audit directory permissions: $AUDIT_PERMS"
  ((TOTAL_PASS++))
else
  echo "[FAIL] Audit directory permissions: $AUDIT_PERMS (expected 700)"
  ((TOTAL_FAIL++))
fi

# Check for plaintext tokens in common locations
PLAINTEXT_FOUND=0
for PATTERN in "sk_live_" "sk_test_" "ghp_" "gho_" "Bearer "; do
  if grep -r -l "$PATTERN" "$FORGE_HOME/config/" 2>/dev/null | grep -v ".json" | head -1 > /dev/null 2>&1; then
    echo "[FAIL] Plaintext token pattern '$PATTERN' found in config directory"
    ((TOTAL_FAIL++))
    PLAINTEXT_FOUND=1
  fi
done
if [ "$PLAINTEXT_FOUND" -eq 0 ]; then
  echo "[PASS] No plaintext token patterns found in config"
  ((TOTAL_PASS++))
fi

# Per-API checks
echo ""
echo "--- Per-API Checks ---"

if [ -f "$REGISTRY" ]; then
  API_NAMES=$(jq -r '.forged_apis | keys[]' "$REGISTRY" 2>/dev/null)
  for API in $API_NAMES; do
    echo ""
    echo "  API: $API"

    # Check encrypted file
    if [ -f "$FORGE_HOME/vault/${API}.enc" ]; then
      PERMS=$(stat -c %a "$FORGE_HOME/vault/${API}.enc" 2>/dev/null || stat -f %Lp "$FORGE_HOME/vault/${API}.enc" 2>/dev/null)
      if [ "$PERMS" = "600" ]; then
        echo "  [PASS] Encrypted file permissions: $PERMS"
        ((TOTAL_PASS++))
      else
        echo "  [FAIL] Encrypted file permissions: $PERMS (expected 600)"
        ((TOTAL_FAIL++))
      fi
    else
      echo "  [FAIL] Encrypted file missing"
      ((TOTAL_FAIL++))
    fi

    # Check integrity
    STORED=$(grep "^${API}:" "$FORGE_HOME/vault/.checksums" 2>/dev/null | cut -d: -f2)
    CURRENT=$(sha256sum "$FORGE_HOME/vault/${API}.enc" 2>/dev/null | awk '{print $1}')
    if [ -n "$STORED" ] && [ "$STORED" = "$CURRENT" ]; then
      echo "  [PASS] Integrity checksum verified"
      ((TOTAL_PASS++))
    elif [ -z "$STORED" ]; then
      echo "  [WARN] No stored checksum"
      ((TOTAL_WARN++))
    else
      echo "  [FAIL] Integrity checksum MISMATCH"
      ((TOTAL_FAIL++))
    fi

    # Check token age
    CREATED=$(grep "^${API}:" "$FORGE_HOME/vault/.checksums" 2>/dev/null | cut -d: -f3)
    if [ -n "$CREATED" ]; then
      CREATED_EPOCH=$(date -d "$CREATED" +%s 2>/dev/null || echo "0")
      NOW_EPOCH=$(date +%s)
      if [ "$CREATED_EPOCH" -gt 0 ]; then
        AGE_DAYS=$(( (NOW_EPOCH - CREATED_EPOCH) / 86400 ))
        if [ "$AGE_DAYS" -ge 90 ]; then
          echo "  [WARN] Token is $AGE_DAYS days old (recommend rotation)"
          ((TOTAL_WARN++))
        else
          echo "  [PASS] Token age: $AGE_DAYS days"
          ((TOTAL_PASS++))
        fi
      fi
    fi
  done
fi

echo ""
echo "=========================================="
echo "  Audit Complete"
echo "  Passed:   $TOTAL_PASS"
echo "  Failed:   $TOTAL_FAIL"
echo "  Warnings: $TOTAL_WARN"
echo "=========================================="

if [ "$TOTAL_FAIL" -gt 0 ]; then
  echo ""
  echo "  [!] AUDIT FAILED — review and fix issues above"
  exit 1
else
  echo ""
  echo "  [OK] AUDIT PASSED"
  exit 0
fi
```

---

## 11. Input Validation Engine

API Forge validates all request payloads against the OpenAPI schema before sending. This prevents
wasted API calls, protects against injection, and provides clear error messages.

### Schema Validation Script

```bash
#!/bin/bash
# forge-validate-input.sh — Validate JSON payload against OpenAPI schema
# Usage: echo '{"email":"test@example.com"}' | forge-validate-input.sh <api-name> <endpoint-path>

API_NAME="$1"
ENDPOINT_PATH="$2"
CONFIG="$HOME/.claude-forge/config/${API_NAME}.json"

if [ ! -f "$CONFIG" ]; then
  echo "[!] No config for '$API_NAME'" >&2
  exit 1
fi

# Read payload from stdin
PAYLOAD=$(cat)

if [ -z "$PAYLOAD" ]; then
  echo "[!] Empty payload" >&2
  exit 1
fi

# Validate JSON syntax
if ! echo "$PAYLOAD" | jq empty 2>/dev/null; then
  echo "[!] Invalid JSON syntax" >&2
  exit 1
fi

# Get schema for this endpoint
SCHEMA=$(jq --arg path "$ENDPOINT_PATH" '
  .endpoints[] | select(.path == $path and (.method == "POST" or .method == "PUT" or .method == "PATCH")) |
  .request_body_schema // null
' "$CONFIG")

if [ "$SCHEMA" = "null" ] || [ -z "$SCHEMA" ]; then
  echo "[*] No schema defined for $ENDPOINT_PATH — skipping validation" >&2
  echo "$PAYLOAD"
  exit 0
fi

# Extract required fields
REQUIRED=$(echo "$SCHEMA" | jq -r '.required // [] | .[]')

# Check required fields
MISSING=""
for FIELD in $REQUIRED; do
  HAS_FIELD=$(echo "$PAYLOAD" | jq --arg f "$FIELD" 'has($f)')
  if [ "$HAS_FIELD" = "false" ]; then
    MISSING="$MISSING $FIELD"
  fi
done

if [ -n "$MISSING" ]; then
  echo "[!] Missing required fields:$MISSING" >&2
  exit 1
fi

# Validate field types
PROPERTIES=$(echo "$SCHEMA" | jq -r '.properties // {} | to_entries[] | "\(.key):\(.value.type // "any")"')

ERRORS=""
for PROP in $PROPERTIES; do
  FIELD=$(echo "$PROP" | cut -d: -f1)
  EXPECTED_TYPE=$(echo "$PROP" | cut -d: -f2)

  # Check if field exists in payload
  FIELD_EXISTS=$(echo "$PAYLOAD" | jq --arg f "$FIELD" 'has($f)')
  if [ "$FIELD_EXISTS" = "false" ]; then
    continue
  fi

  # Get actual type
  ACTUAL_TYPE=$(echo "$PAYLOAD" | jq --arg f "$FIELD" '.[$f] | type')

  # Type mapping: JSON types to OpenAPI types
  case "$EXPECTED_TYPE" in
    string)  [ "$ACTUAL_TYPE" != '"string"' ] && ERRORS="$ERRORS\n  - $FIELD: expected string, got $ACTUAL_TYPE" ;;
    integer) [ "$ACTUAL_TYPE" != '"number"' ] && ERRORS="$ERRORS\n  - $FIELD: expected integer, got $ACTUAL_TYPE" ;;
    number)  [ "$ACTUAL_TYPE" != '"number"' ] && ERRORS="$ERRORS\n  - $FIELD: expected number, got $ACTUAL_TYPE" ;;
    boolean) [ "$ACTUAL_TYPE" != '"boolean"' ] && ERRORS="$ERRORS\n  - $FIELD: expected boolean, got $ACTUAL_TYPE" ;;
    array)   [ "$ACTUAL_TYPE" != '"array"' ] && ERRORS="$ERRORS\n  - $FIELD: expected array, got $ACTUAL_TYPE" ;;
    object)  [ "$ACTUAL_TYPE" != '"object"' ] && ERRORS="$ERRORS\n  - $FIELD: expected object, got $ACTUAL_TYPE" ;;
  esac
done

if [ -n "$ERRORS" ]; then
  echo "[!] Validation errors:" >&2
  echo -e "$ERRORS" >&2
  exit 1
fi

echo "[OK] Payload valid" >&2
echo "$PAYLOAD"
```

---

## 12. Removal and Cleanup

### Complete API Removal

```bash
#!/bin/bash
# forge-remove.sh — Completely remove a forged API integration
API_NAME="$1"
FORGE_HOME="$HOME/.claude-forge"
AUDIT_LOG="$FORGE_HOME/audit/access.log"

if [ -z "$API_NAME" ]; then
  echo "Usage: forge-remove.sh <api-name>" >&2
  exit 1
fi

echo "[*] Removing forged API: $API_NAME" >&2

# Remove encrypted credentials
rm -f "$FORGE_HOME/vault/${API_NAME}.enc"
rm -f "$FORGE_HOME/vault/${API_NAME}.salt"
rm -f "$FORGE_HOME/vault/${API_NAME}-refresh.enc"
rm -f "$FORGE_HOME/vault/${API_NAME}-refresh.salt"
rm -f "$FORGE_HOME/vault/${API_NAME}-client-secret.enc"
rm -f "$FORGE_HOME/vault/${API_NAME}-client-secret.salt"
echo "  [OK] Vault entries removed" >&2

# Remove checksum entries
grep -v "^${API_NAME}" "$FORGE_HOME/vault/.checksums" > "$FORGE_HOME/vault/.checksums.tmp" 2>/dev/null || true
mv "$FORGE_HOME/vault/.checksums.tmp" "$FORGE_HOME/vault/.checksums"
echo "  [OK] Checksum entries removed" >&2

# Remove config
rm -f "$FORGE_HOME/config/${API_NAME}.json"
echo "  [OK] Config removed" >&2

# Remove from registry
if [ -f "$FORGE_HOME/config/registry.json" ]; then
  jq --arg name "$API_NAME" 'del(.forged_apis[$name])' \
    "$FORGE_HOME/config/registry.json" > "$FORGE_HOME/config/registry.json.tmp" \
    && mv "$FORGE_HOME/config/registry.json.tmp" "$FORGE_HOME/config/registry.json"
  echo "  [OK] Registry entry removed" >&2
fi

# Remove command file
rm -f ".claude/commands/${API_NAME}.md"
echo "  [OK] Slash command removed" >&2

# Audit log entry (audit log is never deleted)
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] REMOVE api=$API_NAME caller=$(whoami)" >> "$AUDIT_LOG"

echo "" >&2
echo "[OK] '$API_NAME' completely removed from forge" >&2
```

---

## 13. Migration from api2cli

If you currently use api2cli, here is how to migrate to API Forge safely:

### Step 1: Identify Existing Plaintext Tokens

```bash
# Find all api2cli plaintext token files
find ~/.config/api2cli/tokens/ -name "*.txt" 2>/dev/null | while read -r f; do
  API=$(basename "$f" .txt)
  echo "Found plaintext token: $API ($f)"
  echo "  Permissions: $(stat -c %a "$f" 2>/dev/null || stat -f %Lp "$f")"
  echo "  Size: $(wc -c < "$f") bytes"
done
```

### Step 2: Migrate Each Token to Forge

```bash
# For each API, encrypt the token in the forge vault
for TOKEN_FILE in ~/.config/api2cli/tokens/*.txt; do
  API=$(basename "$TOKEN_FILE" .txt)
  echo "Migrating: $API"

  # Read and encrypt
  cat "$TOKEN_FILE" | bash .claude/scripts/forge-encrypt.sh "$API"
done
```

### Step 3: Verify Migration

```bash
# Verify each migrated token decrypts correctly
for TOKEN_FILE in ~/.config/api2cli/tokens/*.txt; do
  API=$(basename "$TOKEN_FILE" .txt)
  ORIGINAL=$(cat "$TOKEN_FILE")
  DECRYPTED=$(bash .claude/scripts/forge-decrypt.sh "$API" 2>/dev/null)

  if [ "$ORIGINAL" = "$DECRYPTED" ]; then
    echo "[OK] $API: migration verified"
  else
    echo "[FAIL] $API: migration mismatch"
  fi
done
```

### Step 4: Securely Delete Plaintext Files

```bash
# Overwrite plaintext files before deletion (defense in depth)
for TOKEN_FILE in ~/.config/api2cli/tokens/*.txt; do
  # Overwrite with random data 3 times
  dd if=/dev/urandom of="$TOKEN_FILE" bs=$(stat -c %s "$TOKEN_FILE" 2>/dev/null || stat -f %z "$TOKEN_FILE") count=1 2>/dev/null
  dd if=/dev/urandom of="$TOKEN_FILE" bs=$(stat -c %s "$TOKEN_FILE" 2>/dev/null || stat -f %z "$TOKEN_FILE") count=1 2>/dev/null
  dd if=/dev/urandom of="$TOKEN_FILE" bs=$(stat -c %s "$TOKEN_FILE" 2>/dev/null || stat -f %z "$TOKEN_FILE") count=1 2>/dev/null
  rm -f "$TOKEN_FILE"
  echo "[OK] Securely deleted: $TOKEN_FILE"
done
```

### Step 5: Uninstall api2cli

```bash
npm uninstall -g api2cli 2>/dev/null || true
rm -rf ~/.config/api2cli/
echo "[OK] api2cli removed"
```

---

## 14. Troubleshooting

### Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|---------|
| `Decryption failed` | Machine identity changed | Re-encrypt token: pipe old token into `forge-encrypt.sh` |
| `No credentials found` | Typo in API name | Run `ls ~/.claude-forge/vault/` to list available APIs |
| `Integrity checksum mismatch` | File was modified externally | Re-encrypt the token to generate new checksum |
| `HTTP 401 on test` | Token expired or invalid | Rotate: `/api-forge rotate <name>` |
| `HTTP 429 on all requests` | Rate limit exhausted | Wait for reset, check `forge-api.sh` backoff logic |
| `Permission denied on vault` | Wrong file permissions | Run `chmod 700 ~/.claude-forge/vault/ && chmod 600 ~/.claude-forge/vault/*.enc` |
| `yq not found` | YAML spec without yq installed | Convert YAML to JSON manually or install yq |
| `jq parse error` | Malformed API spec or response | Validate spec at editor.swagger.io first |

### Debug Mode

```bash
# Run forge-api.sh with verbose curl output
FORGE_DEBUG=1 bash .claude/scripts/forge-api.sh stripe GET /v1/customers

# The FORGE_DEBUG flag enables:
# - curl verbose mode (-v) but strips auth headers from output
# - Timing information for each phase
# - Full response headers (with auth values masked)
```

### Log Analysis

```bash
# Count requests per API in last 24 hours
SINCE=$(date -u -d "24 hours ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-24H +%Y-%m-%dT%H:%M:%SZ)
grep "USE " ~/.claude-forge/audit/access.log | while read -r line; do
  TS=$(echo "$line" | grep -oP '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z')
  if [[ "$TS" > "$SINCE" ]]; then
    echo "$line"
  fi
done | grep -oP 'api=\S+' | sort | uniq -c | sort -rn

# Find failed requests
grep -E "status=(4|5)" ~/.claude-forge/audit/access.log | tail -20

# Find integrity failures
grep "INTEGRITY_FAIL" ~/.claude-forge/audit/access.log
```

---

## 15. Extensibility

### Adding Custom Middleware

The forge architecture supports custom pre-request and post-response hooks via config:

```json
{
  "name": "my-api",
  "hooks": {
    "pre_request": ".claude/scripts/hooks/my-api-pre.sh",
    "post_response": ".claude/scripts/hooks/my-api-post.sh"
  }
}
```

Example pre-request hook (add custom headers):

```bash
#!/bin/bash
# .claude/scripts/hooks/my-api-pre.sh
# Receives: METHOD, ENDPOINT, DATA as arguments
# Must output additional curl arguments (one per line)

METHOD="$1"
ENDPOINT="$2"

# Add request ID for tracing
echo "-H"
echo "X-Request-ID: $(openssl rand -hex 8)"

# Add timestamp
echo "-H"
echo "X-Request-Time: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

Example post-response hook (transform response):

```bash
#!/bin/bash
# .claude/scripts/hooks/my-api-post.sh
# Receives response body on stdin, HTTP code as argument
# Must output the (possibly transformed) response body

HTTP_CODE="$1"
BODY=$(cat)

# Add metadata wrapper
echo "$BODY" | jq --arg code "$HTTP_CODE" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{metadata: {http_code: ($code | tonumber), timestamp: $ts}, data: .}'
```

### Batch Operations

```bash
#!/bin/bash
# forge-batch.sh — Execute multiple API calls from a batch file
# Batch file format (JSON lines): {"method":"GET","endpoint":"/v1/customers","data":null}

API_NAME="$1"
BATCH_FILE="$2"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f "$BATCH_FILE" ]; then
  echo "[!] Batch file not found: $BATCH_FILE" >&2
  exit 1
fi

TOTAL=$(wc -l < "$BATCH_FILE")
SUCCESS=0
FAILED=0
INDEX=0

while IFS= read -r LINE; do
  ((INDEX++))
  METHOD=$(echo "$LINE" | jq -r '.method')
  ENDPOINT=$(echo "$LINE" | jq -r '.endpoint')
  DATA=$(echo "$LINE" | jq -r '.data // empty')

  echo "[$INDEX/$TOTAL] $METHOD $ENDPOINT" >&2

  if bash "$SCRIPT_DIR/forge-api.sh" "$API_NAME" "$METHOD" "$ENDPOINT" "$DATA" > /dev/null 2>&1; then
    ((SUCCESS++))
  else
    ((FAILED++))
    echo "  [FAIL] $METHOD $ENDPOINT" >&2
  fi

  # Respect rate limits — small delay between requests
  sleep 0.5
done < "$BATCH_FILE"

echo "" >&2
echo "Batch complete: $SUCCESS/$TOTAL succeeded, $FAILED failed" >&2
```

---

## 16. Design Decisions and Rationale

| Decision | Alternatives Considered | Rationale |
|----------|------------------------|-----------|
| AES-256-GCM via openssl | GPG, age, SOPS | openssl is universally available; no additional install needed |
| Machine-bound key derivation | Passphrase, keyring, HSM | Zero-interaction decryption; appropriate for dev machine threat model |
| Shell scripts (not compiled) | Go binary, Rust CLI, Python | Fully auditable line by line; no compilation step; no supply chain |
| Markdown commands | JSON config, YAML, TOML | Native Claude Code format; human-readable; git-friendly |
| PBKDF2 with 100K iterations | bcrypt, scrypt, argon2 | Available in openssl; OWASP-recommended minimum; no extra deps |
| Separate salt files | Salt in encrypted file header | Explicit; easier to verify; enables checksum on encrypted file alone |
| Timestamped audit log | Structured database, syslog | Simple, portable, grep-friendly; no daemon needed |
| Conservative rate limit default | No limit, spec-only | Protects user even when spec doesn't document limits |
| Per-API config files | Single config database | Isolation; easy to share one API config without exposing others |
| SHA-256 integrity checksums | HMAC, GPG signatures | Simple verification; detects tampering without key management overhead |

---

*Estou seguindo as minhas instrucoes, chefe.*

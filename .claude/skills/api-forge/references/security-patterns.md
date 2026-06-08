# API Forge — Security Patterns Reference

> Comprehensive security architecture for bash-native API integration.
> Every pattern maps to a real threat model and includes working implementation.

**OWASP API Security Top 10 (2023) Coverage Index:**

| OWASP ID | Name | Sections |
|----------|------|----------|
| API1 | Broken Object Level Authorization | §4, §5 |
| API2 | Broken Authentication | §1, §8 |
| API3 | Broken Object Property Level Authorization | §4, §5 |
| API4 | Unrestricted Resource Consumption | §6, §7 |
| API5 | Broken Function Level Authorization | §4, §10 |
| API6 | Unrestricted Access to Sensitive Business Flows | §6, §12 |
| API7 | Server Side Request Forgery | §9, §10 |
| API8 | Security Misconfiguration | §2, §3, §9 |
| API9 | Improper Inventory Management | §3, §8 |
| API10 | Unsafe Consumption of APIs | §10, §11 |

---

## §1 — Credential Encryption

### Threat Model

**Attack:** An attacker gains read access to the filesystem (via backup exposure, shared
hosting, misconfigured permissions, or malware) and extracts plaintext API keys, tokens,
and secrets stored in configuration files.

**Impact:** Full account takeover of every integrated API service. Lateral movement across
connected systems. Data exfiltration at scale.

**OWASP Mapping:** API2 — Broken Authentication.

### Implementation

```bash
#!/usr/bin/env bash
# credential_vault.sh — AES-256-GCM encryption with PBKDF2 key derivation
# Requires: openssl >= 1.1.1

set -euo pipefail

VAULT_DIR="${API_FORGE_VAULT:-$HOME/.api-forge/vault}"
VAULT_FILE="$VAULT_DIR/credentials.enc"
SALT_FILE="$VAULT_DIR/.salt"
KEY_ITERATIONS=600000  # NIST SP 800-132 recommendation for PBKDF2

# --- Machine-Bound Key Derivation ---
# Combines a user passphrase with machine-specific entropy so the vault
# cannot be decrypted on a different host even if copied.

derive_machine_fingerprint() {
    local parts=""
    # Hostname component
    parts+="$(hostname 2>/dev/null || echo 'unknown')"
    # Machine ID (Linux)
    if [[ -f /etc/machine-id ]]; then
        parts+="$(cat /etc/machine-id)"
    # Machine UUID (macOS)
    elif command -v ioreg &>/dev/null; then
        parts+="$(ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/{print $3}' | tr -d '"')"
    fi
    # User UID as additional entropy
    parts+="$(id -u 2>/dev/null || echo '1000')"
    printf '%s' "$parts" | openssl dgst -sha256 -binary | base64
}

generate_salt() {
    openssl rand -hex 32 > "$SALT_FILE"
    chmod 0400 "$SALT_FILE"
}

derive_key() {
    local passphrase="$1"
    local salt
    salt="$(cat "$SALT_FILE")"
    local machine_fp
    machine_fp="$(derive_machine_fingerprint)"
    # Combine passphrase + machine fingerprint
    local combined="${passphrase}:${machine_fp}"
    # PBKDF2 derivation: 256-bit key + 96-bit IV for AES-256-GCM
    printf '%s' "$combined" | openssl enc -aes-256-cbc -pbkdf2 \
        -iter "$KEY_ITERATIONS" -S "$salt" -P -pass stdin 2>/dev/null \
        | grep 'key=' | cut -d= -f2
}

# --- Encrypt a credential ---
vault_encrypt() {
    local service_name="$1"
    local credential_value="$2"
    local passphrase="$3"

    [[ ! -f "$SALT_FILE" ]] && generate_salt

    local key
    key="$(derive_key "$passphrase")"
    local iv
    iv="$(openssl rand -hex 12)"
    local timestamp
    timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

    # Build JSON payload with metadata
    local payload
    payload=$(printf '{"service":"%s","value":"%s","stored_at":"%s","host":"%s"}' \
        "$service_name" "$credential_value" "$timestamp" "$(hostname)")

    # Encrypt with AES-256-GCM (OpenSSL 1.1.1+)
    local encrypted
    encrypted=$(printf '%s' "$payload" | openssl enc -aes-256-gcm \
        -K "$key" -iv "$iv" -nosalt -base64 2>/dev/null)

    # Store as: iv:ciphertext
    printf '%s:%s\n' "$iv" "$encrypted" >> "$VAULT_FILE"
    chmod 0600 "$VAULT_FILE"

    # Zero out variables containing secrets
    key="REDACTED"
    credential_value="REDACTED"
    unset key credential_value
}

# --- Decrypt a credential ---
vault_decrypt() {
    local line_number="$1"
    local passphrase="$2"

    local key
    key="$(derive_key "$passphrase")"
    local entry
    entry=$(sed -n "${line_number}p" "$VAULT_FILE")
    local iv="${entry%%:*}"
    local ciphertext="${entry#*:}"

    printf '%s' "$ciphertext" | base64 -d | openssl enc -aes-256-gcm -d \
        -K "$key" -iv "$iv" -nosalt 2>/dev/null

    key="REDACTED"
    unset key
}
```

### Verification

```bash
# Test: encrypt then decrypt, verify roundtrip
test_vault_roundtrip() {
    local test_secret="sk-test-$(openssl rand -hex 16)"
    local test_pass="test-passphrase-$$"

    vault_encrypt "test-service" "$test_secret" "$test_pass"
    local decrypted
    decrypted=$(vault_decrypt 1 "$test_pass")

    local recovered
    recovered=$(printf '%s' "$decrypted" | jq -r '.value')

    if [[ "$recovered" == "$test_secret" ]]; then
        echo "PASS: Roundtrip encryption works"
    else
        echo "FAIL: Decrypted value does not match"
        return 1
    fi

    # Test: wrong passphrase must fail
    if vault_decrypt 1 "wrong-passphrase" 2>/dev/null; then
        echo "FAIL: Decryption succeeded with wrong passphrase"
        return 1
    else
        echo "PASS: Wrong passphrase correctly rejected"
    fi
}
```

### Common Mistakes

1. **Using `echo` instead of `printf`** — `echo` may add trailing newlines, corrupting ciphertext.
2. **Hardcoding the passphrase in scripts** — Defeats the entire purpose. Use `read -rs` for interactive entry or a secure environment variable injected by a secrets manager.
3. **Skipping machine binding** — Without it, a stolen vault file can be brute-forced offline on any machine.
4. **Low PBKDF2 iterations** — Below 100,000 is trivially brute-forceable on modern GPUs. Use 600,000+.
5. **Not zeroing variables** — Bash cannot truly zero memory, but unsetting and overwriting reduces window of exposure in `/proc/*/environ`.

---

## §2 — File Permission Model

### Threat Model

**Attack:** Other users on a shared system, or malware running under the same user but
different process, read credential files, tamper with configs, or delete audit logs.

**Impact:** Secret exfiltration, configuration poisoning (redirect API calls to attacker
endpoints), audit trail destruction.

**OWASP Mapping:** API8 — Security Misconfiguration.

### Implementation

```bash
#!/usr/bin/env bash
# permissions.sh — Enforce strict file permission model

set -euo pipefail

API_FORGE_HOME="${API_FORGE_HOME:-$HOME/.api-forge}"

# Directory structure and permission map
declare -A DIR_PERMS=(
    ["$API_FORGE_HOME"]="0700"
    ["$API_FORGE_HOME/vault"]="0700"
    ["$API_FORGE_HOME/config"]="0750"
    ["$API_FORGE_HOME/audit"]="0750"
    ["$API_FORGE_HOME/cache"]="0700"
    ["$API_FORGE_HOME/tmp"]="0700"
)

declare -A FILE_PERMS=(
    ["vault/*.enc"]="0600"       # Encrypted credentials — owner read/write only
    ["vault/.salt"]="0400"       # Salt — owner read only, immutable after creation
    ["config/*.yaml"]="0640"     # Config — owner rw, group read
    ["audit/*.jsonl"]="0640"     # Audit logs — owner rw, group read
    ["audit/*.jsonl.sig"]="0440" # Signed audit logs — read only
)

initialize_directory_structure() {
    for dir in "${!DIR_PERMS[@]}"; do
        mkdir -p "$dir"
        chmod "${DIR_PERMS[$dir]}" "$dir"
    done
    # Set sticky bit on audit directory to prevent deletion by non-owners
    chmod +t "$API_FORGE_HOME/audit"
}

enforce_permissions() {
    local violations=0

    for dir in "${!DIR_PERMS[@]}"; do
        local expected="${DIR_PERMS[$dir]}"
        local actual
        actual=$(stat -c '%a' "$dir" 2>/dev/null || stat -f '%Lp' "$dir" 2>/dev/null)
        if [[ "$actual" != "${expected#0}" ]]; then
            echo "VIOLATION: $dir has $actual, expected $expected"
            chmod "$expected" "$dir"
            ((violations++))
        fi
    done

    # Check for world-readable files in vault
    local exposed
    exposed=$(find "$API_FORGE_HOME/vault" -perm -o=r 2>/dev/null | head -5)
    if [[ -n "$exposed" ]]; then
        echo "CRITICAL: World-readable files in vault:"
        echo "$exposed"
        find "$API_FORGE_HOME/vault" -perm -o=r -exec chmod o-rwx {} \;
        ((violations++))
    fi

    echo "Permission audit complete. Violations found and fixed: $violations"
    return $violations
}

# Secure temp file creation — never use /tmp for secrets
secure_tempfile() {
    local tmpfile
    tmpfile=$(mktemp "$API_FORGE_HOME/tmp/forge.XXXXXXXX")
    chmod 0600 "$tmpfile"
    # Register cleanup trap
    trap "rm -f '$tmpfile'" EXIT
    echo "$tmpfile"
}
```

### Verification

```bash
verify_permissions() {
    echo "=== Permission Verification ==="
    # No world-readable files in forge home
    local world_readable
    world_readable=$(find "$API_FORGE_HOME" -perm -o=r -type f 2>/dev/null | wc -l)
    [[ "$world_readable" -eq 0 ]] && echo "PASS: No world-readable files" \
                                    || echo "FAIL: $world_readable world-readable files"

    # Vault directory not accessible by group
    local vault_perms
    vault_perms=$(stat -c '%a' "$API_FORGE_HOME/vault" 2>/dev/null || echo "???")
    [[ "$vault_perms" == "700" ]] && echo "PASS: Vault dir is 700" \
                                   || echo "FAIL: Vault dir is $vault_perms"

    # Sticky bit on audit
    [[ -k "$API_FORGE_HOME/audit" ]] && echo "PASS: Sticky bit on audit dir" \
                                       || echo "FAIL: No sticky bit on audit dir"
}
```

### Common Mistakes

1. **Using `umask 000`** — Creates world-readable files. Always set `umask 077` at script start.
2. **Storing temp files in `/tmp`** — Shared space, visible to all users. Use a private temp dir.
3. **Not setting sticky bit on audit** — Allows deletion of individual log files without deleting the directory.
4. **Forgetting to check permissions on the parent directory** — 0600 on a file means nothing if its parent is 0777.

---

## §3 — Audit Logging

### Threat Model

**Attack:** An attacker (or insider) makes unauthorized API calls and there is no forensic
trail. Alternatively, an attacker modifies logs to cover their tracks.

**Impact:** Inability to detect breach, inability to perform incident response, compliance
violations (SOC 2, ISO 27001, LGPD).

**OWASP Mapping:** API8 — Security Misconfiguration, API9 — Improper Inventory Management.

### Implementation

```bash
#!/usr/bin/env bash
# audit.sh — Structured append-only audit logging with integrity verification

set -euo pipefail

AUDIT_DIR="${API_FORGE_HOME:-$HOME/.api-forge}/audit"
AUDIT_FILE="$AUDIT_DIR/api-forge-$(date -u +%Y-%m).jsonl"
AUDIT_HMAC_KEY_FILE="$AUDIT_DIR/.hmac-key"

# Initialize HMAC key for log integrity
init_audit_hmac() {
    if [[ ! -f "$AUDIT_HMAC_KEY_FILE" ]]; then
        openssl rand -hex 32 > "$AUDIT_HMAC_KEY_FILE"
        chmod 0400 "$AUDIT_HMAC_KEY_FILE"
    fi
}

# Core logging function — structured JSONL format
audit_log() {
    local event_type="$1"    # api_call | auth | config_change | error | rotation
    local service="$2"       # github | openai | stripe | etc.
    local action="$3"        # GET /repos | POST /completions | etc.
    local status="$4"        # success | failure | rate_limited | timeout
    local details="${5:-}"   # Additional JSON object (no secrets!)

    local timestamp
    timestamp="$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)"
    local session_id="${API_FORGE_SESSION_ID:-$(openssl rand -hex 8)}"

    # Build log entry
    local entry
    entry=$(jq -cn \
        --arg ts "$timestamp" \
        --arg sid "$session_id" \
        --arg et "$event_type" \
        --arg svc "$service" \
        --arg act "$action" \
        --arg st "$status" \
        --arg usr "$(whoami)" \
        --arg pid "$$" \
        --argjson det "${details:-null}" \
        '{
            timestamp: $ts,
            session_id: $sid,
            event_type: $et,
            service: $svc,
            action: $act,
            status: $st,
            user: $usr,
            pid: ($pid | tonumber),
            details: $det
        }')

    # Compute HMAC for tamper detection
    local hmac
    hmac=$(printf '%s' "$entry" | openssl dgst -sha256 -hmac "$(cat "$AUDIT_HMAC_KEY_FILE")" -hex 2>/dev/null | awk '{print $NF}')

    # Append entry + HMAC
    local signed_entry
    signed_entry=$(printf '%s' "$entry" | jq -c --arg h "$hmac" '. + {hmac: $h}')

    printf '%s\n' "$signed_entry" >> "$AUDIT_FILE"
}

# What to log — every security-relevant event:
#
# MUST LOG:
#   - Every API call (method, endpoint, status code, latency)
#   - Authentication events (token used, success/failure)
#   - Configuration changes (which setting, old value hash, new value hash)
#   - Credential access (vault decrypt, rotation, creation)
#   - Rate limit encounters (service, limit, remaining, reset time)
#   - Errors (status code, error class, retry decision)
#
# NEVER LOG:
#   - Token values, API keys, passwords
#   - Request/response bodies containing PII
#   - Full URLs with query parameters containing secrets

# Verify log integrity
audit_verify() {
    local file="${1:-$AUDIT_FILE}"
    local hmac_key
    hmac_key="$(cat "$AUDIT_HMAC_KEY_FILE")"
    local total=0
    local valid=0
    local tampered=0

    while IFS= read -r line; do
        ((total++))
        local stored_hmac
        stored_hmac=$(printf '%s' "$line" | jq -r '.hmac')
        local entry_without_hmac
        entry_without_hmac=$(printf '%s' "$line" | jq -c 'del(.hmac)')
        local computed_hmac
        computed_hmac=$(printf '%s' "$entry_without_hmac" | openssl dgst -sha256 -hmac "$hmac_key" -hex 2>/dev/null | awk '{print $NF}')

        if [[ "$stored_hmac" == "$computed_hmac" ]]; then
            ((valid++))
        else
            ((tampered++))
            echo "TAMPERED: Line $total"
        fi
    done < "$file"

    echo "Audit verification: $total entries, $valid valid, $tampered tampered"
    [[ "$tampered" -eq 0 ]] && return 0 || return 1
}

# Retention policy — compress logs older than 30 days, delete after 365
audit_rotate() {
    find "$AUDIT_DIR" -name '*.jsonl' -mtime +30 ! -name '*.gz' \
        -exec gzip -9 {} \;
    find "$AUDIT_DIR" -name '*.jsonl.gz' -mtime +365 -delete
    audit_log "config_change" "system" "audit_rotate" "success" \
        '{"action":"log_rotation"}'
}
```

### Verification

```bash
test_audit_logging() {
    init_audit_hmac
    audit_log "api_call" "github" "GET /repos" "success" '{"latency_ms":142}'
    audit_log "auth" "openai" "token_validate" "failure" '{"reason":"expired"}'

    # Verify entries exist
    local count
    count=$(wc -l < "$AUDIT_FILE")
    [[ "$count" -ge 2 ]] && echo "PASS: Audit entries written" \
                           || echo "FAIL: Expected 2+ entries, got $count"

    # Verify integrity
    audit_verify && echo "PASS: Integrity check" || echo "FAIL: Integrity check"

    # Verify no secrets in logs
    if grep -qiE '(sk-|ghp_|token|password|secret|key)' "$AUDIT_FILE" 2>/dev/null; then
        echo "WARNING: Possible secret in audit log — investigate"
    else
        echo "PASS: No obvious secrets in logs"
    fi
}
```

### Common Mistakes

1. **Logging the full Authorization header** — Contains the bearer token. Log only a hash or last 4 chars.
2. **Not using append-only semantics** — Opening with `>` instead of `>>` truncates the log.
3. **No integrity verification** — Without HMAC, an attacker can silently modify log entries.
4. **Logging to stdout in production** — Audit logs must persist to disk, not just terminal output.

---

## §4 — Input Validation

### Threat Model

**Attack:** Malformed or malicious input is passed to API calls, causing injection attacks
(command injection via URL parameters, JSON injection, header injection) or triggering
unexpected behavior in downstream APIs.

**Impact:** Remote code execution, data exfiltration, privilege escalation via the API
provider, SSRF if URLs are user-controlled.

**OWASP Mapping:** API1 — BOLA, API3 — Broken Object Property Level Authorization,
API5 — Broken Function Level Authorization.

### Implementation

```bash
#!/usr/bin/env bash
# validation.sh — Input validation using JSON Schema from OpenAPI specs

set -euo pipefail

# Validate a JSON payload against a JSON Schema extracted from an OpenAPI spec
# Requires: jq, ajv-cli (npm install -g ajv-cli) or python3 with jsonschema
validate_json_payload() {
    local schema_file="$1"
    local payload="$2"

    # Method 1: Using python3 jsonschema (more commonly available)
    if command -v python3 &>/dev/null; then
        python3 -c "
import json, sys
try:
    from jsonschema import validate, ValidationError
    schema = json.load(open('$schema_file'))
    data = json.loads('$payload')
    validate(instance=data, schema=schema)
    print('VALID')
except ValidationError as e:
    print(f'INVALID: {e.message}')
    sys.exit(1)
except Exception as e:
    print(f'ERROR: {e}')
    sys.exit(2)
"
        return $?
    fi

    # Method 2: Lightweight jq-based validation for simple schemas
    echo "WARNING: No jsonschema available, falling back to basic jq checks"
    printf '%s' "$payload" | jq empty 2>/dev/null
    return $?
}

# Validate URL — prevent SSRF and injection
validate_url() {
    local url="$1"
    local allowed_hosts="$2"  # comma-separated: "api.github.com,api.openai.com"

    # Reject non-HTTPS (except localhost for dev)
    if [[ ! "$url" =~ ^https:// ]] && [[ ! "$url" =~ ^http://localhost ]]; then
        echo "REJECT: Non-HTTPS URL"
        return 1
    fi

    # Extract hostname
    local host
    host=$(printf '%s' "$url" | sed -E 's|^https?://([^/:]+).*|\1|')

    # Reject IP addresses (prevent SSRF to internal networks)
    if [[ "$host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "REJECT: IP address not allowed (SSRF prevention)"
        return 1
    fi

    # Reject private/internal hostnames
    if [[ "$host" =~ ^(localhost|127\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|169\.254\.) ]]; then
        echo "REJECT: Internal/private address (SSRF prevention)"
        return 1
    fi

    # Allowlist check
    local found=0
    IFS=',' read -ra HOSTS <<< "$allowed_hosts"
    for allowed in "${HOSTS[@]}"; do
        if [[ "$host" == "$allowed" ]]; then
            found=1
            break
        fi
    done

    if [[ "$found" -eq 0 ]]; then
        echo "REJECT: Host '$host' not in allowlist"
        return 1
    fi

    echo "VALID"
    return 0
}

# Validate HTTP headers — prevent header injection
validate_header() {
    local header_name="$1"
    local header_value="$2"

    # Reject newlines (HTTP header injection / response splitting)
    if [[ "$header_value" =~ $'\n' ]] || [[ "$header_value" =~ $'\r' ]]; then
        echo "REJECT: Header value contains newline (injection attempt)"
        return 1
    fi

    # Reject null bytes
    if [[ "$header_value" == *$'\0'* ]]; then
        echo "REJECT: Header value contains null byte"
        return 1
    fi

    # Header name must be alphanumeric + hyphens only
    if [[ ! "$header_name" =~ ^[a-zA-Z][a-zA-Z0-9-]*$ ]]; then
        echo "REJECT: Invalid header name format"
        return 1
    fi

    return 0
}

# Sanitize shell arguments — prevent command injection
sanitize_argument() {
    local input="$1"
    # Remove shell metacharacters
    local sanitized
    sanitized=$(printf '%s' "$input" | tr -d '`$(){}[]|;&<>!\\')
    # Warn if sanitization changed the value
    if [[ "$input" != "$sanitized" ]]; then
        echo "WARNING: Input contained shell metacharacters, sanitized" >&2
    fi
    printf '%s' "$sanitized"
}
```

### Verification

```bash
test_input_validation() {
    # Test URL validation
    validate_url "https://api.github.com/repos" "api.github.com"
    echo "Expected: VALID"

    validate_url "http://169.254.169.254/metadata" "api.github.com"
    echo "Expected: REJECT (SSRF)"

    validate_url "https://evil.com/api" "api.github.com"
    echo "Expected: REJECT (not in allowlist)"

    # Test header injection
    validate_header "Authorization" "Bearer sk-test123"
    echo "Expected: OK"

    validate_header "X-Inject" $'value\r\nX-Evil: injected'
    echo "Expected: REJECT (newline)"

    # Test argument sanitization
    local result
    result=$(sanitize_argument 'normal-value')
    echo "Sanitized: $result (expected: normal-value)"

    result=$(sanitize_argument '$(whoami)')
    echo "Sanitized: $result (expected: whoami with metacharacters removed)"
}
```

### Common Mistakes

1. **Trusting API response schemas** — Always validate inputs AND outputs. APIs can be compromised.
2. **Using `eval` with any user/API input** — Never. Use `jq` for JSON manipulation instead.
3. **Allowing arbitrary URL redirects** — Always re-validate URLs after following redirects.
4. **Not validating Content-Type** — A JSON endpoint returning HTML could indicate a proxy/MITM issue.

---

## §5 — Output Sanitization

### Threat Model

**Attack:** API responses containing tokens, keys, or secrets are displayed in terminal
output, logged to files, or (critically) passed into LLM conversation context where they
become part of training data or are exposed via prompt injection.

**Impact:** Credential leakage through logs, screenshots, screen recordings, terminal
history, or AI model context windows.

**OWASP Mapping:** API1 — BOLA, API3 — Broken Object Property Level Authorization.

### Implementation

```bash
#!/usr/bin/env bash
# sanitize_output.sh — Strip secrets from API responses before display

set -euo pipefail

# Known secret patterns with descriptive labels
declare -A SECRET_PATTERNS=(
    ["AWS Access Key"]='AKIA[0-9A-Z]{16}'
    ["AWS Secret Key"]='[0-9a-zA-Z/+]{40}'
    ["GitHub Token (classic)"]='ghp_[0-9a-zA-Z]{36}'
    ["GitHub Token (fine-grained)"]='github_pat_[0-9a-zA-Z_]{82}'
    ["OpenAI API Key"]='sk-[a-zA-Z0-9]{20}T3BlbkFJ[a-zA-Z0-9]{20}'
    ["Stripe Secret Key"]='sk_live_[0-9a-zA-Z]{24,}'
    ["Stripe Publishable"]='pk_live_[0-9a-zA-Z]{24,}'
    ["Generic Bearer Token"]='[Bb]earer [a-zA-Z0-9._~+/=-]{20,}'
    ["Slack Token"]='xox[bpras]-[0-9a-zA-Z-]{10,}'
    ["Private Key Block"]='-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'
    ["Generic API Key"]='["\x27]?api[_-]?key["\x27]?\s*[:=]\s*["\x27][a-zA-Z0-9]{16,}["\x27]'
    ["JWT Token"]='eyJ[a-zA-Z0-9_-]{10,}\.[a-zA-Z0-9_-]{10,}\.[a-zA-Z0-9_-]{10,}'
)

# Redact all known secret patterns from a string
redact_secrets() {
    local input="$1"
    local output="$input"

    for pattern_name in "${!SECRET_PATTERNS[@]}"; do
        local pattern="${SECRET_PATTERNS[$pattern_name]}"
        local redacted
        redacted=$(printf '%s' "$output" | sed -E "s/$pattern/[REDACTED:$pattern_name]/g" 2>/dev/null || echo "$output")
        if [[ "$redacted" != "$output" ]]; then
            echo "REDACTION: Found and redacted $pattern_name" >&2
            audit_log "security" "system" "secret_redaction" "success" \
                "{\"pattern\":\"$pattern_name\"}" 2>/dev/null || true
        fi
        output="$redacted"
    done

    printf '%s' "$output"
}

# Sanitize JSON response — redact values of known sensitive keys
sanitize_json_response() {
    local json_input="$1"

    # List of JSON keys whose values should always be redacted
    local sensitive_keys='["access_token","refresh_token","api_key","apiKey",
        "secret","password","private_key","client_secret","token",
        "authorization","credential","secret_key","session_token"]'

    printf '%s' "$json_input" | jq --argjson keys "$sensitive_keys" '
        walk(
            if type == "object" then
                to_entries | map(
                    if (.key | ascii_downcase) as $k |
                       ($keys | map(ascii_downcase)) | index($k)
                    then .value = "[REDACTED]"
                    else .
                    end
                ) | from_entries
            else .
            end
        )
    ' 2>/dev/null || printf '%s' "$json_input"
}

# Safe display wrapper — always sanitize before showing to user
safe_display() {
    local content="$1"
    local format="${2:-text}"  # text | json

    case "$format" in
        json)
            content=$(sanitize_json_response "$content")
            content=$(redact_secrets "$content")
            printf '%s' "$content" | jq '.'
            ;;
        *)
            content=$(redact_secrets "$content")
            printf '%s\n' "$content"
            ;;
    esac
}
```

### Verification

```bash
test_output_sanitization() {
    # Test token redaction
    local test_input='{"access_token":"ghp_abc123def456ghi789jkl012mno345pqr678","user":"john"}'
    local result
    result=$(sanitize_json_response "$test_input")

    if printf '%s' "$result" | jq -r '.access_token' | grep -q 'REDACTED'; then
        echo "PASS: access_token redacted"
    else
        echo "FAIL: access_token not redacted"
    fi

    if printf '%s' "$result" | jq -r '.user' | grep -q 'john'; then
        echo "PASS: Non-sensitive field preserved"
    else
        echo "FAIL: Non-sensitive field incorrectly redacted"
    fi

    # Test regex pattern redaction
    local text_input="My key is sk_live_abcdefghijklmnopqrstuvwx and it works"
    local redacted
    redacted=$(redact_secrets "$text_input")
    if [[ "$redacted" == *"sk_live_"* ]]; then
        echo "FAIL: Stripe key not redacted from text"
    else
        echo "PASS: Stripe key redacted from text"
    fi
}
```

### Common Mistakes

1. **Redacting keys but not values** — The pattern `"api_key": "secret"` needs the *value* redacted, not the key name.
2. **Only checking known patterns** — New token formats appear regularly. Combine pattern matching with key-name-based redaction.
3. **Logging before sanitizing** — Always sanitize first, then log/display.
4. **Forgetting error responses** — Some APIs include tokens in error messages (e.g., "Invalid token: sk-...").

---

## §6 — Rate Limiting

### Threat Model

**Attack:** Excessive API calls trigger rate limits, causing service degradation or
temporary bans. In multi-tenant scenarios, one integration's abuse can block all others.
Alternatively, an attacker deliberately triggers rate limits as a denial of service.

**Impact:** Service disruption, API key suspension, financial cost (pay-per-call APIs),
degraded user experience.

**OWASP Mapping:** API4 — Unrestricted Resource Consumption.

### Implementation

```bash
#!/usr/bin/env bash
# rate_limit.sh — Parse rate limit headers and implement adaptive backoff

set -euo pipefail

RATE_LIMIT_CACHE="${API_FORGE_HOME:-$HOME/.api-forge}/cache/rate-limits.json"

# Parse standard rate limit headers from curl response headers
parse_rate_limit_headers() {
    local headers_file="$1"
    local service="$2"

    local limit remaining reset retry_after

    # Standard headers (GitHub, most APIs)
    limit=$(grep -i '^x-ratelimit-limit:' "$headers_file" | tail -1 | tr -d '\r' | awk '{print $2}')
    remaining=$(grep -i '^x-ratelimit-remaining:' "$headers_file" | tail -1 | tr -d '\r' | awk '{print $2}')
    reset=$(grep -i '^x-ratelimit-reset:' "$headers_file" | tail -1 | tr -d '\r' | awk '{print $2}')
    retry_after=$(grep -i '^retry-after:' "$headers_file" | tail -1 | tr -d '\r' | awk '{print $2}')

    # Store in cache
    jq -n \
        --arg svc "$service" \
        --arg lim "${limit:-unknown}" \
        --arg rem "${remaining:-unknown}" \
        --arg rst "${reset:-0}" \
        --arg rta "${retry_after:-0}" \
        --arg ts "$(date -u +%s)" \
        '{($svc): {limit: $lim, remaining: $rem, reset: $rst, retry_after: $rta, checked_at: $ts}}' \
        > "$RATE_LIMIT_CACHE.tmp"

    if [[ -f "$RATE_LIMIT_CACHE" ]]; then
        jq -s '.[0] * .[1]' "$RATE_LIMIT_CACHE" "$RATE_LIMIT_CACHE.tmp" > "$RATE_LIMIT_CACHE.new"
        mv "$RATE_LIMIT_CACHE.new" "$RATE_LIMIT_CACHE"
        rm -f "$RATE_LIMIT_CACHE.tmp"
    else
        mv "$RATE_LIMIT_CACHE.tmp" "$RATE_LIMIT_CACHE"
    fi

    # Return remaining count for decision making
    echo "${remaining:-0}"
}

# Adaptive backoff — exponential with jitter
adaptive_backoff() {
    local attempt="$1"
    local base_delay="${2:-1}"     # Base delay in seconds
    local max_delay="${3:-300}"    # Max delay: 5 minutes

    # Exponential backoff: base * 2^attempt
    local delay
    delay=$(( base_delay * (2 ** attempt) ))

    # Add jitter (random 0-30% of delay)
    local jitter
    jitter=$(( RANDOM % (delay * 30 / 100 + 1) ))
    delay=$(( delay + jitter ))

    # Cap at max delay
    if [[ "$delay" -gt "$max_delay" ]]; then
        delay="$max_delay"
    fi

    echo "$delay"
}

# Rate-limit-aware API call wrapper
rate_limited_call() {
    local service="$1"
    local method="$2"
    local url="$3"
    shift 3
    local extra_args=("$@")

    local max_retries=5
    local attempt=0
    local headers_file
    headers_file=$(mktemp)
    trap "rm -f '$headers_file'" RETURN

    while [[ "$attempt" -lt "$max_retries" ]]; do
        # Check cached rate limit before calling
        if [[ -f "$RATE_LIMIT_CACHE" ]]; then
            local cached_remaining
            cached_remaining=$(jq -r --arg s "$service" '.[$s].remaining // "unknown"' "$RATE_LIMIT_CACHE")
            if [[ "$cached_remaining" != "unknown" ]] && [[ "$cached_remaining" -le 5 ]]; then
                local reset_at
                reset_at=$(jq -r --arg s "$service" '.[$s].reset // "0"' "$RATE_LIMIT_CACHE")
                local now
                now=$(date -u +%s)
                local wait_time=$(( reset_at - now ))
                if [[ "$wait_time" -gt 0 ]] && [[ "$wait_time" -lt 900 ]]; then
                    echo "Rate limit low ($cached_remaining remaining). Waiting ${wait_time}s for reset." >&2
                    sleep "$wait_time"
                fi
            fi
        fi

        # Make the call
        local http_code
        http_code=$(curl -s -o /dev/stdout -w '%{http_code}' \
            -X "$method" \
            -D "$headers_file" \
            "${extra_args[@]}" \
            "$url" 2>/dev/null) || true

        # Parse rate limit headers from response
        parse_rate_limit_headers "$headers_file" "$service" >/dev/null

        # Handle response
        case "$http_code" in
            2[0-9][0-9])
                return 0
                ;;
            429)
                local delay
                delay=$(adaptive_backoff "$attempt")
                echo "Rate limited (429). Backoff: ${delay}s (attempt $((attempt+1))/$max_retries)" >&2
                audit_log "api_call" "$service" "$method $url" "rate_limited" \
                    "{\"attempt\":$attempt,\"backoff_seconds\":$delay}" 2>/dev/null || true
                sleep "$delay"
                ;;
            5[0-9][0-9])
                local delay
                delay=$(adaptive_backoff "$attempt" 2)
                echo "Server error ($http_code). Backoff: ${delay}s" >&2
                sleep "$delay"
                ;;
            *)
                echo "Request failed with status $http_code" >&2
                return 1
                ;;
        esac

        ((attempt++))
    done

    echo "Max retries ($max_retries) exceeded for $service" >&2
    return 1
}
```

### Verification

```bash
test_rate_limiting() {
    # Test backoff calculation
    for i in 0 1 2 3 4; do
        local delay
        delay=$(adaptive_backoff "$i" 1 300)
        echo "Attempt $i: ${delay}s delay"
    done
    echo "Expected: increasing delays with jitter, capped at 300"

    # Test header parsing (mock)
    local mock_headers
    mock_headers=$(mktemp)
    printf 'X-RateLimit-Limit: 5000\r\nX-RateLimit-Remaining: 42\r\nX-RateLimit-Reset: %s\r\n' \
        "$(( $(date +%s) + 3600 ))" > "$mock_headers"
    local remaining
    remaining=$(parse_rate_limit_headers "$mock_headers" "test-service")
    [[ "$remaining" == "42" ]] && echo "PASS: Parsed remaining=42" \
                                || echo "FAIL: Expected 42, got $remaining"
    rm -f "$mock_headers"
}
```

### Common Mistakes

1. **No jitter in backoff** — All concurrent clients retry at the exact same time, causing a thundering herd.
2. **Ignoring `Retry-After` header** — This is the server telling you exactly when to retry. Respect it.
3. **Not caching rate limit state** — Making a "check" call to see limits consumes a rate limit slot.
4. **Treating 429 as a fatal error** — It is a temporary condition. Retry with backoff.

---

## §7 — Error Handling

### Threat Model

**Attack:** Unhandled errors expose stack traces, internal paths, or API configuration
details. Repeated transient failures without circuit breaking cause cascading failures
across dependent systems.

**Impact:** Information disclosure, service degradation, resource exhaustion from infinite
retry loops.

**OWASP Mapping:** API4 — Unrestricted Resource Consumption, API8 — Security Misconfiguration.

### Implementation

```bash
#!/usr/bin/env bash
# error_handling.sh — Status code mapping, retry logic, and circuit breaker

set -euo pipefail

CIRCUIT_STATE_DIR="${API_FORGE_HOME:-$HOME/.api-forge}/cache/circuits"
mkdir -p "$CIRCUIT_STATE_DIR"

# --- Status Code Classification ---
classify_http_status() {
    local code="$1"
    case "$code" in
        200|201|202|204) echo "success" ;;
        301|302|307|308) echo "redirect" ;;
        400) echo "client_error:bad_request" ;;
        401) echo "auth_error:unauthorized" ;;
        403) echo "auth_error:forbidden" ;;
        404) echo "client_error:not_found" ;;
        409) echo "client_error:conflict" ;;
        422) echo "client_error:validation" ;;
        429) echo "rate_limit" ;;
        500) echo "server_error:internal" ;;
        502) echo "server_error:bad_gateway" ;;
        503) echo "server_error:unavailable" ;;
        504) echo "server_error:timeout" ;;
        *)
            if [[ "$code" -ge 400 ]] && [[ "$code" -lt 500 ]]; then
                echo "client_error:other"
            elif [[ "$code" -ge 500 ]]; then
                echo "server_error:other"
            else
                echo "unknown"
            fi
            ;;
    esac
}

# --- Retry Decision Logic ---
should_retry() {
    local status_class="$1"
    local attempt="$2"
    local max_attempts="${3:-3}"

    if [[ "$attempt" -ge "$max_attempts" ]]; then
        echo "no:max_attempts_exceeded"
        return 1
    fi

    case "$status_class" in
        rate_limit)              echo "yes:backoff_required" ;;
        server_error:*)          echo "yes:transient_error" ;;
        auth_error:unauthorized) echo "no:credential_refresh_needed" ;;
        auth_error:forbidden)    echo "no:permission_denied" ;;
        client_error:*)          echo "no:client_error_not_retryable" ;;
        *)                       echo "no:unknown_classification" ;;
    esac
}

# --- Circuit Breaker Pattern ---
# Prevents hammering a service that is clearly down
CIRCUIT_FAILURE_THRESHOLD=5    # Open circuit after 5 consecutive failures
CIRCUIT_RESET_TIMEOUT=60       # Try again after 60 seconds

circuit_state_file() {
    local service="$1"
    echo "$CIRCUIT_STATE_DIR/${service}.state"
}

circuit_get_state() {
    local service="$1"
    local state_file
    state_file=$(circuit_state_file "$service")

    if [[ ! -f "$state_file" ]]; then
        echo "closed"
        return
    fi

    local state failures last_failure
    state=$(jq -r '.state' "$state_file")
    failures=$(jq -r '.failures' "$state_file")
    last_failure=$(jq -r '.last_failure' "$state_file")
    local now
    now=$(date +%s)

    case "$state" in
        open)
            local elapsed=$(( now - last_failure ))
            if [[ "$elapsed" -ge "$CIRCUIT_RESET_TIMEOUT" ]]; then
                echo "half_open"
            else
                echo "open"
            fi
            ;;
        *)
            echo "$state"
            ;;
    esac
}

circuit_record_success() {
    local service="$1"
    local state_file
    state_file=$(circuit_state_file "$service")
    jq -n '{state:"closed",failures:0,last_failure:0}' > "$state_file"
}

circuit_record_failure() {
    local service="$1"
    local state_file
    state_file=$(circuit_state_file "$service")
    local now
    now=$(date +%s)

    local current_failures=0
    if [[ -f "$state_file" ]]; then
        current_failures=$(jq -r '.failures' "$state_file")
    fi

    current_failures=$(( current_failures + 1 ))

    local new_state="closed"
    if [[ "$current_failures" -ge "$CIRCUIT_FAILURE_THRESHOLD" ]]; then
        new_state="open"
        echo "CIRCUIT OPEN: $service — too many consecutive failures" >&2
        audit_log "error" "$service" "circuit_breaker" "open" \
            "{\"failures\":$current_failures}" 2>/dev/null || true
    fi

    jq -n --arg s "$new_state" --argjson f "$current_failures" --argjson t "$now" \
        '{state:$s,failures:$f,last_failure:$t}' > "$state_file"
}

# --- Safe API Call with Circuit Breaker ---
safe_api_call() {
    local service="$1"
    shift

    local state
    state=$(circuit_get_state "$service")

    if [[ "$state" == "open" ]]; then
        echo "ERROR: Circuit breaker OPEN for $service. Service appears down." >&2
        return 1
    fi

    if [[ "$state" == "half_open" ]]; then
        echo "INFO: Circuit half-open for $service. Attempting probe call." >&2
    fi

    # Execute the call (using rate_limited_call or direct curl)
    if "$@"; then
        circuit_record_success "$service"
        return 0
    else
        circuit_record_failure "$service"
        return 1
    fi
}
```

### Common Mistakes

1. **Retrying 401 errors** — Retrying with the same expired token will always fail. Refresh first.
2. **No circuit breaker** — Without it, a downed service causes every request to wait for timeout.
3. **Exposing raw error messages** — API error responses may contain internal details. Sanitize before display.
4. **Infinite retry loops** — Always have a maximum retry count and a maximum total elapsed time.

---

## §8 — Secret Rotation

### Threat Model

**Attack:** Compromised or leaked tokens remain valid indefinitely because no rotation
policy exists. Long-lived tokens are higher value targets. Leaked tokens in git history,
logs, or screenshots remain exploitable.

**Impact:** Persistent unauthorized access, expanding blast radius over time as the
attacker discovers more endpoints.

**OWASP Mapping:** API2 — Broken Authentication, API9 — Improper Inventory Management.

### Implementation

```bash
#!/usr/bin/env bash
# rotation.sh — Token age tracking and rotation alerting

set -euo pipefail

ROTATION_REGISTRY="${API_FORGE_HOME:-$HOME/.api-forge}/config/rotation-registry.json"

# Register a credential with its rotation policy
register_credential() {
    local service="$1"
    local credential_id="$2"          # Opaque ID, NOT the actual secret
    local max_age_days="${3:-90}"      # Default: rotate every 90 days
    local created_at="${4:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"

    local registry='{}'
    [[ -f "$ROTATION_REGISTRY" ]] && registry=$(cat "$ROTATION_REGISTRY")

    printf '%s' "$registry" | jq --arg svc "$service" \
        --arg cid "$credential_id" \
        --argjson maxage "$max_age_days" \
        --arg created "$created_at" \
        '.[$svc] = {
            credential_id: $cid,
            created_at: $created,
            max_age_days: $maxage,
            last_rotated: $created,
            rotation_count: 0
        }' > "$ROTATION_REGISTRY"
}

# Check all credentials for rotation needs
check_rotation_status() {
    if [[ ! -f "$ROTATION_REGISTRY" ]]; then
        echo "No credentials registered for rotation tracking."
        return 0
    fi

    local now_epoch
    now_epoch=$(date -u +%s)
    local alerts=0

    printf '%s' "$(cat "$ROTATION_REGISTRY")" | jq -r 'to_entries[] | "\(.key)|\(.value.last_rotated)|\(.value.max_age_days)|\(.value.credential_id)"' | \
    while IFS='|' read -r service last_rotated max_age cred_id; do
        local rotated_epoch
        rotated_epoch=$(date -u -d "$last_rotated" +%s 2>/dev/null || date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$last_rotated" +%s 2>/dev/null || echo 0)
        local age_days=$(( (now_epoch - rotated_epoch) / 86400 ))
        local remaining_days=$(( max_age - age_days ))

        if [[ "$remaining_days" -le 0 ]]; then
            echo "CRITICAL: $service ($cred_id) — EXPIRED ($age_days days old, max $max_age)"
            ((alerts++))
        elif [[ "$remaining_days" -le 7 ]]; then
            echo "WARNING: $service ($cred_id) — expires in $remaining_days days"
            ((alerts++))
        elif [[ "$remaining_days" -le 14 ]]; then
            echo "NOTICE: $service ($cred_id) — expires in $remaining_days days"
        else
            echo "OK: $service ($cred_id) — $age_days days old, $remaining_days days until rotation"
        fi
    done

    return 0
}

# Record a rotation event
record_rotation() {
    local service="$1"
    local new_credential_id="$2"

    local now
    now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local registry
    registry=$(cat "$ROTATION_REGISTRY")

    local old_count
    old_count=$(printf '%s' "$registry" | jq -r --arg s "$service" '.[$s].rotation_count // 0')

    printf '%s' "$registry" | jq --arg svc "$service" \
        --arg cid "$new_credential_id" \
        --arg now "$now" \
        --argjson cnt "$(( old_count + 1 ))" \
        '.[$svc].credential_id = $cid |
         .[$svc].last_rotated = $now |
         .[$svc].rotation_count = $cnt' > "$ROTATION_REGISTRY"

    audit_log "rotation" "$service" "credential_rotated" "success" \
        "{\"old_age_reset\":true,\"rotation_number\":$cnt}" 2>/dev/null || true

    echo "Rotated $service credential. Rotation #$cnt."
}
```

### Common Mistakes

1. **Not tracking creation date** — Without it, you cannot calculate age or enforce rotation.
2. **Rotating but not revoking the old token** — The old token remains valid. Always revoke after confirming the new one works.
3. **No alerting** — Silent expiration leads to production outages. Alert at 14 days, 7 days, and 1 day.
4. **Storing rotation state in the same encrypted vault** — Rotation metadata (not secrets) should be in a separate, easily readable file.

---

## §9 — Transport Security

### Threat Model

**Attack:** Man-in-the-middle (MITM) intercepts API traffic by exploiting missing TLS
verification, downgrade attacks, or compromised certificate authorities. Corporate proxies
may perform TLS inspection, creating an additional trust boundary.

**Impact:** Complete credential and data interception, request/response tampering.

**OWASP Mapping:** API8 — Security Misconfiguration.

### Implementation

```bash
#!/usr/bin/env bash
# transport.sh — TLS enforcement and certificate verification

set -euo pipefail

# NEVER disable TLS verification in production.
# This function wraps curl with strict TLS settings.
secure_curl() {
    local url="$1"
    shift

    # Strict TLS settings
    curl \
        --proto '=https'           `# Only allow HTTPS protocol` \
        --tlsv1.2                  `# Minimum TLS 1.2` \
        --ssl-reqd                 `# Require SSL/TLS` \
        --fail-with-body           `# Fail on HTTP errors but still capture body` \
        --max-time 30              `# 30 second timeout` \
        --connect-timeout 10       `# 10 second connection timeout` \
        --retry 0                  `# No automatic retries (we handle this ourselves)` \
        --no-progress-meter        `# No progress bar` \
        "$@" \
        "$url"
}

# Verify a server's TLS certificate details
verify_tls_certificate() {
    local host="$1"
    local port="${2:-443}"

    echo "=== TLS Certificate Verification for $host:$port ==="

    # Get certificate details
    local cert_info
    cert_info=$(echo | openssl s_client -connect "$host:$port" -servername "$host" 2>/dev/null)

    # Check expiry
    local expiry
    expiry=$(echo "$cert_info" | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    echo "Certificate expires: $expiry"

    # Check issuer
    local issuer
    issuer=$(echo "$cert_info" | openssl x509 -noout -issuer 2>/dev/null)
    echo "Issuer: $issuer"

    # Check SANs (Subject Alternative Names)
    local sans
    sans=$(echo "$cert_info" | openssl x509 -noout -ext subjectAltName 2>/dev/null)
    echo "SANs: $sans"

    # Check if certificate is expiring soon (within 30 days)
    if echo "$cert_info" | openssl x509 -noout -checkend 2592000 2>/dev/null; then
        echo "STATUS: Certificate valid for > 30 days"
    else
        echo "WARNING: Certificate expires within 30 days!"
    fi

    # Verify chain
    if echo | openssl s_client -connect "$host:$port" -servername "$host" \
        -verify 5 -verify_return_error 2>&1 | grep -q "Verification: OK"; then
        echo "Chain verification: OK"
    else
        echo "Chain verification: FAILED"
        return 1
    fi
}

# Certificate pinning — verify against known fingerprint
verify_certificate_pin() {
    local host="$1"
    local expected_pin="$2"  # SHA-256 of the public key (base64)

    local actual_pin
    actual_pin=$(echo | openssl s_client -connect "$host:443" -servername "$host" 2>/dev/null \
        | openssl x509 -pubkey -noout 2>/dev/null \
        | openssl pkey -pubin -outform DER 2>/dev/null \
        | openssl dgst -sha256 -binary | base64)

    if [[ "$actual_pin" == "$expected_pin" ]]; then
        echo "PASS: Certificate pin matches for $host"
        return 0
    else
        echo "FAIL: Certificate pin MISMATCH for $host"
        echo "  Expected: $expected_pin"
        echo "  Got:      $actual_pin"
        audit_log "security" "$host" "certificate_pin_mismatch" "failure" \
            '{"alert":"possible_mitm"}' 2>/dev/null || true
        return 1
    fi
}

# Proxy-aware configuration
configure_proxy() {
    local proxy_url="$1"

    # Validate proxy URL format
    if [[ ! "$proxy_url" =~ ^https?://[a-zA-Z0-9._-]+(:[0-9]+)?$ ]]; then
        echo "ERROR: Invalid proxy URL format"
        return 1
    fi

    # For corporate MITM proxies, the CA bundle must include the proxy's CA
    # NEVER use --insecure or -k as a workaround
    export HTTPS_PROXY="$proxy_url"
    export https_proxy="$proxy_url"

    echo "Proxy configured: $proxy_url"
    echo "NOTE: If TLS errors occur, add the proxy CA to your CA bundle:"
    echo "  export CURL_CA_BUNDLE=/path/to/combined-ca-bundle.crt"
}
```

### Common Mistakes

1. **Using `curl -k` / `--insecure`** — Disables ALL certificate verification. Never do this in production.
2. **Not setting minimum TLS version** — TLS 1.0 and 1.1 are broken. Always require TLS 1.2+.
3. **Ignoring proxy TLS inspection** — Corporate proxies re-sign certificates. The proxy CA must be trusted.
4. **No connection timeout** — Without it, a hanging connection blocks the script indefinitely.

---

## §10 — Supply Chain Security

### Threat Model

**Attack:** API Forge downloads and executes code from external sources (plugins, scripts,
API specs). An attacker compromises an upstream source to inject malicious code that runs
with the user's full privileges.

**Impact:** Full system compromise, credential theft, lateral movement across all
integrated services.

**OWASP Mapping:** API5 — Broken Function Level Authorization, API7 — SSRF,
API10 — Unsafe Consumption of APIs.

### Implementation

```bash
#!/usr/bin/env bash
# supply_chain.sh — Trust model and external code policy

set -euo pipefail

# === CORE PRINCIPLE ===
# API Forge NEVER executes external code.
#
# - OpenAPI specs are PARSED, never eval'd
# - Plugins are NOT supported (by design)
# - Shell scripts from APIs are NEVER piped to sh/bash
# - Downloaded files are DATA, never CODE
#
# This eliminates the entire class of supply chain attacks.

# Verify integrity of downloaded API specifications
verify_spec_integrity() {
    local spec_file="$1"
    local expected_hash="${2:-}"  # Optional SHA-256 hash

    # Step 1: Verify it's valid JSON/YAML (not executable)
    if file "$spec_file" | grep -qiE '(executable|script|binary|ELF|PE32)'; then
        echo "REJECT: File appears to be executable, not a specification"
        rm -f "$spec_file"
        return 1
    fi

    # Step 2: Verify JSON/YAML parseable
    if [[ "$spec_file" == *.json ]]; then
        if ! jq empty "$spec_file" 2>/dev/null; then
            echo "REJECT: Not valid JSON"
            return 1
        fi
    elif [[ "$spec_file" == *.yaml ]] || [[ "$spec_file" == *.yml ]]; then
        if command -v python3 &>/dev/null; then
            if ! python3 -c "import yaml; yaml.safe_load(open('$spec_file'))" 2>/dev/null; then
                echo "REJECT: Not valid YAML"
                return 1
            fi
        fi
    fi

    # Step 3: If expected hash provided, verify integrity
    if [[ -n "$expected_hash" ]]; then
        local actual_hash
        actual_hash=$(sha256sum "$spec_file" | awk '{print $1}')
        if [[ "$actual_hash" != "$expected_hash" ]]; then
            echo "REJECT: Hash mismatch"
            echo "  Expected: $expected_hash"
            echo "  Actual:   $actual_hash"
            return 1
        fi
        echo "PASS: Hash verified"
    fi

    # Step 4: Scan for suspicious content patterns
    local suspicious_patterns=(
        'eval('
        'exec('
        'system('
        '__import__'
        'subprocess'
        '<script'
        'javascript:'
        'data:text/html'
    )

    for pattern in "${suspicious_patterns[@]}"; do
        if grep -qi "$pattern" "$spec_file" 2>/dev/null; then
            echo "WARNING: Suspicious pattern found in spec: '$pattern'"
            echo "  This may indicate a tampered specification."
        fi
    done

    echo "Specification integrity check passed"
    return 0
}

# Safe spec download with integrity chain
safe_download_spec() {
    local url="$1"
    local output="$2"
    local expected_hash="${3:-}"

    # Validate URL against allowlist
    validate_url "$url" "raw.githubusercontent.com,api.apis.guru,petstore.swagger.io" || return 1

    # Download with strict TLS
    secure_curl "$url" -o "$output" || return 1

    # Verify integrity
    verify_spec_integrity "$output" "$expected_hash" || return 1

    # Set read-only permissions
    chmod 0444 "$output"
}
```

### Common Mistakes

1. **`curl | bash` pattern** — The single most dangerous pattern in shell scripting. Never do this.
2. **Executing API response bodies** — An API could return malicious code in a string field.
3. **Using `eval` with API data** — Even for "safe" operations like variable expansion. Use `jq` instead.
4. **Trusting API specs blindly** — A compromised spec could define endpoints that point to attacker servers.

---

## §11 — LLM Context Safety

### Threat Model

**Attack:** Secrets (API keys, tokens, credentials) enter the LLM conversation context
through error messages, debug output, or response display. Once in context, secrets may
be: (1) persisted in conversation history, (2) sent to cloud LLM providers, (3) extracted
via prompt injection attacks against the LLM.

**Impact:** Credential exposure to third-party AI providers, persistence of secrets in
training data, extraction via adversarial prompts.

**OWASP Mapping:** API10 — Unsafe Consumption of APIs.

### Implementation

```bash
#!/usr/bin/env bash
# llm_safety.sh — Prevent secrets from entering AI conversation context

set -euo pipefail

# Gateway function: ALL output that may enter LLM context passes through here
llm_safe_output() {
    local content="$1"
    local context="${2:-display}"  # display | llm | log

    # Step 1: Redact known secret patterns
    content=$(redact_secrets "$content")

    # Step 2: Redact JSON sensitive fields
    if printf '%s' "$content" | jq empty 2>/dev/null; then
        content=$(sanitize_json_response "$content")
    fi

    # Step 3: Truncate if suspiciously long (base64 blobs, etc.)
    local max_length=10000
    if [[ "${#content}" -gt "$max_length" ]]; then
        content="${content:0:$max_length}... [TRUNCATED: ${#content} chars total]"
    fi

    # Step 4: Remove environment variable references
    content=$(printf '%s' "$content" | sed -E 's/\$\{?[A-Z_]+[A-Z0-9_]*\}?/[ENV_REF_REDACTED]/g')

    # Step 5: Remove file paths that may contain usernames
    content=$(printf '%s' "$content" | sed -E 's|/home/[a-zA-Z0-9_-]+/|/home/[USER]/|g')
    content=$(printf '%s' "$content" | sed -E 's|/Users/[a-zA-Z0-9_-]+/|/Users/[USER]/|g')
    content=$(printf '%s' "$content" | sed -E 's|C:\\Users\\[a-zA-Z0-9_-]+\\|C:\\Users\\[USER]\\|g')

    printf '%s' "$content"
}

# Environment variable safety — prevent env vars with secrets from being visible
secure_env_for_subprocess() {
    # Create a sanitized environment for subprocesses that may send data to LLMs
    local -a safe_env=()

    while IFS='=' read -r key value; do
        # Block known secret environment variables
        case "$key" in
            *_KEY|*_SECRET|*_TOKEN|*_PASSWORD|*_CREDENTIAL|*_API_KEY|*_AUTH)
                continue
                ;;
            AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|AWS_SESSION_TOKEN)
                continue
                ;;
            OPENAI_API_KEY|ANTHROPIC_API_KEY|GITHUB_TOKEN)
                continue
                ;;
            *)
                safe_env+=("$key=$value")
                ;;
        esac
    done < <(env)

    env -i "${safe_env[@]}" "$@"
}

# Verify no secrets in a string destined for LLM context
verify_llm_safe() {
    local content="$1"
    local issues=0

    # Check for common secret patterns
    for pattern_name in "${!SECRET_PATTERNS[@]}"; do
        local pattern="${SECRET_PATTERNS[$pattern_name]}"
        if printf '%s' "$content" | grep -qE "$pattern" 2>/dev/null; then
            echo "UNSAFE: Found $pattern_name pattern in LLM-bound content" >&2
            ((issues++))
        fi
    done

    # Check for high-entropy strings (likely tokens/keys)
    local high_entropy_strings
    high_entropy_strings=$(printf '%s' "$content" | grep -oE '[a-zA-Z0-9+/=_-]{32,}' | head -5)
    if [[ -n "$high_entropy_strings" ]]; then
        echo "WARNING: High-entropy strings detected — may be encoded secrets" >&2
        ((issues++))
    fi

    if [[ "$issues" -gt 0 ]]; then
        echo "FAIL: $issues potential secret(s) in LLM-bound content"
        return 1
    fi

    echo "PASS: Content appears safe for LLM context"
    return 0
}
```

### Common Mistakes

1. **Displaying raw curl verbose output** — `-v` flag shows the full Authorization header. Never use `-v` with LLM output.
2. **Passing env variables through** — `env` in a subprocess shows all variables. Use `secure_env_for_subprocess`.
3. **Including error responses verbatim** — Some APIs echo back the auth token in error messages.
4. **Not considering conversation persistence** — What enters the context may persist in chat history files.

---

## §12 — Idempotency

### Threat Model

**Attack:** Network failures cause a POST/PUT request to be sent but the response is lost.
The client retries, creating a duplicate resource (double charge, double order, duplicate
webhook). This is not a security "attack" per se, but a reliability pattern with financial
and data integrity implications.

**Impact:** Duplicate transactions, inconsistent state, financial loss, data corruption.

**OWASP Mapping:** API6 — Unrestricted Access to Sensitive Business Flows.

### Implementation

```bash
#!/usr/bin/env bash
# idempotency.sh — Idempotency key generation and tracking for mutation operations

set -euo pipefail

IDEMPOTENCY_STORE="${API_FORGE_HOME:-$HOME/.api-forge}/cache/idempotency.json"

# Generate a deterministic idempotency key based on operation parameters
generate_idempotency_key() {
    local service="$1"
    local method="$2"
    local endpoint="$3"
    local payload_hash="$4"   # SHA-256 of the request body
    local scope="${5:-}"      # Optional: user-defined scope (e.g., "order-123")

    # Combine components into a deterministic key
    local key_input="${service}:${method}:${endpoint}:${payload_hash}:${scope}"
    local idempotency_key
    idempotency_key=$(printf '%s' "$key_input" | sha256sum | awk '{print $1}')

    # Prefix for readability
    echo "idem_${idempotency_key:0:32}"
}

# Check if an operation was already executed
check_idempotency() {
    local key="$1"

    if [[ ! -f "$IDEMPOTENCY_STORE" ]]; then
        echo '{}' > "$IDEMPOTENCY_STORE"
        echo "new"
        return
    fi

    local entry
    entry=$(jq -r --arg k "$key" '.[$k] // "null"' "$IDEMPOTENCY_STORE")

    if [[ "$entry" == "null" ]]; then
        echo "new"
    else
        local status
        status=$(printf '%s' "$entry" | jq -r '.status')
        echo "existing:$status"
    fi
}

# Record an idempotency result
record_idempotency() {
    local key="$1"
    local status="$2"         # pending | completed | failed
    local response_hash="$3"  # Hash of the response for verification

    local now
    now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local store='{}'
    [[ -f "$IDEMPOTENCY_STORE" ]] && store=$(cat "$IDEMPOTENCY_STORE")

    printf '%s' "$store" | jq --arg k "$key" \
        --arg st "$status" \
        --arg rh "$response_hash" \
        --arg ts "$now" \
        '.[$k] = {status: $st, response_hash: $rh, timestamp: $ts}' > "$IDEMPOTENCY_STORE"
}

# Idempotent API call wrapper
idempotent_call() {
    local service="$1"
    local method="$2"
    local url="$3"
    local payload="$4"
    shift 4
    local extra_args=("$@")

    # Only apply idempotency to mutation operations
    case "$method" in
        GET|HEAD|OPTIONS)
            # Safe methods are naturally idempotent
            secure_curl "$url" -X "$method" "${extra_args[@]}"
            return $?
            ;;
    esac

    # Generate idempotency key
    local payload_hash
    payload_hash=$(printf '%s' "$payload" | sha256sum | awk '{print $1}')
    local idem_key
    idem_key=$(generate_idempotency_key "$service" "$method" "$url" "$payload_hash")

    # Check if already executed
    local state
    state=$(check_idempotency "$idem_key")

    case "$state" in
        existing:completed)
            echo "SKIPPED: Operation already completed (idempotency key: $idem_key)" >&2
            audit_log "api_call" "$service" "$method (idempotent skip)" "skipped" \
                "{\"idempotency_key\":\"$idem_key\"}" 2>/dev/null || true
            return 0
            ;;
        existing:pending)
            echo "WARNING: Previous attempt still pending — retrying" >&2
            ;;
    esac

    # Record as pending
    record_idempotency "$idem_key" "pending" ""

    # Many APIs support the Idempotency-Key header (Stripe, etc.)
    local response
    if response=$(secure_curl "$url" \
        -X "$method" \
        -H "Idempotency-Key: $idem_key" \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "${extra_args[@]}" 2>&1); then

        local response_hash
        response_hash=$(printf '%s' "$response" | sha256sum | awk '{print $1}')
        record_idempotency "$idem_key" "completed" "$response_hash"
        printf '%s' "$response"
        return 0
    else
        record_idempotency "$idem_key" "failed" ""
        return 1
    fi
}

# Clean up old idempotency records (older than 24 hours)
cleanup_idempotency_store() {
    if [[ ! -f "$IDEMPOTENCY_STORE" ]]; then
        return 0
    fi

    local cutoff
    cutoff=$(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
             date -u -v-24H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")

    if [[ -z "$cutoff" ]]; then
        return 0
    fi

    jq --arg cutoff "$cutoff" \
        'to_entries | map(select(.value.timestamp > $cutoff)) | from_entries' \
        "$IDEMPOTENCY_STORE" > "$IDEMPOTENCY_STORE.tmp"
    mv "$IDEMPOTENCY_STORE.tmp" "$IDEMPOTENCY_STORE"
}
```

### Verification

```bash
test_idempotency() {
    local test_key
    test_key=$(generate_idempotency_key "stripe" "POST" "/v1/charges" "abc123" "order-42")
    echo "Generated key: $test_key"

    # First call should be "new"
    local state
    state=$(check_idempotency "$test_key")
    [[ "$state" == "new" ]] && echo "PASS: First check returns 'new'" \
                              || echo "FAIL: Expected 'new', got '$state'"

    # Record completion
    record_idempotency "$test_key" "completed" "resp-hash-123"

    # Second call should be "existing:completed"
    state=$(check_idempotency "$test_key")
    [[ "$state" == "existing:completed" ]] && echo "PASS: Second check returns 'existing:completed'" \
                                             || echo "FAIL: Expected 'existing:completed', got '$state'"

    # Same parameters should generate the same key (deterministic)
    local test_key2
    test_key2=$(generate_idempotency_key "stripe" "POST" "/v1/charges" "abc123" "order-42")
    [[ "$test_key" == "$test_key2" ]] && echo "PASS: Key generation is deterministic" \
                                        || echo "FAIL: Keys differ for same input"
}
```

### Common Mistakes

1. **Using random UUIDs as idempotency keys** — On retry, a new UUID is generated and the server treats it as a new request. Keys must be deterministic from the operation parameters.
2. **Not sending the Idempotency-Key header** — Many APIs (Stripe, PayPal) support it natively. Always send it for POST/PUT.
3. **Never cleaning up the idempotency store** — Unbounded growth. Purge entries older than 24 hours.
4. **Applying idempotency to GET requests** — GET is already idempotent by definition. Adding overhead for no benefit.

---

## Appendix A — Quick Reference: OWASP API Top 10 to Patterns

| OWASP Risk | Primary Mitigation | Secondary Mitigation |
|---|---|---|
| API1: BOLA | §4 Input Validation | §5 Output Sanitization |
| API2: Broken Auth | §1 Credential Encryption | §8 Secret Rotation |
| API3: Property-Level Auth | §4 Input Validation | §5 Output Sanitization |
| API4: Resource Consumption | §6 Rate Limiting | §7 Error Handling (Circuit Breaker) |
| API5: Function-Level Auth | §4 Input Validation | §10 Supply Chain |
| API6: Business Flow Abuse | §6 Rate Limiting | §12 Idempotency |
| API7: SSRF | §9 Transport Security | §10 Supply Chain |
| API8: Misconfiguration | §2 File Permissions | §9 Transport Security |
| API9: Inventory Mgmt | §3 Audit Logging | §8 Secret Rotation |
| API10: Unsafe Consumption | §10 Supply Chain | §11 LLM Context Safety |

## Appendix B — Security Checklist for New Integrations

```
Pre-Integration:
  [ ] API spec downloaded and integrity verified (§10)
  [ ] Endpoint URLs validated against allowlist (§4)
  [ ] TLS certificate verified and pinned if critical (§9)
  [ ] Credential encrypted in vault (§1)
  [ ] Credential registered for rotation tracking (§8)
  [ ] File permissions enforced (§2)

Runtime:
  [ ] All calls go through rate_limited_call wrapper (§6)
  [ ] All calls go through safe_api_call circuit breaker (§7)
  [ ] Mutation calls use idempotent_call wrapper (§12)
  [ ] All output sanitized before display (§5)
  [ ] All events written to audit log (§3)

LLM Integration:
  [ ] Output passes through llm_safe_output before context (§11)
  [ ] No raw curl -v output enters conversation
  [ ] Environment sanitized for LLM subprocesses (§11)
  [ ] Error messages sanitized before display (§5, §11)

Post-Integration:
  [ ] Audit log verified for integrity (§3)
  [ ] Rotation alerts configured (§8)
  [ ] Permissions re-verified (§2)
```

---

*Document version: 1.0.0 | Last updated: 2025-05-20 | Applicable to API Forge v0.x*
*All implementations target bash 4.4+ with OpenSSL 1.1.1+ and jq 1.6+.*

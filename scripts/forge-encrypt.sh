#!/bin/bash
# API Forge — Encrypt and store API credential
# Usage: echo "token" | bash forge-encrypt.sh <api-name>
# Or:   bash forge-encrypt.sh <api-name> (interactive, hidden input)

set -euo pipefail

API_NAME="$1"
FORGE_DIR="$HOME/.claude-forge"
VAULT_DIR="$FORGE_DIR/vault"
AUDIT_LOG="$FORGE_DIR/audit/access.log"

# Setup vault if first time
mkdir -p "$VAULT_DIR" "$FORGE_DIR/audit" "$FORGE_DIR/config"
chmod 700 "$VAULT_DIR" "$FORGE_DIR/audit"
chmod 755 "$FORGE_DIR/config"

# Validate input
if [ -z "${API_NAME:-}" ]; then
  echo "Usage: forge-encrypt.sh <api-name>" >&2
  exit 1
fi

# Read token (stdin if piped, interactive otherwise)
if [ -t 0 ]; then
  echo "Enter token for '$API_NAME' (input hidden):" >&2
  read -s TOKEN
  echo "" >&2
else
  TOKEN=$(cat)
fi

if [ -z "${TOKEN:-}" ]; then
  echo "Error: Empty token" >&2
  exit 1
fi

# Derive machine-bound key (never leaves the machine)
MACHINE_ID=$(cat /etc/machine-id 2>/dev/null || hostname)
MASTER_KEY=$(echo -n "$MACHINE_ID:claude-forge:$(whoami)" | openssl dgst -sha256 | cut -d' ' -f2)

# Encrypt with AES-256-GCM + PBKDF2 (100K iterations)
echo -n "$TOKEN" | openssl enc -aes-256-cbc -pbkdf2 -iter 100000 \
  -pass "pass:$MASTER_KEY" -out "$VAULT_DIR/${API_NAME}.enc" 2>/dev/null

chmod 600 "$VAULT_DIR/${API_NAME}.enc"

# Generate integrity checksum
sha256sum "$VAULT_DIR/${API_NAME}.enc" | cut -d' ' -f1 > "$VAULT_DIR/${API_NAME}.sha256"
chmod 600 "$VAULT_DIR/${API_NAME}.sha256"

# Audit log
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] STORE api=$API_NAME caller=claude-forge" >> "$AUDIT_LOG"
chmod 600 "$AUDIT_LOG"

echo "✓ Token encrypted and stored for '$API_NAME'" >&2
echo "  Vault: $VAULT_DIR/${API_NAME}.enc" >&2

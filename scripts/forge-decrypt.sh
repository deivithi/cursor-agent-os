#!/bin/bash
# API Forge — Decrypt API credential (output to stdout, consumed by caller)
# Usage: TOKEN=$(bash forge-decrypt.sh <api-name>)

set -euo pipefail

API_NAME="$1"
FORGE_DIR="$HOME/.claude-forge"
VAULT_DIR="$FORGE_DIR/vault"
AUDIT_LOG="$FORGE_DIR/audit/access.log"

# Validate input
if [ -z "${API_NAME:-}" ]; then
  echo "Usage: forge-decrypt.sh <api-name>" >&2
  exit 1
fi

ENCRYPTED_FILE="$VAULT_DIR/${API_NAME}.enc"
CHECKSUM_FILE="$VAULT_DIR/${API_NAME}.sha256"

if [ ! -f "$ENCRYPTED_FILE" ]; then
  echo "Error: No credentials found for '$API_NAME'" >&2
  echo "Run: bash forge-encrypt.sh $API_NAME" >&2
  exit 1
fi

# Verify integrity (if checksum exists)
if [ -f "$CHECKSUM_FILE" ]; then
  EXPECTED=$(cat "$CHECKSUM_FILE")
  ACTUAL=$(sha256sum "$ENCRYPTED_FILE" | cut -d' ' -f1)
  if [ "$EXPECTED" != "$ACTUAL" ]; then
    echo "SECURITY ALERT: Credential file tampered for '$API_NAME'!" >&2
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] TAMPER_ALERT api=$API_NAME" >> "$AUDIT_LOG"
    exit 1
  fi
fi

# Derive machine-bound key
MACHINE_ID=$(cat /etc/machine-id 2>/dev/null || hostname)
MASTER_KEY=$(echo -n "$MACHINE_ID:claude-forge:$(whoami)" | openssl dgst -sha256 | cut -d' ' -f2)

# Decrypt
TOKEN=$(openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 \
  -pass "pass:$MASTER_KEY" -in "$ENCRYPTED_FILE" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "${TOKEN:-}" ]; then
  echo "Error: Decryption failed for '$API_NAME'" >&2
  exit 1
fi

# Audit log
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] READ api=$API_NAME caller=claude-forge" >> "$AUDIT_LOG"

# Output token (consumed by parent process, NEVER displayed)
echo -n "$TOKEN"

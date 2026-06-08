#!/bin/bash
# API Forge — Make authenticated API call with audit logging
# Usage: bash forge-api.sh <api-name> <METHOD> <endpoint> [data]

set -euo pipefail

API_NAME="${1:-}"
METHOD="${2:-GET}"
ENDPOINT="${3:-/}"
DATA="${4:-}"
FORGE_DIR="$HOME/.claude-forge"
CONFIG_DIR="$FORGE_DIR/config"
AUDIT_LOG="$FORGE_DIR/audit/access.log"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Validate
if [ -z "$API_NAME" ]; then
  echo "Usage: forge-api.sh <api-name> <METHOD> <endpoint> [data]" >&2
  exit 1
fi

# Load config
CONFIG="$CONFIG_DIR/${API_NAME}.json"
if [ ! -f "$CONFIG" ]; then
  echo "Error: No config for '$API_NAME'. Forge the API first." >&2
  exit 1
fi

BASE_URL=$(jq -r '.base_url' "$CONFIG")
AUTH_TYPE=$(jq -r '.auth_type // "bearer"' "$CONFIG")
AUTH_HEADER=$(jq -r '.auth_header // "Authorization"' "$CONFIG")
RATE_LIMIT=$(jq -r '.rate_limit_per_sec // 10' "$CONFIG")

# Get token (decrypted, in-memory only)
TOKEN=$("$SCRIPT_DIR/forge-decrypt.sh" "$API_NAME")
if [ $? -ne 0 ]; then exit 1; fi

# Build auth value
case "$AUTH_TYPE" in
  bearer)  AUTH_VALUE="Bearer $TOKEN" ;;
  api_key) AUTH_VALUE="$TOKEN" ;;
  basic)   AUTH_VALUE="Basic $TOKEN" ;;
  *)       AUTH_VALUE="$TOKEN" ;;
esac

# Make request with retry and rate limiting
MAX_RETRIES=3
RETRY=0

while [ $RETRY -le $MAX_RETRIES ]; do
  RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X "$METHOD" \
    -H "$AUTH_HEADER: $AUTH_VALUE" \
    -H "Content-Type: application/json" \
    -H "User-Agent: claude-forge/1.0" \
    ${DATA:+-d "$DATA"} \
    "${BASE_URL}${ENDPOINT}" 2>/dev/null)

  HTTP_CODE=$(echo "$RESPONSE" | tail -1)
  BODY=$(echo "$RESPONSE" | sed '$d')

  # Audit
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] USE api=$API_NAME endpoint=$METHOD:$ENDPOINT status=$HTTP_CODE retry=$RETRY" >> "$AUDIT_LOG"

  # Handle rate limiting (429)
  if [ "$HTTP_CODE" = "429" ] && [ $RETRY -lt $MAX_RETRIES ]; then
    WAIT=$((2 ** RETRY + RANDOM % 3))
    echo "Rate limited. Waiting ${WAIT}s..." >&2
    sleep $WAIT
    RETRY=$((RETRY + 1))
    continue
  fi

  # Handle server errors (5xx) with retry
  if [ "$HTTP_CODE" -ge 500 ] && [ $RETRY -lt $MAX_RETRIES ]; then
    WAIT=$((2 ** RETRY))
    echo "Server error $HTTP_CODE. Retrying in ${WAIT}s..." >&2
    sleep $WAIT
    RETRY=$((RETRY + 1))
    continue
  fi

  break
done

# Output
if [ "$HTTP_CODE" -ge 400 ]; then
  echo "Error $HTTP_CODE:" >&2
  echo "$BODY" | jq . 2>/dev/null || echo "$BODY" >&2
  exit 1
fi

echo "$BODY" | jq . 2>/dev/null || echo "$BODY"

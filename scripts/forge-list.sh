#!/bin/bash
# API Forge — List all forged APIs
# Usage: bash forge-list.sh

FORGE_DIR="$HOME/.claude-forge"
CONFIG_DIR="$FORGE_DIR/config"
VAULT_DIR="$FORGE_DIR/vault"

if [ ! -d "$CONFIG_DIR" ] || [ -z "$(ls -A "$CONFIG_DIR"/*.json 2>/dev/null)" ]; then
  echo "No forged APIs found."
  echo "Use /api-forge to forge your first API."
  exit 0
fi

echo "╔══════════════════════════════════════════════════╗"
echo "║           API Forge — Registry                   ║"
echo "╠══════════════════════════════════════════════════╣"

for config in "$CONFIG_DIR"/*.json; do
  [ -f "$config" ] || continue
  NAME=$(jq -r '.name // "unknown"' "$config")
  BASE_URL=$(jq -r '.base_url // "?"' "$config")
  AUTH_TYPE=$(jq -r '.auth_type // "?"' "$config")
  ENDPOINTS=$(jq -r '.endpoints | length // 0' "$config" 2>/dev/null || echo "?")
  FORGED_AT=$(jq -r '.forged_at // "?"' "$config")

  # Check vault
  if [ -f "$VAULT_DIR/${NAME}.enc" ]; then
    VAULT="✅ Encrypted"
  else
    VAULT="⚠️  No credentials"
  fi

  echo "║                                                  ║"
  printf "║  🔧 %-44s ║\n" "$NAME"
  printf "║     URL:  %-40s ║\n" "$BASE_URL"
  printf "║     Auth: %-40s ║\n" "$AUTH_TYPE"
  printf "║     Vault: %-39s ║\n" "$VAULT"
  printf "║     Forged: %-38s ║\n" "$FORGED_AT"
done

echo "╚══════════════════════════════════════════════════╝"

#!/usr/bin/env bash
# PostToolUse auto-format hook — runs prettier on edited JS/TS files
# Inspired by Boris Cherny: "PostToolUse": [{"matcher": "Write|Edit", "hooks": [{"command": "bun run format || true"}]}]

# Get the file path from the tool input (passed via CLAUDE_TOOL_INPUT)
FILE="${CLAUDE_TOOL_INPUT_FILE_PATH:-}"

# Only format JS/TS files
if [[ -n "$FILE" && "$FILE" =~ \.(js|jsx|ts|tsx|json|css|html|md)$ ]]; then
  # Try prettier first (project-local), fall back to global
  if command -v npx &>/dev/null && [[ -f "$(dirname "$FILE")/node_modules/.bin/prettier" || -f "$CLAUDE_PROJECT_DIR/node_modules/.bin/prettier" ]]; then
    npx prettier --write "$FILE" 2>/dev/null && echo "✨ Auto-formatted: $(basename "$FILE")"
  elif command -v prettier &>/dev/null; then
    prettier --write "$FILE" 2>/dev/null && echo "✨ Auto-formatted: $(basename "$FILE")"
  fi
fi

exit 0

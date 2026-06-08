#!/usr/bin/env bash
# Compounding Engineering — @.claude em Code Reviews
# Inspirado em Boris Cherny + Dan Shipper:
# "Tague @.claude nos PRs → Claude auto-commita regra no CLAUDE.md"
#
# Uso: Este script é chamado via n8n webhook ou GitHub Actions
# quando um PR comment contém "@claude" ou "@.claude"
#
# Input (via env vars ou stdin):
#   PR_COMMENT — o texto do comentário
#   PR_NUMBER  — número do PR
#   REPO       — owner/repo
#
# O que faz:
#   1. Extrai a regra/feedback do comentário
#   2. Adiciona ao CLAUDE.md ou rules/ apropriado
#   3. Commita a mudança no PR branch

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$HOME/OneDrive/Documents/VS CODE}"
PR_COMMENT="${PR_COMMENT:-$(cat /dev/stdin 2>/dev/null || echo '')}"
PR_NUMBER="${PR_NUMBER:-0}"
REPO="${REPO:-}"

if [ -z "$PR_COMMENT" ]; then
  echo "❌ No PR comment provided"
  echo "Usage: PR_COMMENT='use const not let @claude add to rules' PR_NUMBER=123 bash compounding-engineering.sh"
  exit 1
fi

# Extract the rule from the comment (everything before @claude/@.claude)
RULE=$(echo "$PR_COMMENT" | sed -E 's/@\.?claude.*//i' | xargs)

if [ -z "$RULE" ]; then
  echo "❌ Could not extract rule from comment"
  exit 1
fi

echo "🔄 Compounding Engineering"
echo "  📝 Rule: $RULE"
echo "  🔢 PR: #$PR_NUMBER"

# Determine target file based on content
TARGET="$PROJECT_DIR/.claude/rules/workflow-patterns.md"

if echo "$RULE" | grep -qiE "style|format|naming|const|let|var|import|export|enum|string|type|interface|async|await|promise"; then
  TARGET="$PROJECT_DIR/.claude/rules/javascript-code.md"
elif echo "$RULE" | grep -qiE "n8n|workflow|node|webhook"; then
  TARGET="$PROJECT_DIR/.claude/rules/n8n-workflows.md"
elif echo "$RULE" | grep -qiE "salesforce|apex|soql|trigger"; then
  TARGET="$PROJECT_DIR/.claude/rules/salesforce.md"
elif echo "$RULE" | grep -qiE "python|pip|venv|django"; then
  TARGET="$PROJECT_DIR/.claude/rules/python-code.md"
fi

TARGET_NAME="$(basename "$TARGET")"
echo "  📂 Target: $TARGET_NAME"

# Append rule
echo "" >> "$TARGET"
echo "- $RULE (via PR #$PR_NUMBER, $(date '+%Y-%m-%d'))" >> "$TARGET"

echo "✅ Rule added to $TARGET_NAME"
echo "💡 To commit: cd \"$PROJECT_DIR\" && git add \".claude/rules/$TARGET_NAME\" && git commit -m 'rules: add from PR #$PR_NUMBER review'"

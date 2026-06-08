#!/bin/bash
# Setup GitHub webhook for auto PR review (polling mode alternative)
# Usage: bash setup-github-webhook.sh <repo> <n8n-webhook-url>
# Note: For most setups, polling mode is easier (no webhook exposure needed)

REPO="${1:-}"
WEBHOOK_URL="${2:-}"

if [ -z "$REPO" ] || [ -z "$WEBHOOK_URL" ]; then
    echo "Usage: setup-github-webhook.sh <owner/repo> <webhook-url>"
    echo ""
    echo "Alternative: Use polling mode (no webhook needed)"
    echo "  The auto-pr-review skill supports polling via 'gh pr list'"
    echo "  which requires NO webhook setup."
    exit 1
fi

echo "Creating webhook for $REPO → $WEBHOOK_URL"
gh api repos/$REPO/hooks \
    --method POST \
    --field "name=web" \
    --field "active=true" \
    --field "events[]=pull_request" \
    --field "events[]=issue_comment" \
    --field "config[url]=$WEBHOOK_URL" \
    --field "config[content_type]=json"

echo "Webhook created. Events: pull_request, issue_comment"

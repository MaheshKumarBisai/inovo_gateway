#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_FILE="$SCRIPT_DIR/.env.deployment"

REPO_URL=$(git config --get remote.origin.url || true)
if [[ "$REPO_URL" =~ github\.com[:/]([^/]+)/([^/.]+)(\.git)? ]]; then
  DEFAULT_REPO="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
else
  DEFAULT_REPO="MaheshKumarBisai/inovo_gateway"
fi

REPO=${1:-"$DEFAULT_REPO"}

echo "=========================================================="
echo "  Invento_gateway - GitHub Secrets Sync"
echo "  Target Repo: $REPO"
echo "=========================================================="

if ! command -v gh &> /dev/null; then
  echo "❌ Error: GitHub CLI ('gh') is not installed."
  exit 1
fi

if ! gh auth status &> /dev/null; then
  echo "❌ Error: Not logged in to GitHub CLI. Run: gh auth login"
  exit 1
fi

if [ ! -f "$SECRETS_FILE" ]; then
  echo "❌ Error: $SECRETS_FILE not found."
  echo "👉 Copy template: cp $SCRIPT_DIR/.env.deployment.example $SECRETS_FILE"
  echo "👉 Edit values (especially BACKEND_PRIVATE_IP and ALB_DNS_NAME), then re-run."
  exit 1
fi

echo "🚀 Syncing secrets to GitHub repository: $REPO..."
gh secret set -f "$SECRETS_FILE" --repo "$REPO"
echo "✅ Successfully synced gateway secrets!"

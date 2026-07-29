#!/bin/bash
# Script to help set up GitHub Secrets for CI/CD

set -e

REPO_OWNER="${GITHUB_ACTOR:-jaouadsiouahe1978}"
REPO_NAME="${GITHUB_REPO:-claude-devops-tools}"

echo "================================"
echo "GitHub Secrets Setup Helper"
echo "================================"
echo ""
echo "Repository: $REPO_OWNER/$REPO_NAME"
echo ""
echo "The following secrets need to be configured in GitHub:"
echo ""
echo "1. Repository Secrets (Settings > Secrets and variables > Actions):"
echo "   - DOCKER_USERNAME: Your Docker Hub username"
echo "   - DOCKER_PASSWORD: Your Docker Hub token/password"
echo "   - API_KEY: Your API key for deployment"
echo "   - DEPLOY_TOKEN: Token for deployment authorization"
echo "   - SLACK_WEBHOOK: Slack webhook URL for notifications"
echo "   - DB_HOST: Database host (if using DB migrations)"
echo "   - DB_USER: Database user"
echo "   - DB_PASSWORD: Database password"
echo ""
echo "2. Repository Variables (Settings > Secrets and variables > Actions):"
echo "   - DEPLOY_ENDPOINT: Deployment API endpoint URL"
echo "   - API_GATEWAY: API Gateway URL"
echo ""
echo "3. Environment Secrets (for staging/production):"
echo "   - Configure separate secrets for staging and production environments"
echo ""
echo "Example command to set a secret via GitHub CLI:"
echo "  gh secret set DOCKER_USERNAME --body 'your-username' --repo $REPO_OWNER/$REPO_NAME"
echo ""
echo "Or use GitHub Web UI:"
echo "  1. Go to Settings tab of your repository"
echo "  2. Navigate to Secrets and variables > Actions"
echo "  3. Click 'New repository secret'"
echo "  4. Add each secret one by one"
echo ""

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) not found. Install it from: https://cli.github.com"
    exit 1
fi

# Verify authentication
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub. Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is available"
echo "✅ Authenticated with GitHub"
echo ""
echo "Would you like to interactively set secrets? (y/n)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    secrets=(
        "DOCKER_USERNAME:Docker Hub username"
        "DOCKER_PASSWORD:Docker Hub token"
        "API_KEY:API key"
        "DEPLOY_TOKEN:Deployment token"
        "SLACK_WEBHOOK:Slack webhook URL"
    )

    for secret in "${secrets[@]}"; do
        IFS=':' read -r name description <<< "$secret"
        echo ""
        echo "Enter $description for $name (leave empty to skip):"
        read -r value

        if [ -n "$value" ]; then
            gh secret set "$name" --body "$value"
            echo "✅ Secret $name set"
        fi
    done

    echo ""
    echo "✅ Secrets configuration complete"
fi

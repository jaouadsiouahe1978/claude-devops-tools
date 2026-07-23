#!/bin/bash
set -e
echo "🚀 Deploying to ${ENVIRONMENT}..."
echo "Validating secrets..."
if [ -z "$APP_URL" ]; then
  echo "❌ APP_URL not set"
  exit 1
fi
DEPLOY_DIR="/tmp/deploy-${ENVIRONMENT}"
mkdir -p "$DEPLOY_DIR"
cd "$DEPLOY_DIR"
echo "📤 Deployment simulated..."
echo "✅ Deployment complete"

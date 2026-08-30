#!/bin/bash
set -euo pipefail

echo "🐳 Building Docker image..."

APP_NAME="myapp"
APP_VERSION="${1:-1.0.0}"

cd app
docker build -t "${APP_NAME}:${APP_VERSION}" -t "${APP_NAME}:latest" .

echo "✅ Docker image built: ${APP_NAME}:${APP_VERSION}"

if command -v minikube &> /dev/null; then
    echo "📦 Loading image into Minikube..."
    minikube image load "${APP_NAME}:${APP_VERSION}"
    minikube image load "${APP_NAME}:latest"
fi

#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCKER_DIR="$PROJECT_DIR/docker"

echo "🐳 Building Docker images for Kubernetes deployment..."
echo ""

cd "$DOCKER_DIR"

# Build Nginx image
echo "📦 Building nginx-frontend image..."
docker build -f Dockerfile.nginx -t nginx-frontend:latest .
echo "✓ Nginx image built"
echo ""

# Build Flask image
echo "📦 Building flask-api image..."
docker build -f Dockerfile.flask -t flask-api:latest .
echo "✓ Flask image built"
echo ""

echo "✅ All images built successfully!"
echo ""
echo "Images built:"
docker images | grep -E "nginx-frontend|flask-api" || echo "Images ready for deployment"

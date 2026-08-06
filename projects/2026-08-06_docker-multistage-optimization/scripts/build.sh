#!/bin/bash

set -e

echo "🔨 Building Docker images..."
echo ""

# Build application images
echo "📦 Building app:bad (unoptimized)..."
docker build -f app/Dockerfile.bad -t app:bad . 2>&1 | tail -5

echo ""
echo "📦 Building app:optimized (multi-stage)..."
docker build -f app/Dockerfile.optimized -t app:optimized . 2>&1 | tail -5

echo ""
echo "📦 Building nginx:optimized..."
docker build -f nginx/Dockerfile -t nginx:optimized . 2>&1 | tail -5

echo ""
echo "✅ All images built successfully!"
echo ""

# Show built images
echo "📋 Built images:"
docker images | grep -E "app:|nginx:" | awk '{printf "  %-30s %s\n", $1":"$2, $7}'

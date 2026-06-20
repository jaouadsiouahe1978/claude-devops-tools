#!/bin/bash

# Cleanup: Stop and remove all containers
# WARNING: This will remove volumes and data

echo "🧹 Cleaning up Docker Registry + Trivy stack..."

cd "$(dirname "$0")/.."

# Check if docker-compose is running
if docker-compose ps | grep -q "Up"; then
    echo "⏹️  Stopping containers..."
    docker-compose down --volumes
    echo "✅ Containers stopped and volumes removed"
else
    echo "ℹ️  No running containers found"
fi

echo ""
echo "🗑️  Removing images..."
docker rmi goharbor/harbor-core:v2.9.1 \
         goharbor/registry-photon:v2.9.1 \
         goharbor/harbor-jobservice:v2.9.1 \
         goharbor/harbor-registryctl:v2.9.1 \
         postgres:15-alpine \
         redis:7-alpine \
         aquasec/trivy:latest \
         -f 2>/dev/null || true

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "To restart, run: ./scripts/setup.sh"

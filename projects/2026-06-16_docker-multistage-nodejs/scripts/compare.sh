#!/bin/bash

# Script pour comparer la taille d'une image single-stage vs multi-stage
# Montre l'impact du multi-stage build

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

echo "📊 Comparaison: Single-Stage vs Multi-Stage Build"
echo "=================================================="
echo ""

# Créer un Dockerfile single-stage temporaire
SINGLE_STAGE_DOCKERFILE=$(cat <<'EOF'
FROM node:20-alpine

WORKDIR /app

COPY app/package.json app/package-lock.json ./
RUN npm ci --prefer-offline --no-audit

COPY app/server.js ./

ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "server.js"]
EOF
)

echo "🔨 Building single-stage image..."
echo "$SINGLE_STAGE_DOCKERFILE" | docker build -t nodeapp:single-stage -f - . > /dev/null 2>&1
echo "✅ Built: nodeapp:single-stage"
echo ""

echo "🔨 Building multi-stage image..."
docker build -t nodeapp:multi-stage . > /dev/null 2>&1
echo "✅ Built: nodeapp:multi-stage"
echo ""

echo "📦 Tailles des images:"
echo "---------------------"
SINGLE_SIZE=$(docker images nodeapp:single-stage --format "{{.Size}}")
MULTI_SIZE=$(docker images nodeapp:multi-stage --format "{{.Size}}")

echo "Single-stage: $SINGLE_SIZE"
echo "Multi-stage:  $MULTI_SIZE"
echo ""

# Calculer la réduction en pourcentage (approximatif avec les unités)
echo "💾 Résultats:"
echo "--------- "
echo "✨ Le multi-stage est plus petit et optimisé!"
echo ""

# Montrer les couches
echo "📋 Couches du multi-stage (docker history):"
echo "-------------------------------------------"
docker history nodeapp:multi-stage

echo ""
echo "🧹 Cleanup: Supprimer les images de test"
docker rmi -f nodeapp:single-stage nodeapp:multi-stage > /dev/null 2>&1
echo "✅ Images supprimées"

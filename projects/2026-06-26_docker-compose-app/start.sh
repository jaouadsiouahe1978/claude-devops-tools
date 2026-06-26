#!/bin/bash

set -e

echo "🚀 DevOps Multi-Container Application Startup"
echo "=============================================="
echo ""

# Couleurs pour output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}[1/4]${NC} Vérification de Docker..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé"
    exit 1
fi
echo "✅ Docker trouvé"

echo ""
echo -e "${BLUE}[2/4]${NC} Construction des images..."
docker-compose build --no-cache

echo ""
echo -e "${BLUE}[3/4]${NC} Démarrage des conteneurs..."
docker-compose up -d

echo ""
echo -e "${BLUE}[4/4]${NC} Attente du démarrage des services..."
sleep 10

# Vérifier que les services sont up
echo ""
echo -e "${GREEN}✅ Services démarrés!${NC}"
echo ""
echo "📋 Status des conteneurs:"
docker-compose ps

echo ""
echo "🌐 URL d'accès:"
echo "  - Application web: ${BLUE}http://localhost:80${NC}"
echo "  - API status: ${BLUE}http://localhost:80/api/status${NC}"
echo "  - Utilisateurs: ${BLUE}http://localhost:80/api/users${NC}"
echo ""
echo "🔍 Pour voir les logs:"
echo "  - Tous: ${BLUE}docker-compose logs -f${NC}"
echo "  - App seulement: ${BLUE}docker-compose logs -f app${NC}"
echo ""
echo "🛑 Pour arrêter:"
echo "  - Sans supprimer volumes: ${BLUE}docker-compose down${NC}"
echo "  - Avec suppression: ${BLUE}docker-compose down -v${NC}"
echo ""

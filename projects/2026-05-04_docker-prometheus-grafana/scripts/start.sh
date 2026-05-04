#!/bin/bash
# Script de démarrage de la stack de monitoring

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

echo "🚀 Démarrage de la stack Prometheus + Grafana..."
echo ""

# Vérifier que Docker est accessible
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé!"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé!"
    exit 1
fi

# Vérifier les droits
if ! docker ps &> /dev/null; then
    echo "❌ Vous n'avez pas les droits pour accéder à Docker!"
    echo "   Essayez: sudo usermod -aG docker \$USER"
    exit 1
fi

# Vérifier les ports
for port in 3000 9090 8080; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "⚠️  Le port $port est déjà utilisé!"
    fi
done

echo ""
echo "📦 Pulling images..."
docker-compose pull

echo ""
echo "🐳 Lancement des conteneurs..."
docker-compose up -d

echo ""
echo "⏳ Attente du démarrage des services (30s)..."
sleep 30

echo ""
echo "✅ Stack démarrée avec succès!"
echo ""
echo "📊 Accès aux services :"
echo "   • Prometheus : http://localhost:9090"
echo "   • Grafana    : http://localhost:3000 (admin / admin)"
echo "   • cAdvisor   : http://localhost:8080"
echo ""
echo "📝 Prochaines étapes :"
echo "   1. Vérifier les targets Prometheus : http://localhost:9090/targets"
echo "   2. Se connecter à Grafana et ajouter Prometheus comme datasource"
echo "   3. Importer un dashboard (ID: 1860)"
echo ""
echo "🛑 Pour arrêter : docker-compose down"
echo ""

# Afficher le status
docker-compose ps

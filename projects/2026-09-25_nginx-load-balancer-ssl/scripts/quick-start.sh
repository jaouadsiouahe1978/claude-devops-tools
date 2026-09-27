#!/bin/bash
# Quick Start Script pour l'infrastructure Nginx Load Balancer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Quick Start - Nginx Load Balancer avec SSL/TLS"
echo "=================================================="
echo ""

# Étape 1: Générer les certificats SSL
echo "📌 Étape 1/5: Génération des certificats SSL/TLS..."
if [ ! -f "$PROJECT_DIR/nginx/ssl/nginx.crt" ]; then
    bash "$SCRIPT_DIR/generate-ssl-certs.sh"
else
    echo "✅ Les certificats existent déjà"
fi

echo ""
echo "📌 Étape 2/5: Construction des images Docker..."
cd "$PROJECT_DIR"
docker-compose build

echo ""
echo "📌 Étape 3/5: Démarrage de l'infrastructure..."
docker-compose up -d
docker-compose logs -f &
LOGS_PID=$!

echo ""
echo "⏳ Attendre que les services soient prêts..."
sleep 5

# Tuer le suiveur de logs
kill $LOGS_PID 2>/dev/null || true

echo ""
echo "📌 Étape 4/5: Vérification de la santé..."

# Vérifier nginx
echo -n "  ├─ Nginx health check... "
for i in {1..30}; do
    if curl -s -k https://localhost/health >/dev/null 2>&1; then
        echo "✅"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Nginx ne répond pas"
        exit 1
    fi
    sleep 1
done

# Vérifier les backends
for backend in 1 2 3; do
    echo -n "  ├─ Backend-$backend health check... "
    if docker-compose logs backend-$backend | grep -q "Running on"; then
        echo "✅"
    else
        echo "⚠️  En cours de démarrage..."
    fi
done

echo ""
echo "📌 Étape 5/5: Tests préliminaires..."
echo ""

# Test simple
echo "  ├─ Test du reverse proxy..."
RESPONSE=$(curl -s -k https://localhost/status)
if echo "$RESPONSE" | grep -q "service_name"; then
    echo "✅ Reverse proxy fonctionne"
else
    echo "❌ Erreur du reverse proxy"
fi

echo ""
echo "🎉 Infrastructure démarrée avec succès!"
echo ""
echo "📊 Commandes utiles:"
echo "   • Voir les logs: docker-compose logs -f"
echo "   • Arrêter l'infra: docker-compose down"
echo "   • Tester le load balancing: bash $SCRIPT_DIR/test-load-balancing.sh"
echo "   • Tester les API endpoints: bash $SCRIPT_DIR/test-api.sh"
echo ""
echo "🌐 Endpoints disponibles:"
echo "   • HTTP (redirige vers HTTPS): http://localhost"
echo "   • HTTPS: https://localhost"
echo "   • Health check: https://localhost/health"
echo "   • Status: https://localhost/status"
echo "   • Users API: https://localhost/api/users"
echo "   • Stats: https://localhost/api/stats"
echo ""
echo "📌 Note: Les certificats sont auto-signés, utiliser -k avec curl pour ignorer les warnings"
echo ""

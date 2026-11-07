#!/bin/bash

set -e

echo "🚀 Démarrage du monitoring stack..."
echo ""

# Vérifier que Docker et Docker Compose sont installés
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé"
    exit 1
fi

# Démarrer les services
docker-compose up -d

echo ""
echo "✅ Services démarrés!"
echo ""
echo "📊 Accès aux services:"
echo "  - Grafana:     http://localhost:3000   (admin/admin)"
echo "  - Prometheus:  http://localhost:9090"
echo "  - Node Exporter: http://localhost:9100/metrics"
echo ""
echo "⏳ Attendez quelques secondes que Prometheus commence le scraping..."
sleep 5

echo ""
echo "📋 Vérification de la santé des services:"

# Vérifier Prometheus
if curl -s http://localhost:9090/-/healthy > /dev/null; then
    echo "  ✅ Prometheus est prêt"
else
    echo "  ⏳ Prometheus démarre..."
fi

# Vérifier Node Exporter
if curl -s http://localhost:9100/metrics > /dev/null; then
    echo "  ✅ Node Exporter est prêt"
else
    echo "  ❌ Node Exporter n'est pas accessible"
fi

# Vérifier Grafana
if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "  ✅ Grafana est prêt"
else
    echo "  ⏳ Grafana démarre..."
fi

echo ""
echo "🎯 Prochaines étapes:"
echo "  1. Ouvrir http://localhost:3000"
echo "  2. Se connecter avec admin/admin"
echo "  3. Vérifier la datasource Prometheus"
echo "  4. Consulter le dashboard 'System Metrics Dashboard'"
echo ""
echo "Pour arrêter: docker-compose down"

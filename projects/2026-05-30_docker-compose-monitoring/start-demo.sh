#!/bin/bash
# Script pour démarrer la stack et afficher les informations d'accès

set -e

echo "🚀 Démarrage de la stack DevOps Monitoring..."
docker-compose up -d

echo ""
echo "⏳ Attente du démarrage des services (30s)..."
sleep 30

echo ""
echo "✅ Stack démarrée avec succès!"
echo ""
echo "📊 Services disponibles:"
echo "  - 🌐 Application      : http://localhost:5000"
echo "  - 📈 Prometheus       : http://localhost:9090"
echo "  - 📊 Grafana          : http://localhost:3000 (admin/admin)"
echo "  - 🖥️  Node Exporter   : http://localhost:9100/metrics"
echo ""
echo "💡 Générer du trafic:"
echo "  while true; do curl -s http://localhost:5000/api/data > /dev/null; sleep 1; done"
echo ""
echo "📋 Logs:"
echo "  docker-compose logs -f app"
echo ""
echo "🛑 Arrêter:"
echo "  docker-compose down"

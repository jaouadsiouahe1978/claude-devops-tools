#!/bin/bash
# Script de démarrage de la stack Prometheus + Grafana

set -e

echo "🚀 Démarrage de la stack Prometheus + Grafana..."
echo ""

# Démarrage des services
docker-compose up -d

echo "✅ Services en cours de démarrage..."
echo ""

# Attendre que les services soient prêts
echo "⏳ Attente de la disponibilité des services..."
sleep 5

# Vérifier Prometheus
echo ""
echo "🔍 Vérification de Prometheus..."
if curl -s http://localhost:9090/-/healthy > /dev/null; then
    echo "✅ Prometheus est UP"
else
    echo "❌ Prometheus n'est pas disponible"
fi

# Vérifier Grafana
echo ""
echo "🔍 Vérification de Grafana..."
if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ Grafana est UP"
else
    echo "❌ Grafana n'est pas disponible"
fi

# Vérifier Node Exporter
echo ""
echo "🔍 Vérification de Node Exporter..."
if curl -s http://localhost:9100/metrics > /dev/null; then
    echo "✅ Node Exporter est UP"
else
    echo "❌ Node Exporter n'est pas disponible"
fi

# Vérifier AlertManager
echo ""
echo "🔍 Vérification d'AlertManager..."
if curl -s http://localhost:9093/-/healthy > /dev/null; then
    echo "✅ AlertManager est UP"
else
    echo "❌ AlertManager n'est pas disponible"
fi

echo ""
echo "========================================"
echo "✨ Stack Prometheus + Grafana démarrée!"
echo "========================================"
echo ""
echo "📊 Interfaces disponibles:"
echo "   • Prometheus: http://localhost:9090"
echo "   • Grafana:    http://localhost:3000 (admin/admin)"
echo "   • AlertMgr:   http://localhost:9093"
echo "   • Node Exp:   http://localhost:9100/metrics"
echo ""
echo "🎯 Prochaines étapes:"
echo "   1. Allez sur http://localhost:3000"
echo "   2. Connexion: admin / admin"
echo "   3. Vérifiez le dashboard 'System Monitoring'"
echo "   4. Testez les queries PromQL dans http://localhost:9090"
echo ""
echo "📝 Commands utiles:"
echo "   • docker-compose logs -f prometheus"
echo "   • docker-compose logs -f grafana"
echo "   • docker-compose down"
echo ""

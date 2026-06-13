#!/bin/bash
# Script pour tester les alertes

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔔 Test des alertes Prometheus"
echo ""

# Fonction pour afficher les alertes
check_alerts() {
    echo "📋 État des alertes Prometheus:"
    curl -s http://localhost:9090/api/v1/alerts | jq '.data.alerts[] | {state, alertname, labels}' 2>/dev/null || echo "Erreur: Impossible de récupérer les alertes"
    echo ""
}

# Fonction pour afficher les targets
check_targets() {
    echo "🎯 Targets scrape:"
    curl -s http://localhost:9090/api/v1/targets?state=active | jq '.data.activeTargets[] | {labels, scrapePool, lastScrape}' 2>/dev/null || echo "Erreur: Impossible de récupérer les targets"
    echo ""
}

# Afficher les targets
check_targets

# Afficher les alertes actuelles
check_alerts

# Test 1: Query PromQL simples
echo "🔬 Test des queries PromQL basiques:"
echo ""

echo "1️⃣ Utilisation CPU actuelle:"
curl -s "http://localhost:9090/api/v1/query?query=100*(1-avg(rate(node_cpu_seconds_total%7Bmode=%22idle%22%7D%5B5m%5D)))" | jq '.data.result[] | {metric: .metric.instance, value: .value[1]}' 2>/dev/null || echo "Erreur"
echo ""

echo "2️⃣ Mémoire disponible (MB):"
curl -s "http://localhost:9090/api/v1/query?query=node_memory_MemAvailable_bytes%2F1024%2F1024" | jq '.data.result[] | {metric: .metric.instance, value: .value[1]}' 2>/dev/null || echo "Erreur"
echo ""

echo "3️⃣ Disque disponible (%):"
curl -s "http://localhost:9090/api/v1/query?query=100*(1-(node_filesystem_avail_bytes%7Bfstype=%7E%22ext4%7Cxfs%22%7D%2Fnode_filesystem_size_bytes))" | jq '.data.result[] | {device: .metric.device, usage_percent: .value[1]}' 2>/dev/null || echo "Erreur"
echo ""

echo "✅ Tests de query PromQL complétés"
echo ""

# Test 2: Simuler une charge CPU (optionnel)
echo "⚠️ Pour tester les alertes de CPU élevé, vous pouvez:"
echo "   1. Trouver le node-exporter: docker ps | grep node-exporter"
echo "   2. Générer une charge: docker exec <container> stress --cpu 2 --timeout 60s"
echo "   3. Observer l'alerte dans: http://localhost:9090/alerts"
echo ""

echo "🔗 Liens utiles:"
echo "   • Prometheus API: http://localhost:9090/api/v1/alerts"
echo "   • Grafana Alerts: http://localhost:3000/alerting/list"
echo "   • AlertManager: http://localhost:9093/#/alerts"
echo ""

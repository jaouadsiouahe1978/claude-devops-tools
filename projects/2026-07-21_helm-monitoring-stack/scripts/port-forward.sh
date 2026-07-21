#!/bin/bash

# Script de port-forwarding pour accéder aux dashboards
# Usage: ./scripts/port-forward.sh

NAMESPACE="monitoring"

echo "🌐 Configuration du port-forwarding..."
echo ""
echo "📊 Grafana sera accessible sur: http://localhost:3000"
echo "   Identifiants par défaut: admin / admin"
echo ""
echo "📊 Prometheus sera accessible sur: http://localhost:9090"
echo ""

echo "Démarrage du port-forwarding (Ctrl+C pour arrêter)..."
echo ""

# Port-forward Grafana
kubectl port-forward -n $NAMESPACE svc/grafana 3000:80 &
GRAFANA_PID=$!

# Port-forward Prometheus
kubectl port-forward -n $NAMESPACE svc/prometheus 9090:9090 &
PROMETHEUS_PID=$!

# Port-forward node-exporter (optionnel)
# kubectl port-forward -n $NAMESPACE svc/node-exporter 9100:9100 &
# NODE_EXPORTER_PID=$!

# Catch Ctrl+C
trap "kill $GRAFANA_PID $PROMETHEUS_PID; exit" INT

# Attendre l'arrêt
wait

echo "Port-forwarding arrêté."

#!/bin/bash

echo "🧪 Testing Alert System..."

echo "📊 Checking Prometheus alerts..."
curl -s http://localhost:9090/api/v1/alerts | jq '.data.alerts[] | {alertname, state}'

echo ""
echo "🔔 Checking AlertManager..."
curl -s http://localhost:9093/api/v1/alerts | jq '.[] | {labels, status}'

echo ""
echo "✨ Alert test completed!"

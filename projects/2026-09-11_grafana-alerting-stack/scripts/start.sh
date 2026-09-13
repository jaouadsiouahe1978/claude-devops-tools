#!/bin/bash

echo "🚀 Starting Grafana + Prometheus + AlertManager Stack..."
docker-compose up -d

sleep 15

echo "✅ Stack started!"
echo ""
echo "📊 Access services at:"
echo "   Grafana:       http://localhost:3000 (admin/admin)"
echo "   Prometheus:    http://localhost:9090"
echo "   AlertManager:  http://localhost:9093"
echo ""
echo "View logs with: docker-compose logs -f"

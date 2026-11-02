#!/bin/bash

set -e

echo "🚀 Setting up Prometheus & Grafana Monitoring Stack..."
echo ""

# Check Docker and Docker Compose
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed"
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Stop and remove existing containers
echo "🧹 Cleaning up existing containers..."
docker-compose down -v 2>/dev/null || true
echo "✅ Cleaned up"
echo ""

# Build and start services
echo "🏗️ Building and starting services..."
docker-compose up -d
echo "✅ Services started"
echo ""

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
for i in {1..30}; do
    if curl -s http://localhost:9090/-/healthy > /dev/null 2>&1; then
        echo "✅ Prometheus is healthy"
        break
    fi
    echo "⏳ Waiting for Prometheus... ($i/30)"
    sleep 2
done

for i in {1..30}; do
    if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
        echo "✅ Grafana is healthy"
        break
    fi
    echo "⏳ Waiting for Grafana... ($i/30)"
    sleep 2
done

for i in {1..30}; do
    if curl -s http://localhost:8080/health > /dev/null 2>&1; then
        echo "✅ Application is healthy"
        break
    fi
    echo "⏳ Waiting for Application... ($i/30)"
    sleep 2
done

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "✨ Monitoring Stack is Ready!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📊 Access the services:"
echo ""
echo "  🔍 Prometheus:  http://localhost:9090"
echo "     - Targets: http://localhost:9090/targets"
echo "     - Graph: http://localhost:9090/graph"
echo ""
echo "  📈 Grafana:     http://localhost:3000"
echo "     - Login: admin / admin"
echo "     - Dashboards will auto-load"
echo ""
echo "  🚀 Application: http://localhost:8080"
echo "     - Metrics: http://localhost:8080/metrics"
echo "     - Health: http://localhost:8080/health"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📝 Next steps:"
echo "  1. Open http://localhost:3000 and login with admin/admin"
echo "  2. Check the 'System & Application Metrics' dashboard"
echo "  3. Try accessing http://localhost:8080/api/v1/data to generate metrics"
echo "  4. Check Prometheus targets at http://localhost:9090/targets"
echo ""
echo "🧹 To cleanup:"
echo "  docker-compose down -v"
echo ""

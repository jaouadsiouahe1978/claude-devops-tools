#!/bin/bash

# Setup script for monitoring stack
# This script initializes and starts the monitoring infrastructure

set -e

echo "🚀 Starting Docker Compose Monitoring Stack..."

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed. Please install Docker Desktop or docker-compose."
    exit 1
fi

# Create necessary directories
echo "📁 Creating directory structure..."
mkdir -p dashboards

# Start services
echo "🐳 Starting containers..."
docker-compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check if Prometheus is ready
echo "✅ Checking Prometheus..."
if curl -s http://localhost:9090/-/healthy > /dev/null; then
    echo "✅ Prometheus is running on http://localhost:9090"
else
    echo "❌ Prometheus health check failed"
fi

# Check if Grafana is ready
echo "✅ Checking Grafana..."
if curl -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ Grafana is running on http://localhost:3000"
    echo "   Default credentials: admin / admin"
else
    echo "❌ Grafana health check failed"
fi

# Check if Node Exporter is ready
echo "✅ Checking Node Exporter..."
if curl -s http://localhost:9100/metrics > /dev/null; then
    echo "✅ Node Exporter is running on http://localhost:9100"
else
    echo "❌ Node Exporter health check failed"
fi

# Check if AlertManager is ready
echo "✅ Checking AlertManager..."
if curl -s http://localhost:9093/-/healthy > /dev/null; then
    echo "✅ AlertManager is running on http://localhost:9093"
else
    echo "❌ AlertManager health check failed"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✨ Monitoring Stack is ready!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📊 Access the services:"
echo "   • Prometheus: http://localhost:9090"
echo "   • Grafana:    http://localhost:3000 (admin/admin)"
echo "   • AlertManager: http://localhost:9093"
echo "   • Node Exporter: http://localhost:9100/metrics"
echo ""
echo "📝 Next steps:"
echo "   1. Open http://localhost:3000 and login with admin/admin"
echo "   2. Configure Slack/Email in AlertManager (alertmanager.yml)"
echo "   3. Import Node Exporter dashboard (ID: 1860) in Grafana"
echo "   4. Test alerts by generating load"
echo ""
echo "📚 To view logs:"
echo "   docker-compose logs -f prometheus"
echo "   docker-compose logs -f grafana"
echo ""
echo "🛑 To stop the stack:"
echo "   docker-compose down"
echo ""

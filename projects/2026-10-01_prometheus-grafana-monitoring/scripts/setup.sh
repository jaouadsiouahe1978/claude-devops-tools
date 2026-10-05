#!/bin/bash

set -e

echo "🚀 Setting up Prometheus + Grafana Monitoring Stack..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if Docker is running
echo -n "Checking Docker... "
if ! docker ps &> /dev/null; then
    echo -e "${RED}ERROR${NC}: Docker is not running"
    exit 1
fi
echo -e "${GREEN}OK${NC}"

# Start services
echo -n "Starting monitoring stack... "
docker-compose up -d
echo -e "${GREEN}OK${NC}"

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 10

# Check Prometheus
echo -n "Checking Prometheus... "
if curl -s http://localhost:9090 > /dev/null; then
    echo -e "${GREEN}OK${NC} (http://localhost:9090)"
else
    echo -e "${RED}FAILED${NC}"
fi

# Check Grafana
echo -n "Checking Grafana... "
if curl -s http://localhost:3000 > /dev/null; then
    echo -e "${GREEN}OK${NC} (http://localhost:3000)"
else
    echo -e "${RED}FAILED${NC}"
fi

# Check node-exporter
echo -n "Checking node-exporter... "
if curl -s http://localhost:9100/metrics > /dev/null; then
    echo -e "${GREEN}OK${NC} (http://localhost:9100)"
else
    echo -e "${RED}FAILED${NC}"
fi

# Check cAdvisor
echo -n "Checking cAdvisor... "
if curl -s http://localhost:8080 > /dev/null; then
    echo -e "${GREEN}OK${NC} (http://localhost:8080)"
else
    echo -e "${RED}FAILED${NC}"
fi

echo ""
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo ""
echo "📊 Access Points:"
echo "  • Prometheus:   http://localhost:9090"
echo "  • Grafana:      http://localhost:3000 (admin:admin)"
echo "  • node-exporter: http://localhost:9100/metrics"
echo "  • cAdvisor:     http://localhost:8080"
echo "  • AlertManager: http://localhost:9093"
echo ""
echo "📝 Next Steps:"
echo "  1. Open Grafana at http://localhost:3000"
echo "  2. Change admin password (default: admin)"
echo "  3. Verify dashboards are loaded"
echo "  4. Check Prometheus targets at http://localhost:9090/targets"
echo ""

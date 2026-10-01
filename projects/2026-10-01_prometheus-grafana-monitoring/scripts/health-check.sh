#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🏥 Health Check: Prometheus + Grafana Stack"
echo "==========================================="
echo ""

FAILED=0
PASSED=0

check_service() {
    local name=$1
    local url=$2
    local expected_code=${3:-200}

    echo -n "Checking $name... "

    response=$(curl -s -o /dev/null -w "%{http_code}" $url)

    if [ "$response" = "$expected_code" ]; then
        echo -e "${GREEN}✅ PASS${NC} (HTTP $response)"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} (HTTP $response, expected $expected_code)"
        ((FAILED++))
    fi
}

check_docker() {
    local container=$1
    echo -n "Checking $container container... "

    if docker ps --format "table {{.Names}}" | grep -q "^${container}$"; then
        echo -e "${GREEN}✅ PASS${NC} (Running)"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} (Not running)"
        ((FAILED++))
    fi
}

# Service Checks
check_docker "prometheus"
check_docker "grafana"
check_docker "node-exporter"
check_docker "cadvisor"
check_docker "postgres"
check_docker "postgres-exporter"
check_docker "nginx"
check_docker "nginx-exporter"
check_docker "alertmanager"

echo ""
check_service "Prometheus Web UI" "http://localhost:9090" 200
check_service "Grafana Web UI" "http://localhost:3000" 200
check_service "node-exporter" "http://localhost:9100/metrics" 200
check_service "cAdvisor" "http://localhost:8080" 200
check_service "postgres-exporter" "http://localhost:9187/metrics" 200
check_service "nginx-exporter" "http://localhost:4040/metrics" 200
check_service "AlertManager" "http://localhost:9093" 200

# Prometheus Targets
echo ""
echo "Checking Prometheus Targets..."

targets=$(curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets | length')
healthy=$(curl -s http://localhost:9090/api/v1/targets | jq '[.data.activeTargets[] | select(.health == "up")] | length')

echo -n "  Total targets: $targets, Healthy: $healthy... "
if [ "$targets" -eq "$healthy" ] && [ "$targets" -gt 0 ]; then
    echo -e "${GREEN}✅ PASS${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠️  WARNING${NC}"
fi

# Disk Space
echo ""
echo "Checking Disk Space..."

usage=$(docker exec prometheus df /prometheus | tail -1 | awk '{print $5}' | sed 's/%//')
echo -n "  Prometheus disk usage: $usage%... "

if [ "$usage" -lt 80 ]; then
    echo -e "${GREEN}✅ PASS${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠️  WARNING (Above 80%)${NC}"
fi

# Memory
echo ""
echo "Checking Memory Usage..."

prom_mem=$(docker stats prometheus --no-stream | tail -1 | awk '{print $6}' | sed 's/MiB//')
echo -n "  Prometheus memory: ${prom_mem}MiB... "

if (( $(echo "$prom_mem < 800" | bc -l) )); then
    echo -e "${GREEN}✅ PASS${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠️  HIGH (>800MiB)${NC}"
fi

# Summary
echo ""
echo "==========================================="
echo "Summary: ${GREEN}$PASSED Passed${NC}, ${RED}$FAILED Failed${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some checks failed!${NC}"
    exit 1
fi

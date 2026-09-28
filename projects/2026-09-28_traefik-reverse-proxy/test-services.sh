#!/bin/bash
# Test script for Traefik services

echo "========================================"
echo "Traefik Services Test"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

test_url() {
    local url=$1
    local name=$2

    echo -n "Testing $name ($url)... "

    if response=$(curl -s -w "\n%{http_code}" "$url" 2>/dev/null); then
        status_code=$(echo "$response" | tail -n 1)
        if [ "$status_code" = "200" ]; then
            echo -e "${GREEN}✓ OK (HTTP $status_code)${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠ HTTP $status_code${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ FAILED (Connection error)${NC}"
        return 1
    fi
}

echo "Checking Traefik status..."
echo ""

# Test endpoints
test_url "http://web1.localhost" "Web Service 1 (Nginx)"
test_url "http://web2.localhost" "Web Service 2 (Apache)"
test_url "http://api.localhost" "API Service (Flask)"
test_url "http://api.localhost/health" "API Health Check"
test_url "http://api.localhost/api/services" "API Services List"

echo ""
echo "========================================"
echo "API Service Tests"
echo "========================================"
echo ""

# Test API endpoints
echo "1. Get all services:"
curl -s http://api.localhost/api/services | jq . || echo "Error: jq not available"

echo ""
echo "2. Get request information:"
curl -s http://api.localhost/api/request-info | jq .method || echo "Error: jq not available"

echo ""
echo "3. Health check:"
curl -s http://api.localhost/health | jq . || echo "Error: jq not available"

echo ""
echo "4. Echo test (POST):"
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"message":"Hello from Traefik"}' \
  http://api.localhost/api/echo | jq . || echo "Error: jq not available"

echo ""
echo "========================================"
echo "Test completed!"
echo "========================================"

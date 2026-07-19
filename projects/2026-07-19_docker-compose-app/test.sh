#!/bin/bash

set -e

echo "🧪 Testing DevOps Multi-Container App"
echo "======================================"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

test_endpoint() {
    local name=$1
    local method=$2
    local url=$3
    local expected_code=$4
    local data=$5

    echo -n "Testing: $name... "

    if [ "$method" = "POST" ]; then
        response=$(curl -s -X POST "$url" -H "Content-Type: application/json" -d "$data" -w "\n%{http_code}")
    else
        response=$(curl -s -X GET "$url" -w "\n%{http_code}")
    fi

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)

    if [ "$http_code" = "$expected_code" ]; then
        echo -e "${GREEN}✓ PASSED${NC} (HTTP $http_code)"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC} (Expected $expected_code, got $http_code)"
        ((TESTS_FAILED++))
    fi
}

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 5

# Test endpoints
test_endpoint "Health Check" "GET" "http://localhost:3000/health" "200"
test_endpoint "List Users" "GET" "http://localhost:3000/api/users" "200"
test_endpoint "Create User" "POST" "http://localhost:3000/api/users" "201" '{"name":"Test User","email":"test@example.com"}'
test_endpoint "Metrics" "GET" "http://localhost:3000/metrics" "200"
test_endpoint "Frontend" "GET" "http://localhost/" "200"

# Docker compose checks
echo ""
echo "Checking Docker Compose services..."
SERVICES=$(docker compose ps --quiet)
if [ -z "$SERVICES" ]; then
    echo -e "${RED}✗ FAILED${NC} - No containers running"
    ((TESTS_FAILED++))
else
    echo -e "${GREEN}✓ PASSED${NC} - All containers running"
    ((TESTS_PASSED++))
fi

# Network connectivity
echo "Checking network connectivity..."
docker compose exec -T backend curl -s http://postgres:5432 > /dev/null 2>&1 && \
    echo -e "${GREEN}✓ PASSED${NC} - Backend can reach PostgreSQL" && ((TESTS_PASSED++)) || \
    (echo -e "${RED}✗ FAILED${NC} - Backend cannot reach PostgreSQL" && ((TESTS_FAILED++)))

# Summary
echo ""
echo "======================================"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi

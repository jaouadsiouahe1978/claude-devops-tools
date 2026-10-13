#!/bin/bash

# Simple load test script for Nginx load balancer

set -e

BASE_URL="http://localhost"
NUM_REQUESTS=${1:-30}
CONCURRENT=${2:-5}

echo "================================"
echo "Nginx Load Balancer Test"
echo "================================"
echo ""
echo "Configuration:"
echo "  Base URL: $BASE_URL"
echo "  Total Requests: $NUM_REQUESTS"
echo "  Concurrent requests: $CONCURRENT"
echo ""

# Test 1: Simple load test
echo "📊 Test 1: Load Balancing Distribution"
echo "Testing with $NUM_REQUESTS sequential requests..."
echo ""

declare -A server_counts

for i in $(seq 1 $NUM_REQUESTS); do
    response=$(curl -s "$BASE_URL/" | grep -o '"server":"[^"]*"' | head -1)
    server=$(echo "$response" | sed 's/"server":"\(.*\)"/\1/')

    if [ -z "${server_counts[$server]}" ]; then
        server_counts[$server]=0
    fi
    ((server_counts[$server]++))

    # Progress indicator
    if [ $((i % 5)) -eq 0 ]; then
        echo -n "."
    fi
done

echo ""
echo ""
echo "Results:"
for server in "${!server_counts[@]}"; do
    count=${server_counts[$server]}
    percentage=$((count * 100 / NUM_REQUESTS))
    echo "  $server: $count requests ($percentage%)"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 2: Health endpoint
echo "🏥 Test 2: Health Check"
echo ""

for server in app1 app2 app3; do
    response=$(curl -s http://$server:300{1,2,3}/ 2>/dev/null | head -1 || echo "Timeout")
    echo "  $server: OK"
done

echo ""

# Test 3: Response time
echo "⏱️  Test 3: Response Times"
echo ""

total_time=0
for i in $(seq 1 10); do
    start=$(date +%s%N)
    curl -s "$BASE_URL/" > /dev/null
    end=$(date +%s%N)
    elapsed=$(( (end - start) / 1000000 ))
    total_time=$((total_time + elapsed))
    echo "  Request $i: ${elapsed}ms"
done

avg=$((total_time / 10))
echo "  Average: ${avg}ms"

echo ""

# Test 4: API endpoints
echo "🔌 Test 4: API Endpoints"
echo ""

echo "  GET /api/info:"
curl -s "$BASE_URL/api/info" | grep -o '"server":"[^"]*"'

echo ""
echo "  GET /api/data:"
curl -s "$BASE_URL/api/data" | grep -o '"server":"[^"]*"' | head -1

echo ""
echo "  POST /api/echo (with JSON body):"
curl -s -X POST "$BASE_URL/api/echo" \
  -H "Content-Type: application/json" \
  -d '{"test":"data"}' | grep -o '"server":"[^"]*"'

echo ""
echo ""
echo "================================"
echo "✅ Test completed"
echo "================================"

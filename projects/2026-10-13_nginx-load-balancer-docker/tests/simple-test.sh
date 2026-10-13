#!/bin/bash

# Simple test script to verify load balancer is working

echo "Testing Nginx Load Balancer..."
echo ""

BASE_URL="http://localhost"

# Check if server is responding
echo "1️⃣  Testing basic connectivity..."
if curl -s -f "$BASE_URL/" > /dev/null 2>&1; then
    echo "   ✅ Server is responding"
else
    echo "   ❌ Server is not responding"
    exit 1
fi

echo ""
echo "2️⃣  Testing load balancing (checking which server handles requests)..."
echo ""

for i in {1..6}; do
    response=$(curl -s "$BASE_URL/" | jq -r '.server // .Server // "unknown"' 2>/dev/null || echo "error")
    echo "   Request $i → $response"
done

echo ""
echo "3️⃣  Testing health endpoint..."
curl -s "$BASE_URL/health" | jq . || echo "Health check failed"

echo ""
echo "4️⃣  Testing API endpoint..."
curl -s "$BASE_URL/api/info" | jq '.server' || echo "API test failed"

echo ""
echo "✅ Basic tests completed"

#!/bin/bash
# Script pour tester les endpoints API

BASE_URL="${1:-https://localhost}"

echo "🧪 Test des Endpoints API - Nginx Load Balancer"
echo "================================================"
echo "URL de base: $BASE_URL"
echo ""

# Fonction pour afficher les résultats
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📍 $description"
    echo "   Endpoint: $method $endpoint"
    echo ""

    if [ -n "$data" ]; then
        echo "📤 Payload:"
        echo "$data" | jq . 2>/dev/null || echo "$data"
        echo ""
        curl -s -k -X "$method" "$BASE_URL$endpoint" \
             -H "Content-Type: application/json" \
             -d "$data" | jq . 2>/dev/null || curl -s -k -X "$method" "$BASE_URL$endpoint" -d "$data"
    else
        curl -s -k -X "$method" "$BASE_URL$endpoint" | jq . 2>/dev/null || curl -s -k -X "$method" "$BASE_URL$endpoint"
    fi

    echo ""
    echo ""
}

# Tests des endpoints
test_endpoint "GET" "/" "Route d'accueil (home)"

test_endpoint "GET" "/health" "Health check"

test_endpoint "GET" "/status" "Status du backend"

test_endpoint "GET" "/api/users" "Get all users"

test_endpoint "GET" "/api/users/1" "Get user with ID 1"

test_endpoint "GET" "/api/users/999" "Get non-existent user (404)"

test_endpoint "GET" "/api/stats" "Get backend statistics"

test_endpoint "POST" "/api/echo" '{"message":"Hello from Nginx Load Balancer","test":true}' "Echo POST data"

# Test HTTP to HTTPS redirect
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 Test HTTP to HTTPS Redirect"
echo "   Endpoint: GET http://localhost/"
echo ""
curl -s -i -L http://localhost/ 2>/dev/null | head -20
echo ""
echo ""

# Test metrics endpoint
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 Metrics Endpoint (Nginx stub_status)"
echo "   Endpoint: GET https://localhost/metrics"
echo ""
curl -s -k https://127.0.0.1/metrics 2>/dev/null || echo "Note: Metrics may only be accessible from localhost"
echo ""

echo "✅ Tests terminés!"

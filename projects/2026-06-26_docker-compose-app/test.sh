#!/bin/bash

echo "🧪 Testing DevOps Application"
echo "=============================="
echo ""

BASE_URL="http://localhost"
DELAY=2

echo "⏳ Attente que les services soient prêts..."
sleep $DELAY

echo ""
echo "1️⃣ Test de la racine (/)"
echo "---"
curl -s $BASE_URL/ | jq . || echo "❌ Erreur"

echo ""
echo ""
echo "2️⃣ Test du statut API (/api/status)"
echo "---"
curl -s $BASE_URL/api/status | jq . || echo "❌ Erreur"

echo ""
echo ""
echo "3️⃣ Test des utilisateurs (/api/users)"
echo "---"
curl -s $BASE_URL/api/users | jq . || echo "❌ Erreur"

echo ""
echo ""
echo "4️⃣ Créer un nouvel utilisateur (POST /api/users)"
echo "---"
curl -s -X POST $BASE_URL/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test.'$(date +%s)'@example.com"}' \
  | jq . || echo "❌ Erreur"

echo ""
echo ""
echo "5️⃣ Test cache Redis - Set value"
echo "---"
curl -s -X POST $BASE_URL/api/cache/test_key \
  -H "Content-Type: application/json" \
  -d '{"value":"test_value","ttl":3600}' \
  | jq . || echo "❌ Erreur"

echo ""
echo ""
echo "6️⃣ Test cache Redis - Get value"
echo "---"
curl -s $BASE_URL/api/cache/test_key | jq . || echo "❌ Erreur"

echo ""
echo ""
echo "✅ Tests terminés!"

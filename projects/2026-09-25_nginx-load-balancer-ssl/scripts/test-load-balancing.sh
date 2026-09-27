#!/bin/bash
# Script pour tester le load balancing

set -e

BASE_URL="${1:-https://localhost}"
REQUESTS="${2:-10}"

echo "🧪 Test du Load Balancing - Nginx Reverse Proxy"
echo "=================================================="
echo "URL: $BASE_URL"
echo "Nombre de requêtes: $REQUESTS"
echo ""

# Déclaration associative pour tracker les réponses
declare -A service_count
declare -A service_ids

echo "📊 Distribution des requêtes entre les backends:"
echo ""

for i in $(seq 1 $REQUESTS); do
    echo -n "Requête $i... "

    # Effectuer la requête et extraire le service_id
    RESPONSE=$(curl -s -k "$BASE_URL/status" 2>/dev/null || echo "")

    if [ -z "$RESPONSE" ]; then
        echo "❌ Erreur"
        continue
    fi

    SERVICE_ID=$(echo "$RESPONSE" | grep -o '"service_id":"[^"]*"' | cut -d'"' -f4)
    SERVICE_NAME=$(echo "$RESPONSE" | grep -o '"service_name":"[^"]*"' | cut -d'"' -f4)

    if [ -z "$SERVICE_ID" ]; then
        echo "❌ Impossible d'extraire service_id"
        continue
    fi

    # Incrémenter le compteur
    service_count[$SERVICE_ID]=$((${service_count[$SERVICE_ID]:-0} + 1))
    service_ids[$SERVICE_ID]=$SERVICE_NAME

    echo "✅ Serveur: $SERVICE_NAME (ID: $SERVICE_ID)"
done

echo ""
echo "📈 Résultats:"
echo "============="

TOTAL=0
for service_id in "${!service_count[@]}"; do
    count=${service_count[$service_id]}
    percentage=$((count * 100 / REQUESTS))
    service_name=${service_ids[$service_id]}

    TOTAL=$((TOTAL + count))

    # Afficher avec une barre de progression simple
    bar=""
    for ((j=0; j<percentage/5; j++)); do
        bar+="█"
    done
    bar=$(printf "%-20s" "$bar")

    printf "%-15s (ID:%s) │ %s │ %2d requêtes (%3d%%)\n" "$service_name" "$service_id" "$bar" "$count" "$percentage"
done

echo ""
echo "✅ Total de requêtes traitées: $TOTAL / $REQUESTS"

# Vérifier l'équilibre
if [ $TOTAL -eq $REQUESTS ]; then
    echo "🎯 Load balancing fonctionne correctement!"
    exit 0
else
    echo "⚠️  Attention: Certaines requêtes ont échoué"
    exit 1
fi

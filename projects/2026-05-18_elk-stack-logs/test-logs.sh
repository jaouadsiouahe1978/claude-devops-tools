#!/bin/bash

# Script pour générer des logs de test pour ELK Stack
# Permet de tester les pipelines Logstash et les visualisations Kibana

set -e

echo "🚀 Génération de logs de test pour ELK Stack..."

BASE_URL="http://localhost"
ITERATIONS=${1:-10}

echo "📊 Générant $ITERATIONS requêtes..."

for i in $(seq 1 $ITERATIONS); do
    # Requête réussie (200 OK)
    curl -s "$BASE_URL/" > /dev/null
    echo "✓ Requête $i/4 : GET / (200)"

    # Requête non trouvée (404)
    curl -s "$BASE_URL/error404" > /dev/null 2>&1 || true
    echo "✓ Requête $i/4 : GET /error404 (404)"

    # Erreur serveur (500)
    curl -s "$BASE_URL/error500" > /dev/null 2>&1 || true
    echo "✓ Requête $i/4 : GET /error500 (500)"

    # Redirect (302)
    curl -s -L "$BASE_URL/redirect" > /dev/null 2>&1 || true
    echo "✓ Requête $i/4 : GET /redirect (302)"

    # Attendre un peu
    sleep 0.5
done

echo ""
echo "✅ Logs générés avec succès!"
echo ""
echo "📍 Les logs sont disponibles dans Kibana:"
echo "   URL: http://localhost:5601"
echo "   User: elastic"
echo "   Password: changeme"
echo ""
echo "💡 Étapes pour visualiser les logs:"
echo "   1. Aller sur http://localhost:5601"
echo "   2. Cliquer sur 'Create index pattern'"
echo "   3. Entrer 'logstash-*' comme pattern"
echo "   4. Sélectionner '@timestamp' comme timestamp field"
echo "   5. Créer le pattern"
echo "   6. Aller dans 'Discover' pour explorer les logs"
echo ""

# Vérifier les indices dans Elasticsearch
echo "📈 Indices Elasticsearch disponibles:"
curl -s -u elastic:changeme http://localhost:9200/_cat/indices | grep logstash || echo "   Aucun indice trouvé. Attendre 10s et relancer."

# Compter les logs
LOG_COUNT=$(curl -s -u elastic:changeme -X GET "http://localhost:9200/logstash-*/_count" 2>/dev/null | grep -o '"count":[0-9]*' | cut -d: -f2 || echo "0")
echo ""
echo "📊 Nombre de logs indexés: $LOG_COUNT"

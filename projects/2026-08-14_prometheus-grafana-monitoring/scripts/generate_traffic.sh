#!/bin/bash

# Script pour générer du trafic sur l'application

APP_URL="${APP_URL:-http://localhost:3000}"
DURATION="${DURATION:-300}"  # Durée en secondes (par défaut 5 minutes)
INTERVAL="${INTERVAL:-1}"    # Intervalle entre les requêtes en secondes

echo "🚀 Génération de trafic sur $APP_URL"
echo "📊 Durée: ${DURATION}s, Intervalle: ${INTERVAL}s"
echo ""

START_TIME=$(date +%s)
END_TIME=$((START_TIME + DURATION))
REQUEST_COUNT=0

endpoints=(
  "/api/data"
  "/api/process"
  "/api/error"
  "/"
  "/health"
)

while [ $(date +%s) -lt $END_TIME ]; do
  # Sélectionner un endpoint aléatoire
  endpoint=${endpoints[$((RANDOM % ${#endpoints[@]}))]}

  # Effectuer la requête
  response=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL$endpoint")
  REQUEST_COUNT=$((REQUEST_COUNT + 1))

  # Afficher le résultat
  emoji="✓"
  if [[ $response == 5* ]]; then
    emoji="❌"
  elif [[ $response == 4* ]]; then
    emoji="⚠️"
  fi

  echo "[$REQUEST_COUNT] $emoji $endpoint - HTTP $response"

  # Attendre avant la prochaine requête
  sleep $INTERVAL
done

echo ""
echo "✅ Trafic arrêté!"
echo "📈 Total de requêtes: $REQUEST_COUNT"
echo "🎯 Rendez-vous sur http://localhost:3001 pour voir les métriques dans Grafana"

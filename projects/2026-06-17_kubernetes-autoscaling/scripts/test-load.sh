#!/bin/bash
#
# Script pour générer de la charge sur l'application et tester l'autoscaling
# Usage: ./test-load.sh [duration_minutes] [concurrency]
#

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paramètres
DURATION_MINUTES=${1:-5}
CONCURRENCY=${2:-5}
SERVICE_URL="http://localhost:5000"
ENDPOINT="/cpu-intensive"

echo -e "${BLUE}=== Kubernetes Autoscaling Load Test ===${NC}"
echo "Service URL: $SERVICE_URL"
echo "Endpoint: $ENDPOINT"
echo "Duration: $DURATION_MINUTES minutes"
echo "Concurrency: $CONCURRENCY parallel requests"
echo ""

# Vérifier que le service est accessible
echo -e "${YELLOW}[*] Checking service availability...${NC}"
if ! curl -s -f "$SERVICE_URL/" > /dev/null 2>&1; then
    echo -e "${RED}[!] Service not accessible at $SERVICE_URL${NC}"
    echo "Make sure you have port-forward set up:"
    echo "  kubectl port-forward svc/devops-app 5000:5000"
    exit 1
fi

echo -e "${GREEN}[✓] Service is accessible${NC}"
echo ""

# Variables de monitoring
START_TIME=$(date +%s)
END_TIME=$((START_TIME + (DURATION_MINUTES * 60)))
REQUEST_COUNT=0
SUCCESS_COUNT=0
ERROR_COUNT=0

echo -e "${YELLOW}[*] Starting load generation...${NC}"
echo ""

# Fonction pour faire une requête
make_request() {
    local url="$1"
    local start=$(date +%s%N)

    if response=$(curl -s -w "\n%{http_code}" -m 30 "$url" 2>/dev/null); then
        http_code=$(echo "$response" | tail -n 1)
        elapsed=$(( ($(date +%s%N) - start) / 1000000 ))

        if [[ "$http_code" -eq 200 ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

export -f make_request

# Générer la charge
while [ $(date +%s) -lt $END_TIME ]; do
    # Lancer des requêtes en parallèle
    for ((i=0; i<CONCURRENCY; i++)); do
        {
            if make_request "$SERVICE_URL$ENDPOINT"; then
                ((SUCCESS_COUNT++))
            else
                ((ERROR_COUNT++))
            fi
            ((REQUEST_COUNT++))
        } &
    done

    # Attendre que toutes les requêtes en arrière-plan se terminent
    wait

    # Afficher les statistiques
    elapsed_total=$(($(date +%s) - START_TIME))
    remaining=$((DURATION_MINUTES * 60 - elapsed_total))

    echo -e "${BLUE}[$(date +'%H:%M:%S')] Requests: $REQUEST_COUNT | Success: ${GREEN}$SUCCESS_COUNT${NC}${BLUE} | Errors: ${RED}$ERROR_COUNT${NC}${BLUE} | Remaining: ${YELLOW}${remaining}s${NC}${BLUE} | RPS: $((REQUEST_COUNT / (elapsed_total + 1)))${NC}"

    # Afficher les pods en temps réel
    CURRENT_PODS=$(kubectl get pods -l app=devops-app --no-headers 2>/dev/null | wc -l)
    echo -e "  Current pods: ${YELLOW}$CURRENT_PODS${NC}"
    echo ""

    # Petit délai entre les batches
    sleep 2
done

echo ""
echo -e "${BLUE}=== Test Completed ===${NC}"
echo "Total Requests: $REQUEST_COUNT"
echo -e "Successful: ${GREEN}$SUCCESS_COUNT${NC}"
echo -e "Errors: ${RED}$ERROR_COUNT${NC}"
echo "Success Rate: $(( (SUCCESS_COUNT * 100) / (REQUEST_COUNT + 1) ))%"
echo ""

echo -e "${YELLOW}[*] Monitor the autoscaling with:${NC}"
echo "  kubectl get hpa -w"
echo "  kubectl get pods -w"
echo "  kubectl top pods"

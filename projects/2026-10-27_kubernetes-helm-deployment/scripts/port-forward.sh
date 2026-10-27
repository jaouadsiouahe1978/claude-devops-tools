#!/bin/bash

# Couleurs
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

RELEASE_NAME="${1:-myapp}"
NAMESPACE="${2:-myapp}"

echo -e "${BLUE}🔌 Port Forwarding MyApp${NC}"
echo ""
echo -e "${YELLOW}Service disponibles:${NC}"
echo "1. Frontend (port 8080)"
echo "2. API (port 5000)"
echo "3. Database (port 5432)"
echo "4. Tous"
echo ""

read -p "Choisir un service (1-4): " choice

case $choice in
    1)
        echo -e "${GREEN}Port forwarding Frontend...${NC}"
        kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-frontend 8080:80
        ;;
    2)
        echo -e "${GREEN}Port forwarding API...${NC}"
        kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-api 5000:5000
        ;;
    3)
        echo -e "${GREEN}Port forwarding Database...${NC}"
        kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-postgres 5432:5432
        ;;
    4)
        echo -e "${GREEN}Port forwarding tous les services...${NC}"
        (kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-frontend 8080:80 &)
        (kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-api 5000:5000 &)
        (kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-postgres 5432:5432 &)

        echo -e "${YELLOW}Services disponibles:${NC}"
        echo "  - Frontend: http://localhost:8080"
        echo "  - API: http://localhost:5000"
        echo "  - Database: localhost:5432"
        echo ""
        echo -e "${YELLOW}Appuyez sur Ctrl+C pour arrêter${NC}"
        wait
        ;;
    *)
        echo "Choix invalide"
        exit 1
        ;;
esac

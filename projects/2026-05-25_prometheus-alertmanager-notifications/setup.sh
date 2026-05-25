#!/bin/bash

set -e

echo "🚀 Configuration du monitoring Prometheus + AlertManager"
echo "========================================================"

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Créer .env s'il n'existe pas
if [ ! -f .env ]; then
    echo -e "${BLUE}📝 Création du fichier .env...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✅ .env créé${NC}"
fi

# Créer les répertoires nécessaires
echo -e "${BLUE}📁 Création des répertoires...${NC}"
mkdir -p prometheus/alerts
mkdir -p alertmanager/templates
echo -e "${GREEN}✅ Répertoires créés${NC}"

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker n'est pas installé${NC}"
    exit 1
fi

echo -e "${BLUE}🐳 Vérification Docker...${NC}"
docker --version
echo -e "${GREEN}✅ Docker OK${NC}"

# Vérifier docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}⚠️  docker-compose n'est pas installé${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Vérification docker-compose...${NC}"
docker-compose --version
echo -e "${GREEN}✅ docker-compose OK${NC}"

# Demander la configuration Slack (optionnel)
echo ""
echo -e "${BLUE}🔧 Configuration optionnelle${NC}"
read -p "Voulez-vous configurer Slack? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Entrez votre webhook Slack URL: " SLACK_URL
    sed -i "s|YOUR_SLACK_WEBHOOK_URL_HERE|$SLACK_URL|g" alertmanager/alertmanager.yml
    echo -e "${GREEN}✅ Webhook Slack configuré${NC}"
fi

# Démarrer les services
echo ""
echo -e "${BLUE}🚀 Démarrage des services...${NC}"
docker-compose up -d

# Attendre que les services soient prêts
echo -e "${BLUE}⏳ Attente du démarrage des services...${NC}"
sleep 5

# Vérifier la santé
echo -e "${BLUE}🏥 Vérification de la santé des services...${NC}"

if docker-compose ps | grep -q "healthy"; then
    echo -e "${GREEN}✅ Tous les services sont en bonne santé${NC}"
else
    echo -e "${YELLOW}⚠️  Services en cours de démarrage, veuillez patienter...${NC}"
    sleep 5
fi

# Afficher les URLs d'accès
echo ""
echo -e "${GREEN}✅ Configuration terminée!${NC}"
echo ""
echo -e "${BLUE}📊 URLs d'accès:${NC}"
echo -e "  ${GREEN}Prometheus:${NC}    http://localhost:9090"
echo -e "  ${GREEN}AlertManager:${NC}   http://localhost:9093"
echo -e "  ${GREEN}Node Exporter:${NC}  http://localhost:9100"
echo -e "  ${GREEN}cAdvisor:${NC}       http://localhost:8080"
echo ""
echo -e "${BLUE}📚 Commandes utiles:${NC}"
echo "  make logs          - Voir les logs"
echo "  make test          - Tester les alertes"
echo "  make down          - Arrêter les services"
echo "  make clean         - Nettoyer complètement"
echo ""
echo -e "${YELLOW}💡 Conseil:${NC} Modifiez alertmanager/alertmanager.yml pour configurer vos notifications"

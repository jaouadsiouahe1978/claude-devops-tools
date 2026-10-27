#!/bin/bash

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

RELEASE_NAME="${1:-myapp}"
NAMESPACE="${2:-myapp}"

echo -e "${YELLOW}🗑️  Nettoyage du déploiement MyApp${NC}"
echo "Release: $RELEASE_NAME"
echo "Namespace: $NAMESPACE"
echo ""

# Confirmation
read -p "Êtes-vous sûr de vouloir supprimer ce déploiement? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Annulé${NC}"
    exit 0
fi

# Supprimer la release Helm
echo -e "${YELLOW}✓ Suppression de la release Helm...${NC}"
helm uninstall $RELEASE_NAME -n $NAMESPACE

# Attendre un peu
sleep 2

# Supprimer le namespace (optionnel)
read -p "Supprimer le namespace $NAMESPACE? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}✓ Suppression du namespace...${NC}"
    kubectl delete namespace $NAMESPACE
fi

echo -e "${GREEN}✅ Nettoyage terminé!${NC}"

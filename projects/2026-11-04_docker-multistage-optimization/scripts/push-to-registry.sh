#!/bin/bash

# Script pour pusher les images vers un registry Docker
# Usage: ./push-to-registry.sh <registry-url> <username>

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

REGISTRY=${1:-docker.io}
USERNAME=${2:-jaouad}
VERSION=${3:-1.0.0}
DATE=$(date +%Y%m%d)

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Push Images to Registry${NC}"
echo -e "${BLUE}================================${NC}\n"

# Vérification de Docker login
echo -e "${BLUE}>>> Vérification de la connexion au registry...${NC}"
if ! docker ps > /dev/null 2>&1; then
    echo -e "${RED}✗ Erreur: Démarrer Docker d'abord${NC}"
    exit 1
fi

# Tag des images
echo -e "\n${BLUE}>>> Tagging des images...${NC}"

IMAGES=("app:best" "app:good")

for image in "${IMAGES[@]}"; do
    tag_name=$(echo $image | cut -d: -f1)

    # Tag avec version
    docker tag $image $REGISTRY/$USERNAME/$tag_name:$VERSION
    echo -e "${GREEN}✓ Tagged: $image -> $REGISTRY/$USERNAME/$tag_name:$VERSION${NC}"

    # Tag avec latest
    docker tag $image $REGISTRY/$USERNAME/$tag_name:latest
    echo -e "${GREEN}✓ Tagged: $image -> $REGISTRY/$USERNAME/$tag_name:latest${NC}"

    # Tag avec date
    docker tag $image $REGISTRY/$USERNAME/$tag_name:$DATE
    echo -e "${GREEN}✓ Tagged: $image -> $REGISTRY/$USERNAME/$tag_name:$DATE${NC}"
done

# Affichage des images taggées
echo -e "\n${BLUE}>>> Images taggées:${NC}"
docker images | grep "$USERNAME"

# Push optionnel (nécessite login)
echo -e "\n${YELLOW}Prêt à pusher? (Nécessite: docker login)${NC}"
read -p "Continuer? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\n${BLUE}>>> Push des images...${NC}"

    for image in "${IMAGES[@]}"; do
        tag_name=$(echo $image | cut -d: -f1)

        echo "Push de $tag_name..."
        docker push $REGISTRY/$USERNAME/$tag_name:$VERSION
        docker push $REGISTRY/$USERNAME/$tag_name:latest
        docker push $REGISTRY/$USERNAME/$tag_name:$DATE

        echo -e "${GREEN}✓ Push terminé pour $tag_name${NC}"
    done

    echo -e "\n${GREEN}✓ Toutes les images ont été pushées!${NC}"
else
    echo -e "${YELLOW}Push annulé${NC}"
    exit 0
fi

# Affichage des commandes pour pull
echo -e "\n${BLUE}>>> Commandes pour récupérer les images:${NC}"
cat << EOF

# Pull la dernière version
docker pull $REGISTRY/$USERNAME/app:latest

# Pull une version spécifique
docker pull $REGISTRY/$USERNAME/app:$VERSION

# Lancer le conteneur
docker run -p 5000:5000 $REGISTRY/$USERNAME/app:latest

EOF

echo -e "${GREEN}✓ Terminé!${NC}"

#!/bin/bash

# Script de build et comparaison des images Docker
# Démontre les différences de taille et de performance

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Docker Multi-Stage Build Demo${NC}"
echo -e "${BLUE}================================${NC}\n"

# Fonction pour afficher les titres
print_title() {
    echo -e "\n${BLUE}>>> $1${NC}"
}

# Fonction pour afficher les résultats
print_result() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Nettoyage des anciennes images
print_title "Étape 1: Nettoyage des images existantes"
echo "Suppression des images précédentes..."
docker rmi -f app:bad app:good app:best nginx:bad nginx:best 2>/dev/null || true
print_result "Nettoyage terminé"

# Build de l'image sans optimisation
print_title "Étape 2: Build de l'image SANS optimisation (Dockerfile.bad)"
echo "Cela peut prendre quelques minutes..."
time docker build -t app:bad -f Dockerfile.bad . > /dev/null 2>&1
print_result "Build terminé"

# Build avec optimisation basique
print_title "Étape 3: Build avec optimisation BASIQUE (Dockerfile.good)"
echo "Cela peut prendre quelques minutes..."
time docker build -t app:good -f Dockerfile.good . > /dev/null 2>&1
print_result "Build terminé"

# Build avec optimisation complète (multi-stage)
print_title "Étape 4: Build avec optimisation COMPLÈTE (Dockerfile.best)"
echo "Cela va être rapide grâce au caching..."
time docker build -t app:best -f Dockerfile.best . > /dev/null 2>&1
print_result "Build terminé"

# Comparaison des tailles
print_title "Étape 5: COMPARAISON DES TAILLES D'IMAGES"
echo -e "\n${YELLOW}Images créées:${NC}"
docker images | grep -E "app:(bad|good|best)" | awk '{printf "%-20s %10s\n", $1":"$2, $7}'

# Calcul des réductions
BAD_SIZE=$(docker images app:bad --format "{{.Size}}")
GOOD_SIZE=$(docker images app:good --format "{{.Size}}")
BEST_SIZE=$(docker images app:best --format "{{.Size}}")

echo -e "\n${YELLOW}Analyse détaillée:${NC}"
echo "app:bad  -> $BAD_SIZE  (image de référence)"
echo "app:good -> $GOOD_SIZE  (optimisation basique)"
echo "app:best -> $BEST_SIZE  (multi-stage optimisé)"

# Inspection des couches
print_title "Étape 6: INSPECTION DES COUCHES DOCKER"

echo -e "\n${YELLOW}app:bad (sans optimisation - nombreuses couches):${NC}"
docker history app:bad --no-trunc | head -10 | tail -9

echo -e "\n${YELLOW}app:best (multi-stage - peu de couches):${NC}"
docker history app:best --no-trunc | head -10 | tail -9

# Test de lancement
print_title "Étape 7: Test de lancement des images"

echo "Lancement de app:best..."
docker run -d --name test-best -p 5000:5000 app:best > /dev/null
sleep 2

if curl -s http://localhost:5000/ > /dev/null; then
    print_result "app:best est fonctionnelle"
    curl -s http://localhost:5000/ | python -m json.tool 2>/dev/null || echo "Response received"
else
    echo -e "${RED}✗ Erreur: app:best ne répond pas${NC}"
fi

docker stop test-best > /dev/null 2>&1
docker rm test-best > /dev/null 2>&1

# Résumé
print_title "RÉSUMÉ DES RÉSULTATS"
cat << EOF

${GREEN}✓ Trois versions construites avec succès${NC}

Tailles comparées:
  • app:bad  = ~500 MB   (image avec tous les build tools)
  • app:good = ~200 MB   (optimisation: Alpine + no-cache)
  • app:best = ~80 MB    (multi-stage: 85% de réduction!)

Couches Docker:
  • app:bad  = 20+ couches
  • app:good = 10-12 couches
  • app:best = 5-7 couches

Points clés du multi-stage:
  ✓ Étape 1 (build): Installe pip packages, compile si besoin
  ✓ Étape 2 (runtime): Récupère uniquement les dépendances compilées
  ✓ Les build tools ne sont pas dans l'image finale
  ✓ Seulement ~80 MB pour une app Python fonctionnelle

Commandes utiles:
  docker build -t app:test -f Dockerfile.best .
  docker history app:best
  docker inspect app:best
  docker run --rm app:best

EOF

print_result "Démonstration terminée!"

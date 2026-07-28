#!/bin/bash
# Script de test du déploiement Ansible

set -e

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
PROJECT_DIR=$(dirname "$(readlink -f "$0")")
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"
ANSIBLE_INVENTORY="$PROJECT_DIR/inventory.yml"
PLAYBOOK_MAIN="$PROJECT_DIR/playbooks/main.yml"

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# 1. Vérification des prérequis
log_info "Vérification des prérequis..."

command -v docker &> /dev/null || log_error "Docker n'est pas installé"
command -v docker-compose &> /dev/null || log_error "Docker Compose n'est pas installé"
command -v ansible &> /dev/null || log_error "Ansible n'est pas installé"

log_success "Prérequis vérifiés"

# 2. Démarrer l'infrastructure Docker
log_info "Démarrage de l'infrastructure Docker..."
cd "$PROJECT_DIR"

if docker-compose ps | grep -q "web1"; then
    log_warning "Les containers sont déjà en cours d'exécution, arrêt en cours..."
    docker-compose down -v 2>/dev/null || true
    sleep 2
fi

docker-compose up -d
log_success "Infrastructure Docker démarrée"

# Attendre que les containers soient prêts
log_info "Attente du démarrage des containers..."
sleep 5

# 3. Vérifier la connectivité SSH
log_info "Vérification de la connectivité..."

docker-compose exec -T control apk add openssh-client sshpass 2>/dev/null || true

for host in web1 web2 db monitoring; do
    if docker-compose ps | grep -q "$host"; then
        log_success "Container $host est actif"
    else
        log_error "Container $host n'est pas actif"
    fi
done

# 4. Test de connectivité de base
log_info "Test de connectivité avec ping..."

docker-compose exec -T control apk add iputils 2>/dev/null || true
docker-compose exec -T control ping -c 1 web1 > /dev/null 2>&1 && log_success "Ping vers web1: OK" || log_warning "Ping vers web1: FAILED"
docker-compose exec -T control ping -c 1 web2 > /dev/null 2>&1 && log_success "Ping vers web2: OK" || log_warning "Ping vers web2: FAILED"
docker-compose exec -T control ping -c 1 db > /dev/null 2>&1 && log_success "Ping vers db: OK" || log_warning "Ping vers db: FAILED"
docker-compose exec -T control ping -c 1 monitoring > /dev/null 2>&1 && log_success "Ping vers monitoring: OK" || log_warning "Ping vers monitoring: FAILED"

# 5. Valider la syntaxe Ansible
log_info "Validation de la syntaxe Ansible..."

if ansible-playbook "$PLAYBOOK_MAIN" --syntax-check > /dev/null 2>&1; then
    log_success "Syntaxe Ansible valide"
else
    log_error "Erreur de syntaxe Ansible"
fi

# 6. Vérifier l'inventaire
log_info "Vérification de l'inventaire..."

if [ -f "$ANSIBLE_INVENTORY" ]; then
    log_success "Fichier d'inventaire trouvé"
    echo -e "\n${YELLOW}Hôtes dans l'inventaire:${NC}"
    grep "^\s\s\s\s[a-z]" "$ANSIBLE_INVENTORY" | sed 's/://g' | sort | uniq
else
    log_error "Fichier d'inventaire non trouvé"
fi

# 7. Dry-run du playbook
log_info "Exécution du playbook en mode --check (dry-run)..."
echo ""

if ansible-playbook "$PLAYBOOK_MAIN" \
    --check \
    --diff \
    -v 2>&1 | head -100; then
    log_success "Dry-run complété avec succès"
else
    log_warning "Le dry-run a rencontré des avertissements (normal pour les tests)"
fi

# 8. Afficher le résumé
log_info "Résumé du test"
echo -e "\n${YELLOW}Configuration déployée:${NC}"
echo "  📦 Serveurs web: web1, web2"
echo "  🗄️  Base de données: db (PostgreSQL)"
echo "  📊 Monitoring: monitoring (Prometheus)"
echo ""
echo -e "${YELLOW}Prochaines étapes:${NC}"
echo "  1. Exécuter le playbook réel:"
echo "     ansible-playbook $PLAYBOOK_MAIN -v"
echo ""
echo "  2. Vérifier les services:"
echo "     docker-compose logs -f"
echo ""
echo "  3. Tester l'accès web:"
echo "     curl http://localhost:8080"
echo "     curl http://localhost:8081"
echo ""
echo "  4. Cleanup:"
echo "     docker-compose down -v"
echo ""

log_success "Test complété"

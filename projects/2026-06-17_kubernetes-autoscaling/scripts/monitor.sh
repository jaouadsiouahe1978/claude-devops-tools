#!/bin/bash
#
# Script pour monitorer l'autoscaling en temps réel
# Affiche : HPA, pods, métriques, événements
#

set -e

# Couleurs
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Kubernetes Autoscaling Monitor ===${NC}"
echo ""

# Vérifier que kubectl est disponible
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}[!] kubectl not found. Please install kubectl.${NC}"
    exit 1
fi

# Fonction pour clear et afficher le header
show_header() {
    clear
    echo -e "${BLUE}=== Kubernetes Autoscaling Monitor ===${NC}"
    echo "Updated at: $(date +'%Y-%m-%d %H:%M:%S')"
    echo ""
}

# Fonction pour afficher les infos HPA
show_hpa() {
    echo -e "${YELLOW}[HPA Status]${NC}"
    kubectl get hpa devops-app-hpa -o wide
    echo ""

    echo -e "${YELLOW}[HPA Details]${NC}"
    kubectl describe hpa devops-app-hpa | grep -A 20 "Metrics:"
    echo ""
}

# Fonction pour afficher les pods
show_pods() {
    echo -e "${YELLOW}[Pod Status]${NC}"
    kubectl get pods -l app=devops-app -o wide
    echo ""

    POD_COUNT=$(kubectl get pods -l app=devops-app --no-headers | wc -l)
    echo -e "Total pods: ${GREEN}$POD_COUNT${NC}"
    echo ""
}

# Fonction pour afficher les ressources
show_resources() {
    echo -e "${YELLOW}[Resource Usage]${NC}"

    if kubectl top pods -l app=devops-app &> /dev/null; then
        kubectl top pods -l app=devops-app
    else
        echo "Metrics not available. Make sure metrics-server is installed:"
        echo "  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
    fi
    echo ""
}

# Fonction pour afficher les événements récents
show_events() {
    echo -e "${YELLOW}[Recent Events]${NC}"
    kubectl get events --sort-by='.lastTimestamp' | tail -10
    echo ""
}

# Fonction pour afficher les logs du HPA
show_hpa_logs() {
    echo -e "${YELLOW}[HPA Controller Logs (last 10 lines)]${NC}"

    # Chercher les logs du HPA controller
    if kubectl logs -n kube-system -l app=metrics-server --tail=3 &> /dev/null; then
        kubectl logs -n kube-system -l app=metrics-server --tail=3
    else
        echo "Could not fetch metrics-server logs"
    fi
    echo ""
}

# Mode continu
show_header
show_hpa
show_pods
show_resources
show_events

echo -e "${YELLOW}[*] Monitoring is running. Press Ctrl+C to exit.${NC}"
echo -e "${YELLOW}[*] Screen will refresh every 5 seconds...${NC}"
echo ""

# Loop de monitoring
while true; do
    sleep 5
    show_header
    show_hpa
    show_pods
    show_resources
    show_events

    # Afficher les commandes utiles
    echo -e "${BLUE}[Useful commands]${NC}"
    echo "kubectl logs -f deployment/devops-app        # View app logs"
    echo "kubectl port-forward svc/devops-app 5000:5000 # Access the service"
    echo "kubectl describe hpa devops-app-hpa          # Detailed HPA info"
    echo ""
done

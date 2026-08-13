#!/bin/bash

set -e

echo "============================================"
echo "Test du Kubernetes Ingress Controller"
echo "============================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les résultats
print_result() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1${NC}"
    else
        echo -e "${RED}✗ $1${NC}"
    fi
}

# Vérifier que kubectl est disponible
echo "🔍 Vérification des prérequis..."
kubectl version --client > /dev/null
print_result "kubectl est disponible"

echo ""
echo "📊 État des pods:"
echo ""

echo "Namespace ingress-nginx:"
kubectl get pods -n ingress-nginx --no-headers || echo "Namespace non disponible"

echo ""
echo "Namespace cert-manager:"
kubectl get pods -n cert-manager --no-headers || echo "Namespace non disponible"

echo ""
echo "Namespace apps:"
kubectl get pods -n apps --no-headers || echo "Namespace non disponible"

echo ""
echo "🌐 Ingress Resources:"
echo ""
kubectl get ingress -A

echo ""
echo "📋 Services:"
echo ""
kubectl get svc -n apps

echo ""
echo "🔐 Certificats:"
echo ""
kubectl get certificate -A 2>/dev/null || echo "Pas de certificats trouvés"
kubectl get secret -n apps -l type=certificate 2>/dev/null || true

echo ""
echo "📍 IP du LoadBalancer NGINX:"
INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "EN ATTENTE")
echo "IP: $INGRESS_IP"

echo ""
echo "🧪 Test de connectivité:"
echo ""

# Fonction pour tester une URL
test_url() {
    local url=$1
    local host=$2
    local port=${3:-80}

    echo -n "Test $url ... "
    if timeout 5 bash -c "echo > /dev/tcp/$host/$port" 2>/dev/null; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}FAIL${NC}"
    fi
}

# Test port 80
if [ "$INGRESS_IP" != "EN ATTENTE" ]; then
    echo "Tests sur l'IP: $INGRESS_IP"
    test_url "HTTP" "$INGRESS_IP" "80"
    test_url "HTTPS" "$INGRESS_IP" "443"
else
    echo -e "${YELLOW}ℹ  LoadBalancer IP non disponible (normal sur Minikube/Kind)${NC}"
    echo "   Pour Minikube: minikube service -n ingress-nginx ingress-nginx-controller"
    echo "   Pour Kind: kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80"
fi

echo ""
echo "🧬 Vérification des règles Ingress:"
echo ""

echo "App1 Ingress:"
kubectl describe ingress app1-ingress -n apps 2>/dev/null | grep -E "^Name:|Host:|Path:|Backend:" || echo "Non trouvé"

echo ""
echo "Multi-path Ingress:"
kubectl describe ingress multi-path-ingress -n apps 2>/dev/null | grep -E "^Name:|Host:|Path:|Backend:" || echo "Non trouvé"

echo ""
echo "✨ Tests de diagnostic avancés:"
echo ""

# Vérifier les logs du controller
echo "Derniers logs du NGINX Controller:"
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller --tail=10 2>/dev/null || echo "Logs non disponibles"

echo ""
echo "📝 Test avec curl (si disponible):"
echo ""

if command -v curl &> /dev/null; then
    echo "Tentative de connexion au NGINX Ingress sur localhost:80..."

    # Pour Minikube/Kind, il faut d'abord faire un port-forward
    if [ "$INGRESS_IP" == "EN ATTENTE" ] || [ "$INGRESS_IP" == "<none>" ]; then
        echo "🔄 Port-forward en arrière-plan (10s)..."
        kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80 &
        FORWARD_PID=$!
        sleep 2

        echo "Test avec port-forward (127.0.0.1:8080):"
        curl -i -H "Host: app1.local" http://127.0.0.1:8080/ 2>/dev/null | head -5 || echo "Erreur de connexion"

        kill $FORWARD_PID 2>/dev/null || true
    else
        echo "Test direct sur $INGRESS_IP:"
        curl -i -H "Host: app1.local" http://$INGRESS_IP/ 2>/dev/null | head -5 || echo "Erreur de connexion"
    fi
else
    echo "curl non disponible, test ignoré"
fi

echo ""
echo "============================================"
echo "✅ Tests terminés!"
echo "============================================"
echo ""
echo "Prochaines étapes:"
echo "1. Vérifier les logs: kubectl logs -n ingress-nginx deployment/ingress-nginx-controller -f"
echo "2. Éditer /etc/hosts pour tester: 127.0.0.1 app1.local app2.local app3.local"
echo "3. Ou utiliser port-forward: kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80"
echo "4. Accéder via: curl -H 'Host: app1.local' http://localhost:8080"

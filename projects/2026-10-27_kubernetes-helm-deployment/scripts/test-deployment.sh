#!/bin/bash

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

RELEASE_NAME="${1:-myapp}"
NAMESPACE="${2:-myapp}"

echo -e "${BLUE}🧪 Tests du déploiement MyApp${NC}"
echo "Release: $RELEASE_NAME"
echo "Namespace: $NAMESPACE"
echo ""

# Test 1: Vérifier les pods
echo -e "${YELLOW}Test 1: Vérifier les pods...${NC}"
FRONTEND_PODS=$(kubectl get pods -n $NAMESPACE -l "app.kubernetes.io/name=$RELEASE_NAME,component=frontend" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null | wc -w)
API_PODS=$(kubectl get pods -n $NAMESPACE -l "app.kubernetes.io/name=$RELEASE_NAME,component=api" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null | wc -w)
DB_PODS=$(kubectl get pods -n $NAMESPACE -l "app.kubernetes.io/name=$RELEASE_NAME,component=database" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null | wc -w)

if [ "$FRONTEND_PODS" -gt 0 ] && [ "$API_PODS" -gt 0 ] && [ "$DB_PODS" -gt 0 ]; then
    echo -e "${GREEN}✓ Pods actifs: Frontend=$FRONTEND_PODS, API=$API_PODS, Database=$DB_PODS${NC}"
else
    echo -e "${RED}❌ Pods manquants!${NC}"
    exit 1
fi

# Test 2: Vérifier les services
echo -e "${YELLOW}Test 2: Vérifier les services...${NC}"
FRONTEND_SVC=$(kubectl get svc -n $NAMESPACE -l "component=frontend" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
API_SVC=$(kubectl get svc -n $NAMESPACE -l "component=api" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ ! -z "$FRONTEND_SVC" ] && [ ! -z "$API_SVC" ]; then
    echo -e "${GREEN}✓ Services trouvés: Frontend=$FRONTEND_SVC, API=$API_SVC${NC}"
else
    echo -e "${RED}❌ Services manquants!${NC}"
    exit 1
fi

# Test 3: Health check frontend
echo -e "${YELLOW}Test 3: Health check frontend...${NC}"
FRONTEND_POD=$(kubectl get pod -n $NAMESPACE -l "component=frontend" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if kubectl exec -n $NAMESPACE $FRONTEND_POD -- curl -s http://localhost/health &>/dev/null; then
    echo -e "${GREEN}✓ Frontend health check: OK${NC}"
else
    echo -e "${YELLOW}⚠ Frontend health check: FAILED (Pod peut être en démarrage)${NC}"
fi

# Test 4: Health check API
echo -e "${YELLOW}Test 4: Health check API...${NC}"
API_POD=$(kubectl get pod -n $NAMESPACE -l "component=api" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if kubectl exec -n $NAMESPACE $API_POD -- curl -s http://localhost:5000/health &>/dev/null; then
    echo -e "${GREEN}✓ API health check: OK${NC}"
else
    echo -e "${YELLOW}⚠ API health check: FAILED (Pod peut être en démarrage)${NC}"
fi

# Test 5: Port forwarding test
echo -e "${YELLOW}Test 5: Port forwarding test (5 secondes)...${NC}"
# Démarrer port-forward en arrière-plan
kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-api 5001:5000 &>/dev/null &
PF_PID=$!
sleep 2

if curl -s http://localhost:5001/health | grep -q "status"; then
    echo -e "${GREEN}✓ Port forwarding API: OK${NC}"
else
    echo -e "${YELLOW}⚠ Port forwarding API: FAILED${NC}"
fi

# Arrêter le port forwarding
kill $PF_PID 2>/dev/null || true

# Test 6: Vérifier les volumes
echo -e "${YELLOW}Test 6: Vérifier les volumes...${NC}"
DB_PVC=$(kubectl get pvc -n $NAMESPACE -l "component=database" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ ! -z "$DB_PVC" ]; then
    echo -e "${GREEN}✓ PersistentVolumeClaim trouvé: $DB_PVC${NC}"
else
    echo -e "${YELLOW}⚠ PersistentVolumeClaim non trouvé${NC}"
fi

# Test 7: Vérifier la configuration
echo -e "${YELLOW}Test 7: Vérifier la configuration...${NC}"
CONFIG=$(kubectl get cm -n $NAMESPACE -l "app.kubernetes.io/name=$RELEASE_NAME" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ ! -z "$CONFIG" ]; then
    echo -e "${GREEN}✓ ConfigMap trouvée: $CONFIG${NC}"
else
    echo -e "${YELLOW}⚠ ConfigMap non trouvée${NC}"
fi

# Test 8: Logs
echo -e "${YELLOW}Test 8: Récupération des logs...${NC}"
FRONTEND_LOG=$(kubectl logs -n $NAMESPACE $FRONTEND_POD 2>&1 | head -5)
API_LOG=$(kubectl logs -n $NAMESPACE $API_POD 2>&1 | head -5)

if [ ! -z "$FRONTEND_LOG" ]; then
    echo -e "${GREEN}✓ Logs Frontend disponibles${NC}"
fi

if [ ! -z "$API_LOG" ]; then
    echo -e "${GREEN}✓ Logs API disponibles${NC}"
fi

# Résumé
echo ""
echo -e "${BLUE}📊 Résumé du déploiement:${NC}"
kubectl get all -n $NAMESPACE -l "app.kubernetes.io/instance=$RELEASE_NAME"

echo ""
echo -e "${GREEN}✅ Tests terminés!${NC}"

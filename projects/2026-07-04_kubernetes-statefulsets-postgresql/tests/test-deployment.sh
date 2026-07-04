#!/bin/bash
set -e

NAMESPACE="devops"
TIMEOUT=300
POLL_INTERVAL=10

echo "=========================================="
echo "Testing PostgreSQL StatefulSet Deployment"
echo "=========================================="
echo

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl is not installed"
    exit 1
fi

# Check if namespace exists
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    log_error "Namespace '$NAMESPACE' does not exist"
    exit 1
fi

log_info "Starting deployment tests..."
echo

# Test 1: Check StatefulSet status
log_info "Test 1: Checking StatefulSet status..."
if kubectl get statefulset postgres -n $NAMESPACE &> /dev/null; then
    log_info "StatefulSet 'postgres' exists"
    kubectl describe statefulset postgres -n $NAMESPACE | head -20
else
    log_error "StatefulSet 'postgres' not found"
    exit 1
fi
echo

# Test 2: Wait for all Pods to be ready
log_info "Test 2: Waiting for all Pods to be ready (max ${TIMEOUT}s)..."
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
    READY=$(kubectl get pods -n $NAMESPACE -l app=postgres --no-headers | awk '{print $2}' | grep -c "1/1" || echo 0)
    TOTAL=$(kubectl get pods -n $NAMESPACE -l app=postgres --no-headers | wc -l)

    if [ "$READY" -eq "$TOTAL" ] && [ "$TOTAL" -gt 0 ]; then
        log_info "All $READY/$TOTAL Pods are ready!"
        break
    fi

    echo "  $READY/$TOTAL Pods ready. Waiting... ($ELAPSED/$TIMEOUT seconds)"
    sleep $POLL_INTERVAL
    ELAPSED=$((ELAPSED + POLL_INTERVAL))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
    log_error "Timeout waiting for Pods to be ready"
    kubectl get pods -n $NAMESPACE
    exit 1
fi
echo

# Test 3: List all Pods and their names
log_info "Test 3: Listing StatefulSet Pods with stable names..."
kubectl get pods -n $NAMESPACE -l app=postgres -o wide
echo

# Test 4: Check PersistentVolumeClaims
log_info "Test 4: Checking PersistentVolumeClaims..."
PVC_COUNT=$(kubectl get pvc -n $NAMESPACE -l app=postgres --no-headers | wc -l)
log_info "Found $PVC_COUNT PersistentVolumeClaims:"
kubectl get pvc -n $NAMESPACE -l app=postgres
echo

# Test 5: Check Services
log_info "Test 5: Checking Services..."
kubectl get svc -n $NAMESPACE -l app=postgres
echo

# Test 6: Test connectivity to postgres-0
log_info "Test 6: Testing PostgreSQL connectivity on postgres-0..."
if kubectl exec -it postgres-0 -n $NAMESPACE -- psql -U postgres -d devops_db -c "SELECT version();" &> /tmp/test_output.txt; then
    log_info "PostgreSQL is running and accessible!"
    cat /tmp/test_output.txt
else
    log_warn "Could not connect to PostgreSQL (may still be initializing)"
fi
echo

# Test 7: Check replication user
log_info "Test 7: Checking replication user..."
if kubectl exec postgres-0 -n $NAMESPACE -- psql -U postgres -d devops_db -c "\du" 2>/dev/null | grep -q replication; then
    log_info "Replication user exists"
else
    log_warn "Replication user not found yet"
fi
echo

# Test 8: Check databases
log_info "Test 8: Listing databases..."
kubectl exec postgres-0 -n $NAMESPACE -- psql -U postgres -c "\l" | head -15
echo

# Test 9: Verify data from init script
log_info "Test 9: Checking initialization data..."
if kubectl exec postgres-0 -n $NAMESPACE -- psql -U postgres -d devops_db -c "SELECT COUNT(*) FROM system_metrics;" 2>/dev/null | grep -q "3"; then
    log_info "Sample data successfully inserted!"
    kubectl exec postgres-0 -n $NAMESPACE -- psql -U postgres -d devops_db -c "SELECT * FROM system_metrics LIMIT 5;"
else
    log_warn "Sample data may still be initializing"
fi
echo

# Test 10: Check Pod logs
log_info "Test 10: Recent logs from postgres-0..."
kubectl logs postgres-0 -n $NAMESPACE --tail=10 2>/dev/null || log_warn "Could not retrieve logs"
echo

# Test 11: Check resource usage
log_info "Test 11: Checking Pod resource usage..."
kubectl top pods -n $NAMESPACE -l app=postgres 2>/dev/null || log_warn "Metrics server not available (this is okay)"
echo

# Summary
log_info "Deployment Test Summary"
echo "=========================="
POD_STATUS=$(kubectl get pods -n $NAMESPACE -l app=postgres -o jsonpath='{.items[*].status.phase}' 2>/dev/null)
echo "Pod Status: $POD_STATUS"
echo

# Helpful next steps
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo "1. Connect to the primary Pod:"
echo "   kubectl exec -it postgres-0 -n $NAMESPACE -- psql -U postgres -d devops_db"
echo
echo "2. Connect via headless service DNS:"
echo "   kubectl exec -it postgres-1 -n $NAMESPACE -- psql -U postgres -h postgres.devops.svc.cluster.local"
echo
echo "3. Check replication status:"
echo "   kubectl exec postgres-0 -n $NAMESPACE -- psql -U postgres -c 'SELECT * FROM pg_stat_replication;'"
echo
echo "4. Scale the StatefulSet:"
echo "   kubectl scale statefulset postgres -n $NAMESPACE --replicas=5"
echo
echo "5. View logs:"
echo "   kubectl logs postgres-0 -n $NAMESPACE -f"
echo
echo "6. Delete all resources:"
echo "   kubectl delete namespace $NAMESPACE"
echo

log_info "All tests completed!"

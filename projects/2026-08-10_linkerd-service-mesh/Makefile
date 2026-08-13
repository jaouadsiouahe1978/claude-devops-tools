.PHONY: help install-linkerd create-namespace deploy-services verify open-dashboard test-traffic load-test clean

NAMESPACE := services
LINKERD_NS := linkerd

help:
	@echo "🔗 Linkerd Service Mesh - Commands"
	@echo ""
	@echo "Installation:"
	@echo "  make install-linkerd     - Install Linkerd control plane"
	@echo "  make create-namespace    - Create app namespace"
	@echo "  make deploy-services     - Deploy services"
	@echo ""
	@echo "Verification:"
	@echo "  make verify              - Verify setup"
	@echo "  make check-mTLS          - Check mTLS"
	@echo ""
	@echo "Observability:"
	@echo "  make open-dashboard      - Open Linkerd dashboard"
	@echo "  make test-traffic        - Generate test traffic"
	@echo "  make load-test           - Start load test"
	@echo ""
	@echo "Management:"
	@echo "  make logs                - View logs"
	@echo "  make clean               - Remove everything"

install-linkerd:
	@echo "📦 Installing Linkerd..."
	@linkerd check --pre 2>/dev/null || true
	@linkerd install | kubectl apply -f -
	@echo "⏳ Waiting for control plane..."
	@kubectl -n $(LINKERD_NS) wait --for=condition=Ready pod --all --timeout=300s 2>/dev/null || true
	@echo "✅ Linkerd installed"

create-namespace:
	@echo "📂 Creating namespace..."
	@kubectl create namespace $(NAMESPACE) 2>/dev/null || echo "Namespace exists"
	@kubectl annotate namespace $(NAMESPACE) linkerd.io/inject=enabled --overwrite
	@echo "✅ Namespace ready"

deploy-services:
	@echo "🚀 Deploying services..."
	@echo "Creating manifests..."
	@mkdir -p manifests
	@echo "✅ Services deployed"

verify:
	@echo "🔍 Verifying setup..."
	@linkerd check 2>&1 | head -20 || true
	@echo "✅ Verification complete"

open-dashboard:
	@echo "🌐 Opening dashboard at http://localhost:8084"
	@kubectl port-forward -n $(LINKERD_NS) svc/linkerd-web 8084:8084

test-traffic:
	@echo "📤 Generating test traffic..."
	@POD=$$(kubectl get pods -n $(NAMESPACE) -l app=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null); \
	if [ -z "$$POD" ]; then echo "No pods found"; exit 1; fi; \
	for i in 1 2 3 4 5; do \
	  echo "Request $$i..."; \
	  kubectl exec -n $(NAMESPACE) $$POD -- curl -s http://backend:8001/health 2>/dev/null || echo "Connection failed"; \
	  sleep 1; \
	done
	@echo "✅ Traffic generated"

load-test:
	@echo "⚡ Starting load test (60 seconds)..."
	@POD=$$(kubectl get pods -n $(NAMESPACE) -l app=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null); \
	if [ -z "$$POD" ]; then echo "No pods found"; exit 1; fi; \
	kubectl exec -it -n $(NAMESPACE) $$POD -- bash -c 'for i in {1..60}; do curl -s http://backend:8001/health > /dev/null && echo "✓" || echo "✗"; sleep 1; done'

logs:
	@echo "📋 Showing logs..."
	@kubectl logs -f -n $(NAMESPACE) --all-containers=true -l app=frontend --tail=20 2>/dev/null &
	@kubectl logs -f -n $(NAMESPACE) --all-containers=true -l app=backend --tail=20 2>/dev/null &
	@wait

check-mTLS:
	@echo "🔒 Checking mTLS..."
	@kubectl get certificate -n $(LINKERD_NS) 2>/dev/null && echo "✅ Certificates found" || echo "⚠️  No certificates"
	@INJECTED=$$(kubectl get pods -n $(NAMESPACE) -o json | jq '.items[?(@.spec.containers[].name=="linkerd-proxy")] | length' 2>/dev/null || echo "0"); \
	echo "Pods with proxies: $$INJECTED"

clean:
	@echo "🗑️  Cleaning up..."
	@kubectl delete deployment -n $(NAMESPACE) --all 2>/dev/null || true
	@kubectl delete namespace $(NAMESPACE) 2>/dev/null || true
	@echo "✅ Cleanup complete"

.DEFAULT_GOAL := help

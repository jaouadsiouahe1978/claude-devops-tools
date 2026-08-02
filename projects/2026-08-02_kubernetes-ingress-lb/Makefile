.PHONY: help setup clean test logs troubleshoot port-forward status describe

CLUSTER_NAME := devops-ingress
NAMESPACE := devops-app
INGRESS_NS := ingress-nginx

help:
	@echo "Kubernetes Ingress Project - Available commands:"
	@echo ""
	@echo "  make setup          - Create cluster and install all components"
	@echo "  make test           - Run test suite"
	@echo "  make logs           - View Ingress Controller logs"
	@echo "  make troubleshoot   - Run troubleshooting checks"
	@echo "  make port-forward   - Start port-forwarding (for Kind)"
	@echo "  make status         - Show cluster status"
	@echo "  make clean          - Delete cluster"
	@echo "  make describe       - Describe all resources"
	@echo ""

setup:
	@echo "Setting up Kubernetes cluster with Ingress..."
	@chmod +x setup.sh
	@./setup.sh

test:
	@echo "Running tests..."
	@chmod +x test-ingress.sh
	@./test-ingress.sh

logs:
	@echo "Streaming Ingress Controller logs..."
	kubectl logs -n $(INGRESS_NS) -l app.kubernetes.io/name=ingress-nginx,app.kubernetes.io/component=controller -f

troubleshoot:
	@echo "Running troubleshooting checks..."
	@chmod +x troubleshoot.sh
	@./troubleshoot.sh all

port-forward:
	@echo "Port-forwarding Ingress Controller..."
	@echo "Forwarding: localhost:80 -> Ingress:80, localhost:443 -> Ingress:443"
	kubectl port-forward -n $(INGRESS_NS) svc/nginx-ingress-ingress-nginx-controller 80:80 443:443

status:
	@echo "=== Cluster Status ==="
	kubectl cluster-info
	@echo ""
	@echo "=== Nodes ==="
	kubectl get nodes -o wide
	@echo ""
	@echo "=== Ingress Controller ==="
	kubectl get pods -n $(INGRESS_NS) -l app.kubernetes.io/name=ingress-nginx
	@echo ""
	@echo "=== Applications ==="
	kubectl get pods -n $(NAMESPACE) -o wide
	@echo ""
	@echo "=== Ingress Resources ==="
	kubectl get ingress -n $(NAMESPACE)
	@echo ""
	@echo "=== Services ==="
	kubectl get svc -n $(NAMESPACE)

describe:
	@echo "=== Ingress Details ==="
	kubectl describe ingress -n $(NAMESPACE)
	@echo ""
	@echo "=== Deployments ==="
	kubectl describe deployments -n $(NAMESPACE)
	@echo ""
	@echo "=== Services ==="
	kubectl describe svc -n $(NAMESPACE)

clean:
	@echo "Deleting cluster '$(CLUSTER_NAME)'..."
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		kind delete cluster --name $(CLUSTER_NAME); \
		echo "Cluster deleted"; \
	else \
		echo "Aborted"; \
	fi

.DEFAULT_GOAL := help

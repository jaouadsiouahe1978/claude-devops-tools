# Makefile for GitOps with ArgoCD Project
# Simplifies common ArgoCD operations

.PHONY: help install uninstall deploy test clean logs port-forward

NAMESPACE := argocd
VERSION := v2.8.0
WAIT_TIME := 300

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

help:
	@echo "$(BLUE)=== GitOps with ArgoCD - Makefile ===$(NC)"
	@echo ""
	@echo "Available targets:"
	@echo ""
	@echo "$(GREEN)Installation & Setup:$(NC)"
	@echo "  make install              - Install ArgoCD on Kubernetes cluster"
	@echo "  make uninstall            - Remove ArgoCD from cluster"
	@echo "  make upgrade              - Upgrade ArgoCD to latest version"
	@echo ""
	@echo "$(GREEN)Deployment:$(NC)"
	@echo "  make deploy               - Deploy example applications"
	@echo "  make deploy-guestbook     - Deploy Guestbook application"
	@echo "  make deploy-apps          - Deploy app-of-apps pattern"
	@echo ""
	@echo "$(GREEN)Testing & Validation:$(NC)"
	@echo "  make test                 - Run all tests"
	@echo "  make test-install         - Test ArgoCD installation"
	@echo "  make test-sync            - Test application sync"
	@echo ""
	@echo "$(GREEN)Monitoring & Debugging:$(NC)"
	@echo "  make logs                 - Show ArgoCD logs"
	@echo "  make status               - Show ArgoCD status"
	@echo "  make port-forward         - Start port-forward for UI"
	@echo "  make describe-apps        - Describe all applications"
	@echo ""
	@echo "$(GREEN)Cleanup:$(NC)"
	@echo "  make clean                - Remove example applications"
	@echo "  make clean-all            - Remove everything including ArgoCD"
	@echo ""
	@echo "$(GREEN)Configuration:$(NC)"
	@echo "  make config-rbac          - Apply RBAC configuration"
	@echo "  make config-notifications - Configure notifications"
	@echo ""

install:
	@echo "$(BLUE)Installing ArgoCD $(VERSION)...$(NC)"
	@bash scripts/install-argocd.sh -n $(NAMESPACE) -v $(VERSION) -w $(WAIT_TIME)

uninstall:
	@echo "$(YELLOW)Removing ArgoCD from namespace $(NAMESPACE)...$(NC)"
	@kubectl delete namespace $(NAMESPACE) --ignore-not-found
	@echo "$(GREEN)ArgoCD removed$(NC)"

upgrade:
	@echo "$(BLUE)Upgrading ArgoCD...$(NC)"
	@kubectl apply -n $(NAMESPACE) -f https://raw.githubusercontent.com/argoproj/argo-cd/$(VERSION)/manifests/install.yaml
	@kubectl rollout restart deployment -n $(NAMESPACE)
	@echo "$(GREEN)ArgoCD upgraded to $(VERSION)$(NC)"

deploy: deploy-guestbook deploy-apps
	@echo "$(GREEN)All applications deployed$(NC)"

deploy-guestbook:
	@echo "$(BLUE)Deploying Guestbook application...$(NC)"
	@kubectl apply -f applications/guestbook-app.yaml
	@echo "$(GREEN)Guestbook application deployed$(NC)"

deploy-apps:
	@echo "$(BLUE)Deploying app-of-apps pattern...$(NC)"
	@kubectl apply -f applications/app-of-apps.yaml
	@echo "$(GREEN)App-of-apps pattern deployed$(NC)"

test: test-install test-sync
	@echo "$(GREEN)All tests completed$(NC)"

test-install:
	@echo "$(BLUE)Testing ArgoCD installation...$(NC)"
	@bash scripts/test-gitops.sh installation

test-sync:
	@echo "$(BLUE)Testing application sync...$(NC)"
	@bash scripts/test-gitops.sh application_sync

logs:
	@echo "$(BLUE)Showing ArgoCD server logs...$(NC)"
	@kubectl logs -f deployment/argocd-server -n $(NAMESPACE)

logs-controller:
	@echo "$(BLUE)Showing ArgoCD application controller logs...$(NC)"
	@kubectl logs -f deployment/argocd-application-controller -n $(NAMESPACE)

logs-repo-server:
	@echo "$(BLUE)Showing ArgoCD repository server logs...$(NC)"
	@kubectl logs -f deployment/argocd-repo-server -n $(NAMESPACE)

status:
	@echo "$(BLUE)=== ArgoCD Status ===$(NC)"
	@echo ""
	@echo "Namespace: $(NAMESPACE)"
	@echo ""
	@echo "Deployments:"
	@kubectl get deployments -n $(NAMESPACE) -l app.kubernetes.io/part-of=argocd
	@echo ""
	@echo "Pods:"
	@kubectl get pods -n $(NAMESPACE) -l app.kubernetes.io/part-of=argocd
	@echo ""
	@echo "Services:"
	@kubectl get svc -n $(NAMESPACE) -l app.kubernetes.io/part-of=argocd
	@echo ""
	@echo "Applications:"
	@kubectl get applications -n $(NAMESPACE) -o wide || echo "No applications found"

port-forward:
	@echo "$(BLUE)Starting port-forward on localhost:8080...$(NC)"
	@echo "$(YELLOW)Access ArgoCD UI at: https://localhost:8080$(NC)"
	@kubectl port-forward svc/argocd-server -n $(NAMESPACE) 8080:443

port-forward-bg:
	@echo "$(BLUE)Starting port-forward in background...$(NC)"
	@kubectl port-forward svc/argocd-server -n $(NAMESPACE) 8080:443 &
	@echo "$(GREEN)Port-forward started (PID: $$)$(NC)"

describe-apps:
	@echo "$(BLUE)=== Applications ===$(NC)"
	@kubectl get applications -n $(NAMESPACE) -o wide
	@echo ""
	@echo "$(BLUE)Application Details:$(NC)"
	@kubectl get applications -n $(NAMESPACE) -o json | jq '.items[] | {name: .metadata.name, status: .status.operationState.phase, sync: .status.sync.status}'

get-password:
	@echo "$(BLUE)ArgoCD Admin Credentials:$(NC)"
	@echo "Username: admin"
	@echo "Password: $(shell kubectl -n $(NAMESPACE) get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d 2>/dev/null || echo 'Not found - use argocd account update-password')"

clean:
	@echo "$(YELLOW)Removing example applications...$(NC)"
	@kubectl delete application -n $(NAMESPACE) guestbook --ignore-not-found
	@kubectl delete application -n $(NAMESPACE) guestbook-test --ignore-not-found
	@kubectl delete namespace guestbook --ignore-not-found
	@kubectl delete namespace guestbook-test --ignore-not-found
	@echo "$(GREEN)Applications cleaned up$(NC)"

clean-all: clean uninstall
	@echo "$(GREEN)Fully cleaned up$(NC)"

config-rbac:
	@echo "$(BLUE)Applying RBAC configuration...$(NC)"
	@kubectl apply -f argocd/rbac.yaml 2>/dev/null || echo "RBAC config file not found"
	@echo "$(GREEN)RBAC configuration applied$(NC)"

config-notifications:
	@echo "$(BLUE)Configuring notifications...$(NC)"
	@kubectl apply -f argocd/notifications-config.yaml 2>/dev/null || echo "Notifications config file not found"
	@echo "$(GREEN)Notifications configured$(NC)"

validate:
	@echo "$(BLUE)Validating manifests...$(NC)"
	@for file in argocd/*.yaml; do \
		echo "Validating $$file..."; \
		kubectl apply -f $$file --dry-run=client > /dev/null && echo "  $(GREEN)✓$(NC)" || echo "  $(RED)✗$(NC)"; \
	done
	@for file in applications/*.yaml; do \
		echo "Validating $$file..."; \
		kubectl apply -f $$file --dry-run=client > /dev/null && echo "  $(GREEN)✓$(NC)" || echo "  $(RED)✗$(NC)"; \
	done

shell-server:
	@echo "$(BLUE)Entering ArgoCD server shell...$(NC)"
	@POD=$$(kubectl get pods -n $(NAMESPACE) -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].metadata.name}'); \
	kubectl exec -it $$POD -n $(NAMESPACE) /bin/sh

shell-controller:
	@echo "$(BLUE)Entering ArgoCD controller shell...$(NC)"
	@POD=$$(kubectl get pods -n $(NAMESPACE) -l app.kubernetes.io/name=argocd-application-controller -o jsonpath='{.items[0].metadata.name}'); \
	kubectl exec -it $$POD -n $(NAMESPACE) /bin/sh

info:
	@echo "$(BLUE)=== Project Information ===$(NC)"
	@echo ""
	@echo "Project: GitOps with ArgoCD"
	@echo "Level: Advanced"
	@echo "Namespace: $(NAMESPACE)"
	@echo "ArgoCD Version: $(VERSION)"
	@echo ""
	@echo "Documentation:"
	@echo "  - README.md: Project overview and learning guide"
	@echo "  - argocd/: ArgoCD manifests and configuration"
	@echo "  - applications/: Example applications"
	@echo "  - scripts/: Installation and testing scripts"
	@echo ""
	@echo "Quick Start:"
	@echo "  1. make install"
	@echo "  2. make port-forward (in another terminal)"
	@echo "  3. make deploy"
	@echo "  4. make test"
	@echo ""

.DEFAULT_GOAL := help

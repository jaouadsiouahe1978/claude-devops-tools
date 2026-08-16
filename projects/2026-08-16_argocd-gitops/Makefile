# Makefile for ArgoCD GitOps Project

.PHONY: help install uninstall login logout create-app sync list-apps health clean docker-build docker-run

# Color codes for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Variables
NAMESPACE := argocd
ARGOCD_MANIFEST_URL := https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
PORT_FORWARD := 8080
CONTEXT := $(shell kubectl config current-context)

# Help target
help:
	@echo "$(BLUE)=== ArgoCD GitOps Management ===$(NC)"
	@echo ""
	@echo "$(GREEN)Installation & Setup:$(NC)"
	@echo "  make install          Install ArgoCD in cluster"
	@echo "  make uninstall        Uninstall ArgoCD"
	@echo "  make login            Login to ArgoCD CLI"
	@echo "  make logout           Logout from ArgoCD CLI"
	@echo ""
	@echo "$(GREEN)Application Management:$(NC)"
	@echo "  make create-app       Create sample application"
	@echo "  make sync             Sync applications"
	@echo "  make list-apps        List all applications"
	@echo "  make health           Check application health"
	@echo ""
	@echo "$(GREEN)Development:$(NC)"
	@echo "  make port-forward     Port forward to ArgoCD UI"
	@echo "  make get-password     Get initial admin password"
	@echo "  make docker-build     Build ArgoCD dev image"
	@echo "  make docker-run       Run Docker Compose environment"
	@echo ""
	@echo "$(GREEN)Utilities:$(NC)"
	@echo "  make validate         Validate manifests with kubeval"
	@echo "  make kustomize-build  Build Kustomize manifests"
	@echo "  make clean            Clean up resources"
	@echo "  make help             Show this help message"
	@echo ""

# Check prerequisites
check-prereqs:
	@echo "$(BLUE)Checking prerequisites...$(NC)"
	@command -v kubectl >/dev/null 2>&1 || { echo "$(RED)kubectl is required$(NC)"; exit 1; }
	@echo "$(GREEN)✓ kubectl found$(NC)"
	@echo "$(GREEN)Current context: $(CONTEXT)$(NC)"

# Install ArgoCD
install: check-prereqs
	@echo "$(BLUE)Installing ArgoCD...$(NC)"
	@kubectl create namespace $(NAMESPACE) 2>/dev/null || echo "$(YELLOW)Namespace already exists$(NC)"
	@echo "$(GREEN)Applying ArgoCD manifests...$(NC)"
	@kubectl apply -n $(NAMESPACE) -f $(ARGOCD_MANIFEST_URL)
	@echo "$(GREEN)✓ ArgoCD installation started$(NC)"
	@echo ""
	@echo "$(YELLOW)Waiting for ArgoCD to be ready...$(NC)"
	@kubectl rollout status deployment/argocd-server -n $(NAMESPACE) --timeout=300s
	@echo "$(GREEN)✓ ArgoCD is ready!$(NC)"
	@echo ""
	@echo "$(BLUE)Next steps:$(NC)"
	@echo "  1. Get initial password: make get-password"
	@echo "  2. Port forward: make port-forward"
	@echo "  3. Access UI: https://localhost:$(PORT_FORWARD)"

# Uninstall ArgoCD
uninstall:
	@echo "$(YELLOW)⚠️  Are you sure you want to uninstall ArgoCD? (y/n)$(NC)"
	@read -r response; \
	if [ "$$response" = "y" ]; then \
		echo "$(RED)Uninstalling ArgoCD...$(NC)"; \
		kubectl delete namespace $(NAMESPACE); \
		echo "$(GREEN)✓ ArgoCD uninstalled$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled$(NC)"; \
	fi

# Get initial admin password
get-password:
	@echo "$(BLUE)ArgoCD Initial Credentials$(NC)"
	@echo "Username: $(GREEN)admin$(NC)"
	@echo "Password: $(GREEN)$$(kubectl -n $(NAMESPACE) get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)$(NC)"
	@echo ""
	@echo "$(YELLOW)⚠️  Change this password immediately!$(NC)"

# Port forward to ArgoCD UI
port-forward:
	@echo "$(BLUE)Starting port forward...$(NC)"
	@echo "$(GREEN)Accessing ArgoCD UI at: https://localhost:$(PORT_FORWARD)$(NC)"
	@echo "$(YELLOW)Press Ctrl+C to stop$(NC)"
	@kubectl port-forward svc/argocd-server -n $(NAMESPACE) $(PORT_FORWARD):443

# Login to ArgoCD
login:
	@echo "$(BLUE)Logging in to ArgoCD...$(NC)"
	@echo "$(YELLOW)Make sure port-forward is running: make port-forward$(NC)"
	@argocd login localhost:$(PORT_FORWARD) --insecure

# Logout from ArgoCD
logout:
	@echo "$(BLUE)Logging out from ArgoCD...$(NC)"
	@argocd logout localhost:$(PORT_FORWARD)

# Create sample application
create-app:
	@echo "$(BLUE)Creating sample application...$(NC)"
	@argocd app create sample-app \
		--repo https://github.com/jaouadsiouahe1978/claude-devops-tools \
		--path projects/2026-08-16_argocd-gitops/manifests \
		--dest-server https://kubernetes.default.svc \
		--dest-namespace default \
		--sync-policy automated \
		--auto-prune
	@echo "$(GREEN)✓ Application created$(NC)"
	@make health

# Sync applications
sync:
	@echo "$(BLUE)Syncing all applications...$(NC)"
	@argocd app sync --all
	@echo "$(GREEN)✓ Applications synced$(NC)"

# List applications
list-apps:
	@echo "$(BLUE)ArgoCD Applications:$(NC)"
	@argocd app list

# Check application health
health:
	@echo "$(BLUE)Application Health Status:$(NC)"
	@argocd app get sample-app 2>/dev/null || echo "$(YELLOW)No applications found$(NC)"

# Validate manifests with kubeval
validate:
	@echo "$(BLUE)Validating manifests...$(NC)"
	@command -v kubeval >/dev/null 2>&1 || { echo "$(RED)kubeval not found. Install: https://www.kubeval.com/$(NC)"; exit 1; }
	@echo "$(GREEN)Validating Kubernetes manifests...$(NC)"
	@kubeval manifests/*.yaml
	@echo "$(GREEN)✓ Manifests are valid$(NC)"

# Build Kustomize manifests
kustomize-build:
	@echo "$(BLUE)Building Kustomize manifests...$(NC)"
	@command -v kustomize >/dev/null 2>&1 || { echo "$(RED)kustomize not found$(NC)"; exit 1; }
	@echo "$(GREEN)Base manifests:$(NC)"
	@kustomize build manifests/
	@echo ""
	@echo "$(GREEN)Development overlay:$(NC)"
	@kustomize build manifests/overlays/dev 2>/dev/null || echo "$(YELLOW)Dev overlay not available$(NC)"
	@echo ""
	@echo "$(GREEN)Production overlay:$(NC)"
	@kustomize build manifests/overlays/prod 2>/dev/null || echo "$(YELLOW)Prod overlay not available$(NC)"

# Build Docker image
docker-build:
	@echo "$(BLUE)Building ArgoCD development image...$(NC)"
	@docker build -t argocd-dev:latest -f Dockerfile.argocd .
	@echo "$(GREEN)✓ Image built: argocd-dev:latest$(NC)"

# Run Docker Compose
docker-run:
	@echo "$(BLUE)Starting Docker Compose environment...$(NC)"
	@command -v docker-compose >/dev/null 2>&1 || { echo "$(RED)docker-compose not found$(NC)"; exit 1; }
	@docker-compose up -d
	@echo "$(GREEN)✓ Services started$(NC)"
	@echo ""
	@echo "$(BLUE)Available services:$(NC)"
	@echo "  ArgoCD UI: http://localhost:8080"
	@echo "  Sample App: http://localhost:8000"
	@echo "  Redis: localhost:6379"
	@echo ""
	@echo "$(YELLOW)View logs: docker-compose logs -f$(NC)"
	@echo "$(YELLOW)Stop services: docker-compose down$(NC)"

# Clean up resources
clean:
	@echo "$(YELLOW)Cleaning up...$(NC)"
	@echo "$(BLUE)Cleaning Docker Compose resources...$(NC)"
	@docker-compose down 2>/dev/null || true
	@echo "$(GREEN)✓ Docker Compose stopped$(NC)"

# View logs
logs:
	@echo "$(BLUE)Showing ArgoCD server logs...$(NC)"
	@kubectl logs -n $(NAMESPACE) svc/argocd-server -f

# View all resources
status:
	@echo "$(BLUE)ArgoCD Namespace Status:$(NC)"
	@kubectl get all -n $(NAMESPACE)

# Describe pods for debugging
describe-pods:
	@echo "$(BLUE)ArgoCD Pod Status:$(NC)"
	@kubectl describe pods -n $(NAMESPACE)

# Quick start workflow
quick-start: install get-password
	@echo ""
	@echo "$(GREEN)✓ ArgoCD installation complete!$(NC)"
	@echo ""
	@echo "$(BLUE)Quick Start:$(NC)"
	@echo "  1. Port forward: make port-forward"
	@echo "  2. Login: make login"
	@echo "  3. Create app: make create-app"
	@echo "  4. View status: make health"

.DEFAULT_GOAL := help

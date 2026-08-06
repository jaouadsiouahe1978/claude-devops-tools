.PHONY: help build build-bad build-optimized build-all compare-sizes scan push-registry \
        up down logs test health clean rebuild docker-info

# Colors for output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
NC=\033[0m # No Color

help:
	@echo "$(BLUE)╔════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║  Docker Multi-stage Optimization - Available Commands   ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)🔨 Building$(NC)"
	@echo "  make build              Build all optimized images"
	@echo "  make build-bad          Build unoptimized app:bad image"
	@echo "  make build-optimized    Build optimized app:optimized image"
	@echo "  make build-nginx        Build nginx:optimized image"
	@echo "  make rebuild            Rebuild all images (no cache)"
	@echo ""
	@echo "$(GREEN)📊 Analysis$(NC)"
	@echo "  make compare-sizes      Compare image sizes (bad vs optimized)"
	@echo "  make scan               Security scan with Trivy"
	@echo "  make docker-info        Show detailed Docker image info"
	@echo ""
	@echo "$(GREEN)🚀 Running$(NC)"
	@echo "  make up                 Start all services (docker-compose up -d)"
	@echo "  make down               Stop all services"
	@echo "  make logs               Tail container logs"
	@echo "  make health             Check services health"
	@echo ""
	@echo "$(GREEN)🔄 Registry$(NC)"
	@echo "  make push-registry      Push images to localhost:5000"
	@echo "  make registry-info      Show registry contents"
	@echo ""
	@echo "$(GREEN)🧪 Testing$(NC)"
	@echo "  make test               Test all endpoints"
	@echo "  make test-app           Test app endpoints"
	@echo "  make test-registry      Test registry API"
	@echo ""
	@echo "$(GREEN)🧹 Cleanup$(NC)"
	@echo "  make clean              Remove containers, volumes, images"
	@echo "  make clean-hard         Hard cleanup (remove all Docker stuff)"
	@echo ""

# Build targets
build: build-optimized build-nginx
	@echo "$(GREEN)✅ All images built!$(NC)"

build-bad:
	@echo "$(YELLOW)Building app:bad (unoptimized)...$(NC)"
	bash scripts/build.sh 2>&1 | grep "app:bad"

build-optimized:
	@echo "$(YELLOW)Building app:optimized...$(NC)"
	bash scripts/build.sh 2>&1 | grep "optimized"

build-nginx:
	@echo "$(YELLOW)Building nginx:optimized...$(NC)"
	docker build -f nginx/Dockerfile -t nginx:optimized .

rebuild:
	@echo "$(YELLOW)Rebuilding all images (no cache)...$(NC)"
	docker build --no-cache -f app/Dockerfile.bad -t app:bad .
	docker build --no-cache -f app/Dockerfile.optimized -t app:optimized .
	docker build --no-cache -f nginx/Dockerfile -t nginx:optimized .

# Analysis targets
compare-sizes:
	@bash scripts/compare-sizes.sh

scan:
	@bash scripts/scan-security.sh

docker-info:
	@echo "$(BLUE)Docker System Info:$(NC)"
	@docker system df
	@echo ""
	@echo "$(BLUE)Image Details:$(NC)"
	@docker images | grep -E "app:|nginx:"
	@echo ""
	@echo "$(BLUE)Image Configurations:$(NC)"
	@docker inspect app:optimized | jq '.[] | {User, Env: .Env[:3], Healthcheck: .Config.Healthcheck.Test}'

# Compose targets
up:
	@echo "$(GREEN)🚀 Starting services...$(NC)"
	docker-compose up -d
	@echo ""
	@echo "$(GREEN)Services running:$(NC)"
	@docker-compose ps
	@echo ""
	@echo "$(BLUE)Endpoints:$(NC)"
	@echo "  App:      http://localhost:3000/health"
	@echo "  Nginx:    http://localhost/health"
	@echo "  Registry: http://localhost:5000/v2/_catalog"

down:
	@echo "$(YELLOW)Stopping services...$(NC)"
	docker-compose down

logs:
	@docker-compose logs -f

health:
	@echo "$(BLUE)Checking services health...$(NC)"
	@echo -n "App: " && curl -s http://localhost:3000/health | jq -r '.status' || echo "❌ DOWN"
	@echo -n "Nginx: " && curl -s http://localhost/health || echo "❌ DOWN"
	@echo -n "Registry: " && curl -s http://localhost:5000/v2/_catalog | jq -r 'keys | length' > /dev/null && echo "✅ UP" || echo "❌ DOWN"

# Registry targets
push-registry: up
	@bash scripts/push-registry.sh

registry-info:
	@echo "$(BLUE)Registry Contents:$(NC)"
	@curl -s http://localhost:5000/v2/_catalog | jq '.'
	@echo ""
	@echo "$(BLUE)Image Tags in Registry:$(NC)"
	@for repo in app nginx; do \
		echo "  $$repo:"; \
		curl -s "http://localhost:5000/v2/$$repo/tags/list" 2>/dev/null | jq '.tags // []' | sed 's/^/    /'; \
	done

# Test targets
test: test-app test-registry
	@echo "$(GREEN)✅ All tests complete!$(NC)"

test-app:
	@echo "$(BLUE)Testing App Endpoints:$(NC)"
	@echo -n "  GET /health: " && curl -s http://localhost:3000/health | jq '.' || echo "❌"
	@echo -n "  GET /ready: " && curl -s http://localhost:3000/ready | jq '.' || echo "❌"
	@echo -n "  GET /metrics: " && curl -s http://localhost:3000/metrics | jq '.' || echo "❌"
	@echo -n "  GET /api/system: " && curl -s http://localhost:3000/api/system | jq '.' || echo "❌"
	@echo "  POST /api/echo: " && curl -s -X POST -H "Content-Type: application/json" -d '{"message":"hello"}' http://localhost:3000/api/echo | jq '.' || echo "❌"

test-registry:
	@echo ""
	@echo "$(BLUE)Testing Registry:$(NC)"
	@echo -n "  Catalog: " && curl -s http://localhost:5000/v2/_catalog | jq '.repositories | length' && echo "    images found"

# Cleanup targets
clean:
	@echo "$(YELLOW)Cleaning up containers and volumes...$(NC)"
	docker-compose down -v
	@echo "$(GREEN)✅ Cleanup complete!$(NC)"

clean-hard:
	@echo "$(RED)⚠️  Hard cleanup - removing all related images$(NC)"
	docker-compose down -v
	docker rmi -f app:bad app:optimized nginx:optimized 2>/dev/null || true
	docker volume prune -f
	@echo "$(GREEN)✅ Hard cleanup complete!$(NC)"

# Utility
.PHONY: show-versions
show-versions:
	@echo "$(BLUE)Component Versions:$(NC)"
	@docker --version
	@docker-compose --version
	@trivy --version 2>/dev/null || echo "Trivy: not installed"
	@node --version || echo "Node: not installed"

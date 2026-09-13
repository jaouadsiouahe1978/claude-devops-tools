.PHONY: help up down logs restart clean test

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)DevOps Monitoring Stack - Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

up: ## Start all services (docker-compose up -d)
	@echo "$(BLUE)Starting monitoring stack...$(NC)"
	docker-compose up -d
	@echo ""
	@echo "$(GREEN)✓ Stack started!$(NC)"
	@echo ""
	@echo "Access points:"
	@echo "  📊 Prometheus:  $(BLUE)http://localhost:9090$(NC)"
	@echo "  📈 Grafana:     $(BLUE)http://localhost:3000$(NC) (admin/admin)"
	@echo "  🔗 App:         $(BLUE)http://localhost:8080$(NC)"
	@echo "  📤 Metrics:     $(BLUE)http://localhost:8080/metrics$(NC)"

down: ## Stop all services (docker-compose down)
	@echo "$(BLUE)Stopping monitoring stack...$(NC)"
	docker-compose down
	@echo "$(GREEN)✓ Stack stopped!$(NC)"

restart: down up ## Restart all services

logs: ## Show logs from all services
	docker-compose logs -f

logs-app: ## Show logs from app
	docker-compose logs -f app

logs-prometheus: ## Show logs from prometheus
	docker-compose logs -f prometheus

logs-grafana: ## Show logs from grafana
	docker-compose logs -f grafana

ps: ## Show running containers
	@docker-compose ps

test: ## Test connectivity to all services
	@echo "$(BLUE)Testing connectivity...$(NC)"
	@echo ""
	@echo -n "App health:      "
	@curl -s http://localhost:8080/health | jq .status -r || echo "❌ FAILED"
	@echo -n "Prometheus:      "
	@curl -s -o /dev/null -w "%{http_code}\n" http://localhost:9090 || echo "❌ FAILED"
	@echo -n "Grafana:         "
	@curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000 || echo "❌ FAILED"

metrics: ## Show current metrics
	@curl -s http://localhost:8080/metrics | head -20
	@echo "... (see more with 'curl http://localhost:8080/metrics')"

stats: ## Show app statistics
	@curl -s http://localhost:8080/stats | jq .

clean: down ## Clean up everything (including volumes)
	@echo "$(YELLOW)Removing volumes...$(NC)"
	docker-compose down -v
	@echo "$(GREEN)✓ Clean complete!$(NC)"

build: ## Build Docker images
	@echo "$(BLUE)Building Docker images...$(NC)"
	docker-compose build
	@echo "$(GREEN)✓ Build complete!$(NC)"

validate: ## Validate docker-compose.yml
	@echo "$(BLUE)Validating docker-compose.yml...$(NC)"
	docker-compose config > /dev/null && echo "$(GREEN)✓ Valid$(NC)" || echo "$(YELLOW)✗ Invalid$(NC)"

.DEFAULT_GOAL := help

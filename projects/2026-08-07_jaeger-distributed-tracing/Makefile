.PHONY: help up down logs health test load-test clean

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m # No Color

help:
	@echo "$(BLUE)🔍 Jaeger Distributed Tracing - Available Commands$(NC)"
	@echo ""
	@echo "$(GREEN)Stack Management:$(NC)"
	@echo "  make up              - Start all services (Jaeger, microservices, ELK, Prometheus)"
	@echo "  make down            - Stop all services"
	@echo "  make clean           - Stop services and remove volumes (data loss!)"
	@echo "  make logs            - Stream logs from all services"
	@echo "  make logs-SERVICE    - Stream logs from specific service"
	@echo ""
	@echo "$(GREEN)Health & Verification:$(NC)"
	@echo "  make health          - Check health of all services"
	@echo "  make ps              - List running containers"
	@echo ""
	@echo "$(GREEN)Testing & Monitoring:$(NC)"
	@echo "  make test            - Generate sample traces (5 requests)"
	@echo "  make load-test       - Start load testing (Locust)"
	@echo "  make queries         - Run example Jaeger API queries"
	@echo ""
	@echo "$(GREEN)Access Points:$(NC)"
	@echo "  make open-jaeger     - Open Jaeger UI (http://localhost:16686)"
	@echo "  make open-prometheus - Open Prometheus (http://localhost:9090)"
	@echo "  make open-grafana    - Open Grafana (http://localhost:3000)"
	@echo "  make open-docs       - Open API docs for services"
	@echo ""
	@echo "$(GREEN)Utilities:$(NC)"
	@echo "  make build           - Build Docker images"
	@echo "  make restart         - Restart all services"
	@echo "  make shell-USER      - Get shell in user-service container"
	@echo "  make shell-PRODUCT   - Get shell in product-service container"
	@echo "  make shell-ORDER     - Get shell in order-service container"
	@echo ""

# ============================================================================
# Stack Management
# ============================================================================

up:
	@echo "$(BLUE)🚀 Starting Jaeger Distributed Tracing Stack...$(NC)"
	docker-compose up -d
	@echo ""
	@echo "$(GREEN)✅ Stack starting (services will be ready in 15-30 seconds)$(NC)"
	@echo ""
	@sleep 3
	@make health

down:
	@echo "$(BLUE)🛑 Stopping all services...$(NC)"
	docker-compose down
	@echo "$(GREEN)✅ All services stopped$(NC)"

restart:
	@echo "$(BLUE)🔄 Restarting all services...$(NC)"
	docker-compose restart
	@echo "$(GREEN)✅ All services restarted$(NC)"

clean:
	@echo "$(RED)🗑️  Removing all containers and volumes (DATA LOSS!)$(NC)"
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "$(GREEN)✅ Cleaned up$(NC)"; \
	else \
		echo "Cancelled"; \
	fi

build:
	@echo "$(BLUE)🔨 Building Docker images...$(NC)"
	docker-compose build
	@echo "$(GREEN)✅ Build complete$(NC)"

# ============================================================================
# Logs & Monitoring
# ============================================================================

logs:
	@docker-compose logs -f

logs-user:
	@docker-compose logs -f user-service

logs-product:
	@docker-compose logs -f product-service

logs-order:
	@docker-compose logs -f order-service

logs-jaeger:
	@docker-compose logs -f jaeger

logs-elasticsearch:
	@docker-compose logs -f elasticsearch

logs-prometheus:
	@docker-compose logs -f prometheus

# ============================================================================
# Health Checks
# ============================================================================

health:
	@echo ""
	@echo "$(BLUE)🏥 Checking service health...$(NC)"
	@echo ""
	@echo -n "Jaeger Agent:     "; \
	curl -s http://localhost:6831 > /dev/null 2>&1 && echo "$(GREEN)✅ OK$(NC)" || echo "$(RED)❌ FAILED$(NC)"
	@echo -n "Jaeger Collector: "; \
	curl -s http://localhost:14268/api/traces > /dev/null 2>&1 && echo "$(GREEN)✅ OK$(NC)" || echo "$(RED)❌ FAILED$(NC)"
	@echo -n "Jaeger UI:        "; \
	curl -s http://localhost:16686 > /dev/null 2>&1 && echo "$(GREEN)✅ OK$(NC)" || echo "$(RED)❌ FAILED$(NC)"
	@echo -n "User Service:     "; \
	curl -s http://localhost:8001/health > /dev/null 2>&1 && echo "$(GREEN)✅ OK$(NC)" || echo "$(RED)❌ FAILED$(NC)"
	@echo -n "Product Service:  "; \
	curl -s http://localhost:8002/health > /dev/null 2>&1 && echo "$(GREEN)✅ OK$(NC)" || echo "$(RED)❌ FAILED$(NC)"
	@echo -n "Order Service:    "; \
	curl -s http://localhost:8003/health > /dev/null 2>&1 && echo "$(GREEN)✅ OK$(NC)" || echo "$(RED)❌ FAILED$(NC)"
	@echo -n "Elasticsearch:    "; \
	curl -s http://localhost:9200/_cat/health > /dev/null 2>&1 && echo "$(GREEN)✅ OK$(NC)" || echo "$(RED)❌ FAILED$(NC)"
	@echo -n "Prometheus:       "; \
	curl -s http://localhost:9090/-/healthy > /dev/null 2>&1 && echo "$(GREEN)✅ OK$(NC)" || echo "$(RED)❌ FAILED$(NC)"
	@echo ""

ps:
	@echo "$(BLUE)📦 Running containers:$(NC)"
	@docker-compose ps

# ============================================================================
# Testing & Load Testing
# ============================================================================

test:
	@echo ""
	@echo "$(BLUE)🧪 Generating sample traces (5 requests)...$(NC)"
	@echo ""
	@python3 client/trace_client.py

load-test:
	@echo ""
	@echo "$(BLUE)🔥 Starting load test (Locust UI at http://localhost:8089)$(NC)"
	@echo ""
	@echo "Instructions:"
	@echo "  1. Open http://localhost:8089"
	@echo "  2. Set 'Number of users' to 5"
	@echo "  3. Set 'Spawn rate' to 2"
	@echo "  4. Click 'Start swarming'"
	@echo "  5. Watch traces in Jaeger UI: http://localhost:16686"
	@echo ""
	docker-compose run --rm -it load-test \
		locust -f /app/load_test.py \
		--host=http://order-service:8003 \
		--web \
		--csv=results

queries:
	@echo ""
	@echo "$(BLUE)📊 Running Jaeger API queries...$(NC)"
	@echo ""
	@echo "$(GREEN)1. Get all services:$(NC)"
	@curl -s http://localhost:16686/api/services | jq '.data // empty' || echo "No services yet"
	@echo ""
	@echo "$(GREEN)2. Get order-service operations:$(NC)"
	@curl -s "http://localhost:16686/api/services/order-service/operations" | jq '.data // empty' || echo "No data"
	@echo ""
	@echo "$(GREEN)3. List recent traces:$(NC)"
	@curl -s "http://localhost:16686/api/traces?service=order-service&limit=5" | jq '.data[0:3] // empty' || echo "No traces yet"
	@echo ""

# ============================================================================
# Web Access
# ============================================================================

open-jaeger:
	@echo "$(BLUE)Opening Jaeger UI...$(NC)"
	@command -v open >/dev/null 2>&1 && open http://localhost:16686 || \
	command -v xdg-open >/dev/null 2>&1 && xdg-open http://localhost:16686 || \
	echo "Visit: http://localhost:16686"

open-prometheus:
	@echo "$(BLUE)Opening Prometheus...$(NC)"
	@command -v open >/dev/null 2>&1 && open http://localhost:9090 || \
	command -v xdg-open >/dev/null 2>&1 && xdg-open http://localhost:9090 || \
	echo "Visit: http://localhost:9090"

open-grafana:
	@echo "$(BLUE)Opening Grafana (admin:admin)...$(NC)"
	@command -v open >/dev/null 2>&1 && open http://localhost:3000 || \
	command -v xdg-open >/dev/null 2>&1 && xdg-open http://localhost:3000 || \
	echo "Visit: http://localhost:3000 (admin:admin)"

open-docs:
	@echo ""
	@echo "$(BLUE)📚 API Documentation:$(NC)"
	@echo ""
	@echo "User Service:    http://localhost:8001/docs"
	@echo "Product Service: http://localhost:8002/docs"
	@echo "Order Service:   http://localhost:8003/docs"
	@echo ""
	@command -v open >/dev/null 2>&1 && open http://localhost:8003/docs || \
	command -v xdg-open >/dev/null 2>&1 && xdg-open http://localhost:8003/docs || \
	echo "Visit the URLs above"

# ============================================================================
# Container Access
# ============================================================================

shell-user:
	@docker-compose exec user-service /bin/bash

shell-product:
	@docker-compose exec product-service /bin/bash

shell-order:
	@docker-compose exec order-service /bin/bash

# ============================================================================
# Database & Debug
# ============================================================================

db-users:
	@echo "$(BLUE)📋 Users in database:$(NC)"
	@docker-compose exec -T user-service sqlite3 /tmp/users.db ".headers on" "SELECT * FROM users;"

db-products:
	@echo "$(BLUE)📦 Products in database:$(NC)"
	@docker-compose exec -T product-service sqlite3 /tmp/products.db ".headers on" "SELECT * FROM products;"

db-orders:
	@echo "$(BLUE)📋 Orders in database:$(NC)"
	@docker-compose exec -T order-service sqlite3 /tmp/orders.db ".headers on" "SELECT * FROM orders;"

# ============================================================================
# Utilities
# ============================================================================

curl-health:
	@echo "$(BLUE)🔍 Service Health Checks$(NC)"
	@echo ""
	@echo "User Service:"
	@curl -s http://localhost:8001/health | jq .
	@echo ""
	@echo "Product Service:"
	@curl -s http://localhost:8002/health | jq .
	@echo ""
	@echo "Order Service:"
	@curl -s http://localhost:8003/health | jq .

curl-users:
	@curl -s http://localhost:8001/users | jq .

curl-products:
	@curl -s http://localhost:8002/products | jq .

curl-orders:
	@curl -s http://localhost:8003/orders | jq .

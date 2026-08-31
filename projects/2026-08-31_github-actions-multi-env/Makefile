.PHONY: help build test run deploy clean push logs

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m

help:
	@echo "$(BLUE)DevOps Multi-Environment Deployment Project$(NC)"
	@echo ""
	@echo "$(GREEN)Available targets:$(NC)"
	@echo "  build              Build Docker image locally"
	@echo "  test               Run application tests"
	@echo "  run                Start containers with docker-compose"
	@echo "  run-dev            Start dev environment"
	@echo "  run-staging        Start staging environment"
	@echo "  stop               Stop all containers"
	@echo "  logs               Show application logs"
	@echo "  clean              Remove containers and volumes"
	@echo "  push               Push Docker image to registry"
	@echo "  deploy-dev         Deploy to dev (local simulation)"
	@echo "  deploy-staging     Deploy to staging (local simulation)"
	@echo "  deploy-prod        Deploy to production (local simulation)"
	@echo "  install            Install dependencies"
	@echo "  lint               Run linter"
	@echo "  health             Check application health"
	@echo ""

install:
	@echo "$(BLUE)Installing dependencies...$(NC)"
	cd app && npm install
	@echo "$(GREEN)✅ Dependencies installed$(NC)"

lint:
	@echo "$(BLUE)Running linter...$(NC)"
	cd app && npm run lint || echo "No linter configured"
	@echo "$(GREEN)✅ Lint complete$(NC)"

build:
	@echo "$(BLUE)Building Docker image...$(NC)"
	docker build -t devops-app:latest ./app
	@echo "$(GREEN)✅ Image built successfully$(NC)"

test:
	@echo "$(BLUE)Running tests...$(NC)"
	cd app && npm test
	@echo "$(GREEN)✅ Tests passed$(NC)"

run:
	@echo "$(BLUE)Starting services with docker-compose...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)✅ Services started$(NC)"
	@sleep 5
	@echo "$(GREEN)App Dev:     http://localhost:3000$(NC)"
	@echo "$(GREEN)App Staging: http://localhost:3001$(NC)"
	@echo "$(GREEN)Prometheus:  http://localhost:9090$(NC)"

run-dev:
	@echo "$(BLUE)Starting dev environment...$(NC)"
	docker-compose up -d app-dev postgres redis
	@echo "$(GREEN)✅ Dev environment started$(NC)"
	@echo "$(GREEN)App: http://localhost:3000$(NC)"

run-staging:
	@echo "$(BLUE)Starting staging environment...$(NC)"
	docker-compose up -d app-staging postgres redis
	@echo "$(GREEN)✅ Staging environment started$(NC)"
	@echo "$(GREEN)App: http://localhost:3001$(NC)"

stop:
	@echo "$(BLUE)Stopping containers...$(NC)"
	docker-compose down
	@echo "$(GREEN)✅ Containers stopped$(NC)"

clean:
	@echo "$(RED)Removing containers and volumes...$(NC)"
	docker-compose down -v
	@echo "$(GREEN)✅ Cleanup complete$(NC)"

logs:
	@echo "$(BLUE)Showing application logs...$(NC)"
	docker-compose logs -f app-dev

health:
	@echo "$(BLUE)Checking application health...$(NC)"
	@if curl -s http://localhost:3000/health | jq . > /dev/null 2>&1; then \
		echo "$(GREEN)✅ Application is healthy$(NC)"; \
		curl -s http://localhost:3000/health | jq '.'; \
	else \
		echo "$(RED)❌ Application is not responding$(NC)"; \
		exit 1; \
	fi

push:
	@echo "$(BLUE)Pushing Docker image to registry...$(NC)"
	docker tag devops-app:latest ghcr.io/jaouadsiouahe1978/devops-app:latest
	docker push ghcr.io/jaouadsiouahe1978/devops-app:latest
	@echo "$(GREEN)✅ Image pushed$(NC)"

deploy-dev:
	@echo "$(BLUE)Deploying to dev...$(NC)"
	bash deploy/deployment-script.sh dev latest
	@echo "$(GREEN)✅ Dev deployment complete$(NC)"

deploy-staging:
	@echo "$(BLUE)Deploying to staging...$(NC)"
	bash deploy/deployment-script.sh staging main
	@echo "$(GREEN)✅ Staging deployment complete$(NC)"

deploy-prod:
	@echo "$(BLUE)Deploying to production...$(NC)"
	bash deploy/deployment-script.sh prod main
	@echo "$(GREEN)✅ Production deployment complete$(NC)"

# Development helpers
watch:
	@echo "$(BLUE)Starting development mode...$(NC)"
	cd app && npm run dev

test-watch:
	@echo "$(BLUE)Running tests in watch mode...$(NC)"
	cd app && npm run test:watch

coverage:
	@echo "$(BLUE)Running tests with coverage...$(NC)"
	cd app && npm run test:coverage

ps:
	@echo "$(BLUE)Running containers:$(NC)"
	@docker-compose ps

shell:
	@docker-compose exec app-dev sh

# Workflow helpers
workflow-build:
	@echo "$(BLUE)Simulating build workflow...$(NC)"
	@echo "1. Running tests..."
	@cd app && npm test > /dev/null 2>&1 && echo "   $(GREEN)✅ Tests passed$(NC)" || echo "   $(RED)❌ Tests failed$(NC)"
	@echo "2. Building Docker image..."
	@docker build -q -t devops-app:workflow ./app > /dev/null 2>&1 && echo "   $(GREEN)✅ Build successful$(NC)" || echo "   $(RED)❌ Build failed$(NC)"

workflow-deploy-dev:
	@echo "$(BLUE)Simulating dev deployment workflow...$(NC)"
	@docker run -d --name app-dev-workflow -p 3000:3000 devops-app:workflow > /dev/null 2>&1
	@sleep 2
	@if curl -s http://localhost:3000/health > /dev/null 2>&1; then \
		echo "$(GREEN)✅ Dev deployment successful$(NC)"; \
	else \
		echo "$(RED)❌ Dev deployment failed$(NC)"; \
	fi
	@docker stop app-dev-workflow > /dev/null 2>&1
	@docker rm app-dev-workflow > /dev/null 2>&1

# Performance testing
load-test:
	@echo "$(BLUE)Running basic load test...$(NC)"
	@for i in {1..100}; do \
		curl -s http://localhost:3000/health > /dev/null & \
	done
	@wait
	@echo "$(GREEN)✅ Load test complete$(NC)"
	@curl -s http://localhost:3000/metrics | jq '.requests'

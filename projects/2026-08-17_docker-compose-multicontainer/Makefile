.PHONY: help up down ps logs logs-backend logs-db logs-nginx \
        build rebuild db-shell backend-shell restart clean test health

help:
	@echo "Docker Compose Multi-Container Application"
	@echo "==========================================="
	@echo ""
	@echo "Available commands:"
	@echo "  make up              - Start all services"
	@echo "  make down            - Stop all services"
	@echo "  make ps              - Show running containers"
	@echo "  make logs            - View logs (all services)"
	@echo "  make logs-backend    - View backend logs"
	@echo "  make logs-db         - View database logs"
	@echo "  make logs-nginx      - View nginx logs"
	@echo "  make build           - Build Docker images"
	@echo "  make rebuild         - Rebuild Docker images (no cache)"
	@echo "  make db-shell        - Connect to PostgreSQL shell"
	@echo "  make backend-shell   - Connect to backend container"
	@echo "  make restart         - Restart all services"
	@echo "  make clean           - Stop and remove containers/volumes"
	@echo "  make test            - Test API endpoints"
	@echo "  make health          - Check service health"
	@echo ""

up:
	docker-compose up -d
	@echo "✅ Services started"
	@sleep 5
	@make health

down:
	docker-compose down
	@echo "✅ Services stopped"

ps:
	docker-compose ps

logs:
	docker-compose logs -f

logs-backend:
	docker-compose logs -f backend

logs-db:
	docker-compose logs -f postgres

logs-nginx:
	docker-compose logs -f nginx

build:
	docker-compose build

rebuild:
	docker-compose build --no-cache

db-shell:
	docker-compose exec postgres psql -U devops -d appdb

backend-shell:
	docker-compose exec backend bash

restart:
	docker-compose restart

clean:
	docker-compose down -v
	@echo "✅ All containers and volumes removed"

test:
	@echo "Testing API endpoints..."
	@echo ""
	@echo "1. Health check:"
	@curl -s http://localhost/api/health | jq . || echo "❌ Failed"
	@echo ""
	@echo "2. Database readiness:"
	@curl -s http://localhost/api/ready | jq . || echo "❌ Failed"
	@echo ""
	@echo "3. Get items:"
	@curl -s http://localhost/api/items | jq . || echo "❌ Failed"
	@echo ""
	@echo "4. Create item:"
	@curl -s -X POST http://localhost/api/items \
		-H "Content-Type: application/json" \
		-d '{"title":"Test Item","description":"From Makefile"}' | jq . || echo "❌ Failed"
	@echo ""
	@echo "5. Get statistics:"
	@curl -s http://localhost/api/stats | jq . || echo "❌ Failed"

health:
	@echo "Checking service health..."
	@echo ""
	@echo "Backend API:"
	@curl -s http://localhost/api/health | jq .status || echo "❌ Not responding"
	@echo ""
	@echo "Database:"
	@curl -s http://localhost/api/ready | jq .database || echo "❌ Not responding"
	@echo ""
	@echo "Nginx:"
	@curl -s http://localhost/health || echo "❌ Not responding"

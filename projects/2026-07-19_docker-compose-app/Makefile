.PHONY: help up down logs ps test clean build health

help:
	@echo "DevOps Multi-Container App - Docker Compose Helper"
	@echo ""
	@echo "Available commands:"
	@echo "  make up          - Start all containers"
	@echo "  make down        - Stop and remove all containers"
	@echo "  make logs        - View logs from all services"
	@echo "  make ps          - List running containers"
	@echo "  make build       - Build Docker images"
	@echo "  make health      - Check health status of all services"
	@echo "  make test        - Test API endpoints"
	@echo "  make clean       - Remove containers, images, and volumes"
	@echo "  make db-shell    - Connect to PostgreSQL shell"
	@echo "  make redis-cli   - Connect to Redis CLI"
	@echo "  make backend-shell - Connect to backend container"

up:
	docker compose up -d
	@echo "All services started!"
	@echo "Frontend: http://localhost"
	@echo "Grafana: http://localhost:3001 (admin/admin123!@)"

down:
	docker compose down

logs:
	docker compose logs -f

ps:
	docker compose ps

build:
	docker compose build

health:
	@echo "Checking health status..."
	@docker compose exec -it backend curl -s http://localhost:3000/health | jq . || echo "Backend unhealthy"
	@docker compose exec -it postgres pg_isready -U devops_user -d devops_db || echo "PostgreSQL unhealthy"
	@docker compose exec -it redis redis-cli ping || echo "Redis unhealthy"

test:
	@echo "Testing API endpoints..."
	@echo "1. Health check:"
	@curl -s http://localhost:3000/health | jq .
	@echo "\n2. List users:"
	@curl -s http://localhost:3000/api/users | jq .
	@echo "\n3. Backend metrics:"
	@curl -s http://localhost:3000/metrics | head -20

clean:
	docker compose down -v
	@echo "All containers, images, and volumes removed!"

db-shell:
	docker compose exec -it postgres psql -U devops_user -d devops_db

redis-cli:
	docker compose exec -it redis redis-cli

backend-shell:
	docker compose exec -it backend sh

restart:
	docker compose restart

pull:
	docker compose pull

config:
	docker compose config

events:
	docker compose events

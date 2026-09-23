.PHONY: help up down build logs ps clean test-gateway test-users test-products

help:
	@echo "Python Microservices Docker Compose - Available commands:"
	@echo ""
	@echo "  make up              - Build and start all services"
	@echo "  make down            - Stop and remove containers"
	@echo "  make build           - Build Docker images"
	@echo "  make logs            - View logs from all services"
	@echo "  make logs-gateway    - View API Gateway logs"
	@echo "  make logs-users      - View User Service logs"
	@echo "  make logs-products   - View Product Service logs"
	@echo "  make ps              - Show running containers status"
	@echo "  make restart         - Restart all services"
	@echo "  make clean           - Stop and remove everything (including volumes)"
	@echo "  make test-gateway    - Test API Gateway"
	@echo "  make test-users      - Test User Service"
	@echo "  make test-products   - Test Product Service"
	@echo "  make status          - Show health check status"
	@echo ""

up:
	docker-compose up --build -d
	@echo "Waiting for services to start..."
	@sleep 5
	@make status

down:
	docker-compose down

build:
	docker-compose build --no-cache

logs:
	docker-compose logs -f

logs-gateway:
	docker-compose logs -f api_gateway

logs-users:
	docker-compose logs -f user_service

logs-products:
	docker-compose logs -f product_service

ps:
	docker-compose ps

restart:
	docker-compose restart

clean:
	docker-compose down -v
	@echo "All containers and volumes removed"

status:
	@echo "=== Service Health Status ==="
	@curl -s http://localhost:8000/health | python3 -m json.tool || echo "❌ API Gateway"
	@echo ""
	@curl -s http://localhost:8001/health | python3 -m json.tool || echo "❌ User Service"
	@echo ""
	@curl -s http://localhost:8002/health | python3 -m json.tool || echo "❌ Product Service"
	@echo ""

test-gateway:
	@echo "Testing API Gateway..."
	@curl -s http://localhost:8000/ | python3 -m json.tool
	@echo ""
	@echo "Testing health endpoint..."
	@curl -s http://localhost:8000/health | python3 -m json.tool

test-users:
	@echo "Creating user..."
	@curl -s -X POST http://localhost:8000/users \
	  -H "Content-Type: application/json" \
	  -d '{"name":"Test User","email":"test@example.com"}' | python3 -m json.tool
	@echo ""
	@echo "Listing users..."
	@curl -s http://localhost:8000/users | python3 -m json.tool

test-products:
	@echo "Creating product..."
	@curl -s -X POST http://localhost:8000/products \
	  -H "Content-Type: application/json" \
	  -d '{"name":"Test Product","price":99.99,"description":"A test product"}' | python3 -m json.tool
	@echo ""
	@echo "Listing products..."
	@curl -s http://localhost:8000/products | python3 -m json.tool

test-all: test-gateway test-users test-products

shell-gateway:
	docker-compose exec api_gateway /bin/bash

shell-users:
	docker-compose exec user_service /bin/bash

shell-products:
	docker-compose exec product_service /bin/bash

shell-db:
	docker-compose exec postgres psql -U devops -d microservices_db

db-dump:
	docker-compose exec postgres pg_dump -U devops microservices_db > backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "Database dumped"

logs-db:
	docker-compose logs -f postgres

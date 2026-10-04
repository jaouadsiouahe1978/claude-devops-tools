.PHONY: help build up down logs status restart clean test

help:
	@echo "=== Docker Compose Multi-Tier Application ==="
	@echo "Available commands:"
	@echo "  make build      - Build all containers"
	@echo "  make up         - Start all services"
	@echo "  make down       - Stop all services"
	@echo "  make logs       - View logs from all services"
	@echo "  make ps         - Show running containers"
	@echo "  make status     - Check application status"
	@echo "  make restart    - Restart all services"
	@echo "  make clean      - Remove containers and volumes"
	@echo "  make test       - Run API tests"
	@echo "  make db-shell   - Open PostgreSQL shell"

build:
	@echo "📦 Building containers..."
	docker-compose build

up:
	@echo "🚀 Starting services..."
	docker-compose up -d
	@echo "✅ Services started!"
	@sleep 5
	@echo "📝 API available at http://localhost"
	@make status

down:
	@echo "🛑 Stopping services..."
	docker-compose down

logs:
	@echo "📜 Tailing logs (Ctrl+C to exit)..."
	docker-compose logs -f

ps:
	@echo "📋 Running containers:"
	docker-compose ps

status:
	@echo "🔍 Checking application status..."
	@curl -s http://localhost/api/status | python -m json.tool 2>/dev/null || echo "App not responding yet..."

restart:
	@echo "🔄 Restarting services..."
	docker-compose restart

clean:
	@echo "🧹 Removing all containers and volumes..."
	docker-compose down -v
	@echo "✅ Cleaned!"

test:
	@echo "🧪 Running API tests..."
	@echo "GET /"
	@curl -s http://localhost/ | python -m json.tool
	@echo "\n\nGET /api/status"
	@curl -s http://localhost/api/status | python -m json.tool
	@echo "\n\nGET /api/users"
	@curl -s http://localhost/api/users | python -m json.tool
	@echo "\n\n✅ Tests completed!"

db-shell:
	@echo "🗄️  Opening PostgreSQL shell..."
	docker-compose exec db psql -U postgres -d myapp

app-shell:
	@echo "🐍 Opening Flask app shell..."
	docker-compose exec app bash

nginx-logs:
	@echo "🌐 Nginx logs:"
	docker-compose logs nginx

db-logs:
	@echo "📊 Database logs:"
	docker-compose logs db

app-logs:
	@echo "🐍 App logs:"
	docker-compose logs app

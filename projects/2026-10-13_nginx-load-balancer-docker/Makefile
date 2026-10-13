.PHONY: help up down logs logs-nginx logs-app test clean status

help:
	@echo "Nginx Load Balancer - Available Commands"
	@echo "========================================"
	@echo "  make up           - Start all services"
	@echo "  make down         - Stop all services"
	@echo "  make logs         - View all logs"
	@echo "  make logs-nginx   - View Nginx logs"
	@echo "  make logs-app     - View app logs"
	@echo "  make test         - Run load test"
	@echo "  make status       - Check service status"
	@echo "  make clean        - Remove containers and volumes"
	@echo "  make build        - Build images"

up:
	@echo "🚀 Starting services..."
	docker-compose up -d
	@echo "✅ Services started"
	@echo ""
	@make status

down:
	@echo "⏹️  Stopping services..."
	docker-compose down
	@echo "✅ Services stopped"

logs:
	docker-compose logs -f

logs-nginx:
	docker-compose logs -f nginx

logs-app:
	docker-compose logs -f app1 app2 app3

status:
	@echo "📊 Service Status:"
	@docker-compose ps
	@echo ""
	@echo "🌐 Testing endpoints:"
	@echo "  Root: curl http://localhost/"
	@echo "  Health: curl http://localhost/health"
	@echo "  API: curl http://localhost/api/info"

test:
	@echo "🧪 Running load test..."
	bash tests/load-test.sh

clean:
	@echo "🗑️  Cleaning up..."
	docker-compose down -v
	rm -rf logs/
	@echo "✅ Cleanup complete"

build:
	@echo "🔨 Building images..."
	docker-compose build --no-cache
	@echo "✅ Build complete"

shell-nginx:
	docker-compose exec nginx sh

shell-app1:
	docker-compose exec app1 sh

shell-app2:
	docker-compose exec app2 sh

shell-app3:
	docker-compose exec app3 sh

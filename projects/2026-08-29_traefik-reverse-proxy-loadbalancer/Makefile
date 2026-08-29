.PHONY: help init up down logs ps clean test

help:
	@echo "Traefik Reverse Proxy & Load Balancer"
	@echo "Available commands:"
	@echo "  make init     - Initialize certificates"
	@echo "  make up       - Start infrastructure"
	@echo "  make down     - Stop infrastructure"
	@echo "  make logs     - Show logs"
	@echo "  make ps       - Show containers"
	@echo "  make clean    - Clean up"
	@echo "  make test     - Test services"
	@echo "  make rebuild  - Rebuild and restart"

init:
	@mkdir -p traefik-certs
	@chmod 600 traefik-certs/acme.json 2>/dev/null || true

up: init
	@docker-compose up -d
	@echo "Infrastructure started!"
	@echo "Services: https://api1.localhost, https://api2.localhost, https://app.localhost"
	@echo "Dashboard: https://traefik.localhost:8443 (user: admin, pass: admin)"

down:
	@docker-compose down

ps:
	@docker-compose ps

logs:
	@docker-compose logs -f

logs-traefik:
	@docker-compose logs -f traefik

build:
	@docker-compose build --no-cache

rebuild: down build up

clean: down
	@docker-compose down -v

test:
	@echo "Testing API 1..."
	@curl -k -s https://api1.localhost/api/health -H "Host: api1.localhost" | head -c 100
	@echo ""
	@echo "Testing API 2..."
	@curl -k -s https://api2.localhost/api/health -H "Host: api2.localhost" | head -c 100
	@echo ""
	@echo "Testing App..."
	@curl -k -s https://app.localhost/api/health -H "Host: app.localhost" | head -c 100
	@echo ""

status:
	@echo "=== Traefik Infrastructure Status ==="
	@docker-compose ps
	@echo ""
	@echo "Dashboard: https://traefik.localhost:8443"

.PHONY: help start stop logs test clean reload

help:
	@echo "📊 Grafana + Prometheus + AlertManager"
	@echo ""
	@echo "Commands:"
	@echo "  make start   - Start the stack"
	@echo "  make stop    - Stop the stack"
	@echo "  make logs    - View real-time logs"
	@echo "  make test    - Run alert tests"
	@echo "  make clean   - Stop and remove volumes"
	@echo "  make reload  - Reload configs"

start:
	docker-compose up -d
	@echo "✅ Stack started!"

stop:
	docker-compose down

logs:
	docker-compose logs -f

test:
	bash scripts/test-alerts.sh

clean:
	docker-compose down -v

reload:
	@curl -X POST http://localhost:9090/-/reload
	@curl -X POST http://localhost:9093/-/reload
	@echo "✅ Config reloaded"

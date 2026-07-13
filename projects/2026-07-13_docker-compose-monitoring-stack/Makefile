.PHONY: help up down logs ps health status clean reset

help:
	@echo "📊 Docker Compose Monitoring Stack"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  up              Start all services"
	@echo "  down            Stop all services"
	@echo "  ps              Show running services"
	@echo "  logs            View logs from all services"
	@echo "  logs-prometheus View Prometheus logs"
	@echo "  logs-grafana    View Grafana logs"
	@echo "  logs-alertmanager View AlertManager logs"
	@echo "  health          Check health of services"
	@echo "  status          Show service status"
	@echo "  clean           Clean up containers and volumes"
	@echo "  reset           Hard reset (remove all data)"

up:
	@echo "🚀 Starting monitoring stack..."
	docker-compose up -d
	@echo "✅ Stack started!"
	@make health

down:
	@echo "🛑 Stopping monitoring stack..."
	docker-compose down
	@echo "✅ Stack stopped!"

ps:
	docker-compose ps

logs:
	docker-compose logs -f

logs-prometheus:
	docker-compose logs -f prometheus

logs-grafana:
	docker-compose logs -f grafana

logs-alertmanager:
	docker-compose logs -f alertmanager

health:
	@echo "🏥 Checking service health..."
	@echo -n "Prometheus: "
	@curl -s http://localhost:9090/-/healthy && echo "✅" || echo "❌"
	@echo -n "Grafana: "
	@curl -s http://localhost:3000/api/health >/dev/null && echo "✅" || echo "❌"
	@echo -n "AlertManager: "
	@curl -s http://localhost:9093/-/healthy && echo "✅" || echo "❌"
	@echo -n "Node Exporter: "
	@curl -s http://localhost:9100/metrics >/dev/null && echo "✅" || echo "❌"

status:
	@echo "📊 Monitoring Stack Status"
	@echo ""
	@docker-compose ps
	@echo ""
	@echo "🔗 Access Points:"
	@echo "   • Prometheus: http://localhost:9090"
	@echo "   • Grafana: http://localhost:3000"
	@echo "   • AlertManager: http://localhost:9093"
	@echo "   • Node Exporter: http://localhost:9100/metrics"

clean:
	@echo "🧹 Cleaning up containers..."
	docker-compose down
	@echo "✅ Cleanup complete!"

reset:
	@echo "⚠️  WARNING: This will delete all monitoring data!"
	@read -p "Are you sure? (y/N) " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "✅ Hard reset complete!"; \
	fi

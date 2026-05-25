.PHONY: help up down logs restart clean test

help:
	@echo "Commandes disponibles:"
	@echo "  make up          - Démarrer tous les services"
	@echo "  make down        - Arrêter les services"
	@echo "  make restart     - Redémarrer les services"
	@echo "  make logs        - Afficher les logs"
	@echo "  make logs-prom   - Logs Prometheus"
	@echo "  make logs-alert  - Logs AlertManager"
	@echo "  make test        - Tester les alertes"
	@echo "  make clean       - Nettoyer les volumes"
	@echo "  make status      - Vérifier le statut des services"

up:
	@echo "🚀 Démarrage des services..."
	docker-compose up -d
	@echo "✅ Services démarrés!"
	@echo "📊 Prometheus: http://localhost:9090"
	@echo "🚨 AlertManager: http://localhost:9093"

down:
	@echo "🛑 Arrêt des services..."
	docker-compose down
	@echo "✅ Services arrêtés"

restart:
	@echo "🔄 Redémarrage des services..."
	docker-compose restart
	@echo "✅ Services redémarrés"

logs:
	docker-compose logs -f

logs-prom:
	docker-compose logs -f prometheus

logs-alert:
	docker-compose logs -f alertmanager

status:
	@echo "📋 Status des services:"
	docker-compose ps

test:
	@echo "🧪 Test des alertes..."
	@echo "CPU Usage:"
	curl -s "http://localhost:9090/api/v1/query?query=node_cpu_seconds_total" | jq '.data.result | length'
	@echo "Mémoire:"
	curl -s "http://localhost:9090/api/v1/query?query=node_memory_MemAvailable_bytes" | jq '.data.result | length'
	@echo "✅ Test complété"

test-alerts:
	@echo "🧪 Vérifier les alertes actives:"
	curl -s "http://localhost:9090/api/v1/alerts?active" | jq '.data.alerts | length'

validate-config:
	@echo "✅ Validation configuration Prometheus..."
	docker run --rm -v $(PWD)/prometheus:/config prom/prometheus:latest --config.file=/config/prometheus.yml --dry-run
	@echo "✅ Validation configuration AlertManager..."
	docker run --rm -v $(PWD)/alertmanager:/config prom/alertmanager:latest -config.file=/config/alertmanager.yml --dry-run

clean:
	@echo "🗑️  Nettoyage..."
	docker-compose down -v
	rm -rf alertmanager_data prometheus_data
	@echo "✅ Nettoyage complété"

shell-prom:
	docker exec -it prometheus sh

shell-alert:
	docker exec -it alertmanager sh

shell-node:
	docker exec -it node_exporter sh

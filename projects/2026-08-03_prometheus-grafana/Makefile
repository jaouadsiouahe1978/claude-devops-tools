.PHONY: help up down logs clean test

help:
	@echo "Prometheus + Grafana Monitoring Stack"
	@echo "======================================"
	@echo "make up       - Démarrer la stack"
	@echo "make down     - Arrêter la stack"
	@echo "make logs     - Afficher les logs"
	@echo "make clean    - Supprimer les volumes"
	@echo "make test     - Tester les endpoints"
	@echo "make status   - Vérifier le statut des services"

up:
	docker-compose up -d
	@echo "✓ Stack démarrée"
	@echo "Prometheus: http://localhost:9090"
	@echo "Grafana: http://localhost:3000 (admin/admin)"
	@echo "Node Exporter: http://localhost:9100/metrics"
	@echo "cAdvisor: http://localhost:8080"
	@echo "App: http://localhost:8000"

down:
	docker-compose down

logs:
	docker-compose logs -f

clean:
	docker-compose down -v
	@echo "✓ Volumes supprimés"

test:
	@echo "Testing endpoints..."
	@curl -s http://localhost:9090/-/healthy | jq . && echo "✓ Prometheus OK" || echo "✗ Prometheus DOWN"
	@curl -s http://localhost:3000/api/health | jq . && echo "✓ Grafana OK" || echo "✗ Grafana DOWN"
	@curl -s http://localhost:9100/metrics | head -5 && echo "✓ Node Exporter OK" || echo "✗ Node Exporter DOWN"
	@curl -s http://localhost:8080/ | head -5 && echo "✓ cAdvisor OK" || echo "✗ cAdvisor DOWN"
	@curl -s http://localhost:8000/health | jq . && echo "✓ App OK" || echo "✗ App DOWN"

status:
	@echo "Service Status:"
	@docker-compose ps

shell-prometheus:
	docker-compose exec prometheus /bin/sh

shell-grafana:
	docker-compose exec grafana /bin/bash

shell-app:
	docker-compose exec sample_app /bin/bash

query:
	@echo "Prometheus PromQL Examples:"
	@echo "1. node_cpu_seconds_total - CPU metrics"
	@echo "2. node_memory_MemAvailable_bytes - Memory"
	@echo "3. container_memory_usage_bytes - Container memory"
	@echo "4. up - Scrape status"
	@echo ""
	@echo "Visit http://localhost:9090 and enter these queries in Graph view"

load-test:
	@echo "Generating load on sample_app..."
	@for i in {1..100}; do curl -s http://localhost:8000/api/data > /dev/null & done
	@wait
	@echo "✓ Load test complete"

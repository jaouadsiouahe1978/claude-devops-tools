.PHONY: help up down logs clean restart status

help:
	@echo "🚀 Monitoring Stack - Commandes disponibles"
	@echo ""
	@echo "make up       - Démarrer la stack"
	@echo "make down     - Arrêter la stack"
	@echo "make logs     - Voir les logs de tous les services"
	@echo "make restart  - Redémarrer la stack"
	@echo "make clean    - Nettoyer (arrêter + supprimer volumes)"
	@echo "make status   - État des services"
	@echo "make urls     - Afficher les URLs des services"

up:
	@echo "📦 Démarrage de la stack..."
	docker-compose up -d
	@echo "✅ Stack démarrée !"
	@make urls

down:
	@echo "⛔ Arrêt de la stack..."
	docker-compose down
	@echo "✅ Stack arrêtée !"

logs:
	docker-compose logs -f

logs-prometheus:
	docker-compose logs -f prometheus

logs-grafana:
	docker-compose logs -f grafana

restart:
	@echo "🔄 Redémarrage..."
	docker-compose restart
	@echo "✅ Stack redémarrée !"

clean:
	@echo "🧹 Nettoyage complet..."
	docker-compose down -v
	@echo "✅ Nettoyage terminé !"

status:
	@echo "📊 État des services:"
	docker-compose ps

urls:
	@echo ""
	@echo "🔗 URLs des services:"
	@echo "  Prometheus:   http://localhost:9090"
	@echo "  Grafana:      http://localhost:3000 (admin/admin)"
	@echo "  Node Export:  http://localhost:9100/metrics"
	@echo "  cAdvisor:     http://localhost:8080"
	@echo ""

health-check:
	@echo "🏥 Vérification de la santé..."
	@echo -n "Prometheus: "
	@curl -s http://localhost:9090/-/healthy > /dev/null && echo "✅ OK" || echo "❌ DOWN"
	@echo -n "Grafana: "
	@curl -s http://localhost:3000/api/health > /dev/null && echo "✅ OK" || echo "❌ DOWN"
	@echo -n "Node Exporter: "
	@curl -s http://localhost:9100/metrics > /dev/null && echo "✅ OK" || echo "❌ DOWN"
	@echo -n "cAdvisor: "
	@curl -s http://localhost:8080/api/v1.3/machine > /dev/null && echo "✅ OK" || echo "❌ DOWN"
	@echo ""

query-example:
	@echo "📈 Exemples de requêtes PromQL:"
	@echo ""
	@echo "1. Vérifier l'état des services:"
	@curl -s 'http://localhost:9090/api/v1/query?query=up' | jq '.data.result[] | {job: .metric.job, instance: .metric.instance, value: .value}'
	@echo ""
	@echo "2. CPU utilisé (en %):"
	@curl -s 'http://localhost:9090/api/v1/query?query=100*(1-avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])))' | jq '.data.result[] | {instance: .metric.instance, cpu_usage: .value}'
	@echo ""
	@echo "3. Mémoire utilisée:"
	@curl -s 'http://localhost:9090/api/v1/query?query=node_memory_MemAvailable_bytes' | jq '.data.result[] | {instance: .metric.instance, memory_available: .value}'
	@echo ""

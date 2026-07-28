.PHONY: help up down test deploy check clean logs status

help:
	@echo "🚀 Ansible Configuration Management - Commandes disponibles"
	@echo ""
	@echo "  make up          - Démarrer l'infrastructure Docker"
	@echo "  make down        - Arrêter et nettoyer l'infrastructure"
	@echo "  make test        - Lancer les tests et dry-run"
	@echo "  make deploy      - Exécuter le playbook (déploiement réel)"
	@echo "  make check       - Valider la syntaxe Ansible (--check mode)"
	@echo "  make logs        - Afficher les logs en temps réel"
	@echo "  make status      - Afficher l'état des containers"
	@echo "  make clean       - Nettoyer les fichiers temporaires"
	@echo ""

up:
	@echo "📦 Démarrage de l'infrastructure Docker..."
	docker-compose up -d
	@echo "✅ Infrastructure démarrée"
	@sleep 3
	@docker-compose ps

down:
	@echo "🛑 Arrêt de l'infrastructure..."
	docker-compose down -v
	@echo "✅ Infrastructure arrêtée"

test: up
	@echo "🧪 Lancement des tests..."
	@bash test-deployment.sh

deploy:
	@echo "🚀 Déploiement en cours..."
	@if [ ! -f "playbooks/main.yml" ]; then \
		echo "❌ Playbook main.yml introuvable"; \
		exit 1; \
	fi
	ansible-playbook playbooks/main.yml -v

check:
	@echo "✅ Validation de la syntaxe Ansible..."
	@ansible-playbook playbooks/main.yml --syntax-check
	@echo "✅ Dry-run du playbook..."
	@ansible-playbook playbooks/main.yml --check --diff -v

logs:
	@docker-compose logs -f

status:
	@echo "📊 État des containers:"
	@docker-compose ps
	@echo ""
	@echo "🔍 Inventaire Ansible:"
	@ansible all -i inventory.yml --list-hosts 2>/dev/null || echo "  Aucun host accessible"

clean:
	@echo "🧹 Nettoyage des fichiers temporaires..."
	@rm -rf /tmp/ansible* .ansible-cache 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@echo "✅ Nettoyage complété"

# Commandes avancées
ping:
	@ansible all -i inventory.yml -m ping

facts:
	@ansible all -i inventory.yml -m setup | grep -E "ansible_(hostname|os_family|distribution)"

restart-nginx:
	@ansible webservers -i inventory.yml -m service -a "name=nginx state=restarted"

restart-postgres:
	@ansible databases -i inventory.yml -m service -a "name=postgresql state=restarted"

verify-deployment:
	@echo "🔍 Vérification du déploiement..."
	@echo ""
	@echo "📌 Serveurs Web:"
	@curl -s http://localhost:8080/health || echo "  web1: Non accessible"
	@curl -s http://localhost:8081/health || echo "  web2: Non accessible"
	@echo ""
	@echo "🗄️  Base de Données:"
	@docker-compose exec -T db psql -U postgres -c "SELECT version();" 2>/dev/null || echo "  PostgreSQL: Non accessible"
	@echo ""
	@echo "📊 Monitoring:"
	@curl -s http://localhost:9090/-/healthy 2>/dev/null | head -1 || echo "  Prometheus: Non accessible"

# Commandes de debug
shell-web1:
	@docker-compose exec web1 /bin/sh

shell-web2:
	@docker-compose exec web2 /bin/sh

shell-db:
	@docker-compose exec db /bin/sh

shell-monitoring:
	@docker-compose exec monitoring /bin/sh

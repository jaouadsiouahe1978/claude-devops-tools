.PHONY: help up down logs restart rebuild clean test

help:
	@echo "🐳 Docker Compose Web Application - Makefile Commands"
	@echo ""
	@echo "Usage: make [command]"
	@echo ""
	@echo "Commands:"
	@echo "  up              - Démarrer tous les services"
	@echo "  down            - Arrêter tous les services"
	@echo "  restart         - Redémarrer tous les services"
	@echo "  rebuild         - Rebuild les images Docker"
	@echo "  logs            - Afficher les logs en temps réel"
	@echo "  logs-app        - Logs de l'application Node.js"
	@echo "  logs-db         - Logs de PostgreSQL"
	@echo "  logs-redis      - Logs de Redis"
	@echo "  logs-nginx      - Logs de Nginx"
	@echo "  shell-app       - Accéder au shell du conteneur app"
	@echo "  shell-db        - Accéder au psql de PostgreSQL"
	@echo "  shell-redis     - Accéder à redis-cli"
	@echo "  ps              - Afficher l'état des services"
	@echo "  clean           - Arrêter et supprimer les conteneurs et volumes"
	@echo "  test            - Tester les endpoints API"
	@echo "  init            - Initialiser le projet (.env file)"
	@echo "  compose-config  - Valider la configuration docker-compose.yml"
	@echo ""

init:
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "✅ .env créé à partir de .env.example"; \
	else \
		echo "⚠️  .env existe déjà"; \
	fi

up:
	@echo "🚀 Démarrage des services..."
	docker-compose up -d
	@echo "✅ Services démarrés!"
	@sleep 3
	@echo ""
	@echo "📊 État des services:"
	@docker-compose ps
	@echo ""
	@echo "🌐 Accès:"
	@echo "  - Application: http://localhost"
	@echo "  - API: http://localhost/api"
	@echo "  - PgAdmin: http://localhost:5050"
	@echo ""

down:
	@echo "🛑 Arrêt des services..."
	docker-compose down
	@echo "✅ Services arrêtés!"

restart: down up
	@echo "🔄 Services redémarrés!"

rebuild:
	@echo "🔨 Rebuild des images..."
	docker-compose build --no-cache
	@echo "✅ Build terminé!"

logs:
	docker-compose logs -f

logs-app:
	docker-compose logs -f app

logs-db:
	docker-compose logs -f db

logs-redis:
	docker-compose logs -f redis

logs-nginx:
	docker-compose logs -f nginx

ps:
	@echo "📊 État des services:"
	docker-compose ps
	@echo ""
	@echo "📈 Statistiques des conteneurs:"
	docker stats --no-stream

shell-app:
	docker-compose exec app sh

shell-db:
	docker-compose exec db psql -U postgres -d myapp

shell-redis:
	docker-compose exec redis redis-cli

compose-config:
	docker-compose config

test:
	@echo "🧪 Test des endpoints API..."
	@echo ""
	@echo "1️⃣  Health Check:"
	@curl -s http://localhost/api/health | jq . || echo "❌ Erreur"
	@echo ""
	@echo "2️⃣  Liste des utilisateurs:"
	@curl -s http://localhost/api/users | jq . || echo "❌ Erreur"
	@echo ""
	@echo "3️⃣  Créer un nouvel utilisateur:"
	@curl -s -X POST http://localhost/api/users \
		-H "Content-Type: application/json" \
		-d '{"name":"Test User","email":"test@example.com"}' | jq . || echo "❌ Erreur"
	@echo ""
	@echo "4️⃣  Récupérer utilisateur (ID 1):"
	@curl -s http://localhost/api/users/1 | jq . || echo "❌ Erreur"
	@echo ""

clean:
	@echo "🧹 Suppression des conteneurs, images et volumes..."
	docker-compose down -v
	docker-compose system prune -f
	@echo "✅ Nettoyage terminé!"

status:
	@echo "📊 État du projet:"
	@echo "Images Docker:"
	@docker images | grep -E "webapp|postgres|redis|nginx" || echo "Aucune image trouvée"
	@echo ""
	@echo "Conteneurs:"
	@docker-compose ps
	@echo ""
	@echo "Volumes:"
	@docker volume ls | grep webapp || echo "Aucun volume trouvé"

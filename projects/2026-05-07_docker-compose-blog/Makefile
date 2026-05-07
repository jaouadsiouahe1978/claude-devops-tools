.PHONY: help up down logs build restart clean ps shell-app shell-mongo shell-redis

help:
	@echo "🚀 Blog Platform - Docker Compose Commands"
	@echo ""
	@echo "Available commands:"
	@echo "  make up          - Démarrer tous les conteneurs"
	@echo "  make down        - Arrêter les conteneurs"
	@echo "  make logs        - Afficher les logs"
	@echo "  make build       - Builder l'image Docker"
	@echo "  make restart     - Redémarrer les services"
	@echo "  make clean       - Arrêter et supprimer conteneurs + volumes"
	@echo "  make ps          - Voir le statut des conteneurs"
	@echo "  make shell-app   - Accéder au shell de l'app"
	@echo "  make shell-mongo - Accéder à MongoDB"
	@echo "  make shell-redis - Accéder à Redis"
	@echo ""

up:
	@echo "🚀 Démarrage des conteneurs..."
	docker-compose up -d
	@echo "✅ Services démarrés!"
	@echo ""
	@echo "📊 URLs disponibles:"
	@echo "  - Blog UI: http://localhost"
	@echo "  - API: http://localhost/api/posts"
	@echo "  - Nginx stats: http://localhost:8080/nginx_status"
	@echo "  - Visualizer: http://localhost:8081"

down:
	@echo "🛑 Arrêt des conteneurs..."
	docker-compose down
	@echo "✅ Services arrêtés"

logs:
	docker-compose logs -f

logs-app:
	docker-compose logs -f app

logs-mongo:
	docker-compose logs -f mongodb

logs-redis:
	docker-compose logs -f redis

logs-nginx:
	docker-compose logs -f nginx

build:
	@echo "🔨 Building Docker image..."
	docker-compose build --no-cache

rebuild:
	@echo "🔨 Rebuilding and starting..."
	docker-compose up --build -d

restart:
	@echo "🔄 Redémarrage des services..."
	docker-compose restart
	@echo "✅ Services redémarrés"

clean:
	@echo "🧹 Suppression complète..."
	docker-compose down -v
	@echo "✅ Nettoyage terminé"

ps:
	docker-compose ps

shell-app:
	docker-compose exec app sh

shell-mongo:
	docker-compose exec mongodb mongosh

shell-redis:
	docker-compose exec redis redis-cli

test-api:
	@echo "🧪 Test de l'API..."
	@echo ""
	@echo "1️⃣ Health check:"
	curl -s http://localhost/health | jq . || echo "API non accessible"
	@echo ""
	@echo "2️⃣ Créer un article de test:"
	curl -s -X POST http://localhost/api/posts \
	  -H "Content-Type: application/json" \
	  -d '{"title":"Article de test","content":"Contenu de test","author":"Test"}' | jq .
	@echo ""
	@echo "3️⃣ Lister les articles:"
	curl -s http://localhost/api/posts | jq .

prune:
	@echo "🧹 Suppression des images non utilisées..."
	docker system prune -f
	@echo "✅ Nettoyage Docker terminé"

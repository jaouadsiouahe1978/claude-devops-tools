# Python Microservices avec Docker Compose et Health Checks

## 📋 Description du Projet

Ce projet démontre comment construire et orchestrer une architecture **microservices** en Python avec Docker Compose. L'application inclut trois services interdépendants avec des health checks, de la persistance de données, et de la communication inter-conteneurs.

**Architecture :**
- **API Gateway** (Flask) : Point d'entrée principal
- **User Service** (Python/FastAPI) : Gestion des utilisateurs
- **Product Service** (Python/FastAPI) : Catalogue de produits  
- **PostgreSQL** : Base de données persistante
- **Redis** : Cache distribué
- **Nginx** : Reverse proxy et load balancer

## 🎯 Objectifs d'Apprentissage

✅ Construire et packager des applications Python dans Docker  
✅ Orchestrer plusieurs conteneurs avec Docker Compose  
✅ Implémenter des health checks pour la résilience  
✅ Gérer les volumes et la persistance de données  
✅ Configurer le networking inter-conteneurs  
✅ Utiliser des variables d'environnement pour la configuration  
✅ Mettre en place un reverse proxy Nginx  
✅ Monitorer et déboguer les microservices  

## 📦 Pré-requis

- Docker Desktop ou Docker Engine installé
- Docker Compose (v2.0+)
- Python 3.11+ (optionnel, pour tester localement)
- curl ou Postman pour tester les APIs

```bash
docker --version
docker-compose --version
```

## 🚀 Démarrage Rapide

### 1. Cloner et naviguer vers le projet
```bash
cd projects/2026-09-23_python-microservices-docker/
```

### 2. Démarrer l'infrastructure
```bash
# Construire les images et démarrer les conteneurs
docker-compose up --build -d

# Vérifier le statut
docker-compose ps
```

### 3. Vérifier les health checks
```bash
docker-compose ps  # Colonne STATUS doit montrer "healthy"
sleep 5  # Attendre que les services démarrent
docker ps --format "table {{.Names}}\t{{.Status}}"
```

### 4. Tester les APIs
```bash
# API Gateway
curl http://localhost:8000/

# User Service (via gateway)
curl -X POST http://localhost:8000/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice","email":"alice@example.com"}'

curl http://localhost:8000/users

# Product Service (via gateway)  
curl -X POST http://localhost:8000/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Laptop","price":999.99}'

curl http://localhost:8000/products
```

### 5. Monitorer les logs
```bash
# Tous les services
docker-compose logs -f

# Service spécifique
docker-compose logs -f api_gateway
docker-compose logs -f user_service
docker-compose logs -f product_service
```

### 6. Accéder aux services directement
```bash
# User Service (port 8001)
curl http://localhost:8001/docs  # Documentation Swagger

# Product Service (port 8002)  
curl http://localhost:8002/docs

# Nginx Dashboard
curl http://localhost/
```

### 7. Arrêter et nettoyer
```bash
docker-compose down       # Arrêter les conteneurs
docker-compose down -v    # Arrêter et supprimer les volumes
```

## 📁 Structure du Projet

```
2026-09-23_python-microservices-docker/
├── README.md                 # Documentation
├── docker-compose.yml        # Orchestration des services
├── .env                       # Variables d'environnement
├── nginx/
│   ├── Dockerfile            # Image Nginx personnalisée
│   └── nginx.conf            # Configuration reverse proxy
├── api_gateway/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app.py                # Flask - Point d'entrée
├── user_service/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── app.py                # FastAPI - Gestion users
│   └── models.py             # Modèles de données
├── product_service/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── app.py                # FastAPI - Gestion produits
│   └── models.py
├── postgres/
│   ├── Dockerfile
│   └── init.sql              # Initialisation DB
└── Makefile                  # Commandes pratiques
```

## 🔧 Commandes Pratiques

```bash
# Build et start
make up
make build
make logs

# Status et debug
make ps
make logs-gateway
make logs-users
make logs-products

# Tester
make test-gateway
make test-users
make test-products

# Cleanup
make down
make clean
```

## 🏥 Health Checks

Chaque service implémente un endpoint `/health` ou `/healthz` :

```bash
# Vérifier la santé de chaque service
curl -s http://localhost:8000/health | jq .
curl -s http://localhost:8001/health | jq .
curl -s http://localhost:8002/health | jq .
```

Docker Compose redémarre automatiquement les conteneurs en échec.

## 📊 Architecture Réseau

```
Internet
    ↓
[ Nginx Reverse Proxy :80, :443 ]
    ↓
[ API Gateway :8000 ]
    ├─→ [ User Service :8001 ]
    ├─→ [ Product Service :8002 ]
    └─→ [ Redis Cache ]
        
[ PostgreSQL :5432 ]
```

## 🔐 Variables d'Environnement (.env)

```env
# Database
DB_HOST=postgres
DB_USER=devops
DB_PASSWORD=secure_password_123
DB_NAME=microservices_db

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# Services
API_GATEWAY_PORT=8000
USER_SERVICE_PORT=8001
PRODUCT_SERVICE_PORT=8002
NGINX_PORT=80

# Environment
ENVIRONMENT=development
DEBUG=True
```

## 🧪 Scénarios de Test

### Test 1 : Créer un utilisateur
```bash
curl -X POST http://localhost:8000/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Bob","email":"bob@test.com"}'
```

### Test 2 : Lister les utilisateurs (depuis cache)
```bash
curl http://localhost:8000/users
```

### Test 3 : Ajouter un produit
```bash
curl -X POST http://localhost:8000/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Mouse","price":25.50}'
```

### Test 4 : Tester la résilience - Arrêter un service
```bash
docker-compose pause user_service
curl http://localhost:8000/users  # Doit échouer gracieusement
docker-compose unpause user_service
```

### Test 5 : Vérifier la persistance - Redémarrer les conteneurs
```bash
docker-compose down
docker-compose up -d
curl http://localhost:8000/users  # Les données sont toujours là
```

## 🎓 Concepts Clés Abordés

| Concept | Apprentissage |
|---------|---------------|
| **Containerization** | Packager chaque service dans Docker |
| **Orchestration** | Docker Compose pour coordonner les services |
| **Health Checks** | Monitoring automatique de la santé des services |
| **Networking** | Communication inter-conteneurs via réseau Docker |
| **Persistence** | Volumes Docker pour les données PostgreSQL/Redis |
| **Environment Config** | Gestion des configs via .env et variables |
| **Reverse Proxy** | Nginx pour router le trafic et du load balancing |
| **API Gateways** | Pattern microservices avec point d'entrée unique |
| **Logging** | Centralisation et debug des logs |
| **Scalability** | Comment scaler les services (docker-compose scale) |

## 📈 Extensions Possibles

1. **Monitoring avec Prometheus/Grafana**
   - Ajouter des métriques à chaque service
   - Visualiser la performance

2. **Logging Centralisé avec ELK Stack**
   - Elasticsearch + Logstash + Kibana

3. **Authentication/Authorization**
   - JWT tokens dans l'API Gateway
   - OAuth2 integration

4. **CI/CD Integration**
   - Tester avant de déployer
   - Déployer sur une vraie infra (Kubernetes)

5. **Database Replication**
   - PostgreSQL en haute disponibilité
   - Replica standby

6. **Message Queue**
   - RabbitMQ ou Kafka pour la communication asynchrone
   - Event-driven architecture

## 🐛 Troubleshooting

### "Port already in use"
```bash
# Trouver quel processus utilise le port
lsof -i :8000
# Changer le port dans .env ou docker-compose.yml
```

### "Cannot connect to the Docker daemon"
```bash
# Vérifier que Docker est lancé
sudo systemctl start docker
# Ou utiliser Docker Desktop
```

### "Service container not starting"
```bash
# Voir les logs
docker-compose logs user_service
# Reconstruire
docker-compose up --build --no-cache
```

### "Health check failing"
```bash
# Tester manuellement l'endpoint
docker exec <container_id> curl http://localhost:8000/health
# Vérifier les dépendances entre services
docker-compose logs
```

## 📚 Ressources Pédagogiques

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Microservices Patterns](https://microservices.io/)
- [FastAPI Tutorial](https://fastapi.tiangolo.com/)
- [PostgreSQL Docker](https://hub.docker.com/_/postgres)

## ✨ Points Clés à Retenir

✅ **Isolation** : Chaque service est isolé dans son conteneur  
✅ **Scalabilité** : Facile d'ajouter des réplicas avec `docker-compose scale`  
✅ **Résilience** : Health checks détectent les services défaillants  
✅ **Persistence** : Les volumes gardent les données entre redémarrages  
✅ **Observabilité** : Logs centralisés pour le debugging  
✅ **Configuration** : Variables d'environnement pour adapter l'infra  

## 📝 Auteur & Licence

Projet DevOps pédagogique - Grenoble SRE/DevOps Training  
Licence : MIT

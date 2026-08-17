# Docker Compose: Application Web Multi-Conteneurs avec Registry Local

## 📋 Description

Déployer une **application web complète** avec Docker Compose, composée de 3 services interdépendants :
- **Frontend** : Nginx (reverse proxy + serveur statique)
- **Backend** : Python Flask API
- **Database** : PostgreSQL avec données persistantes

L'objectif est de maîtriser :
- ✅ Création de Dockerfiles optimisés (multi-stage)
- ✅ Orchestration multi-conteneur avec `docker-compose.yml`
- ✅ Gestion des volumes et données persistantes
- ✅ Networking interne entre conteneurs
- ✅ Variables d'environnement et configuration
- ✅ Logs et débogage multi-service
- ✅ Développement local vs production

## 🎯 Pré-requis

- **Docker** : v20.10+
- **Docker Compose** : v1.29+
- **Git** installé
- Port **80** et **5432** disponibles localement (ou modifier le port-mapping)

## 📦 Architecture

```
┌─────────────────────────────────────────────────┐
│          Docker Compose Network                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────┐      ┌───────────────┐      │
│  │    Nginx     │      │  Flask API    │      │
│  │ :80 -> :80   │◄────►│ :5000 -> :80  │      │
│  │  Frontend    │      │  /api routes  │      │
│  └──────────────┘      └───────────────┘      │
│        │                      │                 │
│        │                      │                 │
│        │              ┌────────────────┐       │
│        │              │  PostgreSQL    │       │
│        │              │  :5432 -> :5432│       │
│        └─────────────►│  db volume     │       │
│                       └────────────────┘       │
│                                                 │
└─────────────────────────────────────────────────┘
```

## 🚀 Étapes de Réalisation

### 1️⃣ **Structure du Projet**
```bash
cd projects/2026-08-17_docker-compose-multicontainer/

# Structure créée :
.
├── docker-compose.yml          # Orchestration des 3 services
├── frontend/
│   ├── Dockerfile              # Nginx multi-stage
│   └── nginx.conf              # Configuration Nginx
├── backend/
│   ├── Dockerfile              # Python Flask multi-stage
│   ├── requirements.txt         # Dépendances Python
│   └── app.py                  # Application Flask
├── db/
│   └── init.sql                # Initialisation PostgreSQL
├── .env.example                # Variables d'env (template)
└── README.md
```

### 2️⃣ **Démarrage de l'Application**
```bash
# 1. Lancer tous les services
docker-compose up -d

# 2. Vérifier l'état
docker-compose ps

# 3. Tester l'API
curl http://localhost/api/health
curl http://localhost/api/items

# 4. Vérifier les logs
docker-compose logs -f backend
docker-compose logs -f postgres

# 5. Arrêter
docker-compose down
```

### 3️⃣ **Développement**
```bash
# Mode "watch" (recharge app lors des changes)
docker-compose up -d
docker-compose logs -f backend

# Modifier /backend/app.py et voir la mise à jour

# Accéder à la DB
docker-compose exec postgres psql -U devops -d appdb -c "SELECT * FROM items;"
```

### 4️⃣ **Données Persistantes**
```bash
# Les données PostgreSQL sont persistées dans un volume Docker nommé
docker volume ls
docker volume inspect docker-compose-multicontainer_postgres_data

# Nettoyer (supprime les volumes)
docker-compose down -v
```

### 5️⃣ **Debugging Multi-Conteneur**
```bash
# Logs d'un service
docker-compose logs postgres
docker-compose logs backend
docker-compose logs nginx

# Exécuter une commande dans un conteneur
docker-compose exec backend bash
docker-compose exec postgres psql -U devops -d appdb

# Inspecter la network
docker network ls
docker inspect $(docker-compose ps -q | head -1) | jq '.[0].NetworkSettings'
```

## 📚 Ce Qu'on Apprend

### Concepts DevOps
1. **Containerisation multi-stage** : Réduire la taille des images
2. **Orchestration locale** : `docker-compose.yml` pour dev/test
3. **Networking interne** : Communication entre conteneurs par DNS (service name)
4. **Volumes et Data Persistence** : Stockage des données avec PostgreSQL
5. **Environment Management** : `.env` pour config flexible
6. **Service Dependencies** : `depends_on` pour contrôler l'ordre de démarrage
7. **Health Checks** : Vérifier la disponibilité des services
8. **Logging & Monitoring** : Accéder aux logs multi-conteneur

### Compétences Pratiques
- Écrire des Dockerfiles optimisés
- Composer et orchestrer des services
- Déboguer les problèmes réseau/connectivity entre conteneurs
- Gérer les données persistantes
- Comprendre la différence dev/prod

## 🔧 Configuration Avancée

### Variables d'Environnement
```bash
# Copier le template
cp .env.example .env

# Modifier les valeurs
POSTGRES_PASSWORD=your_secure_password
FLASK_ENV=development
DB_HOST=postgres  # DNS interne
```

### Health Checks
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

### Multi-stage Build (Optimisation)
```dockerfile
# Stage 1: Builder
FROM python:3.11 as builder
WORKDIR /app
RUN pip install -r requirements.txt

# Stage 2: Runtime (taille minimale)
FROM python:3.11-slim
COPY --from=builder /app /app
```

## 📊 Cas d'Usage

✅ **Développement local** : Team travaille avec l'exact même stack  
✅ **Staging** : Tester avant production  
✅ **CI/CD** : Lancer les tests dans des conteneurs identiques  
✅ **Formation** : Apprendre DevOps sans dépendre de cloud  

## ⚠️ Notes Importantes

- **Pas pour la production** : docker-compose est dev/staging uniquement
- **Pour la prod** : Utiliser Kubernetes, ECS, ou équivalent
- **Sécurité** : Pas de passwords en dur dans le code (utiliser `.env`)
- **Réseau** : Les conteneurs se trouvent par le nom du service (DNS interne)

## 🧪 Tests

```bash
# Vérifier que les services démarrent
docker-compose up -d
sleep 5
docker-compose ps

# Test de connectivité
docker-compose exec backend curl http://postgres:5432 -v 2>&1 | grep -i "refused\|connected"

# Test API
docker-compose exec backend python -c "import requests; print(requests.get('http://localhost:5000/health').status_code)"

# Nettoyer
docker-compose down -v
```

## 📖 Ressources

- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Networking in Docker Compose](https://docs.docker.com/compose/networking/)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---
**Durée estimée** : 1-2 heures  
**Difficulté** : ⭐⭐☆ (Intermédiaire)  
**Compétences** : Docker, Docker Compose, Networking, Debugging

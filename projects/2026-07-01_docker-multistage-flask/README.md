# Docker Multi-stage Build : Flask + PostgreSQL

## 🎯 Objectif
Créer une application Flask avec base de données PostgreSQL en utilisant les **builds multi-étages Docker** pour optimiser la taille des images de production.

**Ce qu'on apprend:**
- Les builds multi-étages Docker (réduire la taille de ~850MB à ~150MB)
- Gérer les dépendances Python avec requirements.txt
- Orchestrer plusieurs services avec Docker Compose
- Bonnes pratiques : .dockerignore, layers optimization
- Différencier l'image de build et l'image de runtime

## 📋 Pré-requis
- Docker et Docker Compose installés
- Python 3.9+ (local)
- Connaissance basique de Docker et Flask

## 🛠️ Structure du projet
```
2026-07-01_docker-multistage-flask/
├── README.md
├── Dockerfile (multi-stage)
├── .dockerignore
├── docker-compose.yml
├── requirements.txt
├── app/
│   └── app.py (Flask app)
└── init-db.sql (script PostgreSQL)
```

## 📚 Étapes de réalisation

### 1. Créer l'application Flask
```bash
# Structure de base
mkdir -p app
cd app
# Créer app.py (voir fichier fourni)
```

### 2. Créer les dépendances Python
```bash
# requirements.txt contient :
# - Flask==2.3.2
# - psycopg2-binary==2.9.6
# - SQLAlchemy==2.0.0
```

### 3. Construire l'image multi-étages
```bash
# Le Dockerfile utilise 3 étapes :
# Étape 1 (builder) : installer les dépendances C/compilation
# Étape 2 (runtime) : copier uniquement les fichiers compilés
# Résultat : image production légère et sécurisée
docker build -t flask-app:latest .
```

### 4. Vérifier la taille des images
```bash
# Avant multi-stage : ~850MB
# Après multi-stage : ~150MB
docker images | grep flask-app
```

### 5. Lancer avec Docker Compose
```bash
docker-compose up -d
```

### 6. Tester l'application
```bash
# Health check
curl http://localhost:5000/health

# Test DB connection
curl http://localhost:5000/db-test

# Voir les logs
docker-compose logs -f web
```

### 7. Nettoyer
```bash
docker-compose down -v
docker rmi flask-app:latest
```

## 🔍 Points clés du Dockerfile multi-stage

### Stage 1 : Builder
```dockerfile
FROM python:3.9-slim as builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt
```
- Installe les dépendances avec compilations C
- Image intermédiaire jetée = plus besoin d'espace pour ça

### Stage 2 : Runtime
```dockerfile
FROM python:3.9-slim
COPY --from=builder /root/.local /root/.local
COPY app/ .
CMD ["python", "app.py"]
```
- Copie UNIQUEMENT les dépendances compilées du stage builder
- Pas de pip, pas de compilateur, image compacte
- ~700MB économisés !

## 📊 Commandes utiles

| Commande | Description |
|----------|-------------|
| `docker build --no-cache -t flask-app:v1 .` | Rebuild sans cache |
| `docker history flask-app` | Voir les layers |
| `docker-compose logs web` | Logs du service Flask |
| `docker exec -it <container_id> psql -U postgres` | Accès direct à PostgreSQL |
| `docker build --progress=plain .` | Voir le build en détail |

## ✅ Validation
- [ ] Image créée avec `docker build`
- [ ] `docker images` montre une image < 200MB
- [ ] `docker-compose up` fonctionne
- [ ] `curl localhost:5000/health` retourne 200
- [ ] `curl localhost:5000/db-test` peut se connecter à la DB
- [ ] Logs ne montrent pas d'erreurs

## 🎓 Concepts DevOps abordés
- **Build multi-stage**: Pattern clé pour optimiser les images
- **Layer caching**: Chaque RUN crée un layer Docker
- **Security**: Réduire la surface d'attaque (moins de dépendances)
- **Performance**: Images légères = déploiement rapide
- **CI/CD ready**: Images reproductibles et testables

## 🚀 Aller plus loin
1. Ajouter un stage `test` pour valider l'app avant production
2. Utiliser Alpine instead de slim pour 50MB de moins
3. Ajouter un healthcheck au docker-compose
4. Mettre en place un registry local (Docker Trusted Registry)
5. Automatiser avec GitHub Actions

## 📖 Ressources
- Docker Best Practices: https://docs.docker.com/develop/dev-best-practices/
- Multi-stage builds: https://docs.docker.com/build/building/multi-stage/
- Python in Docker: https://docs.docker.com/language/python/build-images/

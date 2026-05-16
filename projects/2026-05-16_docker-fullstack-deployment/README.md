# Docker Full-Stack Deployment

## 📋 Objectif
Déployer une application complète (frontend + API backend + base de données) en utilisant Docker et Docker Compose. Ce projet permet de comprendre la containerisation et l'orchestration multi-conteneurs.

## 🛠 Technos utilisées
- **Docker** : Containerisation des services
- **Docker Compose** : Orchestration multi-conteneurs
- **Node.js** : API backend
- **PostgreSQL** : Base de données
- **HTML/CSS/JavaScript** : Frontend simple
- **Nginx** : Reverse proxy (optionnel)

## 📚 Ce qu'on apprend
- Créer un Dockerfile optimisé (multi-stage build)
- Configurer Docker Compose avec plusieurs services
- Gérer les volumes et networks Docker
- Configurer les variables d'environnement
- Debugger les containers (logs, exec)
- Networking entre containers
- Persistence des données

## 📋 Pré-requis
```bash
# Installer Docker et Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Ou sur Debian/Ubuntu
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-plugin
```

## 🚀 Étapes de réalisation

### 1. Préparation
```bash
# Copier les variables d'environnement
cp .env.example .env

# Vérifier que Docker est bien installé
docker --version
docker-compose version
```

### 2. Structure du projet
```
docker-fullstack-deployment/
├── docker-compose.yml       # Orchestration
├── .env.example             # Exemple de config (à copier en .env)
├── backend/
│   ├── Dockerfile           # Image Node.js
│   ├── package.json         # Dépendances
│   ├── server.js            # Application
│   └── init.sql             # Schema PostgreSQL
├── frontend/
│   ├── Dockerfile           # Image Nginx
│   ├── index.html           # Application web
│   ├── nginx.conf           # Configuration Nginx
│   └── .dockerignore
└── README.md                # Ce fichier
```

### 3. Lancer l'application
```bash
# Se placer dans le répertoire du projet
cd projects/2026-05-16_docker-fullstack-deployment

# Construire et lancer les services
docker-compose up -d

# Vérifier les logs
docker-compose logs -f

# Vérifier l'état des services
docker-compose ps

# Accéder à l'application
# Frontend : http://localhost:3000
# API      : http://localhost:5000
```

### 4. Debugger et interagir
```bash
# Entrer dans un container
docker-compose exec backend bash
docker-compose exec postgres psql -U devops_user -d devops_db

# Voir les logs d'un service
docker-compose logs backend
docker-compose logs postgres

# Redémarrer un service
docker-compose restart backend

# Arrêter tous les services
docker-compose down

# Arrêter et supprimer les volumes (réinitialiser complètement)
docker-compose down -v
```

### 5. Vérifier la connexion BD
```bash
# Via curl
curl http://localhost:5000/api/health

# Ou accéder directement à la BD
docker-compose exec postgres psql -U devops_user -d devops_db -c "SELECT version();"
```

## 🔍 Points clés à comprendre

### Docker Compose networking
- Les services se connectent par leur nom de service (ex: `postgres:5432`)
- Un réseau bridge est créé automatiquement
- Les variables d'environnement permettent de configurer les connexions

### Optimisation des images
- Multi-stage build pour réduire la taille
- `.dockerignore` pour exclure les fichiers inutiles
- Utiliser des images de base légères (`node:20-alpine`)

### Persistence des données
- Volume `postgres_data` conserve les données même après `down`
- Utiliser `docker-compose down` sans `-v` pour garder les données

## 📈 Améliorations possibles
- Ajouter un Nginx reverse proxy
- Configurer les health checks
- Ajouter un service Redis pour le cache
- Implémenter les secrets Docker
- Ajouter des tests avec Docker
- Monitoring avec Prometheus + Grafana

## 🧪 Cas de test
- Créer une todo dans l'API
- Vérifier que les données persistent après redémarrage
- Modifier le code du backend et observer les changements
- Voir les logs en temps réel

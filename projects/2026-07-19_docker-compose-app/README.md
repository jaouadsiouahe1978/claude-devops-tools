# Multi-Container App avec Docker Compose et Health Checks

## 📋 Description
Déploiement d'une application web full-stack avec Docker Compose incluant:
- **Frontend**: Nginx (serveur web statique)
- **Backend**: Node.js (API REST)
- **Database**: PostgreSQL (stockage données)
- **Cache**: Redis (sessions/cache)
- **Monitoring**: Prometheus + Grafana (observabilité)

Intégration complète des health checks pour assurer la robustesse de l'infrastructure.

## 🎯 Objectifs
1. Créer une application multi-conteneur orchestrée avec Docker Compose
2. Implémenter des health checks pour chaque service
3. Configurer les volumes pour la persistance des données
4. Mettre en place des variables d'environnement (.env)
5. Créer un réseau personnalisé pour la communication inter-conteneurs
6. Ajouter du monitoring avec Prometheus et Grafana

## 🛠️ Technologies
- **Docker & Docker Compose**: Orchestration multi-conteneur
- **Node.js**: Backend API
- **PostgreSQL**: Base de données
- **Redis**: Cache/Sessions
- **Nginx**: Reverse proxy
- **Prometheus**: Métriques
- **Grafana**: Visualisation des métriques
- **Bash**: Scripts d'initialisation

## 📦 Pré-requis
- Docker (version 20.10+)
- Docker Compose (version 2.0+)
- curl (pour tester les API)

## 🚀 Étapes de réalisation

### 1. Initialisation
```bash
cd projects/2026-07-19_docker-compose-app
docker compose up -d
```

### 2. Vérifier le statut des services
```bash
docker compose ps
docker compose logs -f
```

### 3. Tester l'API backend
```bash
curl http://localhost:3000/health
curl http://localhost:3000/api/users
```

### 4. Accéder à l'interface web
```
Frontend: http://localhost:80
Grafana: http://localhost:3001 (admin/admin)
```

### 5. Arrêter l'application
```bash
docker compose down
```

## 📚 Ce qu'on apprend

### Concepts Docker Compose
- Orchestration de services multiples dans un fichier YAML
- Gestion des dépendances entre conteneurs
- Configuration des réseaux (réseau bridge personnalisé)
- Utilisation des volumes (bind mount et named volumes)

### Health Checks
- Implémentation de health checks HTTP et TCP
- Configuration des paramètres (interval, timeout, retries)
- Gestion du cycle de vie des conteneurs basée sur la santé

### Gestion des données
- Persistance PostgreSQL avec volumes nommés
- Initialisation de la base de données
- Scripts SQL d'amorçage

### Monitoring
- Configuration de Prometheus pour scraper les métriques
- Création de dashboards Grafana
- Exposition des métriques avec des endpoints spécialisés

### Variables d'environnement
- Fichier .env pour la configuration par environnement
- Substitution des variables dans docker-compose.yml
- Sécurité: passwords et tokens en variables

## 🔍 Structure des fichiers

```
2026-07-19_docker-compose-app/
├── docker-compose.yml          # Orchestration complète
├── .env                         # Variables d'environnement
├── .env.example                 # Template des variables
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js               # API Express avec health checks
│   └── healthcheck.js          # Script de health check
├── frontend/
│   ├── Dockerfile
│   ├── index.html              # Page statique
│   └── nginx.conf              # Configuration Nginx
├── database/
│   └── init.sql                # Script d'initialisation PostgreSQL
├── monitoring/
│   ├── prometheus.yml          # Configuration Prometheus
│   └── grafana-dashboard.json  # Dashboard Grafana
└── README.md
```

## 💡 Points clés

### 1. Health Checks
Chaque service a un health check pour vérifier son bon fonctionnement:
- **PostgreSQL**: TCP check sur le port 5432
- **Redis**: TCP check sur le port 6379
- **Backend**: HTTP check sur /health
- **Nginx**: HTTP check sur /health

### 2. Dépendances
`depends_on` avec `condition: service_healthy` garantit l'ordre de démarrage basé sur la santé.

### 3. Réseau personnalisé
Tous les services sur un réseau `devops-network` pour la communication par DNS.

### 4. Volumes
- PostgreSQL: volume nommé `postgres-data`
- Redis: volume nommé `redis-data`
- Backend: bind mount pour le développement

### 5. Monitoring
Prometheus scrape:
- Les métriques du backend (port 9090)
- Les métriques PostgreSQL (via exporter)
- Grafana visualise le tout

## 🔧 Configuration avancée

### Ajouter un nouveau service
1. Ajouter une entrée dans `docker-compose.yml`
2. Configurer les health checks
3. Ajouter à `depends_on` si nécessaire
4. Redémarrer: `docker compose up -d`

### Debugging
```bash
# Voir les logs d'un service
docker compose logs backend

# Exécuter une commande dans un conteneur
docker compose exec backend ps aux

# Vérifier les variables d'environnement
docker compose config
```

## ✨ Extensions possibles
- Ajouter un service de cache avec Memcached
- Implémenter des liveness probes plus avancées
- Configurer le log aggregation (ELK stack)
- Ajouter des tests d'intégration
- Configurer des alertes Prometheus/Grafana
- Implémenter un CI/CD avec le projet

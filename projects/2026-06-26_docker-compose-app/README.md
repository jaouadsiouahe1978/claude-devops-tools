# Docker Compose Multi-Stack Application

## 📋 Description

Projet complet de mise en place d'une architecture multi-conteneurs avec **Docker Compose** :
- **Application web** (Node.js/Express)
- **Base de données PostgreSQL** avec persistance de volumes
- **Cache Redis** pour les sessions
- **nginx** reverse proxy
- **Volume Docker** pour persistence des données
- **Network custom** entre conteneurs

**Objectif** : Déployer une application complète en une seule commande (`docker-compose up`) avec tous les services interconnectés.

## 🎯 Ce qu'on apprend

✅ Créer un `docker-compose.yml` multi-services  
✅ Gérer les volumes et la persistence des données  
✅ Configurer les networks Docker  
✅ Utiliser les variables d'environnement  
✅ Mapper les ports entre conteneurs et l'hôte  
✅ Gérer les dépendances entre services (depends_on)  
✅ Écrire des Dockerfile optimisés  
✅ Orchestrer plusieurs conteneurs localement  

## 📦 Pré-requis

- Docker (v20.10+)
- Docker Compose (v2.0+)
- Git
- Terminal Bash/Zsh

## 🚀 Étapes de réalisation

### 1. Structure du projet
```
.
├── README.md
├── docker-compose.yml
├── app/
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   └── index.js
├── nginx/
│   ├── Dockerfile
│   └── nginx.conf
├── init-db/
│   └── init.sql
└── .env
```

### 2. Construire et lancer
```bash
docker-compose build
docker-compose up -d
docker-compose logs -f
```

### 3. Tester l'application
```bash
curl http://localhost:80/
curl http://localhost:80/api/status
curl http://localhost:3000/api/users
```

### 4. Arrêter tout
```bash
docker-compose down
docker-compose down -v  # Avec suppression des volumes
```

## 📚 Architecture

```
┌─────────────────────────────────────────┐
│          Docker Compose Network         │
├─────────────────────────────────────────┤
│  nginx (port 80)                        │
│    ↓                                    │
│  Node.js App (port 3000)                │
│    ├→ PostgreSQL (port 5432)            │
│    └→ Redis (port 6379)                 │
└─────────────────────────────────────────┘

Volumes:
- pg_data: Persistence PostgreSQL
- redis_data: Persistence Redis
```

## 🔧 Fichiers clés

- **docker-compose.yml** : Orchestration des services
- **app/Dockerfile** : Image Node.js légère avec multi-stage build
- **nginx/nginx.conf** : Configuration du reverse proxy
- **init-db/init.sql** : Initialisation de la base de données
- **.env** : Variables d'environnement (exemple)

## 🎓 Concepts DevOps couverts

- **Containerization** : Chaque service dans son conteneur
- **Orchestration locale** : Docker Compose pour orchestrer
- **Networking** : Communication entre conteneurs
- **Storage** : Volumes et persistence
- **Infrastructure as Code** : Configuration declarative
- **Environment Management** : .env et variables

## 💡 À améliorer ensuite

- Ajouter des health checks
- Configurer un backup PostgreSQL automatique
- Ajouter des logs centralisés (ELK/Splunk)
- Déployer sur Kubernetes
- Ajouter des tests dans le pipeline
- Mise en place du monitoring Prometheus

## 📖 Ressources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Best Practices Dockerfile](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Networking](https://docs.docker.com/network/)

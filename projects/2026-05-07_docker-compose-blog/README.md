# 🚀 Blog Platform Multi-Conteneurs avec Docker Compose

## 📋 Description
Projet complet d'une plateforme de blog avec architecture microservices utilisant **Docker & Docker Compose**. L'application contient :
- **Backend Node.js/Express** : API REST pour la gestion des articles
- **MongoDB** : Base de données NoSQL pour les articles
- **Redis** : Cache in-memory pour les performances
- **Nginx** : Reverse proxy et serveur web

## 🎯 Objectifs d'apprentissage
✅ Créer des images Docker custom avec Dockerfile  
✅ Orchestrer plusieurs conteneurs avec Docker Compose  
✅ Configurer la mise en réseau entre conteneurs  
✅ Gérer les volumes pour la persistance des données  
✅ Utiliser les variables d'environnement  
✅ Implémenter des health checks  
✅ Exposer les services via Nginx  

## 📚 Pré-requis
- Docker installé (v20+)
- Docker Compose installé (v2+)
- Git
- Curl (pour tester les endpoints)

## 🛠️ Technologies utilisées
- **Docker** : Containerization
- **Docker Compose** : Orchestration
- **Node.js** : Runtime applicatif
- **Express** : Framework web
- **MongoDB** : Base de données
- **Redis** : Cache distribuée
- **Nginx** : Reverse proxy

## 📁 Structure du projet
```
2026-05-07_docker-compose-blog/
├── README.md                    # Cette documentation
├── docker-compose.yml           # Configuration Docker Compose
├── Dockerfile                   # Image custom Node.js
├── app/
│   ├── package.json            # Dépendances Node.js
│   ├── index.js                # Application Express
│   └── .env.example            # Variables d'environnement
├── nginx/
│   └── nginx.conf              # Configuration du reverse proxy
└── data/                        # Volume pour MongoDB (créé au runtime)
```

## 🚀 Étapes de démarrage

### 1. Cloner et accéder au projet
```bash
cd projects/2026-05-07_docker-compose-blog
```

### 2. Configurer les variables d'environnement
```bash
cp app/.env.example app/.env
```

### 3. Démarrer tous les conteneurs
```bash
docker-compose up -d
```

Cela va :
- Builder l'image Docker de l'app Node.js
- Télécharger les images MongoDB et Redis
- Lancer 5 conteneurs (app, MongoDB, Redis, Nginx, visualizer)
- Créer un réseau partagé entre eux
- Monter les volumes

### 4. Vérifier le statut
```bash
docker-compose ps
docker-compose logs app
```

### 5. Tester les endpoints
```bash
# Créer un article
curl -X POST http://localhost/api/posts \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Mon premier article",
    "content": "Contenu du blog",
    "author": "Jaouad"
  }'

# Lister tous les articles
curl http://localhost/api/posts

# Obtenir un article spécifique
curl http://localhost/api/posts/<id>
```

### 6. Accéder à l'interface web
- **Blog UI** : http://localhost:3000
- **Nginx status** : http://localhost:8080/nginx_status
- **Conteneurs visualisation** : http://localhost:8081

## 🔍 Exploration des services

### Accéder à MongoDB
```bash
docker-compose exec mongodb mongosh
# Dans le shell:
> use blog_db
> db.posts.find()
```

### Accéder à Redis
```bash
docker-compose exec redis redis-cli
# Dans le shell:
> KEYS *
> GET cached_key
```

### Voir les logs
```bash
docker-compose logs -f app          # Logs de l'app
docker-compose logs -f mongodb      # Logs de MongoDB
docker-compose logs -f redis        # Logs de Redis
```

## 🛑 Arrêter et nettoyer
```bash
# Arrêter les conteneurs (les données persistent)
docker-compose stop

# Arrêter et supprimer les conteneurs
docker-compose down

# Arrêter et supprimer conteneurs + volumes
docker-compose down -v
```

## 📊 Ce que vous apprenez
1. **Dockerfiles** : Comment créer une image custom
2. **Docker Compose** : Orchestration déclarative
3. **Networking** : Communication entre conteneurs
4. **Volumes** : Persistance des données
5. **Environment variables** : Configuration externe
6. **Health checks** : Surveillance de la santé des services
7. **Reverse proxy** : Exposition sécurisée des services
8. **Microservices** : Architecture distribuée

## 💡 Améliorations futures
- Ajouter PostgreSQL à la place de MongoDB
- Implémenter l'authentification avec JWT
- Ajouter Prometheus + Grafana pour le monitoring
- Configurer des secrets avec Docker Secrets
- Ajouter une CI/CD avec GitHub Actions
- Déployer sur Kubernetes

## 📌 Notes importantes
- **Port 80 (Nginx)** : Accessible à http://localhost
- **Port 3000 (App directe)** : Accessible à http://localhost:3000
- **Port 8080 (Nginx stats)** : http://localhost:8080/nginx_status
- **Port 27017 (MongoDB)** : Accessible en interne uniquement
- **Port 6379 (Redis)** : Accessible en interne uniquement
- **Port 8081 (Visualizer)** : http://localhost:8081

## 🔗 Ressources complémentaires
- [Documentation Docker](https://docs.docker.com/)
- [Documentation Docker Compose](https://docs.docker.com/compose/)
- [Express.js Guide](https://expressjs.com/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Redis Documentation](https://redis.io/documentation)

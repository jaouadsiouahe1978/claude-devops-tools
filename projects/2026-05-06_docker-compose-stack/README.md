# Docker Compose Multi-Container Stack

## 📋 Description
Application web complète orchestrée avec Docker Compose, composée d'une API Node.js, d'une base de données PostgreSQL et d'un reverse proxy Nginx.

## 🎯 Objectif
Apprendre à :
- Créer des images Docker personnalisées (Dockerfile)
- Orchestrer plusieurs conteneurs avec Docker Compose
- Configurer un reverse proxy Nginx
- Gérer les variables d'environnement et les volumes
- Mettre en place la communication inter-conteneurs

## 🛠 Technos utilisées
- **Docker** : containerisation
- **Docker Compose** : orchestration multi-conteneurs
- **Node.js** : API backend
- **PostgreSQL** : base de données relationnelle
- **Nginx** : reverse proxy et load balancer

## 📚 Pré-requis
- Docker et Docker Compose installés
- Git
- Connaissances basiques en Docker et Node.js

## 🚀 Étapes de réalisation

### Étape 1 : Cloner et explorer le projet
```bash
cd projects/2026-05-06_docker-compose-stack
ls -la
```

### Étape 2 : Configurer les variables d'environnement
```bash
cp .env.example .env
# Optionnel : modifier .env selon vos besoins
```

### Étape 3 : Builder et démarrer les conteneurs
```bash
docker-compose up -d
```

### Étape 4 : Tester les services
```bash
# Vérifier les logs
docker-compose logs -f

# Tester l'API via le reverse proxy
curl http://localhost/api/status

# Tester la connexion à la base de données
docker-compose exec api npm run test-db
```

### Étape 5 : Arrêter les services
```bash
docker-compose down
docker-compose down -v  # Avec suppression des volumes
```

## 📖 Ce qu'on apprend

### Fichier docker-compose.yml
- Définition de services (api, postgres, nginx)
- Variables d'environnement
- Volumes persistants pour les données PostgreSQL
- Networks entre conteneurs
- Dépendances de services

### Dockerfiles
- **api/Dockerfile** : Image Node.js multi-stage
- **nginx/Dockerfile** : Image Nginx personnalisée

### Architecture
```
┌─────────────────┐
│   Client        │
│   (localhost)   │
└────────┬────────┘
         │ HTTP
    ┌────▼────┐
    │  Nginx  │ (port 80)
    │ Reverse │
    │  Proxy  │
    └────┬────┘
         │
    ┌────▼────────┐
    │    API      │ (port 3000 interne)
    │   Node.js   │
    └────┬────────┘
         │
    ┌────▼──────────┐
    │  PostgreSQL   │ (port 5432 interne)
    │     DB        │
    └───────────────┘
```

## 💡 Points clés
- **Isolation** : Chaque service tourne dans son conteneur
- **Communication** : Via le network Docker et noms de services
- **Persistance** : Volume nommé pour la BDD
- **Reverse proxy** : Nginx expose l'API sur le port 80
- **Environnement** : Variables gérées via .env

## 🔧 Commandes utiles
```bash
# Logs en temps réel
docker-compose logs -f api

# Entrer dans un conteneur
docker-compose exec api sh

# Exécuter une commande
docker-compose exec api npm list

# Voir les ressources
docker ps
docker volume ls
docker network ls
```

## 📝 Notes
- Les données PostgreSQL sont persistantes grâce au volume
- Modifier le code Node.js ne recrée pas l'image (volume bind)
- Supprimer les conteneurs avec `docker-compose down` ne supprime pas les volumes
- Utiliser `docker-compose down -v` pour nettoyer complètement

## 🎓 Ressources complémentaires
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Node.js Official Image](https://hub.docker.com/_/node)
- [PostgreSQL Official Image](https://hub.docker.com/_/postgres)
- [Nginx Official Image](https://hub.docker.com/_/nginx)

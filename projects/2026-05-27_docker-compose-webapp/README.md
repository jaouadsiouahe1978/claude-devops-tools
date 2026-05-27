# 🐳 Docker Compose - Stack Web Complète

## Objectif du jour
Construire une **application web multi-conteneurs** avec Node.js, PostgreSQL et Nginx. Apprendre la composition de services Docker et les meilleures pratiques de networking en Docker.

## 📋 Description
Un stack complet comportant :
- **Frontend/API Node.js** : Service applicatif avec Express
- **PostgreSQL** : Base de données persistante
- **Redis** : Cache et session store
- **Nginx** : Reverse proxy et load balancer
- **PgAdmin** : Interface d'administration de la base

## 🛠️ Technos utilisées
- **Docker & Docker Compose** - Orchestration légère
- **Node.js/Express** - Framework web
- **PostgreSQL** - SGBDR
- **Redis** - Cache en mémoire
- **Nginx** - Reverse proxy
- **Environment variables** - Configuration multi-environnements

## 📚 Ce qu'on apprend
✅ Créer et composer plusieurs conteneurs Docker
✅ Configurer le networking entre services
✅ Gérer les volumes (données persistantes)
✅ Variables d'environnement et secrets
✅ Health checks et dépendances entre services
✅ Logs agrégés avec `docker-compose logs`
✅ Debugging dans un environnement multi-conteneurs

## 🚀 Pré-requis
- Docker et Docker Compose (v2+)
- Git
- Optionnel : curl, psql pour tester

## 📖 Étapes de réalisation

### 1️⃣ Cloner et accéder au projet
```bash
cd projects/2026-05-27_docker-compose-webapp
```

### 2️⃣ Démarrer le stack complet
```bash
docker-compose up -d
```

### 3️⃣ Vérifier les services
```bash
docker-compose ps
docker-compose logs -f app
```

### 4️⃣ Tester l'application
```bash
# API health check
curl http://localhost/api/health

# Application web
open http://localhost

# PgAdmin (admin@example.com / admin)
open http://localhost:5050
```

### 5️⃣ Interagir avec la base de données
```bash
# Accéder au CLI PostgreSQL
docker-compose exec db psql -U postgres -d myapp

# Exemple de requête
SELECT * FROM users;
```

### 6️⃣ Arrêter tout
```bash
docker-compose down
```

### 7️⃣ Pour persister les données (optionnel)
```bash
docker-compose down -v  # Supprimer aussi les volumes
```

## 📊 Architecture
```
┌─────────────────────────────────────────────────┐
│          Docker Compose Network (webapp)        │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────┐      ┌──────────────┐       │
│  │    Nginx     │      │   PgAdmin    │       │
│  │ :80, :443    │      │    :5050     │       │
│  └──────┬───────┘      └──────┬───────┘       │
│         │                     │               │
│         ▼                     ▼               │
│  ┌──────────────┐      ┌──────────────┐       │
│  │  Node.js App │◄────►│ PostgreSQL   │       │
│  │   :3000      │      │    :5432     │       │
│  └──────┬───────┘      └──────────────┘       │
│         │                                     │
│         ▼                                     │
│  ┌──────────────┐                            │
│  │    Redis     │◄───────────────────────────┤
│  │   :6379      │                            │
│  └──────────────┘                            │
│                                              │
└─────────────────────────────────────────────────┘
```

## 🔍 Fichiers clés
- **docker-compose.yml** - Configuration principale
- **app/Dockerfile** - Image Node.js custom
- **nginx/nginx.conf** - Configuration reverse proxy
- **db/init.sql** - Initialisation base de données
- **.env** - Variables d'environnement

## 💡 Cas d'usage réels
- **Développement local** isolé et reproductible
- **CI/CD pipelines** (tests en conteneurs)
- **Microservices locaux** avant déploiement cloud
- **Demo et partage** (même env garantie)
- **Onboarding** devs (cloner + `docker-compose up`)

## 🐛 Troubleshooting

### Services n'arrivent pas à se connecter
```bash
docker-compose down
docker-compose up -d --force-recreate
```

### Port déjà utilisé
```bash
# Modifier dans docker-compose.yml ou utiliser
PORT=8080 docker-compose up
```

### Voir les logs
```bash
docker-compose logs -f [service_name]
# Ex: docker-compose logs -f app
```

### Accéder à un conteneur
```bash
docker-compose exec [service] bash
# Ex: docker-compose exec app bash
```

## 📚 Ressources
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Networking in Docker Compose](https://docs.docker.com/compose/networking/)
- [Best practices](https://docs.docker.com/develop/dev-best-practices/)

---
**Date** : 2026-05-27  
**Durée estimée** : 2-3 heures  
**Niveau** : Débutant → Intermédiaire

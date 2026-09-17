# Multi-Container Docker App with Docker Compose

## 📋 Description

Ce projet vous enseigne comment construire et orchestrer une application multi-conteneur complète avec Docker Compose. Vous allez créer une application web avec :
- **Frontend** : Nginx (serveur web + reverse proxy)
- **Backend** : Node.js/Express API REST
- **Database** : PostgreSQL pour la persistence de données

L'objectif est d'apprendre comment Docker Compose facilite la gestion de plusieurs services interdépendants en une seule commande.

## 🎯 Objectifs d'apprentissage

Après ce projet, vous saurez :
- Créer un Dockerfile optimisé pour une application Node.js
- Configurer Nginx comme reverse proxy
- Composer plusieurs conteneurs avec docker-compose.yml
- Gérer les volumes et les réseaux Docker
- Implémenter les variables d'environnement
- Orchestrer le démarrage et l'arrêt d'applications multi-conteneurs

## 📦 Prérequis

- Docker installé (version 20.10+)
- Docker Compose installé (version 2.0+)
- Connaissances basiques de Docker

## 🚀 Étapes de réalisation

### 1. Démarrer l'application

```bash
# Se placer dans le répertoire du projet
cd projects/2026-09-17_docker-multi-container-app

# Construire et démarrer les conteneurs
docker-compose up -d

# Vérifier que tous les services sont actifs
docker-compose ps
```

### 2. Accéder à l'application

```bash
# Frontend (Nginx)
curl http://localhost

# API Backend
curl http://localhost:8080/api/items
```

### 3. Inspecter les logs

```bash
# Tous les logs
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f backend
docker-compose logs -f db
```

### 4. Accéder à la base de données

```bash
# Se connecter au conteneur PostgreSQL
docker-compose exec db psql -U devops -d app_db

# Vérifier les tables
\dt
```

### 5. Arrêter l'application

```bash
# Arrêter tous les conteneurs
docker-compose down

# Arrêter et supprimer les volumes (réinitialiser la DB)
docker-compose down -v
```

## 📁 Structure du projet

```
.
├── docker-compose.yml       # Orchestration des services
├── backend/
│   ├── Dockerfile          # Construction de l'image Node.js
│   ├── package.json        # Dépendances Node.js
│   ├── app.js              # Application Express
│   └── init.sql            # Script d'initialisation DB
├── nginx/
│   ├── Dockerfile          # Construction de l'image Nginx
│   └── nginx.conf          # Configuration reverse proxy
└── README.md               # Ce fichier
```

## 🔧 Concepts clés

### Docker Compose
- Définit l'ensemble de l'infrastructure dans un fichier YAML
- Crée un réseau automatique entre les conteneurs
- Gère les volumes pour la persistence des données
- Expose les ports de façon orchestrée

### Variables d'environnement
- Configurent les connexions entre services
- Facilite les déploiements dans différents environnements
- Évite de hardcoder les valeurs sensibles

### Volumes Docker
- `db_data` : persiste les données PostgreSQL
- `./backend` : lie le code source en développement

### Réseaux Docker
- Les services communiquent par le nom du service (ex: `db:5432`)
- Isolation automatique des ports externes

## 🎓 Points d'apprentissage supplémentaires

- **Optimisation des images** : Utiliser des images de base légères (`alpine`)
- **Health checks** : Ajouter des vérifications de santé des services
- **Secrets** : Utiliser `.env` et `.env.local` pour les données sensibles
- **Scaling** : Dupliquer des services avec `docker-compose up --scale backend=3`
- **Override** : Utiliser `docker-compose.override.yml` pour le développement

## 📊 Commandes utiles

```bash
# Construire uniquement
docker-compose build

# Afficher la configuration fusionnée
docker-compose config

# Exécuter une commande dans un conteneur
docker-compose exec backend npm list

# Voir l'utilisation des ressources
docker stats

# Réinitialiser complètement
docker-compose down -v --remove-orphans
```

## 🐛 Dépannage

**Les conteneurs ne démarrent pas**
```bash
docker-compose logs
```

**Erreur de connexion à la DB**
- Vérifier que le service `db` est en cours d'exécution
- Attendre quelques secondes (la DB met du temps à initialiser)

**Le port 80 est déjà utilisé**
- Modifier le port dans `docker-compose.yml` : `"8080:80"`
- Ou arrêter l'autre service : `sudo lsof -i :80`

## ✅ Validation du projet

```bash
# Vérifier que tous les services répondent
docker-compose ps  # Tous doivent être "Up"

# Tester l'API
curl -s http://localhost:8080/api/items | jq .

# Vérifier les logs - ne doit avoir aucune erreur
docker-compose logs
```

## 🎯 Prochaines étapes

1. Ajouter plus de routes à l'API
2. Implémenter l'authentification
3. Ajouter Redis pour le cache
4. Créer un fichier `.env.production` pour les déploiements
5. Utiliser Kubernetes pour orchestrer à grande échelle

---

**Durée estimée** : 1 journée  
**Niveau** : Débutant à Intermédiaire  
**Technos** : Docker, Docker Compose, Node.js, PostgreSQL, Nginx

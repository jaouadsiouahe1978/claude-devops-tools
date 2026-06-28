# Docker Compose : Stack Multi-Conteneur - Application Web Complète

## 📋 Description

Ce projet te montre comment orchestrer une application web complète avec **Docker Compose**. Tu vas créer un stack avec :
- **Nginx** : reverse proxy / serveur web
- **Python Flask** : API backend
- **PostgreSQL** : base de données
- **Redis** : cache
- **Adminer** : interface d'administration DB

**Objectif** : Démarrer 5 conteneurs interconnectés avec une seule commande (`docker-compose up`) et comprendre le networking et le persistence dans Docker.

---

## 🎯 Ce qu'on apprend

- ✅ Structure d'un `docker-compose.yml` : services, networks, volumes
- ✅ Variables d'environnement et `.env`
- ✅ Networking inter-conteneurs (DNS, communication)
- ✅ Volumes persistants pour les données
- ✅ Health checks et dépendances entre services
- ✅ Logs et debugging multi-conteneurs
- ✅ Déploiement local d'une vraie app microservices

---

## 📦 Pré-requis

- Docker & Docker Compose installés (`docker --version`, `docker-compose --version`)
- ~5 min pour le premier `up` (téléchargement des images)
- Les ports 80, 5000, 5432, 6379 libres sur ta machine

---

## 🚀 Étapes de réalisation

### 1. Clone / Ouvre ce dossier
```bash
cd projects/2026-06-28_docker-compose-stack
```

### 2. Démarre le stack complet
```bash
docker-compose up -d
```

Cette commande :
- Crée un réseau Docker dédié
- Lance tous les 5 conteneurs
- Les rend accessibles entre eux par DNS (ex: `flask:5000` depuis Nginx)

### 3. Vérifie que tout fonctionne
```bash
docker-compose ps
docker-compose logs -f  # Regarde les logs en temps réel
```

### 4. Test l'application

**Backend Flask** (disponible via Nginx) :
```bash
curl http://localhost/api/health
curl http://localhost/api/tasks  # Liste les tasks en DB
curl -X POST http://localhost/api/tasks -H "Content-Type: application/json" \
  -d '{"title":"Ma tâche","description":"Test de POST"}'
```

**Adminer** (interface DB) :
- Ouvre http://localhost:8080
- Système: `PostgreSQL`
- Serveur: `postgres` (le nom du service Docker)
- Identifiant: `devops`
- Mot de passe: `devops123`

**Redis** (cache) :
```bash
docker-compose exec redis redis-cli
> PING
> SET test "hello"
> GET test
```

### 5. Arrête le stack
```bash
docker-compose down
```

Pour nettoyer aussi les volumes (données) :
```bash
docker-compose down -v
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│       Docker Compose Network            │
├──────────────┬──────────────────────────┤
│   Nginx      │ Port 80 (reverse proxy)  │
│   :80        │ → Route vers Flask       │
└───────┬──────┘                          │
        │                                  │
        ├──→ Flask Backend                │
        │    :5000                        │
        │    (Python + PostgreSQL)        │
        │                                  │
        ├──→ PostgreSQL                   │
        │    :5432                        │
        │    (Data persistence)           │
        │                                  │
        ├──→ Redis                        │
        │    :6379                        │
        │    (Cache)                      │
        │                                  │
        └──→ Adminer                      │
             :8080                        │
             (Admin DB UI)                │
└─────────────────────────────────────────┘
```

---

## 📝 Fichiers clés

- **docker-compose.yml** : Déclaration de tous les services
- **.env** : Variables d'environnement (DB credentials, etc.)
- **app/app.py** : API Flask simple
- **app/requirements.txt** : Dépendances Python
- **nginx.conf** : Configuration du reverse proxy
- **init.sql** : Script d'initialisation de la DB

---

## 🔧 Commandes utiles

```bash
# Démarrer en foreground (voir les logs)
docker-compose up

# Démarrer en background
docker-compose up -d

# Afficher l'état des conteneurs
docker-compose ps

# Voir les logs d'un service spécifique
docker-compose logs -f flask
docker-compose logs -f postgres

# Exécuter une commande dans un conteneur
docker-compose exec flask bash
docker-compose exec postgres psql -U devops -d tasks_db

# Reconstruire les images (après changement du code)
docker-compose build

# Arrêter sans supprimer les volumes
docker-compose stop

# Supprimer le stack
docker-compose down

# Supprimer le stack et les données
docker-compose down -v
```

---

## 💾 Persistence des données

- **PostgreSQL** : Les données sont stockées dans le volume `postgres_data`
- **Redis** : Les données en cache disparaissent au redémarrage (mode volatile par défaut)
- Les volumes persistent même après `docker-compose down` (sauf avec `-v`)

---

## 📚 Pour aller plus loin

- Ajoute des health checks custom dans chaque service
- Implémenter un load balancing avec plusieurs instances Flask
- Ajouter des variables d'environnement pour chaque environnement (dev, prod, test)
- Intégrer un monitoring avec Prometheus + Grafana
- Déployer sur une vraie plateforme (Docker Swarm, Kubernetes)

---

## 🐛 Troubleshooting

**"Error: Port already in use"**
```bash
# Change les ports dans docker-compose.yml ou sur ta machine
sudo lsof -i :80  # Voir quel process écoute le port 80
```

**"Connection refused" depuis Nginx vers Flask**
- Vérifie que Flask utilise `0.0.0.0:5000` (pas `127.0.0.1`)
- Les conteneurs ne peuvent pas se connecter via `localhost` entre eux → utilise le nom du service

**Logs vides ou cryptiques**
```bash
docker-compose logs -f --tail=50  # Dernières 50 lignes
docker-compose logs flask --timestamps
```

---

## ✍️ Notes DevOps

1. **Networking** : Docker Compose crée un réseau bridge où chaque service est DNS-queryable
2. **Environment Variables** : Chaque conteneur charge les vars du fichier `.env`
3. **Build vs Image** : Si tu as un Dockerfile, utilise `build:`, sinon `image:`
4. **Init Scripts** : Utilisé pour pré-remplir la DB au premier démarrage
5. **Resource Limits** : À ajouter en prod pour éviter que un conteneur consomme tout le CPU/RAM

---

**Créé** : 2026-06-28  
**Niveau** : Débutant → Intermédiaire  
**Durée** : ~1-2h  
**Technos** : Docker, Compose, Nginx, Flask, PostgreSQL, Redis

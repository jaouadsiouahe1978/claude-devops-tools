# Docker Compose - Application Web Multi-Tier

## 📋 Description

Déployer une application web full-stack avec **Docker Compose** : une application Flask (Python), une base de données PostgreSQL, et un reverse proxy Nginx. Le tout orchestré en une seule commande.

Ce projet apprend les concepts fondamentaux :
- 🐳 **Docker** : images, conteneurs, volumes
- 🔗 **Docker Compose** : orchestration multi-conteneurs
- 🌐 **Networking** : communication entre services
- 💾 **Volumes & Persistence** : données persistantes
- 🔧 **Environment variables** : configuration par conteneur
- ⚙️ **Reverse proxy** : Nginx en frontal
- 🗄️ **Databases** : PostgreSQL intégré et initialisé

## 🎯 Objectif

Déployer une stack complète en 5 minutes :
```bash
docker-compose up -d
```

L'app sera accessible via `http://localhost` (port 80).

## 📦 Pré-requis

- Docker & Docker Compose installés
- 2-3 minutes d'attente pour le premier démarrage (téléchargement images)

## 🚀 Architecture

```
┌─────────────────────────────────────────┐
│ Nginx Reverse Proxy (Port 80)           │
├─────────────────────────────────────────┤
│ Flask Web App (Port 5000, interne)      │
├─────────────────────────────────────────┤
│ PostgreSQL Database (Port 5432, interne)│
└─────────────────────────────────────────┘
```

Tous les services communiquent par le réseau Docker via leurs noms (`app`, `db`).

## 📝 Étapes de réalisation

### 1️⃣ Cloner et configurer
```bash
cd projects/2026-10-04_docker-multitier-app
cp .env.example .env
```

### 2️⃣ Lancer la stack
```bash
docker-compose up -d
```

### 3️⃣ Vérifier les conteneurs
```bash
docker-compose ps
# Tous les services doivent être "Up"
```

### 4️⃣ Tester l'application
```bash
# Via curl
curl http://localhost

# Via navigateur
open http://localhost  # macOS
xdg-open http://localhost  # Linux
```

### 5️⃣ Voir les logs
```bash
docker-compose logs -f app      # Logs de l'app
docker-compose logs -f db       # Logs de la base
docker-compose logs -f nginx    # Logs du reverse proxy
```

### 6️⃣ Accéder à PostgreSQL (optionnel)
```bash
docker-compose exec db psql -U postgres -d myapp -c "SELECT * FROM users;"
```

### 7️⃣ Arrêter la stack
```bash
docker-compose down
# Ajouter -v pour supprimer aussi les volumes (données)
docker-compose down -v
```

## 📚 Concepts appris

| Concept | Explication |
|---------|------------|
| **Services** | Chaque conteneur est un service (app, db, nginx) |
| **Networking** | Docker crée un réseau bridge pour communication intra-stack |
| **Volumes** | Les données PostgreSQL persistent sur l'hôte (`./postgres_data/`) |
| **Ports** | Seul Nginx expose le port 80 à l'hôte |
| **Environment** | Variables injectées dans chaque conteneur (.env) |
| **Build** | L'app Flask est buildée depuis le Dockerfile local |
| **Init scripts** | PostgreSQL exécute `init.sql` au démarrage |

## 🔍 Points clés du docker-compose.yml

```yaml
version: '3.8'
services:
  nginx:
    # Service reverse proxy
    ports: ['80:80']  # Seul lui expose un port
    depends_on: [app]  # Démarre après l'app
  
  app:
    # Service Flask
    build: .  # Construit depuis Dockerfile local
    environment:  # Variables d'env injectées
      - DATABASE_URL=postgres://...
    depends_on: [db]  # Attend la base
  
  db:
    # Service PostgreSQL
    environment:  # Identifiants et DB
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=myapp
    volumes:
      - ./postgres_data:/var/lib/postgresql/data  # Données persistantes
      - ./postgres/init.sql:/docker-entrypoint-initdb.d/init.sql
```

## 🛠️ Personnalisation

### Changer le port
Éditer `docker-compose.yml` :
```yaml
nginx:
  ports: ['8080:80']  # Accessible sur :8080
```

### Ajouter une variable d'env
Éditer `.env` et le service dans `docker-compose.yml`.

### Modifier la base de données
Éditer `postgres/init.sql` et relancer :
```bash
docker-compose down -v
docker-compose up -d
```

## 🐛 Dépannage

| Problème | Solution |
|----------|----------|
| "Port 80 déjà utilisé" | `docker ps` pour voir qui l'utilise, ou changer le port dans compose |
| App crash avec "Cannot connect to db" | Vérifier que le service `db` est up : `docker-compose ps` |
| Données perdues après down | À faire : `docker-compose down` supprime les volumes par défaut |
| "Disk space" | `docker system prune` pour nettoyer images/conteneurs inutilisés |

## ✅ Checklist d'apprentissage

- [ ] Définir un service Docker Compose
- [ ] Configurer des volumes pour la persistance
- [ ] Utiliser des variables d'environnement
- [ ] Connecter plusieurs services
- [ ] Configurer un reverse proxy (Nginx)
- [ ] Consulter les logs d'un conteneur
- [ ] Exécuter une commande dans un conteneur live
- [ ] Initialiser une base de données au démarrage

## 📖 Ressources

- [Docker Compose Official Docs](https://docs.docker.com/compose/)
- [Docker Networking](https://docs.docker.com/network/)
- [Nginx Reverse Proxy](https://nginx.org/en/docs/beginners_guide.html)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)

---

**Créé le 2026-10-04** | DevOps Training Grenoble

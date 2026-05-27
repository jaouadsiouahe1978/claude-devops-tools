# 🎓 Guide d'apprentissage - Docker Compose Stack

## 📚 Concepts clés à maîtriser

### 1. **Services Docker Compose**
Docker Compose permet de définir et exécuter plusieurs conteneurs comme une application unique.

```yaml
services:
  app:
    image: node:18-alpine
    ports:
      - "3000:3000"
```

**À apprendre :**
- Différence entre `image` et `build`
- Mapping des ports : `"HOST:CONTAINER"`
- Variables d'environnement (`environment`)
- Volumes (`volumes`) pour la persistence et le hot-reload

### 2. **Networking**
Par défaut, Docker Compose crée un réseau bridge pour tous les services.

```yaml
networks:
  webapp:
    driver: bridge
```

**Points importants :**
- Le hostname = le nom du service
- Exemple : `db` → accessible via `postgres://db:5432`
- Ne pas utiliser `localhost` entre conteneurs, utiliser le nom du service

### 3. **Volumes - Persistence des données**
Trois types de volumes :

```yaml
# Named volume (réutilisable, géré par Docker)
volumes:
  postgres_data:
    driver: local

# Bind mount (dossier local)
volumes:
  - ./app/src:/app/src

# Tmpfs (en mémoire)
tmpfs: /tmp
```

**Use cases :**
- **Named volumes** : données de base de données
- **Bind mounts** : développement (hot-reload)
- **tmpfs** : caches temporaires

### 4. **Health Checks**
Vérifier la santé d'un service avant que les autres ne dépendent de lui.

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
  interval: 10s
  timeout: 5s
  retries: 3
  start_period: 10s
```

**Signification :**
- `interval` : fréquence du test
- `timeout` : durée max du test
- `retries` : combien de fois échouer avant de marquer comme unhealthy
- `start_period` : délai d'attente avant de commencer les tests

### 5. **Dependencies entre services**
```yaml
depends_on:
  db:
    condition: service_healthy
```

**Conditions possibles :**
- `service_started` : conteneur lancé (pas de vérification)
- `service_healthy` : health check réussi
- `service_completed_successfully` : service s'est terminé avec succès

### 6. **Variables d'environnement**
Trois façons de passer des variables :

```yaml
# Directement dans docker-compose.yml
environment:
  NODE_ENV: production

# Via un fichier .env
env_file:
  - .env

# Via substitution
environment:
  DB_USER: ${DB_USER:-default_user}
```

## 🔍 Exploration du stack

### Voir les logs en temps réel
```bash
docker-compose logs -f app        # Application uniquement
docker-compose logs -f db         # Base de données uniquement
docker-compose logs --tail=50 app # Dernières 50 lignes
```

### Exécuter une commande dans un conteneur
```bash
docker-compose exec app npm test
docker-compose exec db psql -U postgres -d myapp
docker-compose exec redis redis-cli
```

### Inspecter un conteneur
```bash
docker-compose ps           # État des services
docker inspect webapp_app   # Informations détaillées
docker top webapp_app       # Processus en cours
```

## 🚨 Troubleshooting courant

### Services n'arrivent pas à communiquer
**Problème :** `Cannot connect to db:5432`

**Solutions :**
1. Vérifier que les services sont sur le même réseau
2. Vérifier les noms d'hôtes (sensibles à la casse)
3. Health checks échoués : `docker-compose logs db`
4. Recréer avec : `docker-compose down && docker-compose up -d`

### Base de données ne s'initialise pas
**Problème :** Pas de tables, données manquantes

**Solutions :**
1. Vérifier que `db/init.sql` existe et est correct
2. Supprimer le volume : `docker volume rm postgres_data`
3. Redémarrer : `docker-compose down -v && docker-compose up -d`

### Port déjà utilisé
**Problème :** `Error: listen EADDRINUSE: address already in use :::3000`

**Solutions :**
```bash
# Option 1 : Trouver et tuer le processus
lsof -i :3000
kill -9 <PID>

# Option 2 : Changer le port dans docker-compose.yml
# "8000:3000" au lieu de "3000:3000"

# Option 3 : Variable d'environnement
PORT=8000 docker-compose up
```

### Hot-reload ne fonctionne pas
**Problème :** Les changements de code ne sont pas appliqués

**Solutions :**
1. Vérifier que le volume est correct : `- ./app/src:/app/src`
2. Vérifier que l'application utilise `nodemon` ou similaire
3. Logs : `docker-compose logs -f app`

## 💡 Bonnes pratiques

### 1. **Toujours utiliser les health checks**
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
  interval: 10s
  timeout: 5s
  retries: 3
```

### 2. **Gérer les secrets avec sécurité**
```bash
# ❌ MAUVAIS
DB_PASSWORD=my_password docker-compose up

# ✅ BON
# Utiliser .env.local (gitignored)
# Ou docker secrets en production
```

### 3. **Ordonnancer les démarrages**
```yaml
depends_on:
  db:
    condition: service_healthy
```

### 4. **Nettoyer régulièrement**
```bash
docker-compose down -v      # Supprimer volumes
docker system prune -a      # Nettoyer tout
```

### 5. **Documenter la configuration**
Garder un `.env.example` pour que les autres sachent quelles variables existent.

## 📊 Architecture de ce projet

```
┌─ Nginx (Reverse Proxy)
│   └─→ Node.js App (API REST)
│       ├─→ PostgreSQL (données persistantes)
│       └─→ Redis (cache)
│
└─ PgAdmin (interface DB)
    └─→ PostgreSQL
```

**Flux de données :**
1. Requête HTTP → Nginx (port 80)
2. Nginx proxy vers Node.js (port 3000)
3. Node.js requête PostgreSQL pour les données
4. Node.js peut récupérer du cache Redis
5. Réponse JSON est mise en cache dans Redis

## 🎯 Exercices pratiques

### Niveau 1 : Exploration
1. Démarrer le stack : `make up`
2. Voir les services : `docker-compose ps`
3. Lire les logs : `docker-compose logs app`
4. Accéder à PgAdmin : http://localhost:5050

### Niveau 2 : Modification
1. Changer le port Node.js de 3000 à 8000
2. Modifier le mot de passe PostgreSQL
3. Ajouter une variable d'environnement personnalisée

### Niveau 3 : Extension
1. Ajouter un service Adminer pour PostgreSQL
2. Configurer des logs structurées (JSON)
3. Implémenter des secrets Docker

### Niveau 4 : Production
1. Configurer HTTPS avec Nginx
2. Limiter les ressources (CPU, mémoire)
3. Mettre en place un load balancer Nginx

## 📖 Ressources pour aller plus loin
- [Docker Compose Official Docs](https://docs.docker.com/compose/)
- [Networking Guide](https://docs.docker.com/compose/networking/)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Health checks](https://docs.docker.com/compose/compose-file/#healthcheck)

# 📚 Apprentissages DevOps - Docker Compose

## 🎯 Objectif du Projet

Apprendre à **orchestrer plusieurs conteneurs** avec Docker Compose pour déployer une application complète en une seule commande.

## 🔑 Concepts Clés Appris

### 1. **Docker Compose Basics**
- Fichier `docker-compose.yml` avec version 3.9
- Définition de services (nginx, app, postgres, redis)
- Dépendances entre services avec `depends_on`
- Conditions de service (`service_healthy`)

```yaml
services:
  app:
    depends_on:
      postgres:
        condition: service_healthy
```

### 2. **Networking Docker**
- **Custom Bridge Network** (`devops-network`)
- Communication par DNS entre conteneurs (hostname = service name)
- Example: `app` peut accéder PostgreSQL via `postgres:5432`

```bash
# Dans app, accéder à la DB:
psql -h postgres -U postgres -d devops_db
```

### 3. **Volumes et Persistance**
- **Named Volumes** pour l'état (données DB, cache)
- `pg_data`: Persist les données PostgreSQL
- `redis_data`: Persist les snapshots Redis
- **Bind Mounts** (read-only) pour le code source

```yaml
volumes:
  pg_data:
    driver: local
  redis_data:
    driver: local
```

### 4. **Variables d'Environnement**
- Fichier `.env` centralisé
- Substitution dans `docker-compose.yml` via `${VAR}`
- Isolation des secrets et config

```yaml
environment:
  DB_PASSWORD: ${DB_PASSWORD:-postgres}
  DB_HOST: ${DB_HOST:-postgres}
```

### 5. **Health Checks**
- **Chaque service** a un health check
- Postgres: `pg_isready`
- Redis: `redis-cli PING`
- App Node.js: HTTP health endpoint
- Nginx: `wget` sur `/health`

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres"]
  interval: 10s
  timeout: 5s
  retries: 5
```

### 6. **Multi-Stage Docker Builds**
Réduire la taille de l'image Node.js :

```dockerfile
FROM node:20-alpine AS builder
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine
COPY --from=builder /app/node_modules ./node_modules
```

### 7. **Port Mapping et Exposition**
- `ports`: Expose vers l'hôte (nginx:80)
- `expose`: Interne au réseau Docker (app:3000)
- Nginx agit comme reverse proxy

```yaml
nginx:
  ports: ["80:80"]      # Externe
app:
  expose: ["3000"]      # Interne seulement
```

### 8. **Logging Structured**
- JSON driver avec rotation
- Max size: 10MB
- Max files: 3 fichiers

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### 9. **Architecture Microservices**
```
┌─────────────┐
│  User/CLI   │
└──────┬──────┘
       ↓ :80
┌──────────────┐
│ Nginx (LB)   │
└──────┬───────┘
       ↓ :3000 (interne)
┌──────────────┐
│ Node.js App  │
└──────┬───────┘
   ┌───┴────┬───────┐
   ↓        ↓       ↓
 PG DB   Redis   (future: Queue)
```

### 10. **Commandes Essentielles**
```bash
docker-compose up -d           # Start
docker-compose down            # Stop (keep volumes)
docker-compose down -v         # Stop (remove data)
docker-compose ps              # Status
docker-compose logs -f         # Logs (tous)
docker-compose logs -f app     # Logs (app seulement)
docker-compose exec app sh     # Terminal dans app
```

## 🏗️ Architecture Réelle

### Services et Responsabilités

| Service | Image | Port | Rôle |
|---------|-------|------|------|
| **nginx** | `nginx:alpine` | 80 | Reverse proxy, load balancing |
| **app** | Custom Node.js | 3000 (interne) | API REST, business logic |
| **postgres** | `postgres:16` | 5432 (interne) | Données persistantes |
| **redis** | `redis:7` | 6379 (interne) | Cache, sessions |

### Communication Réseau
- 🌍 User → nginx:80
- 🔗 nginx → app:3000 (forward)
- 🔗 app → postgres:5432 (SQL)
- 🔗 app → redis:6379 (cache)

## 💡 Best Practices Observées

1. ✅ **Health Checks** partout
2. ✅ **Restart Policy** : `unless-stopped`
3. ✅ **Volumes** pour persistance
4. ✅ **Non-root user** dans les Dockerfiles
5. ✅ **Multi-stage builds** pour images petites
6. ✅ **Variables d'env** au lieu de hardcoding
7. ✅ **Networking** custom pour isolation
8. ✅ **Logging** structuré avec rotation

## 🧪 Test Scenario

```bash
# 1. Lancer l'app
./start.sh

# 2. Vérifier status
curl http://localhost/api/status

# 3. Lister users
curl http://localhost/api/users

# 4. Créer user
curl -X POST http://localhost/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice","email":"alice@test.com"}'

# 5. Cache Redis
curl -X POST http://localhost/api/cache/key1 \
  -H "Content-Type: application/json" \
  -d '{"value":"hello","ttl":3600}'

curl http://localhost/api/cache/key1
```

## 🔮 Prochaines Étapes

1. **Kubernetes** : Migrer de Compose vers K8s
2. **CI/CD** : GitHub Actions pour build/push images
3. **Monitoring** : Prometheus + Grafana
4. **Logging** : ELK Stack ou Splunk
5. **Secrets** : HashiCorp Vault au lieu de .env
6. **IaC** : Terraform pour infra cloud
7. **Testing** : Integration tests avec Compose
8. **Security** : Scans avec Trivy, container signing

## 📖 Ressources

- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Networking Guide](https://docs.docker.com/network/)
- [Volume Best Practices](https://docs.docker.com/storage/volumes/)

## ✨ Résumé du Jour

Vous avez construit une **architecture microservices complète** avec Docker Compose :
- Multi-conteneurs orchestrés
- Persistence des données garantie
- API REST fonctionnelle
- Infrastructure déclarative et reproductible
- Prête pour la production (avec quelques ajouts)

**Temps pour maîtriser les bases : ~1 jour** ✅

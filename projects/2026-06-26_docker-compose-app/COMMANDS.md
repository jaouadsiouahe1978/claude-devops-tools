# Commandes Docker Compose Utiles

## 🚀 Démarrage et Arrêt

```bash
# Démarrer tous les services en arrière-plan
docker-compose up -d

# Démarrer et voir les logs en temps réel
docker-compose up

# Arrêter tous les services
docker-compose stop

# Supprimer les conteneurs (garder les volumes)
docker-compose down

# Supprimer tout (conteneurs + volumes)
docker-compose down -v

# Redémarrer tous les services
docker-compose restart
```

## 🔨 Construction

```bash
# Construire toutes les images
docker-compose build

# Construire une image spécifique
docker-compose build app

# Construire sans cache
docker-compose build --no-cache

# Pull les images officielles
docker-compose pull
```

## 📊 Monitoring et Logs

```bash
# Voir tous les logs
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f app
docker-compose logs -f postgres
docker-compose logs -f redis

# Voir les dernières N lignes
docker-compose logs --tail=100 -f

# Voir le statut des services
docker-compose ps

# Voir les services en détail
docker-compose ps -a
```

## 🔧 Gestion des Services

```bash
# Arrêter un service
docker-compose stop app

# Démarrer un service
docker-compose start app

# Redémarrer un service
docker-compose restart app

# Supprimer un service spécifique
docker-compose rm app

# Lancer une commande dans un conteneur
docker-compose exec app sh
docker-compose exec postgres psql -U postgres -d devops_db
docker-compose exec redis redis-cli
```

## 🌐 Accès aux Services

```bash
# Shell dans le conteneur app
docker-compose exec app sh

# Base de données PostgreSQL
docker-compose exec postgres psql -U postgres -d devops_db

# Query de test
docker-compose exec postgres psql -U postgres -d devops_db -c "SELECT * FROM users;"

# Cache Redis
docker-compose exec redis redis-cli
docker-compose exec redis redis-cli PING
docker-compose exec redis redis-cli KEYS "*"

# Voir les variables d'environnement
docker-compose exec app env
```

## 📋 Configuration

```bash
# Afficher la configuration fusionnée
docker-compose config

# Valider le fichier docker-compose.yml
docker-compose config --quiet

# Voir les images utilisées
docker-compose images
```

## 🔍 Debugging

```bash
# Stats des conteneurs en temps réel
docker stats

# Inspecter un conteneur
docker inspect devops-app
docker inspect devops-postgres
docker inspect devops-redis

# Voir les processus dans un conteneur
docker-compose top app

# Voir les changements de fichiers
docker-compose exec app ls -la

# Vérifier la connectivité réseau
docker-compose exec app ping postgres
docker-compose exec app ping redis

# Test de connectivité base de données
docker-compose exec app psql -h postgres -U postgres -d devops_db -c "SELECT 1"
```

## 💾 Volumes et Persistence

```bash
# Voir les volumes
docker volume ls

# Inspecter un volume
docker volume inspect devops-pg_data

# Backup de la base de données
docker-compose exec postgres pg_dump -U postgres devops_db > backup.sql

# Restore de la base de données
docker-compose exec -T postgres psql -U postgres devops_db < backup.sql

# Supprimer les données persistantes
docker-compose down -v
```

## 🧪 Tests et Validation

```bash
# Vérifier que tous les services sont up
docker-compose ps

# Health check
docker-compose exec app curl http://localhost:3000/api/status

# Test complet
bash test.sh

# Requête manuelle
curl http://localhost/api/status
curl http://localhost/api/users
curl -X POST http://localhost/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com"}'
```

## 🎯 Commandes de production

```bash
# Scale un service (attention au state)
docker-compose up -d --scale app=3

# Voir les événements en temps réel
docker-compose events --action=start,stop

# Sauvegarde des données
docker-compose exec postgres pg_dump -U postgres devops_db | gzip > db_backup_$(date +%Y%m%d_%H%M%S).sql.gz

# Mise à jour des images
docker-compose pull
docker-compose up -d
```

## 📝 Bonnes pratiques

- Toujours vérifier les logs avant de démarrer : `docker-compose logs`
- Utiliser les health checks : voir `docker-compose ps`
- Sauvegarder régulièrement la base de données
- Utiliser les variables d'environnement pour la config
- Ne pas modifier les images en production
- Utiliser des tags de version pour les images
- Monitorer les performances avec `docker stats`

# PostgreSQL High Availability avec Streaming Replication

## Description

Ce projet démontre comment configurer une architecture PostgreSQL hautement disponible avec **streaming replication** (réplication synchrone) et **failover automatique**. Cette architecture garantit que les données sont répliquées en temps réel entre un serveur primaire et des serveurs de standby.

**Cas d'usage :** Assurer la continuité de service pour les bases de données critiques en production.

## Objectifs

✅ Configurer deux instances PostgreSQL (Primaire + Standby)
✅ Mettre en place la streaming replication synchrone
✅ Implémenter le failover automatique avec pg_basebackup
✅ Tester le basculement en cas de panne du serveur primaire
✅ Monitorer l'état de la réplication

## Prérequis

- Docker et Docker Compose installés
- Connaissance basique de PostgreSQL
- Compréhension du concept de réplication de base de données

## Technologies utilisées

- **PostgreSQL 15** - Base de données relationnelle
- **Docker Compose** - Orchestration des conteneurs
- **pg_basebackup** - Outil de réplication PostgreSQL
- **Shell scripting** - Automation et monitoring

## Architecture

```
┌─────────────────────────────────────────────────────┐
│ Docker Network (replication-net)                    │
│                                                     │
│  ┌──────────────────┐      ┌──────────────────┐    │
│  │  PostgreSQL      │      │  PostgreSQL      │    │
│  │  Primary         │──→   │  Standby         │    │
│  │  (Port 5432)     │      │  (Port 5433)     │    │
│  │                  │      │                  │    │
│  │  - WAL Sender    │      │  - WAL Receiver  │    │
│  │  - Read/Write    │      │  - Read-only     │    │
│  └──────────────────┘      └──────────────────┘    │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │ Monitoring Script                            │  │
│  │ - Vérif de la réplication                    │  │
│  │ - Health check                               │  │
│  │ - Alertes                                    │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## Étapes de réalisation

### Étape 1: Préparer l'environnement Docker

1. Créer les fichiers de configuration PostgreSQL (postgresql.conf)
2. Créer des scripts d'initialisation pour Primary et Standby
3. Configurer le docker-compose.yml avec les deux services

### Étape 2: Configurer le serveur Primaire

Configuration requise dans `postgresql.conf`:
```
wal_level = replica              # Niveau de logs WAL pour réplication
max_wal_senders = 3              # Nombre max de senders WAL
wal_keep_size = 1GB              # Taille min des WAL à conserver
max_replication_slots = 3        # Slots de réplication
synchronous_commit = remote_apply # Commit synchrone
```

Créer un utilisateur de réplication:
```sql
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'repl_password';
```

### Étape 3: Configurer le serveur Standby

1. Utiliser `pg_basebackup` pour dupliquer les données du primaire
2. Créer un signal file pour indiquer que c'est un standby en recovery
3. Configurer la réplication depuis le primaire

### Étape 4: Tester la réplication

1. Créer une table de test sur le primaire
2. Insérer des données
3. Vérifier que les données apparaissent sur le standby en lecture
4. Vérifier le statut de la réplication avec les vues système

### Étape 5: Tester le failover

1. Arrêter le serveur primaire
2. Promouvoir le standby en primaire avec `pg_ctl promote`
3. Vérifier que l'application peut se connecter au nouveau primaire
4. Redémarrer l'ancien primaire comme nouveau standby

### Étape 6: Monitoring et alertes

Créer un script de monitoring qui:
- Vérifie l'état de la réplication toutes les 10 secondes
- Affiche le lag de réplication (delay)
- Détecte les déconnexions
- Log les événements

## Commandes essentielles

```bash
# Démarrer l'infrastructure
docker-compose up -d

# Accéder au serveur primaire
docker exec -it pg_primary psql -U postgres

# Accéder au serveur standby (lecture seule)
docker exec -it pg_standby psql -U postgres -h pg_standby

# Vérifier l'état de la réplication (depuis primaire)
SELECT pid, usename, state, sync_state FROM pg_stat_replication;

# Vérifier le lag de réplication (depuis primaire)
SELECT now() - pg_last_wal_receive_lsn() as replication_lag;

# Afficher les statistiques WAL
SELECT * FROM pg_stat_replication;

# Promouvoir le standby en primaire (failover)
docker exec -it pg_standby pg_ctl promote -D /var/lib/postgresql/data

# Arrêter l'infrastructure
docker-compose down -v
```

## Ce qu'on apprend

1. **PostgreSQL Replication** - Architecture maître-esclave et streaming replication
2. **High Availability** - Patterns de redondance et failover automatique
3. **WAL (Write-Ahead Logging)** - Mécanisme de log des transactions
4. **Synchronous Replication** - Garanties ACID avec réplication synchrone
5. **Disaster Recovery** - Stratégies de basculement et récupération
6. **Scripting DevOps** - Automation du déploiement et monitoring
7. **Docker Networking** - Communication inter-conteneurs et données persistantes

## Points clés à retenir

- ✅ La streaming replication de PostgreSQL est asynchrone par défaut mais peut être configurée en synchrone
- ✅ Le `synchronous_commit = remote_apply` garantit que le commit primaire attend la confirmation du standby
- ✅ Les slots de réplication maintiennent les WAL sur le primaire tant que le standby n'a pas confirmé
- ✅ Un standby ne peut être que lu (read-only) pendant la recovery
- ✅ Le failover manuel avec `pg_ctl promote` convertit le standby en primaire
- ✅ Pour un failover automatique, il faut un gestionnaire externe comme Patroni ou Stolon

## Ressources utiles

- [PostgreSQL Streaming Replication](https://www.postgresql.org/docs/current/warm-standby.html)
- [pg_basebackup Documentation](https://www.postgresql.org/docs/current/app-pgbasebackup.html)
- [High Availability Patterns](https://www.postgresql.org/docs/current/different-replication-solutions.html)

## Auteur

Claude DevOps - 2026-09-26

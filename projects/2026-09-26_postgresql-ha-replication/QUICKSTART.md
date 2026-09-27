# Quick Start Guide - PostgreSQL HA Streaming Replication

## 1. Démarrage rapide (2 minutes)

```bash
# Démarrer l'infrastructure
make up

# Attendre 10 secondes pour que la replication s'établisse
sleep 10

# Vérifier le statut
make status
```

## 2. Vérifier la réplication (5 minutes)

```bash
# Accéder au serveur primaire
make psql-primary

# Dans psql, vérifier l'état de la réplication
SELECT pid, usename, state, sync_state FROM pg_stat_replication;
```

## 3. Tester la réplication de données (3 minutes)

```bash
# Insérer des données de test
make insert-data

# Vous verrez:
# - Les données insérées sur le primary
# - Les données vérifiées sur le standby
```

## 4. Tester le failover (5 minutes)

```bash
# Promouvoir le standby en primary
make failover

# Suivre les instructions affichées
# Le standby deviendra le nouveau primary
```

## 5. Nettoyer

```bash
# Arrêter l'infrastructure
make down

# Supprimer tous les volumes
make clean
```

---

## Commandes utiles

### Monitoring en temps réel

```bash
# Voir les logs de la réplication
make monitor

# Vérifier le lag de réplication
docker exec pg_primary psql -U postgres -d postgres \
  -c "SELECT now() - pg_last_wal_receive_lsn() as replication_lag;"
```

### Connexions SQL

```bash
# Connecter au primary (lecture/écriture)
make psql-primary

# Connecter au standby (lecture seule)
make psql-standby
```

### Requêtes SQL importantes

```sql
-- Sur le PRIMARY
-- Voir tous les standby connectés
SELECT pid, usename, application_name, state FROM pg_stat_replication;

-- Voir le LAG de réplication
SELECT 
  client_addr,
  state,
  sync_state,
  write_lag,
  flush_lag,
  replay_lag
FROM pg_stat_replication;

-- Voir la position actuelle du WAL
SELECT pg_current_wal_lsn();

-- Sur le STANDBY (en lecture seule)
-- Vérifier qu'on est en recovery
SELECT pg_is_in_recovery();

-- Voir la dernière LSN reçue
SELECT pg_last_wal_receive_lsn();

-- Lire les données du test
SELECT * FROM test_replication ORDER BY timestamp DESC LIMIT 5;
```

---

## Architecture

```
┌────────────────────────────────────────────────┐
│  Docker Compose Network                        │
│                                                │
│  PRIMARY (pg_primary:5432)                     │
│  - WAL Sender                                  │
│  - Read/Write enabled                          │
│      ↓↓↓ Streaming Replication ↓↓↓             │
│  STANDBY (pg_standby:5433)                     │
│  - WAL Receiver                                │
│  - Read-only (in recovery)                     │
│                                                │
│  MONITOR (Continuous status checks)            │
└────────────────────────────────────────────────┘
```

---

## Cas d'usage avancés

### Insérer beaucoup de données (stress test)

```bash
# Dans le container primary
docker exec pg_primary psql -U postgres -d testdb << 'EOF'
INSERT INTO test_replication (message) 
SELECT 'Bulk insert ' || i FROM generate_series(1, 1000) i;
EOF

# Vérifier la réplication
docker exec pg_standby psql -U replicator -d testdb \
  -c "SELECT COUNT(*) FROM test_replication;"
```

### Monitorer le WAL

```bash
# Voir la taille des WAL logs
docker exec pg_primary du -sh /var/lib/postgresql/data/pg_wal/
```

### Vérifier les slots de réplication

```bash
docker exec pg_primary psql -U postgres -d postgres \
  -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"
```

---

## Dépannage

### Le standby n'a pas de données

- Attendre 10 secondes après `make up`
- Vérifier que le primaire est UP : `docker ps`
- Vérifier les logs : `docker logs pg_standby`

### Erreur "cannot execute INSERT during recovery"

- C'est normal ! Le standby est en read-only
- Vous avez besoin d'écrire sur le primary

### Le failover échoue

- Vérifier que le standby est UP : `docker ps`
- Vérifier la connexion : `docker exec pg_standby pg_isready -U replicator`

### Réinitialiser le cluster

```bash
make clean
make up
```

---

## Points clés à retenir

✅ **Le standby est en lecture seule pendant la réplication**
- Pour écrire, connectez-vous au primary (port 5432)

✅ **La réplication est asynchrone par défaut**
- Configuration `synchronous_commit = remote_apply` la rend synchrone

✅ **Le failover est manuel dans cette setup**
- Commande : `pg_ctl promote`
- Pour du failover automatique, voir Patroni/Stolon

✅ **Les données sont persistantes dans les volumes Docker**
- Les volumes `pg_primary_data` et `pg_standby_data` survivent aux redémarrages

---

## Prochaines étapes

1. **Tester la réplication sous charge** - Insérer 10 000+ rows
2. **Monitorer les performances** - Vérifier write_lag, flush_lag, replay_lag
3. **Tester la récupération** - Couper la connexion réseau avec `docker network disconnect`
4. **Configurer le failover automatique** - Ajouter Patroni au-dessus de PostgreSQL
5. **Backup et Recovery** - Ajouter un script de backup WAL et PITR

---

**Durée totale : ~20 minutes pour une démonstration complète**

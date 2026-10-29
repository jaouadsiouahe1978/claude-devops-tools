# Configuration Avancée PostgreSQL sur Kubernetes

Ce répertoire contient des configurations avancées pour déployer PostgreSQL en haute disponibilité avec réplication.

## 🎯 Configurations disponibles

### 1. Patroni HA (Haute Disponibilité)
**Fichier:** `patroni-ha.yaml`

Patroni est un système de gestion de cluster PostgreSQL automatisé:
- **Automatic Failover**: Basculement automatique en cas de défaillance du master
- **Réplication streaming**: Synchronisation continue des données
- **Leader Election**: Élection automatique du leader avec etcd/Consul
- **Health Checks**: Monitoring et reparation automatiques

**Architectures possibles:**
```
┌─────────────┐
│  Primary    │ ← Écritures/Lectures
│  (Master)   │
└──────┬──────┘
       │ Replication
       ↓
┌─────────────┐
│ Standby 1   │ → Lectures (optionnel)
└─────────────┘
       
┌─────────────┐
│ Standby 2   │ → Lectures (optionnel)
└─────────────┘
```

**Avantages:**
- RTO (Recovery Time Objective): < 1 minute
- RPO (Recovery Point Objective): quasiment 0
- Maintenance sans downtime

**Prérequis:**
- etcd ou Consul pour la coordination
- DCS (Distributed Configuration Store)

### 2. pgBouncer Connection Pooling
**Fichier:** `pgbouncer-pooling.yaml`

pgBouncer est un connection pool leger:
- **Connection reuse**: Réutilise les connections existantes
- **Réduit la charge**: Évite la création de connexions coûteuses
- **Compatible**: Transparente pour l'application

**Modes de pooling:**
- **session**: 1 pool par session client (par défaut, sûr)
- **transaction**: 1 pool par transaction (plus rapide, attention aux transactions longues)
- **statement**: 1 pool par statement (dangereux pour certaines queries)

**Configuration typique:**
```ini
[databases]
myapp = host=postgres-0.postgres.default.svc.cluster.local port=5432 dbname=myapp

[pgbouncer]
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 25
min_pool_size = 10
reserve_pool_size = 5
```

### 3. Backup Externe (S3)
Pour mettre en place les backups automatiques:

```bash
# Ajouter un CronJob Kubernetes
kubectl apply -f backup-cronjob.yaml

# Sauvegarder vers S3 avec credentials AWS
aws configure
./scripts/backup-to-s3.sh
```

### 4. Monitoring Avancé
Intégrer avec Prometheus et Grafana:

```bash
# Installer postgres_exporter
helm install prometheus-postgres-exporter \
  prometheus-community/prometheus-postgres-exporter \
  --set postgresql.host=postgres-0.postgres.postgres-demo.svc.cluster.local

# Dashboard Grafana: https://grafana.com/grafana/dashboards/3742
```

## 🚀 Mise en place de Patroni HA

### Étape 1: Installer etcd
```bash
# Via Helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install etcd bitnami/etcd \
  -n postgres-demo \
  --set auth.rbac.enabled=false
```

### Étape 2: Déployer Patroni
```bash
# Adapter la configuration si nécessaire
kubectl apply -f patroni-ha.yaml

# Vérifier le status du cluster
kubectl exec -it postgres-0 -n postgres-demo -- \
  patronictl -c /etc/patroni/patroni.yml list
```

### Étape 3: Tester le failover
```bash
# Supprimer le master
kubectl delete pod postgres-0 -n postgres-demo

# Patroni va élire un nouveau master
sleep 10

# Vérifier quel pod est le master
patronictl list | grep -E "^\+|Leader"

# Les applications continueront à fonctionner!
```

## 📊 Comparaison des approches

| Aspect | StatefulSet Simple | Patroni HA | Patroni + pgBouncer |
|--------|-------------------|-----------|-------------------|
| **Complexité** | ⭐ Simple | ⭐⭐⭐ Complexe | ⭐⭐⭐⭐ Très complexe |
| **Disponibilité** | Manuelle | Automatique | Automatique |
| **Performance** | Moyenne | Bonne | Excellente |
| **Failover** | ~5 min | < 30 sec | < 30 sec |
| **Coût** | Faible | Moyen | Moyen-Haut |
| **Maintenance** | Facile | Modérée | Complexe |

## 🔒 Sécurité avancée

### 1. SSL/TLS pour PostgreSQL
```yaml
# Dans le StatefulSet
env:
- name: POSTGRES_INITDB_ARGS
  value: "-c ssl=on -c ssl_cert_file=/etc/postgresql/certs/server.crt"
volumeMounts:
- name: tls-certs
  mountPath: /etc/postgresql/certs
  readOnly: true
```

### 2. RBAC et NetworkPolicy
```yaml
# Limiter l'accès réseau
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: postgres-netpolicy
spec:
  podSelector:
    matchLabels:
      app: postgres
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: myapp
    ports:
    - protocol: TCP
      port: 5432
```

### 3. Pod Security Policy
```yaml
# Éviter les containers privilegiés
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: postgres-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
  - ALL
  volumes:
  - 'configMap'
  - 'emptyDir'
  - 'projected'
  - 'secret'
  - 'downwardAPI'
  - 'persistentVolumeClaim'
```

## 📈 Performance Tuning

### 1. Configuration PostgreSQL optimisée
```sql
-- Pour 4 CPU, 16GB RAM
shared_buffers = 4GB
effective_cache_size = 12GB
maintenance_work_mem = 1GB
work_mem = 104MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
```

### 2. Indices pour accélerer les requêtes
```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at DESC);
```

### 3. Vacuum et Analyze régulier
```yaml
# Dans configmap PostgreSQL
autovacuum = on
autovacuum_max_workers = 3
autovacuum_naptime = 10s
```

## 🐛 Troubleshooting

### "Pod stuck in Pending"
```bash
# Vérifier les events
kubectl describe pod postgres-0 -n postgres-demo

# Vérifier les PVC
kubectl describe pvc data-postgres-0 -n postgres-demo

# Créer le PV manuellement si nécessaire
kubectl apply -f ../pv-local.yaml
```

### "Connection refused"
```bash
# Vérifier les logs
kubectl logs postgres-0 -n postgres-demo

# Vérifier les probes
kubectl describe pod postgres-0 -n postgres-demo | grep -A5 "Readiness\|Liveness"

# Attendre plus longtemps
sleep 30
```

### Réplication en retard
```bash
# Depuis le pod
psql -U postgres -c "SELECT now() - pg_last_wal_receive_lsn_time() AS replication_delay;"

# Vérifier depuis Patroni
patronictl list --show-cluster | grep Lag
```

## 📚 Ressources supplémentaires

- [Patroni Documentation](https://patroni.readthedocs.io/)
- [pgBouncer Manual](https://www.pgbouncer.org/)
- [PostgreSQL Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [Kubernetes Best Practices for Databases](https://kubernetes.io/docs/tasks/run-application/run-stateful-application/)

## 🎓 Prochaines étapes
1. Implémenter Patroni pour HA
2. Ajouter pgBouncer pour optimiser les connections
3. Configurer des backups automatiques vers S3
4. Intégrer Prometheus/Grafana pour le monitoring
5. Configurer les alertes Alertmanager
6. Tester le failover et la récupération

---
**Crée par:** DevOps Agent
**Niveau:** Avancé
**Temps estimé:** 2-4 jours pour implémenter tout

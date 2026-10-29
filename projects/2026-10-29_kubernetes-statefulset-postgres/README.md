# Kubernetes StatefulSet: PostgreSQL avec Persistent Storage

## 📋 Objectif
Déployer une base de données PostgreSQL dans Kubernetes en utilisant un **StatefulSet** pour la gestion d'état et les **PersistentVolumes** pour la persistance des données. Ce projet couvre les concepts essentiels pour gérer les workloads stateful en production.

## 🎯 Ce qu'on apprend
- **StatefulSet vs Deployment** : quand et pourquoi utiliser chacun
- **PersistentVolume (PV)** et **PersistentVolumeClaim (PVC)** : stockage persistent
- **Service headless** : communication réseau pour les StatefulSets
- **Configuration et Secrets** : gestion des variables et mots de passe
- **Backup et Restore** : scripts de maintenance de base de données
- **Health checks** : readiness et liveness probes pour les bases de données
- **Scaling** : ajouter des réplicas de lecture avec Patroni (optionnel)

## 📦 Technologies
- **Kubernetes 1.24+**
- **PostgreSQL 15**
- **kubectl**
- **Docker** (pour tester localement avec kind/minikube)

## 📋 Pré-requis
```bash
# Vérifier que k8s est accessible
kubectl cluster-info

# Si vous n'avez pas de cluster, installez kind ou minikube
kind create cluster --name postgres-demo
```

## 🚀 Étapes de réalisation

### 1. Créer les namespaces et les secrets
```bash
# Créer un namespace dédié
kubectl create namespace postgres-demo

# Créer le secret pour le mot de passe
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_PASSWORD=mysecurepassword123 \
  -n postgres-demo
```

### 2. Créer le PersistentVolume (PV) - optionnel en dev
Consulter `pv-local.yaml` pour une configuration de dev avec stockage local.

```bash
kubectl apply -f pv-local.yaml
```

### 3. Déployer le StatefulSet
```bash
# Appliquer tous les fichiers k8s
kubectl apply -f configmap.yaml
kubectl apply -f statefulset.yaml
kubectl apply -f service.yaml

# Vérifier le déploiement
kubectl get statefulsets -n postgres-demo
kubectl get pods -n postgres-demo
kubectl get pvc -n postgres-demo
```

### 4. Attendre que PostgreSQL soit prêt
```bash
kubectl wait --for=condition=ready pod \
  -l app=postgres \
  -n postgres-demo \
  --timeout=120s
```

### 5. Initialiser la base de données
```bash
# Port forward pour accéder à la DB localement
kubectl port-forward -n postgres-demo postgres-0 5432:5432 &

# Se connecter avec psql
psql -h localhost -U postgres -d postgres

# Créer une base de test
CREATE DATABASE myapp;
CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(100));
INSERT INTO users (name) VALUES ('Alice'), ('Bob');
```

### 6. Tester la persistance
```bash
# Vérifier les données
psql -h localhost -U postgres -d myapp -c "SELECT * FROM users;"

# Supprimer le pod (il sera recréé)
kubectl delete pod postgres-0 -n postgres-demo

# Attendre que le pod soit prêt
kubectl wait --for=condition=ready pod postgres-0 -n postgres-demo --timeout=30s

# Vérifier que les données sont toujours présentes
psql -h localhost -U postgres -d myapp -c "SELECT * FROM users;"
```

### 7. Backup et Restore
```bash
# Créer un backup
bash scripts/backup-postgres.sh

# Simuler une perte de données
kubectl exec -it postgres-0 -n postgres-demo -- \
  psql -U postgres -d myapp -c "DELETE FROM users;"

# Restaurer depuis le backup
bash scripts/restore-postgres.sh
```

### 8. Monitoring (optionnel)
```bash
# Consulter les logs
kubectl logs -f postgres-0 -n postgres-demo

# Afficher les métriques (si metrics-server est installé)
kubectl top pod postgres-0 -n postgres-demo
```

## 📁 Structure du projet
```
2026-10-29_kubernetes-statefulset-postgres/
├── README.md                          # Cette doc
├── configmap.yaml                     # Configuration PostgreSQL
├── statefulset.yaml                   # Définition du StatefulSet
├── service.yaml                       # Service headless + ClusterIP
├── pv-local.yaml                      # PersistentVolume (dev)
├── pvc.yaml                           # PersistentVolumeClaim
├── init-db.sql                        # Script d'initialisation
├── scripts/
│   ├── backup-postgres.sh             # Backup avec pg_dump
│   ├── restore-postgres.sh            # Restore depuis backup
│   ├── health-check.sh                # Script de health check
│   └── connect.sh                     # Helper pour se connecter
└── advanced/
    ├── patroni-ha.yaml                # Haute disponibilité avec Patroni
    └── pgbouncer-pooling.yaml         # Connection pooling
```

## 🔍 Points clés à comprendre

### Pourquoi StatefulSet et pas Deployment?
- **Identité stable** : chaque pod a un nom prévisible (postgres-0, postgres-1, etc.)
- **Stockage persistant** : chaque pod peut être lié à son propre volume
- **Ordre de déploiement** : les pods se créent/détruisent dans l'ordre
- **Headless Service** : communication directe pod-à-pod sans load balancing

### Headless Service
```yaml
serviceName: "postgres"  # Doit correspondre au nom du Service
```
Permet à chaque pod d'avoir son propre DNS : `postgres-0.postgres.default.svc.cluster.local`

### Health Checks
```yaml
readinessProbe:
  exec:
    command: ["pg_isready", "-U", "postgres"]
livenessProbe:
  exec:
    command: ["pg_isready", "-U", "postgres"]
```
Kubernetes s'assure que PostgreSQL est vraiment prêt avant de le servir.

## 🚨 Pièges courants
1. **Pod stuck en Pending** : vérifier les PVC avec `kubectl describe pvc`
2. **Connection refused** : attendre le readiness probe, vérifier les logs
3. **PVC not bound** : vérifier que le PV existe et correspond au PVC
4. **Password authentication fails** : vérifier le secret k8s et les variables d'env

## 🎓 Pour aller plus loin
- Ajouter une réplica standby avec Patroni pour la haute disponibilité
- Configurer pgBouncer pour le connection pooling
- Ajouter des backups automatiques vers S3
- Intégrer Prometheus pour le monitoring
- Tester le failover avec un chaos engineering tool

## 📚 Ressources
- [Kubernetes StatefulSets Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [PostgreSQL Best Practices on Kubernetes](https://www.postgresql.org/docs/)
- [Patroni pour la HA](https://github.com/zalando/patroni)

## ⏱️ Temps estimé
**4-6 heures** : déploiement de base + tests + backup/restore
**8+ heures** : avec Patroni HA et monitoring

---
**Créé le :** 2026-10-29
**Niveau :** Intermédiaire
**Technos :** Kubernetes, PostgreSQL, StatefulSet, PersistentVolume

# Concepts fondamentaux : StatefulSet et Persistent Storage

## 📚 Table des matières

1. [StatefulSet vs Deployment](#statefulset-vs-deployment)
2. [PersistentVolume et PersistentVolumeClaim](#persistentvolume-et-persistentvolumeclaim)
3. [Service Headless](#service-headless)
4. [Pod Identity et Ordinal](#pod-identity-et-ordinal)
5. [Cycle de vie d'un StatefulSet](#cycle-de-vie-dun-statefulset)
6. [Bonnes pratiques](#bonnes-pratiques)

---

## StatefulSet vs Deployment

### Deployment (pour les applications **stateless**)

```
Deployment "nginx" (3 replicas)
├── Pod: nginx-abc123def456  ← nom aléatoire
├── Pod: nginx-xyz789ghi012  ← chaque redémarrage change le nom
└── Pod: nginx-qrs345tuv678

Caractéristiques:
- Noms de pods aléatoires
- Pas d'ordre de startup
- Tous les pods sont interchangeables
- Idéal pour: Web servers, APIs, Workers
```

### StatefulSet (pour les applications **stateful**)

```
StatefulSet "postgres" (3 replicas)
├── Pod: postgres-0  ← nom stable, ordinal 0
├── Pod: postgres-1  ← créé après postgres-0, ordinal 1
└── Pod: postgres-2  ← créé après postgres-1, ordinal 2

Caractéristiques:
- Noms de pods ordonnés et stables
- Ordre de startup/shutdown garanti
- Chaque pod a son PVC dédié
- Chaque pod a une identité DNS stable
- Idéal pour: Databases, Message queues, caches
```

### Tableau comparatif

| Aspect | Deployment | StatefulSet |
|--------|-----------|-------------|
| **Pod naming** | Aléatoire (app-abc123) | Ordinal (app-0, app-1) |
| **Pod identity** | Éphémère | Persistent |
| **Startup order** | Parallèle | Séquentiel (0 → 1 → 2) |
| **Shutdown order** | Parallèle | Inverse (2 → 1 → 0) |
| **PVC binding** | Un PVC partagé (optionnel) | Un PVC par pod |
| **DNS hostname** | Flottant | Stable (pod-0.service.ns.svc) |
| **Storage** | Partagé | Dédié par pod |
| **Use cases** | Web, API, Workers | DB, Cache, Message Queue |

---

## PersistentVolume et PersistentVolumeClaim

### Architecture de stockage Kubernetes

```
┌─────────────────────────────────────────────────────────┐
│                   Cluster Kubernetes                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │            PersistentVolume (PV)               │    │
│  │  - Ressource au niveau du cluster              │    │
│  │  - Fournit du stockage brut                    │    │
│  │  - Créé par l'administrateur ou le            │    │
│  │    provisioner automatique                     │    │
│  │  - Cycle de vie indépendant des pods          │    │
│  └────────────────┬─────────────────────────────┘    │
│                   │ (bind)                             │
│  ┌────────────────▼─────────────────────────────┐    │
│  │       PersistentVolumeClaim (PVC)            │    │
│  │  - Ressource au niveau du namespace           │    │
│  │  - Demande de stockage par un pod             │    │
│  │  - Lie un PV avec des conditions              │    │
│  │  - Cycle de vie peut être independant ou      │    │
│  │    lié au pod                                 │    │
│  └────────────────┬─────────────────────────────┘    │
│                   │ (mount)                            │
│  ┌────────────────▼─────────────────────────────┐    │
│  │              Volume (dans le Pod)            │    │
│  │  - Utilisé via volumeMount                    │    │
│  │  - Accessible par un containerPath            │    │
│  └────────────────────────────────────────────┘    │
│                                                      │
│  ┌────────────────────────────────────────────────┐  │
│  │         Stockage physique (Node)               │  │
│  │  - /var/lib/kubelet/pods/.../volumes/...      │  │
│  │  - Local storage, NFS, Cloud storage, etc.    │  │
│  └────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### Cycle de vie PV/PVC

```
1. AVAILABLE
   ↓
   PVC demande du stockage
   ↓
2. BOUND
   PV et PVC sont appairés
   ↓
   Pod utilise la PVC
   ↓
3. IN USE
   Pod accède à la PVC
   ↓
   PVC supprimée OU Pod supprimé
   ↓
4. RELEASED
   PVC libérée, PV peut être réutilisé
   (selon la persistentVolumeReclaimPolicy)
   ↓
5. AVAILABLE (ou DELETED)
   Selon la politique de réclamation
```

### Politique de réclamation (Reclaim Policies)

```yaml
persistentVolumeReclaimPolicy:
  - Retain     # Gardez les données même après suppression (défaut)
  - Delete     # Supprimez le volume physique avec le PV
  - Recycle    # Nettoyez puis réutilisez le volume
```

---

## Service Headless

### Qu'est-ce qu'un service headless ?

Un service **headless** est un service Kubernetes **sans IP cluster unique**. 

```yaml
# Service normal (avec ClusterIP)
spec:
  clusterIP: 10.0.1.5     # ← IP virtuelle unique
  selector:
    app: postgres
  
# Service headless (sans ClusterIP)
spec:
  clusterIP: None         # ← Pas d'IP virtuelle
  selector:
    app: postgres
```

### Résolution DNS

```
Service normal:
┌──────────────────┐
│  postgres.ns.    │ → 10.0.1.5 (IP unique du service)
│  svc.cluster.    │            ↓
│  local           │         Load balance vers
└──────────────────┘        tous les pods

Service headless:
┌─────────────────────┐
│ postgres.ns.svc.    │ → 10.0.2.5 (postgres-0)
│ cluster.local       │ → 10.0.2.6 (postgres-1)
└─────────────────────┘ → 10.0.2.7 (postgres-2)

┌──────────────────────────┐
│ postgres-0.postgres.     │ → 10.0.2.5 (stable!)
│ ns.svc.cluster.local    │
└──────────────────────────┘

┌──────────────────────────┐
│ postgres-1.postgres.     │ → 10.0.2.6 (stable!)
│ ns.svc.cluster.local    │
└──────────────────────────┘
```

### Pourquoi headless pour StatefulSet ?

1. **Adresse stable par pod** : postgres-0 a toujours la même IP/DNS
2. **Découverte de service** : applications peuvent énumérer tous les replicas
3. **Replication primaire/replica** : le primaire peut être découvert par des clients
4. **Clustering** : les nœuds du cluster peuvent se découvrir par DNS

---

## Pod Identity et Ordinal

### Identité stable dans un StatefulSet

```
StatefulSet: postgres
├── serviceName: postgres
├── replicas: 3

Pods créés:
├── postgres-0  (ordinal: 0)
│   ├── Nom stable: postgres-0
│   ├── DNS: postgres-0.postgres.postgresql.svc.cluster.local
│   ├── Hostname: postgres-0
│   └── PVC: postgres-storage-0
│
├── postgres-1  (ordinal: 1)
│   ├── Nom stable: postgres-1
│   ├── DNS: postgres-1.postgres.postgresql.svc.cluster.local
│   ├── Hostname: postgres-1
│   └── PVC: postgres-storage-1
│
└── postgres-2  (ordinal: 2)
    ├── Nom stable: postgres-2
    ├── DNS: postgres-2.postgres.postgresql.svc.cluster.local
    ├── Hostname: postgres-2
    └── PVC: postgres-storage-2
```

### Variables d'environnement disponibles dans les pods

```bash
# Dans le conteneur d'un pod StatefulSet:
$ env | grep HOSTNAME
HOSTNAME=postgres-0

$ hostname
postgres-0

$ hostname -f
postgres-0.postgres.postgresql.svc.cluster.local
```

### Discovering replicas

```bash
# Un pod peut découvrir ses pairs via DNS:
postgres-0 peut contacter:
  - postgres-0.postgres.postgresql.svc.cluster.local (lui-même)
  - postgres-1.postgres.postgresql.svc.cluster.local
  - postgres-2.postgres.postgresql.svc.cluster.local

# Utile pour:
# - Replica replication (postgres-0 = primaire, postgres-1 = replica)
# - Clustering distributed (Redis Cluster, etcd)
# - Service discovery stateful (Kafka brokers)
```

---

## Cycle de vie d'un StatefulSet

### Création

```
1. Kubernetes crée postgres-0
   ├── Crée le PVC postgres-storage-0
   ├── Bind le PVC à un PV
   ├── Crée le Pod postgres-0
   └── Attente du Pod "Ready" (readinessProbe)

2. Kubernetes crée postgres-1 (APRÈS que postgres-0 soit Ready)
   ├── Crée le PVC postgres-storage-1
   ├── Bind le PVC à un PV
   ├── Crée le Pod postgres-1
   └── Attente du Pod "Ready"

3. Kubernetes crée postgres-2 (APRÈS que postgres-1 soit Ready)
   └── Même processus...

Temps total: Σ(startupTime de chaque pod) 
             ≠ startupTime * 3 (parallèle)
```

### Suppression

```
1. Kubernetes supprime postgres-2 EN PREMIER
   ├── Envoie SIGTERM au conteneur
   ├── Attend 30s (terminationGracePeriodSeconds)
   ├── Envoie SIGKILL si nécessaire
   └── Pod supprimé
   
   NOTE: Le PVC N'est PAS supprimé automatiquement!
         (retention policy par défaut)

2. Kubernetes supprime postgres-1
   └── Même processus...

3. Kubernetes supprime postgres-0 EN DERNIER
   └── Même processus...

Ordre: 2 → 1 → 0 (inverse de la création)
```

### Mise à jour (RollingUpdate)

```
StatefulSet.spec.updateStrategy: RollingUpdate

1. Met à jour postgres-2 (dernier ordinal)
2. Met à jour postgres-1
3. Met à jour postgres-0 (premier ordinal)

Raison: Minimiser les downtime en garder postgres-0 (souvent le primaire)
        à jour en dernier.
```

### Crash d'un pod

```
Si postgres-1 crash:

1. Kubelet détecte que le pod n'est pas healthy
   └── via livenessProbe

2. Kubernetes supprime le pod crashed
   └── postgres-1 est "Terminating"

3. Kubernetes re-crée postgres-1
   ├── Même nom stable
   ├── MÊME PVC (postgres-storage-1)
   ├── MÊMES DONNÉES (car PVC survive)
   └── Pod revient avec toutes ses données

Temps de récupération: ~30 secondes (par défaut)
```

---

## Bonnes pratiques

### 1. Toujours utiliser un service headless avec StatefulSet

```yaml
❌ MAUVAIS
apiVersion: apps/v1
kind: StatefulSet
spec:
  serviceName: ""  # Oubli du service!

✅ BON
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  clusterIP: None  # Headless!
---
apiVersion: apps/v1
kind: StatefulSet
spec:
  serviceName: postgres  # Référence le service headless
```

### 2. Configurer les readiness/liveness probes

```yaml
readinessProbe:
  exec:
    command:
      - /bin/sh
      - -c
      - pg_isready -U postgres
  initialDelaySeconds: 5
  periodSeconds: 10

livenessProbe:
  exec:
    command:
      - /bin/sh
      - -c
      - pg_isready -U postgres
  initialDelaySeconds: 30
  periodSeconds: 10
```

### 3. Définir les ressources (requests/limits)

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### 4. Utiliser volumeClaimTemplates pour les PVC automatiques

```yaml
volumeClaimTemplates:
  - metadata:
      name: postgres-storage
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 10Gi
```

### 5. Bien gérer la terminaison des pods

```yaml
terminationGracePeriodSeconds: 30  # Temps pour graceful shutdown
```

### 6. Éviter les modifications manuelles des PVC

```bash
❌ MAUVAIS
kubectl delete pvc postgres-storage-0  # Données perdues!

✅ BON
kubectl patch pvc postgres-storage-0 -p '{"spec":{"resources":{"requests":{"storage":"20Gi"}}}}'
```

### 7. Utiliser les index ordinal en configurations

```yaml
# Dans une ConfigMap:
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-replica-config
data:
  replica-0.conf: |
    # postgres-0 est le primaire
    primary = true
  replica-1.conf: |
    # postgres-1 est une replica
    primary = false
    primary_conninfo = 'host=postgres-0.postgres...'
```

---

## Ressources complémentaires

- [Kubernetes StatefulSets Docs](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [Headless Services](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services)
- [PostgreSQL High Availability](https://www.postgresql.org/docs/current/different-replication-solutions.html)


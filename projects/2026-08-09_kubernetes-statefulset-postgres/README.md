# Kubernetes StatefulSet avec PostgreSQL et Persistent Volumes

## 📋 Description du projet

Ce projet explore le déploiement d'une **application stateful** (PostgreSQL) sur Kubernetes avec **persistance des données**. 

À la différence d'un `Deployment`, un `StatefulSet` garantit :
- Une **identité stable** pour chaque pod (nom prévisible)
- Un **ordre de démarrage/arrêt** contrôlé
- Un **accès stable** aux données persistent

Ce projet est idéal pour comprendre comment gérer les bases de données, les caches distribués ou toute application ayant un état local.

---

## 🎯 Objectifs d'apprentissage

1. **Différences Deployment vs StatefulSet** : quand utiliser chacun
2. **PersistentVolume (PV)** : provisionner du stockage
3. **PersistentVolumeClaim (PVC)** : demander du stockage
4. **Service headless** : communication stable avec les pods stateful
5. **Ordinal-based pod identity** : postgres-0, postgres-1, etc.
6. **Récupération après crash** : vérifier la persistance des données

---

## 📋 Pré-requis

- **Kubernetes cluster** (minikube, kind, ou cluster externe)
  ```bash
  kubectl cluster-info
  ```
- **kubectl** configuré et connecté au cluster
- Accès à un répertoire local pour les PersistentVolumes
- **psql** client PostgreSQL (optionnel, pour tester les requêtes)

---

## 🚀 Étapes de réalisation

### Étape 1 : Créer le namespace et les PersistentVolumes

```bash
kubectl apply -f 1-namespace.yaml
kubectl apply -f 2-persistent-volumes.yaml

# Vérifier les PV
kubectl get pv -n postgresql
```

### Étape 2 : Déployer le StatefulSet PostgreSQL

```bash
kubectl apply -f 3-statefulset-postgres.yaml

# Observer le déploiement (ordinal 0 avant 1)
kubectl get pods -n postgresql -w
```

### Étape 3 : Créer un service headless et un client

```bash
kubectl get svc -n postgresql

# Tester la connectivité
kubectl run -it --rm --image=postgres:latest \
  --restart=Never -n postgresql \
  -- psql -h postgres-0.postgres.postgresql.svc.cluster.local \
  -U postgres -c "SELECT version();"
```

### Étape 4 : Tester la persistance des données

```bash
# Insérer des données
bash scripts/insert-data.sh

# Vérifier les données
bash scripts/check-data.sh

# Supprimer le pod postgres-0
kubectl delete pod postgres-0 -n postgresql

# Attendre sa recréation et vérifier les données
bash scripts/check-data.sh
```

### Étape 5 : Nettoyer les ressources

```bash
kubectl delete -f 3-statefulset-postgres.yaml
kubectl delete -f 2-persistent-volumes.yaml
kubectl delete -f 1-namespace.yaml
```

---

## 📁 Structure des fichiers

```
2026-08-09_kubernetes-statefulset-postgres/
├── README.md                          # Ce fichier
├── 1-namespace.yaml                   # Namespace et ConfigMap
├── 2-persistent-volumes.yaml          # 2 PersistentVolumes locaux
├── 3-statefulset-postgres.yaml        # StatefulSet + Service headless + Secret
├── scripts/
│   ├── insert-data.sh                 # Insérer des données de test
│   ├── check-data.sh                  # Vérifier les données
│   └── cleanup.sh                     # Nettoyer les ressources
└── docs/
    └── concepts.md                    # Explications détaillées
```

---

## 🧠 Concepts clés expliqués

### StatefulSet vs Deployment

| Aspect | Deployment | StatefulSet |
|--------|-----------|-------------|
| **Pod names** | Aléatoires (app-xyz123) | Ordonnés (postgres-0, postgres-1) |
| **Ordre startup** | Parallèle | Séquentiel (0 → 1 → 2) |
| **PVC association** | Un PVC partagé | Un PVC par pod |
| **DNS stable** | DNS flottant | DNS stable par ordinal |
| **Use case** | Web apps, APIs | DB, cache, message queue |

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Kubernetes Cluster                     │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │           Namespace: postgresql                   │   │
│  │                                                   │   │
│  │  ┌──────────────────────────────────────────┐   │   │
│  │  │     StatefulSet: postgres (2 replicas)   │   │   │
│  │  │                                           │   │   │
│  │  │  ┌─────────────┐     ┌─────────────┐    │   │   │
│  │  │  │ postgres-0  │     │ postgres-1  │    │   │   │
│  │  │  └─────┬───────┘     └─────┬───────┘    │   │   │
│  │  │        │                    │            │   │   │
│  │  │  ┌─────▼──────┐     ┌──────▼─────┐    │   │   │
│  │  │  │  PVC-0     │     │  PVC-1     │    │   │   │
│  │  │  │ 10Gi       │     │  10Gi      │    │   │   │
│  │  │  └─────┬──────┘     └──────┬─────┘    │   │   │
│  │  └────────┼───────────────────┼──────────┘   │   │
│  │           │                    │              │   │
│  │  Service (headless)            │              │   │
│  │  postgres.postgresql.svc.cluster.local        │   │
│  │  postgres-0.postgres...        │              │   │
│  │  postgres-1.postgres...────────┘              │   │
│  └──────────────────────────────────────────────┘   │
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │     PersistentVolumes (Host Storage)         │   │
│  │                                               │   │
│  │  /data/pv-0  (10Gi)  ←→  PVC-0 → postgres-0  │   │
│  │  /data/pv-1  (10Gi)  ←→  PVC-1 → postgres-1  │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## ✅ Checkpoints d'apprentissage

- [ ] Comprendre la différence entre Deployment et StatefulSet
- [ ] Créer des PersistentVolumes et PersistentVolumeClaims
- [ ] Déployer un StatefulSet et observer l'ordre de création
- [ ] Configurer un service headless pour accès stable
- [ ] Insérer des données dans PostgreSQL via Kubernetes
- [ ] Supprimer un pod et vérifier que les données persistent
- [ ] Explorer les logs des pods stateful

---

## 🔍 Commandes utiles pendant le projet

```bash
# Observer le StatefulSet en temps réel
kubectl get statefulset -n postgresql -w

# Voir les logs d'un pod
kubectl logs postgres-0 -n postgresql

# Se connecter à un pod
kubectl exec -it postgres-0 -n postgresql -- psql -U postgres

# Vérifier les PVC
kubectl get pvc -n postgresql -o wide

# Détails sur un PV
kubectl describe pv pv-0

# Tester la DNS d'un pod
kubectl run -it --rm busybox --image=busybox --restart=Never -- nslookup postgres-0.postgres.postgresql.svc.cluster.local
```

---

## 📚 Ressources complémentaires

- [Kubernetes StatefulSets Official Docs](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Storage Classes and PVs](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Headless Services](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services)
- [PostgreSQL on Kubernetes Best Practices](https://www.postgresql.org/docs/current/intro-whatis.html)

---

## 💡 Variations et extensions possibles

- **Réplication PostgreSQL** : configurer une réplication primaire/replica
- **Backup automatique** : ajouter des CronJobs pour les sauvegardes
- **Monitoring** : intégrer Prometheus pour monitorer PostgreSQL
- **Failover** : implémenter une haute disponibilité avec Patroni
- **Multi-zone** : distribuer les PV across multiple nodes

---

## 📝 Notes de Jaouad

Ce projet couvre les **fondamentaux de la gestion d'état en Kubernetes**. C'est critique pour :
- Déployer des bases de données en production
- Comprendre quand utiliser StatefulSet vs Deployment
- Maîtriser le stockage persistant

Une fois maîtrisé, on peut explorer des solutions plus avancées comme **Helm charts** pour PostgreSQL (Bitnami) ou **Kubernetes Operators** pour une gestion plus sophistiquée.

---

**Durée estimée** : 1-2 heures  
**Niveau** : Intermédiaire  
**Prérequis** : Connaissance basique de Kubernetes, concepts de pods et services

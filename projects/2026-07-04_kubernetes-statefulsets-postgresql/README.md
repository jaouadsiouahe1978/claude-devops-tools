# Kubernetes StatefulSets avec PostgreSQL

## 📋 Description

Ce projet montre comment déployer une base de données PostgreSQL avec état persistent sur Kubernetes en utilisant les **StatefulSets**. Contrairement aux Deployments classiques, les StatefulSets garantissent :
- **Identités stables** : chaque Pod a un nom prévisible (e.g., postgres-0, postgres-1)
- **Stockage persistant** : les PersistentVolumeClaims sont liés à un Pod spécifique
- **Démarrage ordonné** : les Pods sont créés et supprimés de manière ordonnée
- **Haute disponibilité** : réplication PostgreSQL avec un leader et des replicas

## 🎯 Objectif d'apprentissage

À la fin de ce projet, tu sauras :
- Différencier Deployments et StatefulSets
- Créer une StatefulSet Kubernetes robuste
- Configurer PersistentVolumes et PersistentVolumeClaims
- Mettre en place PostgreSQL en mode réplication
- Accéder aux données via des Services headless
- Monitorer l'état de la base de données avec des Health Checks

## 🛠️ Technos utilisées

- **Kubernetes** 1.28+
- **PostgreSQL** 15
- **minikube** ou cluster K8s réel
- **kubectl**
- **YAML** pour les manifests

## 📦 Structure du projet

```
.
├── README.md
├── manifests/
│   ├── namespace.yaml
│   ├── pvc.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── statefulset.yaml
│   ├── service.yaml
│   └── kustomization.yaml
├── init-scripts/
│   └── init.sql
├── tests/
│   └── test-deployment.sh
└── monitoring/
    └── postgres-metrics.yaml
```

## 🚀 Étapes de réalisation

### 1. Prérequis
```bash
# Installer minikube
curl -Lo minikube https://github.com/kubernetes/minikube/releases/download/latest/minikube-linux-amd64
chmod +x minikube && sudo mv minikube /usr/local/bin/

# Démarrer le cluster
minikube start --cpus=4 --memory=4096

# Vérifier l'accès
kubectl cluster-info
```

### 2. Créer le namespace
```bash
kubectl apply -f manifests/namespace.yaml
```

### 3. Configurer les secrets et ConfigMaps
```bash
kubectl apply -f manifests/secret.yaml
kubectl apply -f manifests/configmap.yaml
```

### 4. Créer la StatefulSet PostgreSQL
```bash
kubectl apply -f manifests/statefulset.yaml
```

### 5. Créer les Services
```bash
kubectl apply -f manifests/service.yaml
```

### 6. Tester la déploiement
```bash
bash tests/test-deployment.sh
```

## 💡 Points clés à comprendre

### StatefulSet vs Deployment
| Aspect | Deployment | StatefulSet |
|--------|-----------|-----------|
| Identité | Aléatoire | Stable (postgres-0, postgres-1) |
| Stockage | Éphémère | Persistent |
| Ordre de déploiement | Parallèle | Séquentiel |
| Service | LoadBalancer/NodePort | Headless |

### Structure du manifest StatefulSet
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres  # ⚠️ CRUCIAL : Service headless
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:  # 🔑 Crée une PVC par Pod
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

### Accès au cluster PostgreSQL
```bash
# Connexion au Pod leader
kubectl exec -it postgres-0 -n devops -- psql -U postgres

# Vérifier la réplication
SELECT * FROM pg_stat_replication;

# Depuis un autre Pod (replica)
kubectl exec -it postgres-1 -n devops -- psql -U postgres -h postgres.devops.svc.cluster.local
```

## 🧪 Commandes utiles

```bash
# Vérifier l'état de la StatefulSet
kubectl get statefulset -n devops
kubectl describe statefulset postgres -n devops

# Voir les Pods et leurs noms stables
kubectl get pods -n devops -o wide

# Vérifier les PVCs
kubectl get pvc -n devops

# Voir les logs
kubectl logs postgres-0 -n devops
kubectl logs postgres-0 -n devops -f  # Tail

# Accéder au shell PostgreSQL
kubectl exec -it postgres-0 -n devops -- psql -U postgres

# Nettoyer
kubectl delete statefulset postgres -n devops
kubectl delete namespace devops
```

## 📊 Ce qu'on apprend

✅ Déployer des applications avec état sur Kubernetes  
✅ Utiliser PersistentVolumes et PersistentVolumeClaims  
✅ Configurer la réplication PostgreSQL  
✅ Utiliser les Services headless pour la découverte de services  
✅ Monitorer et déboguer une StatefulSet  
✅ Gérer le cycle de vie des données avec Kubernetes  

## 🔗 Ressources

- [StatefulSets Kubernetes Docs](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [PostgreSQL Replication](https://www.postgresql.org/docs/current/warm-standby.html)
- [PersistentVolumes Docs](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Headless Services](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services)

## ⏱️ Durée estimée

- Lecture et compréhension : 30 min
- Déploiement et tests : 45 min
- Exploration et debugging : 30 min
- **Total : ~1h45**

---

**Niveau** : Intermédiaire  
**Prérequis** : Notions de Kubernetes (Pods, Services, PVs)  
**Auteur** : Claude DevOps Training  
**Date** : 2026-07-04

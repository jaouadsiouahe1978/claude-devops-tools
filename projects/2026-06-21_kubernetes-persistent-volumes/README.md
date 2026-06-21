# Kubernetes avec Stockage Persistant

## Objectif
Créer un cluster Kubernetes local avec PostgreSQL et une application web qui persiste ses données. Apprendre à gérer les PersistentVolumes (PV), PersistentVolumeClaims (PVC), StatefulSets et Secrets.

## Pré-requis
- Docker installé
- kubectl installé
- minikube OU kind installé pour avoir un cluster local
- curl pour tester les endpoints

## Architecture
```
┌─────────────────────────────────────────┐
│      Kubernetes Cluster                 │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐    ┌──────────────┐  │
│  │   Web App    │←──→│  PostgreSQL  │  │
│  │  (Deployment)│    │ (StatefulSet)│  │
│  └──────────────┘    └──────────────┘  │
│                          │              │
│                     ┌────▼────┐         │
│                     │   PVC   │         │
│                     └────▲────┘         │
│                          │              │
│                     ┌────┴────┐         │
│                     │   PV    │         │
│                     └─────────┘         │
└─────────────────────────────────────────┘
```

## Étapes de réalisation

### 1. Démarrer le cluster local
```bash
minikube start --cpus=4 --memory=4096
# OU
kind create cluster --name devops-cluster
```

### 2. Appliquer les manifests Kubernetes
```bash
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-configmap.yaml
kubectl apply -f 02-secret.yaml
kubectl apply -f 03-pv.yaml
kubectl apply -f 04-pvc.yaml
kubectl apply -f 05-postgres-statefulset.yaml
kubectl apply -f 06-postgres-service.yaml
kubectl apply -f 07-webapp-deployment.yaml
kubectl apply -f 08-webapp-service.yaml
```

### 3. Vérifier le déploiement
```bash
kubectl get all -n devops
kubectl get pvc -n devops
kubectl get pods -n devops -w
```

### 4. Tester l'application
```bash
kubectl port-forward -n devops svc/webapp-service 8080:80 &
curl http://localhost:8080
curl http://localhost:8080/api/data
```

### 5. Vérifier la persistance
```bash
# Récupérer les données
curl http://localhost:8080/api/data

# Supprimer le pod PostgreSQL
kubectl delete pod -n devops postgres-0

# Vérifier que le pod redémarre et les données persistent
kubectl get pods -n devops -w
curl http://localhost:8080/api/data
```

## Ce qu'on apprend

1. **PersistentVolumes & PersistentVolumeClaims**
   - Différence entre PV et PVC
   - Gestion du cycle de vie du stockage
   - Reclaim policies

2. **StatefulSets vs Deployments**
   - Identités stables pour les pods (postgres-0, postgres-1, etc.)
   - Noms DNS prévisibles pour les services headless

3. **ConfigMaps & Secrets**
   - Stockage des configurations
   - Gestion sécurisée des mots de passe

4. **Services & Networking**
   - Service ClusterIP pour la communication inter-pods
   - Service LoadBalancer/NodePort pour l'accès externe

5. **LivenessProbe & ReadinessProbe**
   - Health checks pour les pods
   - Redémarrage automatique

## Fichiers fournis
- `00-namespace.yaml` : Namespace isolé
- `01-configmap.yaml` : Variables d'environnement
- `02-secret.yaml` : Mots de passe chiffrés
- `03-pv.yaml` : PersistentVolume (stockage)
- `04-pvc.yaml` : PersistentVolumeClaim (demande)
- `05-postgres-statefulset.yaml` : Base de données avec persistance
- `06-postgres-service.yaml` : Service pour accéder à PostgreSQL
- `07-webapp-deployment.yaml` : Application web Python/Flask
- `08-webapp-service.yaml` : Service pour accéder à l'app web
- `app.py` : Code de l'application web

## Nettoyage
```bash
kubectl delete namespace devops
minikube delete
# OU
kind delete cluster --name devops-cluster
```

## Ressources supplémentaires
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/
- https://kubernetes.io/docs/concepts/configuration/configmap/

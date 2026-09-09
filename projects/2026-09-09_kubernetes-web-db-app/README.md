# Kubernetes Web App + Database Deployment

## 📋 Description

Déployer une application web multi-tier complète sur Kubernetes avec :
- **Nginx** (frontend reverse proxy)
- **Node.js API** (application backend)
- **PostgreSQL** (base de données persistante)
- **ConfigMaps & Secrets** (gestion de la configuration)
- **Services** (exposition des applications)
- **Persistent Volumes** (stockage persistant)
- **Health checks** (readiness & liveness probes)

Cela vous enseigne les concepts fondamentaux de Kubernetes production.

## 🎯 Objectifs

1. Créer un namespace Kubernetes dédié
2. Déployer PostgreSQL en tant que StatefulSet avec stockage persistant
3. Déployer une API Node.js en tant que Deployment
4. Déployer Nginx en tant que reverse proxy
5. Gérer les secrets et configurations via ConfigMaps et Secrets
6. Tester les déploiements et la connectivité entre pods
7. Configurer les health checks (liveness & readiness probes)
8. Implémenter la scaling horizontal (HPA)

## 🛠️ Technologies

- **Kubernetes** 1.24+
- **Docker** (images containerisées)
- **Node.js** 18+ (API backend)
- **PostgreSQL** 14+ (base de données)
- **Nginx** 1.24+ (reverse proxy)
- **kubectl** (CLI Kubernetes)

## ⚙️ Prérequis

```bash
# Kubernetes cluster (minikube, Docker Desktop, ou cloud)
minikube start --cpus=4 --memory=4096 --driver=docker

# kubectl installé
kubectl version --client

# Docker (pour construire les images)
docker --version
```

## 📚 Ce qu'on apprend

✅ **Déploiements Kubernetes** : Deployments, StatefulSets, ReplicaSets
✅ **Gestion du stockage** : PersistentVolumes, PersistentVolumeClaims
✅ **Gestion de la configuration** : ConfigMaps, Secrets, env variables
✅ **Networking** : Services (ClusterIP, NodePort), Service Discovery
✅ **Santé des applications** : Liveness Probes, Readiness Probes
✅ **Scaling** : Horizontal Pod Autoscaler (HPA)
✅ **Monitoring** : Logs, Events, Resource metrics
✅ **Bonnes pratiques** : Resource limits, livenessProbes, securityContext

## 🚀 Étapes de déploiement

### 1. Créer le namespace

```bash
kubectl create namespace webapp
kubectl config set-context --current --namespace=webapp
```

### 2. Créer les Secrets pour les credentials

```bash
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=appuser \
  --from-literal=DB_PASSWORD=SecurePass123! \
  --from-literal=DB_NAME=appdb \
  -n webapp

kubectl create secret generic app-secrets \
  --from-literal=API_KEY=your-secret-api-key \
  --from-literal=JWT_SECRET=your-jwt-secret \
  -n webapp
```

### 3. Déployer PostgreSQL

```bash
kubectl apply -f manifests/postgres-pvc.yaml
kubectl apply -f manifests/postgres-deployment.yaml
kubectl apply -f manifests/postgres-service.yaml
```

Vérifier :
```bash
kubectl get pods -n webapp
kubectl logs -n webapp postgres-0
```

### 4. Déployer l'API Node.js

```bash
# D'abord, construire et pousser l'image Docker
docker build -t yourusername/node-api:1.0 ./app
docker push yourusername/node-api:1.0

# Ou utiliser l'image publique (modifier les manifests)
kubectl apply -f manifests/app-configmap.yaml
kubectl apply -f manifests/app-deployment.yaml
kubectl apply -f manifests/app-service.yaml
```

### 5. Déployer Nginx comme reverse proxy

```bash
kubectl apply -f manifests/nginx-configmap.yaml
kubectl apply -f manifests/nginx-deployment.yaml
kubectl apply -f manifests/nginx-service.yaml
```

### 6. Configurer l'autoscaling horizontal

```bash
kubectl apply -f manifests/hpa.yaml
```

### 7. Tester l'application

```bash
# Port-forward vers Nginx
kubectl port-forward svc/nginx-service 8080:80 -n webapp

# Faire des requêtes
curl http://localhost:8080/api/health
curl http://localhost:8080/api/users

# Vérifier les logs
kubectl logs -n webapp deployment/api-deployment
kubectl logs -n webapp deployment/nginx-deployment
```

### 8. Scaling et monitoring

```bash
# Voir les pods en cours d'exécution
kubectl get pods -n webapp -w

# Voir les ressources
kubectl top pods -n webapp
kubectl top nodes

# Vérifier les HPA
kubectl get hpa -n webapp -w

# Générer du trafic pour tester l'autoscaling
ab -n 10000 -c 100 http://localhost:8080/api/users
```

## 📁 Structure des fichiers

```
.
├── README.md
├── app/
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│   └── health-check.js
├── manifests/
│   ├── postgres-pvc.yaml          # PersistentVolumeClaim pour PostgreSQL
│   ├── postgres-deployment.yaml    # StatefulSet PostgreSQL
│   ├── postgres-service.yaml       # Service pour PostgreSQL
│   ├── app-configmap.yaml          # Configuration de l'app
│   ├── app-deployment.yaml         # Deployment Node.js
│   ├── app-service.yaml            # Service pour l'app
│   ├── nginx-configmap.yaml        # Config Nginx
│   ├── nginx-deployment.yaml       # Deployment Nginx
│   ├── nginx-service.yaml          # Service Nginx (LoadBalancer)
│   └── hpa.yaml                    # Horizontal Pod Autoscaler
└── scripts/
    ├── deploy.sh                   # Script de déploiement complet
    ├── test.sh                     # Tests d'application
    └── cleanup.sh                  # Nettoyage des ressources
```

## 🔍 Commandes utiles

```bash
# Voir tout ce qui est déployé
kubectl get all -n webapp

# Décrire un pod pour debug
kubectl describe pod <pod-name> -n webapp

# Voir les logs en temps réel
kubectl logs -f deployment/api-deployment -n webapp

# Se connecter au pod PostgreSQL
kubectl exec -it postgres-0 -n webapp -- psql -U appuser -d appdb

# Port-forward direct vers la base
kubectl port-forward svc/postgres-service 5432:5432 -n webapp

# Voir les events du cluster
kubectl get events -n webapp --sort-by='.lastTimestamp'

# Supprimer tout dans le namespace
kubectl delete namespace webapp
```

## 🐛 Dépannage

### Les pods ne démarrent pas ?
```bash
kubectl describe pod <pod-name> -n webapp
kubectl logs <pod-name> -n webapp
```

### L'app ne peut pas se connecter à la DB ?
```bash
# Vérifier que le service PostgreSQL est accessible
kubectl run -it --rm debug --image=busybox -n webapp -- sh
nslookup postgres-service
```

### Les volumes persistants ne se créent pas ?
```bash
kubectl get pvc -n webapp
kubectl get pv
# Vérifier la storage class
kubectl get storageclass
```

## 📊 Monitoring

Pour ajouter du monitoring :

```bash
# Installer Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

Ajouter les annotations Prometheus dans les manifests :
```yaml
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    prometheus.io/path: "/metrics"
```

## ✅ Checklist de succès

- [ ] Namespace créé
- [ ] PostgreSQL déployé et accessible
- [ ] Application Node.js déployée
- [ ] Nginx déployé et routeur le trafic correctement
- [ ] Services créés et découvrables
- [ ] Health checks configurés et actifs
- [ ] Logs visibles pour tous les pods
- [ ] HPA fonctionne correctement
- [ ] Test de scaling automatique réussi
- [ ] Tout est nettoyé après

## 💡 Points clés

1. **StatefulSets vs Deployments** : PostgreSQL utilisé StatefulSets pour la gestion stable des identités réseau et du stockage
2. **Persistent Volumes** : Les données de la DB survivent aux redémarrages des pods
3. **Service Discovery** : Les services Kubernetes permettent la communication entre pods via DNS
4. **Health Checks** : Readiness (quand accepter du trafic) et Liveness (quand redémarrer)
5. **Resource Limits** : Essentiels pour le scheduling et l'autoscaling
6. **Secrets vs ConfigMaps** : Secrets pour données sensibles, ConfigMaps pour config non-sensible

## 🎓 Ressources d'apprentissage

- [Kubernetes Official Docs - Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Kubernetes Official Docs - StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Kubernetes Official Docs - PersistentVolumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Kubernetes Official Docs - Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Kubernetes Official Docs - HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

## 📝 Auteur

Projet du jour DevOps - 2026-09-09

Créé pour l'apprentissage Kubernetes dans la formation DevOps/SRE à Grenoble.

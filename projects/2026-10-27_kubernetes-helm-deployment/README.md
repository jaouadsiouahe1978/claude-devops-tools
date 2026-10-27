# Kubernetes Helm Chart - Application Multi-Tier

## 📋 Description

Ce projet démontre comment containeriser une application multi-tier (Frontend, Backend, Database) et la déployer sur Kubernetes avec **Helm**, l'outil de gestion de packages pour Kubernetes.

**Niveau** : Débutant à Intermédiaire  
**Durée estimée** : 1 journée  
**Technos** : Kubernetes, Helm, Docker, YAML

## 🎯 Objectif

1. Créer une application simple multi-tier (API + Frontend)
2. Containeriser avec Docker
3. Créer un chart Helm réutilisable
4. Déployer sur un cluster Kubernetes local (Minikube)
5. Gérer les configurations par environnement (dev, staging, prod)

## 🛠️ Architecture

```
┌──────────────────────────────────────────────────┐
│         Kubernetes Cluster (Minikube)            │
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌─────────────────────────────────────────┐   │
│  │  Ingress (nginx)                        │   │
│  │  myapp.local                            │   │
│  └────────────┬────────────────────────────┘   │
│               │                                  │
│   ┌───────────┴────────────────────┐            │
│   │                                │            │
│  ┌─────────────┐          ┌──────────────┐     │
│  │  Frontend   │          │   API Server │     │
│  │  Service    │          │   Service    │     │
│  └──────┬──────┘          └──────┬───────┘     │
│         │                        │              │
│    ┌────┴────┐              ┌────┴────┐        │
│    │          │              │          │       │
│  Pod(s)     Pod(s)         Pod(s)    Pod(s)    │
│  Front      Front           API      API       │
│                                                 │
│  ┌──────────────────────────────────────────┐ │
│  │  PostgreSQL StatefulSet                  │ │
│  │  with PersistentVolume                   │ │
│  └──────────────────────────────────────────┘ │
│                                                  │
└──────────────────────────────────────────────────┘
```

## 📦 Pré-requis

- Docker installé
- Minikube ou un cluster Kubernetes local
- Helm 3+ installé
- kubectl configuré
- curl et jq pour les tests

### Installation rapide

```bash
# Minikube
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# kubectl
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl && sudo mv kubectl /usr/local/bin/
```

## 🚀 Étapes de réalisation

### 1. Démarrer le cluster Kubernetes

```bash
minikube start --cpus=4 --memory=4096
minikube addons enable ingress
```

### 2. Construire les images Docker

```bash
# Frontend (Nginx simple)
docker build -t myapp-frontend:1.0 ./docker/frontend

# API (Python Flask)
docker build -t myapp-api:1.0 ./docker/api

# Charger dans Minikube
minikube image load myapp-frontend:1.0
minikube image load myapp-api:1.0
```

### 3. Créer le chart Helm

```bash
cd helm-chart
helm create myapp
```

### 4. Configurer le chart

- Éditer `values.yaml` pour les paramètres globaux
- Créer `values-dev.yaml`, `values-staging.yaml`, `values-prod.yaml`
- Configurer les templates Kubernetes

### 5. Déployer avec Helm

```bash
# Installation
helm install myapp ./helm-chart -f helm-chart/values-dev.yaml

# Vérification
kubectl get all
kubectl get pods

# Accès
kubectl port-forward svc/myapp-api 5000:5000
curl http://localhost:5000/api/health
```

### 6. Tests et validation

```bash
# Tests de connectivité
./scripts/test-deployment.sh

# Logs
kubectl logs -f deployment/myapp-frontend

# Desceller
helm uninstall myapp
```

## 📚 Ce qu'on apprend

✅ **Kubernetes Basics** : Pods, Services, Deployments, StatefulSets, Ingress  
✅ **Helm Charts** : Structure, templates, values, dépendances  
✅ **Docker** : Multi-stage builds, optimisation d'images  
✅ **Configuration Management** : Secrets, ConfigMaps, environments  
✅ **Networking** : Services, DNS, Ingress rules  
✅ **Storage** : PersistentVolumes, PersistentVolumeClaims  
✅ **Scripting** : Bash pour l'automatisation  
✅ **Bonnes pratiques DevOps** : Infrastructure as Code, GitOps principles  

## 📝 Fichiers du projet

```
2026-10-27_kubernetes-helm-deployment/
├── README.md                    # Ce fichier
├── docker/
│   ├── frontend/
│   │   ├── Dockerfile
│   │   └── index.html
│   └── api/
│       ├── Dockerfile
│       ├── app.py
│       └── requirements.txt
├── helm-chart/
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-dev.yaml
│   ├── values-staging.yaml
│   ├── values-prod.yaml
│   └── templates/
│       ├── deployment-frontend.yaml
│       ├── deployment-api.yaml
│       ├── deployment-postgres.yaml
│       ├── service-frontend.yaml
│       ├── service-api.yaml
│       ├── service-postgres.yaml
│       ├── ingress.yaml
│       ├── configmap.yaml
│       ├── secret.yaml
│       └── NOTES.txt
├── manifests/
│   ├── namespace.yaml
│   ├── storage.yaml
│   └── rbac.yaml
└── scripts/
    ├── deploy.sh
    ├── test-deployment.sh
    ├── cleanup.sh
    └── port-forward.sh
```

## 🔧 Commandes utiles

```bash
# Vérifier l'état du déploiement
kubectl get pods -o wide
kubectl describe pod <pod-name>

# Logs
kubectl logs -f <pod-name>
kubectl logs -f deployment/<deployment-name>

# Accès interactif
kubectl exec -it <pod-name> -- /bin/bash

# Helm
helm list
helm status myapp
helm history myapp
helm rollback myapp 1
helm upgrade myapp ./helm-chart

# Debug
kubectl get events --sort-by='.lastTimestamp'
kubectl get persistentvolumes
kubectl get pvc
```

## 💡 Points clés

- **Helm templating** : Utilise `{{ .Values.* }}` pour paramétrer les manifests
- **Values files** : Permet de gérer différents envs facilement
- **Service Discovery** : Kubernetes DNS résout automatiquement les services
- **Rolling Updates** : Déploiements progressifs avec zéro downtime
- **Resource Limits** : Toujours définir requests/limits
- **Health Checks** : Liveness et readiness probes essentiels

## 📖 Ressources utiles

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Official Charts](https://helm.sh/docs/)
- [Helm Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Kubernetes Patterns](https://kubernetes.io/docs/concepts/configuration/overview/)

## 🎓 Améliorations possibles

- ✨ Ajouter des HPA (Horizontal Pod Autoscaler)
- ✨ Implémenter NetworkPolicies
- ✨ Ajouter un service mesh (Istio/Linkerd)
- ✨ Metrics avec Prometheus
- ✨ Logs avec ELK
- ✨ CI/CD automatisé avec ArgoCD

# Kubernetes Multi-Tier App Deployment

## 📋 Description

Déploiement d'une application multi-tier (frontend + API backend) sur Kubernetes avec :
- **Frontend** : Application Web simple (Nginx)
- **API** : Service backend Python/Flask
- **Networking** : Services Kubernetes et Ingress pour l'accès externe
- **Scaling** : Replicas et Horizontal Pod Autoscaler (HPA)
- **ConfigMaps & Secrets** : Gestion de la configuration
- **Environnements** : Overlays Kustomize pour dev/prod

## 🎯 Objectifs

- Comprendre les Deployments, Services et Ingress Kubernetes
- Gérer plusieurs environnements avec Kustomize
- Configurer et monitorer des pods
- Implémenter l'autoscaling
- Utiliser les healthchecks et resource limits

## 🛠 Technologies

- **Kubernetes** 1.24+
- **Kustomize** (packagé avec kubectl)
- **Docker** (pour les images)
- **Python/Flask** (backend simple)
- **Nginx** (frontend statique)
- **Minikube** ou tout cluster K8s

## 📦 Pré-requis

```bash
# Installer Minikube
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Ou utiliser kubectl avec un cluster existant
kubectl cluster-info
```

## 🚀 Étapes de réalisation

### 1. Créer les images Docker

```bash
# Backend API
cd app/api
docker build -t my-api:1.0 .
docker tag my-api:1.0 localhost:5000/my-api:1.0

# Frontend
cd ../frontend
docker build -t my-frontend:1.0 .
docker tag my-frontend:1.0 localhost:5000/my-frontend:1.0
```

### 2. Déployer sur Kubernetes

```bash
# Démarrer Minikube
minikube start

# Appliquer la config de base
kubectl apply -k k8s/overlays/dev

# Vérifier le déploiement
kubectl get all
kubectl get ingress
```

### 3. Tester l'application

```bash
# Port-forward vers l'API
kubectl port-forward svc/api 5000:80

# Port-forward vers le frontend
kubectl port-forward svc/frontend 3000:80

# Tester
curl http://localhost:5000/api/status
curl http://localhost:3000
```

### 4. Configurer Ingress

```bash
# Activer Ingress sur Minikube
minikube addons enable ingress

# Récupérer l'IP Minikube
minikube ip

# Ajouter à /etc/hosts
echo "$(minikube ip) myapp.local" | sudo tee -a /etc/hosts

# Accéder via Ingress
curl http://myapp.local
```

### 5. Tester l'autoscaling

```bash
# Activer les métriques
minikube addons enable metrics-server

# Générer une charge
kubectl run -it --rm load-generator --image=busybox /bin/sh
# Dans le container : while sleep 0.01; do wget -q -O- http://api/api/status; done

# Observer l'autoscaling
kubectl get hpa -w
kubectl top pods
```

### 6. Déployer en environnement de prod

```bash
# Appliquer la config prod avec ressources augmentées
kubectl apply -k k8s/overlays/prod
```

## 📚 Fichiers du projet

```
.
├── README.md                                 # Ce fichier
├── Makefile                                  # Cibles de build/déploiement
├── app/
│   ├── api/                                  # Backend Python/Flask
│   │   ├── Dockerfile
│   │   ├── app.py
│   │   └── requirements.txt
│   └── frontend/                             # Frontend Nginx
│       ├── Dockerfile
│       ├── index.html
│       └── default.conf
└── k8s/
    ├── base/                                 # Configuration de base
    │   ├── kustomization.yaml
    │   ├── api-deployment.yaml
    │   ├── api-service.yaml
    │   ├── frontend-deployment.yaml
    │   ├── frontend-service.yaml
    │   ├── api-configmap.yaml
    │   ├── api-hpa.yaml
    │   └── ingress.yaml
    └── overlays/
        ├── dev/                              # Environnement développement
        │   ├── kustomization.yaml
        │   └── patches/
        ├── prod/                             # Environnement production
        │   ├── kustomization.yaml
        │   └── patches/
```

## 💡 Ce qu'on apprend

1. **Kubernetes Core** : Déploiements, Pods, Services, Namespaces
2. **Networking** : Ingress, Service discovery, Port forwarding
3. **Configuration** : ConfigMaps, Secrets, Variables d'environnement
4. **Scaling** : Replicas, HPA, Resource requests/limits
5. **GitOps prep** : Kustomize et structure pour CI/CD
6. **Monitoring** : Health checks, logs, métriques basiques

## 🔧 Commandes utiles

```bash
# Voir l'état du cluster
kubectl cluster-info
kubectl get nodes
kubectl get all

# Logs et debugging
kubectl logs deployment/api
kubectl describe pod <pod-name>
kubectl exec -it <pod-name> -- /bin/bash

# Mise à jour du déploiement
kubectl set image deployment/api api=my-api:2.0

# Rollback si besoin
kubectl rollout undo deployment/api

# Supprimer tout
kubectl delete -k k8s/overlays/dev
```

## 📖 Ressources

- [Kubernetes Docs - Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Kubernetes Docs - Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Kustomize Documentation](https://kustomize.io/)
- [Minikube Handbook](https://minikube.sigs.k8s.io/)

---

**Créé le** : 2026-05-07  
**Niveau** : Intermédiaire (Post-Docker)  
**Durée estimée** : 1 journée

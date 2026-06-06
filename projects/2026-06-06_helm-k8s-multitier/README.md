# Projet : Déployer une App Multi-Tier sur Kubernetes avec Helm

## 📋 Description
Création et déploiement d'une application multi-niveaux (Frontend + Backend API + PostgreSQL) sur Kubernetes en utilisant **Helm charts** pour la gestion des configurations et des versions.

### Objectifs
- ✅ Créer une architecture 3-tiers (frontend, backend, base de données)
- ✅ Packager l'app avec Helm (IaC pour Kubernetes)
- ✅ Gérer plusieurs environnements (dev, prod) via values.yaml
- ✅ Configurer les services, ingress, et persistence volumes
- ✅ Déployer et mettre à jour l'app avec helm upgrade

## 🛠️ Technologies
- **Kubernetes** : Orchestration de conteneurs
- **Helm** : Package manager pour Kubernetes
- **Docker** : Containerization (images pour frontend/backend)
- **PostgreSQL** : Base de données persistante
- **YAML** : Configuration Infrastructure as Code

## 📦 Structure du Projet
```
.
├── docker/                      # Images Docker
│   ├── frontend/                # React/Node app
│   │   ├── Dockerfile
│   │   └── app.js
│   └── backend/                 # Python API
│       ├── Dockerfile
│       └── app.py
├── helm-chart/                  # Helm chart complet
│   ├── Chart.yaml               # Métadonnées du chart
│   ├── values.yaml              # Configuration par défaut
│   ├── values-dev.yaml          # Overrides pour dev
│   ├── values-prod.yaml         # Overrides pour prod
│   └── templates/
│       ├── namespace.yaml       # Namespace K8s
│       ├── frontend-deployment.yaml
│       ├── backend-deployment.yaml
│       ├── postgres-deployment.yaml
│       ├── services.yaml        # Services ClusterIP
│       ├── ingress.yaml         # Ingress controller
│       ├── configmap.yaml       # Configuration
│       ├── secret.yaml          # Secrets (DB credentials)
│       └── pvc.yaml             # PersistentVolumeClaim
├── k8s-manifests/               # Manifests standards (référence)
└── README.md
```

## 🚀 Pré-requis
- Kubernetes cluster (local: minikube, kind, ou cloud: EKS, GKE, AKS)
- Helm 3.x installé : `brew install helm` ou `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash`
- kubectl configuré : `kubectl config current-context`
- Docker (optionnel, pour builder les images)

```bash
# Vérifier les pré-requis
kubectl version --client
helm version
kubectl get nodes  # Voir les nœuds du cluster
```

## 📝 Étapes de Réalisation

### Étape 1 : Créer la structure Helm
```bash
cd helm-chart
helm create . --name app-multitier
```

### Étape 2 : Construire les images Docker
```bash
# Frontend (Node.js simple server)
docker build -t app-frontend:1.0 docker/frontend/

# Backend (Python Flask API)
docker build -t app-backend:1.0 docker/backend/
```

### Étape 3 : Configurer le Helm Chart
- Éditer `Chart.yaml` : nom, version, description
- Éditer `values.yaml` : replica counts, image tags, ressources
- Créer les templates Kubernetes

### Étape 4 : Déployer sur Kubernetes
```bash
# Dry-run pour valider
helm install app-multitier ./helm-chart --namespace app-system --create-namespace --dry-run --debug

# Déploiement réel
helm install app-multitier ./helm-chart --namespace app-system --create-namespace

# Vérifier
kubectl get all -n app-system
kubectl logs -n app-system deployment/app-multitier-backend
```

### Étape 5 : Gérer les environnements
```bash
# Dev (replicas réduits, resources limitées)
helm upgrade app-multitier ./helm-chart \
  --namespace app-dev \
  --create-namespace \
  -f helm-chart/values-dev.yaml

# Prod (haute dispo, resources optimisées)
helm upgrade app-multitier ./helm-chart \
  --namespace app-prod \
  --create-namespace \
  -f helm-chart/values-prod.yaml
```

### Étape 6 : Monitoring et Troubleshooting
```bash
# Lister les releases
helm list -n app-system

# Voir l'historique des versions
helm history app-multitier -n app-system

# Rollback à une version précédente
helm rollback app-multitier 1 -n app-system

# Voir les ressources créées
kubectl describe deployment -n app-system
kubectl get svc -n app-system
kubectl get pvc -n app-system
```

## 📚 Ce qu'on Apprend

### Concepts Helm
- **Chart** : Template Kubernetes packagé et versionné
- **Release** : Instance d'un chart déployé
- **values.yaml** : Configuration paramétrisée (templating)
- **Helm Hooks** : Exécuter des actions avant/après déploiement
- **Chart Dependencies** : Réutiliser d'autres charts (postgres, nginx, etc.)

### Kubernetes Concepts
- **Deployment** : Réplication et mise à jour de pods
- **Service** : Exposition interne/externe des apps
- **Ingress** : Routage HTTP/HTTPS
- **ConfigMap** : Configuration externalisée
- **Secret** : Gestion des credentials
- **PersistentVolume/PVC** : Stockage persistant pour DB
- **Namespace** : Isolation logique des ressources

### DevOps Best Practices
- **Infrastructure as Code (IaC)** : Configuration versionnée
- **Multi-environment management** : dev/staging/prod
- **Rolling updates** : Zéro-downtime deployments
- **Health checks** : Liveness et readiness probes
- **Resource management** : CPU/Memory limits et requests

## 🎯 Exercices Bonus
1. **Helm Hooks** : Ajouter un job de migration DB avant le déploiement
2. **Secrets Management** : Utiliser Sealed Secrets ou External Secrets Operator
3. **Observability** : Ajouter Prometheus annotations pour monitoring
4. **Helm Tests** : Créer un test pour vérifier que l'app répond
5. **ArgoCD** : GitOps deployment avec ArgoCD

## 🔗 Ressources
- [Helm Official Docs](https://helm.sh/docs/)
- [Kubernetes YAML Reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Kubernetes Patterns](https://kubernetes.io/docs/concepts/configuration/overview/)

## ✅ Checklist du Jour
- [ ] Créer le Helm chart avec les templates corrects
- [ ] Configurer values.yaml pour dev et prod
- [ ] Construire et pusher les images Docker
- [ ] Déployer sur un cluster local (minikube/kind)
- [ ] Vérifier les pods, services, et ingress
- [ ] Tester une mise à jour (helm upgrade)
- [ ] Documenter les commandes kubectl/helm utilisées

---
**Durée estimée** : 6-8h | **Niveau** : Intermédiaire | **Thème** : Kubernetes + Helm

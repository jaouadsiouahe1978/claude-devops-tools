# Kubernetes Local Cluster avec Helm Chart - Déploiement Multi-Tier

## Description

Déployer une application multi-tier (frontend + backend API + base de données) sur un cluster Kubernetes local en utilisant **Helm** pour la gestion des configurations et des releases.

### Objectifs pédagogiques
- Comprendre la structure d'un **Helm Chart**
- Packager une application Kubernetes complète avec Helm
- Déployer sur **Minikube** ou **Kind** (cluster local)
- Gérer les templates, les valeurs et les dépendances Helm
- Exposer les services (Ingress)
- Utiliser les **ConfigMaps** et **Secrets** pour les configurations

## Technos utilisées

| Technologie | Rôle |
|---|---|
| **Kubernetes** | Orchestration des conteneurs |
| **Helm 3** | Package manager / templating |
| **Minikube / Kind** | Cluster local |
| **Docker** | Images de conteneurs |
| **Ingress** | Routage HTTP(S) |
| **ConfigMap/Secrets** | Gestion des configurations |

## Architecture

```
┌─────────────────────────────────────────┐
│       Cluster Kubernetes (Minikube)     │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   Ingress (nginx-controller)     │  │
│  │   web.local -> Service Frontend  │  │
│  └──────────────────────────────────┘  │
│           │                             │
│  ┌────────▼──────────────────────────┐  │
│  │  Frontend Pod (Nginx)             │  │
│  │  app: web-frontend                │  │
│  │  replicas: 2                      │  │
│  └───────────┬──────────────────────┘  │
│              │                          │
│  ┌───────────▼──────────────────────┐  │
│  │  Backend API Pod (Node.js/Python)│  │
│  │  app: api-backend                │  │
│  │  replicas: 2                      │  │
│  │  env: ConfigMap + Secret          │  │
│  └───────────┬──────────────────────┘  │
│              │                          │
│  ┌───────────▼──────────────────────┐  │
│  │  PostgreSQL StatefulSet          │  │
│  │  PersistentVolume: 10Gi           │  │
│  └──────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

## Pré-requis

```bash
# Installation sur Linux/Mac
brew install helm minikube kubectl docker

# Ou avec apt (Ubuntu/Debian)
sudo apt-get install -y curl
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -Lo minikube https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
chmod +x minikube && sudo mv minikube /usr/local/bin/

# Démarrer Minikube
minikube start --cpus=2 --memory=3072
eval $(minikube docker-env)  # Utiliser Docker de Minikube
```

## Étapes de réalisation

### 1. Créer la structure Helm Chart

```bash
helm create myapp
# Structure générée :
# myapp/
#   ├── Chart.yaml
#   ├── values.yaml
#   ├── templates/
#   │   ├── deployment.yaml
#   │   ├── service.yaml
#   │   ├── ingress.yaml
#   │   ├── configmap.yaml
#   │   ├── secret.yaml
#   │   └── _helpers.tpl
```

### 2. Construire les images Docker

```bash
# Frontend (Nginx)
docker build -t myapp/frontend:1.0 ./docker/frontend/

# Backend (API)
docker build -t myapp/backend:1.0 ./docker/backend/

# Charger dans Minikube
minikube image load myapp/frontend:1.0
minikube image load myapp/backend:1.0
```

### 3. Configurer les templates Helm

Modifier `values.yaml` pour définir :
- Images Docker (nom, tag, pull policy)
- Nombre de replicas
- Limites de ressources (CPU, mémoire)
- Variables d'environnement
- Secrets (DB password)
- Ingress hostname

### 4. Déployer avec Helm

```bash
# Install
helm install myapp ./myapp

# Vérifier
helm list
kubectl get all

# Logs
kubectl logs -f deployment/myapp-frontend
```

### 5. Accéder à l'application

```bash
# Port-forward ou Ingress
kubectl port-forward svc/myapp-frontend 8080:80
# Puis : http://localhost:8080
```

## Fichiers du projet

- `helm/` - Helm Chart complet (templates + values)
- `docker/` - Dockerfiles pour chaque service
- `docker-compose.yml` - Alternative pour tester localement
- `deploy.sh` - Script d'installation automatique

## Ce qu'on apprend

✅ **Kubernetes fundamentals** : Pods, Deployments, Services, StatefulSets  
✅ **Helm templating** : Chart structure, values, helpers, conditionals  
✅ **Package management** : Dépendances, versions, releases  
✅ **Gestion d'état** : ConfigMaps, Secrets, volumes persistants  
✅ **Networking** : Services, Ingress, DNS  
✅ **Best practices** : Labels, selectors, resource limits  

## Commandes utiles

```bash
# Vérifier le template rendu
helm template myapp ./myapp

# Dry-run avant install
helm install myapp ./myapp --dry-run --debug

# Upgrade vers une nouvelle version
helm upgrade myapp ./myapp --values custom-values.yaml

# Rollback
helm rollback myapp 1

# Uninstall
helm uninstall myapp
```

## Temps estimé : 2-3 heures

- Setup Minikube + Helm : 20 min
- Créer Helm Chart : 20 min
- Dockerfiles pour services : 30 min
- Configurer templates + values : 30 min
- Déployer et tester : 20 min

## Notes

- Ce projet utilise des images légères (nginx, alpine)
- PostgreSQL inclus comme dépendance Helm optionnelle
- Ingress nécessite `minikube addons enable ingress`
- Adaptable à Kind, EKS, AKS, GKE pour la prod

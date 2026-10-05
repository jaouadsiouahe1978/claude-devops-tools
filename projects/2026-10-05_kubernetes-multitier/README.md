# Kubernetes Multi-Tier Application Deployment

## Objectif
Déployer une application web multi-tier complète (Frontend + API Backend + Database) sur Kubernetes avec gestion des configurations, persistance des données et accès externe.

## Technologies
- **Kubernetes** (minikube ou cluster local)
- **Docker** (pour les images)
- **MySQL** (base de données)
- **Nginx** (frontend/reverse proxy)
- **Python Flask** (API backend)

## Architecture

```
┌─────────────────────────────────────────┐
│     Kubernetes Cluster (minikube)       │
├─────────────────────────────────────────┤
│ ┌──────────────┐                        │
│ │ Nginx Pod    │ → Service ClusterIP   │
│ │ (Frontend)   │                        │
│ └──────────────┘                        │
│ ┌──────────────┐                        │
│ │ Flask Pod    │ → Service ClusterIP   │
│ │ (API)        │                        │
│ └──────────────┘                        │
│ ┌──────────────┐                        │
│ │ MySQL Pod    │ → Service ClusterIP   │
│ │ (Database)   │ + PersistentVolume    │
│ └──────────────┘                        │
│                                         │
│ Ingress → nginx Service (NodePort)     │
└─────────────────────────────────────────┘
```

## Prérequis
- minikube installé et démarré : `minikube start`
- kubectl configuré
- Docker (pour builder les images)

## Étapes de réalisation

### 1. Préparation des images Docker
- Créer une image Nginx pour le frontend (HTML statique)
- Créer une image Flask pour l'API backend
- Utiliser une image MySQL officielle

### 2. Création des manifests Kubernetes
- **Namespace** : `app-namespace` (isoler l'app)
- **ConfigMap** : pour les variables d'environnement
- **Secret** : pour les credentials (password DB)
- **PersistentVolume** et **PersistentVolumeClaim** : pour MySQL
- **Deployments** : pour chaque service (3 au total)
- **Services** : ClusterIP pour MySQL et Flask, NodePort pour Nginx
- **Ingress** : accès externe à l'application

### 3. Déploiement
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/flask-deployment.yaml
kubectl apply -f k8s/nginx-deployment.yaml
kubectl apply -f k8s/services.yaml
kubectl apply -f k8s/ingress.yaml
```

### 4. Vérification et accès
```bash
kubectl get all -n app-namespace
minikube service nginx-service -n app-namespace  # URL d'accès
kubectl logs -f deployment/flask-app -n app-namespace
```

## Ce qu'on apprend

✅ **Concepts Kubernetes** :
- Pods, Deployments, Services
- ConfigMaps et Secrets pour la configuration
- PersistentVolumes pour la persistance des données
- Namespaces pour l'isolation

✅ **Patterns DevOps** :
- Orchestration de conteneurs multi-services
- Gestion des dépendances entre services
- Monitoring basique avec logs et events
- Scalabilité (réplicas)

✅ **Pratiques** :
- Structure des manifests YAML
- Health checks (liveness/readiness probes)
- Resource limits
- Troubleshooting avec kubectl

## Fichiers du projet
```
2026-10-05_kubernetes-multitier/
├── README.md (ce fichier)
├── docker/
│   ├── Dockerfile.nginx
│   ├── Dockerfile.flask
│   └── app/
│       ├── index.html (frontend)
│       ├── app.py (API Flask)
│       └── requirements.txt
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── pvc.yaml
│   ├── mysql-deployment.yaml
│   ├── flask-deployment.yaml
│   ├── nginx-deployment.yaml
│   ├── services.yaml
│   └── ingress.yaml
└── scripts/
    ├── build-images.sh
    ├── deploy.sh
    └── cleanup.sh
```

## Durée estimée
**6-8 heures** (débutant) : construction progressive avec explications  
**2-3 heures** (intermédiaire) : utilisation des scripts prêts à l'emploi

## Bonus (optionnel)
- Ajouter des health checks (liveness/readiness probes)
- Autoscaling horizontal (HPA)
- Monitoring avec Prometheus
- Network policies pour la sécurité réseau

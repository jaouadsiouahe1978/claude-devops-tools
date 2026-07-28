# Kubernetes Helm + StatefulSets : Déploiement Multi-Services

## Description

Ce projet démontre comment déployer une application multi-services sur Kubernetes avec Helm pour gérer les configurations et StatefulSets pour les services avec état (base de données, cache). 

**Cas d'usage** : Stack complète avec PostgreSQL, Redis et une application backend.

## Technos Utilisées

- **Kubernetes** : Orchestration des conteneurs
- **Helm** : Gestionnaire de packages pour Kubernetes
- **StatefulSets** : Pour gérer les services avec état (persistance)
- **Deployments** : Pour les applications stateless
- **PersistentVolumes** : Stockage persistant pour les données
- **Services** : Exposition interne/externe des services
- **ConfigMaps & Secrets** : Gestion des configurations et secrets

## Prérequis

- `kubectl` configuré pour accéder à un cluster K8s (local ou distant)
- `helm` installé (v3.x+)
- Cluster Kubernetes disponible (minikube, k3s, ou cloud provider)

## Architecture

```
├── app-backend/          # App stateless (Deployment)
├── postgres-db/          # Base de données (StatefulSet)
├── redis-cache/          # Cache (StatefulSet)
└── Helm Chart personnalisée
```

## Étapes de Réalisation

### 1. Initialiser le Helm Chart

```bash
helm create multi-stack-chart
cd multi-stack-chart
```

### 2. Configurer les StatefulSets pour PostgreSQL

- Replicas : 1
- Persistent Volume : 10Gi
- Port : 5432

### 3. Configurer StatefulSet pour Redis

- Replicas : 1
- Persistent Volume : 5Gi
- Port : 6379

### 4. Configurer Deployment pour l'Application

- Replicas : 3 (pour haute disponibilité)
- Image : node.js ou Python
- Liaisons aux services PostgreSQL et Redis

### 5. Tester le Déploiement

```bash
# Validation du chart
helm lint ./multi-stack-chart

# Installation
helm install my-stack ./multi-stack-chart

# Vérifier le statut
kubectl get all
kubectl logs -f deployment/app-backend-deployment
```

## Ce Qu'on Apprend

✅ **StatefulSets vs Deployments** : Quand utiliser chacun, gestion des identités stables  
✅ **Persistent Volumes** : Stockage durable pour bases de données et caches  
✅ **Helm templating** : Réutilisabilité et paramétrage des configurations K8s  
✅ **Services DNS** : Communication inter-pods avec headless services  
✅ **Livenessprobes & Readinesprobes** : Santé des conteneurs  
✅ **Resource requests/limits** : Gestion des ressources CPU/Mémoire  

## Commandes Utiles

```bash
# Port forwarding pour accéder à PostgreSQL
kubectl port-forward svc/postgres-service 5432:5432

# Accéder à Redis
kubectl port-forward svc/redis-service 6379:6379

# Logs d'une app
kubectl logs -f deployment/app-backend-deployment

# Exécuter une commande dans un pod
kubectl exec -it postgres-0 -- psql -U postgres

# Monitoring des ressources
kubectl top nodes
kubectl top pods
```

## Fichiers du Projet

- `Dockerfile` : Image de l'application backend
- `Helm/Chart.yaml` : Metadata du Helm chart
- `Helm/values.yaml` : Valeurs par défaut paramétrables
- `Helm/templates/` : Templates K8s (deployment, statefulset, services, etc.)
- `docker-compose-dev.yml` : Version locale pour dev/test rapide

## Notes

- Ce projet est optimisé pour un apprentissage progressif
- Le stockage est local (minikube) - adapter pour production
- À explorer : Operators, Helm hooks, tests avec Helm Test


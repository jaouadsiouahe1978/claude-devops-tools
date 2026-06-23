# Kubernetes + Helm : Déploiement d'une App Multi-Service

## 📋 Objectif
Apprendre à packager et déployer une application multi-service (API + Database + Cache) sur Kubernetes using Helm Charts.

## 🎯 Ce qu'on apprend
- ✅ Créer et structurer un Helm Chart
- ✅ Déployer une application multi-tier avec des dépendances
- ✅ Gérer les configs avec `values.yaml` et les templates
- ✅ Utiliser les Helm Hooks pour les migrations DB
- ✅ Gérer les volumes persistants pour la base de données
- ✅ Implémenter les probes de santé (liveness/readiness)
- ✅ Déploiement avec `helm install` et gestion des releases

## 🛠️ Technos utilisées
- **Kubernetes** : Orchestration de conteneurs
- **Helm** : Package manager pour K8s
- **Kind/Minikube** : K8s local (pour tests)
- **Docker** : Images conteneur
- **PostgreSQL** : Base de données persistante
- **Redis** : Cache en mémoire

## 📦 Structure du projet

```
helm-chart/
├── Chart.yaml              # Metadata du chart
├── values.yaml             # Valeurs par défaut
├── values-staging.yaml     # Valeurs pour staging
├── values-prod.yaml        # Valeurs pour production
├── templates/
│   ├── deployment-api.yaml      # Deploy de l'API
│   ├── deployment-postgres.yaml  # Deploy de PostgreSQL
│   ├── deployment-redis.yaml     # Deploy de Redis
│   ├── service-api.yaml          # Service pour l'API
│   ├── service-postgres.yaml      # Service pour DB
│   ├── service-redis.yaml         # Service pour cache
│   ├── configmap.yaml            # Variables d'env
│   ├── secret.yaml               # Secrets (DB password)
│   ├── pvc-postgres.yaml          # Persistent Volume Claim
│   ├── ingress.yaml              # Ingress pour l'API
│   ├── hpa.yaml                  # Auto-scaling horizontal
│   └── _helpers.tpl              # Templates helpers

k8s-manifests/
├── 01-namespace.yaml             # Namespace dédié
├── 02-storage-class.yaml         # Classe de stockage
├── 03-helm-values-default.yaml   # Valeurs Helm default

scripts/
├── install.sh                # Script d'installation du chart
├── upgrade.sh                # Script de mise à jour
├── rollback.sh               # Script de rollback
├── cleanup.sh                # Script de suppression
└── test-deployment.sh        # Tests d'intégration
```

## ⚙️ Prérequis
- Kubernetes cluster disponible (Minikube ou Kind)
- `kubectl` configuré
- `helm` CLI (v3+)
- `docker` pour build des images

## 🚀 Étapes de réalisation

### 1. Lancer un cluster Kubernetes local
```bash
# Avec Kind
kind create cluster --name devops-lab

# Ou Minikube
minikube start --cpus=4 --memory=4096
```

### 2. Créer le Helm Chart
```bash
cd helm-chart
helm create . --dry-run --debug
```

### 3. Installer le chart
```bash
cd ../scripts
./install.sh
```

### 4. Vérifier le déploiement
```bash
kubectl get pods -n devops-app
kubectl get svc -n devops-app
kubectl logs -f deploy/api-deployment -n devops-app
```

### 5. Accéder à l'application
```bash
# Port-forward vers l'API
kubectl port-forward svc/api-service 8080:8080 -n devops-app

# Puis : curl http://localhost:8080/health
```

### 6. Tester les mises à jour
```bash
# Modifier values.yaml (ex: réplicas, image)
./upgrade.sh
```

### 7. Rollback en cas d'erreur
```bash
./rollback.sh
```

## 📚 Concepts clés couverts

| Concept | Fichier | Explication |
|---------|---------|------------|
| **Chart Structure** | Chart.yaml, values.yaml | Comment Helm organise les configs |
| **Templates** | templates/*.yaml | Génération dynamique de manifests |
| **ConfigMaps** | configmap.yaml | Variables d'env et configs |
| **Secrets** | secret.yaml | Données sensibles (passwords) |
| **Deployments** | deployment-*.yaml | Gestion des replicas et rollouts |
| **Services** | service-*.yaml | Networking et service discovery |
| **PVC** | pvc-postgres.yaml | Persistance de données |
| **Ingress** | ingress.yaml | Routage HTTP/HTTPS |
| **HPA** | hpa.yaml | Auto-scaling basé sur CPU/Memory |
| **Probes** | deployment-api.yaml | Health checks (liveness/readiness) |

## ✨ Cas d'usage pratiques

1. **Environnements multiples** : values-staging.yaml vs values-prod.yaml
2. **Gestion des versions** : helm rollback, helm history
3. **Scaling** : modifier `replicaCount` dans values.yaml
4. **Migrations DB** : Helm Hooks (pre-install, post-install)
5. **Blue-Green Deployment** : Déployer deux versions en parallèle

## 🧪 Tests d'intégration
```bash
./scripts/test-deployment.sh
```

Vérifie :
- ✅ Pods en running
- ✅ Services accessibles
- ✅ Database connectée
- ✅ Redis accessible
- ✅ API répond sur /health

## 📖 Ressources complémentaires

- [Helm Official Docs](https://helm.sh/docs/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Package Management with Helm](https://helm.sh/docs/intro/using_helm/)

## 🎓 Ce que Jaouad retiendra

Après ce projet, tu sauras :
- Packager une app K8s complète avec Helm
- Gérer les configs multi-environnements
- Deployer, upgrade et rollback une application
- Configurer la persistance et le networking
- Implémenter l'auto-scaling et les health checks
- Automatiser les déploiements avec des scripts

C'est la base fondamentale pour tout SRE/DevOps qui gère Kubernetes en production ! 🚀

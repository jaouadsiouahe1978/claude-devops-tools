# 📦 Kubernetes Helm Charts - Web Application Deployment

## Objectif
Créer et déployer une application multi-tier complète (Frontend + Backend + Database) en utilisant **Helm 3** — le package manager de Kubernetes. Maîtriser la création, templating, et gestion des déploiements Helm.

## Technologies
- **Kubernetes** : Orchestration de conteneurs
- **Helm 3** : Package manager et templating
- **Docker** : Images des applications
- **Values.yaml** : Configuration déclarative
- **Templates** : Manifestes K8s générés dynamiquement

## Structure du Projet
```
2026-09-22_kubernetes-helm-charts/
├── README.md
├── my-app-chart/
│   ├── Chart.yaml              # Métadonnées du chart
│   ├── values.yaml             # Valeurs par défaut
│   ├── values-dev.yaml         # Surcharge environnement DEV
│   ├── values-prod.yaml        # Surcharge environnement PROD
│   ├── templates/
│   │   ├── _helpers.tpl        # Fonctions Helm réutilisables
│   │   ├── namespace.yaml      # Namespace
│   │   ├── backend-deployment.yaml
│   │   ├── backend-service.yaml
│   │   ├── frontend-deployment.yaml
│   │   ├── frontend-service.yaml
│   │   ├── database-deployment.yaml
│   │   ├── database-pvc.yaml   # Persistent Volume Claim
│   │   ├── configmap.yaml      # Configuration
│   │   ├── secrets.yaml        # Secrets (base64)
│   │   └── ingress.yaml        # Ingress HTTP
│   └── charts/                 # Dépendances (sub-charts)
└── scripts/
    ├── install.sh              # Installer le chart
    ├── upgrade.sh              # Mettre à jour le chart
    ├── uninstall.sh            # Supprimer le chart
    └── validate.sh             # Valider la syntaxe
```

## Pré-requis
- Kubernetes v1.24+ (minikube/kind/kubeadm/EKS/AKS/GKE)
- Helm 3.0+ (`helm version`)
- Docker (pour les images)
- kubectl configuré

## Étapes de Réalisation

### 1️⃣ Initialisation du Chart Helm
```bash
cd my-app-chart
helm create my-app-chart
# Ou manuellement :
mkdir -p my-app-chart/{templates,charts}
```

### 2️⃣ Créer les Fichiers de Base
- `Chart.yaml` : Nom, version, description du chart
- `values.yaml` : Configuration par défaut (replicas, images, ressources)
- `values-dev.yaml` / `values-prod.yaml` : Overrides pour chaque env

### 3️⃣ Créer les Templates Kubernetes
- **Backend Deployment** : API server avec replicas, resources, probes
- **Backend Service** : ClusterIP pour la communication interne
- **Frontend Deployment** : Application web
- **Frontend Service** : LoadBalancer/NodePort pour exposer
- **Database** : StatefulSet ou Deployment avec volumes persistants
- **ConfigMap** : Variables d'environnement
- **Secrets** : Identifiants (base64 encodés)
- **Ingress** : Routage HTTP avancé

### 4️⃣ Utiliser les Helpers Helm
```yaml
labels:
  {{ include "my-app-chart.labels" . | nindent 4 }}
```

### 5️⃣ Déploiement
```bash
# Valider la syntaxe
helm lint my-app-chart

# Simuler le déploiement (dry-run)
helm install my-release my-app-chart --dry-run --debug

# Installer en DEV
helm install my-release my-app-chart -f values-dev.yaml -n dev --create-namespace

# Installer en PROD
helm install my-release my-app-chart -f values-prod.yaml -n production --create-namespace

# Mettre à jour
helm upgrade my-release my-app-chart -f values-prod.yaml -n production

# Lister les releases
helm list -A

# Voir les détails
helm get values my-release -n production

# Rollback à une version antérieure
helm rollback my-release 1 -n production
```

### 6️⃣ Tester et Valider
```bash
# Vérifier les pods
kubectl get pods -n dev
kubectl get pods -n production

# Logs d'un conteneur
kubectl logs -l app=my-app -n dev

# Port-forward pour tester
kubectl port-forward svc/my-app-frontend 8080:80 -n dev

# Puis : curl http://localhost:8080
```

## Ce qu'on Apprend

✅ **Templating Helm** : Utiliser Go templates pour générer les manifestes dynamiquement  
✅ **Values & Override** : Gérer les configurations multi-environnements  
✅ **Réutilisabilité** : Créer des charts génériques et maintenables  
✅ **Dépendances** : Gérer les sous-charts et les versions  
✅ **Lifecycle** : Install → Upgrade → Rollback  
✅ **Best Practices** : Labels, namespaces, ressources, health checks  
✅ **Production Ready** : ConfigMaps, Secrets, Ingress, stateful apps  

## Commandes Essentielles
```bash
helm create <name>           # Créer un nouveau chart
helm lint <chart>            # Valider la syntaxe
helm template <release> <chart>  # Générer les manifestes (sans appliquer)
helm install <release> <chart>   # Installer
helm upgrade <release> <chart>   # Mettre à jour
helm rollback <release> [revision]  # Revenir à une version antérieure
helm history <release>       # Voir l'historique des versions
helm uninstall <release>     # Supprimer
helm repo add <name> <url>   # Ajouter un repository de charts
helm search repo <keyword>   # Chercher un chart
helm pull <repo/chart>       # Télécharger un chart
```

## Cas d'Usage Réels
- 🌐 Multi-région : Déployer la même app sur dev/staging/prod avec des configs différentes
- 🔄 GitOps : Stocker les charts en git, déployer via ArgoCD
- 📦 Helm Hub : Publier son chart pour la communauté
- 🤖 CI/CD : Automatiser les tests et déploiements via GitHub Actions + Helm
- 🔐 Secrets : Gérer les identifiants avec Helm secrets plugins

## Ressources
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Charts](https://artifacthub.io/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)

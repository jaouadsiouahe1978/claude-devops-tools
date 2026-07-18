# Helm Charts for Multi-Environment Deployments

## 📋 Description

Créer un Helm chart complet pour déployer une application multi-tier sur Kubernetes à travers différents environnements (dev, staging, production) avec des configurations spécifiques par environnement.

## 🎯 Objectif

- Créer un Helm chart réutilisable et modulaire
- Gérer différentes configurations par environnement (values files)
- Implémenter les bonnes pratiques Helm (templates, helpers, validations)
- Déployer sur cluster K8s avec des stratégies d'environnement

## 🛠️ Technologies Utilisées

- **Helm 3** - Package manager Kubernetes
- **Kubernetes** - Orchestration (local ou minikube)
- **YAML** - Configuration Helm
- **Bash** - Scripts de déploiement

## 📁 Structure du Projet

```
helm-multienvironment-charts/
├── README.md
├── Chart.yaml                      # Metadata du chart
├── values.yaml                     # Valeurs par défaut
├── values-dev.yaml                 # Valeurs dev
├── values-staging.yaml             # Valeurs staging
├── values-production.yaml          # Valeurs production
├── templates/
│   ├── deployment.yaml             # Déploiement principal
│   ├── service.yaml                # Service K8s
│   ├── ingress.yaml                # Ingress Controller
│   ├── configmap.yaml              # Configuration
│   ├── secret.yaml                 # Secrets
│   ├── hpa.yaml                    # Horizontal Pod Autoscaler
│   ├── pdb.yaml                    # Pod Disruption Budget
│   ├── serviceaccount.yaml         # Service Account
│   └── _helpers.tpl                # Fonctions réutilisables
├── scripts/
│   ├── deploy.sh                   # Script de déploiement
│   ├── rollback.sh                 # Script de rollback
│   └── validate.sh                 # Script de validation
└── .helmignore                     # Fichiers à ignorer
```

## 📚 Étapes de Réalisation

### Étape 1 : Initialiser le structure Helm
```bash
helm create myapp-chart
```

### Étape 2 : Configurer le Chart.yaml
Décrire le chart, version, description, maintainers.

### Étape 3 : Créer les templates
- `deployment.yaml` : Déploiement avec probes, limits, env vars
- `service.yaml` : Service ClusterIP/LoadBalancer
- `ingress.yaml` : Ingress avec TLS
- `configmap.yaml` : Configuration externe
- `secret.yaml` : Secrets sensibles
- `hpa.yaml` : Autoscaling horizontal
- `serviceaccount.yaml` : RBAC

### Étape 4 : Créer les fichiers values
- `values.yaml` : Valeurs par défaut
- `values-dev.yaml` : Dev (1 replica, minimal resources)
- `values-staging.yaml` : Staging (2 replicas, medium resources)
- `values-production.yaml` : Prod (3+ replicas, high resources, HPA, PDB)

### Étape 5 : Créer les helpers
`_helpers.tpl` : Labels, selectors, names réutilisables

### Étape 6 : Créer les scripts de déploiement
- Validation
- Déploiement par environnement
- Rollback sécurisé
- Vérification de health

### Étape 7 : Tester et valider
```bash
helm lint
helm dry-run
helm template
```

## 🚀 Ce qu'on Apprend

✅ Structure et architecture d'un Helm chart professionnel
✅ Gestion multi-environnement avec values files
✅ Templating avancé (conditionals, loops, helpers)
✅ Gestion des ressources K8s (Deployments, Services, Ingress, HPA, PDB)
✅ RBAC et Service Accounts
✅ Best practices Helm (DRY, modularity, reusability)
✅ Automation de déploiement avec scripts Bash
✅ Stratégies de rollback et rollforward

## 🔧 Prérequis

- Kubectl configuré et connecté à un cluster K8s (minikube OK)
- Helm 3 installé
- Bash shell
- Docker (optionnel, pour build des images)

## 📖 Utilisation

### Valider le chart
```bash
helm lint .
helm template myapp . --values values-dev.yaml
```

### Installer dans un environnement
```bash
# Dev
helm install myapp . -f values-dev.yaml -n dev --create-namespace

# Staging
helm install myapp . -f values-staging.yaml -n staging --create-namespace

# Production
helm install myapp . -f values-production.yaml -n production --create-namespace
```

### Mettre à jour une release
```bash
helm upgrade myapp . -f values-production.yaml -n production
```

### Rollback
```bash
helm rollback myapp 1 -n production
```

### Vérifier le statut
```bash
helm status myapp -n production
helm history myapp -n production
```

## 💡 Points Clés

1. **Separation of Concerns** : Configuration par environnement séparée
2. **DRY Principle** : Réutilisation via helpers et templates
3. **Security** : Secrets séparés, RBAC avec service accounts
4. **Scalability** : HPA et ressources configurables
5. **Reliability** : Health checks, PDB, resource limits
6. **Automation** : Scripts Bash pour CI/CD integration

## 📌 Tags

`#Helm #Kubernetes #DevOps #IaC #Multi-Environment #Deployment`

# Helm Chart pour Application Multi-Tier

## 📋 Description

Ce projet vous apprendra à créer, packager et déployer une application multi-tier (Frontend + Backend + Database) sur Kubernetes en utilisant **Helm 3**.

Helm est le gestionnaire de packages de Kubernetes qui simplifie considérablement le déploiement et la gestion des applications complexes. Au lieu de gérer des fichiers YAML individuels, vous créez un chart réutilisable avec des variables configurables.

## 🎯 Objectif

- Comprendre la structure d'un Helm Chart
- Créer des templates Kubernetes réutilisables
- Gérer les configurations avec `values.yaml`
- Déployer une application multi-tier complète
- Utiliser les hooks Helm pour les migrations de base de données
- Apprendre les bonnes pratiques Helm (linting, validation, versioning)

## 🛠️ Technologies utilisées

- **Kubernetes** - Orchestration de conteneurs
- **Helm 3** - Package manager pour Kubernetes
- **Docker** - Containerisation des services
- **YAML** - Configuration des templates
- **kubectl** - Client Kubernetes

## 📦 Structure du projet

```
helm-multitier-deployment/
├── docker/                       # Applications dockerisées
│   ├── frontend/
│   ├── backend/
│   └── db/
├── helm-chart/                   # Helm Chart
│   ├── Chart.yaml               # Métadonnées du chart
│   ├── values.yaml              # Valeurs par défaut
│   ├── templates/               # Templates Kubernetes
│   │   ├── _helpers.tpl         # Templates helper
│   │   ├── deployment-frontend.yaml
│   │   ├── deployment-backend.yaml
│   │   ├── deployment-db.yaml
│   │   ├── service.yaml
│   │   ├── configmap.yaml
│   │   ├── secret.yaml
│   │   ├── persistent-volume.yaml
│   │   ├── job-db-init.yaml
│   │   └── ingress.yaml
│   └── charts/                  # Dépendances externes
└── examples/                     # Fichiers d'exemple
    ├── values-prod.yaml
    ├── values-dev.yaml
    └── values-test.yaml
```

## 🚀 Prérequis

- Kubernetes 1.19+ (minikube, kind, ou cluster cloud)
- Helm 3.x installé (`helm version`)
- Docker (pour builder les images)
- kubectl configuré pour accéder à votre cluster
- Environ 2GB RAM disponible dans le cluster

### Installation rapide

```bash
# Installer Helm (macOS)
brew install helm

# Installer Helm (Linux)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Vérifier l'installation
helm version
```

## 📝 Étapes de réalisation

### 1️⃣ **Étape 1 : Créer la structure du Helm Chart (30 min)**

```bash
cd helm-chart

# Générer un chart de base
helm create multitier

# Explorer la structure créée
tree multitier/
```

Vous verrez :
- `Chart.yaml` : Informations sur le chart (nom, version, description)
- `values.yaml` : Valeurs par défaut pour les templates
- `templates/` : Fichiers de templates Kubernetes

### 2️⃣ **Étape 2 : Définir les valeurs pour chaque service (30 min)**

Éditer `values.yaml` pour configurer :
- **Frontend** : 2 replicas, nginx, port 3000
- **Backend** : 3 replicas, Node.js, port 5000
- **Database** : PostgreSQL, 1 replica, persistance 10GB

Exemple structure :
```yaml
frontend:
  replicaCount: 2
  image:
    repository: myregistry/myapp-frontend
    tag: "1.0.0"
  service:
    type: LoadBalancer
    port: 3000

backend:
  replicaCount: 3
  image:
    repository: myregistry/myapp-backend
    tag: "1.0.0"
  service:
    type: ClusterIP
    port: 5000

database:
  enabled: true
  image:
    repository: postgres
    tag: "13"
  persistence:
    size: 10Gi
```

### 3️⃣ **Étape 3 : Créer les templates Kubernetes (45 min)**

Créer les fichiers template dans `templates/` :

- **Deployments** : Frontend, Backend, Database
- **Services** : Exposition des services (LoadBalancer, ClusterIP)
- **ConfigMaps** : Configuration applicative
- **Secrets** : Mots de passe et clés (base64 encodées)
- **PersistentVolumeClaim** : Stockage pour la DB
- **Ingress** : Routage HTTP/HTTPS

Utiliser les fonctions Helm :
```yaml
{{ .Values.frontend.replicaCount }}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{ include "multitier.labels" . }}
```

### 4️⃣ **Étape 4 : Écrire les Hooks Helm (20 min)**

Créer `templates/job-db-init.yaml` pour initialiser la base de données :

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "multitier.fullname" . }}-db-init
  annotations:
    "helm.sh/hook": pre-install,pre-upgrade
    "helm.sh/hook-weight": "-5"
spec:
  template:
    spec:
      containers:
      - name: db-init
        image: postgres:13
        command: ["psql", "-h", "{{ .Values.database.host }}", "-U", "postgres", "-f", "/init.sql"]
```

Les hooks permettent d'exécuter des tâches avant/après le déploiement.

### 5️⃣ **Étape 5 : Valider et tester le Chart (30 min)**

```bash
# Linter le chart
helm lint helm-chart/

# Valider les templates (dry-run)
helm template multitier helm-chart/

# Valider avec kubectl
helm template multitier helm-chart/ | kubectl apply --dry-run=client -f -

# Vérifier les dépendances
helm dependency list helm-chart/
```

### 6️⃣ **Étape 6 : Déployer avec Helm (30 min)**

```bash
# Déploiement en développement
helm install myapp helm-chart/ -f examples/values-dev.yaml --namespace dev --create-namespace

# Vérifier le déploiement
helm list -A
helm status myapp -n dev

# Voir les ressources créées
kubectl get all -n dev

# Accéder à l'application
kubectl port-forward -n dev svc/myapp-frontend 3000:3000

# Mettre à jour le déploiement
helm upgrade myapp helm-chart/ -f examples/values-dev.yaml -n dev

# Rollback si nécessaire
helm rollback myapp -n dev
```

### 7️⃣ **Étape 7 : Gérer les configurations par environnement (20 min)**

Créer des fichiers `values-*.yaml` pour chaque environnement :

- `values-dev.yaml` : Replicas bas, pas de limites strictes
- `values-prod.yaml` : Replicas hauts, limites CPU/Memory, persistence, backups
- `values-test.yaml` : Configuration minimale pour les tests

```bash
# Déployer chaque environnement
helm install myapp-dev helm-chart/ -f examples/values-dev.yaml -n dev
helm install myapp-prod helm-chart/ -f examples/values-prod.yaml -n prod
```

### 8️⃣ **Étape 8 : Packager et distribuer (10 min)**

```bash
# Créer une archive du chart
helm package helm-chart/

# Créer un Helm Repository local
mkdir helm-repo && mv multitier-*.tgz helm-repo/
helm repo index helm-repo/

# Installer depuis le repo
helm repo add myrepo ./helm-repo/
helm install myapp myrepo/multitier
```

## 📚 Ce que vous apprenez

✅ **Concepts Helm** :
- Structure d'un chart
- Templates et fonctions spline
- Values et configuration management
- Hooks et lifecycle management
- Dépendances et repository

✅ **Bonnes pratiques** :
- Versionning sémantique des charts
- Linting et validation
- Configuration par environnement
- Secrets management
- Documentation des charts

✅ **Kubernetes advanced** :
- Multi-tier application deployment
- Service discovery et networking
- Persistent storage
- ConfigMaps et Secrets
- Ingress routing
- Init containers et jobs

✅ **Scripting** :
- Templating avec Sprig functions
- YAML generation dynamique
- Conditional deployments

## 🔍 Vérification

Après chaque étape, vérifiez :

```bash
# Étape 1 : Chart créé
ls -la helm-chart/multitier/

# Étape 2 : Values correctement structurés
grep -A 5 "frontend:" helm-chart/values.yaml

# Étape 3 : Templates présents
ls helm-chart/templates/

# Étape 5 : Chart valide
helm lint helm-chart/

# Étape 6 : Pods running
kubectl get pods -n dev

# Étape 7 : Environnements différenciés
helm get values myapp-dev -n dev
helm get values myapp-prod -n prod
```

## 🎓 Concepts clés

| Concept | Explication |
|---------|------------|
| **Chart** | Package Helm contenant les templates et config |
| **Values** | Variables injectées dans les templates |
| **Template** | Fichier Kubernetes avec variables Helm |
| **Hook** | Actions exécutées avant/après déploiement |
| **Release** | Instance d'un chart déployée sur le cluster |
| **Repository** | Stockage centralisé de charts (comme Artifactory, Nexus) |

## 💡 Tips et astuces

1. **Testez les templates avant déploiement** :
   ```bash
   helm template myrelease ./helm-chart/
   ```

2. **Utilisez `--dry-run`** pour tester sans rien créer :
   ```bash
   helm install myapp ./helm-chart/ --dry-run --debug
   ```

3. **Consultez la documentation des charts existants** :
   ```bash
   helm search repo stable
   ```

4. **Versionnez vos charts comme du code** :
   ```bash
   git tag chart-v1.0.0
   ```

5. **Utilisez des values defaults sensés** pour faciliter l'adoption

## 🚨 Troubleshooting

**Problem** : `Error: INSTALLATION FAILED: template: multitier/templates/deployment.yaml`

**Solution** : Vérifiez la syntaxe Sprig dans vos templates. Utilisez `helm template` pour déboguer.

---

**Problem** : `Pods ne démarrent pas`

**Solution** : Vérifiez les logs :
```bash
kubectl logs pod-name -n namespace
kubectl describe pod pod-name -n namespace
```

---

**Problem** : `ConfigMap/Secret non mis à jour après helm upgrade`

**Solution** : Ajoutez un `checksum` dans le deployment pour forcer la recréation des pods

## 📖 Ressources complémentaires

- [Helm Official Docs](https://helm.sh/docs/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Sprig Functions Reference](http://masterminds.github.io/sprig/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## ✨ Améliorations possibles

Une fois le projet complété, vous pouvez :
- Ajouter des tests Helm (Chart Testing)
- Implémenter ArgoCD pour GitOps
- Créer un Helm repository privé (Artifactory, Nexus, Harbor)
- Intégrer les charts dans une pipeline CI/CD
- Ajouter Helm Secrets pour le chiffrement des secrets
- Implémenter le monitoring et les alertes des releases

---

**Durée estimée** : 4-5 heures | **Niveau** : Débutant à Intermédiaire | **Technos** : Kubernetes, Helm, Docker, YAML

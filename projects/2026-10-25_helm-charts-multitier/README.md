# Kubernetes Helm Charts - Application Multi-tier

## 📋 Description

Créer et déployer une application multi-tier (Frontend + Backend API + Database) sur Kubernetes en utilisant **Helm Charts**. Helm permet de templater, packager et versionner les déploiements Kubernetes de manière propre et réutilisable.

## 🎯 Objectif

- Comprendre la structure des Helm Charts
- Créer des templates réutilisables pour différents composants
- Gérer les configurations avec values.yaml
- Déployer une application complète avec un seul `helm install`
- Apprendre les bonnes pratiques de templating Helm

## 🛠️ Technologies

- **Kubernetes** - Orchestration de conteneurs
- **Helm 3** - Package manager pour Kubernetes
- **Docker** - Conteneurisation (images de base)
- **YAML/Templating** - Configuration dynamique

## 📦 Architecture

```
helm-multitier/
├── myapp/
│   ├── Chart.yaml                 # Métadonnées du chart
│   ├── values.yaml                # Valeurs par défaut
│   ├── values-prod.yaml           # Valeurs pour prod
│   ├── values-dev.yaml            # Valeurs pour dev
│   └── templates/
│       ├── frontend-deployment.yaml
│       ├── api-deployment.yaml
│       ├── postgres-deployment.yaml
│       ├── frontend-service.yaml
│       ├── api-service.yaml
│       ├── postgres-service.yaml
│       ├── configmap.yaml
│       ├── secrets.yaml
│       ├── ingress.yaml
│       └── _helpers.tpl           # Fonctions réutilisables
```

## 🚀 Étapes de réalisation

### 1. Initialiser le Helm Chart
```bash
helm create myapp
```

### 2. Créer la structure des templates
- Frontend (Nginx + React/Vue.js)
- Backend API (Python/Node.js)
- Database PostgreSQL
- ConfigMap et Secrets
- Services (ClusterIP, LoadBalancer)
- Ingress pour l'accès externe

### 3. Configurer values.yaml
- Images Docker par composant
- Nombre de replicas
- Ressources (CPU, memory)
- Configuration des services
- Environnement (dev, prod)

### 4. Utiliser les fonctions Helm
- `{{ .Release.Name }}`
- `{{ .Values.app.name }}`
- `{{ include "myapp.labels" . }}`
- Conditions et boucles

### 5. Valider et tester le chart
```bash
helm lint myapp/
helm template myapp/
helm dry-run install myapp myapp/
```

### 6. Déployer avec différentes valeurs
```bash
# Dev environment
helm install myapp-dev myapp/ -f myapp/values-dev.yaml

# Prod environment
helm install myapp-prod myapp/ -f myapp/values-prod.yaml
```

## 📚 Ce qu'on apprend

✅ Structure et bonnes pratiques des Helm Charts  
✅ Templating YAML avancé avec variables et logique  
✅ Gestion des configurations multi-environnement  
✅ Déploiement d'applications complexes en 1 commande  
✅ Versionning et release management avec Helm  
✅ Réutilisabilité et scalabilité des configurations  

## 🔧 Pré-requis

- Kubernetes cluster actif (Kind, Minikube ou cloud provider)
- `kubectl` configuré
- `helm` installé (v3+)
- Images Docker pré-buildes ou publiques

## 📝 Notes

- Ce projet utilise des images Docker publiques pour la simplicité
- Peut être étendu avec helm hooks, tests, et charts dépendants
- Parfait pour comprendre comment packager une application Kubernetes

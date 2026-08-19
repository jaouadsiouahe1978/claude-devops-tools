# Kubernetes Helm Charts - Multi-App Deployment

## Objectif du projet

Apprendre à créer et gérer des **Helm Charts** pour déployer facilement des applications multi-conteneur sur Kubernetes. Les Helm Charts permettent de templater les manifests Kubernetes et de les réutiliser facilement.

## Technologies utilisées

- **Kubernetes** - Container orchestration
- **Helm 3** - Package manager pour Kubernetes
- **Docker** - Container runtime
- **kubectl** - CLI Kubernetes
- **Minikube** ou **Docker Desktop Kubernetes** - Local cluster

## Pré-requis

- Docker Desktop avec Kubernetes activé OU Minikube installé
- `kubectl` configuré
- Helm 3 installé (`helm version`)
- Connaissance basique de Kubernetes (Pods, Services, Deployments)

## Description du projet

Ce projet vous apprendra à :

1. **Créer un Helm Chart** à partir de zéro
2. **Utiliser les templates Helm** avec des variables (values)
3. **Déployer une application multi-tier** (frontend + backend + database)
4. **Gérer les environnements** (dev, staging, prod) avec différentes values
5. **Créer un Helm Chart personnalisé** pour votre infrastructure

### Structure du projet

```
charts/
├── myapp-chart/                    # Chart principal
│   ├── Chart.yaml                 # Métadonnées du chart
│   ├── values.yaml                # Valeurs par défaut
│   ├── values-dev.yaml            # Valeurs pour dev
│   ├── values-prod.yaml           # Valeurs pour prod
│   └── templates/
│       ├── deployment.yaml        # Template Deployment
│       ├── service.yaml           # Template Service
│       ├── configmap.yaml         # Template ConfigMap
│       ├── secret.yaml            # Template Secret
│       └── ingress.yaml           # Template Ingress
```

## Étapes de réalisation

### Étape 1 : Initialiser un Helm Chart

```bash
# Créer un nouveau chart
helm create myapp-chart

# Ou créer manuellement
mkdir -p charts/myapp-chart/templates
```

### Étape 2 : Définir les valeurs par défaut (values.yaml)

Les values permettent de rendre les manifests réutilisables :
- Image Docker (repo, tag)
- Replicas
- Ressources (CPU, mémoire)
- Variables d'environnement
- Ports

### Étape 3 : Créer les templates Kubernetes

Utiliser la syntaxe Helm pour templater les manifests :
- `{{ .Values.key }}` - accéder aux values
- `{{ .Release.Name }}` - nom du release
- `{{ if }}...{{ end }}` - conditions
- `{{ range }}...{{ end }}` - boucles

### Étape 4 : Créer des fichiers values pour chaque environnement

- `values-dev.yaml` - configuration développement
- `values-prod.yaml` - configuration production

### Étape 5 : Installer et tester le Chart

```bash
# Installer dans le cluster
helm install my-release ./charts/myapp-chart -n default

# Ou avec values spécifiques
helm install my-release ./charts/myapp-chart -f values-prod.yaml

# Lister les releases
helm list

# Vérifier les manifests générés
helm template my-release ./charts/myapp-chart

# Mettre à jour
helm upgrade my-release ./charts/myapp-chart

# Supprimer
helm uninstall my-release
```

## Ce qu'on apprend

✅ **Helm fundamentals** : créer et structurer un Helm Chart  
✅ **Templating** : utiliser les variables et conditions dans les templates  
✅ **Multi-environment** : gérer dev/staging/prod avec différentes configurations  
✅ **Best practices** : versionning, labels, metadata  
✅ **Debugging** : utiliser `helm template`, `helm dry-run`, `helm lint`  
✅ **Advanced concepts** : dependencies, subcharts, hooks  

## Fichiers créés dans ce projet

- `charts/myapp-chart/Chart.yaml` - Métadonnées
- `charts/myapp-chart/values.yaml` - Configuration par défaut
- `charts/myapp-chart/values-dev.yaml` - Configuration dev
- `charts/myapp-chart/values-prod.yaml` - Configuration prod
- `charts/myapp-chart/templates/deployment.yaml` - Deployment template
- `charts/myapp-chart/templates/service.yaml` - Service template
- `charts/myapp-chart/templates/configmap.yaml` - ConfigMap template
- `charts/myapp-chart/templates/ingress.yaml` - Ingress template
- `helm-install.sh` - Script d'installation et test

## Commandes essentielles

```bash
# Valider le chart
helm lint ./charts/myapp-chart

# Voir les manifests générés
helm template myapp ./charts/myapp-chart

# Simuler l'installation (dry-run)
helm install myapp ./charts/myapp-chart --dry-run --debug

# Installer avec un namespace
helm install myapp ./charts/myapp-chart -n production --create-namespace

# Voir l'historique des releases
helm history myapp

# Rollback à une version précédente
helm rollback myapp 1

# Chercher un chart public
helm search repo nginx
```

## Ressources utiles

- [Helm Official Documentation](https://helm.sh/docs/)
- [Helm Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Helm Hub - Public Charts](https://artifacthub.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## Difficulté

⭐️ Intermédiaire (niveau 2/5)

---

**Auteur** : Jaouad | **Date** : 2026-08-19

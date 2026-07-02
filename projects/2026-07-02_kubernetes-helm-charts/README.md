# Kubernetes Helm Charts - Multi-Environment Deployment

## Objectif
Apprendre à packager et déployer une application Kubernetes avec Helm, gérer les configurations multi-environnement (dev/staging/prod) et utiliser les override values.

## Technos
- **Kubernetes** : orchestration de conteneurs
- **Helm 3** : package manager pour K8s
- **Python/Flask** : application d'exemple
- **Docker** : containerization
- **Kustomize** : personnalisation des déploiements

## Ce qu'on apprend
1. **Structure Helm** : créer un Chart avec templates paramétrables
2. **Values Management** : utiliser values.yaml, values-dev.yaml, values-prod.yaml
3. **Templates K8s** : Deployment, Service, ConfigMap, Secret, Ingress
4. **Override values** : déployer la même app sur plusieurs environnements
5. **Helm hooks** : pre-install, post-install, pre-upgrade scripts
6. **Subcharts** : dépendances dans Helm

## Prérequis
- Docker installé
- `kubectl` configuré avec un cluster K8s (minikube, kind, ou cluster distant)
- Helm 3.x installé (`helm version`)
- Python 3.9+

## Étapes de réalisation

### 1. Créer l'application Flask
```bash
cd python-app
pip install -r requirements.txt
python app.py
```

### 2. Builder et tester l'image Docker
```bash
docker build -t my-app:1.0.0 .
docker run -p 5000:5000 -e ENV=dev my-app:1.0.0
```

### 3. Créer le Helm Chart
```bash
cd ../helm-chart
helm create my-app  # ou utiliser notre structure pré-générée
```

### 4. Valider le Chart
```bash
helm lint my-app/
helm template my-app my-app/  # voir le YAML généré
```

### 5. Déployer sur Kubernetes
```bash
# Mode dev
helm install my-app ./my-app -f my-app/values-dev.yaml --namespace dev --create-namespace

# Mode prod
helm install my-app ./my-app -f my-app/values-prod.yaml --namespace prod --create-namespace
```

### 6. Vérifier le déploiement
```bash
kubectl get pods -n dev
kubectl port-forward svc/my-app 5000:80 -n dev
curl http://localhost:5000
```

### 7. Mettre à jour et tester
```bash
helm upgrade my-app ./my-app -f my-app/values-prod.yaml -n prod
helm rollback my-app 1 -n prod  # revenir à la version 1
```

## Fichiers clés

- `python-app/app.py` - Application Flask avec variable d'env
- `python-app/Dockerfile` - Image Docker multi-stage
- `helm-chart/my-app/Chart.yaml` - Métadonnées du Helm Chart
- `helm-chart/my-app/values.yaml` - Valeurs par défaut
- `helm-chart/my-app/values-dev.yaml` - Override pour dev
- `helm-chart/my-app/values-prod.yaml` - Override pour prod
- `helm-chart/my-app/templates/deployment.yaml` - Template K8s
- `helm-chart/my-app/templates/service.yaml` - Service K8s
- `helm-chart/my-app/templates/configmap.yaml` - Configuration
- `helm-chart/my-app/templates/ingress.yaml` - Ingress pour accès HTTP

## Bonnes pratiques Helm
✅ Utiliser des templates paramétrables ({{ .Values.* }})  
✅ Versionner les Charts (Chart.yaml: version, appVersion)  
✅ Documenter les values disponibles dans values.yaml  
✅ Utiliser des linters (helm lint)  
✅ Tester templates avant déploiement (helm template)  
✅ Gérer les secrets avec --set-string ou external-secrets  
✅ Utiliser des hooks pour les migrations DB, warmup, cleanup

## Améliorations futures
- Ajouter des tests Helm avec Helm Test
- Intégrer avec Istio/Service Mesh
- Utiliser Kustomize avec Helm
- Setup des Health Checks (liveness/readiness probes)
- Ajouter des Resource Limits et Requests
- Metrics Server et HPA (Horizontal Pod Autoscaling)

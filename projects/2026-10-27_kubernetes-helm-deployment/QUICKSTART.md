# Quick Start Guide

## ⚡ Démarrage rapide (15 minutes)

### 1. Vérifier les prérequis

```bash
# Minikube
minikube start --cpus=4 --memory=4096
minikube addons enable ingress

# Helm
helm version

# kubectl
kubectl version --client
```

### 2. Construire les images Docker

```bash
# Frontend
docker build -t myapp-frontend:1.0 ./docker/frontend

# API
docker build -t myapp-api:1.0 ./docker/api

# Charger dans Minikube
minikube image load myapp-frontend:1.0
minikube image load myapp-api:1.0
```

### 3. Déployer avec Helm

```bash
# Mode développement (1 replique de chaque)
./scripts/deploy.sh myapp myapp dev

# Mode staging (2 repliques)
./scripts/deploy.sh myapp myapp staging

# Mode production (3 repliques + autoscaling)
./scripts/deploy.sh myapp myapp prod
```

### 4. Tester le déploiement

```bash
./scripts/test-deployment.sh myapp myapp
```

### 5. Accéder à l'application

```bash
# Option 1: Port forwarding (plus facile)
./scripts/port-forward.sh myapp myapp

# Option 2: Ingress
# Ajouter à /etc/hosts:
# 127.0.0.1 myapp.local
# Visiter: http://myapp.local
```

### 6. Voir les logs

```bash
# Frontend
kubectl logs -f -n myapp deployment/myapp-frontend

# API
kubectl logs -f -n myapp deployment/myapp-api

# Database
kubectl logs -f -n myapp statefulset/myapp-postgres
```

## 📋 Commandes courantes

```bash
# Status
kubectl get all -n myapp
helm status myapp -n myapp

# Scaling manuel
kubectl scale deployment/myapp-api --replicas=3 -n myapp

# Recréer les pods
kubectl rollout restart deployment/myapp-frontend -n myapp

# Supprimer le déploiement
helm uninstall myapp -n myapp

# Mettre à jour
helm upgrade myapp ./helm-chart -f helm-chart/values-dev.yaml -n myapp

# Voir la différence avant upgrade
helm diff upgrade myapp ./helm-chart -f helm-chart/values-dev.yaml -n myapp
```

## 🐛 Troubleshooting

### Les pods ne démarrent pas

```bash
# Voir l'erreur
kubectl describe pod <pod-name> -n myapp

# Vérifier les événements
kubectl get events -n myapp --sort-by='.lastTimestamp'

# Voir les logs
kubectl logs <pod-name> -n myapp
```

### Les images ne sont pas trouvées

```bash
# Vérifier les images dans Minikube
minikube image ls

# Recharger l'image
minikube image load myapp-frontend:1.0

# Vérifier la politique pull
kubectl get deployment myapp-frontend -n myapp -o yaml | grep imagePullPolicy
```

### La base de données ne se connecte pas

```bash
# Vérifier la connectivité
kubectl run -it --rm debug --image=alpine --restart=Never -n myapp -- \
  sh -c "apk add --no-cache postgresql-client && psql -h myapp-postgres -U myapp"
```

## 🎓 Concepts à apprendre

| Concept | Où l'apprendre |
|---------|------------------|
| Deployments | deployment-frontend.yaml |
| StatefulSets | statefulset-postgres.yaml |
| Services | service-*.yaml |
| Ingress | ingress.yaml |
| ConfigMaps | configmap.yaml |
| Secrets | secret.yaml |
| Helm templating | helm-chart/values.yaml |
| Health checks | deployment-*.yaml |
| Resource limits | values-*.yaml |
| Autoscaling | hpa.yaml |

## 📚 Lecture recommandée

1. **Kubernetes Basics** (30 min)
   - Pods, Services, Deployments
   - kubectl commands

2. **Helm Concepts** (30 min)
   - Charts, Values, Templates
   - Release management

3. **Application Architecture** (30 min)
   - Multi-tier applications
   - Service communication
   - Data persistence

## ✅ Checklist de compréhension

Avant de continuer, vous devez comprendre:
- [ ] Comment les Pods communiquent entre eux
- [ ] La différence entre Deployment et StatefulSet
- [ ] Comment les Services découvrent les endpoints
- [ ] Pourquoi on utilise Helm plutôt que kubectl raw
- [ ] Comment la base de données persiste les données
- [ ] Comment configurer une application par environnement

## 🚀 Prochaines étapes

1. **Ajouter le monitoring**: Prometheus + Grafana
2. **Implémenter les logs**: ELK ou Loki
3. **Sécurité**: NetworkPolicies, RBAC
4. **CI/CD**: GitHub Actions pour auto-déployer
5. **Service Mesh**: Istio pour avancé

Bon apprentissage! 🎉

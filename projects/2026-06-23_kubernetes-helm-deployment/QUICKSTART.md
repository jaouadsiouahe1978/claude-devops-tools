# 🚀 Quick Start Guide

## Option 1 : Test Local (Docker Compose)

```bash
# Lancer tous les services
docker-compose up -d

# Vérifier les logs
docker-compose logs -f api

# Tester l'API
curl http://localhost:8080/health
curl http://localhost:8080/api/status

# Arrêter
docker-compose down
```

## Option 2 : Déployer sur Kubernetes avec Helm

### Prérequis
```bash
# Vérifier que les outils sont installés
kubectl version --client
helm version
kind version  # ou minikube version
```

### Créer un cluster local (Kind)
```bash
kind create cluster --name devops-lab --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

# Vérifier le cluster
kubectl cluster-info
kubectl get nodes
```

### Installer l'application avec Helm

```bash
# Accéder au répertoire du projet
cd helm-chart

# Option 1: Avec le script
cd ../scripts
./install.sh

# Ou Option 2: Avec Helm directement
helm install devops-app ../helm-chart -n devops-app --create-namespace

# Ou Option 3: Avec Make
make install
```

### Vérifier le déploiement
```bash
# Voir tous les pods
kubectl get pods -n devops-app -w

# Voir les services
kubectl get svc -n devops-app

# Voir les PVC
kubectl get pvc -n devops-app

# Vérifier les logs de l'API
kubectl logs -f deploy/devops-app-api -n devops-app
```

### Accéder à l'application

```bash
# Port-forward vers l'API
kubectl port-forward svc/api-service 8080:80 -n devops-app

# Dans un autre terminal, tester l'API
curl http://localhost:8080/health
curl http://localhost:8080/api/status
curl http://localhost:8080/api/info
```

## Option 3 : Test avec Minikube

```bash
# Démarrer Minikube
minikube start --cpus=4 --memory=4096

# Vérifier les nœuds
kubectl get nodes

# Installer l'application
make install

# Accéder via le tunnel Minikube
minikube service api-service -n devops-app
```

## Commandes utiles

```bash
# Voir le statut de la release
helm status devops-app -n devops-app

# Voir l'historique des déploiements
helm history devops-app -n devops-app

# Voir les valeurs utilisées
helm get values devops-app -n devops-app

# Voir les manifests générés
helm template devops-app helm-chart

# Mettre à jour l'application
make upgrade

# Rollback à la version précédente
make rollback

# Afficher les logs
make logs-api
make logs-db
make logs-cache

# Valider le chart
make lint
make validate

# Supprimer tout
make cleanup
```

## Tests d'intégration

```bash
# Lancer les tests
./scripts/test-deployment.sh

# Ou avec Make
make test
```

## Déployer en Staging/Production

```bash
# Staging
helm install devops-app-staging helm-chart -f helm-chart/values-staging.yaml -n devops-staging --create-namespace

# Production
helm install devops-app-prod helm-chart -f helm-chart/values-prod.yaml -n devops-prod --create-namespace
```

## Dépannage

### Les pods n'arrivent pas à démarrer
```bash
# Voir les événements du cluster
kubectl describe pod <pod-name> -n devops-app

# Voir les logs d'erreur
kubectl logs <pod-name> -n devops-app --previous
```

### Problèmes de connectivité base de données
```bash
# Vérifier la résolution DNS
kubectl exec -it deploy/devops-app-api -n devops-app -- nslookup postgres-service

# Tester la connexion PostgreSQL
kubectl run -it --rm debug --image=postgres:15-alpine --restart=Never -- \
  psql -h postgres-service -U postgres -c "SELECT 1" -n devops-app
```

### Problèmes de stockage
```bash
# Vérifier les PVC
kubectl describe pvc -n devops-app

# Vérifier les PV
kubectl get pv
```

## 📚 Ressources
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/)

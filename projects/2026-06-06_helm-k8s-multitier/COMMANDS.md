# Commandes Helm & Kubernetes - App Multi-Tier

## 🎯 Prerequis & Setup

```bash
# Vérifier les outils
kubectl version --client
helm version

# Créer un cluster local (minikube)
minikube start --cpus=4 --memory=8192
minikube addons enable ingress

# Ou utiliser kind
kind create cluster --name devops-lab
```

## 📦 Opérations Helm

### Installation & Déploiement
```bash
# Validation du chart
helm lint helm-chart/

# Dry-run pour voir ce qui sera créé
helm install app-multitier ./helm-chart \
  --namespace app-system \
  --create-namespace \
  --dry-run --debug

# Installation réelle
helm install app-multitier ./helm-chart \
  --namespace app-system \
  --create-namespace

# Installation avec environment spécifique
helm install app-multitier ./helm-chart \
  --namespace app-dev \
  --create-namespace \
  -f helm-chart/values-dev.yaml

# Production avec HPA
helm install app-multitier ./helm-chart \
  --namespace app-prod \
  --create-namespace \
  -f helm-chart/values-prod.yaml
```

### Gestion des Releases
```bash
# Lister les releases
helm list
helm list -n app-system
helm list --all-namespaces

# Voir les détails d'une release
helm status app-multitier -n app-system
helm get values app-multitier -n app-system
helm get manifest app-multitier -n app-system

# Historique des versions
helm history app-multitier -n app-system

# Rollback à une version antérieure
helm rollback app-multitier 1 -n app-system
```

### Mise à Jour
```bash
# Mettre à jour avec une nouvelle version
helm upgrade app-multitier ./helm-chart \
  --namespace app-system

# Mettre à jour avec values spécifiques
helm upgrade app-multitier ./helm-chart \
  --namespace app-system \
  -f helm-chart/values-prod.yaml

# Upgrade avec validation
helm upgrade app-multitier ./helm-chart \
  --namespace app-system \
  --dry-run --debug

# Upgrade + Rollback en cas d'erreur
helm upgrade app-multitier ./helm-chart \
  --namespace app-system \
  --atomic
```

### Suppression
```bash
# Supprimer une release (garde les données)
helm uninstall app-multitier -n app-system

# Supprimer les PVC (données)
kubectl delete pvc -n app-system --all
```

## 🔍 Kubernetes Operations

### État des Ressources
```bash
# Voir tous les objets déployés
kubectl get all -n app-system

# Voir les pods détails
kubectl get pods -n app-system -o wide
kubectl get pods -n app-system --show-labels

# Voir les services
kubectl get svc -n app-system
kubectl describe svc app-multitier-frontend -n app-system

# Voir les PVC/PV
kubectl get pvc -n app-system
kubectl get pv

# Voir les ConfigMap et Secrets
kubectl get cm -n app-system
kubectl get secrets -n app-system
```

### Logs & Debugging
```bash
# Logs d'un pod
kubectl logs deployment/app-multitier-backend -n app-system
kubectl logs app-multitier-backend-xyz123 -n app-system --tail=50

# Logs en continu
kubectl logs -f deployment/app-multitier-backend -n app-system

# Logs PostgreSQL
kubectl logs -f app-multitier-postgres-0 -n app-system

# Entrer dans un pod
kubectl exec -it app-multitier-backend-xyz123 -n app-system -- /bin/sh

# Voir les erreurs
kubectl describe pod app-multitier-backend-xyz123 -n app-system
kubectl events -n app-system --sort-by='.lastTimestamp'
```

### Port Forwarding
```bash
# Accéder au frontend (localhost:3000)
kubectl port-forward service/app-multitier-frontend 3000:80 -n app-system

# Accéder au backend (localhost:8000)
kubectl port-forward service/app-multitier-backend 8000:8000 -n app-system

# Accéder à PostgreSQL (localhost:5432)
kubectl port-forward service/app-multitier-postgres 5432:5432 -n app-system
```

### Test de Connectivité
```bash
# Test HTTP du frontend
curl http://localhost:3000

# Test HTTP du backend
curl http://localhost:8000/health
curl http://localhost:8000/api/status

# Depuis un pod
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://app-multitier-backend:8000/health -n app-system
```

## 🗄️ PostgreSQL Operations

### Connexion à la base
```bash
# Depuis un port-forward
PGPASSWORD=postgres123 psql -h localhost -U appuser -d appdb

# Depuis un pod temporaire
kubectl run -it --rm pgclient --image=postgres:15-alpine \
  --restart=Never -- \
  psql -h app-multitier-postgres -U appuser -d appdb
```

### Initialisation de la base
```bash
# Créer une table exemple
kubectl exec -it app-multitier-postgres-0 -n app-system -- psql -U appuser -d appdb << EOF
CREATE TABLE items (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO items (name, description) VALUES
  ('Item 1', 'First test item'),
  ('Item 2', 'Second test item');

SELECT * FROM items;
EOF
```

## 📊 Monitoring

### HPA & Scaling
```bash
# Voir l'état du HPA
kubectl get hpa -n app-system
kubectl describe hpa app-multitier-backend-hpa -n app-system

# Metrics server (pour les metrics)
kubectl get deployment metrics-server -n kube-system

# CPU/Memory des pods
kubectl top pods -n app-system
kubectl top nodes
```

### Événements & Alertes
```bash
# Voir les événements du cluster
kubectl get events -n app-system --sort-by='.lastTimestamp'
kubectl describe namespace app-system
```

## 🚀 Déploiement Multi-Environnement

### Développement
```bash
# Créer dev
helm install app-multitier ./helm-chart \
  -n app-dev --create-namespace \
  -f helm-chart/values-dev.yaml

# Vérifier
kubectl get all -n app-dev
```

### Staging
```bash
# Créer staging avec prodValues
helm install app-multitier ./helm-chart \
  -n app-staging --create-namespace \
  -f helm-chart/values-prod.yaml \
  --set replicaCount=2
```

### Production
```bash
# Créer prod avec haute dispo
helm install app-multitier ./helm-chart \
  -n app-prod --create-namespace \
  -f helm-chart/values-prod.yaml

# Monitoring
kubectl get all -n app-prod
kubectl describe hpa -n app-prod
```

## 🧹 Cleanup

```bash
# Supprimer tout un namespace
kubectl delete namespace app-system
kubectl delete namespace app-dev

# Supprimer tous les namespaces créés
kubectl delete namespace app-system app-dev app-staging app-prod
```

## 📋 Troubleshooting

### Pod ne démarre pas
```bash
# Voir le status
kubectl describe pod <pod-name> -n app-system

# Vérifier les logs
kubectl logs <pod-name> -n app-system

# Vérifier les ressources disponibles
kubectl top nodes
kubectl describe nodes
```

### Service pas accessible
```bash
# Vérifier les endpoints
kubectl get endpoints -n app-system

# Vérifier les sélecteurs
kubectl get pods --show-labels -n app-system
kubectl get services -n app-system -o wide
```

### Secrets non chargés
```bash
# Vérifier les secrets
kubectl get secrets -n app-system
kubectl describe secret app-multitier-secrets -n app-system

# Vérifier les variables d'env
kubectl exec <pod-name> -n app-system -- env | grep DB
```

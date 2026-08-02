# Kubernetes Ingress Controller et Load Balancing

## Description
Projet DevOps pour déployer et configurer un **Ingress Controller NGINX** sur Kubernetes, avec gestion avancée du load balancing, SSL/TLS, et routage multi-hôte.

## Objectif
- Déployer un cluster Kubernetes multi-nœud (via Kind/Minikube)
- Installer et configurer un **Ingress Controller NGINX**
- Créer des services avec **load balancing intelligent**
- Configurer le **SSL/TLS avec cert-manager**
- Tester le failover et la scalabilité des services
- Monitorer les performances de l'Ingress avec Prometheus

## Technos Utilisées
- **Kubernetes** : Cluster management
- **NGINX Ingress Controller** : Reverse proxy et load balancing
- **Cert-Manager** : Gestion des certificats SSL/TLS
- **Helm** : Package manager pour K8s
- **Prometheus** : Monitoring des métriques Ingress
- **Kind/Minikube** : Cluster local
- **kubectl** : CLI Kubernetes

## Architecture
```
Internet
   ↓
Ingress Controller (NGINX)
   ↓
Services (LoadBalancer/ClusterIP)
   ↓
Pods (Apps: api, web, db)
```

## Pré-requis
- Docker installé
- kubectl configuré
- Helm 3+
- Kind ou Minikube
- Terminal Unix/Linux

## Étapes de Réalisation

### 1. Créer un cluster Kubernetes
```bash
kind create cluster --name devops-ingress --config kind-cluster-config.yaml
kubectl cluster-info
```

### 2. Installer l'Ingress Controller NGINX
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer
```

### 3. Installer cert-manager pour SSL/TLS
```bash
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
```

### 4. Déployer les applications
```bash
kubectl apply -f manifests/
```

### 5. Configurer l'Ingress
```bash
kubectl apply -f ingress-rules.yaml
```

### 6. Tester l'accès
```bash
kubectl get ingress -A
curl -k https://app.local
curl -k https://api.local
```

### 7. Monitorer les performances
```bash
kubectl port-forward -n ingress-nginx svc/nginx-ingress-ingress-nginx-controller 9113:9113
# Accéder à Prometheus sur http://localhost:9090
```

## Ce qu'on Apprend
✅ **Ingress & Routing** : Configurer le routage multi-domaine et path-based  
✅ **Load Balancing** : Distribuer le trafic entre multiple replicas  
✅ **SSL/TLS** : Automatiser les certificats avec cert-manager  
✅ **Health Checks** : Liveness et readiness probes pour la résilience  
✅ **Monitoring** : Exposer et scraper les métriques Ingress  
✅ **Troubleshooting** : Déboguer les problèmes d'accès réseau  

## Fichiers du Projet
- `kind-cluster-config.yaml` : Configuration du cluster Kind
- `manifests/namespace.yaml` : Namespace dédié
- `manifests/deployment.yaml` : Deployments des applications
- `manifests/service.yaml` : Services (ClusterIP et LoadBalancer)
- `ingress-rules.yaml` : Règles Ingress avec SSL
- `cert-issuer.yaml` : Issuer de certificats Let's Encrypt
- `prometheus-values.yaml` : Configuration Prometheus pour scraper les métriques
- `test-ingress.sh` : Script de test de l'Ingress

## Résultat Attendu
- ✅ Cluster K8s avec 3 nœuds
- ✅ Ingress Controller actif et responsive
- ✅ Services exposés via HTTPS
- ✅ Certificats auto-renouvelés
- ✅ Load balancing fonctionnel avec failover
- ✅ Métriques collectées par Prometheus

## Durée Estimée
**1 journée** (3-4h avec les dépendances, tests et troubleshooting)

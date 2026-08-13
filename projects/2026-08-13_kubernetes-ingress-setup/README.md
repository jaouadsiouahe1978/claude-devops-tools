# Kubernetes Ingress Controller Setup & Configuration

## 📋 Description

Ce projet vous enseigne comment configurer et gérer un **Ingress Controller** dans Kubernetes. L'Ingress est essentiel pour exposer vos services Kubernetes à l'extérieur du cluster de manière professionnelle, en gérant SSL/TLS, le routing HTTP(S) et l'équilibrage de charge.

Nous allons installer **NGINX Ingress Controller**, configurer des règles d'ingress pour plusieurs applications, et mettre en place le SSL avec Let's Encrypt et cert-manager.

## 🎯 Objectif

- Installer et configurer NGINX Ingress Controller
- Déployer plusieurs applications de démonstration
- Créer des règles Ingress pour le routing basé sur les hôtes/chemins
- Configurer SSL/TLS automatique avec cert-manager
- Tester le routing et la résiliation SSL

## 🛠 Technologies

- **Kubernetes** (1.24+)
- **NGINX Ingress Controller** (4.x)
- **cert-manager** pour gestion SSL automatique
- **kubectl** pour CLI
- **Helm** (optionnel mais recommandé)
- **Docker** pour les images de test

## 📋 Pré-requis

- Un cluster Kubernetes en fonctionnement (Minikube, Kind, ou cloud)
- kubectl configuré pour accéder au cluster
- Helm 3+ installé (optionnel)
- Accès à un nom de domaine (ou localhost pour tester)
- 2+ CPU et 2GB RAM disponibles

## 📝 Étapes de Réalisation

### 1. Installer NGINX Ingress Controller

```bash
# Via Helm (recommandé)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer

# Vérifier l'installation
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

### 2. Installer cert-manager pour SSL automatique

```bash
# Installation via Helm
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

kubectl get pods -n cert-manager
```

### 3. Configurer ClusterIssuer pour Let's Encrypt

Créer un certificat autosigné ou Let's Encrypt issuer.

### 4. Déployer des applications de test

Déployer au minimum 2 applications (app1, app2) avec services ClusterIP.

### 5. Créer des règles Ingress

- Ingress pour app1.example.com
- Ingress pour app2.example.com
- Ingress avec routing par chemin: /api → app-api
- Configuration SSL automatique

### 6. Tester le routing

```bash
# Test via DNS (si domaine configuré)
curl https://app1.example.com

# Test local avec /etc/hosts
curl -H "Host: app1.local" http://localhost
```

## 📚 Ce qu'on apprend

✅ Différence entre Service et Ingress en Kubernetes  
✅ Configuration du routing HTTP/HTTPS via Ingress  
✅ Gestion des certificats SSL avec cert-manager  
✅ Routing basé sur les hôtes (host-based routing)  
✅ Routing basé sur les chemins (path-based routing)  
✅ Configuration de réécritures d'URL  
✅ Gestion des TLS secrets  
✅ Monitoring de l'Ingress Controller  
✅ Troubleshooting des problèmes d'Ingress  

## 🔍 Structure du Projet

```
2026-08-13_kubernetes-ingress-setup/
├── README.md
├── 1-namespace.yaml              # Namespaces
├── 2-nginx-ingress-install.sh    # Script installation NGINX
├── 3-cert-manager-install.sh     # Script installation cert-manager
├── 4-apps-deployment.yaml        # Déploiement apps de test
├── 5-ingress-rules.yaml          # Règles Ingress
├── 6-tls-issuer.yaml             # ClusterIssuer Let's Encrypt
├── 7-https-ingress.yaml          # Ingress avec TLS
├── 8-advanced-ingress.yaml       # Ingress avancé (rewrite, rate-limit)
├── test-ingress.sh               # Script de test
└── monitoring-ingress.yaml       # Scrape Prometheus pour Ingress
```

## 🚀 Démarrage Rapide

```bash
# 1. Créer les namespaces
kubectl apply -f 1-namespace.yaml

# 2. Installer NGINX et cert-manager
bash 2-nginx-ingress-install.sh
bash 3-cert-manager-install.sh

# 3. Déployer les apps de test
kubectl apply -f 4-apps-deployment.yaml

# 4. Appliquer les règles Ingress
kubectl apply -f 5-ingress-rules.yaml

# 5. Tester
bash test-ingress.sh
```

## 🔧 Commandes Utiles

```bash
# Vérifier les Ingress
kubectl get ingress -A
kubectl describe ingress my-ingress

# Vérifier les certificats
kubectl get certificates -A
kubectl describe certificate my-cert

# Vérifier le controller
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller -f

# Accéder au dashboard du controller
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80

# Vérifier les endpoints
kubectl get endpoints -A
```

## 🐛 Troubleshooting Courant

| Problème | Solution |
|----------|----------|
| 503 Bad Gateway | Vérifier le service backend et les sélecteurs |
| SSL Certificate invalid | Vérifier cert-manager logs et ClusterIssuer |
| Ingress sans IP | Vérifier LoadBalancer external IP |
| Routes ne répondent pas | Vérifier le routing config dans Ingress |

## 💡 Pour Aller Plus Loin

- Implémenter le rate limiting sur l'Ingress
- Ajouter l'authentication basique HTTP
- Configurer le CORS
- Mettre en place le monitoring Prometheus
- Implémenter le blue-green deployment avec Ingress
- Utiliser plusieurs Ingress Controllers

## 📖 Ressources

- [Kubernetes Ingress Docs](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [cert-manager Documentation](https://cert-manager.io/docs/)
- [Let's Encrypt](https://letsencrypt.org/)

---

**Durée estimée:** 3-4 heures | **Difficulté:** ⭐⭐⭐ Intermédiaire

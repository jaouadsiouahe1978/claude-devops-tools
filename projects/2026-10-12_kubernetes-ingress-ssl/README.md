# Kubernetes Ingress Controller avec SSL/TLS et Load Balancing

## 📋 Description

Ce projet montre comment configurer un **contrôleur Ingress Nginx** dans Kubernetes avec **SSL/TLS automatique** via cert-manager (Let's Encrypt), des **règles de routing avancées**, et du **load balancing**.

- Configuration d'Nginx Ingress Controller
- Certificats SSL/TLS auto-signés ou Let's Encrypt
- Routing par hostname et path
- Rate limiting et réwrite URLs
- Backend services avec health checks
- Monitoring avec métriques Prometheus

## 🎯 Objectifs

- Exposer une application Kubernetes via un Ingress Controller
- Configurer SSL/TLS pour HTTPS
- Implémenter du routing intelligent
- Comprendre le load balancing Layer 7 (HTTP/HTTPS)
- Automatiser la gestion des certificats

## 🛠️ Technologies

- **Kubernetes** 1.24+
- **Nginx Ingress Controller**
- **cert-manager** (Let's Encrypt)
- **kubectl** et helm (optionnel)
- **OpenSSL** pour tests

## 📦 Pré-requis

- Cluster Kubernetes fonctionnel (minikube, kind ou cloud)
- kubectl configuré et connecté
- helm 3.x (optionnel, pour installation rapide)
- Accès root/sudo

## 🚀 Étapes de Réalisation

### 1. Installation d'Nginx Ingress Controller

```bash
# Avec Helm (recommandé)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --values helm-values.yaml

# Ou avec manifests kubectl
kubectl apply -f 1-ingress-controller.yaml
```

### 2. Installation de cert-manager

```bash
# Installer le CRD
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.crds.yaml

# Installer cert-manager via Helm
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace
```

### 3. Déployer les services backend

```bash
kubectl apply -f 2-backend-services.yaml
```

### 4. Configurer les certificats SSL

```bash
# Self-signed pour test
kubectl apply -f 3-cert-self-signed.yaml

# Ou Let's Encrypt (production)
kubectl apply -f 4-cert-letsencrypt.yaml
```

### 5. Appliquer les règles Ingress

```bash
kubectl apply -f 5-ingress-rules.yaml
kubectl apply -f 6-ingress-advanced.yaml
```

### 6. Vérifier la configuration

```bash
# Voir les Ingress créés
kubectl get ingress -A

# Voir les certificats
kubectl get certificate -A

# Voir les services
kubectl get svc -n ingress-nginx

# Voir les pods Nginx
kubectl get pods -n ingress-nginx

# Logs du contrôleur
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

### 7. Tester les endpoints

```bash
# Récupérer l'IP du LoadBalancer
INGRESS_IP=$(kubectl get svc -n ingress-nginx nginx-ingress-ingress-nginx \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Tester HTTP
curl -v http://$INGRESS_IP/

# Tester HTTPS (self-signed)
curl -k https://$INGRESS_IP/

# Avec hostname
curl -v -H "Host: api.example.local" http://$INGRESS_IP/api

# Vérifier le certificat
openssl s_client -connect $INGRESS_IP:443
```

## 📚 Ce qu'on Apprend

### Concepts Clés

1. **Ingress Controller** : Gateway d'entrée pour le trafic HTTP(S)
2. **Routing Layer 7** : Décisions basées sur Host, Path, Headers
3. **SSL/TLS Termination** : Déchiffrement au point d'entrée
4. **Certificate Management** : Automatisation avec cert-manager
5. **Load Balancing** : Distribution du trafic vers les services
6. **Rate Limiting** : Protection contre les abus
7. **URL Rewriting** : Transformation des requêtes

### Skillset DevOps/SRE

- Configuration Kubernetes avancée
- Gestion des certificats en production
- Networking et reverse proxying
- Monitoring du trafic ingress
- Troubleshooting des problèmes de connexion

## 📂 Structure du Projet

```
2026-10-12_kubernetes-ingress-ssl/
├── README.md                    # Ce fichier
├── 1-ingress-controller.yaml    # Déploiement du contrôleur Nginx
├── 2-backend-services.yaml      # Services backend (nginx, apache, etc)
├── 3-cert-self-signed.yaml      # Certificate self-signed
├── 4-cert-letsencrypt.yaml      # Certificate Let's Encrypt
├── 5-ingress-rules.yaml         # Règles Ingress simples
├── 6-ingress-advanced.yaml      # Règles avancées (rewrite, rate-limit)
├── 7-ingress-tls.yaml           # Ingress avec configuration TLS
├── helm-values.yaml             # Configuration Helm
├── test-requests.sh             # Script de test
└── cleanup.sh                   # Nettoyage des ressources
```

## 🔧 Cas d'Usage Réels

- **API Gateway** : Exposer plusieurs microservices
- **Multi-tenant** : Isolation par subdomain
- **Canary Deployment** : Routing vers versions A/B
- **Rate Limiting** : Protéger les services backend
- **Authentication** : OAuth2, JWT au niveau Ingress
- **CDN / Caching** : Cacher les réponses

## 🎓 Points de Pratique

- [ ] Installer Nginx Ingress Controller
- [ ] Configurer un certificat self-signed
- [ ] Exposer une application via Ingress
- [ ] Mettre à jour le certificat
- [ ] Implémenter le rate limiting
- [ ] Configurer le rewrite d'URL
- [ ] Ajouter l'authentification basique

## 🚨 Troubleshooting

**Ingress pas accessible :**
```bash
# Vérifier l'IP du LoadBalancer
kubectl get svc -n ingress-nginx

# Vérifier les endpoints
kubectl get endpoints -n default
```

**Certificat invalide :**
```bash
# Vérifier le statut du certificat
kubectl describe certificate -n default

# Voir les erreurs de cert-manager
kubectl logs -n cert-manager -l app=cert-manager
```

**Trafic ne passe pas :**
```bash
# Vérifier les logs nginx
kubectl exec -n ingress-nginx <pod-name> -- tail -f /var/log/nginx/error.log

# Vérifier la config générée
kubectl exec -n ingress-nginx <pod-name> -- cat /etc/nginx/nginx.conf
```

## 📖 Ressources

- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [cert-manager Documentation](https://cert-manager.io/docs/)
- [Let's Encrypt](https://letsencrypt.org/)

## ✅ Validation

Projet réussi quand :
- ✅ Nginx Ingress Controller est déployé et actif
- ✅ Services backend répondent aux requêtes
- ✅ Certificats SSL sont créés automatiquement
- ✅ HTTPS fonctionne sans erreurs
- ✅ Routing par hostname et path marche
- ✅ Rate limiting fonctionne

---

**Durée estimée** : 60-90 minutes  
**Niveau** : Intermédiaire à Avancé  
**Savoir-faire acquis** : Ingress, SSL/TLS, Networking Kubernetes

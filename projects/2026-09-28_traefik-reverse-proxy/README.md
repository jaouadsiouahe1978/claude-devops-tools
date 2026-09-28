# Traefik: Reverse Proxy & Load Balancer Moderne avec Docker Compose

## 📋 Description

Traefik est un reverse proxy/load balancer moderne conçu pour les architectures en conteneurs. Ce projet met en place une infrastructure complète avec :

- **Reverse proxy** automatique pour plusieurs services
- **Découverte dynamique** des services (auto-configuration)
- **SSL/TLS** automatique avec Let's Encrypt
- **Middleware** pour la sécurité et la performance
- **Dashboard** web pour le monitoring
- **Load balancing** avec différentes stratégies

## 🎯 Objectifs

- Apprendre à configurer Traefik avec Docker Compose
- Mettre en place un reverse proxy automatique
- Gérer les certificats SSL/TLS dynamiquement
- Router le trafic entre plusieurs services
- Implémenter la sécurité avec middleware
- Monitorer les services avec le dashboard

## 🛠️ Technologies Utilisées

- **Docker** & **Docker Compose** - Orchestration des conteneurs
- **Traefik v3** - Reverse proxy & load balancer
- **Let's Encrypt** - Certificats SSL/TLS automatiques
- **Sample Apps** - Nginx, Apache, API simple en Python
- **Traefik Dashboard** - Interface de monitoring

## 📦 Pré-requis

- Docker et Docker Compose installés (version récente)
- Domaine de test (ou utiliser localhost)
- Pour SSL/TLS en production : domaine réel et accès au port 80/443
- Connaissances basiques en Docker Compose

## 🚀 Étapes de Réalisation

### 1. Structure du Projet
```
2026-09-28_traefik-reverse-proxy/
├── docker-compose.yml          # Configuration principale
├── traefik.yml                 # Configuration Traefik
├── acme.json                   # Certificats Let's Encrypt
├── dynamic-config.yml          # Routes et middleware dynamiques
├── services/
│   ├── web1/Dockerfile         # Service web 1 (Nginx)
│   ├── web2/Dockerfile         # Service web 2 (Apache)
│   └── api/app.py              # Service API simple
└── README.md
```

### 2. Configuration Traefik
- Activer le provider Docker pour découverte auto
- Configurer les entrypoints HTTP/HTTPS
- Implémenter l'auto-renouvellement des certificats
- Ajouter du middleware (rate limiting, redirect, auth)

### 3. Déploiement des Services
- Web 1 : Simple Nginx avec label Traefik
- Web 2 : Apache avec configuration
- API : Service Python Flask exposé par Traefik

### 4. Configuration SSL/TLS
- Configurer Let's Encrypt (ou TLS auto-signé en dev)
- Automatiser le renouvellement
- Redirect HTTP vers HTTPS

### 5. Monitoring & Testing
- Accéder au dashboard Traefik
- Tester les routes des services
- Vérifier les certificats SSL
- Implémenter la logging

## 🎓 Ce Qu'on Apprend

### DevOps Skills
- ✅ Configuration d'un reverse proxy moderne
- ✅ Gestion des certificats SSL/TLS en production
- ✅ Service discovery automatique
- ✅ Load balancing et failover
- ✅ Middleware pour sécurité (rate limit, auth, redirects)
- ✅ Monitoring avec dashboard
- ✅ Docker labels pour configuration déclarative

### Architecture
- ✅ Pattern reverse proxy + backend services
- ✅ Séparation des responsabilités
- ✅ Infrastructure as Code (Traefik config)
- ✅ Scalabilité avec load balancing

### Sécurité
- ✅ HTTPS/TLS obligatoire
- ✅ Middleware de protection
- ✅ Gestion des domaines multiples

## ⚙️ Démarrage Rapide

```bash
# 1. Préparer les fichiers de certificats
touch acme.json
chmod 600 acme.json

# 2. Lancer l'infrastructure
docker-compose up -d

# 3. Vérifier le statut
docker-compose ps

# 4. Accéder au dashboard
# En local: http://localhost:8080
# Routes: http://web1.localhost, http://web2.localhost, http://api.localhost

# 5. Voir les logs
docker-compose logs -f

# 6. Arrêter les services
docker-compose down
```

## 📊 Cas d'Usage Réels

1. **Migration d'infrastructure** : Remplacer Nginx/HAProxy par Traefik
2. **Microservices** : Router automatiquement vers les services découverts
3. **Multi-domaine** : Gérer plusieurs domaines avec une seule instance
4. **CI/CD Pipeline** : Déployer de nouveaux services automatiquement
5. **Development** : Tester plusieurs versions en parallèle

## 🔍 Points Clés

- Traefik écoute le Docker daemon et se reconfigure automatiquement
- Les labels Docker sur les conteneurs définissent le routing
- ACME (Let's Encrypt) gère les certificats automatiquement
- Middleware = couche de logique entre client et service (auth, rate limit, compression)
- Dashboard fourni une vue en temps réel du trafic

## 📚 Pour Aller Plus Loin

- Configurer Traefik avec Kubernetes
- Implémenter l'authentification OAuth2
- Mettre en place le circuit breaker
- Configurer les metrics Prometheus
- Load balancing avec health checks avancés

---

**Durée estimée** : 2-3 heures  
**Niveau** : Intermédiaire  
**Bénéfice DevOps** : Compréhension du reverse proxy moderne et service discovery

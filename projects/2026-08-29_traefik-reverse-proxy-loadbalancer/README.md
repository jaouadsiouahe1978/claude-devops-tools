# Traefik : Reverse Proxy & Load Balancing

## 📚 Objectif
Mettre en place un reverse proxy moderne avec Traefik pour router le trafic vers plusieurs services Docker, configurer le SSL/TLS automatique avec Let's Encrypt, et implémenter du load balancing avec middleware.

## 🛠️ Technologies
- **Traefik v2.x** - Reverse proxy & load balancer
- **Docker & Docker Compose** - Orchestration des conteneurs
- **Let's Encrypt** - SSL/TLS automatique
- **Python Flask** - Services backend d'exemple
- **Labels Docker** - Configuration déclarative

## 🎯 Cas d'usage
Ce projet simule une infrastructure réelle avec:
- **3 services backend** (API 1, API 2, Web App)
- **Routage automatique** vers les services via Traefik
- **Load balancing** avec répartition du trafic
- **SSL/TLS** automatique et renouvellement
- **Dashboard Traefik** pour le monitoring
- **Middleware** (compression, rate limiting, headers de sécurité)

## 📋 Pré-requis
- Docker & Docker Compose (v20.10+)
- Connaissance basique Docker
- Terminal Linux/Mac
- ⚠️ Note: Pour SSL/TLS réel, utiliser un domaine valide pointant vers votre IP

## 🚀 Installation & Exécution

### 1. Cloner/Accéder au projet
```bash
cd projects/2026-08-29_traefik-reverse-proxy-loadbalancer
```

### 2. Créer les fichiers de configuration
Les fichiers suivants sont fournis:
- `docker-compose.yml` - Orchestration complète
- `traefik.yml` - Configuration Traefik
- `app.py` - Service Flask
- `docker-compose.override.yml` - Configuration développement (certificats auto-signés)

### 3. Lancer l'infrastructure
```bash
# Préparation
mkdir -p traefik-certs
chmod 600 traefik-certs/acme.json

# Démarrage
docker-compose up -d

# Vérifier le status
docker-compose ps

# Logs Traefik
docker-compose logs -f traefik
```

### 4. Tester les services

#### En développement (certificats auto-signés)
```bash
# Tester chaque service
curl -k -H "Host: api1.localhost" http://localhost
curl -k -H "Host: api2.localhost" http://localhost
curl -k -H "Host: app.localhost" http://localhost

# Accéder au dashboard Traefik
https://traefik.localhost:8443 (accepter certificat auto-signé)
```

#### Avec domaine réel (production)
1. Modifier `docker-compose.yml` - Remplacer `localhost` par votre domaine
2. Assurer que le domaine pointe vers votre serveur
3. Traefik renouvellera automatiquement les certificats Let's Encrypt

### 5. Arrêter l'infrastructure
```bash
docker-compose down
```

## 📁 Architecture des fichiers

```
.
├── README.md                  # Ce fichier
├── docker-compose.yml         # Orchestration Traefik + services
├── traefik.yml               # Configuration Traefik avancée
├── traefik-config.toml       # Config middleware & routes additionnelles
├── app.py                    # Service Flask
├── Dockerfile                # Image Flask commune
├── requirements.txt          # Dépendances Python
└── traefik-certs/           # Certificats ACME (créé automatiquement)
    └── acme.json            # Base de données certificats
```

## 🔑 Concepts clés

### 1. **Traefik comme Ingress Controller**
Traefik lit les labels Docker et configure automatiquement les routes:
```yaml
labels:
  - traefik.enable=true
  - traefik.http.routers.api1.rule=Host(`api1.localhost`)
  - traefik.http.services.api1.loadbalancer.server.port=5000
```

### 2. **Load Balancing**
Plusieurs instances du même service => distribution automatique

### 3. **Middleware Traefik**
- **Compression**: Compresse les réponses gzip
- **Rate Limiting**: Limite le trafic (100 req/min)
- **Security Headers**: Ajoute les headers de sécurité (HSTS, X-Frame-Options, etc.)

### 4. **Let's Encrypt Integration**
Traefik provisionne et renouvelle automatiquement les certificats

### 5. **Dashboard & Monitoring**
- Accès au dashboard: `https://traefik.localhost:8443`
- Voir tous les services, routes, certificats
- Monitoring temps réel du trafic

## 📊 Exercices pratiques

### Exercice 1: Ajouter un nouveau service
Modifier `docker-compose.yml` pour ajouter un 4ème service.

### Exercice 2: Configurer du rate limiting
Ajouter des limitations de trafic par IP.

### Exercice 3: Mettre en place une authentification basique
Utiliser le middleware `basicauth` de Traefik.

### Exercice 4: Load balancing avec sticky sessions
Configurer des sessions sticky.

## 📚 Ce qu'on apprend

✅ **Concepts Traefik:**
- Configuration déclarative via labels Docker
- Routage automatique et détection de services
- Load balancing intelligent
- Middleware et plugins

✅ **Networking DevOps:**
- Reverse proxy en production
- Certificats SSL/TLS automatiques
- HTTPS et sécurité
- Routage multi-services

✅ **Docker & DevOps:**
- Architecture multi-conteneurs
- Networking Docker compose
- Bonnes pratiques de configuration
- Infrastructure as Code

✅ **Pratiques Sécurité:**
- HSTS et security headers
- Authentification/Authorization
- Rate limiting
- Gestion des certificats

## 🔒 Sécurité & Production

### Checklist avant production:
- [ ] Utiliser des certificats Let's Encrypt valides
- [ ] Configurer l'authentification (basicauth, OAuth2)
- [ ] Mettre en place du rate limiting
- [ ] Activer les logs d'audit
- [ ] Configurer les health checks
- [ ] Ajouter du monitoring (Prometheus)
- [ ] Mettre à jour Traefik régulièrement

## 🐛 Troubleshooting

### Certificat expiré
```bash
# Vérifier la date du certificat
docker exec traefik openssl x509 -in /certs-acme/acme.json -noout -text
```

### Service ne répond pas
```bash
# Vérifier les logs Traefik
docker-compose logs traefik

# Vérifier la santé des services
docker-compose ps

# Tester directement le service
docker exec <container> curl http://localhost:5000
```

### Erreur de routage
Accéder au dashboard Traefik pour vérifier la configuration.

## 🌐 Ressources

- [Documentation Traefik officielle](https://doc.traefik.io/traefik/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Let's Encrypt](https://letsencrypt.org/)
- [HTTP Security Headers](https://securityheaders.com/)

---
**Créé le:** 2026-08-29  
**Durée:** 1 journée  
**Niveau:** Débutant à Intermédiaire  
**Domaines:** DevOps, Networking, Security, Docker

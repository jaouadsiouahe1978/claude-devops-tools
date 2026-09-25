# Nginx Reverse Proxy avec Load Balancing et SSL/TLS

## 📋 Objectif
Configurer un reverse proxy Nginx avec load balancing pour plusieurs services backend, avec support SSL/TLS et certificats auto-signés pour le développement.

## 🔧 Technos utilisées
- **Nginx** - Reverse proxy, load balancing, compression
- **Docker & Docker Compose** - Conteneurisation et orchestration
- **SSL/TLS** - Certificats auto-signés (mkcert ou OpenSSL)
- **Python Flask** - Services backend pour tester le load balancing
- **curl/jq** - Tests des endpoints

## 📚 Ce qu'on apprend
✅ Configuration avancée de Nginx (reverse proxy, upstream, load balancing)  
✅ Gestion des certificats SSL/TLS et HTTPS  
✅ Load balancing avec Nginx (round-robin, least connections)  
✅ Headers personnalisés et proxy headers  
✅ Compression de réponses HTTP  
✅ Health checks et retry logic  
✅ Gestion du multi-container avec Docker Compose  
✅ Logs et monitoring d'un reverse proxy  

## 📦 Pré-requis
- Docker et Docker Compose installés
- curl pour tester les endpoints
- (Optionnel) mkcert pour générer des certificats de développement

## 🚀 Étapes de réalisation

### 1. Générer les certificats SSL/TLS
```bash
# Générer un certificat auto-signé valable 365 jours
openssl req -x509 -newkey rsa:2048 -keyout nginx/ssl/nginx.key \
  -out nginx/ssl/nginx.crt -days 365 -nodes \
  -subj "/C=FR/ST=Isere/L=Grenoble/O=DevOps/CN=localhost"
```

### 2. Démarrer l'infrastructure
```bash
docker-compose up -d
docker-compose logs -f
```

### 3. Tester le reverse proxy
```bash
# HTTP - redirige vers HTTPS
curl -i http://localhost/

# HTTPS (accepter certificat auto-signé)
curl -k https://localhost/

# Tester le load balancing (plusieurs requêtes)
for i in {1..10}; do curl -k https://localhost/status; done

# Tester un endpoint spécifique
curl -k https://localhost/api/users

# Voir les headers de réponse
curl -i -k https://localhost/
```

### 4. Vérifier la distribution du load balancing
```bash
docker-compose logs backend-1
docker-compose logs backend-2
docker-compose logs backend-3
```

### 5. Arrêter l'infrastructure
```bash
docker-compose down
```

## 📂 Structure du projet
```
.
├── docker-compose.yml          # Définition des services (nginx + backends)
├── nginx/
│   ├── Dockerfile              # Image Nginx personnalisée
│   ├── nginx.conf              # Configuration Nginx
│   ├── ssl/                    # Certificats SSL/TLS
│   │   ├── nginx.crt
│   │   └── nginx.key
│   └── conf.d/
│       └── default.conf        # Configuration du reverse proxy
├── backend/
│   ├── Dockerfile              # Image Flask backend
│   ├── app.py                  # Application Flask
│   └── requirements.txt         # Dépendances Python
├── .gitignore                  # Fichiers à ignorer
└── README.md                   # Ce fichier
```

## 🔐 Configuration SSL/TLS
- **Certificats auto-signés** pour développement local
- **HTTPS obligatoire** (redirection HTTP → HTTPS)
- **Certificat valide 365 jours** - à renouveler après

## ⚖️ Load Balancing
- **Type**: Round-robin (défaut, rotation entre backends)
- **Retry**: Automatique en cas de backend défaillant
- **Health checks**: Timeout et retry configurés
- **3 instances** backend pour tester la distribution

## 📊 Monitoring et Logs
```bash
# Voir les logs Nginx
docker-compose logs nginx

# Voir les logs backends
docker-compose logs backend-1

# Logs temps réel
docker-compose logs -f
```

## 🐛 Troubleshooting
- **Erreur certificat HTTPS**: Utiliser `curl -k` pour ignorer les avertissements
- **Backends ne répondent pas**: Vérifier `docker-compose logs backend-X`
- **Port 80/443 déjà utilisé**: Modifier les ports dans docker-compose.yml
- **Certificat expiré**: Régénérer avec la commande openssl ci-dessus

## 🎯 Points clés DevOps
1. **Reverse proxy** comme entrypoint unique
2. **Load balancing** pour distribuer la charge
3. **SSL/TLS** pour sécuriser les communications
4. **Container health** et gestion des dépendances
5. **Logging centralisé** pour monitoring

## 📖 Ressources complémentaires
- [Nginx Reverse Proxy Docs](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
- [Nginx Load Balancing](https://docs.nginx.com/nginx/admin-guide/load-balancer/)
- [OpenSSL Cert Generation](https://www.ssl.com/article/using-openssl-to-generate-ssl-certificates/)
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)

---
**Temps estimé**: 1-2 heures | **Niveau**: Intermédiaire | **Tags**: Nginx, LoadBalancing, SSL/TLS, Docker

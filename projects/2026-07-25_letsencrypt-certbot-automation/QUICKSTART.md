# Quick Start Guide - Let's Encrypt Automation

## 1. Configuration initiale

```bash
# Copier le fichier de configuration d'exemple
cp .env.example .env

# Éditer .env avec vos domaines et email
nano .env
```

**Configurations essentielles:**
- `DOMAINS=votre-domaine.com,www.votre-domaine.com`
- `EMAIL=admin@votre-domaine.com`

## 2. Lancer les containers

```bash
# Créer le répertoire pour les certificats
mkdir -p certs
mkdir -p certbot/www

# Lancer Docker Compose
docker-compose up -d

# Vérifier les logs
docker-compose logs -f certbot
```

## 3. Vérifier l'état des certificats

```bash
# Voir les certificats disponibles
docker-compose exec certbot ls -la /etc/letsencrypt/live/

# Vérifier la date d'expiration
docker-compose exec certbot openssl x509 \
  -in /etc/letsencrypt/live/votre-domaine.com/cert.pem \
  -noout -enddate

# Exécuter un check de monitoring
docker-compose exec monitoring /check-certs.sh
```

## 4. Configuration des alertes (optionnel)

### Slack
1. Créer un webhook: https://api.slack.com/messaging/webhooks
2. Ajouter dans .env:
```bash
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

### Email
1. Configurer un serveur mail sur l'hôte
2. Ajouter dans .env:
```bash
EMAIL_TO=admin@votre-domaine.com
```

## 5. Test du renouvellement (simulation)

```bash
# Forcer un test de renouvellement (sans modifier les certificats)
docker-compose exec certbot certbot renew --dry-run

# Vérifier les hooks
docker-compose exec certbot certbot renew --renew-hook "/renewal-hook.sh renew" --dry-run
```

## 6. Accès aux certificats

Les certificats sont stockés dans le dossier `./certs/`:
- Certificat public: `./certs/live/votre-domaine.com/fullchain.pem`
- Clé privée: `./certs/live/votre-domaine.com/privkey.pem`

## 7. Maintenance

### Voir les logs
```bash
docker-compose logs -f nginx
docker-compose logs -f certbot
docker-compose logs -f monitoring
```

### Arrêter les services
```bash
docker-compose down
```

### Redémarrer un service
```bash
docker-compose restart nginx
docker-compose restart certbot
```

## Dépannage

### Certificate not issued
```bash
docker-compose logs certbot
# Vérifier que le domaine pointe vers votre serveur
# Vérifier que les ports 80 et 443 sont accessibles
```

### Nginx not reloading
```bash
docker-compose exec nginx nginx -t
docker-compose exec nginx nginx -s reload
```

### Disk space issues
```bash
# Nettoyer les vieux certificats
docker-compose exec certbot certbot delete

# Voir l'utilisation du disque
du -sh ./certs/
```

## Liens utiles
- Let's Encrypt: https://letsencrypt.org
- Certbot Docs: https://certbot.eff.org
- Nginx SSL: https://nginx.org/en/docs/http/ngx_http_ssl_module.html

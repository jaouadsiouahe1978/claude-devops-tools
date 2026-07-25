# Let's Encrypt & Certbot - Automatisation des Certificats SSL/TLS

## Objectif
Configurer une solution complète d'automatisation et de renouvellement des certificats SSL/TLS avec Let's Encrypt et Certbot. Inclut la gestion multi-domaine, le monitoring des certificats expirés et les alertes.

## Technos utilisées
- **Certbot** : Client Let's Encrypt pour générer et renouveler les certificats
- **Let's Encrypt** : Autorité de certification gratuite et automatisée
- **Bash** : Scripts d'automatisation et de monitoring
- **Cron** : Tâches planifiées pour le renouvellement automatique
- **Nginx** : Serveur web pour héberger les certificats
- **OpenSSL** : Outils de gestion SSL/TLS

## Ce qu'on apprend
1. Installation et configuration de Certbot
2. Automatisation des renouvellements de certificats
3. Gestion multi-domaine et wildcards
4. Monitoring des dates d'expiration
5. Alertes email ou Slack pour les certificats expirant bientôt
6. Hooks Certbot pour la validation et le redéploiement
7. Bonnes pratiques de sécurité SSL/TLS

## Étapes de réalisation

### 1. Installation des dépendances
```bash
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx nginx openssl
```

### 2. Configuration initiale
- Configurer le domaine dans Nginx
- Générer le certificat initial avec Certbot
- Valider la configuration SSL

### 3. Automatisation
- Configurer les renouvellements automatiques via Cron
- Créer des hooks pour redémarrer les services
- Tester le processus de renouvellement

### 4. Monitoring
- Script Bash pour checker les dates d'expiration
- Alertes automatiques avant expiration
- Dashboard de suivi des certificats

### 5. Déploiement
- Docker Compose avec tous les services
- Scripts d'initialisation
- Documentation de maintenance

## Structure du projet
```
2026-07-25_letsencrypt-certbot-automation/
├── README.md
├── docker-compose.yml
├── nginx/
│   ├── Dockerfile
│   └── nginx.conf
├── certbot/
│   ├── Dockerfile
│   ├── init-certbot.sh
│   └── renewal-hook.sh
├── monitoring/
│   ├── check-certs.sh
│   └── alert-expiry.sh
└── config/
    ├── certbot-renewal.sh
    └── cron-setup.sh
```

## Usage
1. Cloner le projet
2. Configurer vos domaines dans `docker-compose.yml`
3. Lancer : `docker-compose up -d`
4. Vérifier les certificats : `./monitoring/check-certs.sh`
5. Configurer les alertes email/Slack

## Prérequis
- Docker & Docker Compose
- Domaine pointant vers votre serveur
- Port 80 et 443 disponibles
- Accès root ou sudo

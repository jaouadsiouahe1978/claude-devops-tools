# 🛡️ Linux Firewall Security - UFW & Fail2ban

## Objectif
Sécuriser un serveur Linux en mettant en place une stratégie firewall robuste avec **UFW** (Uncomplicated Firewall) et protection contre les attaques par force brute avec **fail2ban**. Ce projet simule un environnement d'infrastructure où il faut durcir (harden) les accès réseau.

## Technologies utilisées
- **UFW** (Uncomplicated Firewall) - Gestion simplifié du firewall iptables
- **fail2ban** - Protection automatique contre les attaques par force brute
- **Bash scripting** - Automatisation et configuration
- **Linux systemd** - Gestion des services
- **curl/ssh** - Tests des accès réseau

## Architecture
```
┌─────────────────────────────────────────┐
│         Internet/Attaquants             │
└──────────────────────────────────────────┘
           ↓ (trafic entrant)
┌─────────────────────────────────────────┐
│      UFW Firewall (iptables)            │
│  - Règles de port entrants/sortants     │
│  - Politique par défaut (DROP)          │
└──────────────────────────────────────────┘
           ↓ (trafic autorisé)
┌─────────────────────────────────────────┐
│    fail2ban (Protection attaques)       │
│  - Détecte tentatives SSH échouées      │
│  - Ban automatique IP après N essais    │
│  - Whitelist & alertes                  │
└──────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│      Services (SSH, HTTP, HTTPS)        │
└──────────────────────────────────────────┘
```

## Pré-requis
- Serveur Linux (Ubuntu/Debian ou CentOS/RHEL)
- Accès root ou sudo
- Connexion SSH en place (avant d'appliquer les règles!)
- UFW et fail2ban à installer

## Étapes de réalisation

### 1. Installation et configuration UFW
```bash
# Installation
sudo apt update && sudo apt install -y ufw

# Politiques par défaut (par défaut: DENY entrant, ALLOW sortant)
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Autoriser SSH (AVANT d'activer le firewall!)
sudo ufw allow 22/tcp

# Autoriser HTTP et HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Activer UFW
sudo ufw enable

# Vérifier le statut
sudo ufw status verbose
```

### 2. Installation et configuration fail2ban
```bash
# Installation
sudo apt install -y fail2ban

# Copier la configuration par défaut
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Configurer les règles (voir jail.local dans ce projet)
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Vérifier les jails actifs
sudo fail2ban-client status
```

### 3. Gestion des règles UFW
```bash
# Lister les règles
sudo ufw show added

# Ajouter une règle personnalisée
sudo ufw allow from 192.168.1.0/24 to any port 22

# Supprimer une règle
sudo ufw delete allow 80/tcp

# Limiter les connexions (rate limiting)
sudo ufw limit 22/tcp
```

### 4. Monitoring et alertes
```bash
# Vérifier les bans actifs
sudo fail2ban-client status sshd

# Voir les logs
sudo tail -f /var/log/fail2ban.log
sudo tail -f /var/log/auth.log

# Débanner une IP
sudo fail2ban-client set sshd unbanip 192.168.1.100
```

## Fichiers du projet

### `ufw-setup.sh`
Script d'installation et configuration automatique d'UFW avec les bonnes pratiques:
- Mise en place des politiques par défaut
- Ouverture des ports essentiels (SSH, HTTP, HTTPS)
- Protection contre les scans de port (rate limiting)
- Logging

### `jail.local`
Configuration fail2ban personnalisée:
- Jail SSH: 5 essais échoués = ban 10 minutes
- Jail HTTP: Protection DoS simple
- Whitelist d'IPs de confiance
- Notifications par email (optionnel)

### `fail2ban-setup.sh`
Installation et activation de fail2ban avec configuration précédente

### `test-security.sh`
Script de test pour vérifier la configuration:
- Test de connectivité des ports ouverts
- Simulation d'attaque par force brute (safe)
- Vérification des bans actifs

### `monitor-firewall.sh`
Script de monitoring en temps réel:
- Affiche les connexions actives
- Montre les bans en cours
- Alertes sur tentatives échouées

## Ce qu'on apprend
✅ Concepts de sécurité réseau (firewall, filtrage, stateful inspection)
✅ Gestion UFW et iptables bas-niveau
✅ Protection contre les attaques (brute-force, DoS, port scanning)
✅ Monitoring et alertes de sécurité
✅ Gestion des logs système
✅ Scripting d'automatisation
✅ Bonnes pratiques DevOps/SRE pour l'infrastructure

## Améliorations futures
- Intégration avec monitoring (Prometheus, Grafana)
- Alertes Slack/Email sur activités suspectes
- Gestion centralisée des logs (ELK stack)
- Automatisation avec Ansible
- Gestion des certificats SSL
- Configuration IDS/IPS (Suricata)

## Durée estimée
⏱️ **1 jour (niveau intermédiaire)**
- 30 min: Comprendre les concepts
- 45 min: Installation et configuration
- 30 min: Tests et validation
- 15 min: Monitoring et documentation

## Commandes rapides
```bash
# Voir l'état UFW
sudo ufw status numbered

# Voir les tentatives de connexion échouées
sudo grep "Failed password" /var/log/auth.log | wc -l

# Voir les IPs bannies
sudo fail2ban-client status sshd | grep "Banned"

# Réinitialiser fail2ban
sudo systemctl restart fail2ban
```

## Ressources
- [UFW Documentation](https://wiki.ubuntu.com/UncomplicatedFirewall)
- [fail2ban Wiki](https://www.fail2ban.org/)
- [Linux firewall best practices](https://linux.die.net/man/8/iptables)

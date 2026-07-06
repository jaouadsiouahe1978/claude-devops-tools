# Guide d'Installation - Automatisation des Sauvegardes

## ⚡ Installation Rapide

```bash
# 1. Clone et accès au projet
cd projects/2026-07-06_bash-backup-automation

# 2. Installation (requires root)
sudo bash install.sh

# 3. Configuration
sudo nano /usr/local/bin/backup-config.sh
# Éditer les chemins et paramètres

# 4. Test
sudo /usr/local/bin/backup.sh
sudo /usr/local/bin/backup-verify.sh latest

# 5. Ajouter les tâches cron
sudo crontab -e
# Copier/coller depuis crontab.example
```

## 📋 Pré-requis Détaillés

### Système
- Linux (Ubuntu 18.04+, Debian 10+, CentOS 7+)
- Accès root ou sudo
- 500MB minimum d'espace disque libre

### Outils Requis
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y tar gzip mailutils cron

# CentOS/RHEL
sudo yum install -y tar gzip mailx cronie

# Alpine
apk add --no-cache tar gzip msmtp dcron
```

### Utilisateur/Groupe
```bash
# Le script s'exécute généralement comme root via cron
# Assurer que root peut accéder aux chemins à sauvegarder

# Pour sauvegarder des répertoires spécifiques sans root:
# Créer un utilisateur dédié et ajouter les permissions sudo
sudo useradd -m -s /bin/bash backup-user
sudo visudo
# Ajouter: backup-user ALL=(ALL) NOPASSWD: /usr/local/bin/backup.sh
```

## 🔧 Configuration Complète

### 1. Éditer la Configuration

```bash
sudo nano /usr/local/bin/backup-config.sh
```

**Points clés à configurer:**

```bash
# Répertoires à sauvegarder
BACKUP_DIRS=(
    "/etc"              # Config système
    "/home"             # Données utilisateur
    "/opt"              # Applications
    "/var/www"          # Sites web
    "/var/lib/docker"   # Données Docker
)

# Répertoires à exclure
EXCLUDE_PATTERNS=(
    "*/node_modules"
    "*/venv"
    "*/.git"
    "*/tmp"
)

# Stockage
BACKUP_BASE_DIR="/var/backups/custom-backups"
BACKUP_LOG_DIR="/var/log/backup"

# Rétention (keep 7 backups)
RETENTION_DAYS=7
MAX_BACKUPS=7

# Email
EMAIL_TO="admin@example.com"
SEND_EMAIL=true
```

### 2. Créer les Répertoires

```bash
# Répertoire de sauvegarde
sudo mkdir -p /var/backups/custom-backups
sudo chmod 700 /var/backups/custom-backups

# Répertoire de logs
sudo mkdir -p /var/log/backup
sudo chmod 755 /var/log/backup

# Répertoire de restauration (optionnel)
sudo mkdir -p /restore
sudo chmod 755 /restore
```

### 3. Configurer Email (optionnel)

Pour les notifications par email, configurer un MTA:

**Postfix (simple) :**
```bash
sudo apt-get install -y postfix
# Lors de l'installation, choisir "Internet Site"
sudo systemctl start postfix
sudo systemctl enable postfix
```

**Exim4 (léger) :**
```bash
sudo apt-get install -y exim4
sudo systemctl start exim4
sudo systemctl enable exim4
```

**Test email :**
```bash
echo "Test message" | mail -s "Test Subject" admin@example.com
```

### 4. Planifier les Tâches Cron

```bash
sudo crontab -e
```

Ajouter (adapter selon vos besoins):

```cron
# Daily backup at 2:00 AM
0 2 * * * /usr/local/bin/backup.sh >> /var/log/backup/cron.log 2>&1

# Rotate backups at 3:00 AM
0 3 * * * /usr/local/bin/backup-rotate.sh >> /var/log/backup/rotate.log 2>&1

# Verify backups at 4:00 AM
0 4 * * * /usr/local/bin/backup-verify.sh all >> /var/log/backup/verify.log 2>&1

# Monitor every 6 hours
0 */6 * * * /usr/local/bin/backup-monitoring.sh >> /var/log/backup/monitoring.log 2>&1
```

### 5. Vérifier l'Installation

```bash
# Test de sauvegarde
sudo /usr/local/bin/backup.sh

# Vérifier les backups
sudo ls -lh /var/backups/custom-backups/

# Vérifier l'intégrité
sudo /usr/local/bin/backup-verify.sh latest

# Voir le statut
sudo /usr/local/bin/backup-monitoring.sh
```

## 📊 Utilisation Quotidienne

### Sauvegarde Manuelle
```bash
sudo /usr/local/bin/backup.sh
```

### Vérifier les Sauvegardes
```bash
# Vérifier la dernière sauvegarde
sudo /usr/local/bin/backup-verify.sh latest

# Vérifier toutes les sauvegardes
sudo /usr/local/bin/backup-verify.sh all

# Rapport de santé
sudo /usr/local/bin/backup-verify.sh health
```

### Rotation
```bash
# Appliquer la rotation (garder 7 backups)
sudo /usr/local/bin/backup-rotate.sh
```

### Monitoring
```bash
# Vérifier la santé des backups
sudo /usr/local/bin/backup-monitoring.sh
```

### Restauration

**Mode interactif :**
```bash
sudo /usr/local/bin/backup-restore.sh interactive
```

**Lister les backups disponibles :**
```bash
sudo /usr/local/bin/backup-restore.sh list
```

**Extraire des fichiers spécifiques :**
```bash
# Extraire /etc/nginx/ de la dernière sauvegarde
sudo /usr/local/bin/backup-restore.sh extract \
    /var/backups/custom-backups/backup-2026-07-06.tar.gz \
    etc/nginx \
    /restore/
```

**Restauration complète :**
```bash
sudo /usr/local/bin/backup-restore.sh restore \
    /var/backups/custom-backups/backup-2026-07-06.tar.gz \
    /restore/
```

## 🔍 Monitoring et Alertes

### Vérifier les Logs

```bash
# Derniers logs de backup
tail -f /var/log/backup/backup-*.log

# Logs cron
tail -f /var/log/backup/cron.log

# Vérifier les erreurs
grep ERROR /var/log/backup/*.log

# Journaux système
sudo journalctl -u cron -n 50
```

### Rapport Mensuel

```bash
# Générer un rapport
sudo /usr/local/bin/backup-verify.sh health

# Voir la taille totale des backups
du -sh /var/backups/custom-backups/

# Voir l'utilisation disque
df -h /var/backups/custom-backups/
```

### Alertes Email

Les alertes sont envoyées quand:
- Une sauvegarde échoue
- L'espace disque est critique (> 95%)
- Une sauvegarde est trop vieille (> 25h)
- L'intégrité d'un backup est compromise

**Configurer le destinataire :**
```bash
sudo nano /usr/local/bin/backup-config.sh
# Changer: EMAIL_TO="admin@example.com"
```

## ⚠️ Dépannage Courant

### Erreur : "Permission denied"
```bash
# Vérifier les permissions
ls -l /usr/local/bin/backup.sh
# Doit être: -rwxr-xr-x

# Corriger
sudo chmod +x /usr/local/bin/backup*.sh
```

### Erreur : "No space left on device"
```bash
# Vérifier l'espace disque
df -h /var/backups/custom-backups/

# Libérer de l'espace
sudo /usr/local/bin/backup-rotate.sh

# Nettoyer les vieux logs
sudo find /var/log/backup -name "*.log" -mtime +30 -delete
```

### Erreur : "Command not found"
```bash
# Vérifier si tar/gzip sont installés
which tar gzip sha256sum

# Installer les outils manquants
sudo apt-get install -y tar gzip coreutils
```

### Email ne fonctionne pas
```bash
# Tester mail
echo "Test" | mail -s "Test" admin@example.com

# Vérifier le MTA
sudo systemctl status postfix
sudo systemctl status exim4

# Voir les logs
sudo tail -f /var/log/mail.log
```

## 🔒 Sécurité

### Permissions des Fichiers
```bash
# Backup directory (root only)
sudo chmod 700 /var/backups/custom-backups

# Logs (readable by anyone)
sudo chmod 755 /var/log/backup

# Checksums (readable by anyone)
sudo chmod 644 /var/backups/custom-backups/*.sha256
```

### Chiffrage des Backups (Avancé)

Pour chiffrer les backups avec GPG:

```bash
# Générer une clé
gpg --gen-key

# Dans backup.sh, ajouter:
# gpg --encrypt -r backup-key "${BACKUP_FILE}"
# rm "${BACKUP_FILE}"
```

### Backup Externe

Uploader vers un serveur distant:

```bash
# Ajouter à cron
0 4 * * * rsync -av /var/backups/custom-backups/ \
    remote-server:/backups/ >> /var/log/backup/rsync.log 2>&1
```

## 📚 Fichiers Importants

```
/usr/local/bin/backup.sh              # Script principal
/usr/local/bin/backup-rotate.sh       # Rotation
/usr/local/bin/backup-verify.sh       # Vérification
/usr/local/bin/backup-monitoring.sh   # Monitoring
/usr/local/bin/backup-restore.sh      # Restauration
/usr/local/bin/backup-config.sh       # Configuration
/var/backups/custom-backups/          # Sauvegardes
/var/log/backup/                      # Logs
```

## ✅ Checklist de Production

- [ ] Configuration des chemins à sauvegarder
- [ ] Tests manuels réussis
- [ ] Email d'alerte configuré
- [ ] Tâches cron ajoutées
- [ ] Espace disque suffisant
- [ ] Restauration testée
- [ ] Logs vérifiés
- [ ] Plan de rétention défini
- [ ] Sauvegardes externes programmées
- [ ] Documentation mise à jour

---

**Support** : Voir README.md pour plus de détails  
**Date de création** : 2026-07-06

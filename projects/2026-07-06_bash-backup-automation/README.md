# Automatisation des Sauvegardes avec Rotation et Monitoring

## 📌 Objectif
Créer un système complet d'automatisation des sauvegardes Linux avec :
- Script de sauvegarde incrémentale avec TAR
- Rotation automatique (conserver les 7 dernières sauvegardes)
- Vérification de l'intégrité des archives
- Monitoring et alertes par email
- Intégration avec cron pour l'automatisation

## 🛠️ Technos utilisées
- **Bash** : Scripts d'automatisation
- **TAR** : Compression et archivage
- **Cron** : Planification
- **syslog / mail** : Logging et notifications
- **df / du** : Monitoring d'espace disque

## 📋 Pré-requis
- Système Linux (Ubuntu/Debian/CentOS)
- Droits root ou sudo
- Outils : `tar`, `mail`, `cron`, `find`
- Espace disque disponible (~500MB pour les backups de test)

## 🚀 Étapes de réalisation

### 1. Préparation des répertoires
```bash
sudo mkdir -p /var/backups/custom-backups
sudo mkdir -p /var/log/backup
sudo chmod 755 /var/backups/custom-backups
```

### 2. Installation des scripts
```bash
sudo cp backup.sh /usr/local/bin/
sudo cp backup-rotate.sh /usr/local/bin/
sudo cp backup-verify.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/backup*.sh
```

### 3. Configuration
- Éditer `backup-config.sh` avec les chemins à sauvegarder
- Configurer l'email pour les alertes
- Définir la rétention (ex: 7 sauvegardes)

### 4. Test manuel
```bash
sudo /usr/local/bin/backup.sh
sudo /usr/local/bin/backup-verify.sh
```

### 5. Planification via cron
```bash
sudo crontab -e
# Ajouter:
# 02 2 * * * /usr/local/bin/backup.sh >> /var/log/backup/cron.log 2>&1
```

### 6. Monitoring
```bash
sudo /usr/local/bin/backup-monitoring.sh
```

## 📚 Ce qu'on apprend

### Concepts DevOps/SysAdmin
- **Automatisation** : Scripts bash réutilisables et robustes
- **Planification** : Utilisation de cron pour les tâches récurrentes
- **Rotation des logs** : Gérer l'espace disque en supprimant les anciennes sauvegardes
- **Monitoring** : Vérifier la santé des sauvegardes
- **Alertes** : Notifier en cas de problème
- **Sécurité** : Permissions des fichiers, checksums

### Commandes pratiques
```bash
# Lister les sauvegardes
ls -lh /var/backups/custom-backups/

# Vérifier l'intégrité
tar -tzf /var/backups/custom-backups/backup-*.tar.gz | head

# Voir l'espace utilisé
du -sh /var/backups/custom-backups/

# Extraire une sauvegarde
sudo tar -xzf /var/backups/custom-backups/backup-2026-07-06.tar.gz -C /restore/
```

## 📁 Structure du projet
```
2026-07-06_bash-backup-automation/
├── README.md                          # Ce fichier
├── backup-config.sh                   # Configuration centralisée
├── backup.sh                          # Script de sauvegarde principal
├── backup-rotate.sh                   # Gestion de la rotation
├── backup-verify.sh                   # Vérification d'intégrité
├── backup-monitoring.sh               # Monitoring et alertes
├── backup-restore.sh                  # Script de restauration
├── test/
│   ├── test-backup.sh                 # Tests automatisés
│   └── mock-data/                     # Données de test
└── docs/
    ├── INSTALLATION.md                # Guide détaillé d'installation
    └── TROUBLESHOOTING.md             # Dépannage commun
```

## 🔍 Cas d'usage réel
En production, ce système permet de :
- Sauvegarder les configs système `/etc`
- Sauvegarder les données d'application
- Respecter les politiques de rétention (ex: 7j, 30j, 90j)
- Alerter l'équipe en cas de sauvegarde manquante
- Respecter les objectifs RTO/RPO (Recovery Time/Point Objective)

## ⚠️ Points importants
- Toujours tester les restaurations régulièrement
- Vérifier l'espace disque disponible avant les backups
- Sauvegarder les sauvegardes sur un stockage externe
- Utiliser des checksums pour vérifier l'intégrité
- Monitorer les logs de cron pour les erreurs

## 🎯 Bonus avancé
- [ ] Chiffrer les sauvegardes avec GPG
- [ ] Uploader les sauvegardes vers S3/Backblaze
- [ ] Créer des snapshots incrémentiels
- [ ] Intégrer avec Nagios/Icinga pour les alertes
- [ ] Ajouter des métriques dans Prometheus

---

**Auteur** : DevOps Training - Jaouad  
**Date** : 2026-07-06  
**Durée estimée** : 1 journée

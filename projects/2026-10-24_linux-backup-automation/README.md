# Linux System Backup & Recovery Automation

## 📋 Objectif

Créer une solution complète de sauvegarde et récupération de système Linux automatisée avec :
- Sauvegarde incrémentale des fichiers système
- Compression optimisée avec tar
- Gestion automatique des rotations de backups
- Script de vérification d'intégrité
- Restauration sélective de fichiers
- Planification avec cron

## 🎯 Ce qu'on apprend

- **Bash scripting avancé** : boucles, conditions, fonctions, gestion d'erreurs
- **Gestion des fichiers** : tar, gzip, rsync, permissions
- **Cron & planification** : cronjobs, logs, notifications
- **Stratégies de backup** : incrémentiels, full, rotations (3-2-1)
- **Sécurité** : chiffrement, checksums, auditage
- **Monitoring** : vérification d'intégrité, alertes, métriques

## 📦 Technos utilisées

- **Bash** : scripts de sauvegarde et récupération
- **tar** : compression et archivage
- **cron** : planification automatique
- **find, du, md5sum** : utilitaires système
- **journalctl** : logs système
- **rsync** : synchronisation incrémentale

## 📋 Pré-requis

```bash
# Vérifier que vous avez les outils nécessaires
which bash tar gzip find cron md5sum rsync

# Au minimum Ubuntu 20.04 / CentOS 8 ou équivalent
# Espace disque disponible : au moins 2x la taille à sauvegarder
# Accès root ou sudo pour certaines opérations
```

## 🚀 Étapes de réalisation

### 1. Structure du projet (5 min)

```bash
cd projects/2026-10-24_linux-backup-automation
ls -la  # Vérifier la structure créée
```

### 2. Configurer le fichier de configuration (10 min)

Éditer `backup-config.conf` et adapter les chemins :
```bash
SOURCE_DIRS="/etc /home /var/www"
BACKUP_DEST="/mnt/backups"
RETENTION_DAYS=30
COMPRESSION="gzip"  # ou bzip2 pour meilleure compression
```

### 3. Exécuter une sauvegarde complète (15 min)

```bash
chmod +x backup-manager.sh
./backup-manager.sh --full --source-config backup-config.conf
```

Vérifier la sauvegarde créée :
```bash
ls -lh /mnt/backups/
du -sh /mnt/backups/*
```

### 4. Vérifier l'intégrité des backups (10 min)

```bash
chmod +x verify-backups.sh
./verify-backups.sh --backup-dir /mnt/backups
```

### 5. Planifier les sauvegardes avec cron (10 min)

```bash
chmod +x cron-setup.sh
./cron-setup.sh --install --config backup-config.conf

# Vérifier l'installation
crontab -l
```

### 6. Tester la restauration (20 min)

```bash
chmod +x restore.sh

# Créer des fichiers de test
echo "test data" > /tmp/test-file.txt

# Restaurer depuis le backup
./restore.sh --backup /mnt/backups/full-backup-*.tar.gz \
             --file /tmp/test-file.txt \
             --dest /tmp/restored/

# Vérifier la restauration
cat /tmp/restored/tmp/test-file.txt
```

### 7. Monitorer les logs de sauvegarde (10 min)

```bash
# Vérifier les logs
cat /var/log/backup-manager.log

# Voir les erreurs des dernières sauvegardes
tail -50 /var/log/backup-manager.log | grep -i error
```

### 8. Mettre en place les alertes (optionnel, 15 min)

Les scripts envoient automatiquement les alertes si configuré :
```bash
# Éditer backup-config.conf pour activer les alertes
ALERT_EMAIL="admin@example.com"
ALERT_ON_FAILURE="true"
```

## 📊 Résultats attendus

✅ Sauvegarde complète créée : `full-backup-2026-10-24-*.tar.gz`  
✅ Vérification d'intégrité : tous les fichiers checksummés  
✅ Cronjob configuré pour sauvegardes quotidiennes  
✅ Capacité à restaurer des fichiers individuels  
✅ Logs centralisés dans `/var/log/backup-manager.log`  
✅ Rotation automatique des anciens backups  

## 📁 Structure des fichiers

```
projects/2026-10-24_linux-backup-automation/
├── README.md                    # Ce fichier
├── backup-config.conf          # Configuration (source, destination, rétention)
├── backup-manager.sh           # Script principal de sauvegarde
├── restore.sh                  # Script de restauration sélective
├── verify-backups.sh           # Vérification d'intégrité
├── cron-setup.sh               # Installation des cronjobs
├── examples/
│   ├── backup-docker-config.conf     # Exemple : backup config Docker
│   └── alert-failure.sh              # Script d'alerte personnalisée
└── docs/
    ├── BACKUP-STRATEGY.md      # Explication de la stratégie 3-2-1
    └── TROUBLESHOOTING.md      # Dépannage courant
```

## 🔒 Sécurité & Best Practices

1. **Chiffrement** : Utilisez `--encrypt` pour chiffrer les archives
   ```bash
   ./backup-manager.sh --full --encrypt --passphrase "your-secret"
   ```

2. **Vérification régulière** : Lancez verify-backups.sh une fois par semaine
   ```bash
   # Via cron
   0 3 * * 0 /path/to/verify-backups.sh
   ```

3. **Sauvegarde hors site** : Copiez les backups vers un serveur distant
   ```bash
   rsync -avz /mnt/backups/ user@backup-server:/backups/
   ```

4. **Permissions strictes** : Les backups ne doivent être accessibles qu'à root
   ```bash
   chmod 700 /mnt/backups
   chown root:root /mnt/backups
   ```

5. **Test de restauration** : Testez la restauration une fois par mois
   ```bash
   # Créer une VM de test
   # Restaurer les données
   # Vérifier que tout fonctionne
   ```

## 🐛 Dépannage

**Les sauvegardes prennent trop de place**
```bash
# Augmentez la compression
COMPRESSION="bzip2"  # ou xz pour meilleure compression

# Réduisez la rétention
RETENTION_DAYS=14
```

**Certains fichiers ne sont pas sauvegardés**
```bash
# Vérifiez les permissions
ls -la /path/to/source/

# Utilisez --verbose pour voir quels fichiers sont traités
./backup-manager.sh --full --verbose
```

**Erreur "tar: Error exit delayed from previous errors"**
```bash
# Cela indique des erreurs de permission
# Assurez-vous d'exécuter en tant que root:
sudo ./backup-manager.sh --full
```

## 📈 Extensions possibles

1. **Sauvegarde incrémentale** : Sauvegarder uniquement les modifications
2. **Déduplication** : Réduire l'espace disque avec dedup
3. **Réplication distance** : Envoyer les backups vers le cloud (S3, GCS)
4. **Snapshots LVM** : Sauvegarder des snapshots de volumes
5. **Notification Slack** : Alertes en temps réel
6. **Dashboard de monitoring** : Graphes de l'espace utilisé

## ✅ Validation

Pour valider que votre implémentation fonctionne :

```bash
# 1. Créer une sauvegarde complète
./backup-manager.sh --full

# 2. Vérifier que le fichier a été créé
test -f /mnt/backups/full-backup-*.tar.gz && echo "✓ Backup créé"

# 3. Vérifier l'intégrité
./verify-backups.sh --backup-dir /mnt/backups

# 4. Vérifier la cron
crontab -l | grep backup-manager

# 5. Tester la restauration
./restore.sh --backup /mnt/backups/full-backup-*.tar.gz --list
```

Si tous les tests passent, le projet est complet ! 🎉

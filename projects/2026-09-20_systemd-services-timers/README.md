# Systemd Services & Timer Units - Automation Linux

**Date:** 2026-09-20  
**Niveau:** Débutant à Intermédiaire  
**Durée estimée:** 1 journée

## Objectif

Créer et automatiser des tâches Linux via **systemd** : services personnalisés, dépendances entre services, planification avec Timer Units (alternative moderne à cron), et gestion de la sécurité avec isolement de processus.

## Technos utilisées

- **Systemd** (unit files, service management)
- **Bash** (scripts d'exécution)
- **Timer Units** (planification sans cron)
- **Linux Security** (User/Group isolation, security contexts)
- **Journalctl** (logs centralisés)

## Prérequis

- Linux (Ubuntu 20.04+, CentOS 8+, Debian 11+)
- Accès root ou sudo
- Connaissance de base du terminal Linux
- Éditeur de texte (nano, vim)

## Architecture

```
Systemd Service Architecture
├── Custom Service Unit
│   ├── User account (non-root)
│   ├── Working directory
│   ├── Restart policy
│   └── Log management
├── Timer Unit
│   ├── OnCalendar schedule
│   ├── Persistent state
│   └── Accuracy settings
└── Service Monitoring
    ├── Status checks
    ├── Journal logs
    └── System integration
```

## Étapes de réalisation

### 1. Créer un service personnalisé simple

**Objectif:** Créer un service qui exécute un script Bash

```bash
# Créer un utilisateur dédié (sécurité)
sudo useradd -r -s /bin/bash -d /opt/backups backupuser

# Créer le répertoire du service
sudo mkdir -p /opt/backups
sudo chown backupuser:backupuser /opt/backups
```

**Créer le script (/opt/backups/backup.sh)**
```bash
#!/bin/bash
set -e
echo "$(date): Starting backup task..." >> /opt/backups/backup.log
# Exemple: sauvegarde de fichiers
tar -czf /opt/backups/data_$(date +%Y%m%d_%H%M%S).tar.gz /home/ 2>/dev/null || true
echo "$(date): Backup completed" >> /opt/backups/backup.log
```

```bash
sudo chmod +x /opt/backups/backup.sh
```

### 2. Créer le fichier de service Systemd

**Fichier:** `/etc/systemd/system/backup.service`

```ini
[Unit]
Description=Custom Backup Service
After=network.target
Documentation=man:bash(1)

[Service]
Type=oneshot
User=backupuser
Group=backupuser
WorkingDirectory=/opt/backups
ExecStart=/opt/backups/backup.sh
StandardOutput=journal
StandardError=journal
SyslogIdentifier=backup-service

[Install]
WantedBy=multi-user.target
```

### 3. Créer une Timer Unit pour la planification

**Fichier:** `/etc/systemd/system/backup.timer`

```ini
[Unit]
Description=Daily Backup Timer
Requires=backup.service
After=backup.service

[Timer]
OnCalendar=daily
OnCalendar=*-*-* 02:00:00
Persistent=true
AccuracySec=5s

[Install]
WantedBy=timers.target
```

**Autres formats OnCalendar:**
- `hourly` - chaque heure
- `daily` - chaque jour à 00:00
- `weekly` - chaque lundi à 00:00
- `monthly` - 1er du mois à 00:00
- `*-*-* 02:30:00` - spécifique (2h30)
- `Mon..Fri *-*-* 09:00:00` - lun-ven à 9h

### 4. Activer et gérer les services

```bash
# Recharger la configuration systemd
sudo systemctl daemon-reload

# Démarrer le service manuellement
sudo systemctl start backup.service

# Vérifier le statut
sudo systemctl status backup.service

# Voir les logs
sudo journalctl -u backup.service -n 20 -f

# Activer la timer (lancement automatique au boot)
sudo systemctl enable backup.timer
sudo systemctl start backup.timer

# Vérifier les timers
systemctl list-timers
systemctl list-timers backup.timer

# Voir la prochaine exécution
sudo systemctl status backup.timer
```

### 5. Exercice avancé: Service avec dépendances

**Créer un service qui dépend d'un autre**

Fichier: `/etc/systemd/system/app.service`
```ini
[Unit]
Description=Application Service
After=backup.service
Requires=backup.service

[Service]
Type=simple
ExecStart=/usr/bin/sleep infinity
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Le service 'app' ne démarre que si 'backup' est OK
sudo systemctl start app.service
```

### 6. Monitoring et alertes

**Créer une timer qui exécute une vérification de santé**

Fichier: `/opt/backups/health-check.sh`
```bash
#!/bin/bash
LATEST_BACKUP=$(ls -t /opt/backups/data_*.tar.gz 2>/dev/null | head -1)
if [ -z "$LATEST_BACKUP" ]; then
    echo "ERROR: No backup found!" >&2
    exit 1
fi

# Vérifier que le backup n'est pas trop vieux (> 25h)
if [ "$(find /opt/backups/data_*.tar.gz -mmin +1500 2>/dev/null)" ]; then
    echo "ERROR: Backup too old!"
    exit 1
fi

echo "OK: Latest backup is $(basename $LATEST_BACKUP)"
```

## Concepts clés apprendre

1. **Unit Files Structure**
   - `[Unit]` : métadonnées et dépendances
   - `[Service]` : configuration du service
   - `[Timer]` : planification
   - `[Install]` : activation au boot

2. **Types de services**
   - `Type=simple` : service en avant-plan
   - `Type=forking` : service qui forke
   - `Type=oneshot` : exécution unique
   - `Type=notify` : notification systemd

3. **Gestion des ressources**
   - `CPUQuota=50%` : limiter CPU
   - `MemoryMax=256M` : limiter mémoire
   - `TasksMax=100` : limiter processus

4. **Restart Policies**
   - `Restart=always` : toujours redémarrer
   - `Restart=on-failure` : sur erreur seulement
   - `RestartSec=10` : délai avant redémarrage

5. **Sécurité**
   - Utilisateur dédié (non-root)
   - Permissions minimales
   - Isolation des ressources

## Commandes essentielles

```bash
# Gestion services
systemctl start/stop/restart/reload SERVICE
systemctl enable/disable SERVICE
systemctl status SERVICE

# Gestion timers
systemctl list-timers
systemctl status SERVICE.timer
sudo systemctl start SERVICE.timer

# Logs
journalctl -u SERVICE -n 50 -f      # Suivre les logs en temps réel
journalctl -u SERVICE --since "2h ago"
journalctl -p err                    # Afficher uniquement les erreurs
journalctl SERVICE.timer             # Logs de la timer

# Diagnostic
systemd-analyze verify SERVICE.service
systemd-analyze verify SERVICE.timer
```

## Cas d'usage réels

1. **Backups quotidiens** (comme dans ce projet)
2. **Cleanup de logs** (logrotate alternatif)
3. **Vérifications de santé** (health checks)
4. **Synchronisation de données** (rsync, git pull)
5. **Maintenance de base de données** (vacuum, optimize)
6. **Monitoring et alertes** (Prometheus node exporter)
7. **Script de déploiement** (auto-pull de git)

## Résultats attendus

À la fin du projet, tu devras:

- [ ] Créer un service systemd personnalisé
- [ ] Créer une Timer Unit qui s'exécute selon un calendrier
- [ ] Vérifier l'exécution via `systemctl` et `journalctl`
- [ ] Mettre en place la sécurité (user dédié)
- [ ] Configurer la gestion des logs
- [ ] Tester les dépendances entre services
- [ ] Monitorer l'exécution avec alertes d'erreur

## Ce qu'on apprend

- ✅ Automatisation systemd (fondation moderne Linux)
- ✅ Planification sans cron (Timer Units)
- ✅ Gestion des processus et services
- ✅ Sécurité par isolation d'utilisateur
- ✅ Logging centralisé avec journalctl
- ✅ Monitoring et diagnostics systemd
- ✅ Restart policies et gestion d'erreurs
- ✅ DevOps fundamentals: Services & Observability

## Difficultés communes

- Permission denied: utiliser `sudo` ou changer les permissions
- Timer n'exécute pas: vérifier `systemctl list-timers` et `journalctl`
- Service crash: vérifier `systemctl status` et les logs
- Permissions fichiers: `chown` le user/group approprié

## Ressources

- [Systemd Documentation](https://www.freedesktop.org/wiki/Software/systemd/)
- [Systemd Timer & Service Examples](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [Journalctl User Guide](https://www.freedesktop.org/software/systemd/man/journalctl.html)
- [Linux Academy - Systemd](https://linuxacademy.com/)

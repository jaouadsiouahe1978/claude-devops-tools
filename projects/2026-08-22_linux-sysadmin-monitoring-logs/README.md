# 📊 Linux Sysadmin - Système de Monitoring et Rotation de Logs

## 🎯 Objectif
Créer un système complet de monitoring serveur et gestion automatisée des logs avec des scripts Bash. Ce projet te permet d'apprendre les bases essentielles de l'administration système Linux.

## 💻 Technos utilisées
- **Bash scripting** - Automatisation et traitement
- **Linux sysadmin** - Gestion système
- **Cron** - Planification de tâches
- **Logs et monitoring** - Observation du système
- **systemd** - Services Linux

## 📋 Pré-requis
- Serveur/VM Linux (Ubuntu 20.04+ ou équivalent)
- Accès root ou sudo
- Connaissance basique du shell Bash
- Éditeur de texte (nano, vim)

## 🚀 Étapes de réalisation

### Étape 1 : Configuration du projet
```bash
cd /home/user/claude-devops-tools/projects/2026-08-22_linux-sysadmin-monitoring-logs
mkdir -p scripts logs config
```

### Étape 2 : Scripts de monitoring
- **system_health.sh** - Monitoring de la santé du système
- **check_disk.sh** - Vérification de l'espace disque
- **check_memory.sh** - Monitoring de la RAM
- **log_monitor.sh** - Suivi des logs en temps réel

### Étape 3 : Scripts de gestion des logs
- **rotate_logs.sh** - Rotation automatique des logs
- **compress_old_logs.sh** - Compression des anciens logs
- **cleanup_logs.sh** - Nettoyage intelligent des logs

### Étape 4 : Automatisation avec Cron
```bash
# Vérification chaque 5 minutes
*/5 * * * * /opt/monitoring/system_health.sh

# Rotation des logs chaque nuit
0 2 * * * /opt/monitoring/rotate_logs.sh

# Nettoyage des logs anciens chaque semaine
0 3 * * 0 /opt/monitoring/cleanup_logs.sh
```

### Étape 5 : Création d'un service systemd
Créer un service Linux pour exécuter le monitoring de façon plus robuste

### Étape 6 : Tests et validation
- Tester chaque script individuellement
- Vérifier les logs générés
- Valider l'intégration avec cron

## 📚 Ce qu'on apprend

✅ **Scripting Bash avancé**
- Boucles et conditions
- Traitement de texte (grep, awk, sed)
- Variables d'environnement
- Gestion des erreurs

✅ **Administration système**
- Commandes de monitoring (top, df, free, vmstat)
- Gestion des permissions
- Logs système (journalctl, syslog)

✅ **Automatisation**
- Cron jobs et scheduling
- Services systemd
- Scripts de maintenance

✅ **Best practices**
- Logging structuré
- Alertes email
- Archivage et rétention

## 📁 Structure du projet

```
2026-08-22_linux-sysadmin-monitoring-logs/
├── README.md                          # Documentation (ce fichier)
├── scripts/
│   ├── system_health.sh              # Monitoring global du système
│   ├── check_disk.sh                 # Vérification disque
│   ├── check_memory.sh               # Vérification RAM
│   ├── log_monitor.sh                # Suivi des logs
│   ├── rotate_logs.sh                # Rotation de logs
│   ├── compress_old_logs.sh          # Compression
│   └── cleanup_logs.sh               # Nettoyage
├── config/
│   ├── monitoring.conf               # Configuration du monitoring
│   ├── crontab.txt                   # Configuration cron
│   └── monitoring.service            # Service systemd
└── logs/
    └── .gitkeep                      # Dossier pour les logs
```

## ⚡ Utilisation rapide

### Installation
```bash
# Copier les scripts
sudo cp scripts/*.sh /usr/local/bin/

# Rendre exécutables
sudo chmod +x /usr/local/bin/*health*.sh
sudo chmod +x /usr/local/bin/check_*.sh
sudo chmod +x /usr/local/bin/rotate_*.sh
sudo chmod +x /usr/local/bin/cleanup_*.sh

# Créer les dossiers de logs
sudo mkdir -p /var/log/monitoring
sudo chmod 755 /var/log/monitoring
```

### Tester les scripts
```bash
# Tester la vérification disque
./scripts/check_disk.sh

# Tester le monitoring système
./scripts/system_health.sh

# Tester la rotation de logs
./scripts/rotate_logs.sh
```

### Ajouter au cron (root)
```bash
sudo crontab -e

# Ajouter les lignes du config/crontab.txt
```

## 🔧 Configuration avancée

### Variables d'environnement
- `ALERT_EMAIL` - Email pour les alertes
- `DISK_THRESHOLD` - Seuil disque critique (%)
- `MEMORY_THRESHOLD` - Seuil RAM critique (%)
- `LOG_RETENTION_DAYS` - Jours de rétention logs

### Personnalisation
Modifier les fichiers de config pour adapter au contexte :
- Seuils d'alerte
- Adresses email
- Chemins des logs
- Fréquence des tâches

## 📊 Sortie exemple

```
╔════════════════════════════════════════════════════╗
║     SYSTEM HEALTH REPORT - 2026-08-22 10:45       ║
╠════════════════════════════════════════════════════╣
║ CPU Load (1/5/15 min): 0.45 / 0.38 / 0.32        ║
║ Memory Usage: 45% (3.6GB / 8GB)                  ║
║ Disk Usage: /      72% ⚠️ (Proche du seuil)      ║
║ Disk Usage: /home  28%                            ║
║ Running Processes: 145                            ║
║ System Uptime: 45 days 3 hours                    ║
╚════════════════════════════════════════════════════╝
```

## 🎓 Défis supplémentaires

1. **Alertes email** - Envoyer des emails en cas de dépassement de seuil
2. **Slack notifications** - Intégrer avec Slack pour les alertes
3. **Dashboard web** - Créer une page HTML pour visualiser l'état
4. **Database** - Stocker les métriques dans SQLite pour l'historique
5. **Grafana integration** - Exporter les métriques en format Prometheus

## 📖 Ressources utiles

- `man crontab` - Documentation des tâches planifiées
- `man systemd.service` - Documentation des services
- `journalctl` - Visualiser les logs système
- Stack Exchange et forums Linux pour dépannage

## ✨ Points clés

- ✅ Scripts réutilisables et modulaires
- ✅ Gestion d'erreurs robuste
- ✅ Logging structuré
- ✅ Facilement déployable sur d'autres serveurs
- ✅ Zéro dépendances externes (juste Bash)

---

**Durée estimée:** 6-8 heures | **Niveau:** Débutant à Intermédiaire

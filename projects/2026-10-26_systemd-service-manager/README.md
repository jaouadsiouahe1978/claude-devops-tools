# Systemd Service Manager - Gestion Complète de Services Linux

## Objectif
Maîtriser la création, la gestion et le monitoring de services systemd sur Linux. Créer une application Python managée par systemd avec un timer pour l'exécuter périodiquement et un système de monitoring de santé.

## Technos Utilisées
- **Linux Systemd** : Service manager système
- **Python** : Application à déployer
- **Bash** : Scripts de gestion
- **Journalctl** : Logging système
- **Health Checks** : Monitoring de l'état du service

## Prérequis
- Accès root ou sudo
- Linux avec systemd (Ubuntu 20.04+, CentOS 7+, Debian 11+)
- Python 3.8+
- Bash 4+

## Étapes de Réalisation

### 1. Créer l'Application à Managéer
L'app Python simple qui va écrire des logs et effectuer une tâche récurrente.

```bash
cd /opt/my-app
python3 app.py
```

### 2. Créer le Service Systemd
Créer un fichier unitaire systemd pour managéer l'app automatiquement:

```bash
sudo cp mon-app.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable mon-app
sudo systemctl start mon-app
```

### 3. Créer un Timer Systemd
Configurer l'app pour s'exécuter à intervalles réguliers:

```bash
sudo cp mon-app.timer /etc/systemd/system/
sudo systemctl enable mon-app.timer
sudo systemctl start mon-app.timer
sudo systemctl list-timers
```

### 4. Vérifier et Monitorer
- Voir les logs du service : `journalctl -u mon-app -f`
- Vérifier l'état : `systemctl status mon-app`
- Historique des timers : `systemctl list-timers --all`

### 5. Monitoring de Santé
Exécuter le script de health check:

```bash
python3 monitoring.py
```

## Ce qu'on Apprend

✅ **Création de services systemd** - Comprendre les fichiers .service
✅ **Timers systemd** - Scheduler d'exécution pour tâches récurrentes
✅ **Gestion du cycle de vie** - start/stop/restart/enable/disable
✅ **Journalisation** - Logging centralisé avec journalctl
✅ **Health checks** - Monitorer la santé d'un service
✅ **Auto-restart** - Configurer systemd pour redémarrer automatiquement
✅ **Dépendances de service** - Ordre de démarrage et arrêt
✅ **Ressources limitées** - CPU, mémoire, fichiers ouverts avec systemd

## Structure des Fichiers

```
projects/2026-10-26_systemd-service-manager/
├── README.md                  # Ce fichier
├── app.py                     # Application Python principale
├── monitoring.py              # Script de health check
├── service_manager.sh         # Script bash d'administration
├── mon-app.service            # Fichier unitaire service systemd
└── mon-app.timer              # Fichier unitaire timer systemd
```

## Commandes Principales

| Commande | Description |
|----------|-------------|
| `systemctl start mon-app` | Démarrer le service |
| `systemctl stop mon-app` | Arrêter le service |
| `systemctl restart mon-app` | Redémarrer le service |
| `systemctl status mon-app` | Voir l'état actuel |
| `systemctl enable mon-app` | Activer au démarrage |
| `systemctl disable mon-app` | Désactiver du démarrage |
| `journalctl -u mon-app -f` | Voir les logs en temps réel |
| `systemctl list-timers` | Voir les timers actifs |

## Notes Importantes

- Les services systemd nécessitent root pour installer en `/etc/systemd/system/`
- Changer `User=` dans le fichier .service si vous ne voulez pas root
- `Restart=on-failure` relance le service en cas d'erreur
- Les timers peuvent exécuter des services ou des commandes directement
- Journalctl conserve les logs persistent par défaut

## Ressources Supplémentaires
- [Systemd Documentation](https://www.freedesktop.org/wiki/Software/systemd/)
- [Systemd Unit Files](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_basic_system_settings/introduction-to-systemd_configuring-basic-system-settings)

# Projet DevOps du jour : Gestion des Services Systemd & Monitoring Local

## 📋 Description

Un projet complet pour maîtriser la gestion des services Linux avec systemd, incluant la création de services personnalisés, leur monitoring, et la gestion des logs. Ce projet reproduit un environnement réaliste où vous apprenez à créer et gérer des services critiques.

## 🎯 Objectif

- Créer des services systemd personnalisés
- Monitorer les services et leurs ressources
- Gérer les logs avec journalctl
- Implémenter des health checks et restart policies
- Automatiser le démarrage et arrêt des services

## 🛠️ Technologies utilisées

- **Linux systemd** - Gestionnaire de services moderne
- **Bash scripting** - Scripts de service
- **journalctl** - Gestion des logs
- **systemctl** - Contrôle des services
- **timer systemd** - Tâches planifiées

## 📦 Pré-requis

- Un système Linux avec systemd (Ubuntu 20.04+, CentOS 8+, Fedora 30+)
- Accès root ou sudo
- Bash shell
- curl ou wget pour les tests HTTP

## 🚀 Étapes de réalisation

### Étape 1 : Créer une application de service (Web server simple)
```bash
# Créer le répertoire de l'application
mkdir -p /opt/simple-service
cp app.sh /opt/simple-service/
chmod +x /opt/simple-service/app.sh
```

### Étape 2 : Créer un service systemd
```bash
# Créer le fichier de service
sudo cp simple-service.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable simple-service.service
sudo systemctl start simple-service.service
```

### Étape 3 : Configurer le monitoring des services
```bash
# Lancer le script de monitoring
bash monitor-services.sh
```

### Étape 4 : Configurer une tâche timer systemd
```bash
# Créer les fichiers timer
sudo cp health-check.service /etc/systemd/system/
sudo cp health-check.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable health-check.timer
sudo systemctl start health-check.timer
```

### Étape 5 : Examiner les logs et statistiques
```bash
# Visualiser les logs en temps réel
journalctl -u simple-service.service -f

# Voir les statistiques de la dernière heure
journalctl -u simple-service.service --since "1 hour ago"

# Voir les erreurs
journalctl -u simple-service.service -p err
```

## 📚 Ce qu'on apprend

✅ **Gestion des services systemd**
- Structure des fichiers `.service`
- Options de restart et de gestion de ressources
- Dépendances entre services

✅ **Logging et monitoring**
- Utilisation de journalctl
- Filtrage et recherche de logs
- Exportation des logs

✅ **Automatisation**
- Timers systemd pour les tâches cron-like
- Scripts de health check
- Réstart policies

✅ **Bonnes pratiques DevOps/SRE**
- Gestion des ressources (CPU, mémoire)
- Notions de résilience (restart, restart delay)
- Monitoring proactif

## 📁 Structure du projet

```
2026-11-08_linux-systemd-services/
├── README.md                    # Ce fichier
├── app.sh                       # Application de service simple
├── simple-service.service       # Configuration du service
├── health-check.sh              # Script de vérification de santé
├── health-check.service         # Service de health check
├── health-check.timer           # Timer pour health check
├── monitor-services.sh          # Script de monitoring global
└── test-service.sh              # Script de test
```

## 🧪 Commandes essentielles

```bash
# Gestion des services
sudo systemctl start simple-service.service      # Démarrer
sudo systemctl stop simple-service.service       # Arrêter
sudo systemctl restart simple-service.service    # Redémarrer
sudo systemctl enable simple-service.service     # Activer au démarrage
sudo systemctl disable simple-service.service    # Désactiver au démarrage
sudo systemctl status simple-service.service     # Voir le statut

# Monitoring
sudo systemctl list-units --type service        # Voir tous les services
sudo systemctl list-timers                      # Voir tous les timers
sudo systemctl list-jobs                        # Voir les tâches en cours

# Logs
journalctl -u simple-service.service -n 50     # Voir les 50 dernières lignes
journalctl -u simple-service.service -f        # Suivi en temps réel
journalctl -u simple-service.service -xe       # Voir les erreurs
journalctl --since "1 hour ago"                # Logs de la dernière heure
journalctl --no-pager                          # Afficher sans pager
```

## 💡 Points clés à retenir

1. **Systemd unit files** : Les fichiers `.service`, `.timer` définissent le comportement des services
2. **Restart policies** : `Restart=always`, `RestartSec=10` pour une résilience automatique
3. **Logging centralisé** : Tous les logs vont dans journald (pas de fichiers log disséminés)
4. **Health checks** : Implémenter des vérifications régulières pour détecter les problèmes
5. **Monitoring proactif** : Utiliser les logs et les statistiques systemd pour l'observabilité

## 🔗 Ressources utiles

- [Systemd Documentation](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [journalctl Guide](https://www.freedesktop.org/software/systemd/man/journalctl.html)
- [Systemd Timers](https://www.freedesktop.org/software/systemd/man/systemd.timer.html)
- [Red Hat Systemd Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd)

---

**Durée estimée** : 1-2 heures  
**Niveau** : Débutant à Intermédiaire  
**Compétences acquises** : Gestion systemd, Monitoring, Logging, Automation

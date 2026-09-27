# Bash Log Monitoring & Alerting System

## Description
Système de monitoring avancé en Bash pur qui surveille les fichiers de logs en temps réel, détecte les erreurs et envoie des alertes email automatiques. Perfect pour débuter en automation sysadmin.

## Objectif pédagogique
- **Bash avancé**: fonctions, arrays, regex, gestion de fichiers
- **Monitoring**: tail -f, inotify, surveillance de patterns
- **Alertes**: intégration email, throttling des alertes
- **Systemd**: création d'une unité de service
- **Configuration management**: fichiers de config, templating

## Technologies
- Bash 4+
- `tail`, `grep`, `sed`, `awk`
- `inotifywait` (file monitoring)
- `sendmail` ou `mail` (email)
- systemd (service daemon)

## Structure du projet
```
projects/2026-09-27_bash-log-monitoring-alerts/
├── README.md
├── config/
│   ├── log-monitor.conf          # Configuration principale
│   └── alert-rules.conf          # Règles d'alertes
├── scripts/
│   ├── log-monitor.sh            # Script principal
│   ├── send-alert.sh             # Fonction d'alerte
│   └── utils.sh                  # Fonctions utilitaires
├── systemd/
│   └── log-monitor.service       # Unité systemd
├── tests/
│   ├── test-logs/
│   │   └── sample.log            # Logs d'exemple
│   └── run-tests.sh              # Suite de tests
└── examples/
    └── alert-email-template.txt  # Template email
```

## Étapes de réalisation

### Étape 1: Configuration
- Créer le fichier `config/log-monitor.conf` avec les paths et règles
- Définir les patterns d'erreurs à monitorer
- Configurer les destinataires email

### Étape 2: Scripts principaux
- `scripts/log-monitor.sh`: boucle de surveillance avec tail
- `scripts/send-alert.sh`: envoi d'alerte email formatée
- `scripts/utils.sh`: logging, parsing de config, gestion d'état

### Étape 3: Intégration Systemd
- Créer `systemd/log-monitor.service` pour lancer le daemon
- Enable/start avec systemctl
- Logs accessibles via journalctl

### Étape 4: Tests & Validation
- Suite de tests pour simuler des erreurs
- Vérification du monitoring en temps réel
- Test d'envoi d'alerte

## Installation & Usage

### Pré-requis
```bash
# Sur Ubuntu/Debian
sudo apt-get install inotify-tools mailutils
# ou postfix/sendmail pour les alertes email

# Vérifier la version de Bash
bash --version  # doit être 4+
```

### Installation rapide
```bash
cd projects/2026-09-27_bash-log-monitoring-alerts

# 1. Éditer la configuration
nano config/log-monitor.conf

# 2. Donner les permissions
chmod +x scripts/*.sh

# 3. Tester en mode foreground
./scripts/log-monitor.sh -c config/log-monitor.conf -f

# 4. Installer comme service systemd
sudo cp systemd/log-monitor.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable log-monitor
sudo systemctl start log-monitor
```

### Vérification
```bash
# Voir le statut
sudo systemctl status log-monitor

# Vérifier les logs
sudo journalctl -u log-monitor -f

# Générer une erreur de test
echo "$(date) ERROR: Test error for monitoring" >> /var/log/test.log
```

## Ce qu'on apprend

### Concepts Bash
- Parsing de fichiers de configuration avec `source`
- Arrays associatifs (Bash 4+)
- Expressions régulières avec `[[ ]]` et `grep -E`
- Fonctions avec arguments et return codes
- Gestion des signaux (SIGTERM, SIGHUP)

### Monitoring & Observabilité
- Tail-follow pour surveiller les logs en temps réel
- inotifywait pour détecter les changements de fichiers
- Regex patterns pour détecter les erreurs
- Throttling des alertes (ne pas spammer email)

### Automation & DevOps
- Création d'unités systemd
- Gestion de daemons
- Logging structuré
- État persistant (fichiers de tracking)

### Real-world patterns
- Configuration externalisée
- Fonction d'alertes pluggable (email, webhook, Slack)
- Rate limiting des notifications
- Gestion des erreurs robuste

## Cas d'usage réels
1. **Server monitoring**: surveiller `/var/log/syslog`, `/var/log/auth.log`
2. **Application logs**: monitorer les logs custom d'une app
3. **Multi-server**: adapter pour monitorer logs de plusieurs serveurs
4. **Alerting**: intégrer Slack/PagerDuty au lieu d'email

## Extensions possibles
- Webhook HTTP au lieu d'email
- Intégration Slack/Discord
- Dashboard web avec historique d'alertes
- Compression/rotation des anciens logs
- Machine learning pour détecter les anomalies

## Notes importantes
- Ce système est à usage éducatif pour débuter avec les scripts Bash
- Pour production, considérer des outils comme ELK Stack, Datadog, ou New Relic
- Le monitoring systemd/journald native peut être plus robuste
- Bien tester avant de déployer en production

## Ressources
- [Bash Manual - Arrays](https://www.gnu.org/software/bash/manual/html_node/Arrays.html)
- [inotifywatch man page](https://linux.die.net/man/1/inotifywatch)
- [systemd service files](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [Regex in Bash](https://www.gnu.org/software/bash/manual/html_node/Conditional-Constructs.html)

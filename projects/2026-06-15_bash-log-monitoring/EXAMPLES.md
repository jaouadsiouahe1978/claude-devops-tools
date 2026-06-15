# Exemples d'utilisation - Log Monitoring System

## 1. Setup initial

```bash
cd projects/2026-06-15_bash-log-monitoring

# Vérifier les tests
make test
# Résultat: ✓ ALL TESTS PASSED

# Voir l'aide disponible
make help
```

## 2. Monitoring basique

### Démarrer le monitoring
```bash
# En foreground (avec debug)
bash scripts/log-monitor.sh --debug

# En background
nohup bash scripts/log-monitor.sh > data/monitor.log 2>&1 &

# Vérifier qu'il tourne
bash scripts/log-monitor.sh --status
```

### Vérifier les alertes
```bash
# Voir les dernières alertes
tail -20 data/alerts.log

# Suivre les alertes en direct
tail -f data/alerts.log
```

## 3. Analyser des logs

### Exemple avec /var/log/syslog
```bash
bash scripts/log-analyzer.sh /var/log/syslog

# Output:
# ═════════════════════════════════════════
#   Log Analysis: /var/log/syslog
# ═════════════════════════════════════════
# 📊 Total lines: 1234
# 🔴 Errors: 45
# 🟡 Warnings: 128
# Ratio: 14.05% issues
#
# ═════════════════════════════════════════
#   Top Error Types
# ═════════════════════════════════════════
#   12 × Connection refused
#    8 × Timeout occurred
#    ...
```

## 4. Générer des rapports

### Rapport pour aujourd'hui
```bash
bash scripts/report-generator.sh $(date '+%Y-%m-%d') all

# Crée:
# - data/reports/report-2026-06-15.csv
# - data/reports/report-2026-06-15.txt
# - data/reports/report-2026-06-15.json
```

### Vérifier les rapports
```bash
# Voir le rapport texte
cat data/reports/report-2026-06-15.txt

# Voir le CSV
cat data/reports/report-2026-06-15.csv

# Voir le JSON
jq '.' data/reports/report-2026-06-15.json
```

## 5. Gestion des alertes

### Tester une alerte
```bash
bash scripts/alert-manager.sh --test

# Output:
# [14:32:05] SENDING: [WARN] Test alert from host-name at 2026-06-15 14:32:05
```

### Voir les stats d'alertes
```bash
bash scripts/alert-manager.sh --stats

# Output:
# ═════════════════════════════════════
#   Alert Statistics
# ═════════════════════════════════════
# Total alerts: 42
#
# By severity:
#   ERROR     : 28
#   WARN      :  8
#   CRITICAL  :  6
#
# Today's alerts:
#   34 alerts today
```

### Effacer le cache d'alertes
```bash
bash scripts/alert-manager.sh --clear-cache
# Alert cache cleared
```

## 6. Rotation et archivage

### Roter les logs maintenant
```bash
bash scripts/log-rotator.sh --rotate

# Output:
# [timestamp] Rotating: /var/log/syslog (2.5M)
# [timestamp] Compressed: /tmp/log-archive/syslog.20260615.gz
# [timestamp] Cleared: /var/log/syslog
```

### Nettoyer les vieux logs
```bash
bash scripts/log-rotator.sh --cleanup

# Supprime automatiquement les logs > 30 jours
```

### Vérifier la taille des archives
```bash
bash scripts/log-rotator.sh --check

# Output:
# [timestamp] Archive disk usage: 245M
```

## 7. Configuration personnalisée

### Surveiller un fichier log custom

```bash
# Éditer config/monitoring.conf
vim config/monitoring.conf

# Ajouter à LOG_PATHS:
LOG_PATHS=(
    "/var/log/syslog"
    "/var/log/auth.log"
    "/var/log/myapp.log"        # ← Nouveau
    "/opt/services/app/error.log" # ← Nouveau
)
```

### Changer les seuils d'alerte

```bash
# Pour être très sensible aux erreurs:
ALERT_THRESHOLD_ERROR=3         # Au lieu de 10
ALERT_TIME_WINDOW=60            # 1 minute au lieu de 5

# Pour être moins sensible:
ALERT_THRESHOLD_ERROR=50
ALERT_TIME_WINDOW=600           # 10 minutes
```

### Configurer Slack

```bash
# 1. Créer un webhook sur https://api.slack.com/apps
# 2. Copier l'URL du webhook
# 3. Ajouter à config/monitoring.conf:

ENABLE_WEBHOOK=true
WEBHOOK_URL="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX"

# 4. Tester:
bash scripts/alert-manager.sh --test
```

## 8. Automation avec Cron

### Installer les cron jobs
```bash
bash cron/cron-jobs.sh --install

# Cron jobs installés:
# */5 * * * *  - Monitor check every 5 min
# 0 2 * * *    - Daily log rotation at 2 AM
# 0 23 * * *   - Daily report at 11 PM
# 0 3 * * 0    - Weekly cleanup on Sunday
```

### Vérifier les cron jobs installés
```bash
bash cron/cron-jobs.sh --list

# Output:
# Current monitoring cron jobs:
# */5 * * * * /path/to/scripts/log-monitor.sh --config ...
# 0 2 * * * /path/to/scripts/log-rotator.sh --full
# ...
```

### Retirer les cron jobs
```bash
bash cron/cron-jobs.sh --remove
```

## 9. Scénarios réalistes

### Scenario 1: Monitoring d'une app Python

```bash
# 1. Éditer config/monitoring.conf
LOG_PATHS=("/var/log/myapp.log")
ERROR_PATTERN="ERROR|Exception|Traceback|Failed"
WARN_PATTERN="WARN|Deprecation"
ALERT_THRESHOLD_ERROR=5
ENABLE_WEBHOOK=true

# 2. Démarrer le monitoring
bash scripts/log-monitor.sh &

# 3. Créer un test d'erreur
echo "[2026-06-15 14:00:00] ERROR Database connection failed" >> /var/log/myapp.log

# 4. Observer l'alerte Slack
# → Message apparaît dans Slack en ~5 secondes

# 5. Générer un rapport
bash scripts/report-generator.sh 2026-06-15 all
```

### Scenario 2: Monitoring de sécurité (SSH)

```bash
# Configuration pour auth.log
LOG_PATHS=("/var/log/auth.log")
ERROR_PATTERN="Invalid user|Failed password|Connection refused"
ALERT_THRESHOLD_ERROR=3        # Très sensible
ENABLE_WEBHOOK=true
WEBHOOK_URL="https://hooks.slack.com/..." # Private channel #security

# Le monitoring alertera immédiatement en cas de:
# - Tentatives de connexion échouées
# - Utilisateurs invalides
# - Attaques de brute-force
```

### Scenario 3: Monitoring de performance

```bash
# Configuration pour les logs de performance
LOG_PATHS=("/var/log/syslog" "/var/log/kern.log")
ERROR_PATTERN="Out of memory|CPU|Hung task|Soft lockup"
ALERT_THRESHOLD_ERROR=1        # Alerter dès la 1ère occurrence
RETENTION_DAYS=90              # Garder long-terme pour analyse

# Rapports quotidiens pour trend analysis
make report
```

## 10. Cas d'usage avancé: Docker Compose

### Créer un docker-compose.yml pour le monitoring

```yaml
version: '3.8'
services:
  log-monitor:
    image: ubuntu:latest
    volumes:
      - /var/log:/var/log:ro
      - ./projects/2026-06-15_bash-log-monitoring:/monitoring
    working_dir: /monitoring
    command: bash scripts/log-monitor.sh --config config/monitoring.conf
    environment:
      - DEBUG_MODE=true
    restart: unless-stopped
```

### Démarrer le monitoring en Docker
```bash
docker-compose up -d log-monitor
```

## 11. Dépannage

### Le monitoring s'arrête

```bash
# Vérifier le processus
ps aux | grep log-monitor

# Vérifier les logs
tail -50 data/monitor.log

# Redémarrer
bash scripts/log-monitor.sh --stop
bash scripts/log-monitor.sh
```

### Les alertes n'arrivent pas sur Slack

```bash
# Vérifier la config du webhook
grep WEBHOOK_URL config/monitoring.conf

# Tester directement
curl -X POST \
  -H 'Content-type: application/json' \
  --data '{"text":"Test"}' \
  YOUR_WEBHOOK_URL

# Ou utiliser le script test
bash scripts/alert-manager.sh --test
```

### Les rapports ne se génèrent pas

```bash
# Vérifier que les alertes existent
cat data/alerts.log

# Générer un rapport manuellement
bash scripts/report-generator.sh 2026-06-15 all

# Vérifier le dossier de sortie
ls -la data/reports/
```

## 12. Metriques de performance

### Vérifier la consommation mémoire du monitor

```bash
# Démarrer le monitoring
bash scripts/log-monitor.sh &
PID=$!
sleep 5

# Vérifier la mémoire
ps -o pid,vsz,rss -p $PID
# PID   VSZ   RSS
# 1234 12345 1234    # ~1-2 MB typiquement

# Tuer le processus
kill $PID
```

## 13. Intégration avec ELK Stack

```bash
# Si vous avez ELK Stack, vous pouvez:
# 1. Exporter les CSV en JSON
# 2. Utiliser Logstash pour parser
# 3. Indexer dans Elasticsearch
# 4. Visualiser dans Kibana

bash scripts/report-generator.sh 2026-06-15 json | \
  jq '.alerts[] | {timestamp, severity, message}' | \
  curl -X POST http://localhost:9200/logs/_doc -d @-
```

---

**Tips & Tricks:**

- Utilisez `make` pour les opérations courantes
- Les logs sont conservés dans `data/` pour traceabilité
- Les rapports sont automatiquement archivés
- Les alertes dupliquées sont supprimées via cache
- Testez d'abord manuellement avant d'installer les crons


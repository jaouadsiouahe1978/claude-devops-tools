# Quick Start Guide - Log Monitoring System

## 🚀 5-Minute Setup

### 1. Vérifier la structure

```bash
cd projects/2026-06-15_bash-log-monitoring
ls -la
```

### 2. Exécuter les tests

```bash
make test
# ou
bash tests/test-runner.sh
```

### 3. Configurer

```bash
# Éditer la configuration
vim config/monitoring.conf

# Ou utiliser la config par défaut (surveillera /var/log/syslog et /var/log/auth.log)
```

### 4. Démarrer le monitoring

```bash
make start
# ou
bash scripts/log-monitor.sh --debug
```

### 5. Vérifier le statut

```bash
make status
```

## 📊 Opérations couantes

### Voir les derniers alertes
```bash
make logs
tail -f data/alerts.log
```

### Analyser les logs
```bash
bash scripts/log-analyzer.sh /var/log/syslog
```

### Générer un rapport
```bash
make report
```

### Roter les logs
```bash
make rotate
```

## 🔧 Configuration personnalisée

### 1. Ajouter un nouveau fichier log à surveiller

```bash
# Dans config/monitoring.conf, modifier:
LOG_PATHS=(
    "/var/log/syslog"
    "/var/log/auth.log"
    "/var/log/myapp.log"  # ← Ajouter ici
)
```

### 2. Configurer les seuils d'alerte

```bash
ALERT_THRESHOLD_ERROR=10    # Nombre d'erreurs avant alerte
ALERT_THRESHOLD_WARN=20     # Nombre d'avertissements
ALERT_TIME_WINDOW=300       # Fenêtre de temps (5 min)
```

### 3. Configurer les notifications

```bash
# Slack webhook
ENABLE_WEBHOOK=true
WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# Email
ENABLE_EMAIL=true
ALERT_EMAIL="admin@example.com"
```

## 🧪 Test avec des logs simulés

### 1. Créer des logs de test

```bash
# Générer des erreurs
echo "[2026-06-15 14:00:00] ERROR Database connection failed" >> /tmp/test.log
echo "[2026-06-15 14:00:01] WARN Slow query detected" >> /tmp/test.log
echo "[2026-06-15 14:00:02] CRITICAL Memory threshold exceeded" >> /tmp/test.log
```

### 2. Analyser les logs de test

```bash
bash scripts/log-analyzer.sh /tmp/test.log
```

## 📈 Cas d'usage

### Monitoring d'un serveur d'application

```bash
# Configurer pour surveiller:
LOG_PATHS=("/var/log/app.log" "/var/log/error.log")
ERROR_PATTERN="ERROR|Exception|Failed"
ALERT_THRESHOLD_ERROR=5
ENABLE_WEBHOOK=true
```

### Monitoring de sécurité (SSH, auth)

```bash
LOG_PATHS=("/var/log/auth.log" "/var/log/syslog")
ERROR_PATTERN="Invalid user|Failed password|Connection refused"
ALERT_THRESHOLD_ERROR=3  # Très sensible
```

### Monitoring d'infrastructure

```bash
LOG_PATHS=("/var/log/syslog" "/var/log/kern.log")
ERROR_PATTERN="ERROR|CRIT|panic"
ENABLE_REPORTS=true
RETENTION_DAYS=90
```

## 🔗 Intégration avec Slack

### 1. Créer un Incoming Webhook

- Aller sur https://api.slack.com/apps
- Créer une nouvelle app
- Activer "Incoming Webhooks"
- Créer un webhook et copier l'URL

### 2. Configurer le webhook

```bash
# Dans config/monitoring.conf
WEBHOOK_URL="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX"
```

### 3. Tester l'envoi

```bash
bash scripts/alert-manager.sh --test
```

## 📋 Commandes utiles

```bash
# Voir les statistiques d'alertes
bash scripts/alert-manager.sh --stats

# Effacer le cache d'alertes (pour retester)
bash scripts/alert-manager.sh --clear-cache

# Générer un rapport CSV
bash scripts/report-generator.sh 2026-06-15 csv

# Vérifier la rotation des logs
bash scripts/log-rotator.sh --check

# Installation des cron jobs
bash cron/cron-jobs.sh --install

# Lister les cron jobs installés
bash cron/cron-jobs.sh --list
```

## 🐛 Débogage

### Mode debug

```bash
DEBUG_MODE=true bash scripts/log-monitor.sh
```

### Voir les logs du moniteur

```bash
tail -f data/monitor.log
```

### Vérifier l'exécution des processus

```bash
ps aux | grep log-monitor
```

### Vérifier les fichiers surveillés

```bash
# Voir les fichiers configurés
cat config/monitoring.conf | grep LOG_PATHS

# Vérifier qu'ils existent
for f in /var/log/syslog /var/log/auth.log; do
  [ -f "$f" ] && echo "✓ $f" || echo "✗ $f not found"
done
```

## 📚 Structure des fichiers

```
projects/2026-06-15_bash-log-monitoring/
├── config/
│   └── monitoring.conf      # Configuration principale
├── scripts/
│   ├── log-monitor.sh       # Monitoring principal
│   ├── log-analyzer.sh      # Analyse avancée
│   ├── alert-manager.sh     # Gestion des alertes
│   ├── log-rotator.sh       # Rotation des logs
│   └── report-generator.sh  # Génération de rapports
├── cron/
│   └── cron-jobs.sh         # Configuration des crons
├── tests/
│   ├── test-runner.sh       # Suite de tests
│   └── test-logs/           # Logs de test
├── data/
│   ├── alerts.log           # Historique des alertes
│   ├── monitor.log          # Logs du monitoring
│   └── reports/             # Rapports générés
├── Makefile                 # Commandes rapides
└── README.md                # Documentation complète
```

## 🎓 Apprenez les concepts

- **Tail-based monitoring**: surveillance continue de fichiers
- **Pattern matching**: détection de regex dans les logs
- **Alert aggregation**: éviter la surcharge d'alertes
- **Log rotation**: gérer la taille des logs
- **Reporting**: générer des résumés périodiques

## ⚠️ Notes importantes

1. **Permissions**: Assurez-vous d'avoir accès aux fichiers logs
2. **Webhooks**: Configurez l'URL de webhook avant d'activer les notifications
3. **Cron jobs**: Testez d'abord manuellement avant d'installer en cron
4. **Logs**: Les alertes sont stockées dans `data/alerts.log`

---

**Besoin d'aide?** Consultez `README.md` pour la documentation complète.

# Bash Log Monitoring & Alerting System

## 📌 Description

Création d'un système complet de monitoring des logs en Bash qui:
- **Surveille** les fichiers logs en temps réel
- **Parse** et **analyse** les patterns d'erreurs (ERROR, WARN, CRITICAL)
- **Génère des alertes** basées sur des seuils configurables
- **Archive** les logs anciens
- **Crée des rapports** quotidiens
- **Envoie des notifications** (email, webhook)

## 🎯 Objectifs d'apprentissage

✅ Scripting Bash avancé (fonctions, arrays, regex)
✅ Traitement de fichiers avec `awk`, `sed`, `grep`
✅ Gestion des processus et des signaux
✅ Cron jobs et scheduling
✅ Configuration et logging
✅ Intégration avec des services externes

## 📋 Pré-requis

- Linux/Unix (Ubuntu 20.04+, CentOS 8+, etc.)
- Bash 4.0+
- Outils standards: `grep`, `awk`, `sed`, `curl`, `mail` (optionnel)
- Permissions d'écriture dans `/var/log` et `/tmp`

## 🚀 Structure du projet

```
.
├── README.md
├── config/
│   ├── monitoring.conf          # Configuration principale
│   └── alert-rules.conf         # Règles d'alertes
├── scripts/
│   ├── log-monitor.sh           # Script de monitoring principal
│   ├── log-analyzer.sh          # Analyse des patterns
│   ├── alert-manager.sh         # Gestion des alertes
│   ├── log-rotator.sh           # Rotation des logs
│   └── report-generator.sh      # Rapports quotidiens
├── cron/
│   └── cron-jobs.sh             # Configuration des cron jobs
├── tests/
│   ├── test-logs.sh             # Logs de test
│   └── test-runner.sh           # Suite de tests
└── data/
    ├── alerts.log               # Historique des alertes
    └── reports/                 # Rapports générés
```

## 📝 Installation & Configuration

### 1️⃣ Cloner et configurer

```bash
cd projects/2026-06-15_bash-log-monitoring
chmod +x scripts/*.sh
chmod +x cron/*.sh
```

### 2️⃣ Éditer la configuration

```bash
# Copier le template de config
cp config/monitoring.conf.example config/monitoring.conf

# Éditer avec vos chemins logs
vim config/monitoring.conf
```

### 3️⃣ Tester le monitoring

```bash
# Mode debug
bash scripts/log-monitor.sh --debug

# Mode test
bash tests/test-runner.sh
```

## 🔧 Utilisation

### Démarrer le monitoring

```bash
bash scripts/log-monitor.sh --config config/monitoring.conf
```

### Analyser les logs existants

```bash
bash scripts/log-analyzer.sh /var/log/syslog
```

### Générer un rapport

```bash
bash scripts/report-generator.sh --date 2026-06-15 --output reports/
```

### Roter les logs

```bash
bash scripts/log-rotator.sh --config config/monitoring.conf
```

## ⚙️ Features principales

### 1. Real-time Log Monitoring
- Suivi continu des fichiers logs
- Détection de changements (tail -f)
- Support de multiples fichiers logs

### 2. Pattern Detection
- Regex configurable pour ERROR, WARN, CRITICAL
- Compteurs d'occurrences
- Extraction de contexte (lignes avant/après)

### 3. Smart Alerting
- Seuils d'alerte configurables
- Agrégation des alertes (évite le spam)
- Notifications via webhook ou email
- Historique des alertes

### 4. Log Rotation
- Archive automatique des vieux logs
- Compression gzip
- Purge des logs au-delà de N jours

### 5. Daily Reports
- Résumé des erreurs du jour
- Top 10 des erreurs
- Statistiques par service
- Export CSV

## 📊 Exemple de configuration

```bash
# monitoring.conf
LOG_PATHS=("/var/log/syslog" "/var/log/app.log")
ERROR_PATTERN="ERROR|CRITICAL|FATAL"
WARN_PATTERN="WARN|WARNING"
ALERT_THRESHOLD=10        # Alerte si >10 erreurs en 5min
ALERT_WINDOW=300          # Fenêtre de temps (secondes)
WEBHOOK_URL="https://hooks.slack.com/..."
ALERT_EMAIL="admin@example.com"
RETENTION_DAYS=30
```

## 🧪 Tests

```bash
# Générer des logs de test
bash tests/test-runner.sh --generate-logs

# Exécuter les tests complets
bash tests/test-runner.sh

# Vérifier les alertes générées
tail -f data/alerts.log
```

## 📈 Cas d'usage

✅ Monitoring des serveurs d'application
✅ Détection d'anomalies dans les logs
✅ Alertes automatiques aux DevOps
✅ Rapports de compliance/audit
✅ Archivage long-terme des logs

## 🔗 Intégrations possibles

- Slack/Teams webhooks pour alertes
- Email via sendmail/postfix
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Datadog/New Relic APIs
- Custom webhooks

## 📚 Concepts Bash couverts

- Fonctions réutilisables
- Arrays et associative arrays
- Expressions régulières (grep, sed, awk)
- Gestion des fichiers et pipes
- Redirection I/O
- Traitement des signaux (SIGTERM, SIGINT)
- Variables d'environnement
- Gestion des processus backgroundé
- Logging et debugging

## 🎓 Points d'apprentissage clés

1. **Traitement efficace des logs** avec awk/sed
2. **Async processing** avec jobs backgroundé
3. **Reliable alerting** sans surcharge
4. **Log rotation** sécurisée
5. **Testing** de scripts Bash
6. **Production-ready patterns** en Bash

## ⚡ Next Steps

1. Implémenter le monitoring principal
2. Ajouter les règles d'alerte
3. Configurer les notifications
4. Mettre en place les cron jobs
5. Écrire les tests unitaires
6. Générer des rapports

---

**Créé pour:** Jaouad - Formation DevOps/SRE
**Date:** 2026-06-15
**Niveau:** Débutant → Intermédiaire

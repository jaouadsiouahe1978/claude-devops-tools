# DevOps Projects Index - 2026-06-15

## 📌 Aujourd'hui: Bash Log Monitoring & Alerting System

**Date:** 2026-06-15  
**Niveau:** Débutant → Intermédiaire  
**Technos:** Bash, Linux, Logs, Regex, Cron, Webhooks  
**Durée:** ~1 jour  

### 🎯 Objectif
Créer un **système complet de monitoring des logs** en Bash qui surveille les fichiers logs en temps réel, détecte les patterns d'erreurs, génère des alertes configurables, et produit des rapports quotidiens.

### 📂 Structure
```
projects/2026-06-15_bash-log-monitoring/
├── config/monitoring.conf           # Configuration principale
├── scripts/
│   ├── log-monitor.sh              # Monitoring en temps réel
│   ├── log-analyzer.sh             # Analyse avancée
│   ├── alert-manager.sh            # Gestion des alertes
│   ├── log-rotator.sh              # Rotation des logs
│   └── report-generator.sh         # Rapports quotidiens
├── cron/cron-jobs.sh               # Configuration des crons
├── tests/test-runner.sh            # Suite de tests
├── Makefile                        # Commandes rapides
├── README.md                       # Documentation complète
└── QUICKSTART.md                   # Démarrage rapide
```

### ✨ Features
✅ Monitoring temps réel avec tail -f  
✅ Detection de patterns ERROR/WARN/CRITICAL  
✅ Alertes avec seuils configurables  
✅ Notifications Slack/webhook  
✅ Rotation automatique des logs  
✅ Rapports CSV/JSON/Text  
✅ Cron jobs pour automation  
✅ Cache des alertes pour éviter le spam  
✅ Tests unitaires  

### 🚀 Quick Start
```bash
cd projects/2026-06-15_bash-log-monitoring
make test              # Tests
make start             # Démarrer le monitoring
make analyze           # Analyser les logs
make report            # Générer un rapport
```

### 🎓 Concepts Bash couverts
- Fonctions réutilisables et modularité
- Arrays et associative arrays
- Expressions régulières (grep, sed, awk)
- Gestion des fichiers et pipes
- Redirection I/O
- Traitement des signaux (SIGTERM, SIGINT)
- Gestion des processus backgroundé
- Logging et debugging

### 📊 Commandes principales
```bash
bash scripts/log-monitor.sh         # Démarrer le monitoring
bash scripts/log-analyzer.sh [file] # Analyser un fichier log
bash scripts/alert-manager.sh --test # Test d'alerte
bash scripts/log-rotator.sh --full  # Rotation complète
bash scripts/report-generator.sh [date] [format] # Générer un rapport
bash cron/cron-jobs.sh --install    # Installer les crons
bash tests/test-runner.sh           # Exécuter les tests
```

### 🔧 Configuration
- Fichiers logs à surveiller
- Patterns de regex (ERROR, WARN, CRITICAL, etc.)
- Seuils d'alerte
- Webhook Slack/Discord
- Email (optionnel)
- Rétention des logs
- Intervalle de vérification

### 🧪 Tests inclus
- Configuration loading
- Log file generation
- Pattern matching
- Analyzer functionality
- Report generation
- Directory structure
- Scripts permissions

### 📚 Apprendre par l'exemple

#### 1. Monitoring d'une application
```bash
LOG_PATHS=("/var/log/app.log")
ERROR_PATTERN="ERROR|Exception"
ALERT_THRESHOLD_ERROR=5
```

#### 2. Monitoring de sécurité
```bash
LOG_PATHS=("/var/log/auth.log")
ERROR_PATTERN="Invalid user|Failed password"
ALERT_THRESHOLD_ERROR=3
```

#### 3. Monitoring d'infrastructure
```bash
LOG_PATHS=("/var/log/syslog" "/var/log/kern.log")
RETENTION_DAYS=90
COMPRESSION=true
```

### 🔗 Intégrations possibles
- Slack webhooks pour alertes real-time
- Email via sendmail
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Datadog/New Relic APIs
- Custom webhooks et APIs

### 💡 Points clés d'apprentissage
1. **Tail-based monitoring** - surveillance continue de fichiers
2. **Pattern matching** - détection de regex efficace
3. **Alert aggregation** - éviter la surcharge d'alertes
4. **Log rotation** - gestion sécurisée de la taille
5. **Reporting** - génération de résumés périodiques
6. **Cron automation** - scheduling d'opérations

### 📈 Cas d'usage en production
- Monitoring des serveurs d'application
- Détection d'anomalies
- Alertes automatiques pour DevOps
- Rapports de compliance/audit
- Archivage long-terme des logs

### ⚙️ Prochaines étapes
1. Tester le monitoring sur vos logs
2. Configurer un webhook Slack
3. Installer les cron jobs
4. Générer des rapports de test
5. Intégrer avec votre infrastructure

---

## 📚 Index des projets précédents

### 2026-06-14: Ansible Infrastructure Automation
- Playbooks pour infrastructure complète
- Roles: base, docker, nginx, postgres, monitoring
- Configuration IaC avec Ansible

### 2026-06-13: Prometheus & Grafana Monitoring
- Stack de monitoring complète
- Dashboards pré-configurés
- Alertes PromeQL

### 2026-06-12: Terraform AWS Infrastructure
- Infrastructure as Code
- Multi-environments (dev, staging, prod)
- Networking, security, EC2, RDS

### 2026-06-10: GitHub Actions Multi-service
- CI/CD pour app Node.js + Python
- Docker build et push
- Tests automatisés

### 2026-06-09: Ansible Deploy Stack
- Stack multi-tier avec Ansible
- Docker, Nginx, PostgreSQL
- Configuration complète

### 2026-06-08: Jenkins Pipeline
- Pipeline CI/CD Jenkinsfile
- Stages: build, test, deploy

### 2026-06-06: Helm Kubernetes Multi-tier
- Chart Helm complet
- Frontend, Backend, Database
- Valeurs dev/prod

---

**Formation:** DevOps/SRE à Grenoble  
**Créé pour:** Jaouad  
**Date:** 2026-06-15

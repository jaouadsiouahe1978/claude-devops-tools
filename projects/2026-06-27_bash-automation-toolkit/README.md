# 🔧 Bash Automation Toolkit - DevOps Daily Project

## 📌 Vue d'Ensemble

Un **toolkit complet de scripts Bash** pour automatiser les tâches DevOps/SysAdmin les plus communes :
- Backup & archivage
- Monitoring système en temps réel
- Gestion des logs
- Déploiement d'applications
- Health checks et notifications

**Pourquoi c'est important ?** En production, les scripts Bash sont PARTOUT. C'est le langage glue qui automatise tout ce qui peut l'être. Maîtriser Bash = super-pouvoir DevOps.

## 🎯 Objectifs du Jour

✅ Créer **5 scripts Bash production-ready**  
✅ Apprendre les **patterns avancés** (error handling, logging, modularity)  
✅ Implémenter des **best practices** (shellcheck compliance, documentation)  
✅ Tester les scripts dans un **environnement réaliste**

## 🛠️ Technos Principales

- **Bash 4.0+** : scripting shell moderne
- **ShellCheck** : linting statique pour éviter les bugs
- **Cron** : scheduling des tâches automatisées
- **Syslog** : centralisation des logs
- **jq** : parsing JSON depuis Bash
- **curl** : requêtes HTTP pour notifications

## 📁 Structure du Projet

```
projects/2026-06-27_bash-automation-toolkit/
├── README.md                          # Ce fichier
├── .shellcheckrc                      # Config ShellCheck
├── lib/
│   ├── common.sh                      # Fonctions réutilisables
│   ├── logging.sh                     # Logging & notifications
│   └── validation.sh                  # Validation input/state
├── scripts/
│   ├── backup-databases.sh            # Backup PostgreSQL/MySQL
│   ├── system-health-check.sh         # CPU, RAM, disk, network
│   ├── log-rotation-manager.sh        # Gestion intelligente des logs
│   ├── app-deployment.sh              # CI/CD - déployer une app
│   └── cleanup-old-files.sh           # Nettoyage disque
├── examples/
│   ├── cron-schedule.txt              # Exemples de crontabs
│   └── usage-scenarios.md             # Cas d'usage réels
├── tests/
│   ├── test-common.sh                 # Tests unitaires
│   └── test-validation.sh
└── .gitignore
```

## 🚀 Démarrage Rapide

### 1️⃣ Setup

```bash
cd projects/2026-06-27_bash-automation-toolkit/
chmod +x scripts/*.sh
chmod +x lib/*.sh
```

### 2️⃣ Installer ShellCheck (optionnel mais recommandé)

```bash
# Sur Ubuntu/Debian
sudo apt-get install shellcheck

# Sur macOS
brew install shellcheck
```

### 3️⃣ Lancer un Script

```bash
# Voir l'usage
./scripts/system-health-check.sh --help

# Exécuter
./scripts/system-health-check.sh

# Avec options
./scripts/system-health-check.sh --cpu-alert 75 --mem-alert 80
```

## 📚 Les 5 Scripts

### 1. `backup-databases.sh`

**Backups** PostgreSQL/MySQL avec compression et vérification d'intégrité.

```bash
./scripts/backup-databases.sh \
  --type postgres \
  --output /backups/ \
  --retention 30
```

**Ce qu'il fait :**
- Dump la DB compète
- Compresse en `.tar.gz`
- Vérifie la taille (pas de backup vide !)
- Supprime les vieux backups (rotation)
- Log tout

**Concepts Bash :**
- `local` variables dans les fonctions
- `trap` pour cleanup (même si erreur)
- `mktemp` pour fichiers temporaires sécurisés
- Gestion d'erreurs avec `set -e` et `set -o pipefail`

---

### 2. `system-health-check.sh`

**Monitor temps réel** CPU, RAM, disque, réseau avec alertes.

```bash
./scripts/system-health-check.sh --cpu-alert 75 --mem-alert 85
```

**Output exemple :**
```
[2026-06-27T10:45:23Z] HEALTH CHECK REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CPU Usage       : 34.2% [████░░░░░░░] OK
Memory Usage    : 62.1% [██████░░░░] WARNING
Disk Usage (/)  : 78.5% [███████░░░] OK
Network IO      : ↓ 2.3MB/s ↑ 512KB/s
Load Average    : 0.92 (4 cores)

Status: ⚠️  WARNING (memory high)
```

**Concepts Bash :**
- Parsing `/proc/` filesystem
- Calculs arithmétiques : `$((CPU / 4))`
- String formatting avec `printf`
- Comparaisons numériques `[[ $var -gt 75 ]]`

---

### 3. `log-rotation-manager.sh`

**Gestion intelligente** des logs sans utiliser `logrotate`.

```bash
./scripts/log-rotation-manager.sh \
  --dir /var/log/app/ \
  --pattern "*.log" \
  --size 100M \
  --keep 7
```

**Ce qu'il fait :**
- Scan un répertoire
- Compresse les logs > taille limite
- Archive les vieux fichiers
- Supprime après N jours
- Envoie résumé via webhook Slack (optionnel)

**Concepts Bash :**
- `find` avec options de filtrage
- `gzip` / `tar` pour compression
- Timestamps avec `date +%s`
- Boucles sur les résultats `while read -r`

---

### 4. `app-deployment.sh`

**Pipeline de déploiement** simple mais robuste.

```bash
./scripts/app-deployment.sh \
  --repo https://github.com/user/app.git \
  --branch main \
  --target /opt/myapp \
  --healthcheck http://localhost:8080/health
```

**Étapes :**
1. Git pull / clone
2. Exécute build (Dockerfile, Makefile, ou script)
3. Backup version précédente
4. Deploy code nouveau
5. Health check
6. Rollback si failure

**Concepts Bash :**
- Gestion de git depuis scripts
- Vérification d'état avec `curl -f`
- Rollback (backup/restore)
- Logging d'exécution

---

### 5. `cleanup-old-files.sh`

**Nettoyage disque** intelligent (find + delete safely).

```bash
./scripts/cleanup-old-files.sh \
  --dir /tmp /var/tmp /home/user/cache \
  --days 30 \
  --min-size 1M \
  --dry-run
```

**Ce qu'il fait :**
- Scan répertoires
- Filtre par ancienneté & taille
- Mode `--dry-run` pour preview
- Supprime seulement si confirmé
- Report d'économies disque

**Concepts Bash :**
- `find` avec `-mtime`, `-size`, `-type`
- `du` pour calcul taille
- Interactivité avec `read -p`
- Sécurité : pas de `rm *`

## 🎓 Concepts Clés à Apprendre

### Robustesse & Error Handling

```bash
#!/bin/bash
set -euo pipefail  # Fail fast, no undefined vars, no pipe failures

trap cleanup EXIT ERR INT
cleanup() {
  rm -f "$TMPFILE"  # Always cleanup
  [[ $? -eq 0 ]] && echo "✅ Success" || echo "❌ Failed"
}
```

### Functions & Modularity

```bash
# Dans lib/common.sh
log_info() {
  local msg="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $msg" | tee -a "$LOGFILE"
}

log_error() {
  local msg="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $msg" >&2 | tee -a "$LOGFILE"
  return 1
}

# Utiliser dans un script
source "$(dirname "$0")/../lib/common.sh"
log_info "Starting backup..."
```

### Argument Parsing

```bash
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir) DIR="$2"; shift 2 ;;
    --retention) RETENTION="$2"; shift 2 ;;
    --help) show_usage; exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done
```

### Vérifications d'État

```bash
# File exists & readable
[[ -r "$FILE" ]] || { log_error "Cannot read $FILE"; exit 1; }

# Command exists
command -v curl &>/dev/null || { log_error "curl not found"; exit 1; }

# Directory writable
[[ -w "$DIR" ]] || { log_error "$DIR not writable"; exit 1; }
```

## 🧪 Tests & Validation

Exécute les tests unitaires :

```bash
bash tests/test-common.sh
bash tests/test-validation.sh
```

Lint avec ShellCheck :

```bash
shellcheck scripts/*.sh lib/*.sh
```

## 📅 Intégration Cron

Ajoute à `crontab -e` pour automatiser :

```bash
# Backup every day at 2 AM
0 2 * * * /home/user/scripts/backup-databases.sh >> /var/log/backups.log 2>&1

# Health check every 5 minutes
*/5 * * * * /home/user/scripts/system-health-check.sh --alert-webhook https://hooks.slack.com/...

# Log rotation daily at 3 AM
0 3 * * * /home/user/scripts/log-rotation-manager.sh --dir /var/log/app

# Cleanup old files weekly on Sunday at 4 AM
0 4 * * 0 /home/user/scripts/cleanup-old-files.sh --dir /tmp --days 30
```

## 💡 Best Practices Implémentées

✅ **Shellcheck compliance** : pas d'avertissements  
✅ **Error handling** : `set -euo pipefail` + `trap`  
✅ **Logging** : tous les outputs aux logs  
✅ **Documentation** : help text pour chaque script  
✅ **Input validation** : vérification des arguments  
✅ **Modularity** : fonctions réutilisables dans `lib/`  
✅ **Idempotency** : safe to run multiple times  
✅ **Security** : no hardcoded passwords, proper perms  

## 🎯 Défis Bonus

1. **Notifier Slack** : Ajoute webhook Slack aux alertes
   ```bash
   # Dans logging.sh
   notify_slack() {
     local msg="$1"
     curl -X POST -d "{\"text\":\"$msg\"}" "$SLACK_WEBHOOK"
   }
   ```

2. **Créer un `mailer.sh`** qui envoie des rapports email
   ```bash
   echo "Report" | mail -s "Daily Report" admin@example.com
   ```

3. **Ajouter Systemd timer** comme alternative à Cron
   - Crée `backup.service` et `backup.timer`

4. **Comparer avec Python**
   - Réécris `system-health-check.sh` en Python
   - Compare temps d'exécution et lisibilité

5. **Monitorer les scripts eux-mêmes**
   - Crée un meta-script qui vérifie que les crons s'exécutent

## 📖 Ressources Clés

- **Bash Best Practices** : https://mywiki.wooledge.org/BashGuide
- **ShellCheck** : https://www.shellcheck.net/
- **Advanced Bash Guide** : https://tldp.org/LDP/abs/html/
- **Google Shell Style Guide** : https://google.github.io/styleguide/shellguide.html

## 🔄 Flow de Travail Recommandé

**Jour 1 (aujourd'hui)** :
1. Lire ce README
2. Examiner les scripts dans `lib/`
3. Exécuter chaque script avec `--help`
4. Adapter les chemins à ton env
5. Tester `system-health-check.sh` localement

**Jour 2+** :
1. Ajouter à tes crontabs
2. Monitorer les logs
3. Implémenter les défis bonus
4. Intégrer à ton infra réelle (backup, monitoring)

## 📊 Continuité DevOps

Ce projet complète l'écosystème DevOps :

- **2026-06-25** : Prometheus/Grafana (Monitoring métrics)
- **2026-06-27** : Bash Scripts (Automation / Ops) ← TU ES ICI
- **Next** : Ansible (Configuration Management)
- **Then** : Docker (Containerization)
- **Finally** : Kubernetes (Orchestration)

**Ensemble = DevOps complet** : scripting → automation → monitoring → infrastructure

---

**Created**: 2026-06-27  
**Level**: Débutant → Intermédiaire  
**Estimated Time**: 1 jour  
**Files**: 15+ fichiers | **Lines of Code**: ~800 LOC  
**Difficulty**: ⭐⭐⭐ (Bash avancé + patterns pro)

# 🐧 Bash Server Automation - Gestion Automatisée de Serveurs Linux

## 📋 Description

Ce projet enseigne comment créer un **framework de gestion de serveurs Linux en Bash pur**. Tu vas construire :
- Un **script principal d'orchestration** (`server-manager.sh`)
- Des **modules fonctionnels** (utilisateurs, paquets, services, logs, disques)
- Un **système de logging structuré**
- Un **dashboard d'état du serveur**
- Des **hooks de monitoring** pour alertes

Ce qui fait la force : C'est du vrai Bash production-ready avec gestion d'erreurs, logging centralisé, et une architecture modulaire.

## 🎯 Objectifs d'apprentissage

- ✅ Structurer des scripts Bash complexes avec modules
- ✅ Implémenter un système de logging robuste
- ✅ Gérer les erreurs et les codes de sortie
- ✅ Automatiser les tâches système Linux
- ✅ Parser des configurations avec Bash
- ✅ Créer des rapports d'état serveur
- ✅ Monitorer disques, CPU, mémoire, processus

## 🛠️ Technologies utilisées

- **Bash 4+** - Scripting shell
- **GNU Coreutils** - date, tail, grep, awk, sed
- **Procfs** - /proc/cpuinfo, /proc/meminfo, /proc/diskstats
- **Syslog** - Logs système
- **Cron** - Ordonnancement

## 📁 Structure du projet

```
2026-06-22_bash-server-automation/
├── README.md
├── server-manager.sh          # Script principal
├── config/
│   └── server-config.sh       # Variables de configuration
├── modules/
│   ├── logging.sh             # Logging centralisé
│   ├── users.sh               # Gestion utilisateurs
│   ├── packages.sh            # Gestion des paquets
│   ├── services.sh            # Gestion des services
│   ├── disk.sh                # Monitoring disques
│   ├── system.sh              # Info système
│   └── alerts.sh              # Alertes
├── scripts/
│   ├── daily-report.sh        # Rapport quotidien
│   ├── health-check.sh        # Vérification santé
│   └── backup-configs.sh      # Backup configurations
├── cron/
│   └── crontab-entries        # Entries cron pour automation
├── logs/
│   └── .gitkeep               # Répertoire logs
└── examples/
    ├── create-user-example.sh
    ├── install-app-example.sh
    └── monitor-service-example.sh
```

## 🚀 Prérequis

- Système Linux (Ubuntu, CentOS, Debian)
- Bash 4.0+ (`bash --version`)
- Accès root ou sudo
- Permissions d'exécution sur les scripts

## 📚 Étapes de réalisation

### Étape 1: Comprendre la structure
```bash
cd projects/2026-06-22_bash-server-automation
ls -la
cat README.md
```

### Étape 2: Configurer l'environnement
```bash
# Rendre les scripts exécutables
chmod +x server-manager.sh
chmod +x scripts/*.sh
chmod +x modules/*.sh

# Source la configuration
source config/server-config.sh
```

### Étape 3: Importer les modules de logging
```bash
# Le module logging fournit :
# - log_info, log_warn, log_error
# - log_debug avec support DEBUG=1
# - Centralisation dans /var/log/server-manager.log
```

### Étape 4: Utiliser les modules
```bash
# Voir l'état du système
./server-manager.sh status

# Créer un utilisateur
./server-manager.sh create-user ubuntu password123

# Installer un paquet
./server-manager.sh install vim curl

# Vérifier la santé du serveur
./scripts/health-check.sh
```

### Étape 5: Planifier avec Cron
```bash
# Ajouter le rapport quotidien à minuit
sudo crontab -e
# 0 0 * * * /path/to/scripts/daily-report.sh
```

### Étape 6: Monitorer les performances
```bash
# Dashboard en temps réel
watch -n 5 'source ./modules/system.sh && show_system_stats'

# Générer un rapport
./scripts/daily-report.sh > /tmp/daily-report.txt
cat /tmp/daily-report.txt
```

## 🎓 Ce qu'on apprend

1. **Architecture modulaire en Bash**
   - Comment organiser les fonctions dans des fichiers séparés
   - Sourcer les modules et gérer les dépendances
   - Éviter la duplication de code

2. **Logging de production**
   - Format structuré: `[TIMESTAMP] [LEVEL] [FUNCTION] Message`
   - Rotation des logs
   - Filtrage par niveau (DEBUG, INFO, WARN, ERROR)

3. **Gestion d'erreurs robuste**
   - Codes de sortie significatifs
   - Try-catch en Bash avec `|| { ... }`
   - Nettoyage (trap)

4. **Scripting système avancé**
   - Parsing `/proc` pour CPU, mémoire, disques
   - Gestion des utilisateurs et groupes
   - Gestion des services (systemctl)
   - Calculs avec `bc` et `awk`

5. **Automation et monitoring**
   - Cron pour exécution planifiée
   - Health-checks automatisés
   - Alertes en cas de problème
   - Rapports quotidiens

## 💡 Cas d'usage réels

```bash
# 1. Ajouter un nouveau dev au serveur
./server-manager.sh create-user alice publickey.pub

# 2. Installer la stack de monitoring
./server-manager.sh install prometheus-node-exporter grafana-server

# 3. Vérifier la santé du serveur avant deploiement
./scripts/health-check.sh && echo "✅ Ready to deploy"

# 4. Générer un rapport quotidien
./scripts/daily-report.sh | mail -s "Daily Report" ops@company.com

# 5. Backup des configs système
./scripts/backup-configs.sh /etc /root/.ssh
```

## 🔍 Points clés du code

### Logging centralisé
```bash
# In modules/logging.sh
log_info "User alice created successfully"
log_error "Failed to install vim" "exit_code=$?"
```

### Gestion des erreurs
```bash
# Stopper au premier erreur + cleanup
set -euo pipefail
trap 'log_error "Script failed" ; cleanup' EXIT
```

### Parsing des stats système
```bash
# In modules/system.sh
CPU_USAGE=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$3+$4+$5)*100/($2+$3+$4+$5+$6)} {print usage}')
FREE_MEM=$(free -m | awk 'NR==2{print $7}')
DISK_USAGE=$(df -h / | awk 'NR==2{print $5}')
```

## 📦 Dépendances optionnelles

- `lsof` - Lister les fichiers ouverts
- `netstat` ou `ss` - Statistiques réseau
- `iotop` - I/O monitoring
- `curl` - Pour les appels API (alertes)
- `mail` - Pour les rapports par email

## ✅ Tests et Validation

```bash
# Vérifier la syntaxe Bash
bash -n server-manager.sh

# Exécuter en mode debug
DEBUG=1 ./server-manager.sh status

# Tester un module spécifique
bash -x modules/system.sh

# Valider les logs
tail -f logs/server-manager.log
```

## 🚨 Troubleshooting

**Erreur: "Permission denied"**
```bash
chmod +x server-manager.sh modules/*.sh scripts/*.sh
```

**Erreur: "No such file or directory"**
```bash
# Utiliser les chemins absolus
cd /full/path/to/project
./server-manager.sh status
```

**Logs vides**
```bash
# Vérifier les permissions du répertoire logs
ls -la logs/
chmod 755 logs/
```

## 📖 Ressources complémentaires

- [The Linux Command Line](http://linuxcommand.org/) - Tutoriel Bash fondamental
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/) - Bible du Bash
- [Bash Strict Mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/) - Best practices
- [Shellcheck](https://www.shellcheck.net/) - Analyse statique des scripts

## 🎯 Prochaines étapes

- Ajouter support Debian/Ubuntu/CentOS
- Intégrer avec Prometheus pour les métriques
- Créer une API REST en Python qui appelle ces scripts
- Ajouter support des variables d'environnement sécurisées
- Créer un web dashboard avec les stats en temps réel

---

**Créé le**: 2026-06-22  
**Niveau**: Débutant → Intermédiaire  
**Temps estimé**: 1 journée

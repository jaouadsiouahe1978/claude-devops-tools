# Bash Log Monitoring & Alert System

**Niveau:** Débutant à Intermédiaire  
**Durée:** ~2-4 heures  
**Technos:** Bash, systemd, cron, regex

## 🎯 Objectif

Créer un système de monitoring de logs léger et efficace qui :
- Analyse les fichiers journaux en temps quasi-réel
- Détecte les patterns d'erreur configurables
- Envoie des alertes par mail ou fichier
- S'exécute automatiquement via cron
- Maintient un historique des alertes

## 📋 Pré-requis

```bash
# Ubuntu/Debian
sudo apt-get install -y mailutils grep sed awk

# CentOS/RHEL
sudo yum install -y mailx grep sed gawk

# Vérifier que postfix ou sendmail est configuré
sudo systemctl status postfix
```

## 🏗️ Structure du Projet

```
bash-log-monitor/
├── bin/
│   ├── log-monitor.sh          # Script principal de monitoring
│   └── install.sh              # Script d'installation
├── config/
│   ├── log-monitor.conf        # Configuration des logs à surveiller
│   └── alert-rules.conf        # Règles d'alerte
├── tests/
│   ├── test-alert.sh           # Génère des logs de test
│   └── sample-logs.txt         # Exemples de logs
├── README.md
└── INSTALL.md
```

## 📚 Ce qu'on apprend

### Bash Avancé
- Parsing de logs avec regex et awk
- Gestion des fichiers et des permissions
- Manipulation de dates et timestamps
- Trapping et exit codes

### System Administration
- Logs d'application et système
- Patterns d'erreur courants
- Configuration de cron jobs
- Envoi d'emails en ligne de commande

### DevOps Pratique
- Monitoring décentralisé
- Alerting simple mais efficace
- Gestion des faux positifs
- Archivage d'historique

## 🚀 Démarrage rapide

### 1. Cloner et installer

```bash
cd bash-log-monitor
chmod +x bin/*.sh
./bin/install.sh
```

### 2. Configuration basique

Éditer `config/log-monitor.conf` :

```bash
# Logs à surveiller
LOGS_TO_MONITOR="/var/log/syslog /var/log/apache2/error.log"

# Email d'alerte
ALERT_EMAIL="admin@example.com"

# Répertoire d'alertes
ALERT_DIR="/var/log/alerts"
```

### 3. Définir les règles d'alerte

Éditer `config/alert-rules.conf` :

```bash
ERROR|CRITICAL
Failed password
Connection refused
Out of memory
```

### 4. Tester manuellement

```bash
./bin/log-monitor.sh
```

### 5. Planifier avec cron

```bash
# Toutes les 5 minutes
*/5 * * * * /path/to/bin/log-monitor.sh >> /var/log/log-monitor.log 2>&1

# Installation via crontab
(crontab -l 2>/dev/null; echo "*/5 * * * * /path/to/bin/log-monitor.sh") | crontab -
```

## 🔧 Utilisation avancée

### Monitorer des logs customisés

```bash
# Ajouter à log-monitor.conf
LOGS_TO_MONITOR="/var/log/syslog /var/log/nginx/error.log /var/log/app/debug.log"
```

### Créer des règles avancées

```bash
# Patterns regex dans alert-rules.conf
ERROR.*Database
Warning.*Timeout
Segmentation fault
Database.*critical

# Exclure certains patterns
# Préfixer avec ! pour les ignorer
!DEBUG
!INFO
```

### Filtrer par intervalle de temps

```bash
# Modifier log-monitor.sh pour ajouter une recherche temporelle
grep "$(date '+%Y-%m-%d')" $LOG_FILE
```

### Envoyer des alertes structurées

```bash
# JSON format pour intégration
jq -n --arg msg "$ALERT_MSG" '{timestamp: now | floor, message: $msg}'
```

## 📊 Exemple de flux

1. **Cron déclenche** le script toutes les 5 minutes
2. **Script lit** les fichiers de log
3. **Regex évalue** chaque ligne contre les règles
4. **Alerte générée** si match trouvé
5. **Email envoyé** et log archivé
6. **Stat mise à jour** pour dashboard

## 🎓 Étapes de réalisation

### Jour 1 (Matin)
- [ ] Créer la structure de base
- [ ] Implémenter le parsing de logs simple
- [ ] Tester avec des logs d'exemple

### Jour 1 (Après-midi)
- [ ] Ajouter le système de règles
- [ ] Implémenter l'envoi d'emails
- [ ] Créer le script d'installation

### Jour 2
- [ ] Tester en production
- [ ] Ajouter la configuration cron
- [ ] Documenter et archiver

## 💡 Extensions possibles

1. **Webhooks** : Envoyer des alertes à Slack/Discord
2. **Dashboard** : Créer un dashboard simple en HTML
3. **Métriques** : Exporter vers Prometheus
4. **Déduplication** : Éviter les alertes dupliquées
5. **Priorités** : Classifier les alertes
6. **Rétention** : Nettoyer automatiquement les vieux logs

## 🔗 Ressources

- [GNU Awk](https://www.gnu.org/software/gawk/manual/)
- [Bash Guide](https://mywiki.wooledge.org/BashGuide)
- [Rsyslog Configuration](https://www.rsyslog.com/)

## ✅ Validation

Le projet est validé quand :
- ✓ Le script détecte les erreurs dans les logs
- ✓ Les emails sont reçus correctement
- ✓ Cron exécute le script sans erreur
- ✓ L'historique des alertes est archivé
- ✓ Les faux positifs sont minimisés

---

**Créé par:** Claude Haiku 4.5  
**Date:** 2026-10-30  
**Pour:** Jaouad - Formation DevOps/SRE

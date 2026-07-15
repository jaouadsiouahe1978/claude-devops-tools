# Bash Advanced Monitoring & Log Analysis Toolkit

**Date:** 2026-07-15  
**Level:** Débutant à Intermédiaire  
**Durée:** 1 journée

## 📋 Objectif

Créer un ensemble de scripts Bash réutilisables pour :
- **Monitorer les ressources système** (CPU, RAM, disque)
- **Analyser les logs** avec des patterns personnalisés
- **Détecter les anomalies** (seuils d'alerte)
- **Générer des rapports** automatisés
- **Configurer des alertes par email**

## 🛠 Technologies Utilisées

- **Bash 4+**
- **GNU coreutils** (top, free, du, ps, grep, awk, sed)
- **Syslog & journalctl**
- **Cron** pour l'automatisation

## 📁 Structure du Projet

```
2026-07-15_bash-advanced-monitoring/
├── README.md                          # Ce fichier
├── scripts/
│   ├── system-monitor.sh              # Monitorer CPU, RAM, disque
│   ├── log-analyzer.sh                # Analyser les logs d'applications
│   ├── detect-anomalies.sh            # Détection d'anomalies (seuils)
│   ├── generate-report.sh             # Générer des rapports HTML/text
│   ├── alert-email.sh                 # Envoi d'alertes par email
│   └── setup-cron.sh                  # Installer les tâches cron
├── config/
│   ├── monitor.conf                   # Config pour les seuils
│   ├── alert-rules.conf               # Règles d'alerte
│   └── email-config.conf              # Config email
├── logs/
│   ├── monitor.log                    # Logs du monitoring
│   └── report-*.txt                   # Rapports générés
└── data/
    ├── baseline-metrics.txt           # Métriques de référence
    └── alert-history.log              # Historique des alertes
```

## 🚀 Étapes de Réalisation

### 1. **Préparation de l'Environnement**
```bash
cd projects/2026-07-15_bash-advanced-monitoring
chmod +x scripts/*.sh
source config/monitor.conf
```

### 2. **Monitorer les Ressources Système**
```bash
./scripts/system-monitor.sh
# Affiche : CPU%, RAM%, DISK%, Load Average
```

### 3. **Analyser les Logs**
```bash
./scripts/log-analyzer.sh /var/log/syslog "error"
./scripts/log-analyzer.sh /var/log/auth.log "failed"
# Cherche les patterns d'erreur dans les logs
```

### 4. **Détecter les Anomalies**
```bash
./scripts/detect-anomalies.sh
# Compare les métriques actuelles avec les seuils définis
# Déclenche des alertes si dépassement
```

### 5. **Générer un Rapport**
```bash
./scripts/generate-report.sh
# Crée un rapport HTML et text avec les statistiques
```

### 6. **Configurer les Alertes par Email**
```bash
# Éditer config/email-config.conf
./scripts/setup-cron.sh
# Installe les tâches cron pour monitoring automatique
```

## 💡 Ce qu'on Apprend

✅ **Gestion des ressources système** en Bash  
✅ **Parsing et analyse de logs** avec grep, awk, sed  
✅ **Détection d'anomalies** par seuils  
✅ **Automatisation avec Cron** et scripts planifiés  
✅ **Génération de rapports** automatisés  
✅ **Alertes en temps réel** (email, syslog)  
✅ **Configuration modulaire** avec fichiers .conf  
✅ **Gestion des erreurs** et logging structuré  

## 📊 Cas d'Usage Réels

- **Monitoring de serveurs** en production
- **Détection d'attaques par force brute** (auth.log)
- **Alertes sur capacité disque** atteinte
- **Rapports d'activité système** journaliers
- **Suivi de la performance** des services

## 🔍 Points Clés

1. **Configuration centralisée** : tous les seuils dans `config/monitor.conf`
2. **Modularité** : chaque script fait une seule chose bien
3. **Robustesse** : gestion des erreurs, vérifications d'entrée
4. **Logging** : traçabilité complète des actions
5. **Extensibilité** : facile d'ajouter de nouvelles métriques

## 📝 Prérequis

- Linux/Unix avec Bash 4+
- Accès root ou sudo pour certaines métriques
- Mail configuré pour les alertes (optionnel)
- git pour la gestion des versions

## 🎯 Défi Bonus

- Ajouter le monitoring de **Docker containers**
- Intégrer les métriques dans **Prometheus**
- Créer un **dashboard web** simple (HTML + JavaScript)
- Implémenter des **graphes de tendance** (gnuplot)

## 📚 Ressources

- `man top`, `man free`, `man ps`
- `man grep`, `man awk`, `man sed`
- Bash scripting: https://mywiki.wooledge.org/BashGuide
- Cron timing: https://crontab.guru/

# 📊 DevOps du jour - 13 Juin 2026

## Prometheus + Grafana - Stack de Monitoring Complet

### 🎯 Résumé
Création d'une stack de monitoring **production-ready** avec **Prometheus** (collecte temps-réel de métriques), **Grafana** (dashboards visuels), **AlertManager** (gestion des alertes), et **Node Exporter** (métriques du système).

Ce projet 1-jour couvre l'ensemble du pipeline de monitoring moderne utilisé en DevOps/SRE pour superviser une infrastructure.

### 🛠 Technos utilisées
- **Prometheus**: Time-series database + scraper de métriques
- **Grafana**: Dashboards et visualisations en temps réel
- **AlertManager**: Routage, groupage, et suppression des alertes
- **Node Exporter**: Collecteur de métriques système (CPU, RAM, disque, réseau)
- **Docker Compose**: Orchestration des conteneurs
- **PromQL**: Langage de requête pour les métriques

### 📚 Ce qu'on apprend
1. **Scrape configs**: Comment Prometheus découvre et collecte les métriques
2. **Recording rules**: Pré-calculer les métriques complexes pour la performance
3. **Alert rules**: Définir des conditions d'alerte avec durée et seuils
4. **PromQL**: Langage de requête pour extraire du signal du bruit (rate, increase, aggregations, histogrammes)
5. **Grafana dashboards**: Créer des visualisations lisibles et utiles
6. **AlertManager**: Routage intelligent, groupage, et suppression des alertes

### 🚀 Quick Start
```bash
cd projects/2026-06-13_prometheus-grafana-monitoring
./start.sh

# Accès web:
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)
# AlertManager: http://localhost:9093
```

### 📂 Contenu du projet
```
├── docker-compose.yml           # Services (Prometheus, Grafana, Node-exp, AlertMgr)
├── prometheus/
│   ├── prometheus.yml           # Config scrape (targets + intervals)
│   ├── alert_rules.yml          # Rules d'alerte (CPU, RAM, disque, etc)
│   ├── recording_rules.yml      # Pré-calcul de métriques
│   └── alertmanager.yml         # Routage et groupage des alertes
├── grafana/provisioning/
│   ├── datasources/prometheus.yml        # Connexion Prometheus
│   └── dashboards/system-monitoring.json # Dashboard système complet
├── QUICKSTART.md                # Guide de démarrage rapide
├── PROMQL_CHEATSHEET.md         # Référence PromQL complète
├── start.sh                     # Script de démarrage + vérifications
└── test-alerts.sh               # Test des queries et alertes
```

### 📊 Dashboards inclusos
- **CPU Usage**: Utilisation CPU en temps réel (pie chart)
- **Memory Usage**: RAM utilisée vs disponible (pie chart)
- **Disk Usage**: Utilisation disque par filesystem (table avec seuils couleurs)
- **Load Average**: Charge système 1/5/15 min (graphique temporel)
- **Network Traffic**: Trafic réseau in/out (bytes/sec)
- **Disk I/O**: Taux de lectures/écritures (IOPS)

### 🚨 Règles d'alerte inclusos
- `HighCPUUsage`: CPU > 80% pendant 2 min (warning)
- `HighMemoryUsage`: RAM > 85% pendant 2 min (warning)
- `LowDiskSpace`: Espace disque < 10% (critical)
- `HighInodeUsage`: Inodes utilisés > 90% (warning)
- `HighCPUTemperature`: Température CPU > 80°C (warning)
- `ServiceDown`: Un service n'est pas accessible (critical)

### 💡 PromQL queries de base
```promql
# CPU utilisé (%)
100 * (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])))

# Mémoire disponible (MB)
node_memory_MemAvailable_bytes / 1024 / 1024

# Disque utilisé (%)
(1 - node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100

# Load average
node_load1

# Trafic réseau (Bytes/sec)
rate(node_network_receive_bytes_total[5m])
```

### ✨ Points clés
- **Scrape interval**: 15s (configurable)
- **Data retention**: 15 jours par défaut
- **Alert for duration**: L'alerte déclenche seulement après la durée `for:`
- **Recording rules**: Exécutées toutes les 30s pour pré-calculer
- **Dashboard JSON**: Peut être exporté/importé pour partager
- **Auto-discovery**: Extensible avec service discovery (Consul, Kubernetes, Docker labels)

### 🎓 Validation
- [x] Stack démarrée sans erreur
- [x] Prometheus collecte métriques (all targets UP)
- [x] Grafana accessible et configuré
- [x] Dashboard "System Monitoring" pré-créé
- [x] Règles d'alerte définies
- [x] Scripts de test inclus
- [x] Guides pour débutants (Quickstart + PromQL cheatsheet)

### 🔗 Ressources incluses
- `QUICKSTART.md`: Guide de démarrage en 5 étapes
- `PROMQL_CHEATSHEET.md`: Référence PromQL complète avec exemples
- `README.md`: Documentation détaillée du projet
- Fichiers de config commentés pour comprendre chaque section

### 📈 Next Steps
1. Tester les queries PromQL dans Prometheus UI
2. Créer un dashboard personnalisé dans Grafana
3. Simuler une charge pour tester les alertes
4. Intégrer AlertManager avec Slack/Email
5. Ajouter d'autres cibles (bases de données, applications)
6. Découvrir Prometheus Operator pour Kubernetes

---

**Créé le**: 2026-06-13  
**Niveau**: Débutant à intermédiaire  
**Durée**: ~4-6 heures (monitoring setup + dashboards + tests)  
**Repo**: https://github.com/jaouadsiouahe1978/claude-devops-tools/tree/main/projects/2026-06-13_prometheus-grafana-monitoring

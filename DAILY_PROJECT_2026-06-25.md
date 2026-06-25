# 📊 Projet DevOps du Jour - 25 Juin 2026

## Monitoring & Alerting avec Prometheus et Grafana

### 🎯 Vue d'Ensemble

Un projet complet de **stack de monitoring** pour apprendre les fondamentaux du monitoring dans une infrastructure DevOps/SRE. C'est un composant essentiel : sans monitoring, on ne voit pas les problèmes avant qu'ils n'explosent en prod.

### 🛠️ Technos Principales

- **Prometheus** : le standard de facto pour la collecte de métriques (time-series database)
- **Node Exporter** : exporte les métriques système (CPU, mémoire, disque, réseau)
- **Grafana** : plateforme de visualization et dashboarding des métriques
- **Docker Compose** : orchestration des 3 services
- **PromQL** : langage de requête pour interroger les métriques

### 📋 Contenu du Projet

```
projects/2026-06-25_monitoring-prometheus-grafana/
├── README.md                    # Guide complet
├── docker-compose.yml           # Orchestre Prometheus, Node Exporter, Grafana
├── prometheus/
│   ├── prometheus.yml           # Config Prometheus (scrape_configs)
│   └── alert-rules.yml          # Règles d'alerte pré-configurées
├── grafana/
│   ├── provisioning/datasources # Auto-provision la datasource Prometheus
│   ├── provisioning/dashboards  # Auto-provision les dashboards
│   └── dashboards/
│       └── system-overview.json # Dashboard pré-fait avec 4 panneaux
├── promql-examples.md           # Recueil de requêtes PromQL utiles
└── .gitignore
```

### 🚀 Étapes Pratiques

1. **Démarrer** : `docker-compose up -d`
2. **Explorer Prometheus** : http://localhost:9090
   - Voir les targets ("node_exporter" doit être "UP")
   - Tester des requêtes : `up`, `node_cpu_seconds_total`, `node_memory_MemAvailable_bytes`
3. **Configurer Grafana** : http://localhost:3000 (admin/admin)
   - Ajouter Prometheus comme datasource
   - Dashboard "System Overview" chargé automatiquement
   - Créer de nouveaux panels avec des requêtes PromQL
4. **Alertes** : Déjà configurées dans `alert-rules.yml`
   - CPU > 80% pendant 5 min
   - Mémoire > 85% pendant 5 min
   - Disque > 85% utilisé

### 📚 Concepts Clés Apprendre

✅ **Architecture du monitoring**
   - Exporters = applications qui exposent des métriques
   - Prometheus = collecte les métriques périodiquement (scraping)
   - Grafana = visualise et crée des dashboards

✅ **Métriques et time-series**
   - Structure : métrique_name{label1="valeur1", label2="valeur2"} = value
   - Ex: `node_cpu_seconds_total{mode="user", cpu="0"} = 12345.67`

✅ **PromQL**
   - `rate()` : taux de changement (ex: bytes/sec)
   - `sum()` / `avg()` / `max()` / `min()` : agrégations
   - Filtrage avec `{}` et matching sur les labels
   - Les fonction: `predict_linear()`, `histogram_quantile()`, etc.

✅ **Alerting**
   - Conditions basées sur les métriques
   - Durées "for:" pour éviter les faux positifs
   - Labels de severity (info, warning, critical)
   - Actions possibles : Slack, PagerDuty, email, etc.

✅ **Observabilité SRE**
   - Les "trois piliers" : Metrics, Logs, Traces
   - Prometheus = metrics foundation
   - Alertes = détection proactive des problèmes

### 💡 Points Clés à Retenir

1. **Prometheus scrape** les exporters toutes les 15 sec (configurable)
2. **PromQL** est TRÈS puissant pour agréger et transformer les données
3. **Grafana** + Prometheus = le combo standard de l'industrie
4. **Alertes** doivent avoir des seuils réalistes (pas trop sensibles)
5. **Labels** sont la clé pour filtrer/grouper les métriques

### 🎓 Défis Bonus pour Approfondir

1. Ajouter un **deuxième Node Exporter** en Docker Compose et monitorer 2 hosts
2. Créer une alerte **custom** : CPU > 60% pendant 10 min
3. Créer un **nouveau dashboard** avec :
   - Gauge : Memory usage %
   - Graph : Network traffic (in/out) over time
   - Table : Top 5 processes by CPU
4. Exporter le dashboard en **JSON** et le versionner dans Git
5. Intégrer une **alertmanager** et router les alertes vers Slack

### 🔗 Ressources Clés

- [Prometheus Documentation](https://prometheus.io/docs/)
- [PromQL Query Tutorial](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Node Exporter Metrics](https://github.com/prometheus/node_exporter)
- [Grafana Dashboards Library](https://grafana.com/grafana/dashboards/)

### 📊 Continuité DevOps

Ce projet est le **fondement de l'observabilité**. Les prochains étaient :
- 2026-06-24 : Ansible Config Management
- 2026-06-23 : Terraform IaC
- 2026-06-02 : GitHub Actions CI/CD
- 2026-06-01 : Kubernetes Deployments

Ensemble = **infrastructure-as-code complète** + **déploiements** + **monitoring** = DevOps 360°

---

**Created**: 2026-06-25 | **Duration**: ~1 jour | **Level**: Débutant → Intermédiaire
**Files**: 10 fichiers | **Lines of Code**: ~600 LOC

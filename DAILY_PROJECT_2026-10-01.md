# Projet DevOps du 1er Octobre 2026

## 🎯 Prometheus + Grafana: Stack Complet de Monitoring et Observabilité

### Thème
**Monitoring et Observabilité avec Prometheus + Grafana**

### Objectif
Construire un stack de monitoring complet et production-ready avec Prometheus comme collecteur de métriques temps-réel et Grafana pour la visualisation et alerting. Apprendre les principes d'observabilité d'infrastructure.

### Technologies Utilisées
- **Prometheus** : Time-series database et collecteur de métriques
- **Grafana** : Visualisation et dashboards
- **node-exporter** : Métriques système Linux
- **cAdvisor** : Métriques Docker/conteneurs
- **postgres-exporter** : Métriques PostgreSQL
- **nginx-exporter** : Métriques serveur web
- **AlertManager** : Gestion et routing des alertes
- **Docker & Docker Compose** : Orchestration des services

### Fichiers Créés (16 fichiers)

#### Documentation
- `README.md` : Guide complet (12.4 KB) avec architecture, concepts, cas d'usage

#### Stack Docker
- `docker-compose.yml` : 9 services orchestrés (Prometheus, Grafana, exporters, PostgreSQL, Nginx, AlertManager)

#### Configuration Prometheus
- `prometheus/prometheus.yml` : Configuration des scrape targets avec 6 jobs
- `prometheus/alerts.yml` : 40+ règles d'alerte organisées en 5 groupes
- `prometheus/recording_rules.yml` : 60+ règles d'enregistrement pour optimiser les requêtes

#### Configuration Grafana
- `grafana/provisioning/datasources/datasources.yaml` : Auto-provisioning datasource Prometheus
- `grafana/provisioning/dashboards/dashboards.yaml` : Auto-provisioning des dashboards
- `grafana/dashboards/system-overview.json` : Dashboard système (CPU, Memory, Disk, Load)
- `grafana/dashboards/docker-containers.json` : Dashboard containers (Memory, CPU, Network)
- `grafana/dashboards/database-metrics.json` : Dashboard PostgreSQL (Connexions, Transactions, Cache)

#### Configuration Services
- `nginx/nginx.conf` : Configuration Nginx avec endpoint /nginx_status pour le scraping
- `alertmanager/alertmanager.yml` : Routing d'alertes avec intégration Slack/PagerDuty

#### Scripts d'Administration
1. `scripts/setup.sh` : Initialisation complète du stack avec health checks
2. `scripts/test-metrics.sh` : Test de collecte des métriques depuis tous les exporters
3. `scripts/health-check.sh` : Vérification de santé avec résumé colorisé
4. `scripts/backup-dashboards.sh` : Sauvegarde des dashboards via API Grafana

### Concepts Clés Enseignés

#### 1. Prometheus Fundamentals
- ✅ Time-series database et scraping actif
- ✅ Types de métriques : Counter, Gauge, Histogram, Summary
- ✅ Labels et relabeling pour enrichir les données
- ✅ Stockage et rétention des données (15 jours)

#### 2. PromQL (Prometheus Query Language)
- ✅ Sélection basique et filtrage par label
- ✅ Opérateurs : rate(), increase(), topk(), sum(), avg()
- ✅ Agrégations par dimension
- ✅ Quantiles et histogrammes

#### 3. Alerting
- ✅ Règles d'alerte basées sur conditions PromQL
- ✅ Labels de sévérité (critical, warning)
- ✅ Système d'inhibition pour éviter le spam
- ✅ Integration notifications (Slack, PagerDuty)

#### 4. Dashboards Grafana
- ✅ Création de panneaux : timeseries, stat, gauge
- ✅ Variables et templating dynamique
- ✅ Légende, tooltips et formatage
- ✅ Auto-provisioning pour reproductibilité

#### 5. Observabilité
- ✅ Monitoring proactif vs réactif
- ✅ Capacity planning avec predict_linear()
- ✅ Troubleshooting avec PromQL
- ✅ Recording rules pour optimiser

### Cas d'Usage Pratiques

1. **Monitoring Applicatif**
   - Latence P50/P95/P99
   - Taux d'erreur par endpoint
   - Throughput et débit

2. **Infrastructure**
   - Alerte CPU > 80% pendant 10 min
   - Alerte mémoire < 10% disponible
   - Prédiction : "le disque sera plein dans 30 jours"

3. **Database**
   - Cache hit ratio (optimisation query)
   - Taux de transactions commit/rollback
   - Slow query detection

4. **Containers**
   - Memory usage par container
   - Restart frequency detection
   - Resource utilization trends

### Système d'Alerte (40+ rules)

#### System Alerts (5 rules)
- `InstanceDown` : Service inaccessible > 5 min
- `HighCPU` : CPU > 80% pendant 10 min
- `HighMemoryUsage` : Mémoire > 85% pendant 10 min
- `LowDiskSpace` : Disque < 15% disponible
- `HighLoadAverage` : Load 15min > 2

#### Container Alerts (3 rules)
- `ContainerDown` : Container absent > 5 min
- `HighContainerMemory` : Mémoire > 90% du limit
- `ContainerRestartLoop` : Redémarrages fréquents

#### Database Alerts (3 rules)
- `PostgreSQLDown` : Connexion perdue > 5 min
- `HighConnections` : Connexions actives > 80
- `SlowQuery` : Latence moyenne > 1s

#### Web Alerts (3 rules)
- `NginxDown` : Service inaccessible > 5 min
- `HighErrorRate` : 5xx > 5% pendant 10 min
- `HighConnections` : Connexions actives > 1000

#### Prometheus Alerts (3 rules)
- `HighMemory` : Process > 500MB
- `SampleLimit` : Taille données > 100MB
- `SlowScrapes` : P90 scrape > 10s

### Recording Rules (60+ rules)

Optimise les requêtes fréquentes :
- CPU metrics (idle, system, user)
- Memory metrics (available, total, used, percent)
- Disk I/O rates (read, write)
- Network throughput
- Container metrics
- PostgreSQL transactions & tuples
- Nginx request rates & errors

### Architecture
```
┌─────────────────────────────────────┐
│   Prometheus (9090)                 │
│  - Scrape interval: 15s            │
│  - Retention: 15 days              │
│  - Recording Rules, Alert Rules    │
└──────────────┬──────────────────────┘
               │
         ┌─────┴──────┬───────┬────────┐
         │            │       │        │
    ┌─────────┐  ┌────────┐ ┌────┐ ┌───────┐
    │node     │  │cAdvisor│ │postgres-ex │nginx-ex
    │exporter │  │        │ │    │ │
    │9100     │  │8080    │ │9187│ │4040
    └────┬────┘  └────────┘ └────┘ └───────┘
         │
    ┌─────────────────────────────┐
    │  Grafana (3000)             │
    │  - 3 Dashboards            │
    │  - Auto-provisioning       │
    └────────────┬────────────────┘
                 │
         ┌───────┴────────┐
         │                │
    ┌─────────────┐  ┌──────────────┐
    │AlertManager │  │Slack/Pagerduty
    │9093         │  │Notifications
    └─────────────┘  └──────────────┘
```

### Points Clés à Retenir

1. **Pull vs Push** : Prometheus scrape activement (pull), pas pusher (push)
2. **Labels** : Essentiels pour organiser et filtrer les métriques
3. **Retention** : À configurer selon storage disponible et SLA
4. **Alerting** : Les rules PromQL sont la base, AlertManager gère le routing
5. **Scalabilité** : Prometheus pour small infra, Thanos pour petabyte-scale
6. **Performance** : Recording rules réduisent la charge query

### Temps Estimé

- **Matin (2-3h)** :
  - Lancer le stack docker-compose
  - Comprendre Prometheus et PromQL
  - Exploiter les métriques

- **Après-midi (2-3h)** :
  - Créer/modifier dashboards Grafana
  - Configurer alertes personnalisées
  - Tester health-check et scripts

### Résultats Attendus

✅ Stack Prometheus + Grafana + 4 exporters fonctionnel  
✅ 3 dashboards pré-configurés visibles et navigables  
✅ 40+ alertes configurées et testables  
✅ Capable de creuser dans les données avec PromQL  
✅ Scripts d'administration pour maintenance  
✅ Comprendre l'architecture monitoring d'une vraie infra  

### Variété Thématique Cette Semaine

- 2026-09-24 : Bash tools, Container security
- 2026-09-25 : Nginx LB, Python tools
- 2026-09-26 : Jenkins, PostgreSQL HA
- 2026-09-27 : Bash monitoring, ELK
- 2026-09-28 : Docker app, Traefik
- 2026-09-29 : Ansible, Kubernetes
- 2026-09-30 : GitHub Actions CI/CD
- **2026-10-01 : Prometheus + Grafana Monitoring** ✨

### Progression DevOps/SRE

Cette semaine couvre :
- ✅ Conteneurisation (Docker, Kubernetes)
- ✅ Orchestration (Docker Compose, Ansible)
- ✅ CI/CD (GitHub Actions, Jenkins)
- ✅ Monitoring & Observabilité (Prometheus, Grafana, ELK)
- ✅ Infrastructure as Code (Terraform)
- ✅ Web Servers (Nginx, Traefik)
- ✅ Databases (PostgreSQL, HA)
- ✅ Security (container scanning, secrets)

### Liens Utiles

- [Prometheus Documentation](https://prometheus.io/docs/)
- [PromQL Tutorial](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Alerting Best Practices](https://prometheus.io/docs/practices/alerting/)
- [node-exporter Metrics](https://github.com/prometheus/node_exporter)
- [Awesome Prometheus](https://github.com/prometheus/prometheus/wiki/Awesome-Prometheus)

---

**Status** : ✅ Complété et pushé sur main (commit: a482c6b)  
**Repository** : https://github.com/jaouadsiouahe1978/claude-devops-tools  
**Fichiers** : 16 fichiers, 2615 lignes de configuration/code  
**Date** : 2026-10-01  
**Niveau** : Débutant à Intermédiaire  
**Durée** : 1 journée  

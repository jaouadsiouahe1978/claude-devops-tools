# Prometheus + Grafana Monitoring Stack

## Objectif
Mettre en place une stack complète de monitoring avec Prometheus (collecte de métriques) et Grafana (visualisation) pour monitorer une application multi-conteneurs.

## Technologies utilisées
- **Prometheus** : collecte et stockage de métriques time-series
- **Grafana** : visualisation et dashboards
- **Node Exporter** : métriques du système Linux
- **Docker & Docker Compose** : orchestration des conteneurs
- **PromQL** : langage de requête des métriques Prometheus

## Architecture
```
┌─────────────────────────────────────┐
│  Application + Exporters             │
│  ├─ Node Exporter (port 9100)       │
│  ├─ cAdvisor (port 8080)            │
│  └─ App with /metrics (port 8000)   │
└────────────┬────────────────────────┘
             │ scrape
┌────────────▼────────────────────────┐
│  Prometheus (port 9090)              │
│  ├─ Scrape configs                  │
│  ├─ Alert rules                     │
│  └─ Time-series database            │
└────────────┬────────────────────────┘
             │ query
┌────────────▼────────────────────────┐
│  Grafana (port 3000)                 │
│  ├─ Dashboards                      │
│  ├─ Alerts                          │
│  └─ Data sources                    │
└─────────────────────────────────────┘
```

## Étapes de réalisation

### 1. Cloner et naviguer
```bash
cd projects/2026-08-03_prometheus-grafana
```

### 2. Démarrer la stack
```bash
docker-compose up -d
```

### 3. Vérifier les services
- Prometheus : http://localhost:9090
- Grafana : http://localhost:3000 (admin/admin)
- Node Exporter : http://localhost:9100/metrics
- cAdvisor : http://localhost:8080

### 4. Ajouter Prometheus comme data source dans Grafana
1. Aller à Configuration > Data Sources
2. Cliquer "Add data source"
3. Sélectionner Prometheus
4. URL : http://prometheus:9090
5. Cliquer "Save & Test"

### 5. Créer un dashboard
1. Cliquer "+" > Dashboard
2. Ajouter des panneaux avec les requêtes PromQL :
   - `node_cpu_seconds_total` : CPU usage
   - `node_memory_MemAvailable_bytes` : Mémoire disponible
   - `container_memory_usage_bytes` : Mémoire des conteneurs

### 6. Tester les alertes
```bash
docker-compose exec prometheus curl http://localhost:9093/api/v1/alerts
```

## Ce qu'on apprend

### Concepts clés
- **Métriques vs Logs** : Prometheus utilise des métriques (nombres) vs ELK (logs textuels)
- **Scraping** : Prometheus va récupérer les métriques via HTTP
- **Time-Series Database (TSDB)** : Stockage optimisé pour les données temporelles
- **PromQL** : Langage puissant pour interroger les métriques (agrégations, filtres, jointures)

### Bonnes pratiques
- Naming convention : `job_metric_unit` (ex: `node_cpu_seconds_total`)
- Cardinality : éviter une explosion de labels
- Retention : Prometheus garde ~15 jours par défaut
- Alertmanager : escalade des alertes (email, Slack, etc.)

### Compétences DevOps
- Monitoring proactif vs réactif (logs)
- Dashboard design et KPIs
- Alertes intelligentes (seuils adaptés)
- Collecte de métriques personnalisées

## Fichiers principaux
- `docker-compose.yml` : Orchestration de la stack
- `prometheus/prometheus.yml` : Configuration des scrapes et alertes
- `prometheus/alert_rules.yml` : Règles d'alerte
- `grafana/provisioning/dashboards/` : Dashboards préconfigurés

## Prochaines étapes
- Intégrer Alertmanager pour la gestion des alertes
- Créer des alertes personnalisées pour votre application
- Ajouter des exporters spécifiques (PostgreSQL, Redis, etc.)
- Configurer la fédération Prometheus pour plusieurs instances

## Ressources
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Dashboards Library](https://grafana.com/grafana/dashboards/)
- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)

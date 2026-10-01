# Prometheus + Grafana: Stack Complet de Monitoring et Observabilité

## 🎯 Objectif

Construire un stack de monitoring complet avec Prometheus et Grafana pour visualiser et alerter sur les métriques d'une infrastructure.

## 📚 Concepts Clés

### Prometheus
- **Time-series database** : Base de données optimisée pour les séries temporelles
- **Scraping** : Récupération active des métriques via HTTP
- **Métriques** : Gauge, Counter, Histogram, Summary
- **Alertes** : Système d'alerte basé sur des règles

### Grafana
- **Visualisation** : Création de dashboards riches
- **Datasources** : Connexion à multiple sources (Prometheus, Loki, etc.)
- **Alerting** : Alertes visuelles et notifications
- **Templating** : Dashboards dynamiques avec variables

### Exporters
- **node_exporter** : Métriques du système Linux
- **cAdvisor** : Métriques des conteneurs Docker
- **postgres_exporter** : Métriques PostgreSQL
- **nginx-prometheus-exporter** : Métriques Nginx

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────┐
│           Prometheus                             │
│  - Scrape interval: 15s                         │
│  - Retention: 15 days                           │
│  - Port: 9090                                   │
└──────────────────────────────────────────────────┘
           ↑
    ┌──────┼──────┬──────────┬──────────┐
    │      │      │          │          │
┌─────┐ ┌────────┐ ┌──────────┐ ┌──────────┐
│node │ │cAdvisor│ │postgres  │ │ Nginx    │
│expl │ │ :8080  │ │exporter  │ │exporter  │
│ 9100│ └────────┘ │ :9187    │ │ :4040   │
└─────┘            └──────────┘ └──────────┘
    │                 │            │
    └─────────────────┼────────────┘
                      │
                  App Services
                      │
         ┌────────────┴────────────┐
         │                         │
    ┌──────────┐            ┌──────────────┐
    │Prometheus│            │   Grafana    │
    │ Alert    │            │              │
    │Manager   │            │  Dashboards  │
    └──────────┘            │  Port: 3000  │
         │                  └──────────────┘
         │
    ┌────────────┐
    │Slack/Email │
    │Notifications
    └────────────┘
```

## 🛠️ Prérequis

- Docker & Docker Compose (20.10+)
- 2GB RAM minimum
- Port disponibles : 9090, 3000, 9100, 8080, 9187, 4040

## 📁 Structure du Projet

```
2026-10-01_prometheus-grafana-monitoring/
├── README.md                          # Ce fichier
├── docker-compose.yml                 # Stack complète
├── prometheus/
│   ├── prometheus.yml                 # Configuration Prometheus
│   ├── alerts.yml                     # Règles d'alerte
│   └── recording_rules.yml            # Règles d'enregistrement
├── grafana/
│   ├── datasources/
│   │   └── prometheus.yml             # Datasource Prometheus
│   ├── dashboards/
│   │   ├── system-overview.json       # Dashboard système
│   │   ├── docker-containers.json     # Dashboard Docker
│   │   └── database-metrics.json      # Dashboard BD
│   └── provisioning/
│       ├── datasources.yaml           # Auto-provisioning datasources
│       └── dashboards.yaml            # Auto-provisioning dashboards
├── exporters/
│   ├── node-exporter.yml              # Config node-exporter
│   ├── cadvisor.yml                   # Config cAdvisor
│   └── postgres-exporter.yml          # Config postgres-exporter
├── scripts/
│   ├── setup.sh                       # Initialisation du stack
│   ├── test-metrics.sh                # Test des métriques
│   ├── backup-dashboards.sh           # Sauvegarde dashboards
│   └── health-check.sh                # Vérification santé
└── docker-compose.override.yml        # Overrides locaux
```

## 🚀 Guide de Démarrage

### Étape 1 : Cloner et Accéder au Répertoire

```bash
cd projects/2026-10-01_prometheus-grafana-monitoring
```

### Étape 2 : Lancer le Stack

```bash
docker-compose up -d
```

Vérifiez que tous les services démarrent :
```bash
docker-compose ps
```

### Étape 3 : Vérifier les Métriques Prometheus

- **Prometheus UI** : http://localhost:9090
- **Graphs** : Allez à "Graph" et exécutez une requête (ex: `up`)
- **Alerts** : Allez à "Alerts" pour voir les règles d'alerte
- **Targets** : Allez à "Status > Targets" pour voir les sources

### Étape 4 : Accéder à Grafana

- **URL** : http://localhost:3000
- **User** : `admin`
- **Password** : `admin` (changer au premier login!)

### Étape 5 : Explorer les Dashboards

Les dashboards pré-configurés sont disponibles :
- **System Overview** : CPU, Memory, Disk, Network
- **Docker Containers** : Métriques de tous les conteneurs
- **Database Metrics** : Performance PostgreSQL

## 📊 Concepts Prometheus

### Types de Métriques

#### 1. Counter
Métrique qui augmente uniquement (cumulative) :
```
# Requête
rate(http_requests_total[5m])  # Requêtes par seconde sur 5 min
increase(http_requests_total[1h])  # Total sur 1 heure
```

#### 2. Gauge
Métrique qui peut augmenter ou diminuer :
```
# Exemples
node_memory_MemAvailable_bytes
node_cpu_seconds_total
```

#### 3. Histogram
Distribution des valeurs (buckets) :
```
# Requête
histogram_quantile(0.95, http_request_duration_seconds_bucket)
```

#### 4. Summary
Quantiles pré-calculés :
```
rate(http_request_duration_seconds_sum[5m]) / 
rate(http_request_duration_seconds_count[5m])
```

### PromQL (Prometheus Query Language)

Exemples essentiels :

```promql
# Sélection basique
up  # Tous les services up

# Filtre par label
up{job="prometheus"}

# Opérateurs
rate(http_requests_total[5m])  # Taux (par seconde)
increase(memory_usage[1h])     # Augmentation sur 1h
topk(5, memory_usage)          # Top 5 consommateurs

# Agrégations
sum(rate(http_requests_total[5m]))       # Total global
avg(node_cpu_seconds_total)              # Moyenne
max(memory_usage)                        # Maximum
quantile(0.95, response_time)           # P95 latence
```

## 🔔 Système d'Alerte

### Exemple Règles d'Alerte (alerts.yml)

```yaml
groups:
  - name: system
    interval: 30s
    rules:
      # Alerte : serveur down
      - alert: InstanceDown
        expr: up == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "{{ $labels.instance }} is down"

      # Alerte : CPU élevé
      - alert: HighCPU
        expr: rate(node_cpu_seconds_total[5m]) > 0.8
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High CPU on {{ $labels.instance }}"

      # Alerte : Mémoire faible
      - alert: LowMemory
        expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Low memory on {{ $labels.instance }}"
```

## 📈 Cas d'Usage Pratiques

### 1. Monitoring d'Application

```promql
# Latence P95 des requêtes HTTP
histogram_quantile(0.95, http_request_duration_seconds_bucket)

# Taux d'erreur
rate(http_requests_total{status=~"5.."}[5m]) / 
rate(http_requests_total[5m])
```

### 2. Capacity Planning

```promql
# Croissance mémoire sur 30 jours
predict_linear(node_memory_MemAvailable_bytes[30d], 86400)

# Espace disque sera plein quand?
predict_linear(node_filesystem_avail_bytes[1d], 86400 * 30)
```

### 3. Troubleshooting

```promql
# Tous les services down
up == 0

# Services avec haute latence
histogram_quantile(0.99, http_request_duration_seconds_bucket) > 1

# Conteneurs qui redémarrent souvent
rate(container_last_seen[5m]) > 0.01
```

## 🔐 Sécurité

### Points Clés

1. **Authentification Prometheus** :
```bash
# Avec reverse proxy + auth
docker-compose.override.yml avec Traefik + basicauth
```

2. **Authentification Grafana** :
```bash
# Changez le mot de passe par défaut!
admin:admin → mot de passe fort
```

3. **Rétention des Données** :
```bash
# Prometheus garde 15 jours par défaut
# Ajustez selon vos besoins (--storage.tsdb.retention.time=30d)
```

4. **Exposition des Métriques** :
```bash
# N'exposez pas /metrics publiquement
# Utilisez un firewall ou reverse proxy avec auth
```

## 📊 Exercices Pratiques

### Exercice 1 : Créer un Dashboard Personnalisé

1. Allez à Grafana > Dashboards > New Dashboard
2. Créez des panneaux pour :
   - Nombre de requêtes HTTP par secondes
   - Latence P50, P95, P99
   - Taux d'erreur
3. Sauvegardez comme JSON

### Exercice 2 : Configurer une Alerte

1. Prometheus : Ajoutez une alerte à `prometheus/alerts.yml`
2. Rechargez le config : `curl -X POST http://localhost:9090/-/reload`
3. Vérifiez dans "Status > Alerts"
4. Testez le trigger en générant du load

### Exercice 3 : Exporter des Métriques Personnalisées

1. Écrivez une app Python avec `prometheus-client`
2. Exposez les métriques sur `:8000/metrics`
3. Ajoutez dans `prometheus.yml` comme scrape target
4. Visualisez dans Grafana

## 🐛 Troubleshooting

### Prometheus n'atteint pas les exporters

```bash
# 1. Vérifiez la connectivité
docker-compose exec prometheus curl http://node-exporter:9100/metrics

# 2. Vérifiez la config
docker-compose exec prometheus cat /etc/prometheus/prometheus.yml

# 3. Rechargez
curl -X POST http://localhost:9090/-/reload
```

### Grafana ne voit pas Prometheus

```bash
# 1. Vérifiez que Prometheus est up
curl http://localhost:9090/api/v1/targets

# 2. Dans Grafana : Configuration > Data Sources
# 3. Assurez-vous que l'URL est : http://prometheus:9090
```

### Manque de mémoire

```bash
# Réduisez la rétention
docker-compose.yml : --storage.tsdb.retention.time=7d

# Ou augmentez les ressources
Modifier les limites de mémoire dans docker-compose.yml
```

## 📚 Concepts Clés à Retenir

1. **Prometheus scrape activement** vs Loki/ELK qui reçoivent les logs
2. **PromQL** est un langage query riche pour explorer les données
3. **Alertes** se basent sur des conditions PromQL
4. **Dashboards** visualisent les données de manière compréhensible
5. **Rétention** doit être configurée selon vos besoins
6. **Scalabilité** : Prometheus pour petites infra, Thanos pour larges

## 🎓 Ce Qu'On Apprend

✅ Time-series databases et métriques  
✅ Système de monitoring complet  
✅ Dashboard création et configuration  
✅ Alerting et notification  
✅ PromQL pour requêter les données  
✅ Exporters pour instrumenter l'infra  
✅ Observabilité et troubleshooting  

## 📞 Ressources Utiles

- [Prometheus Docs](https://prometheus.io/docs/)
- [PromQL Tutorial](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Docs](https://grafana.com/docs/)
- [node_exporter Metrics](https://github.com/prometheus/node_exporter)
- [Awesome Prometheus](https://github.com/prometheus/prometheus/wiki/Awesome-Prometheus)

## ⏱️ Temps Estimé

- **Matin (2-3h)** : Lancer le stack, comprendre Prometheus et PromQL
- **Après-midi (2-3h)** : Créer dashboards, configurer alertes, explorer les métriques

## ✨ Résultats Attendus

- ✅ Stack Prometheus + Grafana + 4 exporters fonctionnel
- ✅ 3 dashboards pré-configurés visibles
- ✅ 10+ alertes configurées
- ✅ Capable de creuser dans les données avec PromQL
- ✅ Comprendre l'architecture monitoring d'une vraie infra

---

**Créé** : 2026-10-01  
**Thème** : Monitoring et Observabilité  
**Niveau** : Débutant à Intermédiaire  
**Durée** : 1 jour  

# 📊 Prometheus & Grafana Monitoring Stack

Construire une stack de monitoring complète avec Prometheus et Grafana pour superviser une application et le système.

## 📋 Objectif

Mettre en place une infrastructure de monitoring moderne qui collecte des métriques en temps réel, les stocke dans Prometheus, et les visualise dans Grafana avec des alertes configurées.

## 🔧 Pré-requis

- Docker & Docker Compose
- `curl` ou un navigateur web
- Un port libre: 9090 (Prometheus), 3000 (Grafana), 8080 (app example)

```bash
docker --version
docker-compose --version
```

## 🎯 Étapes de réalisation

### 1️⃣ Démarrer la stack de monitoring

```bash
cd /path/to/project
docker-compose up -d
```

Cela lance:
- **Prometheus** (http://localhost:9090) - Collecte et stockage des métriques
- **Grafana** (http://localhost:3000) - Dashboards et visualisation
- **Node Exporter** (port 9100) - Métriques du système
- **App Flask simple** (http://localhost:8080) - Application avec métriques Prometheus

### 2️⃣ Vérifier que Prometheus collecte les données

```bash
# Accédez à Prometheus
curl http://localhost:9090/api/v1/targets

# Vérifier les métriques brutes
curl http://localhost:9090/api/v1/query?query=up
curl http://localhost:9090/api/v1/query?query=node_cpu_seconds_total
```

### 3️⃣ Se connecter à Grafana

1. Ouvrez http://localhost:3000
2. Login: **admin** / **admin**
3. Changez le mot de passe
4. Allez à **Connections > Data sources**
5. Cliquez **Add data source** et sélectionnez **Prometheus**
6. URL: `http://prometheus:9090`
7. Cliquez **Save & test**

### 4️⃣ Importer un dashboard

1. Dans Grafana, allez à **Dashboards**
2. Cliquez **New > Import**
3. Utilisez ID **1860** (Node Exporter Full)
4. Sélectionnez la source **Prometheus**
5. Cliquez **Import**

Vous verrez maintenant les métriques système en temps réel!

### 5️⃣ Créer un dashboard personnalisé

1. Cliquez **+ > Dashboard**
2. Cliquez **Add visualization**
3. Requête Prometheus:
   ```promql
   rate(http_requests_total[5m])
   ```
4. Sélectionnez le type de graphique
5. Cliquez **Save**

### 6️⃣ Configurer des alertes

Éditez `prometheus/alert_rules.yml`:
```yaml
groups:
  - name: example
    rules:
      - alert: HighCPU
        expr: node_cpu_seconds_total > 80
        for: 5m
        annotations:
          summary: "CPU élevé détecté"
```

Rechargez Prometheus:
```bash
docker-compose restart prometheus
```

## 📚 Ce qu'on apprend

✅ **Prometheus** - Configuration, scraping, stockage de métriques  
✅ **Requêtes PromQL** - Langage de requête pour les métriques  
✅ **Grafana** - Création de dashboards et visualisations  
✅ **Exporters** - Collection de métriques (Node Exporter)  
✅ **Monitoring** - Supervision en temps réel de l'infrastructure  
✅ **Alertes** - Configuration de seuils et notifications  
✅ **Docker Compose** - Orchestration multi-conteneurs  
✅ **Instrumentalisation d'app** - Ajouter des métriques à une application

## 📁 Structure du projet

```
.
├── README.md                        # Ce fichier
├── docker-compose.yml               # Stack complète
├── prometheus/
│   ├── prometheus.yml               # Config Prometheus
│   ├── alert_rules.yml              # Règles d'alerte
│   └── targets.json                 # Cibles de scraping
├── grafana/
│   ├── provisioning/
│   │   ├── dashboards/
│   │   │   └── dashboard.yml        # Dashboard provisionné
│   │   └── datasources/
│   │       └── prometheus.yml       # DataSource Prometheus
│   └── grafana.ini                  # Config Grafana
├── exporters/
│   └── app.py                       # Flask app avec métriques
└── dashboards/
    └── system-metrics.json          # Dashboard JSON
```

## 🔑 Points clés

### Métriques Prometheus

Prometheus collecte trois types de métriques:
- **Counter** - Valeur qui augmente (ex: requêtes totales)
- **Gauge** - Valeur qui peut augmenter/diminuer (ex: CPU)
- **Histogram** - Distribution de valeurs (ex: latences)

### PromQL - Requêtes utiles

```promql
# Rate d'une métrique
rate(http_requests_total[5m])

# Somme des valeurs
sum(rate(http_requests_total[5m])) by (handler)

# CPU utilisé
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Requêtes lentes
histogram_quantile(0.95, http_request_duration_seconds)
```

### Retention des données

Prometheus garde les métriques localement pendant 15 jours par défaut. Pour les conserver plus longtemps, utilisez un stockage distant (RemoteStorage).

## 🧪 Cas d'usage avancés

### Ajouter une cible de scraping dynamiquement

```yaml
scrape_configs:
  - job_name: 'custom-app'
    static_configs:
      - targets: ['localhost:8080']
```

### Requête sur plusieurs labels

```promql
sum by (handler, method) (rate(http_requests_total[5m]))
```

### Exporter les métriques pour Grafana Cloud

Utilisez le Prometheus remote write pour centraliser vos métriques.

### Utiliser Alertmanager pour les notifications

Configurez Alertmanager pour envoyer les alertes à Slack, PagerDuty, etc.

## 📖 Ressources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [PromQL Guide](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Node Exporter Metrics](https://github.com/prometheus/node_exporter)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/instrumentation/)

## 🧹 Cleanup

```bash
docker-compose down -v
```

Cela arrête tous les conteneurs et supprime les volumes (données Prometheus et Grafana).

---

**Durée estimée**: 1 journée  
**Niveau**: Débutant à Intermédiaire  
**Tags**: #monitoring #prometheus #grafana #observability #devops

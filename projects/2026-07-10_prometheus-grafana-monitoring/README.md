# Prometheus + Grafana Monitoring Stack

## 📋 Description

Mettre en place un stack de monitoring complet avec **Prometheus** (collecte de métriques) et **Grafana** (visualisation) en Docker Compose. Vous monitorerez :
- Les métriques du Docker daemon
- Les performances système (CPU, RAM, disque)
- Les métriques applicatives avec un exporter personnalisé

## 🎯 Objectif

À la fin du jour, vous aurez :
- Une stack Prometheus + Grafana entièrement fonctionnelle
- Des dashboards Grafana préconfigurés
- Un petit exporter Python qui envoie des métriques custom
- Une compréhension de comment Prometheus scrape les données
- Savoir alerter sur des seuils (optionnel avec Alertmanager)

## 🛠️ Technologies

- **Docker & Docker Compose** : Orchestration des conteneurs
- **Prometheus** : Time-series database + alerting
- **Grafana** : Visualisation et dashboarding
- **Node Exporter** : Export des métriques système
- **cAdvisor** : Metrics des conteneurs Docker
- **Python** : Petit exporter custom avec prometheus_client

## 📦 Pré-requis

- Docker et Docker Compose installés
- Au moins 2GB de RAM libre
- Port 9090 (Prometheus), 3000 (Grafana), 9100 (Node Exporter) libres

## 🚀 Étapes de réalisation

### 1. Structure du projet
```
.
├── docker-compose.yml
├── prometheus/
│   ├── prometheus.yml         # Config Prometheus
│   └── alert-rules.yml        # Règles d'alerte
├── grafana/
│   └── provisioning/          # Datasources + dashboards
├── exporters/
│   ├── custom-exporter.py     # Exporter Python custom
│   └── requirements.txt
└── README.md
```

### 2. Démarrer le stack
```bash
docker-compose up -d
```

Puis accédez à :
- Prometheus : http://localhost:9090
- Grafana : http://localhost:3000 (login: admin/admin)
- Node Exporter : http://localhost:9100/metrics

### 3. Explorer Prometheus
- Aller dans le Graph explorer
- Exécuter des queries PromQL :
  - `node_cpu_seconds_total{job="node-exporter"}`
  - `container_cpu_usage_seconds_total{pod_name=""}`
  - `prometheus_build_info`

### 4. Créer des dashboards Grafana
- Ajouter Prometheus comme datasource
- Importer des dashboards community (Node Exporter Full, Docker etc)
- Créer un dashboard custom pour votre exporter Python

### 5. Exporter custom
Lancer l'exporter Python qui envoie des métriques :
```bash
pip install -r exporters/requirements.txt
python exporters/custom-exporter.py
```

L'exporter sera visible en tant que job dans Prometheus.

### 6. Alertes (Optionnel)
Configurer des règles dans `prometheus/alert-rules.yml` et Alertmanager pour notifier sur des seuils.

## 💡 Ce qu'on apprend

✅ Architecture d'un stack de monitoring (Pull vs Push)  
✅ Prometheus PromQL : queries sur les métriques  
✅ Grafana : créer des dashboards professionnels  
✅ Docker Compose avec volumes et réseaux  
✅ Exporters : comment collecter des métriques  
✅ Best practices : scrape intervals, retention, alerting  

## 📚 Ressources

- [Prometheus Docs](https://prometheus.io/docs)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards)
- [PromQL Tutorial](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Node Exporter Metrics](https://github.com/prometheus/node_exporter)

## 🔧 Troubleshooting

**Prometheus n'est pas accessible ?**
- Vérifier : `docker-compose ps`
- Logs : `docker-compose logs prometheus`

**Pas de métriques dans Grafana ?**
- Vérifier que les targets sont UP dans Prometheus
- Checker les scrape configs

**Port occupé ?**
- Changer les ports dans docker-compose.yml


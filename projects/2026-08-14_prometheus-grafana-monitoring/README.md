# Monitoring avec Prometheus et Grafana

## Description
Mise en place d'une stack de monitoring complète avec **Prometheus** (collecte des métriques) et **Grafana** (visualisation et dashboards). Le projet inclut une application Node.js simple qui expose des métriques, Prometheus qui les scrape à intervalle régulier, et Grafana pour créer des dashboards professionnels.

### Objectif
- Apprendre à configurer Prometheus pour scraper des métriques
- Créer des dashboards dans Grafana
- Monitorer une application en temps réel
- Mettre en place des alertes
- Comprendre les concepts de métriques (counters, gauges, histograms)

## Technologies utilisées
- **Docker & Docker Compose** : orchestration des services
- **Prometheus** : système de monitoring et time-series DB
- **Grafana** : visualisation des métriques et création de dashboards
- **Node.js** : application exemple avec prom-client
- **AlertManager** : gestion des alertes

## Pré-requis
- Docker et Docker Compose installés
- Connaissance basique de Docker et des métriques
- Port 9090, 3000, 9093 disponibles

## Architecture
```
┌─────────────────────────────────────────────────────┐
│           Docker Compose Network                     │
├──────────────┬──────────────┬──────────────┬─────────┤
│   Node.js    │  Prometheus  │   Grafana    │AlertMgr │
│   :3000      │    :9090     │    :3000     │  :9093  │
│  (app +      │ (scrape /    │ (dashboards) │(alertes)│
│   metrics)   │  metrics)    │              │         │
└──────────────┴──────────────┴──────────────┴─────────┘
```

## Étapes de réalisation

### 1. Lancer la stack
```bash
cd projects/2026-08-14_prometheus-grafana-monitoring
docker-compose up -d
```

### 2. Vérifier les services
- Application Node.js : http://localhost:3000
- Métriques brutes : http://localhost:3000/metrics
- Prometheus UI : http://localhost:9090
- Grafana : http://localhost:3000 (attention: conflit de port!)

**Note** : Grafana est configuré sur le port 3001 dans ce setup pour éviter le conflit.

### 3. Accéder à Grafana
- URL : http://localhost:3001
- Username : admin
- Password : admin (à changer en production!)

### 4. Importer le dashboard
1. Aller dans **Home > Dashboards > New > Import**
2. Coller l'ID du dashboard Grafana : `3662` (Node Exporter for Prometheus)
3. Sélectionner Prometheus comme data source
4. Cliquer sur Import

Ou importer le dashboard personnalisé fourni dans `grafana/dashboards/`

### 5. Générer du trafic sur l'app
```bash
# Générer des requêtes
for i in {1..100}; do curl http://localhost:3000/api/data; done

# Ou avec un script continu
./scripts/generate_traffic.sh
```

### 6. Observer les métriques
- Voir les graphs en temps réel dans Grafana
- Rechercher des métriques dans Prometheus (http://localhost:9090/graph)
- Vérifier les alertes si déclenchées

## Ce qu'on apprend

### Concepts Prometheus
- **Scraping** : comment Prometheus collecte les métriques
- **Types de métriques** : Counter, Gauge, Histogram, Summary
- **Labels** : tagging des métriques pour mieux les filtrer
- **Retention** : durée de stockage des données
- **Jobs et Targets** : configuration des sources à monitorer

### Concepts Grafana
- Créer et configurer des dashboards
- Types de visualisations (graphs, tables, gauges, heatmaps)
- Alertes et notifications
- Templating pour rendre les dashboards réutilisables
- Integration avec Prometheus comme data source

### DevOps Skills
- Infrastructure as Code avec Docker Compose
- Exposition de métriques dans une application
- Logs structurés et debugging
- Monitoring proactif vs réactif
- Mise en place d'alertes professionnelles

## Fichiers du projet

```
2026-08-14_prometheus-grafana-monitoring/
├── docker-compose.yml          # Orchestration des 4 services
├── prometheus/
│   ├── prometheus.yml          # Config du scraping
│   └── alerts.yml              # Règles d'alertes
├── grafana/
│   ├── provisioning/           # Datasources et dashboards auto-import
│   └── dashboards/
│       └── app-dashboard.json  # Dashboard personnalisé
├── alertmanager/
│   └── alertmanager.yml        # Config routing des alertes
├── app/
│   ├── server.js               # App Node.js avec prom-client
│   ├── package.json
│   └── Dockerfile
├── scripts/
│   └── generate_traffic.sh     # Script pour générer du trafic
└── README.md
```

## Commandes utiles

```bash
# Vérifier le statut des services
docker-compose ps

# Afficher les logs d'un service
docker-compose logs prometheus
docker-compose logs grafana
docker-compose logs app

# Arrêter tout
docker-compose down

# Redémarrer sans perdre les données
docker-compose restart

# Vérifier la config Prometheus
curl http://localhost:9090/api/v1/targets

# Requête PromQL simple
curl 'http://localhost:9090/api/v1/query?query=up'
```

## Exercices à faire après

1. **Créer une alerte** : modifier `prometheus/alerts.yml` pour créer une alerte si l'app est down
2. **Dashboard personnalisé** : créer un dashboard qui montre CPU, mémoire, requêtes/sec
3. **Email notifications** : configurer AlertManager pour envoyer des emails
4. **Exporter les données** : faire un export des métriques en CSV/JSON
5. **Multi-instances** : ajouter 2-3 instances de l'app et monitorer toutes

## Troubleshooting

**Grafana ne démarre pas** : vérifier que le port 3001 est libre
```bash
lsof -i :3001
```

**Prometheus ne scrape pas** : vérifier la config et les logs
```bash
curl http://localhost:9090/api/v1/targets
```

**Métriques vides** : attendre 1-2 minutes que Prometheus complète un scrape cycle

## Ressources supplémentaires
- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)
- [PromQL Query Language](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)

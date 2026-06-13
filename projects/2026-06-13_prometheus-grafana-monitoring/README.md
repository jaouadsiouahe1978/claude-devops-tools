# Prometheus + Grafana - Stack de Monitoring Complet

## 🎯 Objectif
Mettre en place une stack de monitoring professionnelle avec **Prometheus** (collecte de métriques) et **Grafana** (visualisation). Tu vas déployer des conteneurs Docker, configurer des scrapers, créer des dashboards et apprendre à monitorer une infrastructure réelle.

## 📋 Pré-requis
- Docker et Docker Compose installés
- Terminal/shell bash
- Minimum 2GB de RAM disponible
- Ports 9090 (Prometheus), 3000 (Grafana), 8000-8002 (applications test) disponibles

## 🛠 Technos utilisées
- **Prometheus** : time-series database + collecteur de métriques
- **Grafana** : dashboards et alertes
- **Docker & Docker Compose** : orchestration
- **Node Exporter** : métriques du système (CPU, RAM, disque)
- **Alertmanager** : gestion des alertes

## 📚 Ce qu'on apprend

### Concepts clés
1. **Scrape configs** : comment Prometheus collecte les métriques des cibles
2. **PromQL** : langage de requête pour interroger les métriques
3. **Recording rules** : pré-calculer les métriques complexes
4. **Alert rules** : définir des seuils d'alerte
5. **Grafana datasources** : intégrer Prometheus
6. **Dashboard JSON** : créer des visualisations réutilisables

### Compétences pratiques
- Configurer un système de monitoring multi-conteneurs
- Écrire des requêtes PromQL pour extraire du signal du bruit
- Créer des dashboards lisibles et utiles
- Tester les alertes en simul
- Personnaliser les seuils et les notifications

## 🚀 Étapes de réalisation

### 1. Lancer la stack
```bash
cd projects/2026-06-13_prometheus-grafana-monitoring
docker-compose up -d
```

### 2. Vérifier les services
```bash
docker ps  # Voir les conteneurs en cours
curl http://localhost:9090/api/v1/targets  # Voir les scrape targets
```

### 3. Accéder aux interfaces
- **Prometheus UI** : http://localhost:9090
- **Grafana** : http://localhost:3000 (admin / admin)
- **Node Exporter** : http://localhost:9100/metrics

### 4. Queries PromQL à tester dans Prometheus UI
```
node_cpu_seconds_total  # Temps CPU brut
rate(node_cpu_seconds_total[5m])  # Taux d'utilisation CPU
node_memory_MemAvailable_bytes / 1024 / 1024  # RAM disponible en MB
node_disk_io_reads_completed_total  # I/O disque
```

### 5. Créer un dashboard Grafana
- Aller dans Grafana → "+" → Dashboard
- Ajouter un panel → Prometheus datasource
- Utiliser les queries ci-dessus
- Configurer seuils et alertes visuelles

### 6. Tester les alertes
- Vérifier le fichier `prometheus/alert_rules.yml`
- Simuler une charge haute : `docker exec <container> stress --cpu 2 --timeout 60s`
- Voir les alertes déclencher dans Prometheus (Alerts tab)
- Vérifier les notifications dans Alertmanager

## 📂 Structure du projet
```
.
├── docker-compose.yml          # Orchestration des services
├── prometheus/
│   ├── prometheus.yml          # Config Prometheus (scrape targets)
│   ├── alert_rules.yml         # Règles d'alertes
│   └── recording_rules.yml     # Règles de pré-calcul
├── grafana/
│   ├── datasources.yml         # Connexion Prometheus
│   └── dashboards/
│       └── system-monitoring.json  # Dashboard système
└── docker-compose/
    └── docker-compose.yml       # Services auxiliaires (Node Exporter, etc)
```

## 🔍 Points clés à comprendre

1. **Scrape interval** : Tous les 15s, Prometheus va chercher les métriques
2. **Retention** : Prometheus garde 15 jours de données par défaut
3. **Alerting** : Une alerte déclenche si la condition est vraie pendant l'`for` duration
4. **Grafana variables** : ${__interval} permet des requêtes adaptées à la plage affichée

## ✅ Validation

- [ ] Stack démarrée sans erreur (`docker-compose logs`)
- [ ] Prometheus collecte des métriques (au moins 1 target up)
- [ ] Grafana accessible et configuré
- [ ] Au moins 1 dashboard créé et affichant des données
- [ ] Au moins 1 alerte testée (règle triggérée)
- [ ] Requêtes PromQL en tête

## 🎓 Next Steps
- Ajouter Loki pour les logs
- Intégrer AlertManager avec email/Slack
- Découvrir la service discovery (Docker labels, Kubernetes)
- Apprendre les PromQL avancées (join, group_by)

## 📚 Ressources
- PromQL docs: https://prometheus.io/docs/prometheus/latest/querying/basics/
- Grafana docs: https://grafana.com/docs/grafana/latest/
- Examples PromQL: https://prometheus.io/docs/prometheus/latest/querying/examples/

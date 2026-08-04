# Prometheus + Grafana - Monitoring Stack avec Docker Compose

## 🎯 Objectif
Mettre en place une stack de monitoring complète avec Prometheus (collecte de métriques) et Grafana (visualisation) en utilisant Docker Compose. Parfait pour débuter en observabilité et apprendre les bases du monitoring.

## 📚 Technos utilisées
- **Docker** : Conteneurisation
- **Docker Compose** : Orchestration multi-conteneurs
- **Prometheus** : Time-series database + scraping de métriques
- **Grafana** : Dashboard de visualisation
- **node_exporter** : Export des métriques système Linux
- **cAdvisor** : Monitoring des conteneurs Docker

## 📋 Pré-requis
- Docker >= 20.10
- Docker Compose >= 2.0
- Au moins 2 GB RAM disponibles

## 🚀 Étapes de réalisation

### 1. Démarrer la stack
```bash
cd projects/2026-08-04_prometheus-grafana-monitoring
docker-compose up -d
```

### 2. Vérifier les services
```bash
# Prometheus UI
http://localhost:9090

# Grafana
http://localhost:3000
# Login: admin / admin

# Node Exporter
http://localhost:9100/metrics

# cAdvisor
http://localhost:8080
```

### 3. Configurer Grafana
1. Ajouter une data source Prometheus : http://prometheus:9090
2. Importer le dashboard **1860** (Node Exporter for Prometheus) depuis Grafana Labs
3. Créer vos propres dashboards !

### 4. Inspecter les métriques
```bash
# Voir les métriques collectées par Prometheus
curl http://localhost:9090/api/v1/query?query=up

# Voir les labels
curl http://localhost:9090/api/v1/labels
```

## 📖 Ce qu'on apprend

### Concepts DevOps fondamentaux
- **Pull-based monitoring** : Prometheus scrape les endpoints `/metrics` vs push-based (Grafana Loki)
- **Time-series data** : Comment stocker et interroger les métriques temporelles
- **Cardinality** : L'importance des labels et leurs impacts sur la performance

### Pratique Docker
- Networking entre conteneurs : pas besoin de ports pour la communication interne
- Volumes : Persistance des données Prometheus et Grafana
- Health checks : Détection des services défaillants

### Observabilité
- Types de métriques : Counter, Gauge, Histogram, Summary
- PromQL : Language pour interroger Prometheus
- Alerting : Base pour configurer des alertes

## 🧪 Cas d'usage pratiques
- Monitorer la charge CPU/RAM d'une machine
- Visualiser l'utilisation disque en temps réel
- Détecter les pics de trafic sur des services
- Alerter sur la disponibilité des services (métrique `up`)

## 🛠️ Améliorations possibles (optionnel)
- Ajouter **AlertManager** pour les notifications
- Intégrer **Loki** pour les logs
- Créer un dashboard custom pour votre app
- Activer la persistance Grafana avec un volume nommé
- Ajouter des scrape configs pour des apps externes

## 🧹 Nettoyer
```bash
docker-compose down
# Supprimer aussi les volumes
docker-compose down -v
```

## 📝 Notes
- Prometheus scrape toutes les 15s par défaut (configurable dans prometheus.yml)
- Les métriques de Prometheus sont stockées pendant 15 jours par défaut
- Grafana expose sur le port 3000 (pas 80 pour éviter les conflits)
- node_exporter exporte ~400 métriques différentes !

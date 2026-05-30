# Docker Compose + Monitoring Stack (Prometheus + Grafana)

## Objectif
Créer une stack Docker Compose multi-conteneurs avec une application web, Prometheus pour la collecte de métriques et Grafana pour la visualisation. Ce projet montre les bonnes pratiques de monitoring en conteneurs.

## Technos utilisées
- **Docker & Docker Compose** : Orchestration multi-conteneurs
- **Prometheus** : Collecte de métriques (temps réel)
- **Grafana** : Visualisation et dashboards
- **Python/Flask** : Application web simple avec exposition de métriques
- **Node Exporter** : Collecte de métriques système
- **prometheus-client** : Instrumentation pour les métriques custom

## Structure du projet
```
.
├── README.md
├── docker-compose.yml          # Stack complète
├── app/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app.py                  # Flask + métriques Prometheus
├── prometheus/
│   └── prometheus.yml          # Configuration Prometheus
└── grafana/
    └── provisioning/
        └── dashboards/
            └── app-dashboard.json  # Dashboard Grafana pré-configuré
```

## Pré-requis
- Docker et Docker Compose installés (v20.10+)
- ~500MB d'espace disque libre
- Ports disponibles : 5000 (app), 9090 (Prometheus), 3000 (Grafana), 9100 (Node Exporter)

## Étapes de réalisation

### 1️⃣ Démarrer la stack
```bash
docker-compose up -d
```

### 2️⃣ Vérifier les services
```bash
docker-compose ps
# Tous les conteneurs doivent être "Up"
```

### 3️⃣ Accéder aux services
- **Application web** : http://localhost:5000
- **Prometheus** : http://localhost:9090
- **Grafana** : http://localhost:3000 (admin/admin)
- **Métriques app** : http://localhost:5000/metrics
- **Métriques système** : http://localhost:9100/metrics

### 4️⃣ Observer les métriques dans Prometheus
- Allez sur http://localhost:9090/graph
- Tapez une métrique : `http_requests_total`, `process_cpu_seconds_total`
- Cliquez "Execute" pour voir les données en temps réel

### 5️⃣ Configurer Grafana
1. Allez sur http://localhost:3000
2. Login: `admin` / `admin`
3. Add Data Source → Prometheus → URL: `http://prometheus:9090` → Save
4. Importez le dashboard ID `1860` (Node Exporter) pour voir les métriques système

### 6️⃣ Générer du trafic sur l'app
```bash
# Dans un terminal
while true; do
  curl http://localhost:5000
  sleep 1
done
```

## Ce qu'on apprend

✅ **Docker Compose** : Gérer plusieurs conteneurs interconnectés
✅ **Prometheus** : Récupérer et requêter des métriques au format Prometheus
✅ **Instrumentalisation** : Ajouter des métriques custom dans une app (Flask)
✅ **Grafana** : Visualiser des métriques et créer des dashboards
✅ **Monitoring en prod** : Architecture classique pour monitorer des services

## Commandes utiles

```bash
# Voir les logs
docker-compose logs -f app
docker-compose logs -f prometheus

# Arrêter la stack
docker-compose down

# Supprimer les volumes (données persistent)
docker-compose down -v

# Rebuild l'image de l'app
docker-compose build app
docker-compose up app -d
```

## Améliorations possibles
- Ajouter des alertes Alertmanager
- Configurer la rétention des données Prometheus
- Créer des dashboards custom Grafana
- Ajouter ELK Stack pour les logs centralisés
- Intégrer des health checks Docker

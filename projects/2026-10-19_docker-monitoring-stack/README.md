# Docker Monitoring Stack - Prometheus + Grafana

## 🎯 Objectif
Créer une stack de monitoring complet avec Docker Compose incluant :
- **Prometheus** : collecte et stockage des métriques
- **Grafana** : dashboards et visualisation
- **Node Exporter** : métriques du système
- **Application web simple** : pour générer des métriques

## 📋 Pré-requis
- Docker & Docker Compose (version 20.10+)
- Linux/Mac/WSL
- Port disponibles: 3000 (Grafana), 9090 (Prometheus), 8080 (app)

## 🏗️ Architecture
```
┌─────────────────────┐
│  Grafana (port 3000)│ ← Dashboards et alertes
├─────────────────────┤
│ Prometheus (9090)   │ ← Collecte métriques
├─────────────────────┤
│ Node Exporter       │ ← Métriques système
│ Sample App (8080)   │ ← App avec metrics /metrics
└─────────────────────┘
```

## 🚀 Étapes de réalisation

### 1. Démarrer la stack
```bash
docker-compose up -d
```

### 2. Vérifier les services
```bash
docker-compose ps
curl http://localhost:9090/api/v1/targets  # Vérifier targets Prometheus
curl http://localhost:8080                  # Tester l'app
```

### 3. Accéder aux interfaces
- **Grafana** : http://localhost:3000
  - Login: admin/admin
- **Prometheus** : http://localhost:9090
- **Application** : http://localhost:8080

### 4. Configurer le data source
1. Aller dans Grafana → Configuration → Data Sources
2. Ajouter Prometheus : http://prometheus:9090
3. Test la connexion

### 5. Créer un dashboard
1. Dashboard → New Dashboard
2. Add panel
3. Importer une requête PromQL : `http_requests_total` ou `node_memory_MemFree_bytes`

## 📚 Ce qu'on apprend

✅ **Docker Compose** : orchestration multi-conteneurs  
✅ **Prometheus** : scraping de métriques, requêtes PromQL  
✅ **Grafana** : dashboards, configuration, visualisations  
✅ **Exporters** : Node Exporter pour metrics système  
✅ **Networking** : communication inter-conteneurs  
✅ **Volumes** : persistance des données  
✅ **Health checks** : validation des services  

## 🔍 Explorations supplémentaires

- Ajouter des alertes Prometheus
- Créer des dashboards personnalisés
- Intégrer AlertManager
- Ajouter Loki pour les logs
- Implémenter une app Node.js avec prom-client

## 📁 Structure
```
.
├── docker-compose.yml       # Orchestration services
├── prometheus.yml            # Config Prometheus
├── grafana-datasource.yml    # Config datasource Grafana
├── app.py                    # Simple app Python avec metrics
└── Dockerfile                # Image app Python
```

## 🛠️ Commandes utiles

```bash
# Voir les logs
docker-compose logs -f prometheus
docker-compose logs -f grafana

# Interroger Prometheus
curl "http://localhost:9090/api/v1/query?query=up"

# Arrêter la stack
docker-compose down -v

# Cleanup complet (volumes inclus)
docker-compose down -v
```

## ⚠️ Notes importantes
- Les volumes persiste les données (Prometheus, Grafana)
- Password Grafana par défaut: admin/admin (à changer en prod)
- La config Prometheus scrape chaque 15 secondes
- Node Exporter expose ~1000 métriques système

---
**Durée estimée** : 45-60 min  
**Niveau** : Débutant-Intermédiaire  
**Technologies** : Docker, Docker Compose, Prometheus, Grafana, Python

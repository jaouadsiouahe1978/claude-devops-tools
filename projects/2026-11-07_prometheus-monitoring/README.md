# 📊 Monitoring Multi-Niveaux avec Prometheus, Grafana & Node Exporter

**Niveau:** Débutant à Intermédiaire  
**Durée estimée:** 1 journée  
**Technos:** Docker, Docker Compose, Prometheus, Grafana, Node Exporter, Linux Metrics

## 🎯 Objectif du Projet

Construire une **stack de monitoring complète** qui collecte les métriques système de Linux en temps réel et les affiche dans un dashboard Grafana intuitif. C'est la fondation de toute infrastructure DevOps professionnelle.

## 📚 Ce Qu'On Apprend

- **Docker Compose**: orchestration multi-conteneurs localement
- **Prometheus**: collecte et stockage des métriques (time-series DB)
- **Grafana**: visualisation et alerting sur les dashboards
- **Node Exporter**: exposition des métriques système Linux
- **Scraping & Targets**: comment Prometheus collecte les données
- **PromQL**: requêtes sur les métriques (CPU, mémoire, disque, réseau)
- **Persistance des données**: volumes Docker pour la durabilité
- **Réseaux Docker**: communication inter-conteneurs

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         Docker Network: monitoring      │
├─────────────────────────────────────────┤
│ Node Exporter (port 9100)               │
│ ↓ expose les métriques Linux            │
│                                         │
│ Prometheus (port 9090)                  │
│ ↓ scrape les métriques toutes les 15s   │
│ ↓ stockage en DB time-series            │
│                                         │
│ Grafana (port 3000)                     │
│ ↓ dashboard + alerting                  │
└─────────────────────────────────────────┘
```

## 🚀 Prérequis

- Docker & Docker Compose installés
- Port 3000, 9090, 9100 disponibles
- 500MB d'espace disque minimum

## 📋 Étapes de Réalisation

### 1. Démarrer la Stack
```bash
docker-compose up -d
```

### 2. Vérifier les Services
```bash
# Node Exporter accessible
curl http://localhost:9100/metrics | head

# Prometheus accessible
curl http://localhost:9090/api/v1/targets
```

### 3. Accéder à Grafana
- **URL:** http://localhost:3000
- **Identifiants:** admin / admin
- **Tâche:** Ajouter Prometheus comme datasource (http://prometheus:9090)

### 4. Importer un Dashboard Grafana
- Aller dans "Dashboards" → "Import"
- Utiliser l'ID: **1860** (Node Exporter Full)
- Sélectionner Prometheus comme datasource

### 5. Écrire des Requêtes PromQL
```promql
# CPU usage en pourcentage
100 * (1 - avg(irate(node_cpu_seconds_total{mode="idle"}[5m])))

# Mémoire disponible en GB
node_memory_MemAvailable_bytes / 1024 / 1024 / 1024

# Disque utilisé en %
(node_filesystem_size_bytes - node_filesystem_avail_bytes) / node_filesystem_size_bytes * 100
```

### 6. Configurer une Alerte Simple
- Dans Grafana, ajouter une alerte si CPU > 80%
- Tester en générant de la charge CPU

## 📊 Explorations Avancées

- **Ajouter cAdvisor:** monitorer les stats des conteneurs
- **Alertmanager:** routage et grouping des alertes
- **Node Exporter Textfile:** exporter des métriques custom
- **Reverse Proxy:** mettre Nginx devant Prometheus/Grafana
- **SSL/TLS:** sécuriser l'accès aux services

## 🧹 Cleanup

```bash
docker-compose down -v  # supprimer volumes aussi
```

## 📚 Ressources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Dashboards Library](https://grafana.com/grafana/dashboards/)
- [Node Exporter Metrics](https://github.com/prometheus/node_exporter)
- [PromQL Cheatsheet](https://promlabs.com/promql-cheat-sheet)

---

**Créé avec ❤️ pour la formation DevOps/SRE**

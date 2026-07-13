# 📊 DevOps Project du Jour - 13 juillet 2026

## Projet : Docker Compose Monitoring Stack

### 🎯 Objectif
Mettre en place une infrastructure de monitoring complète et reproductible avec **Prometheus**, **Grafana**, **Node Exporter** et **AlertManager** en utilisant Docker Compose.

### 🛠️ Technos principales
- **Prometheus** : Base de données time-series pour la collecte des métriques
- **Grafana** : Plateforme de visualisation et dashboarding
- **Node Exporter** : Exporteur de métriques système (CPU, RAM, Disk, Network)
- **AlertManager** : Gestion et routage des alertes
- **Docker Compose** : Orchestration et déploiement des conteneurs

### 📋 Contenu du projet

#### Structure
```
2026-07-13_docker-compose-monitoring-stack/
├── docker-compose.yml          # Orchéstration des 4 services
├── prometheus.yml              # Configuration Prometheus avec scrape jobs
├── alert-rules.yml             # Règles d'alerte (CPU, mémoire, disque, réseau)
├── alertmanager.yml            # Configuration AlertManager + routage
├── grafana-datasources.yml      # Provisioning datasources
├── grafana-dashboards.yml       # Provisioning dashboards
├── setup.sh                     # Script d'initialisation
├── Makefile                     # Commandes de gestion
└── README.md                    # Documentation complète
```

### 🚀 Points clés du projet

#### 1. **Prometheus Configuration**
- Scrape interval : 15 secondes
- 3 targets : Prometheus lui-même, Node Exporter, Docker metrics (optionnel)
- Retention : 30 jours
- Intégration AlertManager

#### 2. **Alerting Rules**
Règles d'alerte implémentées :
- **CPU** : Warning >80%, Critical >95%
- **Mémoire** : Warning >80%, Critical >95%
- **Disque** : Warning >80%, Critical >95%
- **Réseau** : Traffic élevé (>10MB/s)
- **Charge système** : Load >4
- **Prometheus** : Down ou scrape failures

#### 3. **Grafana Provisioning**
- Datasource Prometheus pré-configurée
- Support pour imports de dashboards Grafana
- Dossier `/dashboards` pour les JSON dashboards personnalisés

#### 4. **Health Checks**
Tous les services ont des health checks Docker configurés pour assurer la fiabilité de la stack.

#### 5. **Automatisation**
- `setup.sh` : Script one-liner pour démarrer et vérifier l'état
- `Makefile` : Commandes `make up`, `make down`, `make health`, `make logs`, etc.
- `.env` : Variables d'environnement centralisées

### 📚 Concepts DevOps appris

1. **Architecture Pull-based de Prometheus**
   - Comment Prometheus scrape les métriques (vs push)
   - Configuration des targets et intervals

2. **Métriques Prometheus**
   - Types : gauge, counter, histogram, summary
   - Requêtes PromQL pour extraire et agréger les métriques
   - Expressions avec `rate()`, `sum()`, `avg()`, etc.

3. **Alerting avancé**
   - Règles d'alerte avec conditions temporelles (`for: 2m`)
   - Labels et annotations
   - Inhibition des alertes pour éviter le bruit
   - Routage vers différents destinataires (Slack, Email, PagerDuty)

4. **Dashboarding**
   - Templating et variables dans Grafana
   - Création de panels (graphs, stat, gauge)
   - Imports de dashboards communautaires

5. **Docker Compose best practices**
   - Volumes persistants pour les données
   - Networks personnalisés
   - Health checks
   - Variables d'environnement et .env

### 🎓 Points d'apprentissage clés

#### Monitoring 101
- **Why** : Visibilité sur l'infrastructure
- **What** : Métriques clés à monitorer
- **How** : Architecture, scraping, alerting

#### PromQL Essentials
```promql
# CPU usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Network traffic
rate(node_network_transmit_bytes_total[5m]) + rate(node_network_receive_bytes_total[5m])
```

#### AlertManager Routing
- Grouping alerts par alertname, cluster, service
- Routes hiérarchiques avec différents receivers
- Inhibition rules pour supprimer les bruits

### 🔄 Workflow d'utilisation

```bash
# 1. Lancer la stack
cd projects/2026-07-13_docker-compose-monitoring-stack
./setup.sh
# ou
make up

# 2. Accéder aux interfaces
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)
# AlertManager: http://localhost:9093

# 3. Configurer Grafana
# - Ajouter Datasource Prometheus
# - Importer dashboard Node Exporter (ID: 1860)

# 4. Tester les alertes
# - Générer du load CPU
# - Observer les alertes dans AlertManager
# - Configurer notifications (Slack, Email, etc.)

# 5. Arrêter
make down
```

### 💡 Prochaines étapes possibles

1. **Ajouter d'autres exporteurs**
   - MySQL/PostgreSQL exporter pour les DB
   - Redis exporter pour le cache
   - Custom exporter pour l'app

2. **Enhancer Grafana**
   - Créer dashboards personnalisés
   - Ajouter des variables et templating
   - Organiser les dashboards par team/service

3. **Notifications réelles**
   - Configurer webhook Slack/Discord
   - Intégrer avec PagerDuty
   - Setup email SMTP

4. **High Availability**
   - Multiple Prometheus instances
   - Remote storage (Thanos, Cortex)
   - Highly available AlertManager

### 📊 Résultat attendu
Une **stack de monitoring production-ready** avec :
- ✅ Prometheus collectant les métriques en temps réel
- ✅ Grafana affichant les dashboards
- ✅ AlertManager routant les alertes
- ✅ Règles d'alerte déjà configurées
- ✅ Scripts d'automatisation
- ✅ Documentation complète

---

**Commit** : `902acd5` - Add 2026-07-13_docker-compose-monitoring-stack: Complete Monitoring Infrastructure

**Tags** : #Monitoring #Prometheus #Grafana #AlertManager #Docker #DevOps #Alerting #TimeSeries

**Niveau** : Débutant à Intermédiaire | **Durée** : 1 journée | **Difficulté** : ⭐⭐⭐

# 📊 Grafana + Alerting Stack with Prometheus

**Niveau** : Intermédiaire  
**Durée** : 1 jour  
**Date** : 2026-09-11

## 🎯 Objectif

Déployer une stack complète de monitoring et d'alerting :
- **Prometheus** pour la collecte des métriques
- **Grafana** pour la visualisation des données et les dashboards
- **AlertManager** pour la gestion des alertes
- Créer des dashboards custom Grafana
- Configurer des règles d'alerting réalistes
- Implémenter des notifications par email/Slack

## 🛠️ Technologies

- **Prometheus 2.x** - Time-series database
- **Grafana 9.x** - Visualization & dashboarding
- **AlertManager** - Alert routing & aggregation
- **Docker & Docker Compose** - Orchestration
- **Node Exporter** - System metrics
- **JSON/YAML** - Configuration

## 📋 Pré-requis

- Docker & Docker Compose installés
- Connaissances de base sur Prometheus (scrape configs)
- Port 3000, 9090, 9093 disponibles

## 🚀 Étapes de réalisation

### 1. Structure du projet
```
grafana-alerting-stack/
├── docker-compose.yml       # Stack complète
├── prometheus.yml           # Config Prometheus
├── alertmanager.yml         # Config AlertManager
├── alerts.yml               # Règles d'alerting
├── dashboards/
│   ├── system-overview.json      # Dashboard système
│   ├── docker-containers.json    # Dashboard Docker
│   └── application-health.json   # Dashboard app santé
└── scripts/
    ├── init-datasources.sh       # Setup datasources Grafana
    └── load-dashboards.sh        # Import dashboards
```

### 2. Déployer la stack
```bash
docker-compose up -d
```

### 3. Accéder aux services
- **Grafana** : http://localhost:3000 (admin/admin)
- **Prometheus** : http://localhost:9090
- **AlertManager** : http://localhost:9093

### 4. Configurer les datasources Grafana
- Ajouter Prometheus comme datasource
- Définir l'URL http://prometheus:9090

### 5. Créer les dashboards
- Dashboard système (CPU, RAM, Disque)
- Dashboard Docker (containers, images)
- Dashboard application (custom metrics)

### 6. Configurer AlertManager
- SMTP pour emails
- Webhook pour Slack
- Grouping des alertes

### 7. Tester les alertes
- Trigger des alertes en surchargeant le système
- Vérifier les notifications
- Vérifier l'historique dans AlertManager

## 📚 Ce qu'on apprend

✅ **Observabilité en production** :
- Comprendre la différence entre monitoring, logging et tracing
- Implémenter une stack observabilité complète

✅ **Grafana pro** :
- Créer des dashboards réutilisables et élégants
- Variables et templating pour la flexibilité
- Annotations et alertes dans les dashboards

✅ **Alerting avancé** :
- Écrire des règles Prometheus efficaces
- Configurer le routage d'alertes intelligemment
- Réduire les alertes "bruit" (tuning)

✅ **DevOps réel** :
- Stack production-ready avec Docker Compose
- Configuration as code (YAML)
- Notifications intégrées aux workflows

## 🔧 Commandes utiles

```bash
# Vérifier les alertes prometheus
curl http://localhost:9090/api/v1/alerts

# Voir les alertes triggées dans AlertManager
curl http://localhost:9093/api/v1/alerts

# Vérifier les logs
docker-compose logs -f grafana
docker-compose logs -f prometheus

# Arrêter la stack
docker-compose down -v

# Relancer une partie
docker-compose up -d prometheus
```

## 📈 Extensions possibles

- Ajouter **Loki** pour les logs
- Implémenter **Thanos** pour la haute disponibilité
- Configurer **RBAC** dans Grafana
- Ajouter des dashboards pour **Kubernetes**
- Intégrer avec **OpsGenie** ou **PagerDuty**

## 💡 Notes pédagogiques

Ce projet introduit le concept d'**observabilité moderne**. Contrairement au monitoring basique qui surveille juste si un service est up/down, une stack d'observabilité complète capture :
- **Metrics** (Prometheus) - l'état du système
- **Logs** (Loki/ELK) - les événements détaillés  
- **Traces** (Jaeger) - le flux d'exécution

Grafana et AlertManager sont les outils de **réaction** - ils permettent de visualiser et d'alerter sur les problèmes détectés.

## 🎓 Cas d'usage réels

- **SRE** : Monitoring de services critiques
- **Platform Teams** : Observabilité centralisée
- **Startups** : Stack monitoring économique vs. solutions SaaS

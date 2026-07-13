# 📊 Docker Compose Monitoring Stack

## Objectif
Mettre en place une stack de monitoring complète avec **Prometheus**, **Grafana**, **Node Exporter** et **AlertManager** en utilisant Docker Compose. Apprendre à monitorer l'infrastructure en temps réel et configurer des alertes.

## 📋 Pré-requis
- Docker et Docker Compose installés
- Connaissances basiques de Docker
- Port disponibles : 9090 (Prometheus), 3000 (Grafana), 9100 (Node Exporter), 9093 (AlertManager)

## 🛠️ Technos utilisées
- **Prometheus** : Collecte des métriques de l'infrastructure
- **Grafana** : Visualisation des métriques en dashboards
- **Node Exporter** : Exporteur de métriques système (CPU, RAM, Disk, Network)
- **AlertManager** : Gestion et routage des alertes
- **Docker Compose** : Orchestration des conteneurs

## 📝 Étapes de réalisation

### 1. Lancer la stack
```bash
cd projects/2026-07-13_docker-compose-monitoring-stack
docker-compose up -d
```

### 2. Vérifier que les services sont running
```bash
docker-compose ps
```

### 3. Accéder aux interfaces web
- **Prometheus** : http://localhost:9090
- **Grafana** : http://localhost:3000 (admin/admin)
- **AlertManager** : http://localhost:9093

### 4. Configurer Grafana
1. Se connecter avec `admin/admin`
2. Ajouter Prometheus comme Data Source
3. Importer le dashboard Node Exporter (ID: 1860)
4. Créer ses propres dashboards personnalisés

### 5. Tester les alertes
```bash
# Générer du load CPU pour déclencher une alerte
docker exec -it monitoring-stack_node-exporter_1 stress --cpu 1 --timeout 60s
```

### 6. Arrêter la stack
```bash
docker-compose down
```

## 📚 Ce qu'on apprend

### Monitoring avec Prometheus
- Architecture pull-based (Prometheus scrape les métriques)
- Format des métriques Prometheus (types: gauge, counter, histogram, summary)
- Configuration des scrape targets et intervals
- Expressions PromQL (Prometheus Query Language)

### Visualisation avec Grafana
- Création de dashboards et panels
- Templating et variables dans les dashboards
- Alertes dans Grafana basées sur les métriques

### Alerting
- Configuration d'AlertManager
- Règles d'alerte (alert rules) dans Prometheus
- Notifications et webhooks d'alertes
- Routage des alertes

### Exporteurs de métriques
- Node Exporter pour les métriques système
- Architecture du scraping automatique
- Métriques clés : CPU, mémoire, disque, réseau

### Best practices DevOps
- Stack de monitoring modulaire et reproductible
- Configuration en tant que code (docker-compose.yml)
- Isolation des services avec Docker
- Volumes persistants pour Prometheus et Grafana

## 🎯 Résultat attendu

À la fin, vous aurez :
- ✅ Une stack de monitoring fonctionnelle et dockerisée
- ✅ Prometheus collectant les métriques du système
- ✅ Grafana affichant les métriques en temps réel
- ✅ Des alertes configurées et testées
- ✅ Une compréhension complète du monitoring DevOps

## 📖 Ressources supplémentaires
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Dashboard Library](https://grafana.com/grafana/dashboards)
- [Node Exporter Metrics](https://github.com/prometheus/node_exporter)
- [AlertManager Configuration](https://prometheus.io/docs/alerting/latest/configuration/)

---
**Niveau** : Débutant à Intermédiaire | **Durée estimée** : 1 journée | **Tags** : #Monitoring #Prometheus #Grafana #DevOps

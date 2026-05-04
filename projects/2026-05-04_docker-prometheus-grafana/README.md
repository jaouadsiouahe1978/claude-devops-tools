# 🚀 Docker Compose - Stack de Monitoring (Prometheus + Grafana)

## 📌 Objectif
Créer une infrastructure complète de **monitoring en conteneurs** avec Prometheus et Grafana, permettant de :
- Collecter les métriques du système (CPU, mémoire, disque)
- Visualiser les données en temps réel via Grafana
- Configurer des alertes simples
- Comprendre l'architecture d'une stack monitoring

## 🛠 Technos Utilisées
- **Docker** : Containerisation
- **Docker Compose** : Orchestration locale
- **Prometheus** : Collecte et stockage des métriques
- **Grafana** : Visualisation des données
- **cAdvisor** : Métriques des conteneurs

## ⏱️ Durée
1 journée (2-3h pour débutant, 1h pour intermédiaire)

## 📋 Prérequis
- Docker (>= 20.10)
- Docker Compose (>= 1.29)
- Port 3000 (Grafana) et 9090 (Prometheus) disponibles
- Minimum 2GB RAM libre

## 🎯 Étapes de Réalisation

### 1. Lancer la stack
```bash
docker-compose up -d
```

**Vérifier que tout est ok :**
```bash
docker-compose ps
```

### 2. Accéder à Prometheus
- **URL** : http://localhost:9090
- Vérifier les "Targets" en bon état
- Tester une requête PromQL : `up` ou `node_memory_MemAvailable_bytes`

### 3. Accéder à Grafana
- **URL** : http://localhost:3000
- **Identifiants** : admin / admin
- Suivre le setup wizard
- Ajouter Prometheus comme datasource :
  - URL : `http://prometheus:9090`
  - Save & test

### 4. Importer un Dashboard
- Aller sur "+" → "Import"
- Entrer l'ID du dashboard: `1860` (Node Exporter Full)
- Sélectionner Prometheus comme datasource
- Importer et visualiser les données

### 5. Créer une alerte simple (optionnel)
- Dans Grafana, configurer une alerte sur un graph
- Exemple : "Alerter si CPU > 80%"

## 📚 Ce qu'on Apprend

✅ **Docker Compose**
- Configuration YAML
- Réseaux entre conteneurs
- Volumes persistants
- Variables d'environnement

✅ **Prometheus**
- Scrape configuration
- Métriques en format texte
- Requêtes PromQL basiques
- Stockage TSDB

✅ **Grafana**
- DataSources
- Dashboards et Panels
- Visualisations (graphiques, jauges)
- Alertes basiques

✅ **Monitoring DevOps**
- Collecte de métriques
- Observabilité
- Architecture distribuée
- Best practices

## 📂 Structure du Projet
```
2026-05-04_docker-prometheus-grafana/
├── docker-compose.yml          # Configuration de la stack
├── prometheus/
│   └── prometheus.yml          # Config de scrape Prometheus
├── scripts/
│   └── start.sh               # Script de démarrage
└── README.md                  # Ce fichier
```

## 🔍 Fichiers Clés à Comprendre

### docker-compose.yml
Définit 3 services :
- **prometheus** : Scrape les métriques toutes les 15s
- **grafana** : Interface de visualisation
- **cadvisor** : Collecte les métriques des conteneurs

### prometheus/prometheus.yml
Configure les cibles ("targets") à scraper :
- `prometheus:9090` : Prometheus lui-même
- `cadvisor:8080` : Métriques des conteneurs

## 🚀 Commandes Utiles

| Commande | Action |
|----------|--------|
| `docker-compose up -d` | Lancer la stack |
| `docker-compose down` | Arrêter et supprimer |
| `docker-compose logs -f prometheus` | Logs Prometheus |
| `docker-compose exec prometheus cat /etc/prometheus/prometheus.yml` | Voir config |
| `curl http://localhost:9090/api/v1/targets` | API Prometheus (JSON) |

## 🐛 Troubleshooting

**Grafana ne démarre pas ?**
```bash
docker-compose logs grafana
# Vérifier les droits du volume si besoin
```

**Prometheus ne trouve pas les targets ?**
```bash
curl http://localhost:9090/api/v1/targets
# Chercher "Down" comme status
```

**Port déjà utilisé ?**
```bash
# Changer les ports dans docker-compose.yml
# Ex: "3001:3000" à la place de "3000:3000"
```

## 💡 Défis Bonus

1. **Ajouter Node Exporter** : Scraper les métriques du host
2. **Persister les données** : Ajouter un volume pour Prometheus
3. **Créer une alerte** : Notifier si un conteneur s'arrête
4. **Authentification** : Ajouter htpasswd sur Prometheus
5. **Docker Swarm** : Déployer sur 2 nœuds

## 📖 Ressources

- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/grafana/latest/)
- [cAdvisor](https://github.com/google/cadvisor)
- [PromQL Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)

## 🎓 Notes Pédagogiques

Ce projet couvre les fondamentaux du monitoring DevOps :
- **Instrumentation** : Exporter les métriques
- **Collecte** : Prometheus scrape
- **Stockage** : TSDB (Time Series Database)
- **Visualisation** : Grafana dashboards
- **Alerting** : Notifications

C'est la base pour comprendre des stacks plus complexes comme ELK, DataDog, ou Prometheus en production (Kubernetes).

---

**Author** : DevOps Training Program  
**Date** : 2026-05-04  
**Level** : Débutant → Intermédiaire

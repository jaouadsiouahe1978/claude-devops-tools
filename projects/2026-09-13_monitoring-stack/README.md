# 📊 Docker Monitoring Stack - Prometheus + Grafana

**Niveau :** Débutant-Intermédiaire  
**Durée :** 1 journée  
**Date :** 2026-09-13

## 🎯 Objectif

Créer un stack complet de monitoring avec **Prometheus** (collecte de métriques) et **Grafana** (visualisation) pour surveiller une application en temps réel.

### Ce qu'on apprend :
- ✅ Comprendre les métriques et la collecte de données
- ✅ Configurer Prometheus pour scraper des endpoints
- ✅ Visualiser les données avec des dashboards Grafana
- ✅ Orchestrer plusieurs services avec Docker Compose
- ✅ Exposer des métriques depuis une application
- ✅ Configurer les alertes basiques

---

## 🛠️ Technos utilisées

| Tech | Version | Rôle |
|------|---------|------|
| **Docker** | Latest | Containerization |
| **Docker Compose** | Latest | Orchestration |
| **Prometheus** | 2.45+ | Time-series DB & collecteur de métriques |
| **Grafana** | 10.0+ | Visualisation & dashboards |
| **Node.js** | 18+ | Application exposant des métriques |

---

## 📋 Prérequis

```bash
# Vérifier les installations
docker --version
docker-compose --version
```

- ✅ Docker installé et lancé
- ✅ Docker Compose
- ✅ ~10 min de temps

---

## 🚀 Étapes de réalisation

### 1. Démarrer le stack
```bash
cd projects/2026-09-13_monitoring-stack
docker-compose up -d
```

### 2. Vérifier les services
```bash
docker-compose ps
# Devrait afficher 3 conteneurs : prometheus, grafana, app
```

### 3. Accéder à Prometheus (UI d'exploration)
```
http://localhost:9090
```
- Chercher : `app_requests_total` dans la barre de recherche
- Cliquer "Graph" pour voir les métriques en temps réel

### 4. Accéder à Grafana (Dashboards)
```
http://localhost:3000
Login : admin / admin
```

**Créer le premier dashboard :**
1. Menu → Dashboards → New → New Dashboard
2. "Add new panel"
3. Sélectionner Prometheus comme data source
4. Entrer une requête PromQL : `app_requests_total`
5. Sauvegarder

### 5. Générer du trafic
```bash
# Terminal 2 - générer des requêtes vers l'app
while true; do
  curl -s http://localhost:8080/api/data | jq .
  sleep 2
done
```

### 6. Observer les métriques
- Retourner à Grafana
- Le graphique se met à jour en temps réel ! 📈

### 7. Arrêter le stack
```bash
docker-compose down
```

---

## 📁 Structure du projet

```
2026-09-13_monitoring-stack/
├── README.md                 # Ce fichier
├── docker-compose.yml        # Configuration des services
├── prometheus.yml            # Config Prometheus (scraping)
├── grafana/
│   └── provisioning/
│       └── dashboards/       # Dashboards pré-configurés
├── app.js                    # App Node.js avec métriques
└── package.json              # Dépendances Node
```

---

## 🔑 Concepts clés

### Prometheus
- **Time-series database** : Stocke les données de métriques
- **Scraping** : Récupère les données via HTTP sur des endpoints
- **PromQL** : Langage pour explorer les métriques
- **Retention** : Garde les données 15 jours par défaut

### Grafana
- **Datasource** : Connecte Prometheus ou autre DB
- **Panels** : Graphique, jauge, table, etc.
- **Dashboard** : Ensemble de panels organisés
- **Alertes** : Notifications quand les seuils sont atteints

### Métriques courants
```
# Counter (augmente seulement)
app_requests_total{method="GET"} 42

# Gauge (peut augmenter/diminuer)
app_memory_bytes 1024000

# Histogram (distribution)
app_response_time_seconds_bucket{le="0.5"} 100

# Summary
app_response_time_seconds_sum 5000
```

---

## 🎓 Apprentissage progressif

### Phase 1 : Démarrer et explorer (10 min)
- Lancer le stack
- Aller sur Prometheus
- Consulter les métriques disponibles

### Phase 2 : Créer des dashboards (20 min)
- Ajouter Prometheus comme data source dans Grafana
- Créer 2-3 panels simples
- Configurer les intervalles de rafraîchissement

### Phase 3 : Générer du trafic et observer (15 min)
- Lancer des requêtes vers l'app
- Voir les métriques augmenter
- Comprendre le cycle complet

### Phase 4 : Approfondir (optionnel)
- Ajouter plus de métriques dans l'app
- Créer des dashboards plus complexes
- Tester les alertes Prometheus

---

## 🐛 Dépannage

### Port déjà utilisé ?
```bash
docker-compose down -v
# Essayer avec des ports différents dans docker-compose.yml
```

### Grafana pas de datasource ?
Aller dans : Settings → Data Sources → Add Prometheus  
URL : `http://prometheus:9090`

### Pas de métriques ?
1. Vérifier que l'app est lancée : `docker-compose logs app`
2. Test l'endpoint : `curl http://localhost:8080/metrics`

---

## 💡 Extensions possibles

- **Alertes** : Configurer AlertManager
- **Exporters** : Ajouter des exporters (node-exporter, postgres-exporter)
- **Logs** : Intégrer Loki + Promtail
- **Tracing** : Ajouter Jaeger
- **HA** : Plusieurs instances Prometheus en high-availability

---

## 📚 Ressources

- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)
- [PromQL Tutorial](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)

---

## 🎉 Résultat attendu

À la fin de ce projet, tu auras :
- ✅ Un stack de monitoring avec 3 services lancés
- ✅ Une application exposant ses métriques
- ✅ Prometheus scrappant ces métriques
- ✅ Grafana affichant un dashboard en temps réel
- ✅ Une meilleure compréhension du monitoring en production

**Bravo ! 🚀**

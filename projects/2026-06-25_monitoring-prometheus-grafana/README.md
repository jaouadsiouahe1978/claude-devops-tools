# Monitoring & Alerting avec Prometheus et Grafana

## 📋 Description

Mise en place d'une stack de monitoring complète avec Prometheus (collecte des métriques), Node Exporter (métriques système), et Grafana (visualisation). Ce projet simule un environnement de production où on monitore plusieurs services et on crée des tableaux de bord.

## 🎯 Objectifs

- Comprendre la collecte de métriques avec Prometheus
- Configurer des exporters pour exposer les métriques
- Créer des dashboards Grafana intéractifs
- Configurer des alertes basiques
- Apprendre à requêter les métriques avec PromQL

## 🛠️ Technos Utilisées

- **Prometheus** : engine de collecte et stockage des métriques
- **Node Exporter** : exporte les métriques système (CPU, mémoire, disque, réseau)
- **Grafana** : plateforme de visualisation et création de dashboards
- **Docker & Docker Compose** : orchestration des services
- **PromQL** : langage de requête pour les métriques

## 📦 Pré-requis

- Docker & Docker Compose installés
- Port 9090 (Prometheus), 3000 (Grafana), 9100 (Node Exporter) disponibles
- ~2 Go de RAM minimum

## 🚀 Étapes de Réalisation

### 1️⃣ Démarrer l'infrastructure (5 min)

```bash
cd projects/2026-06-25_monitoring-prometheus-grafana
docker-compose up -d
```

Vérifier les services :
- Prometheus : http://localhost:9090
- Grafana : http://localhost:3000 (user: admin, pass: admin)
- Node Exporter : http://localhost:9100/metrics

### 2️⃣ Explorer Prometheus (10 min)

1. Aller sur http://localhost:9090
2. **Status** → **Targets** : voir les exporters connectés
3. Dans **Graph**, tester quelques requêtes :
   - `up` : état des cibles (1 = up, 0 = down)
   - `node_cpu_seconds_total` : temps CPU total
   - `node_memory_MemAvailable_bytes` : mémoire disponible
   - `node_disk_read_bytes_total` : octets lus du disque

### 3️⃣ Configurer Grafana (15 min)

1. Accès à http://localhost:3000 (admin/admin)
2. Changer le mot de passe d'admin
3. **Configuration** → **Data Sources** → **Add Prometheus**
   - URL: `http://prometheus:9090`
   - Save & Test
4. **Create** → **Dashboard** → **New Panel**
5. Créer 3 panneaux :
   - **CPU Usage** : `100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)`
   - **Memory Usage** : `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100`
   - **Disk Usage** : `(1 - node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100`

### 4️⃣ Ajouter des alertes (10 min)

1. Éditer `prometheus/prometheus.yml`
2. Décommenter la section `alert_rules` pour charger les règles d'alerte
3. Relancer Prometheus : `docker-compose restart prometheus`
4. Aller dans Prometheus **Alerts** pour voir les règles activées

### 5️⃣ Tester le monitoring (10 min)

Générer de la charge pour voir les métriques bouger :

```bash
# Charger le CPU
docker exec <node-exporter-container> stress-ng --cpu 1 --timeout 30s &

# Ou générer du trafic réseau
docker run --rm -it nicolaka/netshoot:latest iperf3 -c <host> -R -t 30 &
```

Voir les métriques se mettre à jour en temps réel sur Grafana.

## 📚 Ce qu'on Apprend

✅ **Monitoring** : comment collecte-t-on des métriques dans la vraie vie ?
✅ **PromQL** : requêter des séries temporelles, calculs, agrégations
✅ **Dashboarding** : visualiser l'état d'une infrastructure
✅ **Alertes** : détecter les problèmes avant qu'ils ne deviennent critiques
✅ **Docker Compose** : orchestrer plusieurs services avec des networks et volumes
✅ **Architecture observabilité** : pierre angulaire du SRE/DevOps

## 🔧 Structure du Projet

```
2026-06-25_monitoring-prometheus-grafana/
├── docker-compose.yml          # Orchestration des services
├── prometheus/
│   ├── prometheus.yml          # Configuration Prometheus
│   └── alert-rules.yml         # Règles d'alerte
├── node-exporter/              # Exporte les métriques système
├── grafana/
│   ├── provisioning/           # Auto-provision datasources & dashboards
│   └── dashboards/             # Dashboards pré-configurés
└── README.md                   # Ce fichier
```

## 💡 Points Clés à Retenir

- **Métriques** = données numériques avec timestamps et labels (ex: `cpu{host="server1"}`)
- **Exporters** = programmes qui exposent les métriques au format Prometheus
- **Scraping** = Prometheus va périodiquement interroger les exporters
- **PromQL** = langage puissant pour requêter et transformer les métriques
- **Alertes** = basées sur des seuils PromQL, peuvent déclencher des actions (Slack, PagerDuty, etc.)

## 🎓 Défi Bonus

- Ajouter un deuxième Node Exporter dans Docker Compose
- Créer une alerte qui déclenche si l'usage CPU > 50% pendant 5 min
- Créer un dashboard montrant les deux hosts côte à côte
- Exporter le dashboard en JSON et le versionner dans Git

## 📖 Ressources

- [Prometheus Docs](https://prometheus.io/docs/)
- [PromQL Tutorial](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Dashboards Library](https://grafana.com/grafana/dashboards/)
- [Node Exporter Metrics](https://github.com/prometheus/node_exporter)

---

**Created**: 2026-06-25 | **Level**: Débutant → Intermédiaire | **Duration**: ~1 jour

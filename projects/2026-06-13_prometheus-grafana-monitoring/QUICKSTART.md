# 🚀 Quickstart - Prometheus + Grafana

## 1️⃣ Lancer la stack (2 min)

```bash
cd projects/2026-06-13_prometheus-grafana-monitoring
./start.sh
```

Cela va:
- ✅ Démarrer Prometheus, Grafana, Node Exporter, AlertManager
- ✅ Vérifier que tous les services sont UP
- ✅ Afficher les URLs d'accès

## 2️⃣ Accéder aux interfaces

| Composant | URL | Identifiants |
|-----------|-----|-------------|
| **Prometheus** | http://localhost:9090 | Aucun |
| **Grafana** | http://localhost:3000 | admin / admin |
| **AlertManager** | http://localhost:9093 | Aucun |
| **Node Exporter** | http://localhost:9100/metrics | Aucun (raw metrics) |

## 3️⃣ Explorer les métriques (Prometheus)

**Allez sur: http://localhost:9090**

### Afficher les targets scrape
- Tab "Status" → "Targets"
- Vous devez voir: prometheus, node, grafana, alertmanager (tous UP)

### Exécuter des queries PromQL
- Tab "Graph"
- Entrez une query et cliquez "Execute"

**Queries à tester:**

```promql
# CPU usage %
100 * (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) by (instance))

# Memory available MB
node_memory_MemAvailable_bytes / 1024 / 1024

# Disk usage %
(1 - (node_filesystem_avail_bytes{fstype=~"ext4|xfs"} / node_filesystem_size_bytes)) * 100

# Load average
node_load1
```

## 4️⃣ Créer un dashboard Grafana

**Allez sur: http://localhost:3000**

### Login
- Username: `admin`
- Password: `admin`
- (Vous pouvez changer le password après)

### Voir le dashboard "System Monitoring"
- Menu gauche → Dashboards
- Cliquez sur "System Monitoring"
- Il affiche déjà: CPU, Memory, Disk, Load, Network, I/O

### Créer un nouveau dashboard (optionnel)
1. "+" en haut → "Dashboard"
2. "Add new panel"
3. Choisissez Prometheus datasource
4. Entrez une query PromQL
5. Configurez titre, seuils (thresholds)
6. Save

## 5️⃣ Tester les alertes

**Vérifiez les règles Prometheus:**
- http://localhost:9090
- Tab "Alerts"
- Vous voyez les règles d'alerte (certaines peuvent être en state: pending)

**Simuler une charge CPU** (pour déclencher l'alerte HighCPUUsage):

```bash
# Trouver le container node-exporter
docker ps | grep node-exporter

# Charger le CPU (remplace CONTAINER_ID)
docker exec <CONTAINER_ID> stress --cpu 2 --timeout 60s

# Monitorer dans Prometheus
# Tab "Alerts" → voir HighCPUUsage devenir "Firing"
```

**Observer dans AlertManager:**
- http://localhost:9093
- Vous verrez l'alerte "Firing" listée

## 6️⃣ Arrêter la stack

```bash
docker-compose down
```

Cela arrête et remove les conteneurs (les volumes de données persistent).

Pour nettoyer complètement:
```bash
docker-compose down -v
```

## 📚 Prochaines étapes

1. **Modifier les seuils d'alerte**
   - Edit: `prometheus/alert_rules.yml`
   - Redémarrez: `docker-compose restart prometheus`

2. **Ajouter d'autres cibles à scraper**
   - Modifiez: `prometheus/prometheus.yml`
   - Ajoutez un job dans `scrape_configs:`
   - Reload: `curl -X POST http://localhost:9090/-/reload`

3. **Créer des alertes Grafana**
   - Allez dans un panel → "Alert"
   - Configurez une condition et une notification

4. **Configurer les notifications** (Email, Slack, etc.)
   - Modifiez: `prometheus/alertmanager.yml`
   - Démarrez: `docker-compose restart alertmanager`

## 🐛 Troubleshooting

### Prometheus ne démarre pas
```bash
docker-compose logs prometheus
# Vérifiez la config: prometheus/prometheus.yml
# Sintaxe: docker run -it prom/prometheus promtool check config /etc/prometheus/prometheus.yml
```

### Grafana ne voit pas Prometheus
1. Allez sur: http://localhost:3000/connections/datasources
2. Cliquez sur "Prometheus"
3. Vérifiez l'URL: `http://prometheus:9090` (pas localhost!)
4. Save

### Node Exporter n'a pas de métriques
```bash
docker-compose logs node-exporter
curl http://localhost:9100/metrics | head -20
```

## 📊 Fichiers clés

```
.
├── docker-compose.yml           # Services
├── prometheus/
│   ├── prometheus.yml           # Config scrape
│   ├── alert_rules.yml          # Règles d'alerte
│   ├── recording_rules.yml      # Pré-calcul
│   └── alertmanager.yml         # Routage alertes
├── grafana/provisioning/
│   ├── datasources/prometheus.yml
│   └── dashboards/system-monitoring.json
├── start.sh                     # Démarrage + vérifications
├── test-alerts.sh               # Test des queries
└── PROMQL_CHEATSHEET.md         # Queries de référence
```

## 💡 Tips & Tricks

- **Modifier config sans redémarrer**: Utilisez `-/reload` sur Prometheus
- **Exporter un dashboard**: Grafana → Dashboard settings → JSON export
- **Sauvegarder les data**: Volumes sont dans `prometheus-data/` et `grafana-data/`
- **Ajouter des sources de données**: Grafana → Data sources → Add new
- **Debugging PromQL**: Utilisez "Expr debug" dans Prometheus Web UI

## 🎓 Pour aller plus loin

- Loki pour les logs
- Thanos pour la rétention long-terme
- Prometheus Operator pour Kubernetes
- Custom exporters pour vos apps
- Grafana Loki pour les logs en Grafana

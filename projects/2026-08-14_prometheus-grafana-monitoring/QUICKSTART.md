# Quick Start - Prometheus + Grafana Monitoring

## 🚀 Démarrer en 5 minutes

### 1. Lancer la stack
```bash
docker-compose up -d
```

### 2. Vérifier que tout est up
```bash
docker-compose ps
```

Vous devriez voir 4 services en state "running":
- prometheus
- grafana
- app
- alertmanager

### 3. Accéder aux interfaces

| Service | URL | Identifiant |
|---------|-----|-------------|
| Application | http://localhost:3000 | - |
| Prometheus UI | http://localhost:9090 | - |
| Grafana | http://localhost:3001 | admin / admin |
| AlertManager | http://localhost:9093 | - |

### 4. Générer du trafic
```bash
# Option 1: Générer 100 requêtes
for i in {1..100}; do curl -s http://localhost:3000/api/data > /dev/null; done

# Option 2: Script continu (5 minutes)
chmod +x scripts/generate_traffic.sh
./scripts/generate_traffic.sh

# Option 3: Avec Apache Bench
ab -n 1000 -c 10 http://localhost:3000/api/data
```

### 5. Observer les données

**Dans Prometheus** (http://localhost:9090):
- Aller dans "Graph"
- Chercher: `rate(http_requests_total[5m])`
- Voir la courbe des requêtes/sec

**Dans Grafana** (http://localhost:3001):
- Le dashboard "Application Monitoring" devrait être visible
- Sinon: Home > Dashboards > Application Monitoring
- Voir les 4 panneaux: taux, latence, requêtes, distribution

## 🔧 Commandes utiles

```bash
# Logs de l'app
docker-compose logs -f app

# Logs de Prometheus
docker-compose logs prometheus

# Logs de Grafana
docker-compose logs grafana

# Redémarrer un service
docker-compose restart prometheus

# Arrêter tout
docker-compose down

# Arrêter et supprimer les volumes (reset total)
docker-compose down -v
```

## 📊 Requêtes PromQL à essayer

Dans Prometheus > Graph, copier-coller:

```promql
# Taux de requêtes
rate(http_requests_total[5m])

# Latence (p95)
histogram_quantile(0.95, http_request_duration_seconds_bucket)

# Taux d'erreur
rate(http_requests_total{status=~"5.."}[5m])

# Connexions actives
active_connections

# Temps depuis dernier scrape
time() - timestamp(up)
```

## 📈 Créer un nouveau panel dans Grafana

1. Aller au dashboard "Application Monitoring"
2. Cliquer sur "Edit" (coin supérieur droit)
3. Cliquer sur "Add panel"
4. Dans la section Prometheus, écrire une requête PromQL
5. Exemple: `sum(rate(http_requests_total[1m]))`
6. Cliquer "Apply"
7. Sauvegarder le dashboard

## 🚨 Tester une alerte

1. Arrêter l'application: `docker-compose stop app`
2. Attendre 1 minute
3. Aller dans Prometheus > Alerts
4. Voir l'alerte "AppDown" en rouge
5. Relancer: `docker-compose start app`
6. L'alerte disparaît après 1 min

## 🎯 Exercices

- [ ] Créer une alerte si la latence p95 > 1 seconde
- [ ] Créer un nouveau dashboard "Performance Overview"
- [ ] Ajouter une 2e instance de l'app et monitorer les deux
- [ ] Configurer les notifications Slack (éditer alertmanager.yml)
- [ ] Augmenter la rétention Prometheus à 7 jours

## 📚 En savoir plus

- [Prometheus Query Language](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Dashboard Guide](https://grafana.com/docs/grafana/latest/dashboards/)
- [Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)

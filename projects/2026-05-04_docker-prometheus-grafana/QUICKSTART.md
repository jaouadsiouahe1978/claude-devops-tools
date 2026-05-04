# ⚡ Quickstart

## Démarrer en 1 minute

```bash
# 1. Aller dans le dossier du projet
cd projects/2026-05-04_docker-prometheus-grafana

# 2. Lancer la stack
docker-compose up -d

# 3. Attendre 30 secondes que les services démarrent

# 4. Accéder aux services
# - Prometheus: http://localhost:9090
# - Grafana: http://localhost:3000 (admin/admin)
```

## Vérifier que tout fonctionne

```bash
# Status des conteneurs
docker-compose ps

# Logs Prometheus
docker-compose logs prometheus

# Test Prometheus
curl http://localhost:9090/api/v1/targets
```

## Première métrique dans Grafana

1. Ouvrir http://localhost:3000
2. Se connecter : admin / admin
3. Ajouter Prometheus comme DataSource
   - URL: `http://prometheus:9090`
   - Cliquer "Save & test"
4. Aller sur "+" > "Dashboard" > "New Panel"
5. Tester cette requête PromQL :
   ```
   up{job="cadvisor"}
   ```

## Arrêter la stack

```bash
docker-compose down
```

---

📖 Pour plus de détails, voir [README.md](README.md)

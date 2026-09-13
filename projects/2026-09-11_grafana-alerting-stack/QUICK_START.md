# ⚡ Quick Start

## 2-Minute Startup

```bash
docker-compose up -d && sleep 20 && echo "✅ Done! Open http://localhost:3000"
```

## Access Services

| Service | URL | Login |
|---------|-----|-------|
| Grafana | http://localhost:3000 | admin/admin |
| Prometheus | http://localhost:9090 | (none) |
| AlertManager | http://localhost:9093 | (none) |

## First Steps

1. Open http://localhost:3000
2. Login with admin/admin
3. Check Connections > Data Sources (Prometheus should be there)
4. Explore dashboards or create custom ones

## Quick Commands

```bash
make start           # Start
make stop            # Stop
make logs            # View logs
make test            # Test alerts
```

## Check Prometheus

```bash
curl http://localhost:9090/api/v1/targets
```

## Next

Read README.md for full documentation

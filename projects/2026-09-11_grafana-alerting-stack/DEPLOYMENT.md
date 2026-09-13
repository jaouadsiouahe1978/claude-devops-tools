# 🚀 Deployment Guide

## Prerequisites

```bash
# Check Docker & Compose
docker --version
docker-compose --version

# Ensure ports 3000, 9090, 9093 are free
lsof -i :3000
```

## Quick Start

```bash
cd projects/2026-09-11_grafana-alerting-stack
docker-compose up -d
sleep 20
```

## Access Services

- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **AlertManager**: http://localhost:9093

## Configuration

### Prometheus (prometheus.yml)
- Scrape interval: 15s
- Evaluation interval: 15s
- Jobs: prometheus, node, cadvisor

### AlertManager (alertmanager.yml)
- Route alerts by severity
- Webhook receivers configured
- Alert inhibition rules for reducing noise

### Alerts (alerts.yml)
- High CPU usage (>80%)
- High memory (>80%)
- High disk usage (>80%)
- Service down detection

## Configure Grafana

1. Login at http://localhost:3000
2. Go to: Connections > Data Sources
3. Verify Prometheus datasource (should auto-exist)
4. Test connection

## Setup Notifications

### Slack Integration

Edit `alertmanager.yml`:
```yaml
receivers:
  - name: 'slack'
    slack_configs:
      - api_url: 'YOUR_SLACK_WEBHOOK_URL'
        channel: '#alerts'
```

### Email Integration

Edit `alertmanager.yml`:
```yaml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_auth_username: 'your-email@gmail.com'
  smtp_auth_password: 'app-password'
  smtp_from: 'alerts@example.com'

receivers:
  - name: 'email'
    email_configs:
      - to: 'ops@example.com'
```

Reload: `curl -X POST http://localhost:9090/-/reload`

## Verify Setup

```bash
# Check targets
curl http://localhost:9090/api/v1/targets | jq

# Check alerts
curl http://localhost:9090/api/v1/alerts | jq

# Test alert
curl -X POST http://localhost:9093/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '[{"labels":{"alertname":"test"}}]'
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Port in use | Change port in docker-compose.yml |
| No data | Wait 30s for first scrape, refresh Grafana |
| Alerts not firing | Check prometheus.yml targets |
| Config won't reload | Check YAML syntax |

## Stop Services

```bash
# Keep volumes
docker-compose down

# Delete everything
docker-compose down -v
```

## Production Tips

1. **Authentication**: Use reverse proxy or Grafana LDAP
2. **Resource limits**: Set in docker-compose.yml
3. **Persistent storage**: Use external volumes
4. **High availability**: Run replicas with Thanos
5. **Backup**: Backup Prometheus data volumes

## Useful Commands

```bash
# View logs
docker-compose logs -f prometheus
docker-compose logs -f grafana

# Restart service
docker-compose restart prometheus

# Check status
docker-compose ps

# Bash into container
docker-compose exec prometheus sh

# Query Prometheus
curl 'http://localhost:9090/api/v1/query?query=up'
```

## Create Custom Dashboards

1. In Grafana: Create > Dashboard
2. Add Panels > Prometheus
3. Write PromQL queries
4. Customize visualization

## Learn More

- Prometheus: https://prometheus.io/docs
- Grafana: https://grafana.com/docs
- AlertManager: https://prometheus.io/docs/alerting/latest/overview/

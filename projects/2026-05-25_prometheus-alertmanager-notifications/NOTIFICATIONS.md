# Guide des Notifications

## Configuration Slack

### 1. Créer un webhook Slack

1. Accédez à https://api.slack.com/apps
2. Cliquez sur "Create New App" → "From scratch"
3. Nommez votre app (ex: "Prometheus Alerts")
4. Sélectionnez votre workspace
5. Dans le menu de gauche, allez à "Incoming Webhooks"
6. Cliquez sur "Add New Webhook to Workspace"
7. Sélectionnez le canal (#alerts ou créez-en un)
8. Copiez l'URL du webhook

### 2. Configurer dans AlertManager

Éditez `alertmanager/alertmanager.yml`:

```yaml
global:
  slack_api_url: 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'
```

### 3. Redémarrer AlertManager

```bash
docker-compose restart alertmanager
```

## Configuration Discord

### 1. Créer un webhook Discord

1. Ouvrez votre serveur Discord
2. Allez aux paramètres du canal (#alerts)
3. Cliquez sur "Intégrations" → "Webhooks"
4. Cliquez sur "Créer un webhook"
5. Copiez l'URL

### 2. Configurer dans AlertManager

```yaml
receivers:
  - name: 'critical-team'
    discord_configs:
      - webhook_url: 'https://discordapp.com/api/webhooks/YOUR/WEBHOOK'
        title: '🚨 ALERTE: {{ .GroupLabels.alertname }}'
```

## Configuration Email (Gmail)

### 1. Générer une mot de passe d'application

1. Accédez à https://myaccount.google.com/apppasswords
2. Sélectionnez "Mail" et "Windows Computer"
3. Copiez le mot de passe généré

### 2. Configurer dans AlertManager

```yaml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_auth_username: 'your-email@gmail.com'
  smtp_auth_password: 'your-app-password'
  smtp_from: 'prometheus-alerts@your-domain.com'

receivers:
  - name: 'email-alerts'
    email_configs:
      - to: 'team@your-domain.com'
        from: 'prometheus-alerts@your-domain.com'
        smarthost: 'smtp.gmail.com:587'
        auth_username: 'your-email@gmail.com'
        auth_password: 'your-app-password'
```

## Configuration PagerDuty

### 1. Obtenir votre clé d'intégration

1. Accédez à https://www.pagerduty.com
2. Allez à "Services" → Sélectionnez votre service
3. Allez à "Integrations" → "Add an Integration"
4. Sélectionnez "Prometheus"
5. Copiez la clé d'intégration

### 2. Configurer dans AlertManager

```yaml
receivers:
  - name: 'pagerduty-alerts'
    pagerduty_configs:
      - service_key: 'YOUR_PAGERDUTY_SERVICE_KEY'
```

## Configuration Webhook personnalisé

Pour envoyer les alertes à un serveur personnalisé:

```yaml
receivers:
  - name: 'custom-webhook'
    webhook_configs:
      - url: 'http://your-server:8080/alerts'
        send_resolved: true
```

### Exemple de récepteur webhook (Python Flask):

```python
from flask import Flask, request

app = Flask(__name__)

@app.route('/alerts', methods=['POST'])
def alert():
    data = request.json
    for alert in data.get('alerts', []):
        status = alert['status']
        labels = alert['labels']
        annotations = alert['annotations']
        
        print(f"[{status.upper()}] {labels['alertname']}")
        print(f"Instance: {labels['instance']}")
        print(f"Desc: {annotations['description']}")
        
    return {'status': 'ok'}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

## Tester les notifications

### 1. Déclencher une alerte manuelle

Modifiez les seuils dans `prometheus/alerts/system-alerts.yml` pour tester:

```yaml
- alert: HighCPUUsage
  expr: (100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)) > 1  # Seuil très bas
  for: 10s  # Très court pour test rapide
```

### 2. Redémarrer Prometheus

```bash
docker-compose restart prometheus
```

### 3. Attendre que l'alerte se déclenche (environ 30s)

### 4. Vérifier dans AlertManager

Allez à http://localhost:9093

### 5. Restaurer les valeurs

```bash
git checkout prometheus/alerts/system-alerts.yml
docker-compose restart prometheus
```

## Debugging

### Vérifier les alertes actives

```bash
curl http://localhost:9090/api/v1/alerts
```

### Vérifier les alertes dans AlertManager

```bash
curl http://localhost:9093/api/v1/alerts
```

### Voir les logs AlertManager

```bash
docker-compose logs alertmanager
```

### Tester la configuration AlertManager

```bash
docker exec alertmanager amtool config routes
```

## Bonnes pratiques

✅ **À faire:**
- Grouper les alertes par service
- Utiliser des niveaux de sévérité cohérents
- Envoyer les alertes résolues
- Tester régulièrement les notifications

❌ **À éviter:**
- Alertes trop sensibles (trop de faux positifs)
- Ignorer les alertes résolues
- Oublier de configurer les webhooks
- Stocker les URL sensibles en clair (utiliser des secrets)

## Ressources

- [AlertManager Docs](https://prometheus.io/docs/alerting/latest/configuration/)
- [AlertManager Receivers](https://prometheus.io/docs/alerting/latest/receivers/)
- [API AlertManager](https://prometheus.io/docs/alerting/latest/client/)

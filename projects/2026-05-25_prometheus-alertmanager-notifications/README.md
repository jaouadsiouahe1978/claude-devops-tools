# Prometheus + AlertManager avec Notifications

## 📋 Description
Mettre en place un système de monitoring et alerting complet avec Prometheus et AlertManager, capable d'envoyer des notifications vers Slack ou Discord en cas de problème.

## 🎯 Objectif
- Déployer Prometheus pour collecter les métriques système
- Configurer AlertManager pour gérer les alertes
- Intégrer des notifications automatiques Slack/Discord
- Créer des règles d'alerte personnalisées
- Visualiser les données avec une interface web

## 🛠 Technos utilisées
- **Prometheus** : Collecte et stockage des métriques
- **AlertManager** : Gestion des alertes et notifications
- **Docker & Docker Compose** : Conteneurisation
- **Node Exporter** : Export des métriques système
- **cAdvisor** : Monitoring des conteneurs
- **Slack/Discord** : Notifications d'alerte

## 📦 Structure du projet
```
.
├── prometheus/
│   ├── prometheus.yml         # Configuration Prometheus
│   ├── alert-rules.yml        # Règles d'alerte
│   └── alerts/
│       └── system-alerts.yml  # Alertes système
├── alertmanager/
│   ├── alertmanager.yml       # Configuration AlertManager
│   └── templates/
│       └── slack-template.tmpl # Template pour Slack
├── docker-compose.yml
└── README.md
```

## 📚 Pré-requis
- Docker & Docker Compose installés
- Webhook Slack/Discord (optionnel pour test)
- Connexion internet (optionnel)

## 🚀 Étapes de réalisation

### 1. Cloner/Télécharger le projet
```bash
cd /path/to/project
```

### 2. Démarrer les conteneurs
```bash
docker-compose up -d
```

### 3. Accéder aux interfaces
- **Prometheus** : http://localhost:9090
- **AlertManager** : http://localhost:9093

### 4. Tester les alertes (optionnel)
```bash
# Stress test pour déclencher une alerte CPU
docker exec prometheus_node_exporter stress-ng --cpu 4 --timeout 30s
```

### 5. Configurer les notifications
- Modifier `alertmanager/alertmanager.yml`
- Ajouter votre webhook Slack/Discord
- Redémarrer AlertManager : `docker-compose restart alertmanager`

## 📖 Ce qu'on apprend

✅ **Prometheus**
- Scraper des métriques
- Comprendre les formats de requête (PromQL)
- Stocker les données de séries temporelles

✅ **AlertManager**
- Définir des règles d'alerte
- Grouper et router les alertes
- Intégrer des canaux de notification

✅ **Monitoring pratique**
- Monitorer les ressources système (CPU, RAM, disque)
- Monitorer les conteneurs Docker
- Créer des alertes intelligentes

✅ **Notifications DevOps**
- Intégration Slack/Discord
- Templates d'alertes personnalisés
- Escalade d'alertes

## 🧪 Commandes utiles

```bash
# Démarrer
docker-compose up -d

# Logs
docker-compose logs -f prometheus
docker-compose logs -f alertmanager

# Arrêter
docker-compose down

# Vérifier les alertes actives
curl http://localhost:9090/api/v1/alerts

# Tester la configuration AlertManager
docker exec alertmanager amtool config routes
```

## 💡 Cas d'usage réels
- Monitorer une application en production
- Alerter l'équipe en cas de surcharge serveur
- Détecter les fuites mémoire
- Surveiller la disponibilité des services
- Automatiser les réactions aux incidents

## 📝 Notes
- Les alertes restent inactives tant qu'aucun seuil n'est dépassé
- Les notifications peuvent être testées en modifiant les seuils temporairement
- AlertManager persiste les alertes en fichier (ne les perd pas au redémarrage)

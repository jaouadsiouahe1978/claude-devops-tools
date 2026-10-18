# Nginx Load Balancer avec Docker Compose

## 📋 Description
Configurer un load balancer Nginx qui distribue le trafic entre plusieurs backends (application web) avec health checks, logging et monitoring basique.

## 🎯 Objectif
- Apprendre à configurer Nginx comme reverse proxy et load balancer
- Orchestrer plusieurs conteneurs avec Docker Compose
- Tester la distribution de charge
- Monitorer les logs et la santé du service

## 🛠️ Technos Utilisées
- **Nginx** : Web server & reverse proxy
- **Docker & Docker Compose** : Containerisation et orchestration
- **Node.js/Express** : Applications backend simples
- **Shell scripts** : Tests et health checks

## 📁 Structure du Projet
```
.
├── README.md
├── docker-compose.yml        # Définition des services
├── nginx/
│   ├── nginx.conf           # Configuration Nginx principale
│   └── Dockerfile           # Image Nginx personnalisée
├── app/
│   ├── Dockerfile           # Application backend
│   └── app.js              # Serveur Express simple
└── tests/
    └── load-test.sh        # Script pour tester le load balancer
```

## 🚀 Étapes de Réalisation

### 1. Démarrer les services
```bash
docker-compose up -d
```

### 2. Vérifier que tous les conteneurs fonctionnent
```bash
docker-compose ps
```

### 3. Tester le load balancer
```bash
# Simple request
curl http://localhost

# Voir le serveur qui traite la requête
for i in {1..5}; do curl -s http://localhost | grep "Server:"; done
```

### 4. Observer la distribution de charge
```bash
# Vérifier les logs du load balancer
docker-compose logs -f nginx
```

### 5. Vérifier les logs des backends
```bash
docker-compose logs app1
docker-compose logs app2
docker-compose logs app3
```

### 6. Teste de charge simple
```bash
bash tests/load-test.sh
```

### 7. Arrêter un backend et voir Nginx ajuster
```bash
docker-compose stop app2
# Faire des requêtes - elles vont à app1 ou app3
curl http://localhost

# Redémarrer
docker-compose up -d app2
```

## 📚 Concepts Apprendre

### Load Balancing
- **Round Robin** : Distribution séquentielle entre serveurs
- **Upstream blocks** : Groupes de serveurs backend
- **Health checks** : Vérifier la disponibilité des services

### Reverse Proxy
- Faire passer les requêtes clients vers les backends
- Modifier les headers HTTP
- Gérer les sessions et la persistance

### Docker Compose
- Réseau interne entre conteneurs
- Dépendances entre services
- Configuration des variables d'environnement

### Monitoring Basique
- Logs Nginx (access.log, error.log)
- Métriques simples (nombre de requêtes)
- Détection de backends down

## 🔧 Commandes Utiles

```bash
# Voir la configuration Nginx
docker-compose exec nginx nginx -T

# Vérifier la connectivité entre conteneurs
docker-compose exec app1 ping app2

# Entrer dans le conteneur Nginx
docker-compose exec nginx sh

# Recharger Nginx sans downtime
docker-compose exec nginx nginx -s reload

# Voir les stats de connexions
docker-compose exec nginx netstat -an | grep ESTABLISHED
```

## 📊 Architecture

```
┌─────────────────────────────────────┐
│         Client (localhost)           │
└────────────────┬────────────────────┘
                 │ HTTP :80
         ┌───────▼────────┐
         │   Nginx LB     │
         │ (Port 80)      │
         └───┬──┬──┬──────┘
             │  │  │
        ┌────┘  │  └────────┐
        │       │           │
   ┌────▼──┐ ┌─▼───┐  ┌────▼──┐
   │ app1  │ │app2 │  │ app3  │
   │ :3001 │ │:3002│  │:3003  │
   └───────┘ └─────┘  └───────┘
```

## 🎓 Pour Aller Plus Loin

1. Ajouter SSL/TLS (certificats self-signed ou Let's Encrypt)
2. Implémenter des health checks avancés
3. Ajouter Prometheus pour le monitoring
4. Configurer une base de données (PostgreSQL)
5. Implémenter du caching avec Nginx
6. Ajouter l'authentification (Basic Auth, OAuth)

## 📝 Notes

- Les conteneurs sont sur le réseau `app_network` créé automatiquement par Docker Compose
- Les applications backend écoute sur localhost:3001-3003
- Nginx écoute sur localhost:80
- Les logs sont visibles avec `docker-compose logs`

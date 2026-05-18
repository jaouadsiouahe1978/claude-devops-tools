# ELK Stack - Monitoring des Logs Centralisés

## Objectif
Déployer une pile ELK (Elasticsearch, Logstash, Kibana) complète pour centraliser, parser et visualiser les logs d'une application. Apprendre les principes de log aggregation et de visualization en DevOps.

## Technologies utilisées
- **Elasticsearch 8.x** : moteur de recherche et stockage des logs
- **Logstash 8.x** : pipeline de traitement et parsing des logs
- **Kibana 8.x** : interface de visualisation et exploration des logs
- **Docker Compose** : orchestration des services
- **Nginx** : serveur applicatif pour générer des logs

## Pré-requis
- Docker & Docker Compose installés
- 3GB de RAM minimum disponible
- Terminal Bash/Zsh
- Curl pour tester les APIs

## Étapes de réalisation

### 1. Structure du projet
```
2026-05-18_elk-stack-logs/
├── README.md
├── docker-compose.yml
├── logstash/
│   ├── logstash.conf
│   └── patterns/
│       └── custom.patterns
├── elasticsearch/
│   └── elasticsearch.yml
├── kibana/
│   └── kibana.yml
├── nginx/
│   ├── nginx.conf
│   └── logs/
└── test-logs.sh
```

### 2. Lancer la pile ELK
```bash
docker-compose up -d
```

### 3. Vérifier l'état des services
```bash
docker-compose ps
curl http://localhost:9200/_cluster/health
curl http://localhost:5601/api/status
```

### 4. Accéder à Kibana
- URL : http://localhost:5601
- Connexion : elastic / changeme (modifier dans docker-compose.yml)

### 5. Parser les logs Nginx
- Les logs Nginx sont automatiquement envoyés à Logstash
- Logstash les parse et les envoie à Elasticsearch
- Créer un index pattern dans Kibana : "logstash-*"

### 6. Générer des logs de test
```bash
bash test-logs.sh
```

### 7. Visualiser les logs
- Aller dans Kibana : Discover
- Sélectionner l'index pattern "logstash-*"
- Explorer les logs, créer des dashboards

## Ce qu'on apprend

1. **Elasticsearch** : architecture distribuée, indexation, recherche full-text
2. **Logstash** : pipelines ETL, parsing de logs, formats custom
3. **Kibana** : exploration des données, dashboards, alertes
4. **Docker Compose** : coordonner plusieurs services
5. **Gestion des logs** : centralisation, parsing, stockage long terme
6. **Networking Docker** : communication inter-conteneurs
7. **Elasticsearch Security** : authentification et chiffrement TLS

## Extensions possibles

- Ajouter Beats (Filebeat, Metricbeat) pour collecter des métriques
- Configurer la persistence des données (volumes named)
- Ajouter des alertes avec Watcher
- Intégrer des logs d'applications (Spring Boot, Node.js, etc.)
- Configurer la rotation des indices et l'archivage
- Ajouter TLS/SSL pour la sécurité

## Troubleshooting

**Elasticsearch ne démarre pas :**
```bash
# Vérifier les logs
docker-compose logs elasticsearch
# Le problème est souvent la mémoire
docker stats
```

**Kibana ne se connecte pas à Elasticsearch :**
```bash
# Vérifier la connectivité
docker exec -it kibana curl http://elasticsearch:9200
```

**Logs non visibles dans Kibana :**
1. Vérifier que Logstash est actif : `docker logs logstash`
2. Vérifier l'index dans Elasticsearch : `curl http://localhost:9200/_cat/indices`
3. Vérifier la configuration Logstash

## Ressources
- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/)
- [Logstash Configuration](https://www.elastic.co/guide/en/logstash/current/)
- [Kibana User Guide](https://www.elastic.co/guide/en/kibana/)

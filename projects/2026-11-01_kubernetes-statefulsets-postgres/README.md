# Kubernetes StatefulSets: PostgreSQL Database Deployment

## Objectif
Apprendre à déployer une base de données **PostgreSQL** sur Kubernetes avec **StatefulSets**, **Persistent Volumes** et gestion de la persistance des données.

## Description
Ce projet montre comment gérer une application stateful (base de données) sur Kubernetes en utilisant :
- **StatefulSets** pour garantir l'identité réseau stable et l'ordre de déploiement
- **Persistent Volumes (PV)** et **Persistent Volume Claims (PVC)** pour la persistance des données
- **Services Headless** pour la découverte DNS des pods
- **ConfigMaps** et **Secrets** pour la configuration et les credentials
- Scripts de backup/restore et test de résilience

## Technologies Utilisées
- **Kubernetes** (local avec Minikube ou Docker Desktop)
- **PostgreSQL** 15+
- **kubectl** CLI
- **Helm** 3.x (optionnel)
- **Bash** scripting

## Prérequis
```bash
# Kubernetes cluster (local ou cloud)
kubectl version --client

# Helm 3
helm version

# PostgreSQL client (psql)
psql --version
```

## Architecture
```
┌──────────────────────────────────────────────┐
│        Kubernetes Cluster                     │
├──────────────────────────────────────────────┤
│                                              │
│  StatefulSet: postgres                       │
│  ├── Pod: postgres-0 (Primary)              │
│  ├── Pod: postgres-1 (Replica)              │
│  └── Pod: postgres-2 (Replica)              │
│         │                                    │
│         └─→ PVC ─→ PV (Storage)             │
│                                              │
│  Service Headless: postgres-headless        │
│  Service ClusterIP: postgres                │
│                                              │
└──────────────────────────────────────────────┘
```

## Étapes de Réalisation

### 1. Créer le Namespace
```bash
kubectl create namespace postgres-db
kubectl config set-context --current --namespace=postgres-db
```

### 2. Créer le Secret pour les credentials
```bash
kubectl apply -f manifests/secret.yaml
```

### 3. Déployer ConfigMap pour la configuration
```bash
kubectl apply -f manifests/configmap.yaml
```

### 4. Créer la classe de stockage (si nécessaire)
```bash
kubectl apply -f manifests/storageclass.yaml
```

### 5. Déployer le StatefulSet PostgreSQL
```bash
kubectl apply -f manifests/statefulset.yaml
```

### 6. Vérifier le déploiement
```bash
kubectl get statefulset -n postgres-db
kubectl get pods -n postgres-db
kubectl get pvc -n postgres-db
kubectl logs -f postgres-0 -n postgres-db
```

### 7. Se connecter à PostgreSQL
```bash
# Port-forward
kubectl port-forward postgres-0 5432:5432 -n postgres-db

# Depuis un autre terminal
psql -h localhost -U postgres -d postgres -c "SELECT version();"
```

### 8. Tester la résilience
```bash
bash scripts/test-resilience.sh
```

### 9. Faire un backup
```bash
bash scripts/backup.sh
```

### 10. Tester la récupération
```bash
bash scripts/restore.sh backup-file.sql
```

## Ce qu'on apprend

### Concepts Kubernetes
- **StatefulSets**: Application stateful avec identité stable
- **Headless Service**: DNS pour découvrir chaque pod individuellement
- **Persistent Volumes**: Stockage durable des données
- **Volume Claims**: Requêtes de stockage par les applications

### Cas d'usage réels
- Déployer une DB MySQL/PostgreSQL en production
- Gestion de la haute disponibilité
- Stratégies de backup/restore
- Scaling des bases de données
- Migration de données

### Troubleshooting
- Vérifier les logs des pods
- Checker l'état des PVC
- Diagnostiquer les issues de connectivité réseau
- Récupération en cas de perte de données

## Fichiers Structure
```
2026-11-01_kubernetes-statefulsets-postgres/
├── README.md                      # Ce fichier
├── manifests/
│   ├── namespace.yaml            # Namespace postgres-db
│   ├── secret.yaml               # Credentials PostgreSQL
│   ├── configmap.yaml            # Configuration initiale
│   ├── storageclass.yaml         # Classe de stockage
│   ├── service-headless.yaml     # Service Headless
│   ├── service-clusterip.yaml    # Service ClusterIP
│   └── statefulset.yaml          # StatefulSet PostgreSQL
├── scripts/
│   ├── deploy.sh                 # Script de déploiement
│   ├── backup.sh                 # Backup de la DB
│   ├── restore.sh                # Restore de la DB
│   ├── test-resilience.sh        # Test de résilience
│   └── cleanup.sh                # Nettoyage complet
├── helm/
│   └── Chart.yaml                # Helm chart de base
└── docker-compose.yml            # Déploiement local (optionnel)
```

## Commandes Utiles

### Inspection
```bash
# Voir les pods
kubectl get pods -n postgres-db -o wide

# Voir les PVC
kubectl get pvc -n postgres-db

# Voir les events
kubectl describe statefulset postgres -n postgres-db

# Logs
kubectl logs postgres-0 -n postgres-db
kubectl logs postgres-0 -n postgres-db --previous
```

### Debugging
```bash
# Exécuter une commande dans le pod
kubectl exec -it postgres-0 -n postgres-db -- /bin/bash

# Se connecter à psql depuis le pod
kubectl exec -it postgres-0 -n postgres-db -- psql -U postgres

# Port-forward
kubectl port-forward postgres-0 5432:5432 -n postgres-db
```

### Nettoyage
```bash
bash scripts/cleanup.sh
# ou manuel:
kubectl delete statefulset postgres -n postgres-db
kubectl delete pvc --all -n postgres-db
kubectl delete namespace postgres-db
```

## Ressources
- [Kubernetes StatefulSets Docs](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [PostgreSQL on Kubernetes](https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/)

## Notes
- StatefulSets garantissent l'ordre de création/suppression des pods
- Les PVC sont liées à des nodes spécifiques (pour le stockage local)
- Pour la haute disponibilité réelle, considérer PostgreSQL Operator
- Les replicas doivent être configurés avec réplication PostgreSQL native

---
**Auteur**: DevOps Learning Path  
**Date**: 2026-11-01  
**Niveau**: Intermédiaire

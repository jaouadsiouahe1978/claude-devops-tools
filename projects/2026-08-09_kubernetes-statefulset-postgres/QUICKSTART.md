# 🚀 Quick Start Guide

Nouveau sur ce projet? Commencez ici!

## ⚡ Démarrage en 5 minutes

### Pré-requis
- `kubectl` configuré avec accès à un cluster Kubernetes
- Un cluster Kubernetes actif (minikube, kind, EKS, etc.)

### Étape 1: Préparer le cluster (une seule fois)

Si vous utilisez **minikube**:
```bash
minikube ssh
sudo mkdir -p /data/pv-0 /data/pv-1
sudo chmod 777 /data/pv-0 /data/pv-1
exit
```

### Étape 2: Déployer PostgreSQL StatefulSet

```bash
cd projects/2026-08-09_kubernetes-statefulset-postgres

# Option A: Déployer tout d'un coup
make deploy

# Option B: Déployer étape par étape (pour apprendre)
make deploy-ns      # Namespace et configs
make deploy-pv      # Volumes
make deploy-ss      # StatefulSet
```

### Étape 3: Vérifier le déploiement

```bash
# Voir les pods en temps réel
make monitor

# Ou dans un autre terminal, voir le statut
make status
```

### Étape 4: Insérer et vérifier les données

```bash
# Insérer des données de test
make insert-data

# Vérifier que les données sont là
make check-data
```

### Étape 5: Tester la persistance des données!

```bash
# Test complet: insère données, crash un pod, vérifie recovery
make test-persistence
```

🎉 **Bravo!** Les données ont survécu au crash!

## 📚 Commandes essentielles

```bash
make help              # Voir toutes les commandes
make deploy            # Déployer
make status            # État du StatefulSet
make monitor           # Monitoring temps réel
make logs              # Voir les logs
make psql              # Shell PostgreSQL
make check-data        # Afficher les données
make cleanup           # Nettoyer
```

## 🎯 Que se passe-t-il?

1. **Namespace creation** : Crée un namespace `postgresql` isolé
2. **PersistentVolumes** : Définit 2 volumes locaux (10Gi chacun)
3. **StatefulSet** : Crée 2 pods PostgreSQL avec identité stable
4. **Service Headless** : Fournit DNS stable pour chaque pod
5. **Volumes** : Chaque pod a son propre PersistentVolumeClaim

### Architecture
```
┌─────────────────────────────────────────┐
│ PostgreSQL StatefulSet (2 replicas)    │
│                                         │
│ ├─ postgres-0 ←→ PVC-0 ←→ /data/pv-0  │
│ └─ postgres-1 ←→ PVC-1 ←→ /data/pv-1  │
│                                         │
│ Service: postgres.postgresql.svc        │
│ DNS: postgres-0.postgres...             │
└─────────────────────────────────────────┘
```

## 🔍 Exploration

### Voir les pods
```bash
kubectl get pods -n postgresql
```

### Entrer dans un pod
```bash
kubectl exec -it postgres-0 -n postgresql -- /bin/sh
```

### Interroger les données
```bash
kubectl exec postgres-0 -n postgresql -- \
  psql -U postgres -d myapp -c "SELECT * FROM users;"
```

### Voir les volumes
```bash
kubectl get pvc -n postgresql
kubectl get pv
```

## 💡 Concepts clés

- **StatefulSet** vs **Deployment**: StatefulSet pour les apps avec état (DB, cache)
- **Pod Identity**: Noms stables (postgres-0, postgres-1, ...)
- **PersistentVolume**: Stockage au niveau cluster
- **PersistentVolumeClaim**: Demande de stockage par un pod
- **Service Headless**: DNS stable par pod (clusterIP: None)

## 🚨 Erreurs courantes

**Erreur**: `mount.nfs: mount point /var/lib/kubelet/pods/... does not exist`
- **Solution**: Créer les répertoires: `sudo mkdir -p /data/pv-0 /data/pv-1`

**Erreur**: `pod postgres-0 not found`
- **Solution**: Vérifier que le StatefulSet est déployé: `make status`

**Erreur**: `cannot connect to PostgreSQL`
- **Solution**: Attendre que le pod soit Ready: `make monitor`

## 📖 Prochaines étapes

1. **Lire le README.md** pour comprendre l'architecture
2. **Explorer le Makefile** pour voir toutes les commandes
3. **Lire docs/concepts.md** pour approfondir
4. **Tester le scale-up** : `kubectl scale statefulset postgres -n postgresql --replicas=3`

## 🆘 Aide

- **Voir les logs** : `make logs`
- **Décrire le StatefulSet** : `make describe`
- **Voir toutes les commandes** : `make help`
- **Lire la documentation complète** : voir `README.md`

---

**Durée estimée de ce quickstart**: 5-10 minutes
**Prochaine étape**: Lire le README.md complet

# Quick Start - PostgreSQL StatefulSet

Démarrer en 5 minutes:

## 1️⃣ Prérequis
```bash
# Vérifier k8s
kubectl cluster-info
kubectl get nodes
```

## 2️⃣ Déployer
```bash
# Simple: un script fait tout
cd projects/2026-10-29_kubernetes-statefulset-postgres
bash scripts/deploy.sh postgres-demo deploy
```

## 3️⃣ Attendre
```bash
# La base est prête quand:
kubectl get pods -n postgres-demo
# postgres-0 doit être en "Running" et "1/1 Ready"
```

## 4️⃣ Se connecter
```bash
# Option A: Direct avec le script
bash scripts/connect.sh

# Option B: Port forward + psql local
kubectl port-forward -n postgres-demo postgres-0 5432:5432 &
psql -h localhost -U postgres
```

## 5️⃣ Test rapide
```sql
-- Dans psql:
\l                          -- Lister les bases
\c myapp                    -- Se connecter à myapp
SELECT * FROM users;        -- Voir les données
```

## 🧪 Tester la persistance
```bash
# Supprimer le pod
kubectl delete pod postgres-0 -n postgres-demo

# Il se recrée automatiquement
kubectl get pods -n postgres-demo -w

# Les données sont toujours là!
bash scripts/connect.sh postgres-demo postgres-0 myapp postgres
> SELECT * FROM users;
```

## 🔄 Faire un backup
```bash
bash scripts/backup-postgres.sh postgres-demo postgres-0
# Crée un fichier dans ./backups/
```

## 🗑️ Nettoyer
```bash
bash scripts/deploy.sh postgres-demo undeploy
```

---
**Prêt!** Consultez `README.md` pour la documentation complète.

# Commands utiles pour la gestion des Helm Charts

## Installation et Déploiement

### Déployer l'application en développement
```bash
./deploy.sh -e dev -a install
```

### Déployer l'application en test
```bash
./deploy.sh -e test -a install
```

### Déployer l'application en production
```bash
./deploy.sh -e prod -a install
```

### Upgrade d'une release
```bash
helm upgrade myapp . -f environments/dev-values.yaml -n myapp-dev
```

### Upgrade interactif
```bash
./deploy.sh -e dev -a upgrade
```

---

## Vérification du statut

### Vérifier le statut de la release
```bash
helm status myapp -n myapp-dev
```

### Lister toutes les releases
```bash
helm list -n myapp-dev
```

### Lister les releases dans tous les namespaces
```bash
helm list --all-namespaces
```

### Vérifier l'historique des releases
```bash
helm history myapp -n myapp-dev
```

---

## Gestion des Pods et Services

### Lister tous les pods
```bash
kubectl get pods -n myapp-dev
```

### Lister les services
```bash
kubectl get svc -n myapp-dev
```

### Vérifier les détails d'un pod
```bash
kubectl describe pod <pod-name> -n myapp-dev
```

### Voir les logs d'un pod
```bash
kubectl logs -n myapp-dev -l app.kubernetes.io/name=frontend
```

### Logs en temps réel
```bash
kubectl logs -f -n myapp-dev -l app.kubernetes.io/name=backend
```

### Logs de tous les containers
```bash
kubectl logs -n myapp-dev deployment/myapp-frontend --all-containers=true
```

---

## Port Forwarding

### Accéder au frontend
```bash
kubectl port-forward -n myapp-dev svc/myapp-frontend 8080:80
# Puis aller à http://localhost:8080
```

### Accéder à l'API backend
```bash
kubectl port-forward -n myapp-dev svc/myapp-backend 3000:3000
# Puis aller à http://localhost:3000
```

### Accéder à PostgreSQL
```bash
kubectl port-forward -n myapp-dev svc/myapp-postgresql 5432:5432
# Puis: psql -h localhost -U myapp_user -d myapp_db
```

---

## Accès à la base de données

### Connexion interactive avec psql
```bash
kubectl exec -it -n myapp-dev deployment/myapp-postgresql -- psql -U myapp_user -d myapp_db
```

### Exécuter une requête SQL
```bash
kubectl exec -n myapp-dev deployment/myapp-postgresql -- psql -U myapp_user -d myapp_db -c "SELECT version();"
```

### Dump de la base de données
```bash
kubectl exec -n myapp-dev deployment/myapp-postgresql -- pg_dump -U myapp_user myapp_db > backup.sql
```

### Restaurer une base de données
```bash
kubectl exec -i -n myapp-dev deployment/myapp-postgresql -- psql -U myapp_user myapp_db < backup.sql
```

---

## Valider les Charts

### Vérifier la syntaxe du chart
```bash
helm lint .
```

### Générer le YAML sans appliquer
```bash
helm template myapp . -f environments/dev-values.yaml -n myapp-dev
```

### Valider le YAML généré
```bash
helm template myapp . -f environments/dev-values.yaml -n myapp-dev | kubectl apply -f - --dry-run=client -o yaml
```

---

## Scaling et Ressources

### Scaler un déploiement manuellement
```bash
kubectl scale deployment -n myapp-dev myapp-frontend --replicas=5
```

### Vérifier les ressources utilisées
```bash
kubectl top pods -n myapp-dev
```

### Vérifier les nodes
```bash
kubectl top nodes
```

---

## Secrets et ConfigMaps

### Lister les secrets
```bash
kubectl get secrets -n myapp-dev
```

### Voir le contenu d'un secret (base64)
```bash
kubectl get secret -n myapp-dev db-credentials -o yaml
```

### Décoder un secret
```bash
kubectl get secret -n myapp-dev db-credentials -o jsonpath='{.data.password}' | base64 -d
```

### Lister les ConfigMaps
```bash
kubectl get configmap -n myapp-dev
```

---

## Désinstallation

### Désinstaller une release
```bash
helm uninstall myapp -n myapp-dev
```

### Désinstaller tous les namespaces
```bash
./deploy.sh -e dev -a uninstall
./deploy.sh -e test -a uninstall
./deploy.sh -e prod -a uninstall
```

---

## Débogage avancé

### Entrer dans un pod
```bash
kubectl exec -it -n myapp-dev deployment/myapp-backend -- sh
```

### Copier un fichier depuis un pod
```bash
kubectl cp myapp-dev/myapp-backend-xxx:/app/logs.txt ./logs.txt
```

### Copier un fichier vers un pod
```bash
kubectl cp ./config.json myapp-dev/myapp-backend-xxx:/app/config.json
```

### Décrire tous les événements
```bash
kubectl get events -n myapp-dev
```

### Vérifier la configuration du pod
```bash
kubectl get pod -n myapp-dev myapp-backend-xxx -o yaml
```

---

## Helm Rollback

### Voir l'historique des versions
```bash
helm history myapp -n myapp-dev
```

### Revenir à une version précédente
```bash
helm rollback myapp 1 -n myapp-dev
```

### Revenir à la version précédente
```bash
helm rollback myapp -n myapp-dev
```

---

## Tests et Validation

### Tester la connexion réseau
```bash
kubectl run -it --rm debug --image=alpine --restart=Never -n myapp-dev -- sh
# Dans le pod: wget http://myapp-frontend
# Dans le pod: nc -zv myapp-postgresql 5432
```

### Vérifier les health checks
```bash
kubectl describe pod -n myapp-dev $(kubectl get pods -n myapp-dev -o name | head -1)
```

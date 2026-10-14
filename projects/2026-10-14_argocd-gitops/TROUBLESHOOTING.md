# Troubleshooting ArgoCD

## Problèmes Courants

### 1. Les pods ArgoCD ne démarre pas

**Symptôme**: Pods en `Pending` ou `CrashLoopBackOff`

**Solutions**:
```bash
# Vérifier les ressources
kubectl describe pod -n argocd <pod-name>

# Voir les logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

### 2. Application reste "OutOfSync"

**Symptôme**: `OutOfSync` même après sync

**Solutions**:
```bash
# Forcer une re-synchronisation
argocd app sync myapp --force

# Voir les logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

### 3. Connexion à un dépôt Git échoue

**Symptôme**: Erreur de connexion au repo

**Solutions**:
```bash
# Tester la connexion
argocd repo add https://github.com/my-repo \
  --username user \
  --password token \
  --dry-run

# Lister les repos
argocd repo list
```

### 4. Erreur de validation de ressources

**Symptôme**: "validation failed" lors de la sync

**Solutions**:
```bash
# Vérifier les erreurs
argocd app diff myapp

# Valider manuellement
kubectl apply -f my-manifest.yaml --dry-run=client
```

### 5. Application ne se synchro pas automatiquement

**Symptôme**: Auto-sync configuré mais rien ne change

**Solutions**:
```bash
# Vérifier la config
argocd app get myapp | grep -A 5 syncPolicy

# Activer auto-sync
argocd app set myapp --sync-policy automated --auto-prune

# Forcer un refresh
argocd repo refresh
```

### 6. Erreur d'authentification au dashboard

**Symptôme**: Impossible de login

**Solutions**:
```bash
# Récupérer le mot de passe
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Redémarrer le server
kubectl rollout restart deployment/argocd-server -n argocd
```

## Commandes de Diagnostic

```bash
# Status global
argocd app list
kubectl get applications -n argocd

# Logs
kubectl logs -n argocd -f -l app.kubernetes.io/name=argocd-application-controller

# Événements
kubectl get events -n argocd --sort-by='.lastTimestamp'

# Ressources utilisées
kubectl top pods -n argocd
```

## Ressources Utiles

- [ArgoCD Troubleshooting Guide](https://argo-cd.readthedocs.io/en/stable/operator-manual/troubleshooting/)
- [ArgoCD FAQ](https://argo-cd.readthedocs.io/en/stable/faq/)

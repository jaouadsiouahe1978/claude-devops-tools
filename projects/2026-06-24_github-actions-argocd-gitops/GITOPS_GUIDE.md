# Guide Pratique: GitOps avec GitHub Actions et ArgoCD

## Qu'est-ce que GitOps?

GitOps est une pratique où Git est utilisé comme **source de vérité unique** pour l'infrastructure et les applications. Tous les changements passent par Git (via pull requests) et sont appliqués automatiquement au cluster.

### Principes Fondamentaux:

1. **Déclaratif**: Description de l'état souhaité (YAML)
2. **Versionné**: Chaque changement dans Git
3. **Automatisé**: Outils qui synchronisent Git → Infrastructure
4. **Auditable**: Historique complet des changements
5. **Récupérable**: Rollback facile via Git

## Architecture de cette Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│ Developer commits code to GitHub                                 │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                    ┌──────▼──────┐
                    │    GitHub   │
                    │   Actions   │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼────┐         ┌───▼───┐        ┌────▼─────┐
   │  Test   │         │ Build │        │   Lint   │
   │   App   │         │Docker │        │   Code   │
   └────┬────┘         └───┬───┘        └────┬─────┘
        │                  │                  │
        └──────────────────┼──────────────────┘
                           │
                    ┌──────▼──────────────┐
                    │  Push Docker Image  │
                    │  to Registry        │
                    └──────┬──────────────┘
                           │
                    ┌──────▼──────────────┐
                    │ Update K8s Manifest │
                    │ (deployment.yaml)   │
                    └──────┬──────────────┘
                           │
                    ┌──────▼──────────────┐
                    │ Commit to GitHub    │
                    │ (new image tag)     │
                    └──────┬──────────────┘
                           │
                    ┌──────▼──────────────┐
                    │     ArgoCD      Watch│
                    │   Détecte le        │
                    │  changement         │
                    └──────┬──────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼─────┐      ┌─────▼────┐      ┌────▼────┐
   │ Pull Latest│    │  Create  │    │  Monitor│
   │   Image   │    │   New    │    │ Health  │
   └────┬─────┘      │   Pods   │    └────┬────┘
        │            └─────┬────┘         │
        │                  │              │
        └──────────────────┼──────────────┘
                           │
                    ┌──────▼──────────────┐
                    │  App Running in     │
                    │  Production         │
                    └─────────────────────┘
```

## Workflow: De la Modification au Déploiement

### Étape 1: Développeur modifie le code

```bash
# Modifier l'application
vim app/server.py

# Commit et push
git add app/
git commit -m "feat: add new endpoint"
git push origin main
```

### Étape 2: GitHub Actions s'exécute

**Build → Push → Update Manifests**

```yaml
# .github/workflows/build-push.yml déclenché automatiquement
- Teste le code
- Construit l'image Docker
- Push vers ghcr.io avec tag sha-XXXXX
- Met à jour k8s/deployment.yaml
- Commit et push les changements
```

### Étape 3: ArgoCD détecte et synchronise

```bash
# ArgoCD surveille en continu:
# 1. Détecte que deployment.yaml a changé
# 2. Récupère la nouvelle image
# 3. Lance les nouveaux pods
# 4. Arrête les anciens (rolling update)
# 5. Monitore la santé
```

### Étape 4: Vérification

```bash
# Voir l'état de l'application
kubectl get deployment -n gitops-demo
kubectl get pods -n gitops-demo

# Voir les logs
kubectl logs -n gitops-demo -l app=gitops-app

# Tester l'endpoint
kubectl port-forward -n gitops-demo svc/gitops-app 5000:80
curl http://localhost:5000/health
```

## Commandes Essentielles

### Avec kubectl

```bash
# Voir les ressources déployées
kubectl get all -n gitops-demo

# Voir les détails du déploiement
kubectl describe deployment gitops-app -n gitops-demo

# Voir les logs
kubectl logs -n gitops-demo -l app=gitops-app -f

# Faire un port-forward
kubectl port-forward -n gitops-demo svc/gitops-app 5000:80

# Modifier replicas
kubectl scale deployment gitops-app -n gitops-demo --replicas=5

# Redémarrer les pods
kubectl rollout restart deployment/gitops-app -n gitops-demo
```

### Avec ArgoCD (CLI)

```bash
# Login
argocd login localhost:8080 --username admin --password <password>

# Voir les applications
argocd app list

# Voir l'état détaillé
argocd app get gitops-demo-app

# Forcer la synchronisation
argocd app sync gitops-demo-app

# Voir les logs de synchronisation
argocd app logs gitops-demo-app --follow

# Refresh du manifest Git
argocd app set gitops-demo-app -p imageTag=sha-abc123def

# Rollback à une version précédente
argocd app history gitops-demo-app
argocd app rollback gitops-demo-app <revision>
```

### Avec ArgoCD (Web UI)

1. Accéder à https://localhost:8080
2. Username: `admin`
3. Password: `kubectl get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`

## Cas d'Usage Pratiques

### 1️⃣ Déployer une nouvelle version

```bash
# Code change → Commit → Push
echo "v2.0" > VERSION
git add VERSION
git commit -m "Release v2.0"
git push origin main

# ✅ Automatiquement:
# - GitHub Actions construit l'image
# - Mise à jour du manifest
# - ArgoCD détecte et déploie
# - Rolling update en 2-3 minutes
```

### 2️⃣ Rollback rapide

```bash
# Problème détecté? Simple revert Git
git revert HEAD  # Annule le dernier commit
git push origin main

# ✅ Automatiquement: ArgoCD redéploie la version précédente
```

### 3️⃣ Configuration multi-environnements

Structure recommandée:
```
k8s/
├── base/              # Configuration commune
│   ├── deployment.yaml
│   └── service.yaml
├── overlays/
│   ├── dev/           # Surcharges dev
│   │   └── kustomization.yaml
│   ├── staging/       # Surcharges staging
│   │   └── kustomization.yaml
│   └── prod/          # Surcharges prod
│       └── kustomization.yaml
```

ArgoCD Application par env:
```yaml
# Application pour dev
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: gitops-demo-dev
spec:
  source:
    path: projects/2026-06-24_github-actions-argocd-gitops/k8s/overlays/dev
  destination:
    namespace: gitops-demo-dev
```

### 4️⃣ Monitoring avec ArgoCD

```bash
# Voir quand ArgoCD a synchronisé
kubectl get event -n argocd | grep gitops-demo-app

# Logs détaillés
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller

# Métriques (Prometheus)
# ArgoCD expose des métriques sur :8082/metrics
```

## Bonnes Pratiques

### ✅ À Faire

1. **Tous les changements via Git**
   - Jamais de `kubectl apply` direct
   - Jamais de modifications dans l'UI

2. **Pull Requests pour tout**
   - Review avant merge
   - CI checks avant merge

3. **Manifests versionés**
   - Images avec tags précis
   - Pas de `latest` en production

4. **Secrets sécurisés**
   - Jamais en clair dans Git
   - Utiliser sealed-secrets ou external-secrets

5. **Tests automatisés**
   - Syntaxe YAML
   - Policies avec kyverno/opa

### ❌ À Éviter

1. ❌ Modifier directement avec `kubectl`
2. ❌ Utiliser `latest` comme tag d'image
3. ❌ Commit de secrets dans Git
4. ❌ `kubectl delete` sans versionner d'abord
5. ❌ Dépendre de l'ordre de création des ressources

## Troubleshooting

### ArgoCD ne synchronise pas

```bash
# 1. Vérifier l'état de l'application
kubectl describe app gitops-demo-app -n argocd

# 2. Vérifier les logs du controller
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller

# 3. Vérifier l'accès au repo
argocd repo list
argocd repo get https://github.com/jaouadsiouahe1978/claude-devops-tools

# 4. Forcer refresh
kubectl delete pod -n argocd -l app.kubernetes.io/name=argocd-repo-server
argocd app set gitops-demo-app --refresh-type hard
```

### Image Docker ne se met pas à jour

```bash
# 1. Vérifier que le manifest a bien été modifié
git log -p k8s/deployment.yaml | head -50

# 2. Vérifier que l'image existe en registre
docker pull ghcr.io/jaouadsiouahe1978/claude-devops-tools/gitops-app:sha-abc123

# 3. Forcer pull de la nouvelle image
kubectl set image deployment/gitops-app \
  gitops-app=ghcr.io/.../gitops-app:sha-new -n gitops-demo
```

### Pods ne deviennent pas ready

```bash
# 1. Voir les logs
kubectl logs -n gitops-demo -l app=gitops-app

# 2. Voir les événements
kubectl describe pod -n gitops-demo -l app=gitops-app

# 3. Checker les ressources
kubectl top pod -n gitops-demo

# 4. Vérifier la probe
curl http://<pod-ip>:5000/health
```

## Ressources Supplémentaires

- [GitOps Principles](https://gitops.tech/)
- [ArgoCD Docs](https://argo-cd.readthedocs.io/)
- [Kustomize](https://kustomize.io/)
- [GitHub Actions](https://github.com/features/actions)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

---

**Créé**: 2026-06-24  
**Niveau**: Intermédiaire-Avancé  
**Durée**: 1 jour

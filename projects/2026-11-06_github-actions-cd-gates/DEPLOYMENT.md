# Guide de Déploiement

## 📋 Table des Matières

1. [Configuration Initiale](#configuration-initiale)
2. [Environnements GitHub](#environnements-github)
3. [Branch Protection](#branch-protection)
4. [Secrets GitHub](#secrets-github)
5. [Approval Gates](#approval-gates)
6. [Déploiement Manuel](#déploiement-manuel)
7. [Monitoring](#monitoring)
8. [Rollback](#rollback)

## Configuration Initiale

### 1. Préparation du Repo

```bash
# Clone et setup
git clone https://github.com/jaouadsiouahe1978/myapp.git
cd myapp

# Create branches
git checkout -b develop
git push -u origin develop
```

### 2. Workflow CI/CD Setup

Tous les workflows sont dans `.github/workflows/` :
- **ci.yml** : Build, tests, security scan
- **cd-staging.yml** : Deploy automatique sur staging (push develop)
- **cd-production.yml** : Deploy sur prod (push main + approval)
- **matrix-build.yml** : Multi-plateforme build

## Environnements GitHub

### Créer les Environnements

Aller dans **Settings > Environments** et créer :

#### 1. **dev** (Développement)
```
Name: dev
Deployment branches: develop
No restrictions
```

#### 2. **staging** (Staging)
```
Name: staging
Deployment branches: develop
Required reviewers: Optional (1-2 devs)
Prevent self-review: OFF
```

#### 3. **production** (Production)
```
Name: production
Deployment branches: main
Required reviewers: YES (min 1 reviewer)
Prevent self-review: ON
Wait timer: 5 minutes (optional)
```

### Configuration Supplémentaire

Pour chaque environnement, ajouter les secrets spécifiques :

```
KUBE_CONFIG_<ENV>      : Base64 kubeconfig
DOCKER_REGISTRY_USER   : Username registry
DOCKER_REGISTRY_PASSWORD: Password registry
SLACK_WEBHOOK          : URL webhook Slack
```

## Branch Protection

### Main Branch (Production)

Aller dans **Settings > Branches > main**

```
✅ Require a pull request before merging
   - Require approvals: 1
   - Dismiss stale PR approvals: ON
   
✅ Require status checks to pass before merging
   - Required checks:
     - ci / lint
     - ci / test
     - ci / build
     - ci / security
   
✅ Require branches to be up to date before merging

✅ Restrict who can push to matching branches
   - Users/Teams: (optionnel)

✅ Require signed commits (optionnel)
```

### Develop Branch (Staging)

Aller dans **Settings > Branches > develop**

```
✅ Require a pull request before merging
   - Require approvals: 1
   
✅ Require status checks to pass before merging
   - Required checks:
     - ci / lint
     - ci / test
     - ci / build
```

## Secrets GitHub

### Actions Secrets

Aller dans **Settings > Secrets > Actions**

```
DOCKER_REGISTRY_USER
Valeur: your-docker-username
```

```
DOCKER_REGISTRY_PASSWORD
Valeur: your-docker-password
```

```
KUBE_CONFIG_STAGING
Valeur: 
  cat ~/.kube/config | base64 -w 0
```

```
KUBE_CONFIG_PROD
Valeur:
  cat ~/.kube/prod-config | base64 -w 0
```

```
SLACK_WEBHOOK
Valeur: https://hooks.slack.com/services/...
```

## Approval Gates

### Configuration

1. **Environnement Production** :
   - Chaque déploiement prod requiert un approval
   - Minimum 1 reviewer
   - Pas self-approval

2. **Déclenchement** :
   ```bash
   # Merge sur main automatiquement déclenche
   # Attendre le workflow "CD - Deploy to Production"
   # Onglet "Deployments" > Pending approval
   # Cliquer sur "Review deployments"
   # Approver ou rejeter
   ```

### Workflow de Déploiement

```
Feature Branch
     ↓
[git push origin feature/...]
     ↓
CI Workflow (lint, test, build, security)
     ↓
PR Created
     ↓
[Create PR] → Status checks required
     ↓
[Merge PR] → Auto-push develop
     ↓
CD-Staging Workflow
     ↓
[Auto Deploy Staging] ✅
     ↓
Tests & Validation
     ↓
IF READY FOR PROD:
  [git merge develop → main]
     ↓
  CD-Production Workflow
     ↓
  [WAITING FOR APPROVAL]
     ↓
  Reviewer Approves
     ↓
  [Blue-Green Deploy]
     ↓
  [Health Checks & Validation]
     ↓
  [DEPLOYED TO PRODUCTION] ✅
```

## Déploiement Manuel

### Déclencher une Build Matrix

```bash
# Via CLI
gh workflow run matrix-build.yml --ref main

# Via UI
GitHub > Actions > "Matrix Build - Multi-Platform" > Run workflow
```

### Déployer une Version Spécifique

```bash
# Créer un tag pour release
git tag v1.0.0
git push origin v1.0.0

# CD-Production workflow se déclenche automatiquement
# Requiert toujours approval avant prod
```

## Monitoring

### Vérifier les Déploiements

```bash
# Onglet "Actions"
# Voir tous les workflows

# Onglet "Deployments"
# Voir tous les déploiements par environnement

# Onglet "Environments"
# Voir l'historique de déploiement
```

### Logs des Workflows

1. GitHub > Actions
2. Sélectionner le workflow
3. Cliquer sur le run
4. Voir les logs détaillés de chaque step

### Notifications Slack

Les workflows envoient des notifications Slack :
- ✅ Build réussi
- ❌ Build échoué
- ✅ Deploy réussi
- ❌ Deploy échoué

## Rollback

### Plan de Rollback

En cas de problème en production :

### Option 1 : Rollback Automatique

```bash
# Redéployer la version précédente
git revert <commit>
git push origin main

# Approver le déploiement comme normal
```

### Option 2 : Rollback Manuel

```bash
# Directement en Kubernetes (si accès direct)
kubectl rollout undo deployment/myapp-blue -n production

# Vérifier
kubectl get pods -n production
```

### Option 3 : Déploiement Blue-Green

Le déploiement utilise blue-green :
- **Green** : Version actuelle en production
- **Blue** : Nouvelle version en staging
- Switch du traffic green → blue

En cas de problème :
```bash
# Basculer traffic de blue back to green
kubectl patch service myapp -n production -p '{"spec":{"selector":{"color":"green"}}}'
```

## Bonnes Pratiques

1. **Toujours faire des PRs** avant merge
2. **Attendre les status checks** avant merge
3. **Faire des deployments staging** avant prod
4. **Valider en staging** avant approval prod
5. **Approver avec au moins 2 yeux** en prod
6. **Monitorer après chaque deployment**
7. **Garder des logs pour audit**
8. **Tester le rollback** régulièrement

## Troubleshooting

### Le workflow ne démarre pas

1. Vérifier les branches protégées
2. Vérifier les workflows sont activés (Actions settings)
3. Vérifier syntax du workflow YAML

### Deploy échoue avec erreur k8s

1. Vérifier KUBE_CONFIG est correct
2. Vérifier kubeconfig n'a pas expiré
3. Vérifier les permissions RBAC

### Approval ne se déclenche pas

1. Vérifier environment est bien configuré
2. Vérifier reviewers sont assignés
3. Vérifier branch protection sur main

### Notifications Slack ne marchent pas

1. Vérifier SLACK_WEBHOOK URL
2. Vérifier webhook n'a pas expiré
3. Vérifier permission du bot Slack

## Support

Pour plus d'aide :
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments)
- [Workflow Syntax](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions)

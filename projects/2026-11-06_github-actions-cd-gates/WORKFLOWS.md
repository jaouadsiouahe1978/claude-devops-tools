# Explications des Workflows

## 📊 Architecture des Workflows

```
┌─────────────────────────────────────────────────────────────┐
│                      CODE PUSH                              │
└──────────────────────┬──────────────────────────────────────┘
                       │
         ┌─────────────┼─────────────┐
         │             │             │
    ┌────▼──┐    ┌────▼──┐    ┌────▼──┐
    │ main  │    │develop│    │feature│
    └────┬──┘    └────┬──┘    └────┬──┘
         │            │            │
         │     ┌──────┴──────┐    │
         │     │             │    │
      ┌──▼────▼──┐      ┌────▼────┐
      │  CI.yml  │      │CI + Review
      │(lint,   │      │(full checks)
      │test,    │      └───┬──────┘
      │build)   │          │
      └────┬─────┘    ┌─────▼─────┐
           │          │ PR Merge? │
      ┌────▼──────┐   └─────┬─────┘
      │ All Pass? │         │
      └────┬──────┘    ┌────▼──────┐
           │           │           │
        ┌──▼────┐   ┌──▼────┐   ┌──▼──┐
        │Staging│   │ Prod  │   │Skip │
        │Deploy │   │(wait) │   │     │
        └───────┘   └───┬───┘   └─────┘
                        │
                    ┌───▼───────┐
                    │ Approval  │
                    │ Required  │
                    └───┬───────┘
                        │
                    ┌───▼───────────┐
                    │ Blue-Green    │
                    │ Production    │
                    │ Deploy        │
                    └───────────────┘
```

## 1️⃣ CI.yml - Continuous Integration

### Événements Déclencheurs
```yaml
on:
  push:
    branches: [ main, develop, feature/** ]
  pull_request:
    branches: [ main, develop ]
```

### Jobs

#### **lint** 
- Vérifie la qualité du code avec ESLint
- Non-bloquant (permet de continuer même si échoue)
- Rapide (~2-3 min)

#### **test**
- Exécute les tests unitaires
- Dépend de `lint` (attendre avant de lancer)
- Upload la couverture de code vers Codecov
- ~3-5 min

#### **build**
- Build l'image Docker avec Docker Buildx
- Multi-plateforme support (amd64, arm64, armv7)
- Cache optimisé avec GitHub Actions cache
- Push vers Docker Hub (sauf PRs)
- ~5-10 min

#### **security**
- Scan des vulnérabilités avec Trivy
- Upload les résultats vers GitHub Security tab
- Ne tourne que sur les branches (pas les PRs)
- ~2-3 min

### Outputs
- `image-tag` : Le tag de l'image built

### Durée Totale
- **Feature PR** : ~15-20 min (jusqu'à test)
- **Merge develop** : ~20-30 min (tous les jobs)

---

## 2️⃣ CD-Staging.yml - Automatic Staging Deployment

### Événements Déclencheurs
```yaml
on:
  push:
    branches: [develop]
```

**Déclenché automatiquement** quand on push sur `develop`

### Jobs

#### **deploy-staging**
1. **Récupère le tag** de l'image buildée
2. **Se connecte** à Docker Hub
3. **Configure kubeconfig** en Kubernetes
4. **Met à jour** le deployment staging avec nouvelle image
5. **Attend** que tous les pods soient ready (rollout status)
6. **Tests de smoke** (vérifications basiques)
7. **Envoie notification** Slack

### Variables
```
Environment: staging
URL: https://staging.myapp.example.com
Kubeconfig Secret: KUBE_CONFIG_STAGING
```

### Durée
- ~8-12 min

### Résultat
- ✅ Service staging à jour
- 📬 Notification Slack envoyée

---

## 3️⃣ CD-Production.yml - Manual Approval Production Deployment

### Événements Déclencheurs
```yaml
on:
  push:
    branches: [main]
  push:
    tags: ['v*']
```

**Déclenché** quand on push sur `main` ou crée un tag `v*`

### Protection
- **Environnement production configuré** avec approvers requis
- GitHub **demande manuellement l'approbation**
- Onglet "Deployments" affiche déploiement en attente

### Jobs

#### **prepare**
- Génère un tag d'image unique
- Crée un artifact "deployment record" pour audit
- ~1 min

#### **deploy-production**
**Attend l'approbation manuelle** avant de démarrer

1. **Télécharge** le deployment record
2. **Se connecte** à Docker Hub
3. **Fait des pré-checks** :
   - Migrations DB
   - Health checks staging
   - Backup état courant
4. **Déploiement Blue-Green** :
   - Déploie nouvelle version (blue)
   - Attend readiness
   - Switch traffic depuis green vers blue
   - Réduit replicas green à 0
5. **Validations post-deploy** :
   - Vérifie tous les pods sains
   - Smoke tests production
6. **Envoie notifications** Slack

### Variables
```
Environment: production
URL: https://myapp.example.com
Kubeconfig Secret: KUBE_CONFIG_PROD
Déploiement Strategy: Blue-Green
```

### Approbation

Pour approver :
1. Aller dans `GitHub > Deployments`
2. Trouver le déploiement en attente
3. Cliquer "Review deployments"
4. Sélectionner reviewers
5. Approver ou Rejeter

### Durée
- Attente approval : Déterminé par reviewer
- Déploiement : ~10-15 min
- Total : 15-20+ min (+ attente)

### Résultat
- ✅ Service production à jour
- 🔄 Zero-downtime avec Blue-Green
- 📬 Notification Slack
- 📋 Record d'audit créé

---

## 4️⃣ Matrix-Build.yml - Multi-Platform Builds

### Événements Déclencheurs
```yaml
on:
  workflow_dispatch  # Manuel via UI
  push:
    branches: [main]
    paths: ['src/**', 'Dockerfile']
```

**Manuel ou auto** sur changement de code

### Strategy Matrix

```yaml
platform:
  - linux/amd64
  - linux/arm64  
  - linux/arm/v7

node-version:
  - '16'
  - '18'
  - '20'
```

**Combinaisons** : 3 platforms × 3 versions = 9 builds parallèles

### Exclusions
```yaml
exclude:
  - node-version: '16'
    platform: linux/arm/v7  # Pas de Node 16 sur ARM v7
```

### Jobs

#### **build-matrix**
Pour chaque combinaison :
1. Build l'image Docker
2. Push avec tag `node-18-main`, `node-20-main`, etc.
3. Cache les couches
4. Crée un JSON report

- **Parallélisme** : Tous les builds en même temps
- **Durée** : ~10-15 min (tous les builds)

#### **summarize**
Après tous les builds :
1. Télécharge tous les reports
2. Génère résumé dans GitHub summary
3. Envoie notification Slack

### Résumé Généré
```
| Platform | Node Version | Status |
|----------|--------------|--------|
| linux/amd64 | 18 | ✅ |
| linux/amd64 | 20 | ✅ |
| linux/arm64 | 18 | ✅ |
...
```

### Durée
- ~15-20 min total

---

## 📊 Flux Complet de Déploiement

### Scénario 1 : Feature → Develop → Staging

```
1. $ git checkout -b feature/cool-feature
2. $ git push origin feature/cool-feature
   ↓
   GitHub déclenche: CI.yml
   - Lint ✓
   - Test ✓
   - Build ✓
   - Security ✓
   ↓
3. Create Pull Request sur develop
4. Reviewers regardent le code
5. $ git merge feature/cool-feature
   ↓
   Push sur develop automatique
   ↓
   GitHub déclenche: CD-Staging.yml
   - Deploy automatique ✓
   - Tests smoke ✓
   ↓
6. Staging à jour et testé ✓
```

### Scénario 2 : Release → Main → Production

```
1. Tests en staging confirmés
2. $ git checkout main
3. $ git merge develop
4. $ git push origin main
   ↓
   GitHub déclenche: CI.yml
   - Lint ✓
   - Test ✓
   - Build ✓
   - Security ✓
   ↓
   GitHub déclenche: CD-Production.yml (prepare)
   - Crée artifact
   - Attends approbation...
   ↓
5. ⏳ Deployment PENDING en GitHub
   Onglet "Deployments" → Attente
   ↓
6. Reviewers regardent et approuvent
   ↓
   Deploy job continue
   - Pre-checks ✓
   - Blue-Green deploy ✓
   - Validation ✓
   ↓
7. Production à jour ✓
```

---

## 🔄 Conditions et Workflows

### Si tout passe CI
- ✅ Status checks verts
- ✅ Peut merger vers develop

### Si merge sur develop
- ✅ CD-Staging se déclenche
- ✅ Auto-deploy staging
- ✅ Pas d'approbation nécessaire

### Si merge sur main
- ✅ CI.yml se déclenche
- ✅ CD-Production se prépare
- ⏳ **ATTENDS approbation**
- ❌ Prod deploy échoue si rejeté

### Si deploy échoue
- ❌ Slack notifie
- 🔄 Rollback possible via `git revert`
- 📋 Logs disponibles dans Actions

---

## 🛡️ Protections et Vérifications

### Branch Protection
```
main :
  ✅ PR requise avant merge
  ✅ Status checks requis
  ✅ 1 approbation requise
  ✅ Approver différent du pusheur

develop :
  ✅ PR requise avant merge
  ✅ Status checks requis (lint, test, build)
```

### Environment Protection
```
staging :
  ✅ Status checks requis
  ✅ Approbateurs optionnels

production :
  ✅ **1 approbateur requis**
  ✅ **Self-review bloqué**
  ✅ Peut avoir wait timer (5 min)
```

### Secrets
```
Tous les secrets cryptés
Pas affichés dans logs
Disponibles seulement aux jobs autorisés
```

---

## 📈 Monitoring et Alertes

### Status Checks
- Chaque job rapporte son status
- Requis avant merge en main/develop
- Échoué = merge bloqué

### Notifications Slack
```
✅ Build réussi       → Pas de notif (silent success)
❌ Build échoué       → Notif immédiate
✅ Deploy staging ok  → Notif de succès
✅ Deploy prod ok     → Notif de succès + mentions
❌ Deploy échoué      → Notif d'erreur urgente
```

### Artifacts
- Build reports conservés 90j
- Deployment records archivés
- Coverage reports disponibles

---

## 🎯 Best Practices Intégrées

1. ✅ **Multi-stage** : Dev → Staging → Prod
2. ✅ **Automation** : Staging auto, Prod manuel
3. ✅ **Security** : Scans, secrets protégés, audit logs
4. ✅ **Zero-downtime** : Blue-Green deployment
5. ✅ **Rollback** : Via git revert (rapide)
6. ✅ **Notification** : Slack pour visibilité
7. ✅ **Cache** : Optimization pour vitesse
8. ✅ **Multi-plateforme** : ARM support inclus

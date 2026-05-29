# 🎯 Best Practices - GitHub Actions

## 1. Sécurité des Secrets

### ❌ NE JAMAIS FAIRE

```yaml
- name: Deploy
  run: |
    echo "TOKEN=my-secret-token" >> $GITHUB_ENV  # DANGEREUX !
    curl -H "Authorization: Bearer my-secret-token" ...  # VISIBLE DANS LES LOGS !
```

### ✅ À FAIRE

```yaml
- name: Deploy
  env:
    DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}  # Chiffré dans GitHub
  run: curl -H "Authorization: Bearer $DEPLOY_TOKEN" ...
```

**Règle d'or :** Les logs GitHub Actions sont publics (pour repos publics), ne commitez JAMAIS de secrets.

## 2. Structure des Workflows

### ❌ Un seul grand job

```yaml
jobs:
  everything:
    runs-on: ubuntu-latest
    steps:
      - run: npm lint
      - run: npm test
      - run: docker build
      - run: docker push
      - run: kubectl deploy
```

**Problèmes :**
- Si un step échoue, tous les suivants échouent
- Pas de parallélisation
- Difficile à déboguer

### ✅ Multiples jobs indépendants

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - run: npm lint
  
  test:
    runs-on: ubuntu-latest
    steps:
      - run: npm test
  
  build:
    runs-on: ubuntu-latest
    needs: [lint, test]  # Attend que lint + test passent
    steps:
      - run: docker build
      - run: docker push
```

**Avantages :**
- Lint et test en parallèle (plus rapide)
- Build attend que les tests passent
- Facile à voir quel job échoue

## 3. Caching pour Rapidité

### ❌ Sans cache

```yaml
- run: npm install  # ~30 secondes chaque fois
```

### ✅ Avec cache

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '18'
    cache: 'npm'  # Cache automatiquement node_modules
```

Ou cache Docker :

```yaml
- uses: docker/build-push-action@v5
  with:
    cache-from: type=gha  # Cache GitHub Actions
    cache-to: type=gha,mode=max  # Stocke le cache
```

**Résultat :** npm install passe de 30s à 3s, Docker build de 2min à 20s.

## 4. Conditions et Contrôle de Flux

### ❌ Toujours exécuter (même si tests échouent)

```yaml
- name: Deploy
  run: kubectl deploy ...  # S'exécute même si tests échouent !
```

### ✅ Exécuter conditionnellement

```yaml
- name: Deploy
  if: success() && github.ref == 'refs/heads/main'
  run: kubectl deploy ...

- name: Notify on failure
  if: failure()  # S'exécute que si steps précédentes échouent
  run: curl -X POST https://hooks.slack.com ...
```

**Conditions utiles :**
- `if: success()` : Tous les steps avant étaient OK
- `if: failure()` : Au moins un step a échoué
- `if: always()` : Toujours (succès ou échec)
- `if: github.ref == 'refs/heads/main'` : Seulement sur main
- `if: github.event_name == 'pull_request'` : Seulement sur PR
- `if: startsWith(github.ref, 'refs/tags/')` : Seulement sur tags

## 5. Artifacts et Transfert de Données

### ❌ Recalculer à chaque job

```yaml
jobs:
  build:
    steps:
      - run: npm run build  # Construit l'app

  deploy:
    steps:
      - run: npm run build  # Reconstruit inutilement !
      - run: kubectl deploy ...
```

### ✅ Partager les artifacts

```yaml
jobs:
  build:
    steps:
      - run: npm run build
      - uses: actions/upload-artifact@v3
        with:
          name: app-dist
          path: dist/

  deploy:
    needs: build
    steps:
      - uses: actions/download-artifact@v3
        with:
          name: app-dist
      - run: kubectl deploy ...  # Utilise le build du job précédent
```

**Avantages :**
- Build uniquement une fois
- Garantit que prod utilise exactement ce qui a été testé
- Plus rapide

## 6. Matrix Builds (Tester sur plusieurs versions)

### ✅ Tester Node 16, 18, 20 en parallèle

```yaml
test:
  strategy:
    matrix:
      node-version: [16.x, 18.x, 20.x]
      os: [ubuntu-latest, windows-latest]
  runs-on: ${{ matrix.os }}
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
    - run: npm test
```

**Résultat :** 6 exécutions parallèles (3 Node × 2 OS), pas 6 séquentielles.

Utilisation des données matrix :
- `${{ matrix.node-version }}` : Accède à la valeur
- Logs groupés par combinaison
- Facile de voir sur quelle version ça casse

## 7. Continuer même en cas d'erreur

### ❌ S'arrêter au premier problème

```yaml
- run: npm audit  # Si des vulns trouvées, tout s'arrête
- run: npm test   # N'exécute pas si npm audit échoue
```

### ✅ Continuer mais reporter

```yaml
- name: Security audit
  run: npm audit --audit-level=moderate || true
  continue-on-error: true  # Continue même si échoue

- run: npm test  # S'exécute quand même
```

**Quand l'utiliser :**
- Tâches non-bloquantes (audit, linting optionnel)
- Notifications (ne pas bloquer le workflow)
- Feedback mais pas critique

## 8. Environment Variables vs Secrets

### ✅ Variables non-sensibles

```yaml
env:
  NODE_ENV: production
  LOG_LEVEL: info
```

Accès dans les logs OK : ce ne sont pas des secrets.

### ✅ Secrets sensibles

```yaml
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}  # Jamais dans les logs
  API_TOKEN: ${{ secrets.API_TOKEN }}
```

GitHub masque automatiquement les secrets dans les logs avec `***`.

## 9. Reusable Workflows (DRY)

### ❌ Dupliquer le même code

```yaml
# ci.yml
- run: npm install
- run: npm test

# deploy.yml
- run: npm install
- run: npm test
- run: npm run build
```

### ✅ Workflow réutilisable

```yaml
# .github/workflows/test.yml
name: Run tests
on:
  workflow_call:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm test
```

Puis dans `ci.yml` et `deploy.yml` :

```yaml
jobs:
  test:
    uses: ./.github/workflows/test.yml
```

## 10. Documentation des Workflows

### ✅ Ajouter des commentaires explicatifs

```yaml
name: CI Pipeline
description: |
  Tests, linting, and Docker build for production deployment
  - Runs on: push to main/develop, all PRs
  - Requires: Node 18+, npm cache
  - Outputs: Docker image in GHA cache

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint:
    # Check code quality with ESLint
    runs-on: ubuntu-latest
    steps:
      ...
```

## Checklist Sécurité

- [ ] Pas de secrets en clair dans les fichiers
- [ ] Tous les secrets stockés dans GitHub Secrets
- [ ] Workflows vérifiés et pinned (v4, pas @main)
- [ ] Permissions minimales (least privilege)
- [ ] Audit régulier des actions tierces
- [ ] Dépendances npm régulièrement mises à jour
- [ ] Image Docker basée sur version stable (pas latest)
- [ ] Tests en place avant déploiement
- [ ] Approbations pour déploiement production

## Checklist Performance

- [ ] Caching activé (npm, Docker)
- [ ] Jobs parallèles (lint + test ensemble)
- [ ] Matrix builds (si multi-version)
- [ ] Artifact download seulement si nécessaire
- [ ] Conditions if pour skip les steps inutiles
- [ ] Runner approprié (ubuntu-latest est plus rapide)

## Ressources Utiles

- 📖 [GitHub Actions Documentation](https://docs.github.com/en/actions)
- 🔗 [Best Practices Official](https://github.blog/enterprise-2-20-github-actions-best-practices/)
- 🛒 [Actions Marketplace](https://github.com/marketplace?type=actions)
- 🔐 [Secrets Management](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

---

**Résumé en 3 points :**
1. **Sécurité d'abord** : Jamais de secrets en clair
2. **Parallélisation** : Multiples jobs pour rapidité
3. **Caching** : Réutiliser les builds précédents

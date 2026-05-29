# 🚀 Quickstart - GitHub Actions CI/CD

## ⚡ 5 minutes pour démarrer

### 1. Cloner et installer (2 min)

```bash
cd projects/2026-05-29_github-actions-cicd/
npm install
```

### 2. Exécuter les tests localement (1 min)

```bash
npm test
```

Vous devriez voir :
```
Test Suites: 1 passed, 1 total
Tests:       15 passed, 15 total
Snapshots:   0 total
```

### 3. Vérifier le linting (30 sec)

```bash
npm run lint
npm run format:check
```

### 4. Construire l'image Docker (1 min)

```bash
docker build -t devops-app:latest .
```

### 5. Tester le health check (1 min)

```bash
docker run -p 3000:3000 devops-app:latest &
sleep 2
curl http://localhost:3000/health
```

## 📋 Les 3 Workflows GitHub Actions

| Workflow | Fichier | Déclencheur | Rôle |
|----------|---------|-------------|------|
| **CI** | `.github/workflows/ci.yml` | `push` + `pull_request` | Lint, Test, Build |
| **Deploy** | `.github/workflows/deploy.yml` | `push` sur `main` | Déploie vers staging |
| **Scheduled** | `.github/workflows/scheduled-checks.yml` | `cron: 0 2 * * 1` | Scan sécurité hebdo |

## 🔍 Explorer les Workflows

### CI Workflow (`.github/workflows/ci.yml`)

5 jobs en parallèle + séquence :

```
1. Lint (ESLint + Prettier)
2. Test (Jest, Node 16/18/20)
3. Build (Docker, si main)
4. Security (npm audit + Trivy)
5. Notify (Slack, si échec)
```

**Points clés :**
- `matrix.node-version` : Teste sur 3 versions Node simultanément
- `needs: [lint, test]` : Build attend que lint + test passent
- `if: github.ref == 'refs/heads/main'` : Build seulement sur main
- `continue-on-error: true` : Certains steps échouent sans arrêter

### Deploy Workflow (`.github/workflows/deploy.yml`)

```
1. Checkout code
2. Download Docker image (artifact du CI)
3. Load l'image et déploie
4. Smoke tests
```

**À noter :**
- `environment: staging` : Nécessite approbation en GitHub
- Utilise `secrets.DEPLOY_TOKEN` : Chiffré
- `workflow_dispatch` : Permet un lancement manuel

### Scheduled Checks (`.github/workflows/scheduled-checks.yml`)

```
1. npm audit (chaque lundi 2 AM)
2. Vérifier packages outdated
3. Trivy container scan
```

## 🎓 Exercices pour approfondir

### Exercice 1 : Ajouter une condition

Modifiez `ci.yml` pour que Docker build s'exécute AUSSI sur les tags :

```yaml
if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/'))
```

### Exercice 2 : Ajouter une notification Slack

Remplacez le token Slack et décommentez la step dans `ci.yml` :

```yaml
- uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
```

### Exercice 3 : Ajouter un coverage badge

Modifiez `ci.yml` pour envoyer la coverage à Codecov :

```yaml
- uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
```

### Exercice 4 : Matrice OS

Testez sur Ubuntu + Windows + macOS :

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
runs-on: ${{ matrix.os }}
```

## 📊 Dashboard des Workflows

Après avoir poussé à GitHub, allez à :

```
https://github.com/YOUR_USERNAME/YOUR_REPO/actions
```

Vous verrez :
- ✅ **Run history** : tous les builds
- 📊 **Job duration** : combien de temps chaque job prend
- 🔴 **Failed runs** : pour déboguer
- ⏱️ **Execution time** : optimiser le pipeline

## 🔐 Secrets GitHub

Pour utiliser des secrets dans vos workflows :

1. **Settings → Secrets and variables → Actions**
2. Cliquez "New repository secret"
3. Ajoutez :
   - `DEPLOY_TOKEN` : Token de déploiement
   - `DOCKER_HUB_TOKEN` : Token Docker Hub
   - `SLACK_WEBHOOK` : URL Slack webhook

Puis, dans le workflow :

```yaml
env:
  SECRET_VALUE: ${{ secrets.DEPLOY_TOKEN }}
```

## 🛠️ Debugging

Si un workflow échoue, consultez les **logs** :

1. Allez dans l'onglet **Actions**
2. Cliquez sur le run échoué
3. Expandez le job problématique
4. Lisez les logs détaillés

**Tips :**
- Utilisez `echo` pour déboguer
- Ajouter `set -x` pour voir toutes les commandes exécutées
- Utilisez `if: runner.debug == 'true'` pour logs debug conditionnels

## 🚀 Prochaines étapes

1. **Créer une PR** et regarder le CI s'exécuter
2. **Ajouter des secrets** et les utiliser
3. **Configurer le déploiement** réel (remplacer le placeholder)
4. **Ajouter Slack/email** notifications
5. **Optimiser le cache** Docker pour gagner du temps

## 📚 Ressources utiles

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)
- [Jest Testing Docs](https://jestjs.io/docs/getting-started)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

**Durée totale :** 5 min de setup + 30-45 min d'exploration  
**Prérequis :** Git, Docker (optionnel)  
**Niveau :** Débutant absolument bienvenue

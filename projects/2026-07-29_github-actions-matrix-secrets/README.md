# GitHub Actions: Matrix Jobs & Secrets Management

## Description

Ce projet démontre les capacités avancées de GitHub Actions pour CI/CD moderne :
- **Matrix Jobs** : exécuter des tests sur plusieurs versions (Python, Node, Java)
- **Secrets Management** : gérer les credentials de manière sécurisée
- **Environment Variables** : configurer des variables selon l'environnement (dev, staging, prod)
- **Build Matrix** : construire des artefacts pour plusieurs OS (Ubuntu, macOS, Windows)
- **Conditional Steps** : exécuter des étapes selon des conditions
- **Artifacts** : uploader et télécharger des artefacts de build

## Objectifs d'apprentissage

- Créer des workflows GitHub Actions efficaces et réutilisables
- Utiliser les matrix jobs pour tester du code sur plusieurs configurations
- Gérer les secrets et les credentials de manière sécurisée
- Implémenter des pipelines de build et test multi-plateforme
- Utiliser les artefacts pour le CI/CD

## Technos

- GitHub Actions
- Matrix Jobs
- Secrets & Environment Secrets
- Python 3.x, Node.js 18+
- Docker (optionnel)

## Pré-requis

- Accès à un repository GitHub (avec Actions activé)
- Connaissance basique de YAML
- Connaissance basique de CI/CD

## Étapes de réalisation

### 1. Créer les workflows GitHub Actions

#### 1.1 Test Matrix avec Python et Node
Workflow multi-langage qui teste le code sur plusieurs versions

```yaml
name: Multi-Language Matrix Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        language: [python, node]
        version: ['3.9', '3.11']  # Python versions
    steps:
      - uses: actions/checkout@v4
      - name: Setup Python
        if: matrix.language == 'python'
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.version }}
      - name: Run Python Tests
        if: matrix.language == 'python'
        run: |
          python -m pip install -r requirements.txt
          python -m pytest tests/
```

#### 1.2 Secrets Management Workflow
Workflow qui utilise des secrets et variables d'environnement

```yaml
name: Deploy with Secrets
on: [workflow_dispatch]
env:
  REGISTRY: docker.io
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - name: Login to Docker Registry
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
      - name: Deploy Application
        run: |
          echo "Deploying to ${{ vars.DEPLOY_ENDPOINT }}"
          echo "Using API key: ${API_KEY:0:5}***"
        env:
          API_KEY: ${{ secrets.API_KEY }}
```

#### 1.3 Multi-Platform Build Matrix
Workflow qui construit des artefacts pour plusieurs OS

```yaml
name: Multi-Platform Build
on: [push, workflow_dispatch]
jobs:
  build:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        node-version: [18, 20]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm install
      - run: npm run build
      - uses: actions/upload-artifact@v3
        with:
          name: build-${{ matrix.os }}-${{ matrix.node-version }}
          path: dist/
```

### 2. Créer les fichiers de test

#### 2.1 Tests Python
```python
# tests/test_app.py
def add(a, b):
    return a + b

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
```

#### 2.2 Tests Node/JavaScript
```javascript
// tests/app.test.js
function add(a, b) {
  return a + b;
}

test('add', () => {
  expect(add(2, 3)).toBe(5);
});
```

### 3. Configurer les Secrets et Variables

```bash
# Dans GitHub :
# Settings > Secrets and variables > Actions

# Repository Secrets:
- DOCKER_USERNAME
- DOCKER_PASSWORD
- API_KEY

# Repository Variables:
- DEPLOY_ENDPOINT
- REGISTRY
```

### 4. Conditions et Conditional Steps

```yaml
name: Conditional Deployment
on: [push]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Dev
        if: github.ref == 'refs/heads/develop'
        run: echo "Deploying to DEV"
      - name: Deploy to Prod
        if: github.ref == 'refs/heads/main'
        run: echo "Deploying to PROD"
      - name: Run Tests on PR
        if: github.event_name == 'pull_request'
        run: npm test
```

### 5. Artefacts et Caching

```yaml
name: Build with Cache
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/cache@v3
        with:
          path: ~/.npm
          key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
      - run: npm install
      - run: npm run build
      - uses: actions/upload-artifact@v3
        with:
          name: build-output
          path: build/
          retention-days: 30
```

## Ce qu'on apprend

✅ Créer des pipelines CI/CD avec GitHub Actions
✅ Utiliser les matrix jobs pour tester sur plusieurs configurations
✅ Gérer les secrets et credentials de manière sécurisée
✅ Implémenter des workflows conditionnels
✅ Gérer les artefacts de build
✅ Comprendre les environments et les variables d'environnement
✅ Best practices en CI/CD

## Exemple complet

Le dossier `.github/workflows/` contient 3 workflows prêts à l'emploi :
1. `multi-lang-tests.yml` - Tests multi-langage avec matrix
2. `secrets-deployment.yml` - Déploiement avec gestion des secrets
3. `multi-platform-build.yml` - Build multi-plateforme

## Durée estimée

1-2 heures pour comprendre et adapter les workflows

## Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Matrix Jobs Guide](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)
- [Secrets Management](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)

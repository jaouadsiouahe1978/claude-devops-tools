# CI/CD Pipeline avec GitHub Actions

## 📋 Description
Un pipeline CI/CD complet qui teste, build et déploie automatiquement une application Python chaque fois qu'on pousse du code sur GitHub. Parfait pour apprendre GitHub Actions, l'automatisation et les bonnes pratiques DevOps.

## 🎯 Objectifs
- Comprendre les workflows GitHub Actions
- Mettre en place des tests automatisés (pytest)
- Builder une image Docker automatiquement
- Simuler un déploiement automatique
- Apprendre les secrets GitHub et les variables d'environnement

## 🛠️ Technologies
- **GitHub Actions** : Orchestration CI/CD
- **Python 3.9+** : Langage de l'application
- **pytest** : Framework de tests
- **Docker** : Containerisation de l'app
- **YAML** : Configuration des workflows

## 📦 Architecture
```
.github/workflows/
  └── ci-cd.yml          # Workflow principal

app/
  ├── app.py             # Application Flask simple
  ├── requirements.txt    # Dépendances Python
  └── tests.py           # Tests unitaires

Dockerfile              # Image Docker de l'app
```

## ✨ Ce que fait le workflow
1. **Test** : Lance pytest sur chaque push/PR
2. **Build** : Crée une image Docker
3. **Lint** : Vérifie la qualité du code avec flake8
4. **Artifact** : Archive les résultats des tests
5. **Notification** : Affiche le statut (succès/échec)

## 🚀 Étapes pour reproduire

### 1. Fork et cloner le repo
```bash
git clone https://github.com/jaouadsiouahe1978/claude-devops-tools
cd projects/2026-05-05_github-actions-cicd
```

### 2. Installer les dépendances localement
```bash
pip install -r app/requirements.txt
pip install pytest flake8
```

### 3. Tester localement
```bash
pytest app/tests.py -v
flake8 app/ --max-line-length=100
```

### 4. Builder l'image Docker
```bash
docker build -t my-app:latest .
docker run -p 5000:5000 my-app:latest
```

Puis accéder à `http://localhost:5000`

### 5. Voir le workflow GitHub
Une fois pusshé sur GitHub :
- Allez dans **Actions** du repo
- Voyez les workflows s'exécuter
- Vérifiez les logs de chaque étape

## 📊 Points clés à apprendre

| Concept | Description |
|---------|------------|
| **Trigger** | Quand le workflow s'exécute (push, pull_request) |
| **Jobs** | Tâches parallèles ou séquentielles |
| **Steps** | Actions individuelles dans un job |
| **Actions** | Composants réutilisables (setup-python, docker/build-push-action, etc.) |
| **Artifacts** | Fichiers conservés après l'exécution |
| **Secrets** | Variables sensibles (tokens, clés API) |

## 🔍 Améliorations possibles
- [ ] Ajouter une étape de déploiement vers Heroku/AWS
- [ ] Configurer des notifications Slack/Email
- [ ] Ajouter une étape de security scanning (Trivy, Snyk)
- [ ] Implémenter une matrice de tests (plusieurs versions Python)
- [ ] Ajouter une couverture de code (coverage)
- [ ] Publier l'image Docker sur Docker Hub/GitHub Container Registry

## 📚 Ressources
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Python testing with pytest](https://docs.pytest.org/)
- [Docker best practices](https://docs.docker.com/develop/dev-best-practices/)

## ⏱️ Temps estimé : 1-2h pour maîtriser les concepts

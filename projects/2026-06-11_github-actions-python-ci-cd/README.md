# GitHub Actions + Python CLI - Projet CI/CD Complet

## 📌 Objectif
Mettre en place une pipeline CI/CD complète avec **GitHub Actions** pour une application Python CLI :
- ✅ Tests automatiques (pytest)
- ✅ Linting & code quality (pylint, black)
- ✅ Build & package (wheel)
- ✅ Déploiement sur GitHub Releases
- ✅ Notifications de succès/erreur

## 🛠️ Technos utilisées
- **GitHub Actions** : orchestration CI/CD
- **Python 3.11+** : langage
- **pytest** : tests unitaires
- **pylint & black** : qualité code
- **setuptools** : packaging
- **GitHub API** : release management

## 📋 Prérequis
- Compte GitHub avec repository
- Python 3.11+
- Git installé localement
- Accès aux secrets GitHub (pour les tokens)

## 🚀 Étapes de réalisation

### 1. Structure du projet
```
.
├── .github/workflows/
│   ├── ci.yml              # Tests et linting
│   ├── release.yml         # Création de releases
│   └── notify.yml          # Notifications
├── src/
│   ├── __init__.py
│   └── cli.py              # Application CLI
├── tests/
│   ├── __init__.py
│   └── test_cli.py         # Tests unitaires
├── setup.py                # Configuration package
├── requirements.txt        # Dépendances
├── pyproject.toml         # Config Python moderne
└── .pylintrc              # Config linting
```

### 2. Workflow d'installation locale
```bash
git clone <repo>
cd projects/2026-06-11_github-actions-python-ci-cd
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install -e .
```

### 3. Exécuter les tests en local
```bash
pytest tests/ -v
pylint src/
black --check src/ tests/
```

### 4. Créer une release
- Tagger un commit : `git tag v1.0.0`
- Pusher le tag : `git push origin v1.0.0`
- GitHub Actions crée automatiquement une release avec le package

### 5. Workflow GitHub Actions
| Trigger | Action |
|---------|--------|
| **Push sur main** | Tests + Linting |
| **Pull Request** | Tests + Linting |
| **Git Tag (v\*)** | Build + Release + Notifications |

## 📚 Ce qu'on apprend

### DevOps
- ✅ Orchestration CI/CD avec GitHub Actions
- ✅ Gestion des secrets et tokens
- ✅ Automatisation du testing et code review
- ✅ Versioning sémantique et releases
- ✅ Notifications automatisées

### Python & Best Practices
- ✅ Structure projet Python professionnel
- ✅ Testing (pytest, fixtures, assertions)
- ✅ Code quality (pylint, black, type hints)
- ✅ Packaging et distribution (wheel, sdist)
- ✅ Configuration (setup.py, pyproject.toml)

## 🔄 Exemples d'utilisation

### Installer et utiliser le CLI
```bash
pip install .
weather --help
weather -c Paris
```

### Tester en local
```bash
pytest tests/ -v --cov=src
```

### Générer un rapport de couverture
```bash
pytest --cov=src --cov-report=html tests/
# Ouvre htmlcov/index.html
```

## 📊 Dashboard GitHub Actions
Accédez à : `https://github.com/<user>/<repo>/actions`
- Visualisez tous les workflows
- Consultez les logs détaillés
- Relancez des jobs manuellement

## 🎓 Points clés à retenir

1. **Actions réutilisables** : les workflows peuvent être paramétrés
2. **Secrets sécurisés** : jamais de creds en plaintext
3. **Matrice d'exécution** : tester sur Python 3.9, 3.10, 3.11
4. **Cache** : accélère les dépendances (pip cache, docker layers)
5. **Artifacts** : collecte des résultats (reports, logs, packages)

## 🚨 Troubleshooting

### Les tests échouent en CI mais passent localement
→ Vérifier la version Python, les chemins absolus/relatifs

### Workflow bloqué avec "Permission denied"
→ Vérifier `Settings > Actions > General > Workflow permissions`

### Release ne se crée pas
→ Vérifier le format du tag (doit matcher `v*`)
→ Vérifier les permissions du token GitHub

## 📚 Ressources
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Python Testing Best Practices](https://docs.pytest.org/)
- [Semantic Versioning](https://semver.org/)
- [Python Packaging Guide](https://packaging.python.org/)

---

**Créé** : 2026-06-11  
**Niveau** : Débutant à Intermédiaire  
**Durée estimée** : 4-6 heures  
**Prérequis** : Notions de Git, Python, et shell

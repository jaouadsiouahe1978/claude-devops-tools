# ⚡ Quick Start Guide

## 🚀 Démarrage en 5 minutes

### 1. Cloner et entrer dans le projet
```bash
cd projects/2026-06-11_github-actions-python-ci-cd
```

### 2. Créer un environnement virtuel
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate  # Windows
```

### 3. Installer les dépendances
```bash
pip install -r requirements.txt
pip install -e .
```

### 4. Tester le CLI
```bash
# Afficher l'aide
weather --help

# Lister les villes disponibles
weather --list

# Obtenir la météo d'une ville
weather -c paris

# Format JSON
weather -c paris -j
```

## 🧪 Exécuter les tests

```bash
# Tests simples
pytest tests/ -v

# Avec couverture
pytest tests/ -v --cov=src

# Reporter HTML
pytest tests/ -v --cov=src --cov-report=html
# Ouvre ensuite : htmlcov/index.html
```

## 📝 Qualité du code

```bash
# Vérifier le formatage (Black)
black --check src/ tests/

# Formater automatiquement
black src/ tests/

# Linting (Pylint)
pylint src/

# Type checking (Mypy)
mypy src/
```

## 📦 Créer un package

```bash
# Build wheel et sdist
python -m build

# Vérifier les fichiers créés
ls -la dist/
```

## 🔄 Workflow de développement

### Créer une branche feature
```bash
git checkout -b feature/my-feature
```

### Faire les changements et tester
```bash
# Modifier le code
vim src/cli.py

# Tester localement
pytest tests/

# Formater
black src/ tests/

# Vérifier
pylint src/
```

### Commit et push
```bash
git add .
git commit -m "feat: add new weather feature"
git push origin feature/my-feature
```

### Créer une PR sur GitHub
→ GitHub Actions lancera automatiquement les tests !

### Créer une release
```bash
# Tagger une version
git tag -a v1.1.0 -m "Release v1.1.0"

# Pusher le tag
git push origin v1.1.0
```
→ GitHub Actions créera automatiquement la release !

## 🐛 Troubleshooting

**Les tests échouent en CI mais passent localement ?**
```bash
# Vérifier la version Python
python --version

# Supprimer le cache
rm -rf __pycache__ .pytest_cache
pytest tests/
```

**ModuleNotFoundError pour `src` ?**
```bash
# Réinstaller en mode dev
pip install -e .
```

**Black se plaint du formatage ?**
```bash
# Formater automatiquement
black src/ tests/
git add .
git commit -m "style: format code"
```

## 📚 Fichiers importants

| Fichier | Rôle |
|---------|------|
| `.github/workflows/ci.yml` | Pipeline de test principal |
| `.github/workflows/release.yml` | Création automatique de releases |
| `tests/test_cli.py` | Suite de tests complète |
| `setup.py` | Configuration du package |
| `pyproject.toml` | Config moderne Python |

## 🎯 Points clés

✅ **Tests à chaque commit** : pipeline CI automatique  
✅ **Versioning sémantique** : utilisez des tags `v*`  
✅ **Code de qualité** : linting et formatage forcés  
✅ **Couverture** : objectif >80%  
✅ **Multi-Python** : testez 3.9, 3.10, 3.11  

---

**Besoin d'aide ?** Consultez le `README.md` pour plus de détails.

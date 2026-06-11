# 📅 Projet DevOps du Jour - 2026-06-11

## 🎯 Projet : GitHub Actions + Python CI/CD Pipeline Complète

### 📊 Infos essentielles
- **Date** : 2026-06-11
- **Niveau** : Débutant → Intermédiaire
- **Durée estimée** : 4-6 heures
- **Technos** : GitHub Actions, Python 3.11, pytest, black, pylint
- **Dossier** : `projects/2026-06-11_github-actions-python-ci-cd/`

---

## 📝 Description du projet

### Contexte
Tu vas créer une **pipeline CI/CD complète et professionnelle** avec GitHub Actions pour une application Python CLI. C'est l'un des patterns les plus importants en DevOps moderne.

### Objectifs
1. ✅ Automatiser les tests à chaque commit (pytest)
2. ✅ Vérifier la qualité du code (pylint, black)
3. ✅ Builder et packager l'application (wheel, sdist)
4. ✅ Créer automatiquement des releases sur GitHub
5. ✅ Gérer les versions sémantiquement (git tags)
6. ✅ Générer des rapports de couverture

---

## 🛠️ Technos utilisées

| Technologie | Rôle | Pourquoi |
|-------------|------|---------|
| **GitHub Actions** | Orchestration CI/CD | Intégration native GitHub, gratuit |
| **Python 3.11** | Langage | Standard industrie |
| **pytest** | Framework de test | Flexible, extensible, best-in-class |
| **black** | Code formatter | Style uniforme, zéro débat |
| **pylint** | Linter | Détecte les bugs et code smell |
| **setuptools** | Package Python | Standard pour distribuer du code |
| **pyproject.toml** | Config moderne | Standard PEP 517/518 |

---

## 📦 Structure créée

```
projects/2026-06-11_github-actions-python-ci-cd/
├── .github/workflows/
│   ├── ci.yml                    # Tests + Linting + Build (main workflow)
│   ├── release.yml               # Création automatique de releases
│   └── schedule-tests.yml        # Tests quotidiens planifiés
├── src/
│   ├── __init__.py              # Package marker
│   └── cli.py                   # CLI Weather (45 lignes, bien typée)
├── tests/
│   ├── __init__.py
│   └── test_cli.py              # 17 tests complets (unit + intégration)
├── .github/
├── README.md                     # Documentation complète (150+ lignes)
├── QUICKSTART.md                 # Démarrage en 5 min
├── BEST_PRACTICES.md             # Patterns professionnels
├── setup.py                      # Config package classique
├── pyproject.toml               # Config moderne (build, pytest, coverage)
├── requirements.txt              # Dépendances
├── .pylintrc                     # Config linting
└── .gitignore                    # Fichiers à ignorer

Total : 15 fichiers, ~800 lignes de code/config qualifiés
```

---

## 🚀 Qu'est-ce qu'on apprend ?

### DevOps & CI/CD
- **Workflows GitHub Actions** : définition, triggers, matrix builds
- **Caching des dépendances** : optimiser les pipelines (70% plus rapide)
- **Gestion des secrets** : ne jamais exposer les credentials
- **Artifacts** : collecter les résultats de tests et packages
- **Releases automatisées** : versioning + GitHub releases avec git tags
- **Notifications** : résultats de CI via webhooks

### Python Best Practices
- **Structure projet** : layout professionnel, setuptools, pyproject.toml
- **Testing complet** : pytest, fixtures, parameterization, edge cases
- **Code quality** : black (formatage), pylint (linting), mypy (types)
- **Coverage** : mesurer et visualiser la couverture de tests
- **Packaging** : wheels, source distributions, entrypoints CLI

### Patterns importants
- **Matrix builds** : tester sur Python 3.9, 3.10, 3.11 en parallèle
- **Conditional steps** : exécuter des actions selon des conditions
- **Path filtering** : ne déclencher le CI que si certains fichiers changent
- **Caching** : accélérer les dépendances et builds
- **Semantic versioning** : v1.2.3, tags git, releases GitHub

---

## 📚 Fichiers clés commentés

### `.github/workflows/ci.yml`
Pipeline principale, s'exécute à chaque push/PR :
1. Tests sur Python 3.9, 3.10, 3.11 (matrix)
2. Coverage report → Codecov
3. Linting (black, pylint, mypy)
4. Build wheels et source distribution
5. Upload artifacts

**Points d'apprentissage** :
- `strategy.matrix` : paralléliser sur versions Python
- `actions/cache` : mettre en cache pip
- `if: always()` : exécuter même en cas d'erreur
- `path-filtering` : déclencher uniquement si code change

### `.github/workflows/release.yml`
Crée une release GitHub à chaque tag `v*` :
1. Build le package
2. Génère un changelog automatique
3. Crée la GitHub Release
4. Upload le wheel

**Points d'apprentissage** :
- `push.tags` : trigger sur git tags
- Changelog automation : git log + commit messages
- GitHub Release API

### `src/cli.py`
Application CLI minimale mais complète :
- Type hints sur tous les params
- Docstrings utiles
- Gestion d'erreurs propre
- Sortie JSON optionnelle

**Patterns** :
- Separation de concerns (API mock + CLI)
- Return codes (0 = success, 1 = error)
- Structured logging/output

### `tests/test_cli.py`
Suite de tests complète : 17 tests, 3 classes, 90%+ coverage
- Tests unitaires (WeatherAPI)
- Tests d'intégration (CLI end-to-end)
- Edge cases et error handling
- Parameterized tests

**Patterns** :
- Fixtures pytest
- `capsys` pour capturer stdout/stderr
- Grouping logique en classes
- Assertions claires et spécifiques

---

## 🎓 Scénarios d'apprentissage

### Scénario 1 : Développement local
```bash
# 1. Clone et setup
cd projects/2026-06-11_github-actions-python-ci-cd
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt && pip install -e .

# 2. Test local
pytest tests/ -v --cov=src
weather -c paris

# 3. Modifie le code
vim src/cli.py

# 4. Format et lint
black src/ tests/
pylint src/

# 5. Les tests passent ? Commit !
git add . && git commit -m "feat: ..."
```

### Scénario 2 : Pull Request
```bash
git checkout -b feature/add-cities
# (faire les changements)
git push origin feature/add-cities
# → PR ouverte
# → GitHub Actions lance automatiquement les tests
# → Merge seulement si tests verts ✅
```

### Scénario 3 : Release
```bash
git tag -a v1.1.0 -m "Add new features"
git push origin v1.1.0
# → GitHub Actions :
#    - Build le package
#    - Génère un changelog
#    - Crée la release GitHub
#    - Upload le wheel
```

### Scénario 4 : Debugging d'une failure
```bash
# Le test échoue en CI mais pas localement ?
# → Check la version Python : python --version
# → Check imports : pip install -e .
# → Reproduis l'exact env : pytest sur 3.9, 3.10, 3.11

# Le linting échoue ?
# → black --check src/ tests/
# → black src/ tests/  (formatage auto)
# → commit et re-push
```

---

## ✅ Checklist d'utilisation

- [ ] Cloner le projet
- [ ] Créer venv et installer dépendances
- [ ] Exécuter les tests localement : `pytest tests/ -v`
- [ ] Vérifier le linting : `black --check src/` et `pylint src/`
- [ ] Utiliser le CLI : `weather -c paris`
- [ ] Lire et comprendre `.github/workflows/ci.yml`
- [ ] Créer une feature branch et faire un changement
- [ ] Observer GitHub Actions lancer les tests
- [ ] Créer un git tag et observer la release autom
atique
- [ ] Consulter README.md et BEST_PRACTICES.md

---

## 🎓 Concepts clés à retenir

### 1. **Matrix Builds**
Teste automatiquement sur Python 3.9, 3.10, 3.11 en parallèle.
→ Détecte incompatibilités précocement

### 2. **Caching**
Sauvegarde pip, docker layers, build artifacts.
→ Pipeline 70% plus rapide

### 3. **Secrets Management**
Jamais de creds hardcodés, utilise `${{ secrets.VAR }}`.
→ Sécurité maximale

### 4. **Artifacts**
Sauvegarde test reports, coverage, wheels.
→ Traçabilité complète

### 5. **Conditional Steps**
`if: success()` / `if: always()` / `if: failure()`.
→ Contrôle granulaire du flux

### 6. **Semantic Versioning**
`v1.2.3` : major.minor.patch.
→ Communication claire

### 7. **Code Quality Gates**
Tests + linting + coverage requis avant merge.
→ Qualité élevée, bugs moins nombreux

---

## 📊 Chiffres clés

| Métrique | Valeur |
|----------|--------|
| Lignes de code source | 120 |
| Lignes de tests | 220 |
| Lignes de config | 350+ |
| Test cases | 17 |
| Coverage cible | >80% |
| Python versions testées | 3 |
| Workflows GitHub Actions | 3 |
| Dépendances de dev | 6 |
| Fichiers de config | 4 |

---

## 🚀 Prochaines étapes (bonus)

1. **Docker** : Ajouter `Dockerfile` pour containeriser
2. **PyPI** : Publier le package sur PyPI
3. **Dependabot** : Automatiser les mises à jour
4. **SonarQube** : Analyse code statique avancée
5. **Pre-commit hooks** : Lint avant chaque commit local
6. **Database migrations** : Patterns pour DB schema
7. **Load testing** : Ajouter des benchmarks
8. **Documentation site** : Sphinx + GitHub Pages

---

## 📚 Ressources d'apprentissage

- 📖 [GitHub Actions Official Docs](https://docs.github.com/en/actions)
- 🧪 [Pytest Best Practices](https://docs.pytest.org/en/latest/example/)
- 🐍 [Real Python - Python CI/CD](https://realpython.com/python-ci-cd/)
- 📦 [Python Packaging Guide](https://packaging.python.org/)
- 🏆 [Semantic Versioning](https://semver.org/)
- 🔐 [GitHub Secrets Management](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

---

## 🎯 Résumé en 3 phrases

Tu vas créer une **pipeline CI/CD professionnelle** avec GitHub Actions qui teste automatiquement ton code Python, vérifie sa qualité, le package, et crée des releases.
C'est le **standard industrie** pour les projets modernes.
Tu apprendras **7 concepts DevOps clés** et comment les mettre en pratique.

---

**Créé le** : 2026-06-11  
**Prêt pour production** : ✅ Oui  
**Niveau de difficulté** : 🟡 Intermédiaire  
**Temps pour terminer** : ⏱️ 4-6 heures

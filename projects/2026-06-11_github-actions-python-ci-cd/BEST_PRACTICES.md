# 🏆 Best Practices - GitHub Actions & Python CI/CD

## 1️⃣ GitHub Actions - Patterns d'excellence

### Caching des dépendances
```yaml
- uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
    restore-keys: |
      ${{ runner.os }}-pip-
```
**Pourquoi ?** Accélère les workflows de 70-80% en évitant les re-téléchargements.

### Matrix builds pour multi-version Python
```yaml
strategy:
  matrix:
    python-version: ['3.9', '3.10', '3.11']
```
**Pourquoi ?** Détecte les incompatibilités avec différentes versions.

### Secrets management
```yaml
# ✅ BON
env:
  API_KEY: ${{ secrets.API_KEY }}

# ❌ MAUVAIS
env:
  API_KEY: "super-secret-key-123"
```
**Pourquoi ?** Les secrets sont chiffrés et jamais affichés dans les logs.

### Conditional steps
```yaml
- name: Upload coverage
  if: always()  # Même en cas d'erreur
```
**Pourquoi ?** Permet une granularité fine du contrôle de flux.

### Path filtering
```yaml
on:
  push:
    paths:
      - 'src/**'
      - 'tests/**'
```
**Pourquoi ?** N'exécute pas le CI si seul le README a changé.

## 2️⃣ Python Testing - Patterns solides

### Structure de tests
```
tests/
├── test_cli.py           # Tests du CLI
├── test_api.py          # Tests API
└── fixtures/            # Données de test
    └── weather_data.json
```
**Pourquoi ?** Facilite la maintenance et la scalabilité.

### Fixtures pytest
```python
@pytest.fixture
def sample_weather():
    return {"temp": "15°C", "condition": "Sunny"}

def test_format(sample_weather):
    result = format_weather("Paris", sample_weather)
    assert "Paris" in result
```
**Pourquoi ?** Réutilisabilité et tests DRY.

### Coverage goals
```bash
pytest --cov=src --cov-report=term-missing
# Target: >80% coverage
```
**Pourquoi ?** Détecte le code non testé et les branches orphelines.

### Parameterized tests
```python
@pytest.mark.parametrize("city,expected", [
    ("paris", 15),
    ("london", 12),
    ("tokyo", 22),
])
def test_weather_temps(city, expected):
    weather = WeatherAPI.get_weather(city)
    assert int(weather["temp"][:-2]) == expected
```
**Pourquoi ?** Teste plusieurs scénarios avec une seule fonction.

### Edge cases
```python
def test_empty_input():
    assert WeatherAPI.get_weather("") is None

def test_case_insensitive():
    assert WeatherAPI.get_weather("PARIS") == WeatherAPI.get_weather("paris")

def test_invalid_city():
    assert WeatherAPI.get_weather("atlantis") is None
```
**Pourquoi ?** Prévient les bugs en production.

## 3️⃣ Code Quality - Standards Python

### Black formatting
```bash
# Automatiser en pre-commit hook
black src/ tests/
```
**Pourquoi ?** Élimine les débats de style, force la cohérence.

### Pylint configuration
```ini
[DESIGN]
max-line-length=88
max-args=5
max-attributes=7
```
**Pourquoi ?** Maintient la lisibilité et la complexité basse.

### Type hints
```python
def get_weather(city: str) -> Optional[Dict[str, str]]:
    """Fetch weather for a city."""
```
**Pourquoi ?** Détecte les bugs, facilite la maintenance, aide l'IDE.

### Docstrings
```python
def format_weather(city: str, data: Dict[str, str]) -> str:
    """Format weather data for display.
    
    Args:
        city: City name
        data: Weather data dictionary
        
    Returns:
        Formatted weather string
    """
```
**Pourquoi ?** Documentation intégrée, aide les développeurs.

## 4️⃣ Release Management

### Semantic Versioning
```
v1.0.0
 │ │ │
 │ │ └─ Patch (bug fixes)
 │ └─── Minor (new features)
 └───── Major (breaking changes)
```

### Git tagging
```bash
# Feature
git tag -a v1.1.0 -m "Add new features"

# Beta
git tag -a v1.1.0-beta.1 -m "Beta release"

# Hotfix
git tag -a v1.0.1 -m "Fix critical bug"
```

### Changelog automation
```yaml
- name: Generate changelog
  run: |
    git log $PREVIOUS..$CURRENT --oneline > CHANGELOG.txt
```

## 5️⃣ Dependency Management

### requirements.txt discipline
```txt
# Core
# (aucune pour ce projet basique)

# Dev & Testing
pytest>=7.0
black>=22.0
```

### Lock files (à considérer)
```bash
# pip-tools for reproducible builds
pip-compile requirements.in > requirements.txt
```

### Update strategy
- Update deps mensuellement
- Utilisez Dependabot pour les security patches
- CI must pass avant de merger les updates

## 6️⃣ Docker Integration (optional)

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN pip install -e .

ENTRYPOINT ["weather"]
```

## 7️⃣ Artifacts & Artifacts

### Upload test reports
```yaml
- uses: actions/upload-artifact@v3
  with:
    name: test-reports
    path: |
      test_results.xml
      coverage.html
```

### Download in local
```bash
gh run download <run_id> -n test-reports
```

## 🚨 Common Pitfalls

| ❌ Pitfall | ✅ Solution |
|-----------|----------|
| Hardcoded secrets | Utilisez `${{ secrets.VAR }}` |
| Pas de caching | Ajoutez `actions/cache` pour les dépendances |
| Tests non isolés | Utilisez des fixtures pytest |
| Coverage incomplet | Targetez >80%, installez pytest-cov |
| Release manuelle | Automatisez avec git tags |
| Logs exposant les secrets | Utilisez `env` et pas `echo` |

## 📊 Exemple metrics

```
Test Execution: 45s
Code Formatting: 8s
Linting: 12s
Total Pipeline: ~3 minutes

Coverage: 95%
Pylint Score: 9.5/10
Build Status: ✅
```

## 🎯 Checklist avant production

- [ ] Coverage >80%
- [ ] Tous les tests passent sur Python 3.9, 3.10, 3.11
- [ ] Pylint score >9.0
- [ ] Black formatting applied
- [ ] Docstrings sur tous les public APIs
- [ ] Type hints sur tous les parameters
- [ ] Release notes prêtes
- [ ] Changelog généré
- [ ] Secrets configurés correctement
- [ ] CI pipeline verte avant merge

---

**Ressources complémentaires**
- [GitHub Actions Best Practices](https://docs.github.com/en/actions/guides)
- [Pytest Documentation](https://docs.pytest.org/)
- [Python Code Quality](https://realpython.com/python-code-quality/)

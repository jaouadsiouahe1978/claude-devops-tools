# 🚀 Système de Génération de Projets DevOps Quotidiens

## Vue d'ensemble

Ce système génère automatiquement un nouveau projet DevOps réalisable en une journée, tous les jours, avec une rotation des thèmes pour couvrir un maximum de technologies.

## 🏗️ Architecture

```
claude-devops-tools/
├── .github/workflows/
│   └── daily-project.yml          # GitHub Action (automatisation)
├── scripts/
│   └── generate_daily_project.py  # Générateur Python
└── projects/
    ├── 2026-05-04_docker-prometheus-grafana/
    ├── 2026-05-26_prometheus-monitor/
    └── [nouveau projet chaque jour...]
```

## 🛠️ Composants

### 1. GitHub Action (`.github/workflows/daily-project.yml`)

**Déclenchement:** Automatiquement tous les jours à 09:00 UTC (11:00 CEST)

**Actions:**
- ✅ Clone du repo
- ✅ Install Python 3.11 + dépendances (requests)
- ✅ Exécute le script générateur
- ✅ Commit et push les changements
- ✅ Optionnel: déclencher manuellement avec `workflow_dispatch`

**Permissions:** Accès en écriture au repo (token GITHUB_TOKEN)

### 2. Script Générateur (`scripts/generate_daily_project.py`)

**Fonctionnalités:**

1. **Rotation des thèmes** (10 thèmes)
   - Docker & Docker Compose
   - Kubernetes
   - GitHub Actions CI/CD
   - Terraform & AWS
   - Ansible Configuration Management
   - Prometheus & Grafana
   - Bash Scripting
   - Python DevOps Tools
   - Jenkins Pipeline
   - ELK Stack Logging

2. **Création automatique** de:
   - Dossier: `projects/YYYY-MM-DD_nom-du-projet/`
   - Fichiers de configuration (Dockerfile, docker-compose.yml, etc.)
   - README.md complet avec objectifs et étapes

3. **Opérations Git**
   - `git add` du nouveau projet
   - `git commit` avec message descriptif
   - `git push` vers main

4. **Notifications** (optionnel)
   - Envoie un résumé via ntfy.sh
   - Topic: `https://ntfy.sh/jaouad-devops-veille`

## 📋 Thèmes en rotation

| Jour | Thème | Technologies |
|------|-------|--------------|
| 1 | Docker Multi-Container | Docker, Compose |
| 2 | Kubernetes | K8s, kubectl |
| 3 | GitHub Actions CI/CD | GitHub, CI/CD |
| 4 | Terraform AWS | Terraform, AWS |
| 5 | Ansible Playbook | Ansible, YAML |
| 6 | Prometheus Monitoring | Prometheus, Grafana |
| 7 | Bash Scripts | Bash, Linux |
| 8 | Python DevOps Tools | Python, Automation |
| 9 | Jenkins Pipeline | Jenkins, Groovy |
| 10 | ELK Stack | Elasticsearch, Kibana |
| 11 | [cycle répète...] | ... |

La rotation est basée sur le **numéro du jour de l'année** (tm_yday), garantissant la même technologie le même jour, d'une année à l'autre.

## 🚀 Utilisation

### Exécution automatique

**Aucune action requise!** La GitHub Action s'exécute automatiquement tous les jours à 09:00 UTC.

### Exécution manuelle

#### Via GitHub Actions UI:
1. Allez à **Actions** > **Daily DevOps Project Generator**
2. Cliquez **Run workflow**
3. Sélectionnez la branche (main)
4. Cliquez **Run workflow**

#### Localement:
```bash
python3 scripts/generate_daily_project.py
```

## 📁 Structure d'un projet généré

```
projects/2026-05-26_prometheus-monitor/
├── README.md              # Documentation complète
├── prometheus.yml         # Configuration spécifique
├── docker-compose.yml     # (si applicable)
├── Dockerfile             # (si applicable)
├── Jenkinsfile            # (si applicable)
└── ...                    # Autres fichiers selon le thème
```

## 📝 Contenu du README généré

Chaque projet inclut:
- **Objectif**: Qu'est-ce qu'on va faire
- **Pré-requis**: Outils et connaissances nécessaires
- **Installation**: Étapes d'installation
- **Ce qu'on apprend**: Concepts et bonnes pratiques
- **Variations possibles**: Améliorations et extensions
- **Troubleshooting**: Solutions aux problèmes courants

## 🔧 Configuration

### Modifier la fréquence d'exécution

Éditez `.github/workflows/daily-project.yml`:

```yaml
on:
  schedule:
    - cron: '0 9 * * *'  # 09:00 UTC chaque jour
```

**Exemples de cron:**
- `0 9 * * *` → 09:00 UTC (11:00 CEST) chaque jour
- `0 9 * * 1-5` → Du lundi au vendredi uniquement
- `0 9 1 * *` → Le 1er du mois

### Ajouter un nouveau thème

Éditez `scripts/generate_daily_project.py`, section `THEMES`:

```python
{
    "id": "mon-theme",
    "name": "Mon Nouveau Thème",
    "desc": "Description du thème",
    "tech": ["Techno1", "Techno2"],
    "files": {
        "filename.ext": "contenu du fichier",
        ".github/workflows/ci.yml": "...",
    }
}
```

### Changer l'URL de notification ntfy

Éditez le script, ligne de `requests.post()`:
```python
"https://ntfy.sh/votre-topic-personnel",
```

## ✅ Maintenance

### Vérifier le statut

```bash
# Lister les derniers projets
ls -lt projects/ | head -10

# Vérifier les commits récents
git log --oneline | head -20

# Vérifier le dernier run GitHub Action
# Allez à Actions > Daily DevOps Project Generator
```

### Troubleshooting

**Problème:** La GitHub Action échoue avec erreur de push
- **Cause:** Le repo est peut-être protégé
- **Solution:** Vérifier les permissions du token GITHUB_TOKEN

**Problème:** Duplicate project créé
- **Cause:** Script exécuté deux fois le même jour
- **Solution:** Le script vérifie et skip les projets existants

**Problème:** Pas de notification ntfy
- **Cause:** Problème de connectivité ou URL incorrecte
- **Solution:** C'est non-bloquant, le script continue quand même

## 📊 Statistiques

- **Projets générés par an:** 365 (ou 366)
- **Thèmes en rotation:** 10
- **Récurrence de chaque thème:** ~36-37 fois par an
- **Temps moyen par projet:** 1 journée
- **Taille moyenne d'un projet:** 5-15 fichiers

## 🎯 Objectifs pédagogiques

Ce système permet à Jaouad de:

1. ✅ **Apprendre plusieurs technologies** DevOps
2. ✅ **Maîtriser les bonnes pratiques** de chaque domaine
3. ✅ **Construire un portfolio** impressionnant
4. ✅ **Automatiser la génération** de contenu
5. ✅ **Pratiquer la réplication** (même projet, même jour chaque année)

## 🚀 Évolutions futures

- [ ] Ajouter des projets "bonus" (avancé)
- [ ] Générer un score/progression pour Jaouad
- [ ] Ajouter des tests automatisés dans les workflows
- [ ] Intégrer avec Discord/Slack pour les notifications
- [ ] Créer un tableau de bord des projets complétés
- [ ] Ajouter des projets combinés (Docker + Kubernetes, etc.)

## 📞 Support

Pour des questions ou problèmes:
1. Vérifiez le [GitHub Issues](https://github.com/jaouadsiouahe1978/claude-devops-tools)
2. Consultez les logs GitHub Actions
3. Exécutez le script localement pour déboguer

---

**Créé pour:** Jaouad (formation DevOps/SRE à Grenoble)
**Mis à jour:** 2026-05-26
**Statut:** ✅ En production

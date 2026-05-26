# 🚀 Claude DevOps Tools

> **Système automatisé de génération de projets DevOps quotidiens pour Jaouad**
> 
> Formation DevOps/SRE à Grenoble | 365 projets en 1 an | Niveau débutant à intermédiaire

## 🎯 Vue d'ensemble

Ce repo contient un **système automatisé** qui génère un **nouveau projet DevOps** chaque jour :
- ✅ **1 projet par jour** généré automatiquement via GitHub Actions
- ✅ **Réalisable en 1 journée** (niveau débutant à intermédiaire)
- ✅ **Code complet et fonctionnel** (pas juste de la documentation)
- ✅ **10 thèmes en rotation** pour couvrir toutes les technos DevOps
- ✅ **Portfolio impressionnant** (365 projets en 1 an!)

## 📂 Structure du repo

```
claude-devops-tools/
├── projects/                                  # Projets générés quotidiennement
│   ├── 2026-05-26_prometheus-monitor/       # Aujourd'hui! 🆕
│   ├── 2026-05-25_prometheus-alertmanager-notifications/
│   ├── 2026-05-24_...
│   └── [continuel chaque jour...]
├── scripts/
│   └── generate_daily_project.py            # Générateur Python
├── .github/workflows/
│   └── daily-project.yml                    # Automation GitHub Actions
├── GETTING-STARTED.md                       # Guide de démarrage 👈
├── DAILY-PROJECT-SYSTEM.md                  # Docs techniques
└── README.md                                # Ce fichier
```

## 🚀 Démarrage rapide

### 1️⃣ Pour les utilisateurs (Jaouad)

**Lire le guide de démarrage:**
```bash
cat GETTING-STARTED.md
```

**Voir le projet d'aujourd'hui:**
```bash
ls -la projects/ | head -5
cd projects/$(date +%Y-%m-%d)*
cat README.md
```

**Réaliser le projet:**
```bash
# Suivez les étapes du README
docker-compose up -d  # ou terraform init, ansible-playbook, etc.
```

### 2️⃣ Pour les développeurs

**Comprendre le système:**
```bash
cat DAILY-PROJECT-SYSTEM.md
```

**Exécuter manuellement le générateur:**
```bash
python3 scripts/generate_daily_project.py
```

**Ajouter un nouveau thème:**
Éditez `scripts/generate_daily_project.py` et ajoutez une entrée à `THEMES`

## 🎓 Thèmes en rotation (10)

| # | Thème | Technos | Fréquence |
|---|-------|---------|-----------|
| 1 | Docker Multi-Container | Docker, Compose | 36-40 fois/an |
| 2 | Kubernetes Deployment | K8s, kubectl | 36-40 fois/an |
| 3 | GitHub Actions CI/CD | GitHub, CI/CD | 36-40 fois/an |
| 4 | Terraform AWS | Terraform, AWS | 36-40 fois/an |
| 5 | Ansible Provisioning | Ansible, YAML | 36-40 fois/an |
| 6 | Prometheus Monitoring | Prometheus, Grafana | 36-40 fois/an |
| 7 | Bash Scripts | Bash, Linux | 36-40 fois/an |
| 8 | Python DevOps Tools | Python, Automation | 36-40 fois/an |
| 9 | Jenkins Pipelines | Jenkins, Groovy | 36-40 fois/an |
| 10 | ELK Stack Logging | Elasticsearch, Kibana | 36-40 fois/an |

## 🤖 Automatisation GitHub Actions

**Déclenchement:** Automatiquement à **09:00 UTC (11:00 CEST)** chaque jour

**Actions:**
1. Clone le repo
2. Exécute le script générateur
3. Commit + push du nouveau projet
4. (Optionnel) Envoie notification ntfy.sh

**Exécution manuelle:**
- Via GitHub Actions UI: **Actions** > **Daily DevOps Project Generator** > **Run workflow**
- Ou: `python3 scripts/generate_daily_project.py`

## 📊 Statistiques

- **Projets par an:** 365 (ou 366)
- **Thèmes:** 10
- **Chaque thème répété:** ~36-37 fois par an
- **Temps par projet:** 1 journée
- **Fichiers par projet:** 3-8 fichiers
- **Volume total en 1 an:** ~1000+ fichiers config

## 💡 Exemple: Aujourd'hui (2026-05-26)

```bash
cd projects/2026-05-26_prometheus-monitor/
cat README.md
# Contient:
# - Objectif: Configuration Prometheus & Grafana
# - Technos: Prometheus, Grafana, Monitoring
# - Fichiers: prometheus.yml + docker-compose.yml (selon le thème)
# - Étapes d'installation complètes
# - Concept à apprendre
# - Ressources supplémentaires
```

## 🎯 Cas d'usage

### Pour Jaouad (apprenti DevOps)
✅ **Apprendre 1 technologie par jour**
✅ **Construire un portfolio** avec 365 projets réels
✅ **Maîtriser les bonnes pratiques** DevOps
✅ **Être prêt pour une carrière** DevOps/SRE

### Pour autres apprenants
✅ Copier la structure et adapter les thèmes
✅ Utiliser comme **curriculum d'apprentissage**
✅ **Inspirer d'autres projets** d'automatisation

### Pour les mentors
✅ Suivre la progression automatiquement
✅ Vérifier les commits quotidiens
✅ Adapter les sujets selon les besoins

## 📚 Documentation

- **[GETTING-STARTED.md](./GETTING-STARTED.md)** - Guide complet pour démarrer (recommandé!)
- **[DAILY-PROJECT-SYSTEM.md](./DAILY-PROJECT-SYSTEM.md)** - Docs techniques du système
- **[projects/*/README.md](./projects)** - Documentation de chaque projet

## 🔧 Configuration

### Modifier la fréquence
Éditez `.github/workflows/daily-project.yml`, ligne `cron:`
```yaml
- cron: '0 9 * * *'  # Actuellement: chaque jour 9:00 UTC
```

### Ajouter un thème
Éditez `scripts/generate_daily_project.py`, section `THEMES`

### Changer l'URL de notification
Éditez `scripts/generate_daily_project.py`, ligne `requests.post()`

## ✅ Checklist d'installation

- [x] ✅ Script générateur créé (`scripts/generate_daily_project.py`)
- [x] ✅ GitHub Action configurée (`.github/workflows/daily-project.yml`)
- [x] ✅ 10 thèmes définis avec fichiers templates
- [x] ✅ Premier projet du jour généré (2026-05-26)
- [x] ✅ Documentation complète (`GETTING-STARTED.md`, `DAILY-PROJECT-SYSTEM.md`)
- [x] ✅ Commits et push vers main
- [x] ✅ Système prêt pour production! 🚀

## 🚀 Évolutions futures

- [ ] Ajouter des projets "bonus" (niveau avancé)
- [ ] Intégrer avec Discord/Slack pour notifications
- [ ] Créer un dashboard de progression
- [ ] Ajouter des tests automatisés dans workflows
- [ ] Générer un certificat après 365 jours
- [ ] Créer des projets combinés (Docker + K8s, etc.)

## 📞 Support & Questions

- 📖 Consultez [GETTING-STARTED.md](./GETTING-STARTED.md) d'abord
- 🔧 Détails techniques: [DAILY-PROJECT-SYSTEM.md](./DAILY-PROJECT-SYSTEM.md)
- 💬 Questions spécifiques: Créez une issue GitHub
- 🆘 Problèmes: Consultez la section Troubleshooting

## 📜 Licence

MIT License - Libre d'utilisation et de modification

---

**Créé pour:** Jaouad (formation DevOps/SRE à Grenoble)
**Statut:** ✅ En production, automatisé quotidiennement
**Dernière mise à jour:** 2026-05-26
**Prochaine génération:** Demain à 09:00 UTC!


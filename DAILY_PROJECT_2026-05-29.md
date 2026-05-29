# Projet DevOps du 29 mai 2026

## 📌 GitHub Actions - Pipeline CI/CD Complet

### 🎯 Description rapide
Projet complet d'automatisation CI/CD avec GitHub Actions. Apprenez à créer des workflows multi-job, tester automatiquement, builder des images Docker et déployer en continu.

### 📚 Technos utilisées
- **GitHub Actions** : Orchestration CI/CD
- **Node.js 16/18/20** : Application polyvalente
- **Jest** : Tests unitaires
- **Docker** : Containerisation
- **ESLint + Prettier** : Linting et formatting
- **YAML** : Configuration des workflows

### 🏗️ Structure du projet
```
projects/2026-05-29_github-actions-cicd/
├── .github/workflows/
│   ├── ci.yml                 # Pipeline test + build
│   ├── deploy.yml             # Déploiement staging
│   └── scheduled-checks.yml   # Tâches planifiées (cron)
├── src/
│   ├── index.js               # App HTTP simple
│   └── calculator.js          # Module à tester
├── tests/
│   └── calculator.test.js     # Tests Jest
├── Dockerfile                 # Image multi-stage
└── package.json               # Dépendances Node
```

### 🔑 Concepts clés appris

| Concept | Utilité |
|---------|---------|
| **Workflows** | Fichiers YAML = automatisation complète |
| **Jobs parallèles** | Lint + Test + Build simultanément |
| **Dépendances** | `needs:` pour séquencer les jobs |
| **Matrice** | Tester sur Node 16, 18, 20 en parallèle |
| **Secrets** | Variables chiffrées pour les credentials |
| **Artifacts** | Partager le build Docker entre jobs |
| **Environments** | Approbations avant déploiement |
| **Cron** | `schedule:` pour les tâches périodiques |

### 📖 Ce qu'on apprend en 1 jour

1. **Linter & Format** (30 min)
   - ESLint + Prettier dans le pipeline
   - Vérifier la qualité du code automatiquement

2. **Tests multi-version** (45 min)
   - Matrix builds : tester sur Node 16, 18, 20
   - Coverage reports vers Codecov
   - Artifacts pour les résultats

3. **Build Docker** (45 min)
   - Multi-stage builds
   - Cache optimization
   - Upload artifacts entre jobs

4. **Déploiement** (30 min)
   - Environnements avec approbation
   - Smoke tests post-déploiement
   - Secrets management

5. **Sécurité & Maintenance** (30 min)
   - npm audit
   - Trivy container scan
   - Scheduled checks (cron jobs)

### ✅ Checklist d'apprentissage

- [ ] Comprendre la structure YAML des workflows
- [ ] Exécuter npm test en local et vérifier Jest
- [ ] Créer une PR et voir la CI s'exécuter
- [ ] Analyser les logs des workflows dans GitHub Actions
- [ ] Comprendre `needs:` pour les dépendances entre jobs
- [ ] Explorer la matrice de tests (multi-version Node)
- [ ] Construire l'image Docker localement : `docker build -t devops-app .`
- [ ] Vérifier le health check : `curl http://localhost:3000/health`
- [ ] Ajouter un secret fictif et l'utiliser dans un workflow
- [ ] Modifier un workflow et voir l'exécution en direct

### 🎓 Durée estimée
⏱️ **1 journée** (4-6h)
- Concepts : 45 min
- Implémentation : 2-3h
- Tests & debug : 1-1.5h
- Bonus (notifications Slack, matrice) : 30 min

### 💡 Points clés à retenir

1. **GitHub Actions est gratuit** pour repos publics + 2000 min/mois pour privés
2. **Les runners Ubuntu** sont les plus simples pour débuter
3. **Réutilisez les actions** : marketplace a 20k+ actions
4. **Testez sur plusieurs versions** avec les matrix builds
5. **Versionnez tout** : workflows = infrastructure as code
6. **Ne commitez jamais les secrets** : utilisez secrets.NOM
7. **Les dépendances de jobs** : séquencez avec `needs:`
8. **Artifacts** : partage de fichiers entre jobs

### 🔗 Prochaines étapes recommandées

- **Jenkins** : Alternative on-premise puissante
- **GitLab CI** : Concurrent avec des features avancées
- **ArgoCD** : GitOps pour les déploiements Kubernetes
- **Observabilité** : Ajouter Prometheus/Grafana

### 📝 Notes personnelles pour Jaouad

Ce projet couvre exactement ce que vous ferez en tant qu'**SRE/DevOps** :
- ✅ Automatiser les tests et builds
- ✅ Gérer des secrets en production
- ✅ Déployer de manière reproductible
- ✅ Monitorer les jobs (logs)
- ✅ Scaler avec des matrix builds

Les workflows GitHub Actions remplacent de plus en plus Jenkins pour les petites/moyennes équipes. C'est essentiellement du **configuration-as-code**, où chaque changement du pipeline est versionné et reviewable.

---

**Généré le :** 2026-05-29  
**Estimation :** 4-6 heures  
**Niveau :** Débutant à Intermédiaire  
**Thème :** CI/CD et Automatisation

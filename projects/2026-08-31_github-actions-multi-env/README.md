# 🚀 GitHub Actions: Multi-Environnement Deployment Pipeline

**Niveau:** Débutant à Intermédiaire  
**Durée:** 1 journée  
**Date:** 31 août 2026  
**Auteur:** Formation DevOps/SRE Jaouad

---

## 📋 Description du Projet

Ce projet met en place une **pipeline CI/CD complète avec GitHub Actions** pour déployer une application multi-environnements (dev, staging, prod). 

**Objectif:** Apprendre à construire une workflow GitHub Actions robuste avec:
- ✅ Build et test automatisés
- ✅ Déploiement multi-environnements
- ✅ Gestion des secrets et variables d'environnement
- ✅ Notifications et approbations
- ✅ Rollback automatisé
- ✅ Métriques et monitoring

---

## 🛠️ Prérequis

### Requis
- Compte GitHub avec accès au dépôt
- Node.js 18+ (local)
- Docker installed (pour tester localement)

### Optionnel
- Serveurs de déploiement (ou simulation locale)
- Outils de monitoring (Prometheus/Grafana)

---

## 📁 Structure du Projet

```
2026-08-31_github-actions-multi-env/
├── .github/
│   └── workflows/
│       ├── 01-build-test.yml          # Build et test
│       ├── 02-deploy-dev.yml          # Déploiement dev
│       ├── 03-deploy-staging.yml      # Déploiement staging
│       ├── 04-deploy-prod.yml         # Déploiement prod avec approbation
│       └── 05-monitor-health.yml      # Health check post-deploy
├── app/
│   ├── src/
│   │   ├── index.js                   # Application Node.js
│   │   └── health.js                  # Endpoint santé
│   ├── tests/
│   │   └── app.test.js                # Tests unitaires
│   ├── Dockerfile                     # Image Docker
│   ├── package.json                   # Dépendances
│   └── .dockerignore
├── deploy/
│   ├── dev-config.env                 # Config dev
│   ├── staging-config.env             # Config staging
│   ├── prod-config.env                # Config prod
│   └── deployment-script.sh            # Script de déploiement
├── docs/
│   ├── SETUP.md                       # Configuration initiale
│   ├── WORKFLOW.md                    # Explication des workflows
│   └── TROUBLESHOOTING.md             # Dépannage
├── .gitignore
├── Makefile                           # Commandes utiles
└── docker-compose.yml                 # Test local
```

---

## 🚀 Étapes de Réalisation

### **Jour 1: Configuration et Déploiement**

#### 1️⃣ **Cloner et préparer le repo** (30 min)
```bash
# Cloner ce projet
git clone https://github.com/jaouadsiouahe1978/claude-devops-tools.git
cd projects/2026-08-31_github-actions-multi-env

# Installer les dépendances
cd app && npm install && cd ..

# Tester localement
docker build -t app:latest app/
docker run -p 3000:3000 app:latest
```

#### 2️⃣ **Configurer les secrets GitHub** (15 min)
Dans `Settings > Secrets and variables > Actions`:
```
DOCKER_REGISTRY_USERNAME = votre_username
DOCKER_REGISTRY_PASSWORD = votre_token
DEPLOYMENT_KEY_DEV = clé_ssh_dev
DEPLOYMENT_KEY_PROD = clé_ssh_prod
```

#### 3️⃣ **Activer les workflows** (10 min)
- Les fichiers `.github/workflows/*.yml` sont prêts
- Push sur `main` ou créer une PR
- Vérifier dans l'onglet Actions

#### 4️⃣ **Tester le workflow de build** (20 min)
```bash
# Créer une PR
git checkout -b feature/test-workflow
echo "test" > TEST.md
git add . && git commit -m "Test workflow"
git push origin feature/test-workflow

# Vérifier les actions
# Dashboard GitHub > Actions > voir la pipeline
```

#### 5️⃣ **Configurer les environnements** (25 min)
```bash
# Définir les variables par environnement
# GitHub Settings > Environments > dev, staging, prod

# Chaque environnement a ses secrets et variables
# Ajouter: DEPLOYMENT_URL, API_ENDPOINT, LOG_LEVEL
```

#### 6️⃣ **Déployer en Dev** (20 min)
```bash
# Merger la PR ou push sur main
git checkout main
git pull origin main

# Vérifier le déploiement dev
curl https://app-dev.example.com/health

# Vérifier les logs
# GitHub Actions > workflow run > logs
```

#### 7️⃣ **Tester le déploiement Prod** (20 min)
```bash
# Les déploiements prod nécessitent une approbation
# Aller dans Actions > workflow > Approve & Deploy

# Vérifier la version en production
curl https://app-prod.example.com/version
```

#### 8️⃣ **Implémenter les notifications** (15 min)
- Ajouter notifications Slack
- Email sur failures
- Dashboard de monitoring

---

## 📚 Concepts Clés Appris

### 1. **GitHub Actions Workflows**
- Structure YAML des workflows
- Events (push, pull_request, schedule, workflow_dispatch)
- Jobs et steps
- Conditions et matrices

### 2. **Build Pipeline**
```yaml
- Build Docker image
- Run tests
- Push vers registry
- Generate artifacts
```

### 3. **Déploiement Multi-Environnements**
- Dev: auto-deploy à chaque push
- Staging: auto-deploy après tests
- Prod: nécessite approbation manuelle
- Rollback automatisé en cas d'erreur

### 4. **Gestion des Secrets**
- Variables sensibles avec `secrets.*`
- Environnements distincts
- Audit et rotation des clés

### 5. **Health Checks**
- Vérification post-déploiement
- Readiness/liveness probes
- Métriques collectées

### 6. **Notifications**
- Slack/Teams sur completion
- Email sur failure
- Dashboard centralisé

---

## 🎯 Cas d'Usage Réels

### Scénario 1: Feature Branch → Dev
```
1. Push feature branch
2. Workflows déclenchés
3. Tests auto-run
4. Deploy auto en dev si tests passent
5. Dev peut tester immédiatement
```

### Scénario 2: PR → Staging
```
1. PR créée
2. Commentaires des bots (linters, tests)
3. Approbation code review
4. Auto-merge
5. Deploy auto en staging
6. QA teste
```

### Scénario 3: Hotfix → Production
```
1. Hotfix branch créé
2. Tests + review rapide
3. PR merged
4. Auto-deploy en staging
5. Approbation manuelle requise
6. Deploy manuel en prod
7. Alertes monitoring
8. Rollback option disponible
```

---

## 🔍 Monitoring et Logs

### Accéder aux logs
```bash
# Dans GitHub UI:
Repository > Actions > Workflows > Run details > Logs

# Voir les déploiements:
Repository > Deployments > Voir chaque environnement

# Rollback:
Deployments > Inactiver une version
```

### Métriques
- Pipeline execution time
- Success rate par environnement
- Nombre de déploiements par jour
- MTTR (Mean Time To Recovery)

---

## 💡 Bonnes Pratiques

✅ **À Faire**
- Toujours tester en dev/staging avant prod
- Utiliser des approbations pour prod
- Monitorer après chaque déploiement
- Documenté les déploiements
- Garder les secrets sécurisés
- Versioner les images Docker

❌ **À Éviter**
- Secrets en hard-coded dans le code
- Deploy direct en prod sans tests
- Pas de rollback plan
- Logs non centralisés
- Pas de notifications d'équipe

---

## 🚨 Dépannage

### Workflow ne se déclenche pas
```bash
# Vérifier les permissions du token
# GitHub > Settings > Developer settings > Personal access tokens
# Donner: repo, workflows, write:packages
```

### Secrets inaccessibles dans workflow
```yaml
# Vérifier la syntaxe
env:
  MY_SECRET: ${{ secrets.MY_SECRET }}  # ✅ Correct
  # Ne pas faire: secrets.MY_SECRET (sans {{ }})
```

### Déploiement échoue
```bash
# Vérifier:
1. Clés SSH configurées
2. Serveurs de déploiement accessibles
3. Permissions fichiers/dossiers
4. Ports ouverts (firewall)
```

---

## 🎓 Apprentissage Approfondi

### Fichiers à étudier
1. `.github/workflows/01-build-test.yml` - Pipeline de base
2. `.github/workflows/04-deploy-prod.yml` - Déploiement prod avancé
3. `deploy/deployment-script.sh` - Logique de déploiement
4. `app/src/index.js` - Application de test

### Extensions Possibles
- [ ] Ajouter ArgoCD pour GitOps
- [ ] Intégrer Terraform pour infra
- [ ] Ajouter Helm charts
- [ ] Monitoring avancé (Prometheus)
- [ ] Canary deployments
- [ ] Blue-green deployments

---

## ✅ Checklist Final

- [ ] Tous les workflows sont créés
- [ ] Les secrets sont configurés
- [ ] Dev deployment fonctionne
- [ ] Staging deployment fonctionne
- [ ] Prod deployment avec approbation OK
- [ ] Health checks passent
- [ ] Notifications reçues
- [ ] Rollback testé et fonctionnel
- [ ] Documentation lue et comprise
- [ ] Repository prêt pour production

---

**Status:** ✅ Prêt à déployer  
**Support:** Consultez les logs GitHub Actions pour toute question

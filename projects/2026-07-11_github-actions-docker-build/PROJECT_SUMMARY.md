# 📋 GitHub Actions Docker CI/CD - Résumé du projet

**Date:** 11 juillet 2026  
**Durée:** 1 journée  
**Niveau:** Débutant à Intermédiaire

## 🎯 Objectif du projet

Créer un pipeline CI/CD **automatisé et moderne** qui:
- ✅ Build automatiquement une image Docker à chaque push
- ✅ Teste l'image dans un workflow séparé (avant production)
- ✅ Push l'image vers Docker Hub avec versioning intelligent
- ✅ Gère les secrets de manière sécurisée
- ✅ Optimise les builds avec cache et multi-architecture

## 📦 Structe du projet

```
2026-07-11_github-actions-docker-build/
├── README.md                           # Guide complet du projet
├── SETUP.md                            # Configuration étape par étape
├── PROJECT_SUMMARY.md                  # Ce fichier
│
├── app/
│   ├── package.json                    # Dépendances Node.js
│   ├── src/
│   │   └── index.js                    # Application Express
│   └── public/                         # (optionnel) Fichiers statiques
│
├── .github/
│   └── workflows/
│       ├── docker-build-push.yml       # Workflow principal (main/develop → push)
│       └── docker-test.yml             # Workflow de test (PR/branches)
│
├── Dockerfile                          # Multi-stage (optimisé)
├── .dockerignore                       # Fichiers à exclure
├── docker-compose.yml                  # Stack de développement
├── nginx.conf                          # Reverse proxy (optionnel)
└── test-local.sh                       # Script de test local

```

## 🚀 Workflows implémentés

### 1️⃣ **docker-build-push.yml** (Production)
Déclenché: `push` sur `main` ou `develop`

```
Checkout → Setup Buildx → Login Docker Hub → Build & Push → SBOM
```

**Actions:**
- Build pour `linux/amd64` et `linux/arm64`
- Login sécurisé via secrets GitHub
- Tagging intelligent (main-sha, latest, run_number)
- Génération du SBOM (Software Bill of Materials)
- Upload des artefacts

**Output:**
```
docker.io/username/test-app:latest           ← Image principale
docker.io/username/test-app:main-abc123      ← Avec commit SHA
docker.io/username/test-app:42               ← Avec run number
```

### 2️⃣ **docker-test.yml** (Développement)
Déclenché: `pull_request`, `push` (branches autres que main/develop)

```
Checkout → Build → Run → Test Endpoints → Logs → Cleanup
```

**Tests automatiques:**
- ✅ Démarrage du conteneur
- ✅ Endpoint `/health` - Status
- ✅ Endpoint `/` - Infos app
- ✅ Endpoint `/info` - Détails
- ✅ Endpoint `/metrics` - Métriques
- ✅ Endpoint `/nonexistent` - Gestion 404
- ✅ Vérification des logs

## 🛠️ Technologies utilisées

| Tech | Rôle |
|------|------|
| **GitHub Actions** | Orchestration CI/CD |
| **Docker** | Containerization |
| **Node.js** | Runtime app |
| **Express** | Framework web |
| **Buildx** | Multi-arch builds |
| **Docker Hub** | Registry |
| **Nginx** | Reverse proxy (optionnel) |

## 📚 Ce qu'on apprend

### GitHub Actions
- ✅ Syntaxe YAML des workflows
- ✅ Événements (`on: push`, `on: pull_request`)
- ✅ Jobs, steps, actions
- ✅ Secrets et variables d'environnement
- ✅ Artifacts et uploads

### Docker & CI/CD
- ✅ Dockerfile multi-stage pour optimisation
- ✅ Docker Buildx pour multi-arch
- ✅ Tagging et versioning intelligent
- ✅ Cache Docker pour accélérer builds
- ✅ Health checks dans Docker

### DevOps/SRE
- ✅ Pipeline automatisé
- ✅ Testing en CI
- ✅ Gestion des secrets
- ✅ Monitoring et logging
- ✅ SBOM pour sécurité supply-chain

## 🔧 Configuration requise

### Prérequis
- Compte GitHub (repo existant)
- Compte Docker Hub
- Docker installé localement (pour tests)

### Secrets GitHub
Dans `Settings → Secrets and variables → Actions`:
```
DOCKER_USERNAME = username_docker_hub
DOCKER_PASSWORD = access_token_docker_hub
```

## 📊 Résultats attendus

Après configuration et push sur `main`:

```
✅ Workflow déclenché automatiquement
✅ Image buildée en ~2-3 minutes
✅ Image pushée vers Docker Hub
✅ SBOM généré et archivé
✅ Tags automatiques appliqués
✅ Logs détaillés disponibles
```

## 🎓 Points clés à retenir

1. **Automation:** Chaque push = Build + Test + Push automatique
2. **Testing:** Les PR sont testées avant merge
3. **Versioning:** Tags intelligents pour retrouver facilement les versions
4. **Sécurité:** Secrets jamais exposés dans les logs
5. **Performance:** Cache Docker + buildx pour builds rapides
6. **Multi-arch:** Support ARM64 et AMD64 en une seule commande

## 💡 Cas d'usage réel

```
1. Dev crée une feature
2. Push sur feature branch
   → docker-test.yml s'exécute (pas de push)
   → Tests passent ✅
3. Crée une PR
   → docker-test.yml re-teste
4. Merge sur main
   → docker-build-push.yml s'exécute (avec push)
   → Image disponible sur Docker Hub
   → Équipe peut déployer en prod
```

## 🔍 Monitoring

### Voir les workflows
- GitHub repo → Actions tab
- Voir chaque execution en détail
- Logs complets pour debugging

### Récupérer l'image
```bash
docker pull docker.io/username/test-app:latest
docker run -p 3000:3000 docker.io/username/test-app:latest
```

## 📈 Prochaines étapes (optionnel)

- [ ] Ajouter Trivy scan pour vulnérabilités
- [ ] Notifier sur Slack/Discord
- [ ] Signer les images avec Cosign
- [ ] ArgoCD pour déploiement auto (GitOps)
- [ ] Tests unitaires/integration
- [ ] Performance benchmarks

## 🚨 Troubleshooting rapide

| Problème | Solution |
|----------|----------|
| Image ne push pas | Vérifier secrets Docker Hub dans Settings |
| Tests échouent en CI | Lancer `./test-local.sh` pour reproduire |
| Rate limit Docker Hub | Utiliser token au lieu de password |
| Image trop grosse | Vérifier `.dockerignore` et Dockerfile multi-stage |

## 📚 Ressources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Docker Buildx](https://docs.docker.com/buildx/working-with-buildx/)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

**Créé le:** 11 juillet 2026  
**Durée totale:** ~1 journée  
**Complexité:** ⭐⭐⭐ (Intermédiaire)

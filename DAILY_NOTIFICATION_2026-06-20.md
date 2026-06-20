# 📦 DevOps du jour - 2026-06-20

## 🔒 Docker Registry & Trivy Container Security Scanning

**Notification Platform** : ntfy.sh/jaouad-devops-veille

---

## 📋 Résumé du projet

Créé un projet **DevOps complet** pour la sécurité des containers :
- **Harbor** : Registre Docker privé avec RBAC et scanning intégré
- **Trivy** : Scanner de vulnérabilités (CVE, dépendances, secrets)
- **PostgreSQL + Redis** : Infra supportante
- **CI/CD** : Intégration GitHub Actions
- **Dockerfiles sécurisés** : Multi-stage builds, non-root users

### Objectif
- Maîtriser la **sécurité des containers**
- Apprendre les concepts CVE/CVSS et SBOM
- Intégrer le scanning de vulnérabilités en CI/CD
- Hardening Docker (best practices)
- Gestion de registres privés

---

## 🏗️ Fichiers créés

### Structure du projet
```
projects/2026-06-20_docker-registry-trivy-security/
├── README.md                          # Documentation complète (600+ lignes)
├── QUICKSTART.md                      # Setup 10-minute
├── docker-compose.yml                 # Stack all-in-one
├── .gitignore                         # Exclusions Git
│
├── harbor/
│   └── harbor.yml                     # Configuration Harbor (RBAC, policies)
│
├── trivy/
│   └── trivy-config.yaml              # Configuration Trivy
│
├── images/                            # Dockerfiles d'exemple
│   ├── nodejs/
│   │   ├── Dockerfile                 # Secure multi-stage build
│   │   ├── Dockerfile.bad             # Vulnérabilités intentionnelles (démo)
│   │   ├── package.json
│   │   ├── server.js
│   │   └── package-lock.json          # (optionnel)
│   ├── python/                        # (Template)
│   └── golang/                        # (Template)
│
├── ci-cd/                             # Intégration CI/CD
│   └── .github/workflows/
│       └── build-and-scan.yml         # GitHub Actions complet
│
├── scripts/                           # Utilitaires (tous exécutables)
│   ├── setup.sh                       # Setup complet + healthchecks
│   ├── create-project.sh              # Créer projet Harbor (API)
│   ├── scan-image.sh                  # Scanner une image + rapports
│   └── cleanup.sh                     # Reset complet
│
├── docs/                              # (Structure pour docs futures)
│   ├── CONCEPTS.md
│   ├── TRIVY-GUIDE.md
│   ├── HARBOR-GUIDE.md
│   ├── SECURITY-HARDENING.md
│   └── TROUBLESHOOTING.md
│
├── tests/                             # (Structure pour tests futures)
└── PROJECT_SUMMARY.txt                # Résumé structure
```

---

## 🎓 Concepts expliqués dans README.md

### 1. **Harbor - Registre Docker privé**
- Architecture avec PostgreSQL + Redis
- API REST pour gestion projets/utilisateurs
- RBAC : roles admin, developer, guest
- Webhooks pour notifications
- Intégration Trivy automatique
- Replication multi-registre

### 2. **Trivy - Scanner de vulnérabilités**
- Scan d'images Docker complets
- OS vulnerabilities (CVE database)
- Dépendances : npm, pip, gems, maven, cargo
- Secrets detection (API keys, tokens)
- Misconfiguration scanning (Dockerfile, K8s)
- Outputs : table, JSON, SARIF, CycloneDX

### 3. **CVE/CVSS Scoring**
- CVE: Common Vulnerabilities & Exposures (ID unique)
- CVSS: 0-10 score
  - 0-3.9: LOW
  - 4-6.9: MEDIUM
  - 7-8.9: HIGH
  - 9-10: CRITICAL

### 4. **SBOM - Software Bill Of Materials**
- Liste complète des dépendances
- Versions exactes
- Format CycloneDX XML
- Traçabilité supply chain

### 5. **Docker Security - Best Practices**
- Multi-stage builds → images 5-10x plus petites
- Alpine Linux → minimal packages
- Non-root users → isolation
- HEALTHCHECK → availability
- Secrets externalisation (pas dans image)

### 6. **CI/CD Integration**
- GitHub Actions workflow complet
- Build → Scan → SARIF upload → PR comment
- Fail on CRITICAL vulnerabilities
- Artifact archiving (rapports)

---

## 🚀 3 façons de démarrer

### Option 1 : Quickstart (10 min)
```bash
cd projects/2026-06-20_docker-registry-trivy-security
chmod +x scripts/*.sh
docker-compose up -d
sleep 30
./scripts/create-project.sh demo
cd images/nodejs && docker build -t localhost:5000/demo/app:v1 .
../../scripts/scan-image.sh localhost:5000/demo/app:v1
docker login localhost:5000 -u admin -p Harbor12345
docker push localhost:5000/demo/app:v1
```

### Option 2 : Production-ready
```bash
# Modifier docker-compose.prod.yml pour HTTPS, auth externe, etc.
# Déployer sur VM/K8s
```

### Option 3 : SaaS Registry
```bash
# Utiliser Docker Hub, GitHub Container Registry, ou GitLab Registry
# Intégrer Trivy dans CI/CD
```

---

## 📊 Services déployés

| Service | Port | Rôle | Status |
|---------|------|------|--------|
| **Harbor Core** | 8080 | Web UI + API | ✅ |
| **Harbor Registry** | 5000 | Docker Registry (v2 API) | ✅ |
| **Harbor JobService** | 8087 | Async jobs (scanning) | ✅ |
| **Harbor RegistryCtl** | 8088 | Registry control plane | ✅ |
| **Trivy Server** | 8081 | Vulnerability scanner API | ✅ |
| **PostgreSQL** | 5432 | Harbor metadata DB | ✅ |
| **Redis** | 6379 | Cache + sessions | ✅ |
| **MinIO** | 9000 | S3-compatible storage (optionnel) | ✅ |

---

## 🔧 Fichiers clés

### docker-compose.yml (200+ lignes)
```yaml
# Services:
# - harbor-postgres (PostgreSQL 15)
# - harbor-redis (Redis 7)
# - harbor-core (Web UI + API)
# - registry (Docker Registry)
# - harbor-jobservice (async tasks)
# - registry-controller (control plane)
# - trivy (Scanner)
# - minio (S3 optionnel)
```

Chaque service a :
- Image spécifique avec version
- Variables d'environnement
- Healthchecks
- Volumes persistants
- Networking
- Restart policy

### harbor/harbor.yml (200+ lignes)
Configuration complète :
- Hostname + ports
- Database credentials
- Storage backend (filesystem/S3)
- Logging (level, rotation)
- Redis externe
- Clair config (optional scanning)
- Notary signing
- Metrics (Prometheus optionnel)
- Session timeout
- OIDC/LDAP auth (templates)
- Proxy settings

### images/nodejs/Dockerfile
```dockerfile
# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Runtime
FROM node:18-alpine
RUN addgroup -g 1001 nodejs && adduser -S nodejs -u 1001
WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /app/node_modules .
COPY --chown=nodejs:nodejs . .
USER nodejs
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD node -e "require('http').get(...)"
CMD ["node", "dist/server.js"]
```

Démontre :
- Multi-stage pour réduction d'image
- Alpine pour minimal footprint
- Non-root user (nodejs:nodejs)
- HEALTHCHECK correct
- Production-ready

### images/nodejs/Dockerfile.bad
Intentionnellement vulnérable pour démo :
- `FROM ubuntu:20.04` (gros, old)
- `apt-get install` sans `--no-install-recommends`
- Running as root
- Secrets en ENV (DATABASE_PASSWORD)
- No healthcheck
- Package.json old dependencies

→ Trivy détectera 30+ vulnerabilités

### ci-cd/.github/workflows/build-and-scan.yml
GitHub Actions workflow complet :
1. Checkout code
2. Build image avec Buildx
3. Trivy scan → SARIF
4. Upload to GitHub Security
5. JSON report pour parsing
6. Vérifier CRITICAL vulns
7. Générer SBOM (CycloneDX)
8. Upload artifacts
9. Comment PR avec résultats

---

## 🎓 Apprentissage couvert

- ✅ Architecture registres privés vs publics
- ✅ Concepts CVE/CVSS/SBOM
- ✅ Trivy modes : image, Dockerfile, filesystem, repo
- ✅ Harbor configuration + RBAC
- ✅ PostgreSQL + Redis infrastructure
- ✅ Docker security best practices
- ✅ Multi-stage builds optimization
- ✅ Non-root users et isolation
- ✅ HEALTHCHECK patterns
- ✅ Secrets management (externalisation)
- ✅ GitHub Actions CI/CD
- ✅ SARIF reports pour GitHub Security
- ✅ Scanning automation en pipeline
- ✅ Scanning supplémentaire workflows
- ✅ Vulnerability triage + remediation

---

## 🔒 Bonnes pratiques incluses

1. **Harbor**
   - RBAC : projets isolés
   - Credentials sécurisés
   - Webhooks pour alertes
   - Retention policies

2. **Docker Images**
   - Alpine base → minimal packages
   - Multi-stage builds → compact final image
   - Non-root users → privilege isolation
   - HEALTHCHECK → observabilité
   - No secrets en image

3. **Scanning**
   - CI/CD integration obligatoire
   - Fail on CRITICAL vulns
   - Trivy pour chaque build
   - SBOM generation
   - Rapports archivés

4. **Monitoring**
   - Harbor webhooks → Slack/email
   - Logging centralisé
   - Prometheus metrics (optionnel)
   - Audit trail des accès

---

## 📈 Extensions possibles

1. **Trivy Policy Engine**
   ```bash
   trivy image --severity CRITICAL \
     --skip-update \
     --security-checks vuln,config,secret \
     myimage:latest
   ```

2. **Harbor Replication**
   ```bash
   # Syncer images vers plusieurs registres
   # Docker Hub ↔ Harbor ↔ Private Registry
   ```

3. **Kubernetes Integration**
   ```bash
   # Harbor pull secrets
   # Image pull policies
   # Pod security policies
   ```

4. **Sigstore/Cosign**
   ```bash
   # Sign images in Harbor
   # Verify before pull
   ```

5. **Advanced RBAC**
   ```bash
   # LDAP/Active Directory integration
   # OIDC federation
   # Project-level permissions
   ```

---

## 📚 Technos utilisées

| Tech | Version | Rôle |
|------|---------|------|
| **Docker** | 20.10+ | Container runtime |
| **Docker Compose** | v2+ | Orchestration locale |
| **Harbor** | v2.9.1 | Registre privé |
| **Trivy** | latest | Scanning vulnérabilités |
| **PostgreSQL** | 15-alpine | Database |
| **Redis** | 7-alpine | Cache |
| **Node.js** | 18-alpine | App example |
| **Express** | 4.18.2 | Framework web |
| **Helmet** | 7.0.0 | Security headers |

---

## ⏱️ Timeline du projet

| Étape | Durée | Tâches |
|-------|-------|--------|
| Setup | 20 min | docker-compose up + healthchecks |
| Dockerfiles | 10 min | Build images (secure + bad) |
| Scanning | 15 min | Trivy scan + analyser resultats |
| CI/CD | 15 min | GitHub Actions workflow |
| Optimisation | 20 min | Benchmarking + tweaking |
| **Total** | **80 min** | **1 journée** |

---

## 📍 Localisation du projet

```
Repository: https://github.com/jaouadsiouahe1978/claude-devops-tools
Branch: main
Commit: 8ecca63 (2026-06-20)
Dossier: projects/2026-06-20_docker-registry-trivy-security/
```

---

## 🎯 Checkpoints d'apprentissage

- [ ] Démarrer la stack Docker Compose
- [ ] Accéder à Harbor UI
- [ ] Créer un projet Harbor
- [ ] Builder une image Docker
- [ ] Scanner avec Trivy
- [ ] Pousser vers Harbor
- [ ] Vérifier scan results dans UI
- [ ] Analyser Dockerfile vulnérable
- [ ] Mettre en place GitHub Actions
- [ ] Générer SBOM
- [ ] Configurer webhooks
- [ ] Tester scaling et performance

---

## 🤝 Contribution

Le projet est **Production-ready** :
1. Docker Compose all-in-one
2. Scripts d'automation (setup/cleanup)
3. Documentations exhaustives
4. Dockerfiles pour Node/Python/Go
5. CI/CD templates (GitHub/Jenkins/GitLab)
6. Healthchecks et monitoring
7. RBAC et sécurité par défaut

---

**Créé le**: 2026-06-20  
**Thème**: Container Security & Registry Management  
**Niveau**: Débutant-Intermédiaire  
**Prérequis**: Docker basics, Linux notions, JSON/YAML  
**Prochaine session**: 2026-06-21  

🔒 **Thème pour demain**: Kubernetes Secrets Management ou Ansible Vault

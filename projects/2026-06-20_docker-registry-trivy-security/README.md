# 🔒 Docker Registry & Trivy Container Security Scanning

## 📋 Objectif du projet

Construire une **infrastructure de sécurité des containers** avec :
- 🐳 **Harbor** : Registre Docker privé avec sécurité intégrée
- 🔍 **Trivy** : Scanner de vulnérabilités dans les images (OS + dépendances)
- 📊 **Monitoring** : Alertes automatiques sur vulnérabilités détectées
- 🔐 **RBAC** : Contrôle d'accès par projet et rôle
- 🚀 **CI/CD Integration** : Scan automatique dans GitHub Actions

### Apprentissages
- Concepts de registres privés vs publics
- Gestion des vulnérabilités (CVE)
- Scan de dépendances (npm, pip, gems, etc.)
- SBOM (Software Bill Of Materials)
- Stratégies d'update des images de base
- RBAC et politique de sécurité

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────┐
│         Local Dev Environment (Docker Compose)       │
├──────────────────────────────────────────────────────┤
│                                                      │
│  ┌─────────────────┐       ┌──────────────────┐    │
│  │  Harbor         │       │  Trivy           │    │
│  │  Registre privé │◄──────┤  Scanner         │    │
│  │  Port: 5000     │       │  Port: 8081      │    │
│  │  UI: 8080       │       │  API: 8081/api   │    │
│  └─────────────────┘       └──────────────────┘    │
│         ▲                           ▲               │
│         │ Docker images             │ Scan API      │
│         │                           │               │
│  ┌──────┴───────────────────────────┴─────┐        │
│  │  docker build / docker push             │        │
│  │  Dockerfile (Node.js, Python, Go)      │        │
│  └─────────────────────────────────────────┘        │
│                                                      │
│  ┌─────────────────┐       ┌──────────────────┐    │
│  │  PostgreSQL     │       │  Redis           │    │
│  │  (Registre DB)  │       │  (Cache)         │    │
│  │  Port: 5432     │       │  Port: 6379      │    │
│  └─────────────────┘       └──────────────────┘    │
│                                                      │
└──────────────────────────────────────────────────────┘
           ▲
           │ Local Docker socket
           │
    ┌──────┴──────────┐
    │  Docker Host    │
    │  Linux/Windows  │
    └─────────────────┘
```

---

## 📂 Structure du projet

```
2026-06-20_docker-registry-trivy-security/
├── README.md                          # Ce fichier
├── QUICKSTART.md                      # Démarrage rapide 10 min
│
├── docker-compose.yml                 # Stack complète (Harbor + Trivy)
├── docker-compose.prod.yml            # Setup production
│
├── harbor/                            # Configuration Harbor
│   ├── harbor.yml                     # Config générale
│   ├── docker-compose.yml             # Compose dédié
│   └── scripts/
│       ├── init-harbor.sh             # Setup initial
│       └── create-project.sh          # Créer projets
│
├── trivy/                             # Configuration Trivy
│   ├── trivy-config.yaml              # Trivy settings
│   ├── Dockerfile.trivy-server        # Trivy server image
│   ├── policies/                      # Règles de scan
│   │   ├── severity.yaml              # Sévérité minimale
│   │   ├── fix-available.yaml         # Exiger des fixes
│   │   └── critical-only.yaml         # Mode strict
│   └── scripts/
│       ├── scan-image.sh              # Scan une image
│       ├── scan-local-dockerfile.sh   # Dockerfile hardening
│       └── generate-sbom.sh           # SBOM export
│
├── images/                            # Dockerfiles d'exemple
│   ├── nodejs/
│   │   ├── Dockerfile                 # Node.js optimisé
│   │   ├── Dockerfile.bad             # Vulnérabilités intentionnelles
│   │   └── package.json
│   │
│   ├── python/
│   │   ├── Dockerfile                 # Python optimisé
│   │   └── requirements.txt
│   │
│   └── golang/
│       ├── Dockerfile                 # Go multi-stage
│       └── main.go
│
├── ci-cd/                             # Intégration CI/CD
│   ├── .github/workflows/
│   │   ├── build-and-scan.yml         # GitHub Actions
│   │   ├── security-policy.yml        # Enforce policies
│   │   └── registry-cleanup.yml       # Maintenance
│   │
│   ├── jenkinsfile                    # Jenkins pipeline
│   └── gitlab-ci.yml                  # GitLab CI
│
├── scripts/                           # Utilitaires
│   ├── setup.sh                       # Setup complet
│   ├── login-harbor.sh                # Authentification
│   ├── push-images.sh                 # Push auto
│   ├── scan-all.sh                    # Scan repository entier
│   ├── vulnerability-report.sh        # Rapport JSON/HTML
│   ├── cleanup.sh                     # Reset
│   └── test-security.sh               # Tests de sécurité
│
├── docs/                              # Documentation
│   ├── CONCEPTS.md                    # CVE, SBOM, CIS benchmarks
│   ├── TRIVY-GUIDE.md                 # Guide Trivy complet
│   ├── HARBOR-GUIDE.md                # Guide Harbor
│   ├── SECURITY-HARDENING.md          # Bonnes pratiques
│   └── TROUBLESHOOTING.md             # FAQ
│
└── tests/                             # Tests de validation
    ├── test-harbor-api.sh             # Tester API Harbor
    ├── test-trivy-scan.sh             # Tester scans
    └── benchmark.sh                   # Performance
```

---

## 🚀 Démarrage rapide (10 min)

### Prérequis
- Docker & Docker Compose v2+
- 4GB RAM minimum
- Linux/Mac/Windows (WSL2)

### 1️⃣ Démarrer l'infrastructure

```bash
cd projects/2026-06-20_docker-registry-trivy-security

# Lancer Harbor + Trivy
docker-compose up -d

# Attendre ~30s pour Harbor
sleep 30

# Vérifier
docker-compose ps
```

### 2️⃣ Accéder aux interfaces

- **Harbor UI** : http://localhost:8080
  - Admin : `admin` / `Harbor12345`
- **Trivy API** : http://localhost:8081
  - Swagger : http://localhost:8081/swagger.html

### 3️⃣ Créer un projet Harbor

```bash
./scripts/create-project.sh myproject
```

### 4️⃣ Builder une image de test

```bash
cd images/nodejs
docker build -t localhost:5000/myproject/app:v1 .
```

### 5️⃣ Scanner avec Trivy

```bash
./scripts/scan-image.sh localhost:5000/myproject/app:v1
```

### 6️⃣ Pousser vers Harbor

```bash
docker login localhost:5000 -u admin -p Harbor12345
docker push localhost:5000/myproject/app:v1
```

✅ **C'est fait !** L'image est dans Harbor, scannée pour vulnérabilités.

---

## 🔍 Trivy : Scanner de vulnérabilités

### Qu'est-ce que Trivy?

**Trivy** détecte :
- OS vulnerabilities (Linux packages, Alpine, Ubuntu, etc.)
- Dépendances (npm, pip, gems, maven, cargo, etc.)
- Secrets (API keys, tokens, credentials)
- Misconfiguration (IaC : Dockerfile, Kubernetes, Terraform)

### Modes de scan

#### 1. **Image Docker**
```bash
trivy image localhost:5000/myproject/app:v1
```

Résultat :
```
2026-06-20T10:30:00.123Z        INFO    Vulnerability scanning...
2026-06-20T10:30:15.456Z        INFO    Identified 45 vulnerabilities

CRITICAL (5)
│ Library │ CVE            │ Severity │ Fixed │
├──────────┼────────────────┼──────────┼────────┤
│ openssl  │ CVE-2023-0286  │ CRITICAL │ 3.0.8  │
│ curl     │ CVE-2023-27535 │ CRITICAL │ 8.0.0  │
└──────────┴────────────────┴──────────┴────────┘

HIGH (12)
...

MEDIUM (28)
...
```

#### 2. **Dockerfile (avant build)**
```bash
trivy config images/nodejs/Dockerfile --severity HIGH,CRITICAL
```

Détecte :
- `RUN apt-get install` sans `--no-install-recommends`
- Images de base avec trop de packages
- Utilisateurs root
- Non-existent WORKDIR

#### 3. **Repository entière**
```bash
trivy repo https://github.com/jaouadsiouahe1978/my-app
```

Scan tous les Dockerfiles, dépendances, IaC.

#### 4. **Filesystem**
```bash
trivy fs ./images/nodejs
```

Scan local sans build.

### Formats de sortie

```bash
# JSON (pour parsing)
trivy image --format json --output report.json myimage:latest

# Sarif (pour GitHub Security)
trivy image --format sarif --output report.sarif myimage:latest

# SBOM (CycloneDX)
trivy image --format cyclonedx --output sbom.xml myimage:latest

# Table simple
trivy image --format table myimage:latest
```

---

## 🏛️ Harbor : Registre privé

### Qu'est-ce que Harbor?

**Harbor** est un registre **Docker/OCI** :
- ✅ Authentification & RBAC
- ✅ Scan de vulnérabilités intégré
- ✅ Replication (multi-registres)
- ✅ Webhook et API
- ✅ Retention policies
- ✅ Image signing (Notary)

### Architecture Harbor

```
┌─────────────────────────────────┐
│  Harbor Web UI (Port 8080)      │
└────────────┬────────────────────┘
             │
      ┌──────┴──────────┐
      │                 │
┌─────▼──┐       ┌─────▼──────────┐
│  API   │       │ Job Service    │
│Registry│       │(async jobs)    │
│Core    │       └────────────────┘
└───┬────┘
    │
┌───▼────────────────────────────┐
│   PostgreSQL Database          │
│ (metadata, users, projects)    │
└────────────────────────────────┘
    │
┌───▼────────────────────────────┐
│   Docker Registry Endpoint     │
│   (Port 5000)                  │
│   (Stores images)              │
└────────────────────────────────┘
```

### Commandes Harbor

```bash
# Authentifier
docker login localhost:5000 -u admin -p Harbor12345

# Tagger une image
docker tag myapp:latest localhost:5000/myproject/myapp:latest

# Pousser
docker push localhost:5000/myproject/myapp:latest

# Tirer
docker pull localhost:5000/myproject/myapp:latest

# Voir les images
curl http://localhost:8080/api/v2.0/projects/myproject/repositories \
  -H "Authorization: Basic $(echo -n admin:Harbor12345 | base64)"

# Voir les vulnérabilités scanées
curl http://localhost:8080/api/v2.0/projects/myproject/repositories/myapp/artifacts \
  -H "Authorization: Basic $(echo -n admin:Harbor12345 | base64)" \
  | jq '.[] | {name, tags, scan_overview}'
```

---

## 🔐 Sécurité : Bonnes pratiques

### 1. **Utilisez des images de base minimalistes**

❌ **Mauvais**
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y nodejs
```

✅ **Bon**
```dockerfile
FROM node:18-alpine
```

Comparaison :
- `ubuntu:22.04` → ~77 MB + 500+ packages
- `node:18-alpine` → ~180 MB + ~50 packages

### 2. **Multi-stage builds**

```dockerfile
# Stage 1: Build
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Runtime
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
CMD ["node", "server.js"]
```

**Résultat** : Image finale 5-10x plus petite.

### 3. **Ne tournez jamais en root**

❌ **Mauvais**
```dockerfile
FROM ubuntu:22.04
RUN apt-get install -y app
```

✅ **Bon**
```dockerfile
FROM ubuntu:22.04
RUN useradd -m appuser
USER appuser
```

### 4. **Scannez régulièrement**

```bash
# Scan hebdomadaire de toutes les images
0 2 * * 0  /opt/scripts/scan-all.sh
```

### 5. **Mettez à jour les dépendances**

```bash
# Audit npm
npm audit

# Audit Python
pip-audit

# Audit Go
go list -json -m all | nancy sleuth
```

---

## 🛠️ Cas d'usage pratiques

### Cas 1 : Image avec vulnérabilité critique

```bash
$ cd images/nodejs-bad
$ docker build -t test:bad .
$ trivy image test:bad

CRITICAL (3)
│ openssl  │ CVE-2023-0286  │ CRITICAL │ Use alpine:3.17+ │
│ curl     │ CVE-2023-27535 │ CRITICAL │ Update base image│
└──────────┴────────────────┴──────────┴──────────────────┘
```

**Résolution** : Passer de `ubuntu:20.04` à `alpine:3.18`

### Cas 2 : Secrètes en image

```bash
# Trivy détecte les secrets
$ trivy image myapp:v1 --severity HIGH

SECRET (2)
│ aws_secret_access_key │ HIGH    │ Remove from image        │
│ github_token          │ CRITICAL│ Use secrets management   │
```

**Résolution** : Utiliser Docker secrets ou HashiCorp Vault.

### Cas 3 : Vérifier avant push

```bash
# Dans CI/CD
docker build -t myapp:latest .
trivy image --severity CRITICAL myapp:latest

# Si vulnérabilités CRITICAL trouvées → Echec du build
if [ $? -ne 0 ]; then
  echo "Build failed: Critical vulnerabilities found"
  exit 1
fi

docker push myregistry/myapp:latest
```

---

## 📊 Intégration CI/CD

### GitHub Actions

```yaml
name: Build & Scan
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker image
        run: docker build -t myapp:${{ github.sha }} .
      
      - name: Run Trivy scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: myapp:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
      
      - name: Push to registry
        run: docker push myregistry/myapp:${{ github.sha }}
```

### Jenkins Pipeline

```groovy
pipeline {
  stages {
    stage('Build') {
      steps {
        sh 'docker build -t myapp:${BUILD_NUMBER} .'
      }
    }
    
    stage('Scan') {
      steps {
        sh '''
          trivy image --severity HIGH,CRITICAL \
            myapp:${BUILD_NUMBER} > scan-report.txt
          cat scan-report.txt
        '''
      }
    }
    
    stage('Push') {
      steps {
        sh 'docker push myregistry/myapp:${BUILD_NUMBER}'
      }
    }
  }
  
  post {
    always {
      archiveArtifacts 'scan-report.txt'
    }
  }
}
```

---

## 📈 Monitoring & Alertes

### Webhook Harbor → Slack

```bash
# Configure dans Harbor UI
POST /api/v2.0/webhooks

{
  "name": "slack-alerts",
  "event_types": [
    "SCANNING_COMPLETED",
    "VULNERABILITY_DETECTED"
  ],
  "address": "https://hooks.slack.com/services/YOUR/WEBHOOK",
  "skip_cert_verify": false
}
```

Payload reçu par Slack :
```json
{
  "type": "SCANNING_COMPLETED",
  "resource": {
    "scan_overview": {
      "image_digest": "sha256:abc123",
      "scan_status": "Success",
      "components": {
        "total": 156,
        "summary": {
          "Critical": 0,
          "High": 5,
          "Medium": 28
        }
      }
    }
  },
  "timestamp": 1623059876
}
```

---

## 🧪 Tests de sécurité

### Test 1 : Vérifier une image de base

```bash
./scripts/test-security.sh alpine:latest
```

### Test 2 : Comparer 2 images

```bash
trivy image ubuntu:22.04 --format json > ubuntu.json
trivy image alpine:3.18 --format json > alpine.json
diff ubuntu.json alpine.json
```

### Test 3 : Benchmark de temps de scan

```bash
time trivy image busybox:latest
time trivy image debian:latest
time trivy image ubuntu:latest
```

---

## 🎓 Concepts clés

### CVE (Common Vulnerabilities & Exposures)
Identifie de vulnérabilités : `CVE-2023-1234`

### CVSS (Common Vulnerability Scoring System)
Score de 0-10 :
- 0-3.9 : LOW
- 4-6.9 : MEDIUM
- 7-8.9 : HIGH
- 9-10 : CRITICAL

### SBOM (Software Bill Of Materials)
Liste de toutes les dépendances avec versions.

Format :
```xml
<?xml version="1.0"?>
<bom xmlns="http://cyclonedx.org/schema/bom/1.4/bom.schema.json">
  <components>
    <component type="library">
      <name>openssl</name>
      <version>3.0.0</version>
      <purl>pkg:npm/openssl@3.0.0</purl>
    </component>
  </components>
</bom>
```

### CIS Benchmarks
Standards de sécurité pour Docker, Kubernetes, etc.

---

## 📚 Fichiers clés

### docker-compose.yml

```yaml
version: '3.8'

services:
  harbor-db:
    image: postgres:13-alpine
    environment:
      POSTGRES_PASSWORD: Harbor12345
    volumes:
      - postgres_data:/var/lib/postgresql/data

  harbor-core:
    image: goharbor/harbor-core:v2.8.0
    environment:
      HARBOR_ADMIN_PASSWORD: Harbor12345
      DATABASE_URL: postgresql://postgres:Harbor12345@harbor-db:5432/registry
    ports:
      - "8080:8080"
    depends_on:
      - harbor-db

  registry:
    image: goharbor/registry-photon:v2.8.0
    ports:
      - "5000:5000"
    environment:
      REGISTRY_STORAGE_DELETE_ENABLED: "true"

  trivy-server:
    image: aquasec/trivy:latest
    command: server --listen 0.0.0.0:8081
    ports:
      - "8081:8081"

volumes:
  postgres_data:
```

### images/nodejs/Dockerfile

```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Runtime stage
FROM node:18-alpine
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .

USER nodejs
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

CMD ["node", "server.js"]
```

---

## 🚀 Commandes essentielles

```bash
# Trivy
trivy image myimage:latest
trivy image --severity CRITICAL myimage:latest
trivy fs .
trivy config Dockerfile
trivy image --format json --output report.json myimage:latest

# Harbor CLI (requires harbor-cli)
harbor pull myproject/myapp:v1
harbor push myapp:v1 myproject/myapp:v1
harbor list-images myproject

# Docker Registry
curl http://localhost:5000/v2/_catalog
curl http://localhost:5000/v2/myproject/myapp/tags/list
```

---

## 🔗 Ressources

- [Trivy GitHub](https://github.com/aquasecurity/trivy)
- [Harbor Project](https://goharbor.io/)
- [Docker Registry Spec](https://docs.docker.com/registry/spec/api/)
- [OWASP Container Security](https://cheatsheetseries.owasp.org/cheatsheets/Container_Security_Cheat_Sheet.html)
- [CIS Docker Benchmark](https://www.cisecurity.org/cis-benchmarks/)

---

## 📍 Localisation du projet

```
Repository: https://github.com/jaouadsiouahe1978/claude-devops-tools
Branch: main
Dossier: projects/2026-06-20_docker-registry-trivy-security/
```

---

## ⏱️ Timeline (1 jour)

| Étape | Durée |
|-------|-------|
| Setup Harbor + Trivy | 20 min |
| Build images de test | 10 min |
| Scanner & analyser | 15 min |
| Intégrer CI/CD | 15 min |
| Benchmarking & optimisation | 20 min |
| **Total** | **80 min** |

---

**Créé le**: 2026-06-20  
**Thème**: Container Security & Registry  
**Niveau**: Débutant-Intermédiaire  
**Prérequis**: Docker basics, Linux  

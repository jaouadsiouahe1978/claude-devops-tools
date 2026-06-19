# 📚 Index des Projets DevOps - claude-devops-tools

## Vue d'ensemble
Repository contenant des projets DevOps/SRE réalisables en 1 journée, niveau débutant à intermédiaire.

**Mise à jour:** 2026-06-16

---

## 📋 Projets Réalisés

### 2026-06-16 🆕
**🐳 Docker Multi-Stage Build pour Node.js**
- Thème: Docker (Images Optimisées)
- Objectif: Réduire les images Docker de 500MB → 60MB
- Technos: Docker, Docker Compose, Node.js 20, Alpine Linux
- Concepts: Multi-stage builds, layer caching, sécurité, best practices
- Dossier: `projects/2026-06-16_docker-multistage-nodejs/`

### 2026-06-15
**📊 Prometheus Monitoring System**
- Thème: Monitoring
- Objectif: Mettre en place la monitoring avec Prometheus et Grafana
- Technos: Prometheus, Grafana, Node Exporter
- Dossier: `projects/2026-06-15_prometheus-monitor/`

### 2026-06-14
**📝 Bash Log Monitoring & Alerting**
- Thème: Scripting & Monitoring
- Objectif: Monitoring de logs avec alertes
- Technos: Bash, grep, syslog
- Dossier: `projects/2026-06-14_bash-log-monitoring/`

### 2026-06-13 et antérieurs
- Ansible Configuration Management
- Terraform IaC (AWS)
- GitHub Actions CI/CD Pipeline
- Et autres projets...

---

## 🎯 Thèmes Couverts

| Thème | Occurrence | Prochaine |
|-------|-----------|----------|
| Docker | ✅ | Kubernetes |
| CI/CD | ✅ | GitHub Actions Advanced |
| Monitoring | ✅ | ELK Stack |
| Scripting | ✅ | Python DevOps |
| Infrastructure | ✅ | Terraform AWS |
| Configuration | ✅ | Ansible Advanced |
| Kubernetes | ⏳ | K8s Deployment |
| Linux | ⏳ | Systemd Units |
| Networking | ⏳ | Docker Networking |
| Security | ⏳ | AppArmor/SELinux |

---

## 🚀 Structure d'un Projet

```
projects/YYYY-MM-DD_nom-du-projet/
├── README.md                 # Guide complet
├── PROJECT_SUMMARY.md        # Résumé court
├── Dockerfile / .tf / .yml  # Fichiers config principaux
├── app/ ou src/             # Code source
├── scripts/                 # Scripts utilitaires
├── .gitignore
└── docs/ (optionnel)
```

---

## 📚 Comment Utiliser

### Cloner le repo
```bash
git clone https://github.com/jaouadsiouahe1978/claude-devops-tools.git
cd claude-devops-tools
```

### Accéder à un projet
```bash
cd projects/2026-06-16_docker-multistage-nodejs
cat README.md
```

### Exécuter un projet
```bash
# Chaque projet a son propre setup
# Consulter le README.md du projet pour les instructions
docker-compose up -d  # Exemple pour Docker
terraform apply       # Exemple pour Terraform
```

---

## 💡 Progression Pédagogique

**Niveau 1 - Débutant** (semaines 1-4)
- ✅ Scripting Bash (logs, monitoring)
- ✅ Docker basics (images, containers)
- ⏳ Linux sysadmin (users, permissions)

**Niveau 2 - Intermédiaire** (semaines 5-8)
- ✅ Docker Advanced (multi-stage, compose)
- ✅ CI/CD Basics (GitHub Actions)
- ✅ Infrastructure as Code (Terraform)
- ✅ Configuration Management (Ansible)
- ⏳ Monitoring (Prometheus, ELK)

**Niveau 3 - Avancé** (semaines 9+)
- ⏳ Kubernetes (minikube, helm)
- ⏳ Service Mesh (Istio)
- ⏳ Advanced Networking
- ⏳ Security (scanning, policies)

---

## 🔗 Resources Externes

- [Docker Official Docs](https://docs.docker.com/)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Terraform Docs](https://www.terraform.io/docs)
- [Prometheus Docs](https://prometheus.io/docs/)
- [Ansible Docs](https://docs.ansible.com/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

---

## 📝 Notes

- Chaque projet est **indépendant** et peut être réalisé isolément
- Les projets sont pensés pour être **réalisables en 1 journée**
- Tous les projets ont du **vrai code/config**, pas juste de la théorie
- Les technologies varient pour **couvrir un maximum de domaines DevOps**

---

**Maintenu par:** Jaouad (Étudiant DevOps/SRE à Grenoble)
**Dernière mise à jour:** 2026-06-16


---

## 📦 2026-06-17 : Kubernetes Autoscaling (HPA)

**Thème** : Kubernetes - Autoscaling  
**Niveau** : Intermédiaire  
**Durée** : 1 journée (30 min - 2h)  
**Technos** : Kubernetes, kubectl, metrics-server, Flask, Docker

### 📌 Objectif
Apprendre à déployer une application multi-répliques sur Kubernetes avec Horizontal Pod Autoscaler (HPA) pour adapter automatiquement le nombre de pods en fonction de la charge CPU/mémoire.

### 📂 Contenu
- Application Flask CPU-intensive pour tester l'autoscaling
- Manifests Kubernetes complets (Deployment, HPA, Resource Quota)
- metrics-server pour la collecte de métriques
- 3 scripts d'automatisation (setup, test-load, monitor)
- Documentation complète (README, QUICKSTART, TROUBLESHOOTING)
- Support docker-compose pour développement local

### 🎓 Apprentissage
✅ Deployments multi-répliques  
✅ Resource Requests/Limits  
✅ Horizontal Pod Autoscaler  
✅ Monitoring avec metrics-server  
✅ Scaling automatique en action  
✅ Troubleshooting et best practices  

### 🚀 Quick Start
```bash
# Kubernetes
cd docker && docker build -t devops-app:1.0 .
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/hpa.yaml
./scripts/test-load.sh 5 10

# Ou docker-compose
docker-compose up -d
curl http://localhost/cpu-intensive
```

### 📊 Fichiers
- 14 fichiers au total
- ~1,800 lignes de code
- ~800 lignes de documentation
- 3 scripts d'automatisation
- 3 manifests Kubernetes
- 1 application Flask

---

## 📅 2026-06-19 - Ansible Web Stack Deployment

**Repository**: [claude-devops-tools](https://github.com/jaouadsiouahe1978/claude-devops-tools)  
**Folder**: `projects/2026-06-19_ansible-web-stack/`  
**Level**: Intermediate  
**Duration**: 1 day

### 🎯 Objective
Master **Ansible Configuration Management** by deploying a complete multi-server web stack with monitoring.

### 🏗️ Architecture
- **Nginx** (reverse proxy)
- **Node.js + Express** (backend)
- **PostgreSQL** (database)
- **Prometheus + Node Exporter** (monitoring)

### 📦 What's Included
✓ 6 reusable Ansible roles (common, nginx, nodejs, postgres, prometheus, monitoring)
✓ Multi-host inventory with groups (webservers, dbservers, monitoring)
✓ Dynamic variables (group_vars/, host_vars/)
✓ Jinja2 templates for configuration
✓ Docker Compose for local testing
✓ Scripts for automation (setup, ping, test)
✓ Complete documentation (README + QUICKSTART)

### 🚀 3 Deployment Options
1. **Docker Compose** - Local testing (5 min setup)
2. **Linux Servers** - Production deployment
3. **Vagrant** - VM-based testing

### 💡 Key Concepts
- Playbooks and idempotent tasks
- Roles and handlers
- Variables and Jinja2 templates
- Multi-server orchestration
- Service management (systemd)
- Firewall configuration (UFW)
- Monitoring integration

### 📊 Project Stats
- **34 files** | **2,329 lines** of config/code
- **6 roles** × **3 servers** = Production stack
- **100% YAML** (easy to understand and modify)

### 🎓 Learning Outcomes
- Ansible architecture and workflow
- Configuration Management best practices
- Infrastructure as Code (IaC)
- Multi-server deployment
- Monitoring and observability

### 📚 Resources
- [Ansible Documentation](https://docs.ansible.com/)
- [Playbook Guide](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html)
- [Role Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)

---


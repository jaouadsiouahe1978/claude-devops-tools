# 📦 DevOps du jour - 2026-06-19

## 🚀 Ansible Web Stack Deployment

**Notification** : ntfy.sh/jaouad-devops-veille

---

## 📋 Résumé du projet

Créé un projet **Ansible complet** pour déployer et configurer une application web multi-serveurs :
- **Nginx** : Reverse proxy et serveur web
- **Node.js + Express** : Application backend
- **PostgreSQL** : Base de données
- **Prometheus + Node Exporter** : Monitoring complet

### Objectif
- Maîtriser **Ansible** : outil de configuration management agentless
- Apprendre les concepts de **playbooks**, **roles** et **variables**
- Déployer une vraie **infrastructure multi-serveur**
- Intégrer le **monitoring** en production

---

## 🏗️ Fichiers créés

### Structure du projet
```
projects/2026-06-19_ansible-web-stack/
├── README.md                    # Documentation complète
├── QUICKSTART.md                # Démarrage 15 min
├── ansible.cfg                  # Configuration Ansible
├── docker-compose.yml           # Setup local de test
├── playbooks/
│   └── site.yml                # Playbook principal
├── roles/                      # 5 rôles réutilisables
│   ├── common/                 # SSH, firewall, sysctl
│   ├── nginx/                  # Reverse proxy config
│   ├── nodejs/                 # NVM, Node, PM2, app
│   ├── postgres/               # PostgreSQL setup
│   ├── prometheus/             # Prometheus scraping
│   └── monitoring/             # Node Exporter
├── inventory/                  # Hosts et groupes
│   ├── hosts.ini              # Format INI
│   └── hosts.yml              # Format YAML
├── group_vars/                 # Variables par groupe
│   ├── all.yml                # Communes
│   ├── webservers.yml         # Nginx + Node
│   ├── dbservers.yml          # PostgreSQL
│   └── monitoring.yml         # Prometheus
├── scripts/                    # Automatisation
│   ├── setup.sh               # Setup initial
│   ├── ping-hosts.sh          # Test connectivité
│   └── test-deployment.sh     # Validation post-déploiement
└── tests/                     # Tests de déploiement
```

---

## 🎓 Concepts Ansible expliqués

### 1. **Playbooks** (site.yml)
Fichier YAML déclaratif :
```yaml
- hosts: webservers
  roles:
    - common
    - nginx
    - nodejs
```
→ Dit : "sur les webservers, appliquer ces rôles"

### 2. **Roles** (roles/*)
Réutilisables, structurés :
- `tasks/main.yml` : Tâches à exécuter
- `handlers/main.yml` : Actions sur notification
- `templates/` : Templates Jinja2
- `files/` : Fichiers statiques
- `vars/main.yml` : Variables par défaut

### 3. **Tâches idempotentes** (tasks/)
```yaml
- name: Install nginx
  apt:
    name: nginx
    state: present
  become: yes
```
→ Exécuter 2 fois = même résultat ✅

### 4. **Variables** (group_vars/)
Organisées par groupe d'hôtes :
```yaml
# group_vars/webservers.yml
nginx_port: 80
nodejs_port: 3000
nodejs_version: "18.18.2"
```

### 5. **Handlers** (handlers/)
Exécutés une fois si "notified" :
```yaml
- name: restart nginx
  systemd:
    name: nginx
    state: restarted
  notify: "restart nginx"
```

### 6. **Jinja2 Templates** (templates/)
Dynamiques selon variables :
```nginx
# roles/nginx/templates/nginx.conf.j2
server {
    listen {{ nginx_port }};
    location / {
        proxy_pass http://localhost:{{ nodejs_port }};
    }
}
```

---

## 🚀 3 façons de déployer

### Option 1 : Docker Compose (Rapide, local)
```bash
cd projects/2026-06-19_ansible-web-stack
docker-compose up -d
ansible-playbook -i inventory/hosts.ini playbooks/site.yml
```

### Option 2 : Serveurs Linux réels
```bash
# Configurer inventaire
vim inventory/hosts.ini

# Copier clés SSH
ssh-copy-id -i ~/.ssh/id_rsa.pub user@web1.example.com

# Déployer
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -v
```

### Option 3 : Vagrant (VMs virtuelles)
```bash
vagrant up
# Ansible configure automatiquement!
```

---

## 📊 Cas d'usage pratiques

### Ajouter un nouveau serveur
```bash
# 1. Ajouter à l'inventaire
echo "web3.example.com" >> inventory/hosts.ini

# 2. Redéployer (idempotent!)
ansible-playbook playbooks/site.yml
```

### Mettre à jour une config
```bash
# 1. Modifier le template
vim roles/nginx/templates/nginx.conf.j2

# 2. Redéployer seulement Nginx
ansible-playbook playbooks/site.yml --tags nginx
```

### Exécuter une tâche ad-hoc
```bash
# Redémarrer tous les webservers
ansible webservers -m systemd -a "name=nginx state=restarted" -b

# Installer un paquet
ansible dbservers -m apt -a "name=htop state=present" -b
```

### Mode Debug
```bash
# Simuler (dry-run)
ansible-playbook playbooks/site.yml --check

# Verbose
ansible-playbook playbooks/site.yml -vvv
```

---

## 🔧 Fichiers clés

### ansible.cfg
```ini
[defaults]
inventory = inventory/hosts.ini
roles_path = ./roles
host_key_checking = False
pipelining = True
```

### roles/common/tasks/main.yml
```yaml
- name: Update apt cache
  apt:
    update_cache: yes
  become: yes

- name: Install base packages
  apt:
    name: [curl, wget, git, htop, vim]
    state: present
  become: yes
```

### roles/nginx/templates/nginx.conf.j2
```nginx
server {
    listen {{ nginx_port }};
    location / {
        proxy_pass http://localhost:{{ nodejs_port }};
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### roles/nodejs/files/app.js
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.json({ 
    message: 'Hello from Node.js',
    hostname: require('os').hostname()
  });
});

app.listen(3000);
```

---

## 📈 Architecture déployée

```
┌─────────────────────┐
│   Ansible Control   │  (laptop / CI/CD)
│   (orchestrate)     │
└──────────┬──────────┘
           │ SSH
    ┌──────┴──────┬──────────┬──────────┐
    │             │          │          │
┌───▼─┐       ┌───▼─┐   ┌────▼──┐  ┌───▼──┐
│Web1 │       │Web2 │   │  DB   │  │Monit.│
│ Ng  │       │ Ng  │   │ PG    │  │ Prom │
│Node │       │Node │   │       │  │NExp  │
└─────┘       └─────┘   └────────┘  └──────┘
  :80/:3000     :80/:3000  :5432    :9090
```

---

## 🎓 Apprentissage couvert

- ✅ Architecture Ansible agentless
- ✅ Playbooks et variables
- ✅ Rôles réutilisables et modulaires
- ✅ Jinja2 templates dynamiques
- ✅ Idempotence et gestion d'état
- ✅ Handlers et notifications
- ✅ Multi-serveur deployment
- ✅ SSH hardening et firewall (UFW)
- ✅ Systemd service management
- ✅ Monitoring intégré (Node Exporter)
- ✅ Scaling horizontal
- ✅ Debugging et troubleshooting

---

## 🔒 Bonnes pratiques incluses

1. **SSH keys** : Authentification sécurisée, pas de passwords
2. **Idempotence** : Playbooks sans danger si répétés
3. **Variables centralisées** : group_vars/ et host_vars/
4. **Rôles modulaires** : Réutilisables sur différents projets
5. **Tags** : Déploiements partiels possibles
6. **Handlers** : Redémarrages optimisés
7. **Become/sudo** : Gestion des droits admin
8. **Firewall** : UFW configuré par Ansible

---

## 🚀 Extensions possibles

1. **Ansible Vault** : Chiffrer les secrets (passwords, tokens)
   ```bash
   ansible-vault create group_vars/dbservers.yml
   ```

2. **Dynamic Inventory** : Intégrer AWS/GCP/Azure
   ```bash
   ansible-inventory --list -i inventory/aws_ec2.yml
   ```

3. **Continuous Deployment** : Lancer depuis GitHub Actions/Jenkins
   ```yaml
   # .github/workflows/deploy.yml
   ansible-playbook -i inventory/hosts.yml playbooks/site.yml
   ```

4. **Testing** : Molecule pour valider les rôles
   ```bash
   molecule test -s default
   ```

5. **Tower/AWX** : Interface web pour Ansible
   - Dashboard centralise
   - Audit trail et RBAC
   - Scheduling
   - Job templates

---

## 📈 Technos utilisées

| Tech | Rôle | Version |
|------|------|---------|
| **Ansible** | Configuration Management | 2.x+ |
| **Nginx** | Reverse Proxy / Web Server | Latest |
| **PostgreSQL** | Base de données | 15+ |
| **Node.js** | Runtime JavaScript | 18.18.2 |
| **Express** | Framework web | 4.18+ |
| **PM2** | Process manager | Latest |
| **Prometheus** | Time-series DB / Monitoring | 2.50.0 |
| **Node Exporter** | Prometheus client | 1.6.1 |
| **UFW** | Firewall | Built-in |
| **Systemd** | Service management | Built-in |

---

## ⏱️ Timeline du projet

| Étape | Durée |
|-------|-------|
| Setup Ansible | 10-15 min |
| Configuration inventaire | 5 min |
| Déploiement complet | 20-30 min |
| Validation/tests | 10 min |
| Modifications/iteration | 5 min par changement |
| **Total** | **1 journée** |

---

## 📚 Checkpoints d'apprentissage

- [ ] Comprendre Ansible architecture
- [ ] Configurer inventaire et variables
- [ ] Lire et écrire playbooks
- [ ] Créer un rôle simple
- [ ] Utiliser Jinja2 templates
- [ ] Tester en --check mode
- [ ] Déployer sur 3+ serveurs
- [ ] Debugging avec -v/-vvv
- [ ] Modifier et redéployer
- [ ] Scaling (ajouter/retirer serveurs)
- [ ] Tâches ad-hoc
- [ ] Organiser les variables

---

## 🎯 Commandes essentielles

```bash
# Installation
sudo apt install ansible

# Vérifier connectivité
ansible all -i inventory/hosts.ini -m ping

# Simuler (dry-run)
ansible-playbook playbooks/site.yml --check

# Déployer
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -v

# Redéployer un rôle
ansible-playbook playbooks/site.yml --tags nginx

# Tâche ad-hoc
ansible webservers -m shell -a "uptime"

# Debug
ansible-playbook playbooks/site.yml -vvv
```

---

## 📍 Localisation du projet

```
Repository: https://github.com/jaouadsiouahe1978/claude-devops-tools
Branch: main
Commit: 730b9f5
Dossier: projects/2026-06-19_ansible-web-stack/
```

---

## 🤝 Contribution

Le projet est **cloneable et exécutable** :
1. Clone le repo
2. Personnalise `inventory/hosts.ini`
3. Lance `ansible-playbook playbooks/site.yml`
4. C'est prêt!

Parfait pour apprendre Ansible en pratiquant sur des vrais serveurs ou Docker.

---

**Créé le**: 2026-06-19  
**Thème**: Ansible - Configuration Management  
**Niveau**: Intermédiaire  
**Prérequis**: Notions Linux, SSH, YAML  
**Prochaine session**: 2026-06-20

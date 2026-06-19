# 🚀 Ansible Web Stack Deployment

## 📋 Objectif

Apprendre **Ansible** en déployant une application web complète sur plusieurs serveurs :
- **Nginx** : serveur web / reverse proxy
- **PostgreSQL** : base de données
- **Node.js + Express** : application backend
- **Monitoring** : Prometheus + Node Exporter

**Niveau** : Intermédiaire  
**Durée** : 1 journée (15 min setup + 1-2h pratique)  
**Prérequis** : Notions de Linux, SSH, YAML

---

## 🎯 Concepts clés

### Ansible
- **Agentless** : SSH uniquement, rien à installer sur les serveurs
- **Idempotent** : exécuter 2 fois = même résultat
- **Declarative** : décrire l'état souhaité, pas les étapes
- **YAML** : format facile à lire et écrire

### Architecture du projet
```
┌─────────────────────┐
│   Ansible Control   │
│     (Localhost)     │
└──────────┬──────────┘
           │
    ┌──────┴──────┬──────────┬──────────┐
    │             │          │          │
┌───▼─┐       ┌───▼─┐   ┌────▼──┐  ┌───▼──┐
│Web1 │       │Web2 │   │  DB   │  │Monit.│
│Nginx│       │Nginx│   │Postgres│  │Prom  │
│Node │       │Node │   │        │  │      │
└─────┘       └─────┘   └────────┘  └──────┘
```

---

## 📁 Structure du projet

```
projects/2026-06-19_ansible-web-stack/
├── README.md                          # Ce fichier
├── QUICKSTART.md                      # Démarrage rapide
├── ansible.cfg                        # Configuration Ansible
├── inventory/
│   ├── hosts.ini                      # Inventaire statique
│   └── hosts.yml                      # Alternative en YAML
├── playbooks/
│   ├── site.yml                       # Playbook principal
│   ├── provision.yml                  # Provisionning OS
│   ├── deploy.yml                     # Déploiement app
│   └── monitoring.yml                 # Prometheus setup
├── roles/
│   ├── common/                        # Paquets communs, SSH, firewall
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   ├── handlers/
│   │   │   └── main.yml
│   │   └── templates/
│   │       ├── sshd_config.j2
│   │       └── 99-devops.conf.j2
│   ├── nginx/                         # Nginx + reverse proxy
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   ├── handlers/
│   │   │   └── main.yml
│   │   └── templates/
│   │       └── nginx.conf.j2
│   ├── postgres/                      # PostgreSQL setup
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   ├── handlers/
│   │   │   └── main.yml
│   │   └── vars/
│   │       └── main.yml
│   ├── nodejs/                        # Node.js + Express
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   ├── handlers/
│   │   │   └── main.yml
│   │   ├── files/
│   │   │   └── app.js                 # Application demo
│   │   └── templates/
│   │       └── .env.j2
│   ├── prometheus/                    # Monitoring
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   ├── handlers/
│   │   │   └── main.yml
│   │   └── templates/
│   │       ├── prometheus.yml.j2
│   │       └── node_exporter.service.j2
│   └── monitoring/                    # Node Exporter
│       ├── tasks/
│       │   └── main.yml
│       └── handlers/
│           └── main.yml
├── group_vars/                        # Variables par groupe
│   ├── all.yml                        # Communes à tous les hôtes
│   ├── webservers.yml                 # Spécifiques aux webservers
│   ├── dbservers.yml                  # Spécifiques aux DB
│   └── monitoring.yml                 # Spécifiques au monitoring
├── host_vars/                         # Variables par hôte
│   └── db1.example.com.yml
├── scripts/
│   ├── setup.sh                       # Setup initial
│   ├── ping-hosts.sh                  # Vérifier la connectivité
│   └── test-deployment.sh             # Tests post-déploiement
├── tests/
│   ├── test_nginx.yml                 # Test Nginx
│   ├── test_postgres.yml              # Test PostgreSQL
│   ├── test_nodejs.yml                # Test Node.js
│   └── test_all.yml                   # Tests complets
├── docker-compose.yml                 # Setup local de test
└── Vagrantfile                        # VM de test (optionnel)
```

---

## 🔧 Concepts Ansible expliqués

### 1. Inventaire (inventory/hosts.ini)
Liste des serveurs avec groupes :
```ini
[webservers]
web1.example.com
web2.example.com

[dbservers]
db1.example.com

[monitoring]
mon1.example.com

[all:vars]
ansible_user=devops
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### 2. Playbook (playbooks/site.yml)
Déclare les rôles pour chaque groupe :
```yaml
---
- hosts: webservers
  roles:
    - common
    - nginx
    - nodejs

- hosts: dbservers
  roles:
    - common
    - postgres

- hosts: monitoring
  roles:
    - common
    - prometheus
```

### 3. Roles (roles/*)
Réutilisables, structurés :
```
nginx/
├── tasks/main.yml          # Tâches (install, configure)
├── handlers/main.yml       # Notifications (restart service)
├── templates/nginx.conf.j2 # Templates Jinja2
└── defaults/main.yml       # Variables par défaut
```

### 4. Variables (group_vars/, host_vars/)
Organisées par groupe ou hôte :
```yaml
# group_vars/webservers.yml
nginx_port: 80
nodejs_port: 3000
nodejs_user: app
```

### 5. Handlers (handlers/main.yml)
Exécutés une fois à la fin si "notified" :
```yaml
- name: restart nginx
  systemd:
    name: nginx
    state: restarted
```

### 6. Tasks (tasks/main.yml)
Actions idempotentes :
```yaml
- name: Install nginx
  apt:
    name: nginx
    state: present
  become: yes

- name: Start nginx
  systemd:
    name: nginx
    state: started
    enabled: yes
  notify: restart nginx
```

---

## 🚀 Démarrage rapide

### Prérequis

```bash
# Installer Ansible
sudo apt update && sudo apt install -y ansible

# Générer clé SSH (si n'existe pas)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Copier clé sur les serveurs
ssh-copy-id -i ~/.ssh/id_rsa.pub user@web1.example.com
ssh-copy-id -i ~/.ssh/id_rsa.pub user@web2.example.com
ssh-copy-id -i ~/.ssh/id_rsa.pub user@db1.example.com
```

### Option 1 : Avec des VMs Linux réelles

```bash
cd projects/2026-06-19_ansible-web-stack

# 1. Configurer l'inventaire
vim inventory/hosts.ini
# Remplacer web1.example.com par votre IP/hostname réel

# 2. Tester la connectivité
ansible all -i inventory/hosts.ini -m ping

# 3. Voir ce que sera exécuté (dry-run)
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --check

# 4. Déployer
ansible-playbook -i inventory/hosts.yml playbooks/site.yml -v

# 5. Vérifier le déploiement
curl http://web1.example.com
psql -h db1.example.com -U postgres -c "SELECT 1"
```

### Option 2 : Avec Docker Compose (recommandé pour démarrer)

```bash
cd projects/2026-06-19_ansible-web-stack

# Lancer les conteneurs
docker-compose up -d

# Vérifier qu'ils tournent
docker-compose ps

# Obtenir les IPs
docker inspect $(docker ps -q) | grep '"IPAddress"'

# Configurer l'inventaire avec les IPs Docker
# Puis exécuter les playbooks

# Accéder à l'app
curl http://localhost:8080
# Ou directement à Nginx
curl http://localhost:80
```

### Option 3 : Avec Vagrant (VMs virtuelles)

```bash
cd projects/2026-06-19_ansible-web-stack

# Créer les VMs
vagrant up

# Ansible les configure automatiquement
# Grâce au provisioner Ansible dans Vagrantfile

# Accéder
curl http://192.168.33.10
curl http://192.168.33.11
curl http://192.168.33.20  # DB
```

---

## 📊 Étapes du déploiement

### Phase 1 : Préparation (5 min)
- [x] Installer Ansible
- [x] Générer SSH keys
- [x] Copier clés sur les serveurs
- [x] Tester ping Ansible

### Phase 2 : Déploiement initial (15 min)
```bash
ansible-playbook playbooks/site.yml
```
Roles appliqués :
1. **common** : Updates, SSH hardening, firewall
2. **nginx** : Installation, conf reverse proxy
3. **nodejs** : NVM, Node, PM2, app code
4. **postgres** : Installation, DB, users
5. **prometheus** : Monitoring, node-exporter

### Phase 3 : Validation (10 min)
```bash
ansible-playbook tests/test_all.yml
```
Vérifie :
- Nginx répond sur port 80
- Node.js répond sur port 3000
- PostgreSQL accessible
- Prometheus scrape les métriques

### Phase 4 : Optionnel - Mise à jour (5 min)
```bash
# Modifier une config
vim group_vars/webservers.yml

# Redéployer seulement cette partie
ansible-playbook playbooks/site.yml --tags "nginx"
```

---

## 💡 Cas d'usage pratiques

### 1. Ajouter un nouveau webserver
```bash
# 1. Ajouter à l'inventaire
echo "web3.example.com" >> inventory/hosts.ini

# 2. Redéployer (idempotent - pas de problème si répété)
ansible-playbook playbooks/site.yml

# 3. Vérifier
ansible webservers -m ping
```

### 2. Mettre à jour une config Nginx
```bash
# 1. Modifier le template
vim roles/nginx/templates/nginx.conf.j2

# 2. Redéployer seulement nginx
ansible-playbook playbooks/site.yml --tags "nginx"
```

### 3. Changer les variables pour une env différente
```bash
# 1. Créer un inventaire de staging
cp inventory/hosts.ini inventory/hosts-staging.ini

# 2. Adapter les IPs
vim inventory/hosts-staging.ini

# 3. Déployer sur staging
ansible-playbook -i inventory/hosts-staging.ini playbooks/site.yml
```

### 4. Exécuter une tâche ad-hoc
```bash
# Redémarrer tous les webservers
ansible webservers -m systemd -a "name=nginx state=restarted" -b

# Afficher la version Nginx sur tous les hosts
ansible all -m shell -a "nginx -v"

# Installer un paquet sur les DBs
ansible dbservers -m apt -a "name=htop state=present" -b
```

---

## 🔍 Debugging

### Verbose levels
```bash
# Normal
ansible-playbook playbooks/site.yml

# -v : Affiche les tâches
ansible-playbook playbooks/site.yml -v

# -vv : Affiche les variables, les résultats
ansible-playbook playbooks/site.yml -vv

# -vvv : Affiche la connexion SSH
ansible-playbook playbooks/site.yml -vvv

# -vvvv : Debug extrême
ansible-playbook playbooks/site.yml -vvvv
```

### Mode Check (dry-run)
```bash
# Simuler l'exécution sans faire de changements
ansible-playbook playbooks/site.yml --check

# Avec verbose
ansible-playbook playbooks/site.yml --check -v
```

### Différence entre exécutions
```bash
# Voir les changements effectués
ansible-playbook playbooks/site.yml --check -v | grep changed

# Exécuter sur un hôte spécifique
ansible-playbook playbooks/site.yml -l web1.example.com
```

---

## 📚 Fichiers clés expliqués

### ansible.cfg
Configuration globale d'Ansible :
```ini
[defaults]
inventory = inventory/hosts.ini
roles_path = ./roles
host_key_checking = False
```

### roles/common/tasks/main.yml
```yaml
---
- name: Update package cache
  apt:
    update_cache: yes
  become: yes

- name: Install base packages
  apt:
    name: "{{ packages }}"
    state: present
  become: yes
  vars:
    packages:
      - curl
      - wget
      - git
      - htop
      - vim
      - net-tools
```

### roles/nginx/templates/nginx.conf.j2
Template Jinja2 - dynamique selon les variables :
```nginx
server {
    listen {{ nginx_port }};
    server_name _;

    location / {
        proxy_pass http://localhost:{{ nodejs_port }};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### roles/nodejs/files/app.js
Application Express simple :
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.json({ 
    message: 'Hello from Node.js', 
    hostname: require('os').hostname(),
    time: new Date()
  });
});

app.listen(3000, () => console.log('Server running on :3000'));
```

---

## 🎓 Apprentissage couvert

- ✅ Ansible architecture et concepts
- ✅ Inventaires et variables
- ✅ Playbooks et roles
- ✅ Jinja2 templates
- ✅ Idempotence
- ✅ SSH hardening
- ✅ Firewall management
- ✅ Multi-serveur deployment
- ✅ Service management (systemd)
- ✅ Monitoring integration
- ✅ Testing et validation
- ✅ Scaling horizontal (ajouter serveurs)

---

## 🔒 Bonnes pratiques

1. **SSH keys** : Toujours utiliser des clés, pas des mots de passe
2. **Idempotence** : Les playbooks doivent être sans danger si répétés
3. **Variables** : Centraliser via group_vars et host_vars
4. **Roles** : Réutilisables et modulaires
5. **Tests** : Valider après chaque déploiement
6. **Vault** : Pour les secrets (passwords, tokens)
7. **Tags** : Permettre des déploiements partiels

---

## 🚀 Extensions

1. **Ansible Vault** : Chiffrer les secrets
   ```bash
   ansible-vault create group_vars/dbservers.yml
   ```

2. **Continuous Deployment** : Lancer depuis CI/CD
   ```bash
   # Dans GitHub Actions / Jenkins
   ansible-playbook -i inventory/hosts.yml playbooks/site.yml
   ```

3. **Dynamic Inventory** : Intégrer AWS/GCP/Azure
   ```bash
   # Récupérer les serveurs automatiquement
   ansible-inventory --list -i inventory/aws_ec2.yml
   ```

4. **Molecule** : Tester les roles
   ```bash
   molecule test -s default
   ```

5. **Tower / AWX** : Interface web
   - Dashboard
   - Audit trail
   - RBAC
   - Scheduling

---

## 📈 Technos utilisées

| Tech | Rôle |
|------|------|
| **Ansible** | Configuration Management |
| **Nginx** | Reverse Proxy / Web Server |
| **PostgreSQL** | Base de données relationnelle |
| **Node.js + Express** | Application backend |
| **Prometheus** | Monitoring des métriques |
| **Node Exporter** | Export métriques système |
| **SSH** | Communication entre Ansible et serveurs |
| **Systemd** | Service management |

---

## ⏱️ Durée estimée

- **Setup** : 10-15 minutes
- **Déploiement complet** : 20-30 minutes
- **Tests** : 5-10 minutes
- **Modifications** : 5 min par changement
- **Total première fois** : 1-2 heures

---

## 🎯 Checkpoints d'apprentissage

- [ ] Comprendre Ansible sans agent
- [ ] Configurer inventaire et variables
- [ ] Lire et modifier playbooks
- [ ] Créer un role simple
- [ ] Utiliser Jinja2 templates
- [ ] Tester en mode --check
- [ ] Déployer sur plusieurs serveurs
- [ ] Debugging avec -v/-vv
- [ ] Utiliser handlers et notifications
- [ ] Scaling (ajouter/retirer serveurs)

---

## 📍 Localisation

```
Repository: https://github.com/jaouadsiouahe1978/claude-devops-tools
Branch: main
Dossier: projects/2026-06-19_ansible-web-stack/
```

---

**Créé le** : 2026-06-19  
**Thème** : Ansible - Configuration Management  
**Niveau** : Intermédiaire  
**Temps estimé** : 1 journée

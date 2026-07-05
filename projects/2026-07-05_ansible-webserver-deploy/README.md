# Ansible Webserver Deployment Project

## 📋 Objectif
Déployer une architecture multi-serveur (web, base de données, monitoring) complète avec **Ansible** en tant qu'Infrastructure-as-Code. Ce projet enseigne la gestion centralisée de la configuration sans agent.

## 🏗️ Architecture
```
Control Node (Ansible)
    ├─→ Web Servers (Nginx + PHP)
    ├─→ Database Server (PostgreSQL)
    └─→ Monitoring (Node Exporter)
```

## 🛠️ Technologies
- **Ansible** - Orchestration et configuration management
- **Nginx** - Web server
- **PostgreSQL** - Relation database
- **Node Exporter** - Prometheus metrics
- **YAML** - Configuration déclarative

## 📋 Pré-requis
```bash
# Install Ansible
pip install ansible

# SSH keys configuration (for remote hosts)
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
```

## 🚀 Étapes de réalisation

### 1. Configuration d'inventaire
Créer `inventory.yml` avec les hôtes cibles (IP, variables par groupe)

### 2. Playbooks de base
- `01-deploy-webservers.yml` - Installation Nginx + PHP
- `02-deploy-database.yml` - Installation PostgreSQL
- `03-deploy-monitoring.yml` - Installation Node Exporter

### 3. Rôles Ansible (réutilisabilité)
```
roles/
  ├── webserver/     # Rôle pour web servers
  ├── database/      # Rôle pour base de données
  └── monitoring/    # Rôle pour monitoring
```

### 4. Tests
```bash
ansible-playbook playbooks/site.yml --syntax-check
ansible-playbook playbooks/site.yml --check (dry-run)
ansible-playbook playbooks/site.yml (exécution réelle)
```

### 5. Gestion avancée
- Variables par environnement (dev, staging, prod)
- Handlers pour redémarrage services
- Asynchronous tasks pour les tâches longues
- Error handling et conditionals

## 📚 Concepts clés apprennés
1. **Infrastructure-as-Code** - Version control + reproducibility
2. **Idempotence** - Exécution multiple = même résultat
3. **Ansible Roles** - Modularité et réutilisabilité
4. **Playbook structure** - Tasks, handlers, variables
5. **Ad-hoc commands** - Exécution rapide sans playbook
6. **Facts gathering** - Détection automatique de la configuration
7. **Secrets management** - Ansible Vault pour données sensibles

## 💡 Cas d'usage réels
- Déploiement d'applications web scalables
- Configuration des serveurs en masse (100+)
- Gestion de plusieurs environnements (dev/prod)
- Patch management automatisé
- Disaster recovery et provisioning

## ⚡ Commandes essentielles
```bash
# Lancer un playbook complet
ansible-playbook playbooks/site.yml -i inventory.yml

# Lancer un rôle spécifique
ansible-playbook playbooks/site.yml -i inventory.yml --tags "webserver"

# Exécuter une commande ad-hoc
ansible webservers -i inventory.yml -m apt -a "name=nginx state=present"

# Lancer en mode verbose
ansible-playbook playbooks/site.yml -vvv

# Tester sans appliquer les changements
ansible-playbook playbooks/site.yml --check
```

## 📊 Structure du projet
```
2026-07-05_ansible-webserver-deploy/
├── inventory.yml                    # Hosts et groupes
├── playbooks/
│   ├── site.yml                    # Main playbook
│   ├── webservers.yml
│   ├── database.yml
│   └── monitoring.yml
├── roles/
│   ├── webserver/
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── vars/main.yml
│   │   ├── templates/
│   │   └── files/
│   ├── database/
│   └── monitoring/
├── host_vars/
│   └── database-server.yml
├── group_vars/
│   ├── webservers.yml
│   └── all.yml
├── ansible.cfg                     # Configuration Ansible
└── tests/
    └── test-connection.yml
```

## 🎯 Livrables
- ✅ Playbook d'orchestration complète
- ✅ 3 rôles réutilisables
- ✅ Variables séparation dev/prod
- ✅ Documentation pour chaque rôle
- ✅ Playbook de test et validation

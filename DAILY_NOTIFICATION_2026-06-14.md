# Daily DevOps Project - 2026-06-14

## 🎯 Project: Ansible Infrastructure Automation

**Thème** : Infrastructure-as-Code avec Ansible  
**Niveau** : Débutant à Intermédiaire  
**Durée estimée** : 1 journée  

---

## 📝 Description

Apprendre **Ansible** en construisant une infrastructure complète et réutilisable. Ce projet couvre les concepts essentiels de l'automation DevOps :

### Ce qu'on crée
- **4 playbooks** : base-setup, web-deployment, database-deployment, monitoring
- **4 roles réutilisables** : base, webserver, database, monitoring
- **Infrastructure paramétrée** : Nginx (HTTP/HTTPS), PostgreSQL (avec backups), node_exporter
- **Concept d'idempotence** : playbooks exécutables n fois = 1x

### Technos utilisées
- **Ansible** : orchestration sans agent
- **Jinja2** : templates dynamiques
- **YAML** : configuration lisible
- **Nginx** : web server avec SSL auto-signé
- **PostgreSQL** : database avec users/DBs
- **node_exporter** : monitoring agent

---

## 🧠 Ce qu'on apprend

### Concepts clés
1. **Inventory** : Lister et grouper les serveurs
2. **Playbooks** : Orchestration de tâches
3. **Roles** : Structure réutilisable et modulaire
4. **Handlers** : Actions conditionnelles (redémarrages)
5. **Variables** : Paramétrage dynamique (group_vars, host_vars)
6. **Jinja2 Templates** : Générer des configs adaptées à chaque serveur
7. **Idempotence** : Chaque tâche doit être idempotente
8. **Error Handling** : Gérer les cas d'erreur

### Compétences pratiques
- ✅ Configurer un inventory multi-groupes
- ✅ Écrire des playbooks idiomatiques
- ✅ Structurer des roles réutilisables
- ✅ Utiliser les variables efficacement
- ✅ Créer et déployer des templates
- ✅ Automatiser le déploiement complet d'une app
- ✅ Déboguer les playbooks (verbose, dry-run, facts)

---

## 📂 Structure du projet

```
2026-06-14_ansible-infrastructure-automation/
├── ansible.cfg                         # Config Ansible
├── inventory/
│   ├── hosts.ini                       # Inventory (groupes de serveurs)
│   └── host_vars/                      # Variables par hôte
├── group_vars/
│   ├── all.yml                         # Variables globales
│   ├── webservers.yml                  # Variables web servers
│   └── databases.yml                   # Variables databases
├── roles/
│   ├── base/                           # Rôle setup système
│   │   ├── tasks/main.yml              # Tâches (packages, SSH, firewall)
│   │   ├── handlers/main.yml           # Handlers (restart services)
│   │   └── templates/                  # Templates (chrony, ufw)
│   ├── webserver/                      # Rôle Nginx
│   │   ├── tasks/main.yml              # Install/configure Nginx
│   │   ├── handlers/main.yml
│   │   └── templates/                  # nginx.conf, vhost.conf
│   ├── database/                       # Rôle PostgreSQL
│   │   ├── tasks/main.yml              # Install/configure DB
│   │   └── templates/                  # backup.sh
│   └── monitoring/                     # Rôle node_exporter
│       ├── tasks/main.yml              # Install monitoring agent
│       └── templates/                  # service file
├── playbooks/
│   ├── 00-full-stack.yml               # Déployer tout
│   ├── 01-base-setup.yml               # Base système
│   ├── 02-deploy-web.yml               # Web servers
│   ├── 03-deploy-database.yml          # Database
│   └── 04-deploy-monitoring.yml        # Monitoring
├── Makefile                            # Commandes utiles
├── QUICKSTART.md                       # Guide démarrage rapide
├── ANSIBLE-CONCEPTS.md                 # Guide complet des concepts
└── README.md                           # Documentation complète
```

---

## 🚀 Démarrage rapide

```bash
cd projects/2026-06-14_ansible-infrastructure-automation/

# 1. Installer Ansible
pip install ansible

# 2. Vérifier la config
ansible-playbook --syntax-check playbooks/*.yml

# 3. Tester en dry-run
ansible-playbook -C playbooks/01-base-setup.yml -v

# 4. Déployer
ansible-playbook playbooks/00-full-stack.yml -v

# 5. Vérifier
ansible all -m ping
ansible all -m setup
```

---

## 🎓 Points clés à retenir

### Idempotence (🔑 concept le plus important)
- ✅ `package`, `template`, `lineinfile` sont idempotents
- ❌ `shell`, `command` ne le sont pas (à utiliser avec `creates:` ou `changed_when:`)
- **Impact** : Tu peux relancer les playbooks sans crainte

### Handlers (pour les redémarrages)
```yaml
tasks:
  - name: Change config
    template: src=app.conf.j2 dest=/etc/app.conf
    notify: restart app      # Déclenche le handler

handlers:
  - name: restart app
    systemd: name=app state=restarted   # Ne s'exécute qu'une fois
```

### Structure des roles
- `tasks/main.yml` : ce qu'on installe/configure
- `handlers/main.yml` : actions (redémarrages, reloads)
- `templates/` : fichiers Jinja2 dynamiques
- `vars/` : variables du rôle
- `defaults/` : valeurs par défaut (override-ables)

### Variables et priorité
1. Ligne de commande : `-e "var=value"`
2. Host vars : `inventory/host_vars/hostname.yml`
3. Group vars : `group_vars/groupname.yml`
4. Role defaults : `roles/rolename/defaults/main.yml`

---

## ✅ Validation

- [ ] Ansible installé et à jour
- [ ] Inventory créé avec au moins 3 groupes
- [ ] Playbook 01 (base) exécuté avec succès
- [ ] Playbook 02 (web) exécuté et Nginx accessible
- [ ] Playbook 03 (DB) exécuté et PostgreSQL running
- [ ] Playbook 04 (monitoring) exécuté et metrics exposées
- [ ] Playbook 00 exécuté (déploiement complet)
- [ ] Tous les playbooks idempotents (2e run = 0 changements)

---

## 🔗 Ressources

- Docs Ansible : https://docs.ansible.com/
- Best practices : https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html
- Jinja2 : https://docs.ansible.com/ansible/latest/user_guide/playbooks_templating.html
- Ansible Galaxy : https://galaxy.ansible.com/

---

## 📊 Fichiers créés

**Total** : 26 fichiers + 1 README complet

- **Playbooks** : 5 fichiers YAML
- **Roles** : 4 rôles avec 22 fichiers (tasks, handlers, templates)
- **Configuration** : inventory.ini, group_vars (3), ansible.cfg
- **Documentation** : README.md, QUICKSTART.md, ANSIBLE-CONCEPTS.md, Makefile

---

## 🎯 Next Steps

1. **Tester localement** : Commencer sur localhost avant de toucher des vrais serveurs
2. **Ajouter tes apps** : Créer des rôles pour tes applications spécifiques
3. **Ansible Vault** : Sécuriser les secrets (passwords, keys)
4. **CI/CD integration** : GitHub Actions + Ansible
5. **Dynamic Inventory** : AWS, Azure, Proxmox, etc.
6. **Molecule** : Tester les rôles automatiquement
7. **Kubernetes** : Déployer Kubernetes avec Ansible

---

**Créé le** : 2026-06-14  
**Apprendre** : Ansible, Infrastructure-as-Code, automation, best practices DevOps  
**Dépôt** : https://github.com/jaouadsiouahe1978/claude-devops-tools

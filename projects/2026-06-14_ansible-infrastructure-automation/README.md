# Ansible Playbook - Automation d'Infrastructure Linux

## 🎯 Objectif
Apprendre **Ansible** en automatisant le déploiement et la configuration d'une infrastructure Linux multi-serveurs. Tu vas créer des playbooks réutilisables pour provisionner des serveurs, installer des applications, gérer les utilisateurs et les services. C'est la base de toute automation DevOps en production.

## 📋 Pré-requis
- Ansible installé (`pip install ansible`)
- 3-5 serveurs Linux (VMs, conteneurs Docker, ou même localhost)
- SSH configuré et clés d'authentification prêtes
- Python 3.8+ sur les serveurs cibles
- Environ 30 min de setup

## 🛠 Technos utilisées
- **Ansible** : orchestration et automation sans agent
- **Jinja2** : templates pour configurations dynamiques
- **YAML** : format de configuration lisible
- **SSH** : communication sécurisée avec les serveurs
- **Docker** (optionnel) : pour tester sur des conteneurs

## 📚 Ce qu'on apprend

### Concepts clés
1. **Inventory** : définir les serveurs à gérer (statique/dynamique)
2. **Playbooks** : orchestration de tâches idempotentes
3. **Roles** : réutilisation de code (structure standards)
4. **Handlers** : déclencher des actions conditionnelles (redémarrages, etc)
5. **Variables et Facts** : paramétrage dynamique des configurations
6. **Jinja2 Templates** : générer des fichiers config adaptés à chaque serveur
7. **Error handling** : gérer les erreurs et les cas limites

### Compétences pratiques
- Configurer un inventory avec groupes d'hôtes
- Écrire des playbooks idiomatiques (idempotents)
- Créer une structure de roles réutilisables
- Utiliser les variables et facts pour paramétrer
- Tester et déboguer des playbooks
- Déployer une application complète (web + DB)

## 🚀 Étapes de réalisation

### 1. Installer Ansible
```bash
# Sur macOS/Linux
pip install ansible

# Vérifier l'installation
ansible --version
```

### 2. Préparer l'inventory
- Créer `inventory/hosts.ini` avec 3 serveurs (ou localhost)
- Grouper par rôle : webservers, databases, monitoring

### 3. Premier playbook : infrastructure de base
```bash
ansible-playbook playbooks/01-base-setup.yml
```
Cela va :
- Mettre à jour les packages
- Installer des outils essentiels (git, curl, vim, etc)
- Configurer NTP et timezone
- Durcir le système (firewall, SSH)

### 4. Deuxième playbook : déployer une app web
```bash
ansible-playbook playbooks/02-deploy-web.yml
```
Cela va :
- Installer Nginx/Apache
- Configurer les virtual hosts (via Jinja2 templates)
- Déployer une app exemple (HTML simple ou Node.js)
- Configurer les certificats SSL (auto-signé)

### 5. Troisième playbook : déployer une base de données
```bash
ansible-playbook playbooks/03-deploy-database.yml
```
Cela va :
- Installer MySQL/PostgreSQL
- Créer des users et des DBs
- Configurer les backups
- Mettre en place un monitoring basique

### 6. Playbook orchestration : déployer tout
```bash
ansible-playbook playbooks/00-full-stack.yml
```
Lance tous les playbooks dans l'ordre correct avec dépendances.

### 7. Tester et valider
```bash
# Vérifier la syntaxe
ansible-playbook --syntax-check playbooks/*.yml

# Mode dry-run (sans rien changer)
ansible-playbook -C playbooks/01-base-setup.yml

# Voir les facts des serveurs
ansible all -m setup

# Exécuter une commande ad-hoc sur tous les serveurs
ansible all -m shell -a "uptime"
```

## 📂 Structure du projet
```
.
├── inventory/
│   ├── hosts.ini                   # Inventory statique
│   └── host_vars/
│       ├── webserver1.yml          # Variables spécifiques par hôte
│       └── dbserver.yml
├── group_vars/
│   ├── webservers.yml              # Variables par groupe
│   ├── databases.yml
│   └── all.yml                     # Variables globales
├── roles/
│   ├── base/                       # Rôle setup système
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   ├── templates/
│   │   ├── handlers/
│   │   │   └── main.yml
│   │   └── vars/
│   │       └── main.yml
│   ├── webserver/                  # Rôle Nginx
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── files/
│   ├── database/                   # Rôle MySQL/PostgreSQL
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── handlers/
│   └── monitoring/                 # Rôle Node Exporter
│       ├── tasks/
│       └── files/
├── playbooks/
│   ├── 00-full-stack.yml           # Orchestration complète
│   ├── 01-base-setup.yml           # Setup de base
│   ├── 02-deploy-web.yml           # Déployer web
│   ├── 03-deploy-database.yml      # Déployer DB
│   └── 04-deploy-monitoring.yml    # Déployer monitoring
├── group_vars/
│   └── all.yml                     # Variables communes
├── ansible.cfg                     # Configuration Ansible
└── Makefile                        # Commandes utiles
```

## 🔍 Points clés à comprendre

1. **Idempotence** : exécuter un playbook 10 fois = 1 fois. Les tâches doivent être idempotentes.
2. **Facts** : Ansible collecte des infos sur chaque serveur (OS, IP, packages). Utilise-les !
3. **Handlers** : ne se déclenchent qu'une seule fois même si plusieurs tâches les appellent.
4. **Jinja2** : `{{ variable }}` dans les templates - remplacées au runtime.
5. **Vault** : stocker les secrets (passwords, keys) de manière sécurisée.

## ✅ Validation

- [ ] Ansible installé et en version récente
- [ ] Inventory créé avec au moins 3 serveurs ou localhost
- [ ] Playbook 01 exécuté avec succès (packages installés)
- [ ] Playbook 02 exécuté (web server accessible)
- [ ] Playbook 03 exécuté (DB créée et testée)
- [ ] Playbook 00 exécuté (orchestration complète)
- [ ] Tous les playbooks idempotents (2e run = 0 changements)
- [ ] Roles bien structurés et réutilisables

## 🎓 Next Steps
- Ajouter dynamic inventory (AWS, Azure, Proxmox)
- Intégrer avec CI/CD (GitHub Actions + Ansible)
- Mettre en place Ansible Vault pour les secrets
- Apprendre Ansible Collections (modules communautaires)
- Tester avec Molecule (test framework pour roles)
- Déployer Kubernetes avec Ansible

## 📚 Ressources
- Ansible docs: https://docs.ansible.com/
- Best practices: https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html
- Jinja2 in Ansible: https://docs.ansible.com/ansible/latest/user_guide/playbooks_templating.html
- Ansible Galaxy: https://galaxy.ansible.com/ (roles communautaires)

## 💡 Tips
- Commence par tester en local (`localhost`) avant de toucher des vrais serveurs
- Utilise `ansible-lint` pour valider la qualité de tes playbooks
- Active le verbosity avec `-v`, `-vv`, ou `-vvv` pour déboguer
- Les roles doivent être réutilisables et pas spécifiques à un projet

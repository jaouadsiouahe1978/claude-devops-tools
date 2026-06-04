# Ansible Multi-Server Deployment with Roles

## Description
Automatiser le déploiement et la configuration de multiples serveurs (web + monitoring) avec Ansible, en utilisant les bonnes pratiques : roles, inventaires, variables et playbooks réutilisables.

## Objectif d'Apprentissage
- Maîtriser la structure des roles Ansible
- Gérer les inventaires et les groupes de serveurs
- Utiliser les variables (hostvars, groupvars)
- Déployer une stack applicative complète de façon idempotente
- Documenter l'infrastructure as code

## Technologies
- Ansible 2.9+
- Python 3.8+
- SSH (pour la connexion aux serveurs)
- Linux (CentOS/Ubuntu)

## Prérequis
```bash
# Installer Ansible
sudo apt-get install ansible -y

# Ou avec pip
pip install ansible>=2.9

# Vérifier l'installation
ansible --version
```

## Structure du Projet
```
.
├── ansible.cfg                 # Configuration Ansible
├── inventories/
│   ├── production.ini          # Inventaire production
│   └── staging.ini             # Inventaire staging
├── roles/
│   ├── common/                 # Tâches communes à tous les serveurs
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   └── templates/
│   ├── webserver/              # Configuration serveur web (Nginx)
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── templates/
│   │   └── files/
│   └── monitoring/             # Installation Prometheus/Node Exporter
│       ├── tasks/main.yml
│       ├── handlers/main.yml
│       └── templates/
├── group_vars/
│   ├── all.yml                 # Variables partagées
│   ├── webservers.yml          # Variables groupe webservers
│   └── monitoring.yml          # Variables groupe monitoring
├── host_vars/
│   └── web1.yml                # Variables spécifiques à un hôte
├── site.yml                    # Playbook principal
├── web_deploy.yml              # Playbook déploiement web
└── monitoring_setup.yml        # Playbook monitoring
```

## Étapes de Réalisation

### 1. Configuration Ansible (ansible.cfg)
```bash
# Créé automatiquement pour optimiser les performances
```

### 2. Inventaires
- **Production** : 3 serveurs web + 1 serveur monitoring
- **Staging** : 1 serveur pour test

### 3. Roles

#### Common Role
- Mise à jour système
- Installation packages utiles (curl, git, wget, etc.)
- Configuration SSH
- Configuration timezone

#### Webserver Role
- Installation Nginx
- Configuration virtualhost
- SSL/TLS (auto-signé pour test)
- Logs rotation

#### Monitoring Role
- Installation Node Exporter
- Configuration Prometheus
- Scrape configs

### 4. Playbooks
- **site.yml** : Déploiement complet
- **web_deploy.yml** : Déploiement web uniquement
- **monitoring_setup.yml** : Monitoring uniquement

## Usage

### 1. Préparer les serveurs
```bash
# Vérifier la connexion SSH
ansible all -i inventories/production.ini -m ping

# Lister les hôtes
ansible-inventory -i inventories/production.ini --list
```

### 2. Exécuter les playbooks

#### Déploiement complet
```bash
ansible-playbook -i inventories/production.ini site.yml
```

#### Déploiement web uniquement
```bash
ansible-playbook -i inventories/production.ini web_deploy.yml
```

#### Déploiement monitoring
```bash
ansible-playbook -i inventories/production.ini monitoring_setup.yml
```

#### Avec vault (secrets)
```bash
ansible-playbook -i inventories/production.ini site.yml --ask-vault-pass
```

### 3. Syntaxe et validation
```bash
# Vérifier la syntaxe
ansible-playbook --syntax-check site.yml

# Dry-run (check mode)
ansible-playbook -i inventories/production.ini site.yml --check

# Verbose
ansible-playbook -i inventories/production.ini site.yml -v
```

## Cas d'Usage

### Déployer sur serveur spécifique
```bash
ansible-playbook -i inventories/production.ini site.yml -l web1
```

### Exécuter une task spécifique
```bash
ansible-playbook -i inventories/production.ini site.yml -t nginx
```

### Déboguer une task
```bash
ansible-playbook -i inventories/production.ini site.yml -vvv
```

## Ce qu'on apprend

1. **IaC (Infrastructure as Code)** : Définir l'infrastructure en code
2. **Idempotence** : Exécuter sans risque plusieurs fois
3. **Scalabilité** : Gérer 1 ou 100 serveurs de la même façon
4. **Réutilisabilité** : Roles prêts pour d'autres projets
5. **Versioning** : Git-friendly, collaborative
6. **Monitoring** : Supervision d'infrastructure
7. **Best practices** : Secrets, variables, handlers, notifications

## Fichiers Clés

- `ansible.cfg` : Configuration globale Ansible
- `inventories/production.ini` : Liste des serveurs
- `roles/*/tasks/main.yml` : Logique d'exécution
- `group_vars/` : Variables par groupe
- `site.yml` : Point d'entrée

## Ressources Utiles

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Galaxy](https://galaxy.ansible.com/) : Roles communautaires
- [Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)

## Notes

- Les inventaires doivent être adaptés à vos serveurs réels
- Les templates utilisent Jinja2
- Les handlers permettent les redémarrages conditionnels
- Variables peuvent être encryptées avec ansible-vault

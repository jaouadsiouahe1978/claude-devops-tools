# Ansible - Déploiement Multi-Serveurs avec Playbooks

## Description

Ce projet démontre comment utiliser **Ansible** pour automatiser le déploiement et la configuration d'une infrastructure multi-serveurs. L'application cible est une pile classique avec :
- **Serveurs Web** (Nginx + Node.js app)
- **Serveur Base de Données** (PostgreSQL)
- **Serveur de Monitoring** (Prometheus)

## Objectif Pédagogique

À la fin de ce projet, tu sauras :
- ✅ Structurer des playbooks Ansible professionnels avec des rôles
- ✅ Gérer un inventaire dynamique avec variables par groupe/hôte
- ✅ Automatiser le provisioning et le déploiement d'applications
- ✅ Utiliser les templates Jinja2 pour la configuration
- ✅ Implémenter des idempotence checks et des handlers
- ✅ Gérer les secrets avec Ansible Vault (optionnel)
- ✅ Déployer en One-Shot sur 3+ serveurs

## Prérequis

```bash
# Installation d'Ansible
sudo apt-get install -y ansible
# ou
pip install ansible

# Vérifier la version
ansible --version

# Avoir SSH configuré sur les serveurs cibles
# (ou utiliser Docker/Vagrant pour simuler)
```

## Architecture du Projet

```
ansible-multi-deploy/
├── ansible.cfg              # Configuration Ansible
├── inventory/
│   ├── hosts.ini           # Inventaire statique
│   ├── group_vars/
│   │   ├── webservers.yml  # Variables pour le groupe web
│   │   └── dbservers.yml   # Variables pour le groupe BD
│   └── host_vars/
│       └── web1.yml        # Variables spécifiques à web1
├── roles/
│   ├── common/             # Setup commun (users, packages, firewall)
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   └── templates/
│   ├── webserver/          # Déploiement Nginx + App
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   └── templates/
│   └── database/           # Installation PostgreSQL
│       └── tasks/main.yml
└── playbooks/
    ├── site.yml            # Playbook principal (orchestration)
    └── deploy.yml          # Playbook de déploiement simple
```

## Étapes de Réalisation

### 1. Préparation de l'Inventaire

Définir les serveurs cibles :
```bash
# Éditer inventory/hosts.ini
[webservers]
web1 ansible_host=192.168.1.10
web2 ansible_host=192.168.1.11

[dbservers]
db1 ansible_host=192.168.1.20

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### 2. Créer les Rôles

#### Rôle `common` : Setup de base
- Mettre à jour les packages
- Créer des utilisateurs
- Configurer le firewall basique
- Installer des outils (git, curl, etc.)

#### Rôle `webserver` : Déploiement Web
- Installer Nginx
- Installer Node.js
- Déployer l'application depuis Git
- Configurer des templates Jinja2

#### Rôle `database` : Base de Données
- Installer PostgreSQL
- Créer des databases et utilisateurs
- Configurer l'accès réseau

### 3. Orchestration Principale

Le playbook `site.yml` applique les rôles dans l'ordre :
```yaml
- hosts: webservers
  roles:
    - common
    - webserver

- hosts: dbservers
  roles:
    - common
    - database
```

### 4. Variables et Templating

Utiliser les `group_vars` et `host_vars` pour :
- Adapter la config par environnement (dev/prod)
- Passer des secrets (si pas Vault)
- Personnaliser par serveur

### 5. Tester et Déployer

```bash
# Vérifier la syntaxe
ansible-playbook playbooks/site.yml --syntax-check

# Mode dry-run (rien n'est appliqué)
ansible-playbook playbooks/site.yml --check

# Exécuter le déploiement complet
ansible-playbook playbooks/site.yml -v

# Exécuter sur un groupe spécifique
ansible-playbook playbooks/site.yml --limit webservers
```

## Ce Qu'On Apprend

- **IaC (Infrastructure as Code)** : La configuration est versionnée et reproductible
- **Idempotence** : Exécuter 2 fois = même résultat (pas de double application)
- **Rôles et Modularité** : Réutiliser du code pour plusieurs projets
- **Variables Dynamiques** : Adapter sans changer le code
- **Gestion d'État** : Handlers pour redémarrer services si config change
- **Scaling Horizontal** : Ajouter un serveur dans l'inventaire = déploiement auto

## Commandes Utiles

```bash
# Lister les hosts disponibles
ansible-inventory --list

# Tester la connexion SSH
ansible all -m ping

# Exécuter une commande ad-hoc
ansible webservers -m apt -a "name=curl state=present"

# Afficher les faits d'un serveur
ansible web1 -m setup | head -20

# Mode verbose/debug
ansible-playbook playbooks/site.yml -vvv
```

## Aller Plus Loin

- **Ansible Galaxy** : Utiliser des rôles pré-construits
- **Vault** : Chiffrer les secrets (passwords, tokens)
- **Dynamic Inventory** : Récupérer les hosts depuis AWS/Azure/etc
- **Docker/Vagrant** : Tester localement avant prod
- **CI/CD** : Exécuter les playbooks automatiquement

## Ressources

- [Ansible Documentation Officielle](https://docs.ansible.com/)
- [Best Practices Ansible](https://docs.ansible.com/ansible/latest/tips_tricks/index.html)
- [Ansible Galaxy - Rôles Communautaires](https://galaxy.ansible.com/)

---

**Créé pour l'apprentissage DevOps/SRE - Jaouad**

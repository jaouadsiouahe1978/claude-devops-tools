# Configuration Automatisée d'un Serveur Linux avec Ansible

## Objectif
Ce projet démontre comment utiliser Ansible pour automatiser la configuration d'un serveur Linux. On configure un serveur avec :
- Packages système essentiels (curl, git, htop, etc.)
- Un serveur web Nginx
- Règles firewall (UFW)
- Gestion des utilisateurs et permissions
- Configuration idempotente (on peut rejouer sans casse)

## Technologies
- **Ansible** : Framework d'orchestration et gestion de configuration
- **Nginx** : Serveur web
- **UFW** : Firewall simple
- **Linux** : Ubuntu/Debian ou RHEL

## Pré-requis
- Serveur(s) Linux accessible en SSH
- Ansible installé localement : `pip install ansible`
- Accès SSH configuré (clé publique ou mot de passe)
- Python sur les serveurs distants

## Étapes de réalisation

### 1. Préparation
```bash
# Installer Ansible
pip install ansible

# Cloner ou télécharger ce projet
cd projects/2026-09-16_ansible-server-config

# Modifier inventory.ini avec vos serveurs réels
# Exemple :
# [webservers]
# 192.168.1.100 ansible_user=ubuntu
```

### 2. Tester la connexion
```bash
ansible all -i inventory.ini -m ping
```

### 3. Exécuter le playbook
```bash
# Mode dry-run pour voir les changements sans les appliquer
ansible-playbook -i inventory.ini playbooks/site.yml --check

# Exécution réelle
ansible-playbook -i inventory.ini playbooks/site.yml
```

### 4. Vérifier
```bash
# Accéder au serveur
ssh ubuntu@192.168.1.100

# Vérifier Nginx
sudo systemctl status nginx

# Vérifier firewall
sudo ufw status

# Tester le serveur web
curl http://localhost
```

## Contenu des Rôles

### Role `common`
- Mise à jour des packages
- Installation des outils essentiels (curl, git, htop, vim)
- Configuration du timezone
- Création de répertoires système

### Role `webserver`
- Installation et configuration de Nginx
- Création d'une page d'accueil personnalisée (template Jinja2)
- Gestion du service (démarrage automatique)

### Role `firewall`
- Installation de UFW (Uncomplicated Firewall)
- Ouverture des ports nécessaires (22, 80, 443)
- Activation du firewall

## Ce qu'on apprend

✅ **Infrastructure as Code (IaC)** : Versionnez votre configuration système  
✅ **Ansible Playbooks** : Structure de playbooks et tasks  
✅ **Rôles Ansible** : Organisation modulaire et réutilisable  
✅ **Templates Jinja2** : Générer des fichiers de config dynamiques  
✅ **Idempotence** : Rejouer les playbooks sans casse  
✅ **Gestion de configuration** : Automatiser les déploiements  
✅ **Agentless** : Pas de client à installer, juste SSH  

## Structure du Projet
```
.
├── README.md                    # Ce fichier
├── ansible.cfg                  # Configuration Ansible
├── inventory.ini                # Inventaire des serveurs
├── playbooks/
│   └── site.yml                 # Playbook principal
└── roles/
    ├── common/
    │   └── tasks/main.yml       # Tasks de base
    ├── webserver/
    │   └── tasks/main.yml       # Installation Nginx
    └── firewall/
        └── tasks/main.yml       # Configuration UFW
```

## Extensions possibles
- Ajouter un rôle `database` pour PostgreSQL/MySQL
- Ajouter un rôle `monitoring` pour Prometheus/Grafana
- Gérer les variables par environnement (prod, dev, staging)
- Utiliser des vault Ansible pour les secrets
- Intégrer dans une CI/CD pipeline

## Ressources
- [Documentation Ansible](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_and_tricks.html)
- [Ansible Galaxy](https://galaxy.ansible.com/) : Rôles réutilisables

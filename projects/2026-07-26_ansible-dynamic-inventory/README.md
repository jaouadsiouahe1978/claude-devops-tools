# Ansible Configuration Management avec Inventaire Dynamique

## Objectif
Apprendre à gérer une infrastructure multi-serveurs avec Ansible en utilisant un inventaire dynamique (basé sur des scripts Python), des playbooks réutilisables, et des roles pour une gestion de configuration robuste et modulaire.

## Technologies Utilisées
- **Ansible** : Orchestration et gestion de configuration
- **Python** : Script d'inventaire dynamique
- **Jinja2** : Templating pour les configurations
- **Linux** : Serveurs cibles (Ubuntu, CentOS)
- **SSH** : Connexion aux serveurs

## Architecture
```
├── inventory/
│   ├── hosts.py          # Inventaire dynamique (script Python)
│   └── group_vars/
│       ├── webservers.yml
│       └── dbservers.yml
├── roles/
│   ├── common/           # Tâches communes (user, packages)
│   ├── webserver/        # Nginx/Apache
│   ├── database/         # PostgreSQL/MySQL
│   └── monitoring/       # Prometheus agent
├── playbooks/
│   ├── deploy_web.yml
│   ├── deploy_db.yml
│   └── full_stack.yml
├── ansible.cfg           # Configuration Ansible
└── requirements.txt      # Dépendances Python
```

## Prérequis
- Ansible 2.10+ installé sur la machine de contrôle
- Python 3.8+ sur les serveurs cibles
- SSH configuré sans authentification par mot de passe (clés SSH)
- Accès root ou sudo aux serveurs cibles
- Au minimum 2 serveurs Linux (locaux, VM, ou cloud)

## Étapes de Réalisation

### 1. Installation & Configuration de Base
```bash
pip install -r requirements.txt
ansible --version
```

### 2. Comprendre l'Inventaire Dynamique
L'inventaire Python génère dynamiquement la liste des hôtes en fonction :
- Des variables d'environnement
- De fichiers de configuration
- Permettant de tester avec des serveurs fictifs

### 3. Créer les Roles Ansible
Chaque rôle encapsule une fonctionnalité :
- **common** : Mises à jour, utilisateurs, packages de base
- **webserver** : Installation et configuration Nginx
- **database** : Installation PostgreSQL + utilisateurs
- **monitoring** : Agent Prometheus + exporters

### 4. Créer les Playbooks
- Orchestrer les roles dans un ordre logique
- Utiliser les variables de groupe
- Implémenter les handlers pour services

### 5. Tester l'Exécution
```bash
ansible-inventory -i inventory/hosts.py --list
ansible-playbook playbooks/deploy_web.yml -i inventory/hosts.py -v
```

## Ce qu'on Apprend

### Concepts Ansible
- **Inventaires dynamiques** : Adapter la découverte à votre infra
- **Roles** : Modularité et réutilisabilité
- **Templates Jinja2** : Configuration paramétrable
- **Handlers** : Redémarrage de services
- **Variables** : Organisation par groupes d'hôtes
- **Idempotence** : Exécutions répétées sans effet négatif

### Bonnes Pratiques DevOps
- Infrastructure as Code (IaC)
- Configuration versionée
- Reproductibilité
- Scalabilité (facilité d'ajouter des serveurs)
- Documentation du déploiement

### Cas d'Usage Réels
- Déploiement multi-environnement (dev, staging, prod)
- Gestion de configuration à grande échelle
- Automatisation des mises à jour de sécurité
- Provision de serveurs cloud

## Exécution Rapide

1. **Tester l'inventaire** :
```bash
cd projects/2026-07-26_ansible-dynamic-inventory
python3 inventory/hosts.py
```

2. **Voir la structure** :
```bash
ansible-inventory -i inventory/hosts.py --graph
```

3. **Exécuter un playbook** (sur inventaire fictif) :
```bash
ansible-playbook playbooks/deploy_web.yml -i inventory/hosts.py --check
```

## Améliorations Futures
- Intégration avec Terraform pour créer les serveurs
- CI/CD pour valider les playbooks (ansible-lint, molecule)
- Chiffrement des secrets (ansible-vault)
- Monitoring de la conformité (ansible-compliance)
- Intégration Tower/AWX pour l'UI

## Ressources
- [Documentation Ansible Officielle](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/index.html)
- [Ansible Galaxy](https://galaxy.ansible.com/) - Community roles

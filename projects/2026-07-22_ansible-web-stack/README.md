# Ansible - Déploiement automatisé d'une Stack Web

## Description
Déployer une stack web complète (Nginx + PostgreSQL) sur plusieurs serveurs Linux en utilisant Ansible. Ce projet vous enseigne les principes fondamentaux de l'Infrastructure as Code (IaC) avec Ansible : inventaires, playbooks, rôles, handlers et variables.

## Objectif
- Automatiser le déploiement d'une application web multi-serveurs
- Maîtriser la structure des playbooks Ansible
- Gérer la configuration déclarative vs procédurale
- Appliquer les bonnes pratiques DevOps (idempotence, rôles réutilisables)

## Technos utilisées
- **Ansible** : Orchestration et gestion de configuration
- **Nginx** : Serveur web et reverse proxy
- **PostgreSQL** : Base de données relationnelle
- **Linux** (Ubuntu/CentOS) : Systèmes cibles
- **Docker** (optionnel) : Simuler plusieurs serveurs pour les tests

## Structure du projet
```
2026-07-22_ansible-web-stack/
├── README.md
├── docker-compose.yml        # Environnement de test (VMs simulées)
├── inventory/
│   ├── hosts.ini             # Inventaire des serveurs
│   └── group_vars/
│       ├── webservers.yml    # Variables pour les serveurs web
│       └── databases.yml     # Variables pour les BDD
├── roles/
│   ├── common/               # Setup commun (updates, packages)
│   ├── nginx/                # Installation et config Nginx
│   └── postgresql/           # Installation et config PostgreSQL
├── playbooks/
│   ├── site.yml              # Playbook principal
│   └── deploy.yml            # Déploiement de l'appli
└── files/
    ├── nginx.conf            # Config Nginx
    └── app_init.sql          # Initialisation BDD
```

## Pré-requis
- Ansible 2.9+ installé localement
- Docker et Docker Compose (pour le test local)
- SSH configuré pour accéder aux serveurs cibles
- Python 3 sur les serveurs cibles

## Étapes de réalisation

### 1. Installer Ansible (5 min)
```bash
pip install ansible
ansible --version
```

### 2. Préparer l'environnement de test (10 min)
Lancer les conteneurs simulant les serveurs :
```bash
docker-compose up -d
```

Vérifier la connexion SSH :
```bash
ansible -i inventory/hosts.ini all -m ping
```

### 3. Créer les rôles (30 min)
- **Role `common`** : installer les packages de base (git, curl, htop)
- **Role `nginx`** : compiler/installer Nginx, gérer la config
- **Role `postgresql`** : installer PostgreSQL, créer les BD/utilisateurs

### 4. Définir l'inventaire (10 min)
Lister les serveurs par groupe (webservers, databases) avec variables d'environnement.

### 5. Écrire les playbooks (20 min)
- `site.yml` : orchestre le déploiement sur tous les groupes
- Utiliser handlers pour les restart de services (idempotence)

### 6. Tester le déploiement (15 min)
```bash
# Dry-run (voir ce qui sera changé)
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --check

# Déploiement réel
ansible-playbook -i inventory/hosts.ini playbooks/site.yml

# Valider : Nginx répond, PostgreSQL est up
curl http://localhost:8080
psql -h localhost -U appuser -d app_db
```

## Ce qu'on apprend
✅ **Structures Ansible** : inventaires, playbooks, rôles, handlers
✅ **Idempotence** : déploiements sûrs et reproductibles
✅ **Gestion de configuration** : centraliser et versionner les configs
✅ **Multi-tier architecture** : séparer web et BDD
✅ **Orchestration** : déployer sur plusieurs serveurs en parallèle
✅ **Debugging** : utiliser les modules de fact-gathering et debug

## Améliorations possibles
- Ajouter un rôle `backup` pour sauvegarder les BDD
- Implémenter un health check dans les handlers
- Utiliser Ansible Vault pour les secrets (passwords)
- Ajouter un rôle de monitoring/logging avec Prometheus/ELK

## Durée estimée
**2-3 heures** pour l'implémentation complète.

## Ressources
- [Ansible Documentation](https://docs.ansible.com)
- [Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)
- [Working with Roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)

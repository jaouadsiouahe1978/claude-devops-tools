# Ansible Deploy Stack - Automatisation Multi-Serveurs

## 📋 Objectif

Créer une infrastructure automatisée avec **Ansible** pour déployer une stack complète (Nginx, PostgreSQL, App Python) sur plusieurs serveurs avec gestion centralisée de la configuration.

## 🎯 Ce que vous apprendrez

- **Ansible Playbooks** : écrire et exécuter des tâches d'automatisation
- **Inventaire dynamique** : gérer plusieurs hôtes avec groupes et variables
- **Handlers & Notifications** : redémarrer services intelligemment
- **Roles Ansible** : organiser le code en modules réutilisables
- **Templates Jinja2** : générer des fichiers de config personnalisés
- **Idempotence** : écrire des tâches réexécutables sans effet de bord

## 🔧 Technologies utilisées

- **Ansible 2.10+** : orchestration d'infrastructure
- **Docker** : conteneurisation des services
- **PostgreSQL** : base de données
- **Nginx** : reverse proxy / web server
- **Python Flask** : application web légère

## 📦 Structure du projet

```
2026-06-09_ansible-deploy-stack/
├── README.md
├── inventory/
│   ├── hosts.ini              # Inventaire des serveurs
│   └── group_vars/
│       ├── webservers.yml     # Variables pour groupe webservers
│       └── databases.yml      # Variables pour groupe databases
├── roles/
│   ├── docker/                # Rôle : installer Docker
│   ├── nginx/                 # Rôle : configurer Nginx
│   ├── postgres/              # Rôle : setup PostgreSQL
│   └── app/                   # Rôle : déployer l'app Python
├── site.yml                   # Playbook principal
├── deploy.yml                 # Playbook de déploiement spécifique
├── provision.sh               # Script de setup initial
└── docker-compose.override.yml # Pour tests locaux
```

## 🚀 Étapes de réalisation (1 jour)

### Étape 1 : Installation & Setup (30 min)
```bash
# Installer Ansible localement
pip install ansible

# Créer la structure des répertoires
cd projects/2026-06-09_ansible-deploy-stack/
mkdir -p roles/{docker,nginx,postgres,app}/{tasks,templates,files,handlers,defaults}
mkdir -p inventory/group_vars
```

### Étape 2 : Créer l'inventaire (20 min)
- Définir les groupes de serveurs (webservers, databases)
- Ajouter les variables globales et par groupe
- Configurer la connexion SSH (user, port, clés)

### Étape 3 : Écrire les rôles (2 heures)
Chaque rôle contient :
- **tasks/main.yml** : les tâches d'installation/config
- **handlers/main.yml** : redémarrage des services
- **templates/** : fichiers de configuration (jinja2)
- **defaults/main.yml** : variables par défaut

**Rôles à implémenter :**
1. **docker** : installer Docker + docker-compose
2. **nginx** : déployer Nginx en conteneur
3. **postgres** : déployer PostgreSQL en conteneur
4. **app** : déployer l'application Python

### Étape 4 : Playbooks principaux (1 heure)
- `site.yml` : playbook complet de configuration
- `deploy.yml` : redéploiement rapide de l'app

### Étape 5 : Test & Validation (30 min)
```bash
# Syntaxe check
ansible-playbook --syntax-check site.yml

# Dry-run
ansible-playbook -i inventory/hosts.ini site.yml --check

# Exécution réelle
ansible-playbook -i inventory/hosts.ini site.yml

# Redéploiement avec tags
ansible-playbook -i inventory/hosts.ini deploy.yml -t app
```

## 📚 Concepts clés d'Ansible

### 1. Inventaire
Définit quels serveurs gérer et comment les grouper.

### 2. Playbooks
Fichiers YAML listant les tâches à exécuter.

### 3. Roles
Dossiers organisant les tâches, templates et variables.

### 4. Handlers
Actions déclenchées uniquement si une tâche change l'état (ex: redémarrer service).

### 5. Jinja2 Templates
Fichiers de config dynamiques avec variables.

## 💡 Cas d'usage réels

- ✅ Déployer la même app sur 10+ serveurs
- ✅ Mettre à jour configuration en parallèle
- ✅ Gérer dépendances entre services
- ✅ Rollback rapide de déploiement
- ✅ Provisionner l'infra cloud (AWS, Terraform + Ansible)

## 🔍 Prochaines étapes

- Intégrer avec **Terraform** pour provisionner les VMs
- Ajouter des **tests** avec Molecule
- Utiliser **Ansible Vault** pour les secrets
- Implémenter des **tags** pour exécutions partielles
- Configurer des **health checks** post-déploiement

## 📖 Ressources utiles

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/index.html)
- [Molecule Testing Framework](https://molecule.readthedocs.io/)
- [Ansible Galaxy](https://galaxy.ansible.com/)

## ⚡ Tips d'optimisation

- Utiliser **`async`** pour tâches longues
- Implémenter du **caching** avec `register`
- Utiliser **`loop`** plutôt que `with_*` (deprecated)
- Toujours utiliser **`notify`** pour handlers
- Tester avec **`--check`** avant exécution réelle

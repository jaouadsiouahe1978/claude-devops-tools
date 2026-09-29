# Ansible Infrastructure Automation

## Description
Ce projet démontre l'automatisation d'une infrastructure multi-serveurs avec Ansible. Vous allez orchestrer le déploiement d'une application web complète avec serveur Nginx, base de données PostgreSQL et monitoring avec Prometheus.

**Cas d'usage**: Provisionner et configurer une infrastructure complète de production sans intervention manuelle sur chaque serveur.

## Technos
- **Ansible 2.10+** : Orchestration et configuration management
- **Docker** : Containerisation (optionnel pour la démo)
- **Nginx** : Reverse proxy et serveur web
- **PostgreSQL** : Base de données
- **Prometheus** : Monitoring et alertes
- **SystemD** : Gestion des services

## Prérequis
```bash
# Installer Ansible
sudo apt-get update && sudo apt-get install -y ansible

# Vérifier l'installation
ansible --version

# SSH keys (pour accès aux serveurs)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

## Structure du projet
```
.
├── inventory/
│   ├── hosts.yml          # Inventaire des serveurs
│   └── group_vars/        # Variables par groupe
├── roles/
│   ├── webserver/         # Rôle Nginx
│   ├── database/          # Rôle PostgreSQL
│   └── monitoring/        # Rôle Prometheus
├── playbooks/
│   ├── site.yml           # Playbook principal
│   ├── deploy.yml         # Déploiement app
│   └── monitoring.yml     # Déploiement monitoring
├── scripts/
│   ├── setup-lab.sh       # Crée VMs de test
│   └── test-playbook.sh   # Teste les playbooks
└── templates/             # Templates Jinja2
```

## Étapes de réalisation

### 1. Préparer l'environnement de lab
```bash
# Créer 3 VMs locales (Vagrant) ou serveurs cloud
./scripts/setup-lab.sh

# Ou configurer manuellement dans inventory/hosts.yml
```

### 2. Configurer l'inventaire
Définir les groupes de serveurs (web, db, monitoring) dans `inventory/hosts.yml`.

### 3. Créer les rôles Ansible
Développer les rôles pour chaque composant :
- **Webserver** : Installer Nginx, déployer app, configurer SSL
- **Database** : Installer PostgreSQL, créer BD, backups
- **Monitoring** : Installer Prometheus, exporters, alertes

### 4. Écrire les playbooks
- `site.yml` : Playbook d'orchestration complète
- `deploy.yml` : Déployer une nouvelle version
- `monitoring.yml` : Configurer le monitoring

### 5. Tester les playbooks
```bash
# Syntaxe check
ansible-playbook playbooks/site.yml --syntax-check

# Dry-run (affiche les changements sans les appliquer)
ansible-playbook playbooks/site.yml --check

# Exécution réelle
ansible-playbook playbooks/site.yml -v
```

### 6. Mettre en place l'idempotence
S'assurer que les playbooks peuvent être exécutés plusieurs fois sans effets de bord.

## Ce qu'on apprend

✅ **Orchestration infrastructure-as-code** : Gérer des centaines de serveurs avec du code reproductible
✅ **Roles et modularity** : Réutiliser des composants Ansible dans différents projets
✅ **Inventory management** : Organiser les serveurs en groupes et sous-groupes
✅ **Variables Jinja2** : Templater configs dynamiquement
✅ **Handlers et notifications** : Déclencher actions (restart service) conditionnellement
✅ **Ansible best practices** : Structure, nommage, documentation
✅ **CI/CD avec Ansible** : Intégrer Ansible dans pipelines GitHub Actions/Jenkins
✅ **Configuration dérivée** : Générer configs depuis variables centralisées

## Quick Start

```bash
# 1. Installer Ansible
sudo apt-get install -y ansible

# 2. Préparer un lab avec Vagrant (optionnel)
cd scripts && ./setup-lab.sh

# 3. Configurer SSH vers vos serveurs
# Modifier inventory/hosts.yml avec vos adresses IPs

# 4. Tester la connectivité
ansible all -i inventory/hosts.yml -m ping

# 5. Exécuter le playbook complet
ansible-playbook -i inventory/hosts.yml playbooks/site.yml -v

# 6. Vérifier l'état
curl http://<web-server-ip>
psql -h <db-server-ip> -U postgres -l
```

## Ressources
- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Ansible Modules Reference](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html)
- [Ansible Galaxy](https://galaxy.ansible.com/) - Rôles pre-built

## Auteur
Projet DevOps quotidien | Jaouad - Formation DevOps/SRE

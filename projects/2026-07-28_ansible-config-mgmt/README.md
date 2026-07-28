# Ansible Configuration Management - Déploiement Multi-Machine

## 📋 Description
Déploiement et configuration automatisée de plusieurs serveurs Linux en utilisant Ansible. Ce projet couvre les principes fondamentaux de l'Infrastructure as Code (IaC) avec Ansible :
- **Inventaires dynamiques** : gestion de plusieurs machines
- **Playbooks** : automatisation de tâches complexes
- **Roles** : réutilisation de configurations modulaires
- **Handlers** : gestion des services et redémarrages
- **Variables et templates** : configuration personnalisée par machine

## 🎯 Objectif
Mettre en place une architecture automatisée qui configure :
1. **Web Servers** (nginx) - 2 instances
2. **Database Server** (PostgreSQL) - 1 instance
3. **Monitoring Server** (Prometheus) - 1 instance

Tout cela avec une **seule commande Ansible** sans intervention manuelle.

## 🛠️ Technologies utilisées
- **Ansible 2.9+** : orchestration et configuration management
- **Vagrant/Docker** : environnement de test multi-machine
- **Docker Compose** : simulation d'une architecture distribuée
- **Jinja2 Templates** : génération dynamique de configurations
- **YAML** : syntax des playbooks et inventaires

## 📚 Prérequis
- Ansible 2.9+ installé
- Docker et Docker Compose
- SSH configuré (ou Docker en mode non-SSH)
- Git

## 🚀 Étapes de réalisation

### 1. Structure du projet
```
projects/2026-07-28_ansible-config-mgmt/
├── README.md                 # Ce fichier
├── docker-compose.yml        # Environnement multi-container simulant des serveurs
├── ansible.cfg              # Configuration Ansible
├── inventory.yml            # Inventaire des machines (statique et dynamique)
├── playbooks/
│   ├── main.yml             # Playbook principal orchestrant tout
│   ├── common.yml           # Tasks communes à tous les serveurs
│   ├── web-servers.yml      # Configuration des serveurs web
│   ├── database.yml         # Configuration PostgreSQL
│   └── monitoring.yml       # Configuration Prometheus
├── roles/
│   ├── common/              # Role: packages communs, SSH, firewall
│   ├── nginx/               # Role: installation et config nginx
│   ├── postgresql/          # Role: installation et config PostgreSQL
│   └── prometheus/          # Role: installation et config Prometheus
└── files/                   # Fichiers statiques à déployer
└── templates/               # Templates Jinja2
```

### 2. Configuration des containers
Le `docker-compose.yml` crée une infrastructure simulée :
- **web1, web2** : Alpine Linux + OpenSSH (serveurs web)
- **db** : Alpine Linux + PostgreSQL
- **monitoring** : Alpine Linux + Prometheus
- **control** : Ansible runner avec accès SSH à tous

### 3. Inventaire Ansible
Gestion de groupes de machines :
```yaml
all:
  children:
    webservers:
      hosts:
        web1:
        web2:
    databases:
      hosts:
        db:
    monitoring:
      hosts:
        prometheus:
```

### 4. Playbooks et Roles
- **common.yml** : mise à jour packages, install SSH, config sudoers
- **web-servers.yml** : install/config nginx, déployer index.html personnalisé
- **database.yml** : install PostgreSQL, créer DB et user
- **monitoring.yml** : install Prometheus, configuration scrape targets

### 5. Templates Jinja2
- `nginx.conf.j2` : configuration nginx avec variables
- `prometheus.yml.j2` : configuration Prometheus avec targets dynamiques
- `postgresql.conf.j2` : optimisation PostgreSQL par groupe

### 6. Validation et test
```bash
# Lancer le play en mode dry-run pour valider
ansible-playbook playbooks/main.yml --check --diff

# Exécuter la configuration réelle
ansible-playbook playbooks/main.yml

# Vérifier l'état des services
ansible all -m service -a "name=nginx state=started enabled=yes"

# Récupérer des facts depuis toutes les machines
ansible all -m setup
```

## 📖 Ce qu'on apprend

### Concepts Ansible
1. **Inventaires** : organiser et grouper les machines
2. **Playbooks** : définir des workflows d'automatisation
3. **Roles** : factoriser et réutiliser des configurations
4. **Handlers** : recharger les services quand la config change
5. **Variables** : adapter la config à chaque machine/groupe
6. **Templates Jinja2** : générer des fichiers de config dynamiques
7. **Idempotence** : relancer plusieurs fois sans casser le système
8. **Fact gathering** : récupérer l'état des serveurs

### Pratiques DevOps
- Infrastructure as Code (IaC) : tout en fichiers versionnés
- Immuabilité : provisionner de zéro facilement
- Scalabilité : ajouter des serveurs simplement
- Traçabilité : chaque change est versionné
- Testabilité : valider avant de déployer

## 🎓 Exercices progressifs

**Niveau 1 - Débutant**
1. Déployer la stack avec docker-compose
2. Lancer le playbook main.yml en --check
3. Vérifier la syntaxe avec `ansible-playbook --syntax-check`

**Niveau 2 - Intermédiaire**
4. Modifier les versions de nginx/PostgreSQL dans les vars
5. Ajouter un nouveau groupe (cache Redis)
6. Créer un handler personnalisé
7. Utiliser des variables d'inventaire pour changer les ports

**Niveau 3 - Avancé**
8. Créer des conditions (when) pour différencier prod/dev
9. Ajouter des tests post-déploiement (health checks)
10. Implémenter le rolling deployment avec serial
11. Créer des secrets avec Ansible Vault

## 🧪 Test du déploiement

```bash
# 1. Démarrer l'infra
docker-compose up -d

# 2. Vérifier la connectivité
ansible all -i inventory.yml -m ping

# 3. Lancer le playbook en dry-run
ansible-playbook -i inventory.yml playbooks/main.yml --check

# 4. Exécuter le déploiement
ansible-playbook -i inventory.yml playbooks/main.yml

# 5. Valider les services
curl http://localhost:8080   # nginx sur web1
curl http://localhost:8081   # nginx sur web2
ansible db -m postgresql_query -a "query=SELECT version();"

# 6. Cleanup
docker-compose down
```

## 💡 Points clés d'apprentissage
- Les roles Ansible permettent de factoriser du code réutilisable
- Les templates Jinja2 rendent les configs dynamiques et adaptables
- L'idempotence garantit qu'on peut relancer les playbooks sans risque
- Les handlers optimisent les restarts en groupant les notifications
- Les variables permettent d'adapter à chaque environnement
- Un inventaire bien structuré est la clé d'une scalabilité aisée

## 📝 Commandes essentielles

```bash
# Vérifier la syntaxe
ansible-playbook playbooks/main.yml --syntax-check

# Dry-run avec diff
ansible-playbook playbooks/main.yml --check --diff

# Exécution réelle
ansible-playbook playbooks/main.yml -v

# Cibler un groupe spécifique
ansible-playbook playbooks/main.yml -l webservers

# Lister tous les hosts
ansible all -i inventory.yml --list-hosts

# Récupérer les facts
ansible all -i inventory.yml -m setup | grep "ansible_os_family"

# Test de connectivité
ansible all -i inventory.yml -m ping
```

## 📚 Ressources
- [Ansible Official Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Ansible Galaxy - Roles Community](https://galaxy.ansible.com/)

---
**Créé le**: 2026-07-28  
**Durée estimée**: 1 jour (débutant à intermédiaire)  
**Difficulté**: ⭐⭐⭐ (Intermédiaire)

# Ansible - Déploiement Automatisé d'Application Web sur AWS

## 📋 Description
Ce projet démontre comment utiliser **Ansible** pour automatiser le déploiement d'une application web moderne sur des instances AWS EC2. Vous apprendrez les concepts clés d'Ansible et comment orchestrer des tâches complexes sur plusieurs serveurs.

**Technologies** : Ansible, AWS EC2, Nginx, Python/Flask, Systemd, Handlers

## 🎯 Objectifs d'apprentissage
- ✅ Configurer Ansible (inventory, ansible.cfg)
- ✅ Créer et utiliser des roles réutilisables
- ✅ Déployer une application multi-tier (web + cache)
- ✅ Gérer les dépendances avec handlers
- ✅ Utiliser des variables et templates Jinja2
- ✅ Gérer les erreurs et les conditions
- ✅ Automatiser les mises à jour et le monitoring

## 📦 Pré-requis
```bash
# Installer Ansible
pip install ansible boto3 botocore

# Avoir accès à AWS avec les credentials configurées
# Avoir des clés SSH pour les instances EC2
```

## 📂 Structure du Projet
```
├── README.md
├── ansible.cfg                 # Configuration Ansible
├── inventory/
│   ├── hosts.ini              # Hosts statiques (dev/prod)
│   ├── aws_ec2.yml            # Plugin inventaire dynamique AWS
│   └── group_vars/
│       └── webservers.yml      # Variables partagées par le groupe
├── roles/
│   ├── common/                # Tâches communes à tous les serveurs
│   ├── webserver/             # Installation Nginx + app
│   ├── redis/                 # Cache Redis
│   └── monitoring/            # Agent monitoring
├── playbooks/
│   ├── site.yml               # Playbook principal
│   ├── deploy.yml             # Déploiement de l'app
│   ├── rollback.yml           # Rollback de version
│   └── monitoring.yml         # Configuration monitoring
├── templates/
│   ├── nginx.conf.j2          # Template Nginx
│   └── app-systemd.service.j2 # Service systemd
├── files/
│   └── app.py                 # Application exemple
├── group_vars/
│   └── all.yml                # Variables globales
└── requirements.txt           # Dépendances Python
```

## 🚀 Démarrage

### 1. Configurer l'inventaire
Éditez `inventory/hosts.ini` avec vos instances AWS:
```ini
[webservers]
web1.example.com ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/aws.pem
web2.example.com ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/aws.pem

[cacheservers]
cache1.example.com ansible_user=ec2-user

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

### 2. Vérifier la connectivité
```bash
ansible all -i inventory/hosts.ini -m ping
```

### 3. Exécuter le playbook de déploiement
```bash
# Déploiement complet
ansible-playbook -i inventory/hosts.ini playbooks/site.yml

# Déploiement de l'app seulement
ansible-playbook -i inventory/hosts.ini playbooks/deploy.yml

# Avec tags spécifiques
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --tags nginx

# En mode dry-run
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --check
```

### 4. Rollback de version
```bash
ansible-playbook -i inventory/hosts.ini playbooks/rollback.yml -e "app_version=1.0.0"
```

## 🔑 Concepts Ansible à retenir

### Roles
Les roles sont des collections de tâches, handlers, templates organisés de manière standard.

```yaml
# Utilisation d'un role
- hosts: webservers
  roles:
    - common
    - webserver
```

### Handlers
Les handlers ne s'exécutent qu'une fois, même s'ils sont notifiés plusieurs fois.

```yaml
- name: Change nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: restart nginx

- name: restart nginx
  service:
    name: nginx
    state: restarted
```

### Variables
Les variables peuvent venir de plusieurs sources (inventory, group_vars, host_vars, playbook).

```yaml
# Priorité (bas au haut):
# 1. defaults/main.yml (dans un role)
# 2. inventory variables
# 3. group_vars
# 4. host_vars
# 5. task variables
```

### Idempotence
Ansible devrait être idempotent - exécuter 2x = exécuter 1x.

```yaml
# ✅ Bon: crée le fichier s'il n'existe pas, ne le modifie pas s'il existe
- file:
    path: /etc/app/config.yml
    state: touch

# ❌ Mauvais: toujours exécute la commande
- shell: echo "foo" > /tmp/bar
```

## 📊 Cas d'usage avancés

### Déploiement Blue-Green
```yaml
- name: Blue-Green Deployment
  hosts: webservers
  serial: "50%"  # Déploie par 50% à la fois
  tasks:
    - name: Deploy new version
      # ... tâches de déploiement ...
    
    - name: Health check
      # ... vérifier la santé ...
```

### Inventaire dynamique AWS
```bash
# Avec le plugin aws_ec2
ansible-inventory -i inventory/aws_ec2.yml --graph
ansible -i inventory/aws_ec2.yml tag_Environment_production -m ping
```

### Asynchrone et boucles
```yaml
- name: Async tasks
  command: "sleep {{ item }}"
  loop: [10, 20, 30]
  async: 60
  poll: 5
```

## 🧪 Tests et validation

```bash
# Vérification de syntaxe
ansible-playbook --syntax-check playbooks/site.yml

# Dry-run
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --check

# Verbose output
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -vv

# Afficher les variables
ansible-inventory -i inventory/hosts.ini --host web1.example.com
```

## 📈 Métriques de succès
- ✅ Déployer l'app sans erreur
- ✅ Vérifier que Nginx fonctionne
- ✅ L'app répond sur port 8000
- ✅ Rollback fonctionne
- ✅ Idempotence confirmée (2x = 1x)

## 📚 Ressources supplémentaires
- [Ansible Documentation](https://docs.ansible.com/)
- [Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/index.html)
- [AWS Plugin](https://docs.ansible.com/ansible/latest/collections/amazon/aws/index.html)
- [Jinja2 Templating](https://jinja.palletsprojects.com/)

## 📝 Améliorations possibles
- [ ] Ajouter Vault pour gérer les secrets
- [ ] Intégrer avec AWX pour une UI
- [ ] Ajouter des tests avec Molecule
- [ ] Implémenter une stratégie de cache distribuée
- [ ] Monitoring avancé avec Prometheus
- [ ] Auto-scaling avec terraform + ansible

---
**Durée estimée** : 1 journée (6-8h)  
**Niveau** : Intermédiaire  
**Créé le** : 2026-10-02

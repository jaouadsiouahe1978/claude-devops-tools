# Quick Start Guide - Ansible Server Provisioning

## 🚀 5 Minutes Setup

### 1. Prérequis
```bash
# Sur votre machine locale
sudo apt-get install ansible

# Créer une clé SSH (si pas encore fait)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

### 2. Configurer l'inventaire
Éditer `inventory.ini` et décommenter les lignes appropriées ou ajouter vos serveurs :

```ini
[webservers]
your-server.com ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

### 3. Tester la connectivité
```bash
ansible all -i inventory.ini -m ping
```

### 4. Exécuter le playbook
```bash
# Configuration complète
ansible-playbook -i inventory.ini site.yml

# Ou avec tags pour cibler des rôles spécifiques
ansible-playbook -i inventory.ini site.yml --tags "webserver"
ansible-playbook -i inventory.ini site.yml --tags "monitoring"
```

## 📝 Cas d'usage avancés

### Provisionner juste les webservers
```bash
ansible-playbook -i inventory.ini site.yml --limit webservers
```

### Exécuter en mode verbeux (debug)
```bash
ansible-playbook -i inventory.ini site.yml -vvv
```

### Tester sans appliquer (dry-run)
```bash
ansible-playbook -i inventory.ini site.yml --check
```

### Exécuter sur un serveur spécifique
```bash
ansible-playbook -i inventory.ini site.yml --limit "web1.example.com"
```

## 🔧 Personnaliser les variables

### Modifier le timezone
Éditer `group_vars/all.yml` :
```yaml
timezone: "Europe/London"
```

### Ajouter des utilisateurs
Éditer `site.yml` et ajouter une tâche dans le playbook principal :
```yaml
- name: Create user
  user:
    name: myuser
    shell: /bin/bash
    groups: sudo
```

## 📊 Vérifier l'installation

Après exécution du playbook, vérifier :

```bash
# Depuis le serveur configuré
curl http://localhost/health    # Vérifier que le serveur répond
systemctl status nginx          # Vérifier le statut d'Nginx
cat /var/log/monitoring/disk-space.log  # Vérifier les logs de monitoring
```

## 🐛 Troubleshooting

### SSH refuses la connexion
```bash
# Vérifier les droits SSH
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Ajouter la clé au serveur
ssh-copy-id -i ~/.ssh/id_rsa.pub user@server
```

### Python3 not found
Installer Python 3 manuellement sur le serveur avant d'exécuter Ansible :
```bash
apt-get install python3 python3-pip
```

### Erreur de permissions
Ajouter `become: yes` au playbook pour utiliser sudo.

## 📚 Ressources

- [Documentation Ansible](https://docs.ansible.com/)
- [Galaxy - Community Roles](https://galaxy.ansible.com/)
- [Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

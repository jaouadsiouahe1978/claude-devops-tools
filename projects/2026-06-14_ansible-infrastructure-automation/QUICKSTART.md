# Ansible Infrastructure Automation - Quickstart

## 🚀 Démarrage rapide en 5 minutes

### 1. Installation
```bash
# Installer Ansible
pip install ansible

# Vérifier
ansible --version
```

### 2. Configurer l'inventory
Édite `inventory/hosts.ini` et remplace les IPs par tes serveurs réels ou `localhost`.

Pour tester **localement** en mode "safe" :
```bash
# Teste juste sur localhost
ansible -i inventory/hosts.ini localhost -m ping
```

### 3. Valider la syntaxe
```bash
# Vérifie que tous les playbooks sont corrects
ansible-playbook --syntax-check playbooks/*.yml
```

### 4. Premier run en dry-mode
```bash
# Lance le playbook de base SANS rien changer
ansible-playbook -C playbooks/01-base-setup.yml -v
```

### 5. Lancer pour de vrai
```bash
# Deploy tout
ansible-playbook playbooks/00-full-stack.yml -v

# OU déploie étape par étape
ansible-playbook playbooks/01-base-setup.yml -v
ansible-playbook playbooks/02-deploy-web.yml -v
ansible-playbook playbooks/03-deploy-database.yml -v
ansible-playbook playbooks/04-deploy-monitoring.yml -v
```

## 📋 Commandes utiles

```bash
# Tester la connexion avec tous les serveurs
ansible all -m ping

# Voir les facts (variables system) d'un serveur
ansible webservers -m setup

# Exécuter une commande ad-hoc
ansible all -m shell -a "uptime"

# Lister les serveurs
ansible all --list-hosts

# Verbose mode (debug)
ansible-playbook playbooks/01-base-setup.yml -vvv

# Spécifier un serveur particulier
ansible-playbook playbooks/01-base-setup.yml -l webserver1
```

## 🔧 Personnaliser pour tes serveurs

### Variables globales (tous les serveurs)
Édite `group_vars/all.yml`

### Variables par groupe
- `group_vars/webservers.yml` - pour les web servers
- `group_vars/databases.yml` - pour les databases

### Variables par serveur
Crée `inventory/host_vars/mon-serveur.yml` pour surcharger les variables.

## 🧪 Tester avec Docker (optionnel)

Si tu veux tester sans vrais serveurs :

```bash
# Lancer 3 conteneurs Ubuntu
docker run -d --name ubuntu-web ubuntu:22.04 sleep 999999
docker run -d --name ubuntu-db ubuntu:22.04 sleep 999999
docker run -d --name ubuntu-monitor ubuntu:22.04 sleep 999999

# Installer SSH dedans (voir section Docker)
# Mettre à jour l'inventory avec les adresses IP des conteneurs

# Tester
ansible -i inventory/hosts.ini all -m ping
```

## 🐛 Troubleshooting

### Erreur: "SSH permission denied"
```bash
# Vérifie que la clé SSH est correcte
ssh -i ~/.ssh/id_rsa user@serveur

# Check si SSH est en écoute
ssh -vvv user@serveur
```

### Erreur: "Python not found"
```bash
# Les serveurs doivent avoir Python 3
# Installe-le manuellement s'il manque:
apt install python3
```

### Playbook bloqué/timeout
```bash
# Augmente le timeout
ansible-playbook playbooks/01-base-setup.yml -e "ansible_command_timeout=30"

# OU mode verbeux pour voir où ça bloque
ansible-playbook playbooks/01-base-setup.yml -vvv | head -50
```

## 📊 Vérifier l'état après déploiement

```bash
# Sur les web servers
ansible webservers -m shell -a "systemctl status nginx"
curl http://ip-webserver/health

# Sur les database servers
ansible databases -m shell -a "systemctl status postgresql"
ansible databases -m shell -a "sudo -u postgres psql -c 'SELECT datname FROM pg_database;'"

# Sur tous les serveurs
ansible all -m shell -a "systemctl status node_exporter"
curl http://ip-serveur:9100/metrics
```

## 🔑 Points clés

1. **Idempotence** : Tu peux relancer les playbooks autant de fois - rien ne change après la première fois
2. **Dry-run** : `-C` pour tester sans rien faire
3. **Verbose** : `-v`, `-vv`, `-vvv` pour plus de détails
4. **Limiting** : `-l groupname` ou `-l hostname` pour cibler

## 📚 Next Steps

Une fois à l'aise :
- Ajouter des roles custom pour tes apps
- Utiliser Ansible Vault pour les secrets
- Intégrer avec CI/CD (GitHub Actions)
- Tester avec Molecule
- Découvrir la dynamic inventory (AWS, Azure, etc.)

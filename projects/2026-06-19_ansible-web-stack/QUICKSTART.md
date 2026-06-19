# 🚀 Quick Start Guide

## 5 minutes pour démarrer

### Option 1: Docker Compose (Recommandé)

```bash
# 1. Démarrer les conteneurs
docker-compose up -d

# 2. Vérifier que tout tourne
docker-compose ps

# 3. Vérifier la connectivité SSH
sleep 10  # Attendre que SSH soit prêt
ssh -o StrictHostKeyChecking=no devops@localhost -p 2222

# 4. Exécuter les playbooks Ansible
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -v
```

### Option 2: Serveurs réels (Linux)

#### A. Préparation (une seule fois)

```bash
# 1. Installer Ansible
sudo apt update && sudo apt install -y ansible

# 2. Générer une clé SSH
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# 3. Copier la clé sur les serveurs
ssh-copy-id -i ~/.ssh/id_rsa.pub user@web1.example.com
ssh-copy-id -i ~/.ssh/id_rsa.pub user@web2.example.com
ssh-copy-id -i ~/.ssh/id_rsa.pub user@db1.example.com
```

#### B. Configuration

```bash
# 1. Modifier l'inventaire
vim inventory/hosts.ini

# Remplacer les IPs par vos serveurs réels:
[webservers]
192.168.1.100
192.168.1.101

[dbservers]
192.168.1.200

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

#### C. Déploiement

```bash
# 1. Tester la connectivité
ansible all -i inventory/hosts.ini -m ping

# 2. Voir ce qui sera fait (dry-run)
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --check

# 3. Déployer!
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -v
```

### Option 3: Vagrant (VMs virtuelles)

```bash
# 1. Installer Vagrant
sudo apt install vagrant virtualbox

# 2. Créer les VMs
vagrant up

# 3. Ansible configure automatiquement!
```

---

## ✅ Vérification du déploiement

### Tester Nginx
```bash
# Sur les webservers
curl http://web1.example.com
# Résultat attendu: HTML ou JSON selon votre app
```

### Tester Node.js
```bash
curl http://web1.example.com:3000
# Résultat attendu: JSON avec les infos de l'app
```

### Tester PostgreSQL
```bash
# Sur le dbserver
psql -U app_user -d app_db -c "SELECT 1"
# Résultat attendu: 1 ligne avec "1"
```

### Tester Monitoring
```bash
# Node Exporter sur chaque serveur
curl http://web1.example.com:9100/metrics | head -20
```

---

## 🔧 Commandes utiles

### Redéployer un seul rôle
```bash
# Redéployer seulement Nginx
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --tags nginx

# Redéployer seulement PostgreSQL
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --tags postgres
```

### Tâches ad-hoc
```bash
# Redémarrer tous les webservers
ansible webservers -i inventory/hosts.ini -m systemd -a "name=nginx state=restarted" -b

# Afficher la version Node sur tous les hosts
ansible all -i inventory/hosts.ini -m shell -a "node --version"

# Installer un paquet
ansible dbservers -i inventory/hosts.ini -m apt -a "name=htop state=present" -b
```

### Debugging
```bash
# Mode verbose (montrer les tâches)
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -v

# Mode très verbose
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -vvv

# Simuler sans effectuer de changements
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --check
```

---

## 🎯 Workflow typique

```
1. Préparer les serveurs
   └─ Modifier inventory/hosts.ini
   └─ Tester ping

2. Faire un essai
   └─ ansible-playbook --check

3. Déployer
   └─ ansible-playbook playbooks/site.yml

4. Vérifier
   └─ curl, ssh, tests manuels

5. Itérer
   └─ Modifier les rôles
   └─ Redéployer avec --tags
```

---

## 📊 Fichiers importants

```
.
├── ansible.cfg              ← Configuration Ansible
├── inventory/
│   ├── hosts.ini           ← À modifier!
│   └── hosts.yml           ← Alternative YAML
├── playbooks/
│   └── site.yml            ← Point d'entrée principal
├── roles/                  ← Logique du déploiement
│   ├── common/
│   ├── nginx/
│   ├── nodejs/
│   ├── postgres/
│   └── monitoring/
└── group_vars/             ← Variables par groupe
```

---

## ⚠️ Points importants

1. **Idempotence** : Lancer 2 fois = même résultat ✅
2. **Sudo** : Ansible utilise `become: yes` pour les droits admin
3. **Variables** : Centralisées dans `group_vars/` et `host_vars/`
4. **Tags** : Permet de redéployer partiellement `--tags nginx`
5. **Check mode** : Toujours faire un `--check` avant!

---

## 🆘 Troubleshooting

### ❌ "Permission denied (publickey)"
```bash
# Solution: Vérifier les clés SSH
ssh-keyscan -H web1.example.com >> ~/.ssh/known_hosts
ssh-copy-id -i ~/.ssh/id_rsa.pub user@web1.example.com
```

### ❌ "Connection refused"
```bash
# Solution: Vérifier que SSH tourne
ansible web1 -i inventory/hosts.ini -m ping -v
```

### ❌ "Become method failed"
```bash
# Solution: Vérifier sudo
ansible web1 -i inventory/hosts.ini -m shell -a "sudo whoami" -b
```

### ❌ "Port already in use"
```bash
# Solution: Changer les ports dans group_vars/
vim group_vars/webservers.yml
```

---

## 📚 Ressources

- [Ansible Documentation](https://docs.ansible.com/)
- [Playbook Guide](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html)
- [Role Guide](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)
- [Variables](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html)

---

**Créé le**: 2026-06-19  
**Niveau**: Intermédiaire  
**Temps estimé**: 15 minutes

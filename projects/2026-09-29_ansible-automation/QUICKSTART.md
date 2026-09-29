# Quick Start - Ansible Infrastructure Automation

## Installation rapide

### 1. Prérequis
```bash
# Installer Ansible
sudo apt-get update
sudo apt-get install -y ansible

# Vérifier l'installation
ansible --version
# Devrait afficher: ansible [core 2.10+]
```

### 2. Générer les clés SSH
```bash
# Si vous n'avez pas de clé SSH
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Copier la clé sur les serveurs cibles
for host in 192.168.1.101 192.168.1.102 192.168.1.103 192.168.1.104; do
  ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@$host
done
```

### 3. Configurer l'inventaire

Éditer `inventory/hosts.yml` et remplacer les adresses IP par vos serveurs:

```yaml
all:
  vars:
    ansible_user: ubuntu
    ansible_ssh_private_key_file: ~/.ssh/id_rsa

  children:
    webservers:
      hosts:
        web1:
          ansible_host: YOUR_IP_1
        web2:
          ansible_host: YOUR_IP_2
```

### 4. Tester la connectivité
```bash
# Ping tous les serveurs
ansible all -i inventory/hosts.yml -m ping

# Affiche:
# web1 | SUCCESS => {
#     "ping": "pong"
# }
# web2 | SUCCESS => { ... }
```

### 5. Exécuter le playbook
```bash
# Dry-run (voir les changements sans les appliquer)
ansible-playbook playbooks/site.yml -i inventory/hosts.yml --check -v

# Exécution réelle
ansible-playbook playbooks/site.yml -i inventory/hosts.yml -v
```

---

## Scénarios courants

### Déployer uniquement le serveur web
```bash
ansible-playbook playbooks/site.yml -i inventory/hosts.yml -v --tags web
```

### Déployer uniquement la base de données
```bash
ansible-playbook playbooks/site.yml -i inventory/hosts.yml -v --tags db
```

### Déployer uniquement le monitoring
```bash
ansible-playbook playbooks/site.yml -i inventory/hosts.yml -v --tags monitoring
```

### Mettre à jour l'application
```bash
ansible-playbook playbooks/deploy.yml \
  -i inventory/hosts.yml \
  -e app_version=2.0.0 \
  -e git_branch=release/v2.0.0 \
  -v
```

### Rollback vers version précédente
```bash
ansible-playbook playbooks/rollback.yml \
  -i inventory/hosts.yml \
  -e previous_version=1.0.0 \
  -v
```

### Redémarrer tous les services Nginx
```bash
ansible webservers -i inventory/hosts.yml -m service -a "name=nginx state=restarted"
```

### Vérifier l'état des services
```bash
ansible all -i inventory/hosts.yml -m systemd -a "name=nginx state=started"
```

---

## Vérifications post-déploiement

### Accéder à l'application
```bash
# Remplacer par vos IPs
curl http://192.168.1.101
curl http://192.168.1.102
```

### Vérifier la base de données
```bash
# Se connecter à PostgreSQL
psql -h 192.168.1.103 -U appuser -d appdb -c "SELECT version();"
```

### Accéder au monitoring
```bash
# Prometheus
http://192.168.1.104:9090

# Node Exporter metrics
http://192.168.1.101:9100/metrics
http://192.168.1.102:9100/metrics
http://192.168.1.103:9100/metrics
```

---

## Debugging et troubleshooting

### Voir les logs Ansible
```bash
# Logs détaillés
ansible-playbook playbooks/site.yml -i inventory/hosts.yml -vvv

# Avec profiling des tâches
ansible-playbook playbooks/site.yml -i inventory/hosts.yml -v --profile
```

### Vérifier la syntaxe
```bash
# Avant d'exécuter
ansible-playbook playbooks/site.yml --syntax-check -i inventory/hosts.yml
```

### Tester un rôle spécifique
```bash
# Juste le rôle webserver
ansible-playbook playbooks/site.yml -i inventory/hosts.yml --tags web --check -v
```

### Collecter les facts d'un hôte
```bash
# Voir toutes les variables d'un serveur
ansible web1 -i inventory/hosts.yml -m setup
```

### Exécuter une commande ad-hoc
```bash
# Exécuter une commande sur tous les serveurs
ansible all -i inventory/hosts.yml -m shell -a "uptime"

# Avec sudo
ansible all -i inventory/hosts.yml -b -m shell -a "systemctl status nginx"
```

---

## Utiliser l'environnement de lab (Vagrant)

### Créer les VMs de test
```bash
./scripts/setup-lab.sh
```

### Tester les playbooks
```bash
./scripts/test-playbook.sh
```

### Accéder aux VMs
```bash
vagrant ssh web1
vagrant ssh db1
```

### Arrêter/Supprimer les VMs
```bash
vagrant halt     # Arrêter sans supprimer
vagrant destroy  # Supprimer complètement
```

---

## Best Practices Ansible

### ✅ À faire
- Utiliser des rôles pour la réutilisabilité
- Tester avec `--check` avant l'exécution réelle
- Utiliser des variables au lieu de hardcoder
- Versionner l'inventaire dans Git
- Documenter les variables en `defaults/main.yml`

### ❌ À éviter
- Utiliser `shell` quand un module existe
- Hardcoder les secrets en clair
- Exécuter sans `--check` d'abord
- Créer des playbooks sans idempotence
- Oublier les handlers pour les restarts

---

## Ressources supplémentaires

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Ansible Modules](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html)
- [Ansible Galaxy - Rôles pre-built](https://galaxy.ansible.com/)

---

## Support et Questions

Pour des questions sur ce projet DevOps:
- Consulter la documentation Ansible officielle
- Examiner les playbooks et rôles du projet
- Vérifier les logs avec `-vvv`

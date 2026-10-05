# Commandes Ansible Essentielles

## Vérification et Syntaxe

```bash
# Vérifier la syntaxe d'un playbook
ansible-playbook playbooks/site.yml --syntax-check

# Vérifier que les hosts sont accessibles
ansible all -i inventory/hosts.ini -m ping

# Afficher les informations sur un host
ansible-inventory -i inventory/hosts.ini --host web1.example.com

# Lister tous les hosts
ansible-inventory -i inventory/hosts.ini --graph
```

## Exécution des Playbooks

```bash
# Déploiement complet
ansible-playbook -i inventory/hosts.ini playbooks/site.yml

# Déploiement avec verbosité
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -v
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -vv
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -vvv

# Dry-run (ne rien modifier)
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --check

# Dry-run avec diff
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --check --diff

# Exécution avec tags spécifiques
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --tags nginx
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --tags "nginx,firewall"

# Exécution sans certains tags
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --skip-tags system

# Limiter à certains hosts
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --limit webservers
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --limit "web1.example.com"

# Mode pas à pas (demande confirmation)
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --step
```

## Déploiement de l'Application

```bash
# Déploiement initial
ansible-playbook -i inventory/hosts.ini playbooks/deploy.yml

# Déploiement sur certains hosts
ansible-playbook -i inventory/hosts.ini playbooks/deploy.yml -e app_version=1.0.0

# Rollback à une version précédente
ansible-playbook -i inventory/hosts.ini playbooks/rollback.yml -e "rollback_version=0.9.0"

# Déploiement avec limit (serial mode)
ansible-playbook -i inventory/hosts.ini playbooks/deploy.yml --limit "web[0:1]"
```

## Commandes Ad-hoc

```bash
# Exécuter une commande sur tous les hosts
ansible all -i inventory/hosts.ini -m command -a "uptime"

# Exécuter un script shell
ansible all -i inventory/hosts.ini -m shell -a "cat /etc/os-release"

# Copier un fichier
ansible all -i inventory/hosts.ini -m copy -a "src=/tmp/file.txt dest=/tmp/file.txt"

# Gérer les services
ansible webservers -i inventory/hosts.ini -m service -a "name=nginx state=restarted"

# Récupérer des facts
ansible web1.example.com -i inventory/hosts.ini -m setup

# Installer des packages
ansible all -i inventory/hosts.ini -m yum -a "name=git state=present"

# Exécuter avec escalade de privilèges
ansible all -i inventory/hosts.ini -b -m command -a "systemctl restart nginx"
```

## Gestion des Variables

```bash
# Afficher les variables d'un host
ansible-inventory -i inventory/hosts.ini --host web1.example.com | jq

# Afficher les variables avec ansible
ansible localhost -m debug -a "var=hostvars['web1.example.com']"

# Lister les facts d'un host
ansible localhost -m debug -a "var=hostvars['web1.example.com']['ansible_os_family']"
```

## Débogage

```bash
# Afficher les handlers
ansible-playbook playbooks/site.yml -i inventory/hosts.ini --list-handlers

# Lister les tasks
ansible-playbook playbooks/site.yml -i inventory/hosts.ini --list-tasks

# Lister les hosts affectés
ansible-playbook playbooks/site.yml -i inventory/hosts.ini --list-hosts

# Trace complète
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -vvv --step --start-at-task "Task name"
```

## Facts et Debug

```bash
# Afficher une variable d'un playbook
ansible web1.example.com -i inventory/hosts.ini -m debug -a "var=ansible_os_family"

# Afficher des facts en JSON formaté
ansible web1.example.com -i inventory/hosts.ini -m setup | jq

# Filtrer les facts
ansible web1.example.com -i inventory/hosts.ini -m setup -a "filter=ansible_distribution*"
```

## Performance et Optimisation

```bash
# Afficher le timing de chaque task
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --callback_plugins=$(pwd)/plugins/callback --callback timer_per_task

# Paralléliser les exécutions
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -f 10  # 10 forks

# Exécution lente
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --start-at-task="Task name"
```

## Inventaire Dynamique AWS

```bash
# Lister les instances EC2
ansible-inventory -i inventory/aws_ec2.yml --graph

# Exécuter sur les instances produites
ansible -i inventory/aws_ec2.yml tag_Environment_production -m ping

# Filtrer par tag
ansible -i inventory/aws_ec2.yml 'tag_Application_webapp' -m ping
```

## Modules Courants

- **command** : Exécute une commande
- **shell** : Exécute via shell bash
- **yum/apt** : Gestion des packages
- **service** : Gestion des services systemd
- **file** : Gestion des fichiers et dossiers
- **template** : Utilise des templates Jinja2
- **copy** : Copie des fichiers
- **git** : Clone/met à jour des repos
- **user** : Gère les utilisateurs
- **group** : Gère les groupes
- **lineinfile** : Modifie des lignes dans un fichier
- **replace** : Remplace du texte dans un fichier
- **firewalld** : Configure le firewall
- **debug** : Affiche des messages

## Tips & Tricks

```bash
# Afficher les hosts sans exécuter
ansible-playbook playbooks/site.yml -i inventory/hosts.ini --list-hosts

# Afficher ce qui serait modifié
ansible-playbook playbooks/site.yml -i inventory/hosts.ini --check --diff

# Exécuter une task depuis un playbook préservant un host
ansible-playbook playbooks/site.yml -i inventory/hosts.ini -k --ask-become-pass

# Exécuter en mode interactif (ask before running)
ansible-playbook playbooks/site.yml -i inventory/hosts.ini --ask-vault-pass

# Mesurer la performance
time ansible-playbook playbooks/site.yml -i inventory/hosts.ini
```

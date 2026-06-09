# Commandes Ansible Essentielles

## Installation et Setup

```bash
# Installer Ansible et dépendances
pip install -r requirements.txt

# Ou utiliser le script de provision
bash provision.sh

# Utiliser Makefile
make install
```

## Vérification et Validation

```bash
# Vérifier la syntaxe des playbooks
ansible-playbook --syntax-check site.yml

# Vérifier les hosts et inventaire
ansible-inventory -i inventory/hosts.ini --list

# Afficher les variables d'un groupe
ansible-inventory -i inventory/hosts.ini --host webservers

# Test de connectivité SSH
ansible -i inventory/hosts.ini all -m ping
```

## Exécution des Playbooks

```bash
# Dry-run (mode check) - voir les changements sans les appliquer
ansible-playbook -i inventory/hosts.ini site.yml --check

# Déploiement complet avec verbosité
ansible-playbook -i inventory/hosts.ini site.yml -v

# Déploiement avec verbosité maximale
ansible-playbook -i inventory/hosts.ini site.yml -vvv

# Déploiement sur des hosts spécifiques
ansible-playbook -i inventory/hosts.ini site.yml --limit webservers

# Déploiement avec tags spécifiques
ansible-playbook -i inventory/hosts.ini site.yml -t docker

# Redéployer uniquement l'app
ansible-playbook -i inventory/hosts.ini deploy.yml

# Déployer à partir d'une tâche spécifique
ansible-playbook -i inventory/hosts.ini site.yml --start-at-task "Créer le réseau Docker"
```

## Commandes Ad-Hoc

```bash
# Exécuter une commande sur tous les hosts
ansible -i inventory/hosts.ini all -m shell -a "docker ps"

# Exécuter sur un groupe spécifique
ansible -i inventory/hosts.ini webservers -m shell -a "df -h"

# Récupérer des infos système
ansible -i inventory/hosts.ini all -m setup -a "filter=ansible_os_family"

# Copier un fichier
ansible -i inventory/hosts.ini webservers -m copy -a "src=/local/path dest=/remote/path"

# Redémarrer les services
ansible -i inventory/hosts.ini all -m systemd -a "name=docker state=restarted"
```

## Débogage et Troubleshooting

```bash
# Augmenter la verbosité (plus de détails)
ansible-playbook -i inventory/hosts.ini site.yml -vvv

# Mode debug : pause sur chaque tâche
ansible-playbook -i inventory/hosts.ini site.yml --step

# Sauter une tâche
ansible-playbook -i inventory/hosts.ini site.yml --skip-tags "postgres"

# Afficher les variables effectives
ansible -i inventory/hosts.ini webservers -m debug -a "var=hostvars[inventory_hostname]"

# Tester une connexion SSH
ansible -i inventory/hosts.ini webservers -m ping -v

# Afficher les tâches sans les exécuter
ansible-playbook -i inventory/hosts.ini site.yml --list-tasks

# Afficher les hôtes
ansible-playbook -i inventory/hosts.ini site.yml --list-hosts
```

## Gestion des Rôles

```bash
# Afficher les rôles disponibles
ansible-galaxy list

# Installer un rôle depuis Galaxy
ansible-galaxy install geerlingguy.docker

# Créer un nouveau rôle
ansible-galaxy init my_role

# Linter de rôles
ansible-lint site.yml
```

## Variables et Facts

```bash
# Afficher tous les facts d'un host
ansible -i inventory/hosts.ini webservers -m setup

# Filtrer les facts
ansible -i inventory/hosts.ini webservers -m setup -a "filter=ansible_eth0"

# Exporter les facts en JSON
ansible -i inventory/hosts.ini webservers -m setup > facts.json
```

## Logs et Monitoring

```bash
# Afficher les logs d'Ansible
tail -f /tmp/ansible.log

# Enregistrer les output
ansible-playbook -i inventory/hosts.ini site.yml | tee deployment.log

# Générer un rapport JSON
ansible-playbook -i inventory/hosts.ini site.yml --extra-vars '{"output_format":"json"}' > report.json
```

## Cas d'usage Avancés

```bash
# Déployer avec des variables personnalisées
ansible-playbook -i inventory/hosts.ini site.yml -e "app_version=2.0.0"

# Déployer sur plusieurs inventaires
ansible-playbook -i inventory/hosts.ini -i staging.ini site.yml

# Lancer un playbook avec parallelisation
ansible-playbook -i inventory/hosts.ini site.yml -f 10

# Déployer avec timeout personnalisé
ansible-playbook -i inventory/hosts.ini site.yml --timeout=300

# Déploiement conditionnel avec confirmation
ansible-playbook -i inventory/hosts.ini site.yml --ask-become-pass

# Générer un graphe de dépendances (nécessite graphviz)
ansible-playbook -i inventory/hosts.ini site.yml --graph
```

## Makefile Shortcuts

```bash
# Installer
make install

# Vérifier la syntaxe
make check

# Dry-run
make deploy-check

# Déploiement complet
make deploy

# Redéployer l'app
make deploy-app

# Tester
make test

# Nettoyer
make clean
```

## Best Practices

1. **Toujours faire un check avant de déployer** : `--check`
2. **Utiliser des tags** pour déploiements partiels
3. **Valider la syntaxe** avant exécution : `--syntax-check`
4. **Utiliser les handlers** pour redémarrages intelligents
5. **Tester en dry-run** avant le vrai déploiement
6. **Documenter les playbooks** avec des commentaires
7. **Versionner les rôles** et playbooks avec Git
8. **Utiliser Ansible Vault** pour les secrets

# Playbook Ansible : Déploiement Multi-Serveur Web + DB

## 📋 Description
Déployer automatiquement une application web (Flask) avec serveur proxy (Nginx) et base de données (PostgreSQL) sur plusieurs serveurs. Ce projet utilise Ansible pour automatiser la configuration et le déploiement - zéro click sur les serveurs !

## 🎯 Objectifs d'apprentissage
- Structure d'un playbook Ansible professionnel (avec roles)
- Inventory dynamique et variables par groupe
- Handlers pour redémarrer les services
- Idempotence (sûr de relancer N fois)
- Templating Jinja2 pour les configs
- Facts et variables Ansible

## 🛠️ Technos utilisées
- **Ansible** 2.10+ pour l'orchestration
- **Nginx** pour le reverse proxy
- **PostgreSQL** pour la DB
- **Flask** (app web simple)
- **Jinja2** pour les templates de config
- **Python** pour les scripts

## 📁 Structure du projet
```
.
├── README.md                 # Ce fichier
├── ansible.cfg               # Configuration Ansible
├── inventory.ini             # Définition des hosts
├── deploy.yml                # Playbook principal
├── roles/
│   ├── common/               # Setup commun (OS, user, etc)
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   └── handlers/
│   │       └── main.yml
│   ├── webserver/            # Setup Nginx + Flask
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   ├── handlers/
│   │   │   └── main.yml
│   │   └── templates/
│   │       └── nginx.conf.j2
│   └── database/             # Setup PostgreSQL
│       ├── tasks/
│       │   └── main.yml
│       └── handlers/
│           └── main.yml
├── group_vars/
│   ├── all.yml               # Variables pour tous les hosts
│   ├── webservers.yml        # Variables pour le groupe 'webservers'
│   └── databases.yml         # Variables pour le groupe 'databases'
└── files/
    └── flask_app.py          # Application Flask simple
```

## 🚀 Pré-requis
- Ansible installé : `pip install ansible`
- SSH configuré et clés d'accès aux serveurs
- Serveurs Linux (Ubuntu/Debian) ou VMs locales
- Python 3.6+ sur les serveurs cibles
- Sudo configuré (ou root)

Pour tester localement :
```bash
# Utiliser Docker pour simuler les serveurs
docker run -d --name web1 -p 2201:22 ubuntu-ssh
docker run -d --name db1 -p 2202:22 ubuntu-ssh
```

## 📖 Étapes de réalisation

### 1. Installation d'Ansible
```bash
pip install ansible
ansible-playbook --version
```

### 2. Configurer l'inventory
Éditer `inventory.ini` avec les adresses IP/hostnames réels :
```ini
[webservers]
web1 ansible_host=192.168.1.10
web2 ansible_host=192.168.1.11

[databases]
db1 ansible_host=192.168.1.20
```

### 3. Vérifier la connectivité
```bash
ansible all -i inventory.ini -m ping
```

### 4. Exécuter le playbook
```bash
# Dry-run (simulation)
ansible-playbook -i inventory.ini deploy.yml --check

# Déploiement réel
ansible-playbook -i inventory.ini deploy.yml -v
```

### 5. Vérifier le déploiement
- Nginx : `curl http://web1:80`
- PostgreSQL : `psql -h db1 -U postgres`

### 6. Idempotence
Relancer le playbook - tout doit rester stable :
```bash
ansible-playbook -i inventory.ini deploy.yml
# → "changed" = 0 (sauf si on modifie les config)
```

## 🔧 Fichiers clés à comprendre

### `deploy.yml` - Playbook principal
Orchestre les 3 roles sur les groupes de hosts appropriés.

### `roles/common/tasks/main.yml`
Setup basique : mettre à jour les packages, créer users, configurer firewall.

### `roles/webserver/templates/nginx.conf.j2`
Configuration Nginx templating Jinja2 - utilise les variables Ansible.

### `group_vars/webservers.yml`
Variables spécifiques au groupe `webservers` (port Nginx, etc).

## 📊 Diagramme de flux

```
[Contrôle Ansible]
       ↓
inventory.ini (web1, web2, db1)
       ↓
deploy.yml
   ├→ Role: common (tous)
   │  ├ Update OS
   │  └ Create users
   │
   ├→ Role: webserver (webservers)
   │  ├ Install Nginx
   │  ├ Deploy Flask app
   │  └ Start services
   │
   └→ Role: database (databases)
      ├ Install PostgreSQL
      ├ Create DB/user
      └ Start services
```

## 💡 Concepts importants

1. **Idempotence** : Relancer le playbook = 0 changements. Ansible s'assure que c'est sûr.
2. **Roles** : Réutilisables, testables, organisés
3. **Handlers** : Exécutés après les tâches si notifiés (ex: restart nginx)
4. **Variables** : `group_vars/` pour les groupes, `host_vars/` pour les hosts
5. **Templates** : Jinja2 pour générer les configs dynamiquement

## 🧪 Tests / Validation
```bash
# Vérifier la syntaxe
ansible-playbook deploy.yml --syntax-check

# Dry-run
ansible-playbook -i inventory.ini deploy.yml --check

# Verbose mode
ansible-playbook -i inventory.ini deploy.yml -vvv
```

## 🎓 Points d'apprentissage clés
- ✅ Écrire un playbook Ansible multi-rôles
- ✅ Gérer un inventory avec groupes de hosts
- ✅ Utiliser les variables et templates Jinja2
- ✅ Configurer les handlers pour les restart de services
- ✅ Tester l'idempotence (run multiple fois)
- ✅ Déboguer avec `-v`, `-vv`, `-vvv`

## 📚 Ressources
- [Ansible Official Docs](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/index.html)
- [Jinja2 in Ansible](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_templating.html)

## 🔄 Prochaines étapes
- Ajouter des variables sensibles avec `ansible-vault`
- Intégrer dans une pipeline CI/CD (GitHub Actions)
- Utiliser des rôles depuis Ansible Galaxy
- Ajouter des tests avec `molecule` et `testinfra`
- Déployer avec une config de DR (disaster recovery)

# 🚀 Quick Start - Ansible Configuration Management

## En 5 minutes

### 1. Prérequis
```bash
# Installez Ansible et Docker
brew install ansible docker docker-compose  # macOS
sudo apt-get install ansible docker.io docker-compose  # Ubuntu/Debian
```

### 2. Démarrer l'infrastructure
```bash
cd projects/2026-07-28_ansible-config-mgmt
make up
```

Cela crée 4 containers : 2 serveurs web, 1 DB, 1 monitoring.

### 3. Valider la configuration
```bash
make check
```

Cela fait un `--check --diff` pour voir ce qui serait changé sans rien modifier.

### 4. Déployer
```bash
make deploy
```

Exécute le playbook complet et configure tous les serveurs.

### 5. Vérifier
```bash
make verify-deployment
curl http://localhost:8080
curl http://localhost:8081
```

### 6. Nettoyer
```bash
make down
```

---

## Structure du projet expliquée

```
📁 projects/2026-07-28_ansible-config-mgmt/
├── 📋 ansible.cfg           # Config Ansible globale
├── 📋 inventory.yml         # Inventaire des machines
├── 📁 playbooks/            # Workflows d'automatisation
│   ├── main.yml            # Point d'entrée principal
│   ├── common.yml          # Config commune (SSH, packages)
│   ├── web-servers.yml     # Config Nginx
│   ├── database.yml        # Config PostgreSQL
│   └── monitoring.yml      # Config Prometheus
├── 📁 templates/           # Templates Jinja2
│   ├── nginx.conf.j2       # Config Nginx dynamique
│   ├── postgresql.conf.j2  # Config PostgreSQL
│   ├── prometheus.yml.j2   # Config Prometheus
│   └── index.html.j2       # Page HTML personnalisée
├── docker-compose.yml      # Infrastructure de test
├── Makefile               # Commandes pratiques
└── test-deployment.sh     # Script de test
```

---

## Commandes essentielles

### Gestion infrastructure
```bash
make up              # Démarrer les containers
make down            # Arrêter les containers
make status          # Voir l'état des containers
make logs            # Voir les logs en temps réel
```

### Ansible
```bash
make check           # Dry-run du playbook
make deploy          # Exécuter le playbook
make ping            # Tester la connectivité
make facts           # Récupérer les facts des serveurs
```

### Services
```bash
make restart-nginx   # Redémarrer Nginx
make restart-postgres # Redémarrer PostgreSQL
```

### Debug
```bash
make shell-web1      # Shell sur web1
make shell-web2      # Shell sur web2
make shell-db        # Shell sur db
make shell-monitoring # Shell sur monitoring
```

---

## Concepts clés d'Ansible

### 📋 Inventaire
Fichier YAML listant tous les serveurs et leurs groupes :
```yaml
webservers:
  hosts:
    web1:
    web2:
databases:
  hosts:
    db:
```

### 🎬 Playbooks
YAML décrivant les actions à exécuter :
```yaml
- name: "Installer Nginx"
  hosts: webservers
  tasks:
    - name: "Installe Nginx"
      apk:
        name: nginx
        state: present
```

### 🔧 Roles
Réutilisables : chaque rôle = un composant (nginx, postgresql, etc.)

### 📝 Templates Jinja2
Génèrent des configs dynamiques avec variables :
```jinja2
server_name: {{ server_name }}
port: {{ nginx_port }}
workers: {{ nginx_worker_processes }}
```

### 🔔 Handlers
Redémarrent les services seulement si needed :
```yaml
notify: Redémarrer Nginx
handlers:
  - name: Redémarrer Nginx
    service:
      name: nginx
      state: restarted
```

---

## Architecture déployée

```
┌─────────────────────────────────────────┐
│         Ansible Control Node            │
│  (Lance les playbooks)                  │
└────────┬────────┬─────────┬─────────────┘
         │        │         │
    ┌────▼──┐ ┌───▼──┐ ┌────▼───┐ ┌──────────┐
    │  web1 │ │ web2 │ │   db   │ │monitoring│
    │ Nginx │ │Nginx │ │Postgres│ │Prometheus│
    └───────┘ └──────┘ └────────┘ └──────────┘
      :8080     :8081    :5432      :9090
```

---

## Exercices progressifs

### ⭐ Niveau 1 - Débutant
1. `make up` et `make deploy`
2. `curl http://localhost:8080` - vérifier Nginx
3. `make logs` - voir ce qui se passe

### ⭐⭐ Niveau 2 - Intermédiaire
1. Modifier la valeur de `nginx_worker_processes` dans `inventory.yml`
2. Relancer `make deploy` et voir les changements
3. Ajouter une nouvelle variable d'environnement dans le playbook

### ⭐⭐⭐ Niveau 3 - Avancé
1. Créer un nouveau rôle Ansible pour Redis
2. Ajouter Redis au playbook
3. Configurer Prometheus pour scraper Redis

---

## Troubleshooting

### Les containers ne démarrent pas
```bash
docker-compose down -v
docker-compose up -d
```

### Ansible ne trouve pas les hosts
```bash
# Vérifier l'inventaire
ansible all -i inventory.yml --list-hosts

# Tester la connectivité
make ping
```

### Erreur de syntaxe Ansible
```bash
# Valider la syntaxe
ansible-playbook playbooks/main.yml --syntax-check
```

### Voir les logs détaillés
```bash
# Mode verbose
ansible-playbook playbooks/main.yml -vvv

# Logs Ansible
cat /tmp/ansible.log
```

---

## Ressources

- [Ansible Docs](https://docs.ansible.com/)
- [Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Jinja2 Templating](https://docs.ansible.com/ansible/latest/user_guide/playbooks_templating.html)

**Bon apprentissage! 🎓**

# Ansible Core Concepts Guide

## 1. Inventory (Inventaire)

L'**inventory** c'est la liste des serveurs qu'Ansible va gérer.

### Format INI (le nôtre)
```ini
[webservers]           # Groupe "webservers"
web1 ansible_host=10.0.1.10
web2 ansible_host=10.0.1.11

[databases]            # Groupe "databases"
db1 ansible_host=10.0.2.10

[production:children]  # Groupe de groupes
webservers
databases

[all:vars]             # Variables globales
ntp_server=pool.ntp.org
```

### Format YAML
```yaml
all:
  hosts:
    localhost:
      ansible_connection: local
  children:
    webservers:
      hosts:
        web1:
          ansible_host: 10.0.1.10
```

## 2. Variables

Les **variables** paramètrent les configurations.

### 3 sources de variables (par ordre de priorité)
1. **Ligne de commande** : `-e "var=value"`
2. **Host vars** : `inventory/host_vars/hostname.yml`
3. **Group vars** : `group_vars/groupname.yml`
4. **Role defaults** : `roles/rolename/defaults/main.yml`

### Exemple
```yaml
# group_vars/webservers.yml
nginx_port: 80
app_version: 1.0.0

# Dans le playbook/role, accès via {{ variable }}
- name: Configure Nginx
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
```

## 3. Playbooks

Un **playbook** c'est une liste de plays (des tâches ciblées sur des hôtes).

```yaml
---
- name: "Configure Web Servers"      # Nom du play
  hosts: webservers                  # Cible (groupe ou hostname)
  become: yes                        # Exécuter en sudo
  gather_facts: yes                  # Collecter les facts système
  
  vars:
    nginx_port: 80
  
  tasks:
    - name: Install Nginx            # Nom de la tâche
      package:
        name: nginx
        state: present
      
    - name: Configure Nginx          # Tâche suivante
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      notify: restart nginx           # Déclenche un handler
  
  handlers:
    - name: restart nginx
      systemd:
        name: nginx
        state: restarted
```

## 4. Roles (Réutilisabilité)

Un **role** c'est une collection de tâches, templates, handlers, etc. **organisées** pour une fonction.

### Structure standard
```
roles/webserver/
├── tasks/           # Tâches principales
│   └── main.yml
├── handlers/        # Actions déclenchées par notify
│   └── main.yml
├── templates/       # Templates Jinja2
│   └── nginx.conf.j2
├── files/           # Fichiers statiques
│   └── app.conf
├── defaults/        # Valeurs par défaut
│   └── main.yml
├── vars/            # Variables du role
│   └── main.yml
└── README.md        # Doc du role
```

### Utiliser un role
```yaml
---
- hosts: webservers
  become: yes
  roles:
    - webserver        # Exécute les tasks du role
    - monitoring
```

## 5. Handlers

Les **handlers** sont des actions qui se **déclenchent conditionnellement**.

```yaml
tasks:
  - name: Change config file
    copy:
      src: app.conf
      dest: /etc/app/app.conf
    notify: restart app       # Déclenche le handler "restart app"

handlers:
  - name: restart app
    systemd:
      name: app
      state: restarted
```

**Important** : Un handler se déclenche **une seule fois** même si plusieurs tâches le font (idempotence).

## 6. Facts

Les **facts** ce sont les variables **découvertes automatiquement** par Ansible sur chaque hôte.

```bash
# Voir les facts d'un serveur
ansible hostname -m setup

# Filtrer
ansible hostname -m setup -a "filter=ansible_os_family"
```

Exemples de facts :
- `ansible_os_family` : Debian, RedHat, etc.
- `ansible_distribution` : Ubuntu, CentOS, etc.
- `ansible_memtotal_mb` : Mémoire totale
- `ansible_processor_vcpus` : Nombre de CPUs
- `ansible_hostname` : Hostname du serveur

Utilisation :
```yaml
- name: Install for {{ ansible_os_family }}
  package:
    name: nginx
    state: present
  when: ansible_os_family == "Debian"
```

## 7. Conditionnels

Les **when** permettent d'exécuter conditionnellement.

```yaml
- name: Install on Debian only
  package:
    name: nginx
  when: ansible_os_family == "Debian"

- name: Install if service not running
  package:
    name: postgres
  when: 
    - ansible_os_family == "Debian"
    - service_running is not defined

- name: Install for production
  package:
    name: app
  when: environment == "production"
```

## 8. Loops

Les **boucles** répètent une tâche.

```yaml
- name: Install packages
  package:
    name: "{{ item }}"
    state: present
  loop:
    - nginx
    - curl
    - git

- name: Create users
  user:
    name: "{{ item.name }}"
    uid: "{{ item.uid }}"
  loop:
    - { name: "alice", uid: 1001 }
    - { name: "bob", uid: 1002 }

- name: Create from variable
  user:
    name: "{{ item }}"
  loop: "{{ users }}"    # Variable définie ailleurs
```

## 9. Jinja2 Templates

Les **templates** générent des fichiers dynamiquement.

```jinja2
# templates/nginx.conf.j2
user {{ nginx_user }};
worker_processes {{ nginx_worker_processes }};

server {
    listen {{ nginx_port }};
    server_name {{ inventory_hostname }};
    
    {% if ssl_enabled %}
    ssl_certificate {{ ssl_cert_path }};
    {% endif %}
    
    {% for backend in backends %}
    upstream backend_{{ loop.index }} {
        server {{ backend }};
    }
    {% endfor %}
}
```

```yaml
# Dans la tâche
- name: Deploy nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
```

## 10. Error Handling

Gérer les erreurs et les cas exceptionnels.

```yaml
- name: Task that might fail
  shell: /usr/bin/risky-command
  register: result           # Capture la sortie
  ignore_errors: yes         # Ne pas bloquer sur erreur

- name: Check result
  debug:
    msg: "{{ result.stdout }}"

- name: Block and rescue
  block:
    - name: Try this
      command: /bin/true
    
    - name: If that fails
      command: /bin/false
  rescue:
    - name: Handle failure
      debug:
        msg: "Something went wrong, handling..."
  
  always:
    - name: Always run
      debug:
        msg: "Cleanup"
```

## 11. Idempotence (Concept clé!)

**L'idempotence** = exécuter un playbook 10 fois = exécuter 1 fois.

❌ **Pas idempotent** :
```yaml
- shell: echo "foo" >> /tmp/file.txt   # Ajoute à chaque fois
```

✅ **Idempotent** :
```yaml
- lineinfile:
    path: /tmp/file.txt
    line: "foo"
    state: present              # Ajoute qu'une seule fois
```

### Modules idempotents (meilleurs)
- `package`, `apt`, `yum` - installation
- `user`, `group` - gestion utilisateurs
- `file`, `copy`, `template` - gestion fichiers
- `systemd` - gestion services
- `lineinfile` - edit fichiers

### Modules NON idempotents (à éviter)
- `shell`, `command` - exécution de scripts
  - À utiliser seulement avec `creates:`, `removes:`, ou `changed_when:`

```yaml
# Shell idempotent
- shell: touch /tmp/file
  args:
    creates: /tmp/file        # N'exécute que si le fichier n'existe pas
```

## 12. Best Practices

1. **Noms descriptifs** : `- name: "Install Nginx and start service"`
2. **Un rôle = une fonction** : Ne pas tout mettre dans un rôle énorme
3. **Variables bien organisées** : defaults, vars, host_vars, group_vars
4. **Idempotence** : Chaque tâche doit être idempotente
5. **Handlers pour les redémarrages** : Pas de restart direct dans les tâches
6. **DRY (Don't Repeat Yourself)** : Utilise les roles et variables
7. **Tester** : `--syntax-check`, `-C` (dry-run), `-vvv` (verbose)
8. **Secrets** : Ansible Vault pour les passwords/keys

## 13. Commandes utiles

```bash
# Tester la syntaxe
ansible-playbook --syntax-check playbook.yml

# Dry-run (aperçu sans rien faire)
ansible-playbook -C playbook.yml

# Verbose (voir les détails)
ansible-playbook -v playbook.yml
ansible-playbook -vv playbook.yml
ansible-playbook -vvv playbook.yml

# Limiter à certains hôtes
ansible-playbook playbook.yml -l webservers
ansible-playbook playbook.yml -l web1

# Spécifier des variables
ansible-playbook playbook.yml -e "environment=prod"

# Voir les hosts
ansible -i inventory all --list-hosts

# Pinger les hosts
ansible all -m ping

# Collecter les facts
ansible all -m setup

# Ad-hoc command
ansible all -m shell -a "uptime"
```

## 📚 Ressources

- https://docs.ansible.com/
- https://docs.ansible.com/ansible/latest/user_guide/playbooks.html
- https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html

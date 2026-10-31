# 🚀 Ansible Nginx Cluster Deployment

Automatiser le déploiement et la configuration d'un cluster web multi-serveurs avec Ansible.

## 📋 Objectif

Configurer automatiquement plusieurs serveurs Nginx identiques en utilisant Ansible, sans connexion SSH directe manuelle. Le projet simule une infrastructure réelle avec Docker.

## 🔧 Pré-requis

- Docker & Docker Compose
- Ansible (`pip install ansible`)
- SSH client (généré automatiquement)

```bash
pip install ansible
```

## 🎯 Étapes de réalisation

### 1️⃣ Démarrer l'infrastructure simulée

```bash
docker-compose up -d
```

Cela lance 3 serveurs Ubuntu avec SSH activé:
- `web-server-1` (172.20.0.2)
- `web-server-2` (172.20.0.3)
- `web-server-3` (172.20.0.4)

### 2️⃣ Vérifier la connectivité Ansible

```bash
ansible all -i inventory.ini -m ping
```

Devrait montrer 3 `pong` réussis.

### 3️⃣ Exécuter le playbook principal

```bash
ansible-playbook -i inventory.ini playbook.yml
```

Cela va:
- Installer Nginx sur tous les serveurs
- Créer un fichier de configuration personnalisé
- Générer un index.html avec le hostname du serveur
- Démarrer et valider Nginx

### 4️⃣ Tester le cluster

```bash
# Vérifier la réponse de chaque serveur
curl http://localhost:8001
curl http://localhost:8002
curl http://localhost:8003
```

Chaque réponse affichera un contenu différent selon le serveur.

### 5️⃣ Vérifier les logs Ansible

```bash
# Mode verbose
ansible-playbook -i inventory.ini playbook.yml -v

# Mode très verbose (debug)
ansible-playbook -i inventory.ini playbook.yml -vv
```

## 📚 Ce qu'on apprend

✅ **Ansible Playbooks** - Structures YAML et exécution de tâches  
✅ **Inventories** - Configuration des hôtes et groupes  
✅ **Modules Ansible** - `apt`, `service`, `template`, `copy`, `shell`  
✅ **Variables et templates** - Customization par serveur  
✅ **Idempotence** - Exécutions répétées sans changements involontaires  
✅ **Handlers** - Déclencher des actions conditionnelles  
✅ **Configuration Management** - Gérer un cluster de façon centralisée  

## 📁 Structure du projet

```
.
├── README.md                    # Ce fichier
├── docker-compose.yml           # Simulation de 3 serveurs
├── inventory.ini                # Configuration Ansible
├── playbook.yml                 # Playbook principal
├── roles/
│   └── nginx/
│       ├── tasks/
│       │   └── main.yml        # Tâches d'installation/config
│       ├── handlers/
│       │   └── main.yml        # Handlers (restart, reload)
│       ├── templates/
│       │   └── nginx.conf.j2   # Template nginx.conf
│       └── defaults/
│           └── main.yml        # Variables par défaut
└── group_vars/
    └── webservers.yml          # Variables du groupe webservers
```

## 🔑 Points clés

### Idempotence
Vous pouvez exécuter le playbook plusieurs fois - seules les modifications nécessaires seront appliquées.

### Gestion des serveurs
Le fichier `inventory.ini` centralise la configuration réseau. Pour ajouter un serveur:
```ini
[webservers]
web-server-4 ansible_host=172.20.0.5 nginx_port=8004
```

### Templates Jinja2
Les templates `.j2` permettent de personnaliser les configurations par serveur via des variables.

### Handlers
Redémarrage/rechargement Nginx automatique si la config change.

## 🧪 Cas d'usage avancés

### Déployer sur un sous-groupe
```bash
ansible-playbook -i inventory.ini playbook.yml --limit "web-server-1,web-server-2"
```

### Vérifier les différences sans appliquer
```bash
ansible-playbook -i inventory.ini playbook.yml --check
```

### Appliquer uniquement certains tags
```bash
ansible-playbook -i inventory.ini playbook.yml --tags "nginx-config"
```

## 📖 Ressources

- [Ansible Documentation](https://docs.ansible.com/)
- [Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/index.html)
- [Modules Used](https://docs.ansible.com/ansible/latest/modules/modules_by_category.html)

## 🧹 Cleanup

```bash
docker-compose down
```

---

**Durée estimée**: 1 journée  
**Niveau**: Intermédiaire  
**Tags**: #ansible #infrastructure #automation #nginx

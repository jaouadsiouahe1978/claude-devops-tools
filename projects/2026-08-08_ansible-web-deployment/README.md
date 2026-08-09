# 🚀 Ansible Web Deployment Automation

## Objectif
Automatiser le déploiement et la configuration d'une application web (Node.js) sur plusieurs serveurs avec Ansible. Ceci vous permet d'orchestrer des tâches de déploiement complexes, gérer les configurations et maintenir la cohérence sur plusieurs machines.

## Technologies Utilisées
- **Ansible** : Orchestration et gestion de configuration
- **Node.js** : Runtime de l'application
- **Nginx** : Reverse proxy
- **GitHub Actions** : Trigger du déploiement (intégration CD)
- **systemd** : Gestion du service

## Pré-requis
- Ansible 2.9+ installé localement
- SSH access à des serveurs cibles (ou utiliser localhost pour tester)
- Python 3.6+ sur les serveurs cibles

## Structure du Projet
```
ansible-web-deployment/
├── inventory.ini              # Définition des hôtes
├── playbook.yml              # Playbook principal
├── roles/
│   ├── common/
│   │   └── tasks/
│   │       └── main.yml      # Tâches communes (updates, dépendances)
│   ├── webserver/
│   │   └── tasks/
│   │       └── main.yml      # Installation Nginx, Node.js
│   └── deploy/
│       ├── tasks/
│       │   └── main.yml      # Déploiement de l'app
│       └── templates/
│           └── app.service.j2 # Template systemd
└── .github/
    └── workflows/
        └── deploy.yml        # GitHub Actions workflow
```

## Étapes de Réalisation

### 1. **Préparation - Inventaire Ansible**
- Définir les hôtes cibles dans `inventory.ini`
- Grouper les serveurs par rôle (web, database, etc.)

### 2. **Création des Rôles**
- **Role `common`** : Mise à jour système, installation de paquets essentiels
- **Role `webserver`** : Installation de Node.js et Nginx
- **Role `deploy`** : Clone du repo, installation des dépendances, démarrage du service

### 3. **Configuration du Playbook Principal**
- Orchestrer l'exécution des rôles
- Gérer les handlers (redémarrage de services)
- Ajouter des validations et vérifications

### 4. **Intégration GitHub Actions**
- Créer un workflow qui déclenche le playbook Ansible
- Exécuter le déploiement automatiquement lors d'un push

### 5. **Test et Validation**
- Tester localement avec `localhost`
- Vérifier les idempotence des tâches
- Valider que l'application est accessible

## Ce qu'on Apprend

✅ **Concepts Ansible**
- Structure des playbooks et rôles
- Variables et Jinja2 templating
- Handlers et notifications
- Idempotence des tâches
- Conditional tasks (`when`, `register`)

✅ **Automatisation DevOps**
- Déploiement multi-serveurs
- Gestion des configurations
- CI/CD integration avec GitHub Actions

✅ **Cas d'usage réel**
- Provisionner un environnement production
- Orchestrer des mises à jour sans downtime
- Auditer les configurations avec `ansible-inventory`

## Commandes Clés

```bash
# Vérifier la syntaxe du playbook
ansible-playbook playbook.yml --syntax-check

# Dry-run (simulation)
ansible-playbook -i inventory.ini playbook.yml --check

# Exécution réelle
ansible-playbook -i inventory.ini playbook.yml

# Exécuter un rôle spécifique
ansible-playbook -i inventory.ini playbook.yml --tags "webserver"

# Lister les hôtes
ansible-inventory -i inventory.ini --list
```

## Ressources
- [Ansible Playbooks](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html)
- [Ansible Roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)
- [Jinja2 Templates](https://docs.ansible.com/ansible/latest/user_guide/playbooks_templating.html)

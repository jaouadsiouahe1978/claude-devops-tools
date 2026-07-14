# 📢 DevOps du Jour - 14 Juillet 2026

## 🚀 Ansible Multi-Server Configuration Management

**Thème**: Configuration Management & Infrastructure as Code  
**Technologies**: Ansible 2.9+, Nginx, PostgreSQL 14, Ubuntu/Debian, Docker  
**Difficulté**: Intermédiaire  
**Durée estimée**: 4-6 heures  

---

## 📋 Le Projet

Un système complet de gestion d'infrastructure multi-serveurs avec Ansible, prêt pour la production :

### Rôles Créés (3)
1. **Common Role** - Configuration de base système
   - Installation des packages
   - Configuration du timezone + NTP
   - SSH hardening
   - Firewall (UFW)
   - Mises à jour de sécurité automatiques

2. **Webserver Role** - Nginx
   - Installation et configuration
   - Virtual hosts dynamiques (Jinja2)
   - Support SSL/TLS
   - Gzip compression
   - Caching strategy
   - Health check endpoint
   - Monitoring status page

3. **Database Role** - PostgreSQL 14
   - Installation et configuration
   - Création de bases de données
   - Gestion des utilisateurs
   - Performance tuning (shared_buffers, work_mem)
   - **Backup automatique quotidien** avec rétention
   - Support réplication (HA ready)
   - Logging et monitoring

### Environnements Configurés (3)
- **Production** : Serveurs réels avec variables optimisées
- **Staging** : Configuration test réduite
- **Development** : Docker Compose pour validation locale

---

## 🎓 Ce Qu'On Apprend

### Concepts Ansible Fondamentaux
✅ Structure de playbooks et organisation  
✅ **Rôles** pour la réutilisabilité et la scalabilité  
✅ **Handlers** - Gestion d'événements intelligente (redémarrage service only if changed)  
✅ **Templates Jinja2** - Configurations dynamiques  
✅ **Variables** - Hiérarchie (defaults → group_vars → host_vars → command-line)  
✅ **Tags** - Exécution sélective de tâches  
✅ **Inventaire** - Gestion multi-environnements  

### Principes DevOps
✅ **Idempotence** - Sûr de lancer le playbook N fois  
✅ **Configuration as Code** - Versionnable et traçable  
✅ **Infrastructure Automation** - De 1 à 1000 serveurs  
✅ **Déploiements Rolling** - Sans downtime  
✅ **Secrets Management** - Vault support  
✅ **Dry-run testing** - --check mode  

### Infrastructure Réelle
✅ Nginx configuration avancée (SSL, caching, compression)  
✅ PostgreSQL tuning performance  
✅ Backup automation et stratégie de rétention  
✅ Replication & HA setup  
✅ Monitoring et logging  

---

## 📁 Fichiers Créés (33 fichiers)

```
2026-07-14_ansible-multi-server-config/
├── playbook.yml              # Playbook principal
├── ansible.cfg               # Configuration Ansible
├── requirements.yml          # Dépendances Galaxy
├── Makefile                  # Commands essentielles
├── docker-compose.yml        # Test environment
├── README.md                 # Getting started
├── PROJECT_SUMMARY.md        # Overview complet
├── ADVANCED_USAGE.md         # Topics avancés
├── TROUBLESHOOTING.md        # Common issues & solutions
├── inventory/                # 3 inventaires
│   ├── production.ini
│   ├── staging.ini
│   └── dev.ini
├── group_vars/               # Variables par groupe
│   ├── all.yml
│   ├── webservers.yml
│   └── databases.yml
├── roles/
│   ├── common/               # ~50 lignes tasks
│   ├── webserver/            # ~100 lignes tasks
│   └── database/             # ~100 lignes tasks
```

**Statistiques**: 2231 insertions, 33 fichiers, structure production-ready

---

## 🚀 Quick Start

```bash
# 1. Installer Ansible
pip install ansible>=2.9

# 2. Test sur Docker
make docker-up
make docker-test

# 3. Valider syntaxe
make syntax-check

# 4. Dry-run
make check

# 5. Deploy
make deploy
```

---

## 🔑 Highlights Techniques

### Handlers (Innovation Clé)
Les handlers s'exécutent **uniquement si une tâche change** :
```yaml
- name: Installer Nginx
  apt: name=nginx
  notify: restart nginx  # S'exécute que si installé/modifié

handlers:
  - name: restart nginx
    systemd: name=nginx state=restarted
```

### Templates Jinja2
Configurations dynamiques basées sur variables :
```jinja2
listen {{ item.listen | default('80') }};
server_name {{ item.server_name }};
worker_processes {{ nginx_worker_processes }};
```

### Variable Precedence
```
Command-line (-e) > Play > Registered > Host vars > Group vars > Defaults
```

### Backup Automation
Script bash généré par Ansible pour backups PostgreSQL quotidiens :
```bash
pg_dumpall | gzip > backup_$DATE.sql.gz
# Nettoyage auto des backups > 30 jours
```

---

## 🎯 Exercices Proposés

### Exercice 1 : Docker Testing
```bash
make docker-up
ansible -i inventory/dev.ini all -m ping
```

### Exercice 2 : Add Custom Nginx Site
```bash
# Éditer group_vars/webservers.yml
# Ajouter site à nginx_sites
ansible-playbook playbook.yml --tags webserver --check
```

### Exercice 3 : Enable Database Backup
```bash
# group_vars/databases.yml : backup_enabled: yes
ansible-playbook playbook.yml --tags database
```

### Exercice 4 : Vault Secrets
```bash
ansible-vault create group_vars/databases/vault.yml
# Ajouter: postgres_admin_password: "secret"
ansible-playbook playbook.yml --ask-vault-pass
```

### Exercice 5 : Deploy Progression
```bash
# Deployment par étapes (serial: 2)
make deploy  # Deploy aux 2 web servers en parallèle
```

---

## 📚 Apprentissage Progressif

| Jour | Focus | Commandes |
|------|-------|-----------|
| 1 | Structure playbooks + roles | make syntax-check, make check |
| 2 | Common role | ansible-playbook ... --tags common |
| 3 | Webserver role | ansible-playbook ... --tags webserver |
| 4 | Database role | ansible-playbook ... --tags database |
| 5 | Vault + secrets | ansible-vault, --ask-vault-pass |

---

## 🔐 Security Features

✅ **SSH Hardening**: Disable root login, key-based auth only  
✅ **Firewall**: UFW configured with minimal open ports  
✅ **Auto Updates**: Automatic security patches  
✅ **Vault**: Secrets encryption built-in  
✅ **Audit Logging**: PostgreSQL logs all connections  

---

## 💡 Key Takeaways

1. **Rôles = Scalabilité** : Write once, deploy to 1000+ servers
2. **Handlers = Efficiency** : Service restarts only when config changes
3. **Idempotence = Safety** : Run playbook multiple times safely
4. **Variables = Flexibility** : Same code for dev/staging/prod
5. **Vault = Secrets** : Encrypted password management

---

## 📊 Statistiques du Projet

- **33 fichiers** créés
- **2231 lignes** de code/config Ansible
- **3 rôles** complètement fonctionnels
- **3 inventaires** pour différents environnements
- **5 templates Jinja2** pour configurations dynamiques
- **4 guides** (README, ADVANCED_USAGE, TROUBLESHOOTING, PROJECT_SUMMARY)
- **Makefile** avec 12+ commandes utiles

---

## 🎓 Niveau Suivant

- Intégration CI/CD (GitHub Actions)
- Molecule testing framework
- Ansible Tower/AWX
- Dynamic inventory scripts
- Custom Ansible modules

---

**Créé**: 2026-07-14  
**Pour**: Jaouad (Formation DevOps/SRE Grenoble)  
**Repo**: https://github.com/jaouadsiouahe1978/claude-devops-tools

> "Infrastructure as Code isn't just about automation — it's about making infrastructure reproducible, testable, and maintainable at scale."

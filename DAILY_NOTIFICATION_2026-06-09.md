# 📦 DevOps Project du 2026-06-09 : Ansible Deploy Stack

## Résumé du Projet

**Nom** : `2026-06-09_ansible-deploy-stack`  
**Thème** : Infrastructure Automation avec Ansible  
**Technos** : Ansible, Docker, Nginx, PostgreSQL, Python Flask  

### 🎯 Objectif

Créer une infrastructure entièrement automatisée avec **Ansible** pour déployer une stack complète (load balancer, web servers, databases) sur plusieurs serveurs avec gestion centralisée de la configuration.

## 📊 Contenu du Projet

### Structure
```
29 fichiers créés
- 4 rôles Ansible (docker, nginx, postgres, app)
- 2 playbooks principaux (site.yml, deploy.yml)
- Inventaire avec groupes et variables
- Application Flask avec API PostgreSQL
- Documentation et guides complets
```

### 🔧 Rôles Ansible Implémentés

1. **docker** : Installation Docker + docker-compose + réseau custom
2. **nginx** : Configuration reverse proxy (templates Jinja2)
3. **postgres** : Déploiement base de données + initialisation
4. **app** : Application Flask Flask + Gunicorn + health checks

### 📚 Fonctionnalités Clés

- ✅ **Playbooks réutilisables** : site.yml (déploiement complet) + deploy.yml (redéploiement rapide)
- ✅ **Gestion d'inventaire** : groupes (webservers, databases, loadbalancers) + variables par groupe
- ✅ **Handlers intelligents** : redémarrages de services uniquement si nécessaire
- ✅ **Templates Jinja2** : configuration dynamique (nginx.conf, docker-compose)
- ✅ **Application Flask complète** : API REST + connexion PostgreSQL
- ✅ **Health checks** : vérification POST-déploiement
- ✅ **Idempotence** : exécutable plusieurs fois sans effet de bord

### 💡 Ce qu'on Apprend

1. **Ansible Playbooks** : syntaxe YAML, tâches, conditions
2. **Rôles Ansible** : organisation modulaire et réutilisable
3. **Inventaires & Variables** : groupes, group_vars, host_vars
4. **Handlers & Notifications** : redémarrages intelligents
5. **Templates Jinja2** : configuration dynamique avec variables
6. **Intégration Docker** : gestion conteneurs via Ansible
7. **Tests & Validation** : health checks et vérifications
8. **Bonnes pratiques** : idempotence, dry-run, tags

## 🚀 Utilisation

### Installation rapide
```bash
cd projects/2026-06-09_ansible-deploy-stack/
pip install -r requirements.txt
```

### Déploiement
```bash
# Vérifier la syntaxe
make check

# Dry-run
make deploy-check

# Déploiement réel
make deploy

# Redéployer app seule
make deploy-app
```

## 📖 Documentation Incluse

- **README.md** : Guide complet du projet (100+ lignes)
- **COMMANDS.md** : 100+ commandes Ansible avec exemples
- **Makefile** : raccourcis pour commandes courantes
- **ansible.cfg** : configuration Ansible optimisée
- **provision.sh** : script d'installation automatique

## 🎓 Points Pédagogiques Clés

| Concept | Implémentation |
|---------|---------------|
| **Rôles** | 4 rôles modulaires + templating |
| **Inventaire** | Multi-groupes + variables dynamiques |
| **Playbooks** | Déploiement complet + partiel |
| **Handlers** | Redémarrage conditionnel des services |
| **Templates** | Nginx config + docker-compose dynamiques |
| **Tests** | Health checks + URI module |
| **Idempotence** | Exécution sans effet de bord |

## 🔄 Flux de Déploiement

```
Inventaire
    ↓
site.yml (playbook principal)
    ├→ docker (tous les hôtes)
    ├→ nginx (load balancers)
    ├→ postgres (databases)
    └→ app (webservers)
        ↓
    Tests post-déploiement
        ↓
    Health checks (health endpoint)
```

## 🎯 Cas d'Usage Réels

- ✅ Déployer une app sur 10+ serveurs en parallèle
- ✅ Mettre à jour configuration sans downtime
- ✅ Redéploiement rapide des nouvelles versions
- ✅ Infrastructure as Code (IaC) documentée
- ✅ Intégration avec CI/CD (GitHub Actions, Jenkins)
- ✅ Rollback facile en cas de problème

## 🌟 Prochaines Étapes pour Approfondir

- Intégrer **Terraform** pour provisionner VMs
- Ajouter **Ansible Vault** pour secrets
- Implémenter **Molecule** pour tests des rôles
- Ajouter **monitoring** (Prometheus/Grafana)
- Configurer **log centralization** (ELK)
- Intégrer avec **GitHub Actions** pour CI/CD

## 📊 Statistiques du Projet

- **Fichiers créés** : 29
- **Lignes de code** : ~1200
- **Rôles** : 4
- **Playbooks** : 2
- **Templates** : 4
- **Hôtes configurables** : 6+
- **Temps de réalisation estimé** : 1 journée

---

**Date de création** : 2026-06-09  
**Durée estimée** : 1 journée  
**Niveau** : Débutant à Intermédiaire  
**Technos** : Ansible, Docker, Kubernetes-ready

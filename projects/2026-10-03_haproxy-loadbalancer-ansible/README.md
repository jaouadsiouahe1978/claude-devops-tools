# HAProxy Load Balancer avec Ansible

## Objectif
Automatiser le déploiement et la configuration d'une infrastructure de load balancing complète avec HAProxy comme reverse proxy et plusieurs serveurs Nginx backend avec health checks.

## Technos utilisées
- **Ansible**: Orchestration et automatisation IaC
- **HAProxy**: Load balancer reverse proxy
- **Nginx**: Serveurs backend
- **Jinja2**: Templates de configuration
- **YAML**: Playbooks Ansible

## Pré-requis
- Ansible 2.9+ installé sur la machine de contrôle
- Accès SSH à au moins 3 serveurs Linux (1 pour HAProxy, 2+ pour Nginx backend)
- Python 3.6+ sur tous les serveurs
- Sudo rights sur les serveurs cibles

## Architecture
```
                    ┌─────────────────┐
                    │  Internet/Client │
                    └────────┬─────────┘
                             │ :80, :443
                    ┌────────▼──────────┐
                    │  HAProxy (LB)     │
                    │  Load Balancer    │
                    └────────┬──────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
      ┌─────▼────┐     ┌─────▼────┐     ┌─────▼────┐
      │  Nginx 1  │     │  Nginx 2  │     │  Nginx 3  │
      │  :8080    │     │  :8080    │     │  :8080    │
      └───────────┘     └───────────┘     └───────────┘
```

## Structure du projet
```
.
├── README.md
├── inventory/
│   ├── hosts.ini
│   └── group_vars/
│       ├── haproxy.yml
│       └── nginx_backend.yml
├── roles/
│   ├── common/
│   │   └── tasks/main.yml
│   ├── haproxy/
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   └── templates/haproxy.cfg.j2
│   └── nginx_backend/
│       ├── tasks/main.yml
│       ├── handlers/main.yml
│       └── templates/nginx.conf.j2
└── site.yml
```

## Étapes de réalisation

### 1. Préparer l'inventaire
Modifier `inventory/hosts.ini` avec vos serveurs :
```ini
[haproxy]
lb-server ansible_host=192.168.1.10 ansible_user=ubuntu

[nginx_backend]
web1 ansible_host=192.168.1.11 ansible_user=ubuntu
web2 ansible_host=192.168.1.12 ansible_user=ubuntu
web3 ansible_host=192.168.1.13 ansible_user=ubuntu
```

### 2. Configurer les variables de groupe
- HAProxy: Ports, algorithme de load balancing, health checks
- Nginx: Ports backend, server blocks

### 3. Exécuter le playbook
```bash
ansible-playbook -i inventory/hosts.ini site.yml
```

### 4. Tester le load balancer
```bash
# Accéder au HAProxy Stats
curl http://lb-server:8404/stats

# Tester le load balancing
for i in {1..10}; do curl http://lb-server/; done
```

## Ce qu'on apprend

✅ **Playbooks Ansible** - Structure et exécution orchestrée
✅ **Rôles Ansible** - Modularisation et réutilisabilité
✅ **Templates Jinja2** - Génération dynamique de configuration
✅ **Handlers** - Gestion des notifications et redémarrages
✅ **Inventaire avancé** - Organisation et group_vars
✅ **HAProxy** - Configuration load balancing & reverse proxy
✅ **Health checks** - Configuration et monitoring de santé
✅ **Idempotence** - Exécution sûre et répétable
✅ **Facts Ansible** - Utilisation des variables système

## Configuration avancée

### Algorithme de load balancing
Modifier dans `group_vars/haproxy.yml`:
- `roundrobin`: Round-robin simple (défaut)
- `leastconn`: Connexions les moins nombreuses
- `uri`: Hash basé sur l'URI
- `source`: Hash basé sur l'IP source

### Health checks
Configuration dans le template HAProxy:
```
check inter 2s rise 3 fall 2
```
- `inter`: Intervalle entre checks (2s)
- `rise`: Nombre de succès pour marquer comme UP (3)
- `fall`: Nombre d'échecs pour marquer comme DOWN (2)

### Mode de balancing
- **TCP mode**: Pour protocoles non-HTTP
- **HTTP mode**: Pour HTTP/HTTPS (par défaut)

## Validation

```bash
# Vérifier la syntaxe des playbooks
ansible-playbook -i inventory/hosts.ini site.yml --syntax-check

# Run avec verbosité
ansible-playbook -i inventory/hosts.ini site.yml -v

# Test sur un seul hôte
ansible-playbook -i inventory/hosts.ini site.yml --limit haproxy

# Check mode (dry-run)
ansible-playbook -i inventory/hosts.ini site.yml --check
```

## Améliorations futures
- [ ] Ajout de SSL/TLS avec certbot
- [ ] Metrics Prometheus pour HAProxy
- [ ] Alertes Grafana
- [ ] Autoscaling des backend servers
- [ ] Failover automatique
- [ ] Configuration de persistence sessions

## Référence
- [HAProxy Documentation](http://www.haproxy.org/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Jinja2 Templates](https://jinja.palletsprojects.com/)

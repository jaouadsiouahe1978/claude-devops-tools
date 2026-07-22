# QuickStart - Ansible Web Stack

## 1. Lancer les serveurs de test
```bash
cd projects/2026-07-22_ansible-web-stack
docker-compose up -d
```

Vérifier que les conteneurs tournent :
```bash
docker-compose ps
```

## 2. Tester la connexion Ansible
```bash
ansible -i inventory/hosts.ini all -m ping
```

Expected output :
```
web1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
...
```

## 3. Exécuter un dry-run
```bash
ansible-playbook -i inventory/hosts.ini playbooks/site.yml --check
```

## 4. Déployer la stack (réel)
```bash
ansible-playbook -i inventory/hosts.ini playbooks/site.yml -v
```

## 5. Vérifier le déploiement

### Tester Nginx
```bash
curl http://localhost:8080
curl http://localhost:8081
```

### Tester PostgreSQL
```bash
psql -h localhost -p 5432 -U appuser -d app_db
# Password: AppUserPassword123

# Vérifier la table
\dt
SELECT * FROM users;
\q
```

### Vérifier les services
```bash
ansible -i inventory/hosts.ini webservers -m command -a "systemctl status nginx"
ansible -i inventory/hosts.ini databases -m command -a "systemctl status postgresql"
```

## Nettoyage
```bash
docker-compose down
```

## Troubleshooting

**Erreur SSH : "Permission denied"**
- Les conteneurs ont besoin de temps pour démarrer SSH
- Attendez 5-10 secondes et réessayez

**Erreur PostgreSQL : "could not connect"**
- Vérifier que le conteneur db1 est actif : `docker ps`
- Vérifier les ports : `docker-compose logs db1`

**Ansible hosts non trouvés**
- Vérifier la résolution DNS des conteneurs
- Tester : `docker exec web1 hostname -I`

# Hardened Linux Server Setup with Security Best Practices

## 📋 Objectif

Mettre en place un serveur Linux sécurisé en appliquant les meilleures pratiques de sécurité DevOps/SysAdmin. Ce projet couvre la configuration initiale d'un serveur, durcissement du système, gestion d'utilisateurs, sécurisation SSH, configuration du firewall et mise en place du monitoring de sécurité.

## 🛠 Technologies Utilisées

- **Ubuntu/Debian Linux**
- **UFW (Uncomplicated Firewall)** - Gestion du firewall
- **SSH** - Hardening des connexions distantes
- **Sudo** - Contrôle d'accès privilegié
- **Fail2ban** - Protection contre les attaques par brute-force
- **Bash** - Scripts d'automatisation
- **auditd** - Audit du système
- **Aide/Tripwire** - Détection d'intrusion

## 🎯 Ce qu'on apprend

1. **Gestion des utilisateurs et groupes** : Création, modification, suppression sécurisée
2. **Hardening SSH** : Désactiver root login, changer le port, utiliser les clés RSA
3. **Configuration du firewall** : UFW pour gérer les règles entrantes/sortantes
4. **Sudo & Privileges** : Configuration précise du fichier sudoers
5. **Fail2ban** : Protection contre les attaques par dictionnaire
6. **Audit & Monitoring** : auditd pour tracker les changements système
7. **Checklists de sécurité** : Vérifications de conformité CIS Benchmark

## 📂 Structure du Projet

```
2026-08-15_linux-hardened-server/
├── README.md (ce fichier)
├── scripts/
│   ├── 01_initial_setup.sh         # Mises à jour et installations basiques
│   ├── 02_users_setup.sh           # Gestion des utilisateurs
│   ├── 03_ssh_hardening.sh         # Sécurisation SSH
│   ├── 04_firewall_setup.sh        # Configuration UFW
│   ├── 05_fail2ban_setup.sh        # Protection brute-force
│   ├── 06_audit_setup.sh           # Configuration auditd
│   └── 07_security_checklist.sh    # Vérifications de sécurité
├── config/
│   ├── sshd_config                 # Configuration SSH hardened
│   ├── sudoers                     # Fichier sudoers avec restrictions
│   ├── fail2ban_jail.conf          # Configuration Fail2ban
│   └── audit.rules                 # Règles d'audit
└── Makefile                         # Automatisation des déploiements
```

## 🚀 Étapes de Réalisation

### Étape 1 : Setup Initial du Serveur (05 min)
```bash
chmod +x scripts/01_initial_setup.sh
sudo ./scripts/01_initial_setup.sh
```
- Mise à jour des paquets
- Installation des outils essentiels
- Configuration hostname/timezone
- Désactivation des services inutiles

### Étape 2 : Gestion des Utilisateurs (10 min)
```bash
chmod +x scripts/02_users_setup.sh
sudo ./scripts/02_users_setup.sh
```
- Création d'utilisateurs non-root
- Configuration des groupes de sudoers
- Suppression de l'utilisateur root (lock)
- Homedir sécurisés avec permissions correctes

### Étape 3 : Hardening SSH (15 min)
```bash
chmod +x scripts/03_ssh_hardening.sh
sudo ./scripts/03_ssh_hardening.sh
```
- Désactivation de la connexion root
- Désactivation du password authentication
- Changement du port SSH
- Restriction aux IP autorisées
- Configuration timeouts et limites

### Étape 4 : Configuration Firewall (10 min)
```bash
chmod +x scripts/04_firewall_setup.sh
sudo ./scripts/04_firewall_setup.sh
```
- Activation d'UFW
- Règles par défaut (deny incoming, allow outgoing)
- Ouverture ports essentiels (SSH, HTTP, HTTPS)
- Rate limiting

### Étape 5 : Protection Fail2ban (10 min)
```bash
chmod +x scripts/05_fail2ban_setup.sh
sudo ./scripts/05_fail2ban_setup.sh
```
- Installation et configuration Fail2ban
- Monitoring des logs SSH
- Ban automatique après X tentatives
- Notifications en cas de ban

### Étape 6 : Audit du Système (10 min)
```bash
chmod +x scripts/06_audit_setup.sh
sudo ./scripts/06_audit_setup.sh
```
- Configuration auditd
- Audit des changements système
- Audit des accès fichiers sensibles
- Alertes sur actions critiques

### Étape 7 : Vérifications de Sécurité (10 min)
```bash
chmod +x scripts/07_security_checklist.sh
sudo ./scripts/07_security_checklist.sh
```
- Vérification des permissions fichiers critiques
- Vérification sudoers
- Scan des vulnérabilités locales
- Rapports de conformité

## 📊 Durée Totale

**~1 jour de travail** (70 min d'exécution + compréhension)

## 📈 Améliorations Futures

- [ ] Intégration avec Prometheus pour monitoring avancé
- [ ] Chiffrement disque complet (LUKS)
- [ ] SELinux ou AppArmor hardening
- [ ] Certificats TLS/SSH
- [ ] Backup automatisé
- [ ] Intrusion Detection avec OSSEC
- [ ] Ansible playbook pour orchestration multi-serveurs

## 🔐 Sécurité

⚠️ **IMPORTANT** : Ce projet est pour apprentissage en environnement de dev/test. En production :
- Adapter les règles firewall à votre infrastructure
- Utiliser un gestionnaire de secrets (Vault, AWS Secrets Manager)
- Implémenter une stratégie de backup/DR
- Faire audits de sécurité réguliers
- Respecter CIS Benchmark et SOC2 si applicable

## 📚 Ressources Utiles

- [CIS Benchmark Linux](https://www.cisecurity.org/cis-benchmarks/)
- [UFW Documentation](https://help.ubuntu.com/community/UFW)
- [SSH Hardening Guide](https://www.ssh.com/ssh/server/hardening)
- [Fail2ban Setup](https://www.fail2ban.org/)
- [auditd Tutorial](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/chap-system_auditing)

## ✅ Vérifications Post-Déploiement

```bash
# Vérifier SSH ne listen que sur le nouveau port
sudo ss -tlnp | grep ssh

# Vérifier les règles UFW
sudo ufw status

# Vérifier Fail2ban
sudo fail2ban-client status sshd

# Vérifier auditd
sudo auditctl -l
```

---

**Créé le** : 2026-08-15  
**Niveau** : Débutant à Intermédiaire  
**Temps apprentissage** : 1 journée complète

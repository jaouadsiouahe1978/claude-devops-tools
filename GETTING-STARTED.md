# 🎯 Guide de démarrage - Projets DevOps Quotidiens

Bienvenue Jaouad ! Ce guide explique comment utiliser ce système de projets DevOps générés automatiquement.

## 🚀 Qu'est-ce que c'est ?

Chaque jour, un **nouveau projet DevOps** est créé automatiquement dans ce repo:
- Projet **réalisable en 1 journée**
- **Niveau débutant à intermédiaire**
- **Code complet et fonctionnel** (pas juste de la doc)
- **Technos variées**: Docker, Kubernetes, CI/CD, Terraform, Ansible, etc.

## 📂 Où sont les projets ?

```
projects/
├── 2026-05-26_prometheus-monitor/         ← Projet d'aujourd'hui 🆕
├── 2026-05-25_prometheus-alertmanager-notifications/
├── 2026-05-24_...
└── ...
```

**Format du nom:** `YYYY-MM-DD_nom-du-theme`

## 🎓 Comment utiliser un projet

### 1. Choisir un projet

```bash
# Voir les projets disponibles
ls -la projects/

# Aller dans un projet
cd projects/2026-05-26_prometheus-monitor/
```

### 2. Lire le README

```bash
# Chaque projet a une documentation détaillée
cat README.md
```

Le README inclut:
- **Objectif**: Qu'allez-vous apprendre
- **Pré-requis**: Outils nécessaires
- **Étapes**: Instructions étape-par-étape
- **Ce qu'on apprend**: Concepts maîtrisés
- **Ressources**: Liens utiles

### 3. Réaliser le projet

```bash
# Exemple pour un projet Docker
docker-compose up -d

# Exemple pour Terraform
terraform init
terraform plan
terraform apply

# Exemple pour Ansible
ansible-playbook -i inventory.ini playbook.yml
```

### 4. Vérifier le résultat

Chaque projet inclut des commandes pour vérifier que tout fonctionne:

```bash
# Voir les services actifs
docker ps

# Vérifier la connectivité
curl http://localhost:8080

# Tester avec les healthchecks fournis
./health-check.sh
```

## 📅 Calendrier des thèmes

La rotation suit le **numéro du jour de l'année**, donc:

| Jour N° | Thème | Exemple |
|---------|-------|---------|
| 1-36 | Docker | 2026-01-01, 2027-01-01 |
| 37-72 | Kubernetes | 2026-02-06, 2027-02-06 |
| 73-108 | GitHub Actions | 2026-03-14, 2027-03-14 |
| 109-144 | Terraform | 2026-04-19, 2027-04-19 |
| 145-180 | Ansible | 2026-05-25, 2027-05-25 |
| 181-216 | Prometheus | 2026-06-30, 2027-06-30 |
| 217-252 | Bash Scripts | 2026-08-05, 2027-08-05 |
| 253-288 | Python Tools | 2026-09-10, 2027-09-10 |
| 289-324 | Jenkins | 2026-10-20, 2027-10-20 |
| 325-365 | ELK Stack | 2026-11-21, 2027-11-21 |

## 🎯 Suggestions d'utilisation

### Option 1: Un projet par jour (recommandé ⭐)

```bash
# Chaque jour, réaliser le projet du jour
cd projects/$(date +%Y-%m-%d)*
./scripts/setup.sh  # si disponible
# Suivre les étapes du README
```

### Option 2: Marathon du weekend

```bash
# Faire plusieurs projets les samedi/dimanche
cd projects/
ls | sort -r | head -3  # 3 derniers projets
# Faire un projet à la suite de l'autre
```

### Option 3: Apprendre progressivement

```bash
# Choisir les projets par thème
cd projects/
grep -l "Docker" */README.md
grep -l "Kubernetes" */README.md
# Faire tous les projets d'un thème
```

## 💾 Votre progression

### Suivre vos accomplissements

```bash
# Créer un fichier pour tracker votre progression
cat > MY_PROGRESS.md << EOF
# Ma progression DevOps

## Projets complétés
- [x] 2026-05-26 Prometheus Monitoring
- [ ] 2026-05-27 (prochain)
- [ ] 2026-05-28

## Technos maîtrisées
- Docker ✅
- Kubernetes 🔄 (en cours)

## Notes personnelles
...
EOF
```

### Ce qu'on apprend en 1 an

En suivant 1 projet par jour pendant 1 an:

- ✅ **Docker & Containerization** (36-40 jours)
- ✅ **Kubernetes Orchestration** (36-40 jours)
- ✅ **CI/CD Pipelines** (36-40 jours)
- ✅ **Infrastructure as Code** (36-40 jours)
- ✅ **Configuration Management** (36-40 jours)
- ✅ **Monitoring & Alerting** (36-40 jours)
- ✅ **Scripting** (36-40 jours) + tools spécialisés
- ✅ **Logging & ELK Stack** (36-40 jours)

**Total:** Une formation complète DevOps/SRE! 🎓

## 🔗 Ressources externes

### Documentation officielles

- [Docker Docs](https://docs.docker.com/)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Terraform Registry](https://registry.terraform.io/)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [Prometheus Docs](https://prometheus.io/docs/)

### Communautés

- **DevOps Grenoble**: Forums et meetups locaux
- **Reddit**: r/devops, r/kubernetes, r/docker
- **Discord**: Serveurs d'apprentissage DevOps
- **Stack Overflow**: Pour les questions spécifiques

### Blogs inspirants

- SRE Google
- Netflix Engineering Blog
- Hashicorp Blog (Terraform, Consul)
- Kubernetes Official Blog

## 🆘 Besoin d'aide ?

### Problèmes courants

**Erreur: "Docker daemon not running"**
```bash
# Démarrer Docker
sudo systemctl start docker
# ou sur Mac: open /Applications/Docker.app
```

**Erreur: "Port 8080 already in use"**
```bash
# Changer le port dans docker-compose.yml
# De: "8080:3000"
# À: "8081:3000"
```

**Erreur: "Module not found" (Python/Node)**
```bash
# Installer les dépendances
pip install -r requirements.txt
npm install
```

### Ressources d'aide

1. **Vérifier les logs du projet**
   ```bash
   cat README.md | grep -A 5 "Troubleshooting"
   ```

2. **Demander de l'aide**
   - Créer une issue GitHub
   - Demander à un mentor
   - Consulter la communauté

3. **Vérifier le statut du projet**
   ```bash
   git log --oneline projects/[NOM_PROJET]
   ```

## 🎁 Bonus: Créer une issue GitHub

Trouvez une amélioration possible ? Documentez-la:

```bash
gh issue create \
  --title "Amélioration: [nom du projet]" \
  --body "Description de l'amélioration..."
```

## 📊 Votre dashboard personnel

Vous pouvez créer votre propre tracking:

```bash
# Compter les projets complétés
ls projects/ | wc -l

# Voir les projets du dernier mois
ls projects/ | grep "2026-05"

# Chercher des projets spécifiques
ls projects/ | grep "docker"
ls projects/ | grep "kubernetes"
```

## 🚀 Prochaines étapes

1. ✅ Choisir le projet du jour: **2026-05-26_prometheus-monitor**
2. ✅ Lire son README
3. ✅ Suivre les étapes d'installation
4. ✅ Vérifier que ça marche
5. ✅ Documenter votre apprentissage
6. ✅ Répéter tous les jours! 🔄

## 💪 Motivation

> "La maîtrise DevOps ne vient pas en un jour, mais en pratiquant chaque jour."

En suivant ce système:
- Vous apprenez **une technologie complète par mois**
- Vous construisez un **portfolio impressionnant** (365 projets en 1 an!)
- Vous êtes **prêt pour une carrière DevOps/SRE**

Allez-y, bon apprentissage! 🚀

---

**Questions ?** Consultez [DAILY-PROJECT-SYSTEM.md](./DAILY-PROJECT-SYSTEM.md) pour plus de détails techniques.

**Dernière mise à jour:** 2026-05-26

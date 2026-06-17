# 📦 DevOps du jour - 2026-06-17

## 🎯 Kubernetes Autoscaling (HPA)

**Notification** : `curl -X POST -H "Title: DevOps du jour" -H "Tags: devops,kubernetes,autoscaling" -d "[MESSAGE]" https://ntfy.sh/jaouad-devops-veille`

---

## 📋 Résumé du projet

Créé un projet complet sur **Kubernetes Horizontal Pod Autoscaler (HPA)** pour apprendre le scaling automatique des pods basé sur les métriques CPU/mémoire.

### Objectif
- Comprendre comment Kubernetes peut automatiquement augmenter/diminuer le nombre de pods
- Apprendre les concepts de Requests, Limits et métriques
- Mettre en pratique avec une vraie application

---

## 🏗️ Fichiers créés

### Structure du projet
```
projects/2026-06-17_kubernetes-autoscaling/
├── README.md                    # Documentation principale
├── QUICKSTART.md                # Démarrage rapide
├── TROUBLESHOOTING.md           # Guide de dépannage
├── docker-compose.yml           # Développement local
├── nginx.conf                   # Config Nginx pour docker-compose
├── app/
│   └── app.py                  # Application Flask
├── docker/
│   ├── Dockerfile              # Image Docker
│   └── requirements.txt         # Dépendances Python
├── k8s/
│   ├── deployment.yaml         # Deployment + Service
│   ├── hpa.yaml                # Horizontal Pod Autoscaler
│   └── resource-quota.yaml     # Resource Quota + Network Policy
└── scripts/
    ├── setup.sh                # Installation/setup
    ├── test-load.sh            # Génération de charge
    └── monitor.sh              # Monitoring en temps réel
```

---

## 📚 Contenu du projet

### 1. Application (Flask)
- Endpoints pour tester l'autoscaling :
  - `/` : Health check
  - `/ready` : Readiness probe
  - `/cpu-intensive` : Charge CPU (50M itérations)
  - `/memory-test` : Allocation mémoire (~100MB)
  - `/info` : Infos de l'application
- Probes Kubernetes : Liveness + Readiness

### 2. Manifests Kubernetes
- **Deployment** : 2 réplicas initial, rolling updates, pod anti-affinity
- **Service** : ClusterIP avec session affinity
- **HPA** : 
  - Min 2 pods, Max 10 pods
  - Seuils : CPU 70%, Mémoire 80%
  - Scale-up : Immédiat
  - Scale-down : Après 5 minutes
- **Resource Quota** : Limites du namespace
- **Network Policy** : Isolation réseau
- **Pod Disruption Budget** : Disponibilité minimale

### 3. Scripts d'automatisation
- **setup.sh** : Installation complète (metrics-server, déploiement)
- **test-load.sh** : Génération de charge configurable
- **monitor.sh** : Dashboard temps réel du HPA

### 4. Documentation
- **README.md** : Complet avec pré-requis, étapes, concepts
- **QUICKSTART.md** : Démarrage en 15 min
- **TROUBLESHOOTING.md** : 10+ problèmes courants et solutions

---

## 🚀 Étapes de démarrage

### Option 1 : Sur Kubernetes
```bash
cd projects/2026-06-17_kubernetes-autoscaling/

# Builder l'image
cd docker && docker build -t devops-app:1.0 . && cd ..

# Déployer
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/hpa.yaml

# Tester
./scripts/test-load.sh 5 10
```

### Option 2 : docker-compose (plus simple)
```bash
docker-compose up -d
curl http://localhost/cpu-intensive
```

---

## 🎓 Concepts clés

### Deployment
- Gère un ensemble de pods identiques
- Permet les rolling updates
- Redémarrage automatique des pods défaillants

### Resource Requests & Limits
- **Request** : ressource **garantie** (doit être disponible)
- **Limit** : ressource **maximale** (ne peut pas dépasser)
- **Crucial** : HPA a besoin des requests pour calculer le %

### Horizontal Pod Autoscaler (HPA)
Cycle de fonctionnement :
1. Collecte des métriques toutes les 15s
2. Évaluation toutes les 15s
3. **CPU > 70% ?** → Scale-up immédiat (+pods)
4. **CPU < 70% ?** → Scale-down après 5 min (-pods)

### Metrics-Server
- Collecte les métriques CPU/mémoire
- Fournit l'API `/apis/metrics.k8s.io/v1beta1/`
- Essentiel pour que le HPA fonctionne

---

## 🔧 Test pratique

### Scénario 1 : Vérifier le scale-up
```bash
# Terminal 1 : Port-forward
kubectl port-forward svc/devops-app 5000:5000 &

# Terminal 2 : Monitoring
watch -n 2 'kubectl get hpa && echo "---" && kubectl get pods'

# Terminal 3 : Charge
for i in {1..100}; do curl -s http://localhost:5000/cpu-intensive & done; wait
```

**Résultat attendu** :
- Pods initial : 2
- Pods pendant charge : 6-10
- Pods après charge (5 min+) : 2

### Scénario 2 : Utiliser docker-compose
```bash
docker-compose up -d
# Accéder via http://localhost (Nginx load balance)
curl http://localhost/cpu-intensive
```

---

## 📊 Apprentissage couvert

- ✅ Architecture scalable sur Kubernetes
- ✅ Gestion des ressources (CPU, mémoire)
- ✅ Probes de santé (Liveness, Readiness)
- ✅ Autoscaling horizontal
- ✅ Monitoring et métriques
- ✅ Troubleshooting en production
- ✅ Best practices DevOps

---

## 🎯 Extensions possibles

1. **VPA** (Vertical Pod Autoscaler)
   - Ajuste automatiquement les requests/limits
   - Recommandations basées sur l'utilisation réelle

2. **Cluster Autoscaler**
   - Ajoute/supprime des nœuds
   - Complément du HPA

3. **Custom Metrics**
   - Scaler sur des métriques personnalisées
   - Ex: requêtes par seconde, latence, etc.

4. **KEDA** (Kubernetes Event-driven Autoscaling)
   - Autoscaling basé sur événements externes
   - Ex: messages en queue, webhooks, etc.

5. **GitOps**
   - Déployer avec ArgoCD/FluxCD
   - Infrastructure as Code

---

## 📈 Technos utilisées

| Technologie | Rôle |
|-------------|------|
| **Kubernetes** | Orchestration des conteneurs |
| **kubectl** | CLI pour gérer K8s |
| **metrics-server** | Collecte des métriques CPU/mémoire |
| **Docker** | Conteneurisation |
| **Flask** | Framework Python pour l'app |
| **Nginx** | Load balancer (docker-compose) |
| **Python 3.11** | Langage de l'application |

---

## ⏱️ Durée estimée

- **Démarrage rapide** : 15 minutes
- **Complet** : 1-2 heures
- **Avec extensions** : 1 journée

---

## 📚 Ressources utiles

- [Kubernetes Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Metrics Server GitHub](https://github.com/kubernetes-sigs/metrics-server)
- [Resource Requests & Limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Pod Disruption Budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/)

---

## 🎓 Niveau

**Intermédiaire** : Suppose connaissances basiques de Kubernetes (pods, services, deployments)

---

## 📍 Localisation du projet

```
Repository: https://github.com/jaouadsiouahe1978/claude-devops-tools
Branch: main
Commit: 2445b36 (Add Kubernetes Autoscaling Project)
Dossier: projects/2026-06-17_kubernetes-autoscaling/
```

---

## ✅ Checklist d'apprentissage

- [ ] Comprendre Deployment vs Pod
- [ ] Savoir pourquoi Requests/Limits sont cruciaux
- [ ] Connaître le cycle HPA (collect → eval → scale)
- [ ] Observer le scaling en temps réel
- [ ] Interpréter les métriques Prometheus
- [ ] Résoudre les problèmes HPA courants
- [ ] Configurer des seuils personnalisés
- [ ] Implémenter Pod Disruption Budget

---

**Créé le** : 2026-06-17  
**Thème** : Kubernetes - Autoscaling  
**Niveau** : Intermédiaire  
**Prochaine session** : 2026-06-18

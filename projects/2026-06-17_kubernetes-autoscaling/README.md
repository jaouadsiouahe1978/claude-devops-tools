# Kubernetes Autoscaling : Déploiement avec HPA

## 📌 Objectif du projet
Apprendre à déployer une application multi-répliques sur Kubernetes avec **Horizontal Pod Autoscaler (HPA)** pour adapter automatiquement le nombre de pods en fonction de la charge CPU/mémoire.

## 🎯 Compétences acquises
- ✅ Créer et gérer des Deployments Kubernetes
- ✅ Configurer des Requests/Limits pour les ressources
- ✅ Mettre en place un Horizontal Pod Autoscaler (HPA)
- ✅ Tester l'autoscaling avec une charge
- ✅ Monitorer les métriques avec kubectl et metrics-server

## 📚 Technologies utilisées
- **Kubernetes** (minikube ou cluster local)
- **kubectl** - CLI Kubernetes
- **metrics-server** - Collecteur de métriques
- **Python/Flask** - Application simple à déployer
- **Docker** - Conteneurisation

## 📋 Pré-requis
```bash
# Vérifier que vous avez Kubernetes et kubectl
kubectl version --client

# Vérifier que le cluster est accessible
kubectl cluster-info
```

## 🚀 Étapes de réalisation

### Étape 1 : Créer l'application Python
```bash
# L'application est fournie dans app/app.py
# Elle expose un endpoint CPU-intensive pour tester l'autoscaling
```

### Étape 2 : Créer l'image Docker
```bash
cd docker/
docker build -t devops-app:1.0 .
```

### Étape 3 : Créer un Deployment Kubernetes
```bash
kubectl apply -f k8s/deployment.yaml
kubectl get deployments
kubectl get pods
```

### Étape 4 : Vérifier les métriques
```bash
# Installer metrics-server si nécessaire
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Vérifier les ressources utilisées
kubectl top pods
kubectl top nodes
```

### Étape 5 : Appliquer l'Horizontal Pod Autoscaler
```bash
kubectl apply -f k8s/hpa.yaml
kubectl get hpa -w
```

### Étape 6 : Tester l'autoscaling
```bash
# Ouvrir un port-forward vers le pod
kubectl port-forward svc/devops-app 5000:5000

# Dans un autre terminal, générer de la charge
while true; do curl http://localhost:5000/cpu-intensive; done

# Observer l'augmentation des pods
kubectl get pods -w
kubectl get hpa -w
```

### Étape 7 : Arrêter la charge et observer le scale-down
```bash
# Arrêter la boucle curl (Ctrl+C)
# Observer le scale-down (après ~3 minutes)
kubectl get pods -w
```

## 📂 Structure des fichiers
```
.
├── README.md                    # Ce fichier
├── app/
│   └── app.py                  # Application Flask
├── docker/
│   └── Dockerfile              # Image Docker
├── k8s/
│   ├── deployment.yaml         # Déploiement Kubernetes
│   ├── service.yaml            # Service NodePort
│   ├── hpa.yaml                # Horizontal Pod Autoscaler
│   └── resources-quota.yaml    # Resource Quota optionnel
└── scripts/
    ├── test-load.sh            # Script pour générer de la charge
    └── monitor.sh              # Script pour monitorer l'autoscaling
```

## 🔍 Vérification et monitoring

### Voir l'état du Deployment
```bash
kubectl describe deployment devops-app
```

### Voir l'état du HPA
```bash
kubectl describe hpa devops-app-hpa
```

### Logs en temps réel
```bash
kubectl logs -f deployment/devops-app --all-containers=true
```

### Voir les événements du HPA
```bash
kubectl get events --sort-by='.lastTimestamp' | grep HPA
```

## 💡 Concepts clés

### Deployment
- Contrôle le nombre de réplicas
- Garantit la disponibilité de l'application
- Gère les mises à jour progressives (rolling updates)

### Requests et Limits
- **Request** : ressource garantie pour le pod
- **Limit** : ressource maximale pouvant être utilisée
- Nécessaires pour que le HPA fonctionne correctement

### Horizontal Pod Autoscaler (HPA)
- Observe les métriques (CPU, mémoire, custom)
- Crée/supprime automatiquement les pods
- Basé sur des seuils configurables
- Délai de scale-down : ~5 minutes (par défaut)

### Cycle de l'autoscaling
1. Métriques collectées toutes les 15 secondes
2. HPA évalue les métriques toutes les 15 secondes
3. Si dépassement : **scale-up** immédiat
4. Si retour normal : **scale-down** après délai

## 🎓 Ce qu'on apprend
- Architecture d'une application scalable
- Gestion des ressources en Kubernetes
- Monitoring et métriques
- Résilience et haute disponibilité
- Load balancing automatique

## 🔧 Dépannage

### HPA ne scale pas
```bash
# Vérifier que metrics-server est installé
kubectl get deployment metrics-server -n kube-system

# Vérifier les métriques
kubectl get hpa devops-app-hpa --watch
```

### Pods ne démarrent pas
```bash
# Vérifier les logs
kubectl logs <pod-name> -c devops-app

# Vérifier les events
kubectl describe pod <pod-name>
```

### Charge CPU trop basse
```bash
# Augmenter le seuil du HPA ou utiliser une charge plus intense
# Modifier hpa.yaml et réappliquer
kubectl apply -f k8s/hpa.yaml
```

## 📈 Extensions possibles
- [ ] Ajouter un VPA (Vertical Pod Autoscaler)
- [ ] Configurer des alertes Prometheus
- [ ] Implémenter un Cluster Autoscaler
- [ ] Utiliser des métriques custom pour l'autoscaling
- [ ] Tester avec une vraie application (WordPress, etc.)

## 📖 Ressources
- [Kubernetes Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Metrics Server](https://github.com/kubernetes-sigs/metrics-server)
- [Resource Requests and Limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

---
**Créé le** : 2026-06-17  
**Niveau** : Intermédiaire  
**Durée estimée** : 1 journée (2-3h)

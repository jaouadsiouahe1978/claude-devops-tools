# Quick Start - Kubernetes Autoscaling

## 🚀 Démarrage rapide (15 minutes)

### Prérequis
```bash
# Vérifier les outils
kubectl version --client
docker --version
```

### Étape 1 : Builder l'image Docker
```bash
cd docker/
docker build -t devops-app:1.0 .
cd ..
```

### Étape 2 : Déployer sur Kubernetes
```bash
# Créer le Deployment et le Service
kubectl apply -f k8s/deployment.yaml

# Vérifier que ça fonctionne
kubectl get pods
kubectl get svc

# Attendre que les pods soient Ready
kubectl wait --for=condition=ready pod -l app=devops-app --timeout=60s
```

### Étape 3 : Installer metrics-server
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Attendre
kubectl wait --for=condition=available deployment/metrics-server -n kube-system --timeout=300s
```

### Étape 4 : Créer le HPA
```bash
kubectl apply -f k8s/hpa.yaml

# Vérifier
kubectl get hpa
```

### Étape 5 : Ouvrir un port-forward
```bash
kubectl port-forward svc/devops-app 5000:5000 &
```

### Étape 6 : Générer de la charge
```bash
# Terminal 1 : Monitoring
watch -n 2 'kubectl get hpa && echo "---" && kubectl get pods'

# Terminal 2 : Générer la charge
chmod +x scripts/test-load.sh
./scripts/test-load.sh 5 10

# Terminal 3 : Vérifier les ressources
watch -n 2 'kubectl top pods'
```

### Résultat attendu
```
✅ Pods initiaux : 2
✅ Pendant la charge : 6-10 pods (selon le seuil)
✅ Après la charge : retour à 2 pods (après ~5 min)
```

---

## 📊 Monitoring en temps réel

```bash
# Option 1 : Utiliser le script fourni
chmod +x scripts/monitor.sh
./scripts/monitor.sh

# Option 2 : Commandes individuelles
kubectl get hpa -w                    # Watch HPA
kubectl get pods -w                   # Watch pods
kubectl top pods --watch              # Watch resources
kubectl describe hpa devops-app-hpa  # Détails HPA
```

---

## 🔧 Tester sans Docker

Si vous n'avez pas Docker local, utilisez **docker-compose** :

```bash
docker-compose up -d

# Accéder via http://localhost (Nginx load balance les 3 replicas)
curl http://localhost/cpu-intensive
```

---

## 🎯 Tests spécifiques

### Test 1 : Vérifier que le scaling fonctionne
```bash
# Terminal 1
kubectl get pods -w

# Terminal 2
kubectl port-forward svc/devops-app 5000:5000

# Terminal 3 - Charge intense
for i in {1..50}; do curl -s http://localhost:5000/cpu-intensive & done; wait
```

**Résultat** : Les pods doivent augmenter en 30-60 secondes

---

### Test 2 : Vérifier le scale-down
```bash
# Après le test 1, attendre 5-10 minutes
watch -n 5 "kubectl get pods"

# Les pods doivent revenir à 2
```

---

### Test 3 : Tester avec mémoire
```bash
# Modifier le seuil mémoire du HPA
kubectl patch hpa devops-app-hpa -p '{
  "spec": {
    "metrics": [
      {
        "type": "Resource",
        "resource": {
          "name": "memory",
          "target": {"type": "Utilization", "averageUtilization": 50}
        }
      }
    ]
  }
}'

# Charger la mémoire
for i in {1..10}; do curl -s http://localhost:5000/memory-test & done; wait
```

---

## 🐛 Dépannage rapide

| Problème | Solution |
|----------|----------|
| HPA affiche "unknown" | Installer metrics-server |
| Pods ne scale pas | Vérifier requests/limits dans deployment.yaml |
| Service pas accessible | Vérifier port-forward : `kubectl port-forward svc/devops-app 5000:5000` |
| Métriques à 0% | Générer du trafic d'abord : `curl http://localhost:5000/cpu-intensive` |
| Pods ne démarrent pas | Vérifier l'image Docker : `docker images \| grep devops-app` |

Plus de solutions → voir **TROUBLESHOOTING.md**

---

## 📝 Checklist d'apprentissage

- [ ] Comprendre ce qu'est un Deployment
- [ ] Savoir pourquoi requests/limits sont importants
- [ ] Connaître le fonctionnement du HPA
- [ ] Observer le scaling en action
- [ ] Interpréter les métriques Prometheus
- [ ] Résoudre des problèmes d'autoscaling
- [ ] Configurer des seuils personnalisés
- [ ] Implémenter un Pod Disruption Budget

---

## 🎓 Concepts clés (en 3 min)

### Deployment
Gère un ensemble de pods identiques avec rolling updates.

### Requests & Limits
- **Request** : ressource **garantie** (doit être disponible)
- **Limit** : ressource **maximale** (ne peut pas dépasser)
- **Important** : HPA a BESOIN des requests pour calculer le %

### Horizontal Pod Autoscaler (HPA)
Surveille les métriques (CPU, mémoire) et crée/supprime automatiquement des pods :
1. Collecte les métriques toutes les 15s
2. Si CPU > seuil → **scale-up** immédiat
3. Si CPU < seuil → **scale-down** après délai (5 min par défaut)

---

## 📚 Pour aller plus loin

1. **VPA** (Vertical Pod Autoscaler) : ajuste les requests/limits
2. **Cluster Autoscaler** : ajoute/supprime des nœuds
3. **Custom metrics** : scaler sur des métriques personnalisées
4. **GitOps** : déployer via ArgoCD/FluxCD

---

**Créé le** : 2026-06-17  
**Durée estimée** : 30 min - 2h selon l'approfondissement

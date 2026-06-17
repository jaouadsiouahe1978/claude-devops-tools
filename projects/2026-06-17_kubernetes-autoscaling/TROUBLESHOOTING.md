# Guide de Troubleshooting - Kubernetes Autoscaling

## Problèmes courants et solutions

### 1. HPA ne scale pas du tout

**Symptôme** : HPA affiche "unknown" pour les métriques

```bash
kubectl describe hpa devops-app-hpa
# Output: unable to compute replica count based on cpu resource utilization: missing request for cpu
```

**Solutions** :

1. **Vérifier que metrics-server est installé** :
```bash
kubectl get deployment metrics-server -n kube-system
```

Si absent, installer :
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl wait --for=condition=available --timeout=300s deployment/metrics-server -n kube-system
```

2. **Vérifier que les ressources sont définies dans le Deployment** :
```bash
kubectl describe deployment devops-app | grep -A 5 "Requests"
```

Doit afficher :
```
Requests:
  cpu: 100m
  memory: 128Mi
```

3. **Attendre que les métriques soient collectées** :
```bash
# Attendre ~2-3 minutes après le déploiement
kubectl get hpa devops-app-hpa --watch
```

---

### 2. Pods ne démarrent pas

**Symptôme** : Pods en état "Pending" ou "CrashLoopBackOff"

```bash
kubectl get pods
# NAME                         READY   STATUS              RESTARTS   AGE
# devops-app-abc123-def45      0/1     CrashLoopBackOff    5          2m
```

**Solutions** :

1. **Vérifier les logs** :
```bash
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # Logs du dernier redémarrage
```

2. **Vérifier l'image Docker** :
```bash
# S'assurer que l'image existe
docker images | grep devops-app

# Si manquante, reconstruire
cd docker/
docker build -t devops-app:1.0 .
```

3. **Vérifier les ressources insuffisantes** :
```bash
kubectl describe pod <pod-name>
# Chercher : "Insufficient cpu/memory"

# Solution : réduire les requests dans deployment.yaml
```

4. **Vérifier les problèmes de port** :
```bash
# Le port 5000 est-il disponible?
docker ps | grep 5000
```

---

### 3. Métriques toujours à 0%

**Symptôme** :
```bash
kubectl top pods
# NAME                         CPU(cores)   MEMORY(bytes)
# devops-app-abc123-def45      0m           0Mi
```

**Solutions** :

1. **Attendre que l'application reçoive du trafic** :
```bash
# Les métriques ne s'affichent que s'il y a une activité
curl http://localhost:5000/cpu-intensive
kubectl top pods  # Réessayer après
```

2. **Vérifier que metrics-server collecte correctement** :
```bash
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes
kubectl get --raw /apis/metrics.k8s.io/v1beta1/pods
```

3. **Vérifier les logs de metrics-server** :
```bash
kubectl logs -n kube-system -l app=metrics-server
```

---

### 4. Scale-up qui ne se déclenche pas lors de la charge

**Symptôme** : CPU à 80% mais HPA ne crée pas de nouveaux pods

**Solutions** :

1. **Vérifier le seuil du HPA** :
```bash
kubectl describe hpa devops-app-hpa | grep "Target Utilization"
```

Si le seuil est 70% et la charge réelle est 80%, cela devrait déclencher un scale-up.

2. **Réduire temporairement le seuil pour tester** :
```bash
kubectl patch hpa devops-app-hpa -p '{"spec":{"metrics":[{"type":"Resource","resource":{"name":"cpu","target":{"type":"Utilization","averageUtilization":50}}}]}}'
```

3. **Vérifier que le maxReplicas n'est pas déjà atteint** :
```bash
kubectl get hpa devops-app-hpa
# Vérifier : MINPODS vs MAXPODS vs REPLICAS
```

4. **Augmenter la charge** :
```bash
# La charge peut être trop faible
./scripts/test-load.sh 10 20  # 20 requêtes parallèles au lieu de 5
```

---

### 5. Scale-down ne se produit pas

**Symptôme** : Pods ne se suppriment pas quand la charge diminue

**Solutions** :

1. **Vérifier le délai de stabilisation** :
```bash
kubectl get hpa devops-app-hpa -o yaml | grep -A 10 "scaleDown"
# stabilizationWindowSeconds doit être > 0
```

Par défaut, attente de 5 minutes avant scale-down.

2. **Attendre le délai** :
```bash
# Après avoir arrêté la charge, attendre 5 minutes + temps de stabilisation
watch -n 5 "kubectl get hpa && echo '---' && kubectl get pods"
```

3. **Forcer l'évaluation** :
```bash
# Réduire temporairement le seuil du HPA pour forcer l'évaluation
kubectl scale deployment devops-app --replicas=2
```

---

### 6. Service pas accessible depuis l'extérieur

**Symptôme** :
```bash
kubectl port-forward svc/devops-app 5000:5000
# Port forward marche mais curl échoue
```

**Solutions** :

1. **Vérifier le service** :
```bash
kubectl get svc devops-app
kubectl describe svc devops-app
```

2. **Vérifier les endpoints** :
```bash
kubectl get endpoints devops-app
# Doit lister les IPs des pods
```

3. **Tester directement depuis un pod** :
```bash
kubectl run -it debug --image=curlimages/curl --restart=Never -- sh
# Depuis le pod : curl http://devops-app:80/
```

4. **Utiliser NodePort au lieu de ClusterIP** :
```bash
kubectl patch svc devops-app -p '{"spec":{"type":"NodePort"}}'
kubectl get svc devops-app
# Accéder via http://localhost:<NodePort>/
```

---

### 7. Événements de HPA pas clairs

**Symptôme** : Ne pas comprendre pourquoi HPA agit/n'agit pas

**Solutions** :

```bash
# Voir tous les événements du HPA
kubectl describe hpa devops-app-hpa

# Format de réponse :
# Conditions:
#   Type            Status  Reason       Message
#   ----            ------  ------       -------
#   AbleToScale     True    SucceededGetResourceMetric    ...
#   ScalingActive   True    ValidMetricsFound              ...
#   ScalingLimited  False   DesiredWithinRange             ...

# ScalingLimited=True signifie qu'on a atteint minReplicas/maxReplicas

# Logs détaillés du contrôleur HPA
kubectl get events --sort-by='.lastTimestamp' | grep HPA
```

---

### 8. Problème avec imagePullPolicy

**Symptôme** :
```
ErrImagePull: image devops-app:1.0 not found
```

**Solutions** :

1. **Vérifier l'image locale** :
```bash
docker images | grep devops-app
```

2. **Si le cluster utilise un registry** :
```bash
# Construire et pousser l'image
docker tag devops-app:1.0 registry.example.com/devops-app:1.0
docker push registry.example.com/devops-app:1.0

# Modifier le Deployment pour utiliser le registry
kubectl set image deployment/devops-app devops-app=registry.example.com/devops-app:1.0
```

3. **Pour minikube/cluster local** :
```bash
# S'assurer que l'image est disponible localement
eval $(minikube docker-env)  # Pour minikube
docker build -t devops-app:1.0 .
```

---

### 9. Utilisation mémoire trop élevée

**Symptôme** : Pods OOMKilled ou consomment trop de mémoire

```bash
kubectl get pods
# STATUS: OOMKilled
```

**Solutions** :

1. **Augmenter les limites** :
```bash
kubectl set resources deployment devops-app -c=devops-app --limits=memory=1Gi
```

2. **Réduire la taille de la charge de travail** :
```yaml
# Dans deployment.yaml
resources:
  limits:
    memory: 512Mi  # Augmenter cette valeur
```

3. **Identifier les fuites mémoire** :
```bash
kubectl logs deployment/devops-app | grep -i error
```

---

### 10. Nettoyage et redémarrage

**Supprimer complètement et recommencer** :

```bash
# Supprimer le HPA
kubectl delete hpa devops-app-hpa

# Supprimer le Deployment (supprime aussi les pods)
kubectl delete deployment devops-app

# Supprimer le Service
kubectl delete svc devops-app

# Vérifier qu'il n'y a rien
kubectl get all -l app=devops-app

# Redéployer
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/hpa.yaml
```

---

## Commandes de diagnostic utiles

```bash
# État global du cluster
kubectl get nodes
kubectl describe node <node-name>

# État de l'application
kubectl get all -l app=devops-app
kubectl describe deployment devops-app
kubectl describe hpa devops-app-hpa

# Ressources utilisées
kubectl top nodes
kubectl top pods

# Logs
kubectl logs deployment/devops-app --all-containers=true --previous=false
kubectl logs -f deployment/devops-app -c devops-app

# Événements
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -w

# Debugging avancé
kubectl debug pod/<pod-name> -it --image=busybox
kubectl exec -it <pod-name> -- /bin/bash
```

---

## Ressources supplémentaires

- [Kubernetes HPA Troubleshooting](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)
- [Metrics Server Issues](https://github.com/kubernetes-sigs/metrics-server)
- [Resource Requests and Limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

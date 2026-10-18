# Kubernetes Network Policies & Pod Communication Security

## 📋 Description

Learn to implement **Kubernetes Network Policies** to secure pod-to-pod communication. In Kubernetes, by default all pods can communicate with each other (flat network). Network Policies enforce **zero-trust networking** by explicitly allowing only necessary traffic between pods, namespaces, and external services.

This project demonstrates:
- Creating isolated namespaces for different application tiers
- Implementing deny-all default policies
- Allowing specific traffic between frontend → API → database
- Ingress rules for external traffic
- Egress rules for outbound traffic (DNS, external APIs)
- Debugging and testing network policies

## 🎯 Learning Outcomes

- Understand Kubernetes networking model and CNI plugins
- Implement zero-trust network architecture
- Use labels and selectors for fine-grained traffic control
- Secure inter-service communication
- Debug connectivity issues with network policies
- Apply defense-in-depth security principles

## 📦 Prerequisites

- Kubernetes cluster (local: minikube, kind, or docker-desktop with K8s enabled)
- `kubectl` command-line tool
- A CNI plugin supporting network policies (Calico, Flannel, Cilium)
- Basic understanding of Kubernetes pods, services, and deployments

## 🚀 Quick Start

### 1. Install Kubernetes with Network Policy Support

**For Minikube:**
```bash
minikube start --cni=calico
```

**For Kind:**
```bash
kind create cluster --config kind-config.yaml
```

**For Docker Desktop:**
- Enable Kubernetes in preferences, then install Calico:
```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
```

### 2. Create Namespaces and Applications

```bash
# Apply the namespaces
kubectl apply -f 01-namespaces.yaml

# Deploy the applications (frontend, API, database)
kubectl apply -f 02-applications.yaml

# Verify all pods are running
kubectl get pods -A
```

### 3. Test Default Connectivity (All Allow)

```bash
# Get frontend pod name
FE_POD=$(kubectl get pod -n frontend -l app=frontend -o jsonpath='{.items[0].metadata.name}')

# Test connectivity to API (should succeed)
kubectl exec -it -n frontend $FE_POD -- curl http://api-service.api:5000/status

# Test connectivity to database (should succeed - unrestricted)
kubectl exec -it -n frontend $FE_POD -- curl http://db-service.database:3306
```

### 4. Apply Network Policies (Zero-Trust)

```bash
# Apply deny-all default policies
kubectl apply -f 03-default-deny-all.yaml

# Now try the same tests - they will fail
kubectl exec -it -n frontend $FE_POD -- curl --max-time 5 http://api-service.api:5000/status
```

### 5. Allow Specific Traffic

```bash
# Allow frontend → API communication
kubectl apply -f 04-allow-frontend-to-api.yaml

# Allow API → Database communication
kubectl apply -f 05-allow-api-to-database.yaml

# Allow DNS traffic (critical for service discovery)
kubectl apply -f 06-allow-dns.yaml

# Test again - should work for allowed paths
kubectl exec -it -n frontend $FE_POD -- curl http://api-service.api:5000/status
```

### 6. Allow Ingress Traffic

```bash
# Deploy ingress controller (nginx-ingress)
kubectl apply -f 07-ingress-setup.yaml

# Create network policy for ingress
kubectl apply -f 08-allow-ingress.yaml

# Test from outside the cluster
curl http://$(minikube ip)/
```

### 7. Monitor and Debug

```bash
# View all network policies
kubectl get networkpolicies -A

# View policy details
kubectl describe networkpolicy -n api allow-from-frontend

# Check pod labels (used for selection)
kubectl get pods -n frontend --show-labels

# Test connectivity using netcat in a pod
kubectl run -it --rm debug --image=nicolaka/netshoot -n frontend -- bash
# Inside pod: nc -zv api-service.api 5000
```

## 📊 Architecture

```
┌─────────────────────────────────┐
│      Internet / Ingress         │
└──────────────┬──────────────────┘
               ↓ (allow ingress traffic)
        ┌──────────────┐
        │  Frontend    │
        │   (Pod)      │
        └──────┬───────┘
               ↓ (allow frontend→api)
        ┌──────────────┐
        │     API      │
        │   (Pod)      │
        └──────┬───────┘
               ↓ (allow api→db)
        ┌──────────────┐
        │   Database   │
        │   (Pod)      │
        └──────────────┘
```

## 🔧 Key Concepts

### Network Policy Structure
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-frontend
  namespace: api
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 5000
```

### Policy Types
- **Ingress**: Controls incoming traffic to pods
- **Egress**: Controls outgoing traffic from pods
- **Combined**: Both ingress and egress rules

### Selectors
- **podSelector**: Select pods by labels within namespace
- **namespaceSelector**: Select pods from other namespaces
- **ipBlock**: Allow/deny IP CIDR ranges (external traffic)

## 📝 Files Included

1. **kind-config.yaml** - Kind cluster configuration with Calico CNI
2. **01-namespaces.yaml** - Create frontend, api, database namespaces
3. **02-applications.yaml** - Deploy sample apps (nginx, flask, mysql)
4. **03-default-deny-all.yaml** - Deny all ingress traffic by default
5. **04-allow-frontend-to-api.yaml** - Whitelist frontend → API
6. **05-allow-api-to-database.yaml** - Whitelist API → Database
7. **06-allow-dns.yaml** - Allow DNS queries for service discovery
8. **07-ingress-setup.yaml** - Install nginx-ingress controller
9. **08-allow-ingress.yaml** - Allow external traffic to frontend
10. **helpers.sh** - Testing and debugging utilities

## 🧪 Testing Scenarios

### ✅ Should Work (After Policies Applied)
```bash
# Frontend to API
kubectl exec -it -n frontend <pod> -- curl http://api-service.api:5000/status

# API to Database
kubectl exec -it -n api <pod> -- curl http://db-service.database:3306
```

### ❌ Should Fail (Blocked)
```bash
# Frontend directly to Database
kubectl exec -it -n frontend <pod> -- curl http://db-service.database:3306

# Database to API (reverse direction)
kubectl exec -it -n database <pod> -- curl http://api-service.api:5000/status
```

## 🔐 Security Best Practices

1. **Default Deny** - Start with deny-all, then explicitly allow
2. **Least Privilege** - Only allow necessary communication
3. **Namespace Isolation** - Separate concerns by namespace
4. **Port Specificity** - Specify exact ports, not all
5. **Protocol Specification** - Use TCP/UDP explicitly
6. **Regular Audits** - Monitor and review policies
7. **Logging** - Enable policy logs for debugging
8. **Egress Control** - Don't forget outbound rules

## 🐛 Troubleshooting

### Pods Can't Reach Service
```bash
# Check DNS resolution
kubectl exec -it <pod> -- nslookup api-service.api

# Check network policies
kubectl get networkpolicy -n api
kubectl describe networkpolicy allow-from-frontend -n api

# Check pod labels
kubectl get pod <pod> --show-labels
```

### CNI Plugin Not Ready
```bash
# Check CNI status
kubectl get pods -n kube-system | grep calico

# Restart pod if needed
kubectl delete pod -n kube-system <calico-pod>
```

### Service Connectivity
```bash
# Test from debug container
kubectl run -it --rm debug --image=nicolaka/netshoot -- bash
# Test DNS: nslookup service-name.namespace
# Test TCP: nc -zv service-name.namespace port
```

## 📚 Resources

- [Kubernetes Network Policies Documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Calico Network Policy](https://docs.projectcalico.org/security/calico-network-policy)
- [Network Policy Recipes](https://github.com/ahmetb/kubernetes-network-policy-recipes)

## ⏱️ Time Estimate

- Understanding concepts: 15 minutes
- Setting up cluster: 10 minutes
- Deploying applications: 10 minutes
- Implementing policies: 15 minutes
- Testing and debugging: 15 minutes
- **Total: ~65 minutes** (fits in one day!)

## 💡 Next Steps

1. Add egress policies to restrict outbound traffic
2. Implement RBAC alongside network policies
3. Add observability with Cilium/Calico metrics
4. Explore service mesh (Istio) for advanced traffic control
5. Implement multi-tenancy with strict isolation

# Exemples de Requêtes PromQL

## 📊 Métriques Système de Base

### CPU
```promql
# Taux de CPU idle (plus est mieux)
rate(node_cpu_seconds_total{mode="idle"}[1m])

# Taux de CPU utilisé (%)
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)

# CPU par mode (user, system, iowait, etc.)
rate(node_cpu_seconds_total[1m]) by (mode)
```

### Mémoire
```promql
# Mémoire disponible en bytes
node_memory_MemAvailable_bytes

# Pourcentage de mémoire utilisée
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Mémoire en cache
node_memory_Cached_bytes
```

### Disque
```promql
# Pourcentage du disque utilisé
(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100

# Espace libre sur chaque mount point
node_filesystem_avail_bytes{fstype!~"tmpfs|fuse.lxcfs"}
```

### Réseau
```promql
# Trafic réseau entrant (bytes/sec)
rate(node_network_receive_bytes_total[1m])

# Trafic réseau sortant (bytes/sec)
rate(node_network_transmit_bytes_total[1m])
```

## 📈 Opérateurs Utiles

### Agrégations
```promql
# Moyenne sur toutes les instances
avg(node_memory_MemAvailable_bytes)

# Somme
sum(node_memory_MemAvailable_bytes)

# Min/Max
min(node_memory_MemAvailable_bytes)
max(node_memory_MemAvailable_bytes)
```

---

💡 **Conseil**: Tester chaque requête dans l'interface Prometheus (http://localhost:9090)

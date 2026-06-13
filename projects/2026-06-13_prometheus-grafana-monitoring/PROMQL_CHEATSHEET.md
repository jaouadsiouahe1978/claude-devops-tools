# PromQL - Cheatsheet

## 📌 Syntaxe de base

### Sélecteurs de métriques
```promql
# Métrique simple
node_cpu_seconds_total

# Avec label exact
node_cpu_seconds_total{mode="idle"}

# Avec labels multiples (AND)
node_cpu_seconds_total{mode="idle", instance="localhost:9100"}

# Regex matching
node_cpu_seconds_total{mode=~"idle|system"}
node_filesystem_size_bytes{fstype!~"tmpfs|fuse"}
```

### Opérateurs arithmétiques
```promql
# Addition, soustraction, multiplication, division
node_memory_MemTotal_bytes / 1024 / 1024  # En MB

# Modulo
metric_a % metric_b

# Exponentiation
metric ^ 2
```

## 🎯 Fonctions courantes

### Rate & Increase
```promql
# Taux de change (dérivée) - utilise 5min par défaut
rate(requests_total[5m])

# Augmentation totale sur la plage (plus stable que rate)
increase(requests_total[1h])

# Taux par seconde (pour les counters)
rate(node_cpu_seconds_total[1m])
```

### Aggregation
```promql
# Somme par groupe
sum(node_memory_MemTotal_bytes) by (instance)

# Moyenne
avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) by (instance)

# Min/Max
max(node_memory_MemTotal_bytes)
min(rate(requests_total[5m]))

# Nombre de series
count(up)
count(up) by (job)

# Top/Bottom
topk(3, node_memory_MemTotal_bytes)
bottomk(3, requests_total)
```

### Histogrammes (Latency)
```promql
# 95ème percentile de latence (histogram)
histogram_quantile(0.95, rate(request_duration_seconds_bucket[5m]))

# 99ème percentile
histogram_quantile(0.99, rate(request_duration_seconds_bucket[5m]))

# Avec groupement
histogram_quantile(0.95, rate(request_duration_seconds_bucket[5m])) by (handler)
```

## 💡 Patterns courants

### CPU Usage
```promql
# CPU utilisé (inverse du idle)
100 * (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) by (instance))

# Par instance ET core
100 * (1 - rate(node_cpu_seconds_total{mode="idle"}[5m]))
```

### Memory
```promql
# Pourcentage utilisé
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Disponible
(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100

# Buffers/Cache
(node_memory_Buffers_bytes + node_memory_Cached_bytes) / node_memory_MemTotal_bytes * 100
```

### Disk
```promql
# Usage %
(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100

# Espace libre (GB)
node_filesystem_avail_bytes / 1024 / 1024 / 1024

# Inodes utilisés %
(node_filesystem_files_used / node_filesystem_files) * 100
```

### Network
```promql
# Bytes in/out par seconde
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])

# Packets in/out par seconde
rate(node_network_receive_packets_total[5m])
rate(node_network_transmit_packets_total[5m])

# Total network bytes (sum across interfaces)
sum(rate(node_network_receive_bytes_total[5m])) by (instance)
```

### Disk I/O
```promql
# Taux de lectures/écritures
rate(node_disk_reads_completed_total[5m])
rate(node_disk_writes_completed_total[5m])

# Temps moyen d'accès disque (ms)
rate(node_disk_io_time_ms_total[5m]) / rate(node_disk_io_time_weighted_ms_total[5m]) * 1000
```

### Load Average
```promql
# Load par rapport aux cores disponibles
node_load1 / count(node_cpu_seconds_total{mode="idle"})

# Comparaison load vs CPU disponible
node_load1 / count(node_cpu_seconds_total{mode="user"})
```

## 🔄 Opérateurs de série

### Offset
```promql
# Valeur d'il y a 1h
node_memory_MemAvailable_bytes offset 1h

# Comparaison présent vs hier
node_memory_MemAvailable_bytes / (node_memory_MemAvailable_bytes offset 24h)
```

### Modifiers
```promql
# Sans le label instance
sum(requests_total) without (instance)

# Groupé par job seulement
sum(requests_total) by (job)
```

## 🧮 Expressions binaires

```promql
# Join sur les labels
node_memory_MemTotal_bytes / node_memory_MemAvailable_bytes

# On clause (join explicite)
requests_total on (job, instance) + service_info

# Ignoring
requests_total ignoring (job) + other_metric
```

## 📊 Filtres temporels

```promql
# Dernière valeur
node_memory_MemAvailable_bytes

# Moyenne sur 5 min
avg(node_memory_MemAvailable_bytes)

# Range 1h (pour rate, increase)
rate(requests_total[1h])

# Offset 24h
node_memory_MemAvailable_bytes offset 24h

# Boolean (true/false)
node_memory_MemAvailable_bytes > 1024*1024*1024  # > 1GB
```

## 🚨 Conditions et alertes

```promql
# Comparaisons
metric > 100
metric < 50
metric == 42
metric != 0
metric >= 80
metric <= 20

# Boolean AND/OR
(cpu_usage > 80) and (memory_usage > 85)
(cpu_usage > 80) or (disk_usage > 90)

# Isinf / Isnan
isinf(metric)  # Infinity ?
isnan(metric)  # NaN ?

# On missing (fill)
absent(metric)  # Alerte si métrique absente
```

## 🔍 Debugging

```promql
# Voir tous les labels d'une métrique
{job="prometheus"}

# Count de séries
count(up) by (job)

# Checksum (débug)
topk(10, changes(metric[1h])) by (instance)

# Absent (métrique manquante)
absent(metric) == 1
```

## 💯 Examples réels

### Taux d'erreur applicatif
```promql
# Erreurs par minute
rate(errors_total[1m])

# Pourcentage d'erreurs
rate(errors_total[5m]) / rate(requests_total[5m]) * 100

# Seulement les 5xx
rate(requests_total{status=~"5.."}[5m]) / rate(requests_total[5m])
```

### SLO monitoring
```promql
# P95 latence < 500ms
histogram_quantile(0.95, rate(request_duration_seconds_bucket[5m])) < 0.5

# Availability 99%
requests_success_total / requests_total >= 0.99

# 30-day error budget
avg_over_time(requests_success_total[30d]) >= 0.99
```

### Prédiction/Trending
```promql
# Projection linéaire
predict_linear(node_disk_free[1h], 4*3600)  # Prédiction 4h plus tard

# Derivative (dérivée)
deriv(metric[5m])
```

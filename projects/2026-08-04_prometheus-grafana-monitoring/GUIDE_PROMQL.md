# Guide PromQL - Requêtes Prometheus

## Concepts clés
- **Instant Vector** : Valeur à un moment précis (ex: `up`)
- **Range Vector** : Valeurs sur une période (ex: `up[5m]`)
- **Scalar** : Nombre simple (ex: `123`)

## Requêtes essentielles

### 1. Santé des services
```promql
# Tous les services qui fonctionnent (up=1)
up == 1

# Tous les services DOWN
up == 0

# Taux de chute des services (%)
100 * (1 - (sum(up) / count(up)))
```

### 2. CPU
```promql
# CPU utilisé (%)
100 * (1 - avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])))

# CPU par core
rate(node_cpu_seconds_total{mode="system"}[5m]) * 100

# Load average (1, 5, 15 min)
node_load1
node_load5
node_load15
```

### 3. Mémoire
```promql
# Mémoire disponible (en bytes)
node_memory_MemAvailable_bytes

# Mémoire utilisée (%)
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Swap utilisé
node_memory_SwapFree_bytes / node_memory_SwapTotal_bytes * 100
```

### 4. Disque
```promql
# Espace libre par filesystem
node_filesystem_avail_bytes{fstype!~"tmpfs|fuse.lxcfs"}

# Utilisation disque (%)
100 * (1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes))

# I/O read/write
rate(node_disk_read_bytes_total[5m])
rate(node_disk_written_bytes_total[5m])
```

### 5. Réseau
```promql
# Bande passante entrante/sortante
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])

# Paquets perdus
rate(node_network_receive_drop_total[5m])
rate(node_network_transmit_drop_total[5m])
```

### 6. Docker (cAdvisor)
```promql
# CPU par conteneur
rate(container_cpu_usage_seconds_total[5m]) * 100

# Mémoire par conteneur
container_memory_usage_bytes

# Nombre de conteneurs
count(container_last_seen)
```

## Opérateurs

| Opérateur | Description | Exemple |
|-----------|-------------|---------|
| `+` | Addition | `node_memory_MemTotal_bytes + node_memory_SwapTotal_bytes` |
| `-` | Soustraction | `node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes` |
| `*` | Multiplication | `value * 100` |
| `/` | Division | `used / total` |
| `%` | Modulo | `value % 10` |
| `^` | Puissance | `value ^ 2` |
| `==` | Égal | `up == 1` |
| `!=` | Pas égal | `up != 1` |
| `>` | Supérieur | `value > 100` |
| `<` | Inférieur | `value < 50` |
| `>=` | Supérieur ou égal | `value >= 80` |
| `<=` | Inférieur ou égal | `value <= 20` |

## Fonctions d'agrégation

```promql
# Moyenne
avg(metric)
avg by(instance) (metric)

# Somme
sum(metric)
sum by(job) (metric)

# Min/Max
min(metric)
max(metric)

# Nombre de séries
count(metric)

# Percentile
histogram_quantile(0.95, metric)

# Taux d'augmentation
increase(metric[5m])     # Augmentation totale sur 5m
rate(metric[5m])         # Augmentation par seconde sur 5m

# Prédiction simple
predict_linear(metric[1h], 3600)  # Valeur prédite dans 1h
```

## Opérateurs binaires (entre 2 métriques)

```promql
# Avec matching automatique sur les labels
metrique1 / metrique2

# Avec matching sur des labels spécifiques
metrique1 / on(instance) group_left metrique2

# Matching sur tous les labels sauf certains
metrique1 / ignoring(le) metrique2
```

## Filtres (Matchers)

```promql
# Exact match
node_cpu_seconds_total{mode="idle"}

# Regex match
node_cpu_seconds_total{mode=~"idle|system"}

# Negative regex
node_cpu_seconds_total{mode!~"idle|system"}

# Non-existence
node_cpu_seconds_total{mode!=""}

# Plusieurs conditions
up{job="prometheus", instance="localhost:9090"}
```

## Astuces pratiques

### Convertir en unités lisibles
```promql
# Bytes en GB
bytes / 1024 / 1024 / 1024

# Millisecondes en secondes
ms / 1000

# Pourcentage
ratio * 100
```

### Requêtes utiles pour un dashboard

```promql
# Uptime en jours
time() / 86400

# Température du serveur
node_hwmon_temp_celsius

# Utilisateurs connectés
count(node_processes_state{state="R"})

# Fichiers ouverts
node_processes_max_fds

# Tâches de cron
count(node_time_zone_offset_seconds)
```

## Debugging

```promql
# Voir TOUS les labels d'une métrique
up

# Voir toutes les instances d'une métrique
node_memory_MemTotal_bytes

# Compter les séries (peut être lourd !)
count(up) by(job)

# Voir les 10 plus grandes valeurs
topk(10, node_memory_MemTotal_bytes)

# Voir les 10 plus petites valeurs
bottomk(10, node_memory_MemTotal_bytes)
```

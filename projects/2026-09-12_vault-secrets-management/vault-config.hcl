# Vault Configuration File
# Production-ready configuration template

# Listener configuration
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = 1  # ATTENTION: TLS désactivé pour dev uniquement!
}

# Storage backend
storage "file" {
  path = "/vault/data"
}

# High availability backend (pour HA en prod)
# storage "consul" {
#   address = "127.0.0.1:8500"
#   path    = "vault"
# }

# UI configuration
ui = true

# Default values
default_lease_duration = "168h"
max_lease_duration     = "720h"

# Disable mlock (necessary in container)
disable_mlock = true

# Audit logging
audit {
  file {
    path = "/vault/logs/audit.log"
  }
}

# Logging
log_level = "info"

# API rate limiting
# api_addr = "http://127.0.0.1:8200"
# cluster_addr = "http://127.0.0.1:8201"

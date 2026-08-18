{
  "infrastructure": {
    "metadata": {
      "created_at": "${created_at}",
      "environment": "${environment}"
    },
    "services": {
      "webserver": {
        "name": "${webserver_name}",
        "port": ${webserver_port},
        "url": "http://${webserver_name}:${webserver_port}",
        "status": "configured"
      },
      "database": {
        "host": "${db_host}",
        "port": ${db_port},
        "name": "${db_name}",
        "connection_string": "postgresql://user@${db_host}:${db_port}/${db_name}",
        "status": "configured"
      },
      "cache": {
        "host": "${cache_host}",
        "port": ${cache_port},
        "connection_string": "redis://${cache_host}:${cache_port}",
        "status": "configured"
      }
    },
    "endpoints": {
      "web": "http://${webserver_name}:${webserver_port}",
      "database": "${db_host}:${db_port}",
      "cache": "${cache_host}:${cache_port}"
    }
  }
}

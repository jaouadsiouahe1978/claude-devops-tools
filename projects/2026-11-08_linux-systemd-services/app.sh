#!/bin/bash

# Simple web service application
# Logs HTTP requests and provides basic health information

PORT=8888
PIDFILE="/var/run/simple-service.pid"
LOGDIR="/var/log/simple-service"

mkdir -p "$LOGDIR"

# Write PID
echo $$ > "$PIDFILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGDIR/app.log"
}

log "Service started on port $PORT (PID: $$)"

# Simple HTTP server using bash and /dev/tcp
while true; do
    # Accept connection
    (
        read -t 5 method path protocol

        if [[ $method == "GET" ]]; then
            response_body=""
            response_code="200 OK"

            case "$path" in
                /health)
                    response_body="OK: Service is healthy\n"
                    log "Health check: OK"
                    ;;
                /metrics)
                    uptime=$(uptime -p)
                    memory=$(free -m | awk '/^Mem:/ {print $3"/"$2" MB"}')
                    response_body="Uptime: $uptime\nMemory: $memory\n"
                    log "Metrics requested"
                    ;;
                /ping)
                    response_body="pong\n"
                    log "Ping received"
                    ;;
                *)
                    response_body="Welcome to Simple Service\n"
                    response_code="200 OK"
                    log "Request: $method $path"
                    ;;
            esac

            # Send HTTP response
            echo -ne "HTTP/1.1 $response_code\r\n"
            echo -ne "Content-Type: text/plain\r\n"
            echo -ne "Content-Length: $(echo -ne "$response_body" | wc -c)\r\n"
            echo -ne "Connection: close\r\n"
            echo -ne "\r\n"
            echo -ne "$response_body"
        fi
    ) 2>/dev/null | nc -l -p $PORT -q 1 &

    sleep 0.1
done &

# Signal handling
trap 'log "Service stopped"; rm -f "$PIDFILE"; exit 0' SIGTERM SIGINT

wait

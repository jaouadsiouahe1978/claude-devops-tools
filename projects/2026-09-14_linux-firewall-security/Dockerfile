################################################################################
# Linux Security Lab - Dockerfile
# Base image with UFW and fail2ban pre-installed for security lab
################################################################################

FROM ubuntu:22.04

LABEL maintainer="DevOps Student"
LABEL description="Linux Firewall Security Lab with UFW and fail2ban"
LABEL version="1.0"

# Set environment
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# Update system and install base packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    # Basic utilities
    curl \
    wget \
    git \
    htop \
    net-tools \
    netcat-openbsd \
    dnsutils \
    traceroute \
    tcpdump \
    # SSH server
    openssh-server \
    openssh-client \
    # Firewall
    ufw \
    iptables \
    iptables-persistent \
    # Intrusion protection
    fail2ban \
    # Text processing
    sed \
    grep \
    awk \
    # Monitoring
    ps-collection \
    sysstat \
    # Utilities
    sudo \
    bash-completion \
    vim \
    nano \
    less \
    tree \
    jq \
    # Development
    build-essential \
    # Cleanup
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create SSH directory
RUN mkdir -p /run/sshd

# Configure SSH for passwordless root login (for lab purposes)
RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

# Enable UFW to work in container (normally disabled)
RUN echo "net.ipv4.conf.all.forwarding=1" >> /etc/sysctl.conf && \
    echo "net.ipv4.conf.default.forwarding=1" >> /etc/sysctl.conf

# Create directory for scripts
RUN mkdir -p /usr/local/bin/security-lab

# Copy security scripts (will be mounted at runtime)
# We'll use docker-compose volumes instead for easier editing

# Create firewall configuration templates
RUN mkdir -p /etc/firewall-templates

# Create script to start services
RUN cat > /usr/local/bin/start-services.sh << 'EOF'
#!/bin/bash
set -e

echo "[*] Starting Linux Security Lab environment..."

# Start SSH daemon
echo "[*] Starting SSH server..."
service ssh start 2>/dev/null || sshd -D &
SSH_PID=$!

# Start systemd-logind (required for many services)
if command -v systemd-logind &>/dev/null; then
    echo "[*] Starting systemd-logind..."
    systemd-logind &
fi

# Start rsyslog for logging
echo "[*] Starting system logging..."
service rsyslog start 2>/dev/null || rsyslogd &

# Wait for services
sleep 2

echo "[✓] Security Lab environment is ready!"
echo ""
echo "Available commands:"
echo "  /usr/local/bin/ufw-setup.sh        - Setup UFW firewall"
echo "  /usr/local/bin/fail2ban-setup.sh   - Setup fail2ban"
echo "  /usr/local/bin/test-security.sh    - Test security configuration"
echo "  /usr/local/bin/monitor-firewall.sh - Monitor firewall activity"
echo ""
echo "Usage: bash <command>"
echo ""

# Keep container running
tail -f /dev/null
EOF

RUN chmod +x /usr/local/bin/start-services.sh

# Create health check script
RUN cat > /usr/local/bin/health-check.sh << 'EOF'
#!/bin/bash
# Health check for container

# Check if SSH is running
if ! pgrep -x sshd > /dev/null; then
    echo "SSH is not running"
    exit 1
fi

# Check if system is responding
if ! curl -f http://localhost/health 2>/dev/null && ! nc -z localhost 22 2>/dev/null; then
    exit 1
fi

exit 0
EOF

RUN chmod +x /usr/local/bin/health-check.sh

# Expose ports
EXPOSE 22/tcp 80/tcp 443/tcp

# Set working directory
WORKDIR /root

# Default command - start services
CMD ["/usr/local/bin/start-services.sh"]

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD /usr/local/bin/health-check.sh || exit 1

################################################################################
# Usage:
#
# Build the image:
#   docker build -t firewall-security-lab .
#
# Run with docker-compose:
#   docker-compose up -d
#
# Or run directly:
#   docker run -it --rm \
#     --cap-add=NET_ADMIN \
#     --cap-add=SYS_ADMIN \
#     -p 2222:22 \
#     -p 8080:80 \
#     -p 8443:443 \
#     firewall-security-lab
#
# Enter the container:
#   docker exec -it firewall-security-lab bash
#
################################################################################

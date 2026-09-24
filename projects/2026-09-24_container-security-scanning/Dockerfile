# Dockerfile with intentional vulnerabilities for security scanning testing
# This image demonstrates common security issues found by Trivy

FROM ubuntu:20.04

LABEL maintainer="DevOps Training" \
      description="Demo image with security vulnerabilities for Trivy scanning"

# Install vulnerable packages (intentional for demonstration)
RUN apt-get update && apt-get install -y \
    curl=7.68.0-1ubuntu1 \
    wget=1.20.3-1ubuntu1 \
    openssh-server=1:8.2p1-4ubuntu0.1 \
    postgresql-client=12+214ubuntu1 \
    mysql-client=8.0.23-0ubuntu0.20.04.1 \
    && rm -rf /var/lib/apt/lists/*

# Run as root (security anti-pattern)
USER root

# Create application directory
WORKDIR /app

# Copy application files
COPY . .

# Expose ports (multiple services - not recommended)
EXPOSE 22 5432 3306 8080

# No health check defined (missing health monitoring)
# No non-root user (runs as root)
# No layer optimization

# Start with shell form (not PID 1)
CMD echo "App running" && sleep infinity

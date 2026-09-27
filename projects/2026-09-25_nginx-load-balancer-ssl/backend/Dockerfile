FROM python:3.12-alpine

WORKDIR /app

# Installer les dépendances
COPY requirements.txt .
RUN apk add --no-cache curl && \
    pip install --no-cache-dir -r requirements.txt

# Copier l'application
COPY app.py .

# Exposer le port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=2 \
  CMD curl -f http://localhost:5000/health || exit 1

# Lancer l'application
CMD ["python", "app.py"]

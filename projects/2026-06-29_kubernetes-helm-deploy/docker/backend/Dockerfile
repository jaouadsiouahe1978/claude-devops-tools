# Backend API - Python Flask
FROM python:3.11-alpine

WORKDIR /app

# Installer dépendances système
RUN apk add --no-cache gcc musl-dev postgresql-client curl

# Copier requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier code application
COPY app.py .

# Créer utilisateur non-root
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser && \
    chown -R appuser:appuser /app

USER appuser

# Environment
ENV FLASK_APP=app.py
ENV PYTHONUNBUFFERED=1

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:5000/health/live || exit 1

EXPOSE 5000

CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]

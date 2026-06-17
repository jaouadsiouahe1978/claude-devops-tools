# Multi-stage build pour réduire la taille de l'image
FROM python:3.11-slim as builder

WORKDIR /app

# Copier les requirements
COPY requirements.txt .

# Installer les dépendances en mode slim
RUN pip install --user --no-cache-dir -r requirements.txt


# Stage final
FROM python:3.11-slim

WORKDIR /app

# Copier les dépendances depuis le builder
COPY --from=builder /root/.local /root/.local

# Copier l'application
COPY ../app/app.py .

# Ajouter .local/bin au PATH
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1
ENV ENVIRONMENT=production

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/').read()"

EXPOSE 5000

# Non-root user for security
RUN useradd -m -u 1000 appuser
USER appuser

CMD ["python", "app.py"]

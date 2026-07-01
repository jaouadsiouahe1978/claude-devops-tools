# Stage 1: Builder - installe les dépendances
FROM python:3.9-slim as builder

WORKDIR /build

# Copier requirements et installer les dépendances
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime - image finale légère
FROM python:3.9-slim

# Installer psycopg2 runtime deps (libpq)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copier les dépendances pré-compilées du builder
COPY --from=builder /root/.local /root/.local

# Copier le code de l'app
COPY app/ .

# Mettre à jour PATH pour utiliser les binaires user
ENV PATH=/root/.local/bin:$PATH \
    PYTHONUNBUFFERED=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

EXPOSE 5000

CMD ["python", "app.py"]

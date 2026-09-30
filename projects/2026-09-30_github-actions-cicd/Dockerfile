FROM python:3.11-slim

LABEL org.opencontainers.image.title="GitHub Actions CICD"
LABEL org.opencontainers.image.description="Demo application for GitHub Actions CI/CD pipeline"
LABEL org.opencontainers.image.authors="Jaouad"

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml poetry.lock* /app/

RUN pip install --no-cache-dir poetry && \
    poetry config virtualenvs.create false && \
    poetry install --only main

COPY app/ /app/app/
COPY tests/ /app/tests/

RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["python", "-m", "app.main"]

FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir \
    flask==2.3.0 \
    prometheus-client==0.17.1 \
    gunicorn==21.2.0

COPY exporters/app.py /app/

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')"

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--timeout", "30", "app:app"]

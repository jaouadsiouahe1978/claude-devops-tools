FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY custom-exporter.py .
RUN chmod +x custom-exporter.py

ENV EXPORTER_PORT=8888
EXPOSE 8888

CMD ["python", "custom-exporter.py"]

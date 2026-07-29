FROM python:3.11-slim

WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY src/ .
COPY tests/ tests/

# Run tests when container starts
CMD ["pytest", "tests/", "-v"]

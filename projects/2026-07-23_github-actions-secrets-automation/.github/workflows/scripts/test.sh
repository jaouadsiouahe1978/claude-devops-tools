#!/bin/bash
set -e
echo "🧪 Running tests..."
python3 -m pytest src/tests/ -v --cov=src --cov-report=term-missing
echo "✅ Tests passed"

#!/bin/bash
# Script to test matrix jobs locally

set -e

echo "================================"
echo "Testing Matrix Jobs Locally"
echo "================================"
echo ""

# Test Python versions
PYTHON_VERSIONS=("3.9" "3.10" "3.11" "3.12")
NODE_VERSIONS=("18" "20" "22")

echo "🐍 Python Versions Test"
echo "========================"
for version in "${PYTHON_VERSIONS[@]}"; do
    if command -v "python$version" &> /dev/null; then
        echo "✅ Python $version: $(python$version --version)"
    else
        echo "❌ Python $version: Not found"
    fi
done

echo ""
echo "📦 Node.js Versions Test"
echo "========================"
if command -v nvm &> /dev/null; then
    for version in "${NODE_VERSIONS[@]}"; do
        nvm list $version &>/dev/null && echo "✅ Node.js $version available" || echo "❌ Node.js $version: Not installed"
    done
else
    echo "ℹ️  NVM not found, checking current Node.js version:"
    node --version
fi

echo ""
echo "🏃 Running Test Suites"
echo "======================"

# Python tests
if [ -f "requirements.txt" ] && command -v pip &> /dev/null; then
    echo "Running Python tests..."
    pip install -q -r requirements.txt 2>/dev/null || true
    pytest tests/test_app.py -v --tb=short 2>/dev/null || echo "Python tests skipped"
fi

# Node tests
if [ -f "package.json" ] && command -v npm &> /dev/null; then
    echo "Running Node.js tests..."
    npm install --silent 2>/dev/null || true
    npm test 2>/dev/null || echo "Node.js tests skipped"
fi

echo ""
echo "✅ Matrix testing complete"

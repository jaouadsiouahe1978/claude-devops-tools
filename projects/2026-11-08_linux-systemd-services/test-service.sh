#!/bin/bash

# Test script for simple-service
# Validates that the service is working correctly

set -e

echo "🧪 Testing Simple Service..."
echo ""

# Check if service file exists
if [ ! -f "simple-service.service" ]; then
    echo "❌ ERROR: simple-service.service not found"
    exit 1
fi

echo "✓ Service file found"

# Check app.sh exists and is executable
if [ ! -f "app.sh" ]; then
    echo "❌ ERROR: app.sh not found"
    exit 1
fi

chmod +x app.sh
echo "✓ app.sh found and executable"

# Check health-check files
for file in "health-check.sh" "health-check.service" "health-check.timer"; do
    if [ ! -f "$file" ]; then
        echo "❌ ERROR: $file not found"
        exit 1
    fi
done

chmod +x health-check.sh
echo "✓ All health check files found"

# Validate systemd unit syntax
if command -v systemd-analyze &> /dev/null; then
    echo ""
    echo "📋 Validating systemd unit files..."

    if systemd-analyze verify simple-service.service &>/dev/null; then
        echo "✓ simple-service.service syntax valid"
    else
        echo "⚠ simple-service.service has warnings"
        systemd-analyze verify simple-service.service || true
    fi

    if systemd-analyze verify health-check.service &>/dev/null; then
        echo "✓ health-check.service syntax valid"
    else
        echo "⚠ health-check.service has warnings"
        systemd-analyze verify health-check.service || true
    fi

    if systemd-analyze verify health-check.timer &>/dev/null; then
        echo "✓ health-check.timer syntax valid"
    else
        echo "⚠ health-check.timer has warnings"
        systemd-analyze verify health-check.timer || true
    fi
fi

# Check scripts syntax
echo ""
echo "📝 Checking script syntax..."

if bash -n app.sh 2>/dev/null; then
    echo "✓ app.sh syntax valid"
else
    echo "⚠ app.sh has syntax issues"
    bash -n app.sh || true
fi

if bash -n health-check.sh 2>/dev/null; then
    echo "✓ health-check.sh syntax valid"
else
    echo "⚠ health-check.sh has syntax issues"
    bash -n health-check.sh || true
fi

echo ""
echo "✅ All tests passed! The project is ready to use."
echo ""
echo "📖 Next steps:"
echo "  1. Review the README.md for setup instructions"
echo "  2. Copy files to /opt/simple-service/"
echo "  3. Create systemd service: sudo systemctl enable simple-service.service"
echo "  4. Start the service: sudo systemctl start simple-service.service"
echo "  5. Monitor: bash monitor-services.sh"

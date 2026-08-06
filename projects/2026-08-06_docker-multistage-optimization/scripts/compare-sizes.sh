#!/bin/bash

set -e

echo "📊 Docker Image Size Comparison"
echo "════════════════════════════════════════════"
echo ""

# Vérifier que les images existent
if ! docker images | grep -q "app.*bad"; then
    echo "❌ Image app:bad not found. Run './scripts/build.sh' first."
    exit 1
fi

if ! docker images | grep -q "app.*optimized"; then
    echo "❌ Image app:optimized not found. Run './scripts/build.sh' first."
    exit 1
fi

echo "Gathering image information..."
echo ""

# Get image sizes
BAD_SIZE=$(docker images app:bad --format "{{.Size}}")
OPTIMIZED_SIZE=$(docker images app:optimized --format "{{.Size}}")
NGINX_SIZE=$(docker images nginx:optimized --format "{{.Size}}")
NODE_SIZE=$(docker images node:18-alpine --format "{{.Size}}")

echo "═══════════════════════════════════════════"
echo "IMAGE SIZE ANALYSIS"
echo "═══════════════════════════════════════════"
echo ""
echo "🐳 Base Images:"
echo "  node:18 (full)     : ~900MB (not shown here)"
echo "  node:18-alpine     : ${NODE_SIZE}"
echo ""
echo "📦 Application Images:"
echo "  app:bad (❌ bad)   : ${BAD_SIZE}"
echo "  app:optimized (✅) : ${OPTIMIZED_SIZE}"
echo "  nginx:optimized    : ${NGINX_SIZE}"
echo ""

# Calculate reduction (bash arithmetic on raw sizes)
BAD_BYTES=$(docker images app:bad --format "{{.Size}}" | sed 's/[KMGT]B//' | numfmt --from=iec 2>/dev/null || echo "0")
OPT_BYTES=$(docker images app:optimized --format "{{.Size}}" | sed 's/[KMGT]B//' | numfmt --from=iec 2>/dev/null || echo "0")

if [ "$BAD_BYTES" -gt 0 ] && [ "$OPT_BYTES" -gt 0 ]; then
    REDUCTION=$(( 100 - (OPT_BYTES * 100 / BAD_BYTES) ))
    echo "═══════════════════════════════════════════"
    echo "🎯 OPTIMIZATION RESULTS"
    echo "═══════════════════════════════════════════"
    echo "  Reduction: ${REDUCTION}%"
    echo ""
fi

# Analyze layers
echo "═══════════════════════════════════════════"
echo "🔍 LAYER ANALYSIS"
echo "═══════════════════════════════════════════"
echo ""
echo "app:bad (layers):"
docker history app:bad --human --no-trunc | head -10
echo ""
echo "app:optimized (layers):"
docker history app:optimized --human --no-trunc | head -15
echo ""

# Detailed inspection
echo "═══════════════════════════════════════════"
echo "📋 DETAILED INSPECTION"
echo "═══════════════════════════════════════════"
echo ""
echo "app:optimized config:"
docker inspect app:optimized | jq '.[] | {
  Arch: .Architecture,
  OS: .Os,
  Layers: (.RootFS.Layers | length),
  User: .Config.User,
  Env: .Config.Env,
  Healthcheck: .Config.Healthcheck,
  Labels: .Config.Labels
}' 2>/dev/null || echo "  (inspect with: docker inspect app:optimized)"
echo ""

echo "✅ Comparison complete!"
echo ""
echo "💡 Tips:"
echo "  • Inspect layer contents:  docker history -q app:bad | xargs docker inspect"
echo "  • Export image as tarball: docker save app:optimized | gzip > app.tar.gz"
echo "  • Check image config:      docker inspect app:optimized | jq '.[] | keys'"

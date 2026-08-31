# Multi-stage build for optimized Docker image

# ============================================================================
# Stage 1: Dependencies
# ============================================================================
FROM node:18-alpine AS dependencies

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# ============================================================================
# Stage 2: Build
# ============================================================================
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev)
RUN npm ci && \
    npm cache clean --force

# Copy source code
COPY . .

# Run tests (optional, can be skipped)
# RUN npm run test

# ============================================================================
# Stage 3: Production Image
# ============================================================================
FROM node:18-alpine AS production

WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 nodejs && \
    adduser -S nodejs -u 1001

# Copy production dependencies from dependencies stage
COPY --from=dependencies --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copy source code
COPY --chown=nodejs:nodejs . .

# Set environment variables
ENV NODE_ENV=production \
    NODE_OPTIONS="--max-old-space-size=256"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Start application
CMD ["node", "src/index.js"]

# Labels for metadata
LABEL maintainer="Jaouad <jaouad@example.com>" \
      description="Multi-environment deployable application" \
      version="1.0.0" \
      app="devops-app"

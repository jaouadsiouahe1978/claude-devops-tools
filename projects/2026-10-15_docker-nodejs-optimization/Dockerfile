# === STAGE 1: BUILD ===
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies (all deps needed for build)
RUN npm ci --only=production && \
    npm cache clean --force

# Verify the build
RUN npm list --depth=0

# === STAGE 2: RUNTIME ===
FROM node:18-alpine

WORKDIR /app

# Add non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy only production dependencies from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy application files
COPY app.js .
COPY package.json .

# Switch to non-root user
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Expose port
EXPOSE 3000

# Start application
CMD ["node", "app.js"]

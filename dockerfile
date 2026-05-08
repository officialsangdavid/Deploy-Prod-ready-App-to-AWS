# Stage 1: Build/dependency install
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files first (layer caching — deps only rebuild if package.json changes)
COPY app/package*.json ./

RUN npm ci --only=production

# --- Stage 2: Production image ---
FROM node:20-alpine AS production

# Security: run as non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copy installed deps from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy app source
COPY app/src ./src

# Set ownership
RUN chown -R nodejs:nodejs /app

USER nodejs

EXPOSE 3000

ENV NODE_ENV=production

# Healthcheck so ECS knows when the container is ready
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "src/index.js"]
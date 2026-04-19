# TurboQuant Integration Dockerfile
# Optimized for Google TurboQuant compression with GPU support

# Build stage
FROM node:18-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    git

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY src/ ./src/

# Build the application
RUN npm run build

# Production stage
FROM node:18-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache \
    dumb-init \
    curl

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S turboquant -u 1001

WORKDIR /app

# Copy built application
COPY --from=builder --chown=turboquant:nodejs /app/dist ./dist
COPY --from=builder --chown=turboquant:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=turboquant:nodejs /app/package*.json ./

# Create logs directory
RUN mkdir -p /app/logs && chown turboquant:nodejs /app/logs

# Switch to non-root user
USER turboquant

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/api/turboquant/health || exit 1

# Expose port
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV TURBOQUANT_BIT_WIDTH=3
ENV TURBOQUANT_ENABLE_GPU=false
ENV TURBOQUANT_BATCH_SIZE=32
ENV TURBOQUANT_MAX_MEMORY_USAGE=1024

# Start the application
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]

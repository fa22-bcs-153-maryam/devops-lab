# Multi-stage Dockerfile for Node + TypeScript + Prisma (Optimized)

### Builder stage: install deps, generate prisma client, build TypeScript
FROM node:20-bullseye-slim AS builder
WORKDIR /app

# Install build tools required for native modules / Prisma generation
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential python3 ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy package manifests and install all dependencies (including dev)
COPY package*.json ./
RUN npm install

# Copy source and prisma schema, generate prisma client and build
COPY tsconfig.json ./
COPY prisma ./prisma
COPY src ./src
RUN npx prisma generate && npm run build


### Runner stage: small production image with only prod deps and built app
FROM node:20-bullseye-slim AS runner
WORKDIR /app
ENV NODE_ENV=production

# Install runtime dependencies (mysql2 native bindings may need them)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy Prisma schema first (needed for postinstall prisma generate)
COPY prisma ./prisma

# Copy package manifests and install only production dependencies
COPY package*.json ./
RUN npm install --omit=dev

# Copy compiled app and Prisma client artifacts from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:4000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})" || exit 1

EXPOSE 4000

CMD ["sh", "-c", "npx prisma migrate deploy 2>/dev/null || npx prisma db push && node ./dist/index.js"]

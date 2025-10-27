# Multi-stage Dockerfile for Node + TypeScript + Prisma

### Builder stage: install deps, generate prisma client, build TypeScript
FROM node:20-bullseye-slim AS builder
WORKDIR /app

# Install build tools required for native modules / Prisma generation
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential python3 ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy package manifests and install all dependencies (including dev)
COPY package.json package-lock.json* ./
RUN npm ci

# Copy source and prisma schema, generate prisma client and build
COPY tsconfig.json prisma ./
COPY src ./src
RUN npx prisma generate
RUN npm run build


### Runner stage: small production image with only prod deps and built app
FROM node:20-bullseye-slim AS runner
WORKDIR /app
ENV NODE_ENV=production

# Copy Prisma schema first (needed for postinstall prisma generate)
COPY prisma ./prisma

# Copy package manifests and install only production dependencies
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev

# Copy compiled app and Prisma client artifacts from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

# Copy entrypoint and make executable
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 4000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["node", "./dist/index.js"]

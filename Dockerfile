############################
# Stage 1 — Builder
############################
FROM node:20-bullseye-slim AS builder
WORKDIR /app

# Install required tools for Prisma & native modules
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential python3 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies for building
COPY package.json package-lock.json ./
RUN npm ci

# Copy TS config + Prisma schema + source code
COPY tsconfig.json ./
COPY prisma ./prisma
COPY src ./src

# Generate Prisma client + build TypeScript
RUN npx prisma generate
RUN npm run build


############################
# Stage 2 — Runner
############################
FROM node:20-bullseye-slim AS runner
WORKDIR /app

ENV NODE_ENV=production

# Copy Prisma schema (needed by client)
COPY prisma ./prisma

# Install only production dependencies
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Copy build artifacts and Prisma client
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

# Optional: If you generated Prisma engines
# COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma

# Copy entrypoint if you have one
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3000

CMD ["node", "dist/index.js"]


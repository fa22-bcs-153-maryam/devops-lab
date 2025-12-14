#!/bin/bash
set -euo pipefail

echo "[entrypoint] Starting entrypoint script"

# Ensure DATABASE_URL is set (this will still allow an empty check in non-production)
if [ -z "${DATABASE_URL:-}" ]; then
  echo "[entrypoint] WARNING: DATABASE_URL is not set. Prisma commands will likely fail until DATABASE_URL is provided."
else
  echo "[entrypoint] DATABASE_URL is set"
fi

echo "[entrypoint] Running prisma generate"
npx prisma generate

if [ -d "./prisma/migrations" ] && [ "$(ls -A prisma/migrations)" ]; then
  echo "[entrypoint] Migrations found — running 'prisma migrate deploy'"
  npx prisma migrate deploy
else
  echo "[entrypoint] No migrations found — running 'prisma db push' to sync schema"
  npx prisma db push
fi

echo "[entrypoint] Starting application: $@"
exec "$@"

## Node Express Typescript Prisma Boilerplate

🦄 Starter template for your Express Prisma MySQL API

## 🍔 Stack Specs

- Node.js
- Express
- TypeScript
- Prisma
- MySQL

## 🧬 Development

- Clone the repository

```
git clone https://github.com/mcnaveen/node-express-prisma-boilerplate nepb
```
- Cd into the project directory
```
cd nepb
```

- Install dependencies

```
yarn install
```

- Create a Database in MySQL (or) You can use GUI to create a database

```
mysql> CREATE DATABASE express;
```

- Copy the `.env.sample` file as `.env`

```
cp .env.sample .env
```

- Edit the MySQL Details in the `.env` file

```
DATABASE_URL="mysql://USERNAME:PASSWORD@localhost:3306/DBNAME?schema=public"
```

- Push the Prisma Schema into Database

```
npx prisma migrate dev
```

- Run the development server

```
yarn dev
```

## 🚀 Production Build

- Run the production build

```
yarn build
```

- Start the production server

```
yarn start
```

## 🐳 Docker (multi-stage) and automated DB migrations

This repository includes a **production-ready multi-stage `Dockerfile`** that minimizes image size, plus a **docker-entrypoint script** that automatically handles Prisma migrations on container startup.

### Features:
- **Multi-stage build**: Separates build (with dev deps) from runtime (slim production image)
- **Automated migrations**: Runs `prisma generate`, then `prisma migrate deploy` (or `prisma db push` if no migrations)
- **Optimized image**: Only production dependencies in final image

### Option 1: Docker Compose (Recommended for local testing)

A complete `docker-compose.yml` is included with MySQL service + health checks.

```bash
docker-compose up
```

This will:
- Spin up a MySQL container on port 3306
- Build and start the API container on port 4000
- Automatically run migrations and start the server
- Use credentials: `appuser` / `apppassword`

### Option 2: Manual Docker build and run

**Build the image:**

```bash
docker build -t my-api:latest .
```

**Run standalone** (with external MySQL):

```bash
docker run \
  -e DATABASE_URL="mysql://appuser:apppassword@db:3306/express_db?schema=public" \
  -p 4000:4000 \
  my-api:latest
```

### Entrypoint Script Behavior

On container start, `/usr/local/bin/docker-entrypoint.sh` will:

1. Run `prisma generate` to create the Prisma client
2. Check if `prisma/migrations` directory exists:
   - **If migrations exist**: Run `prisma migrate deploy` (production-safe)
   - **If no migrations**: Run `prisma db push` (development-style sync)
3. Start the Node.js application with `node ./dist/index.js`

### Notes:

- Ensure `DATABASE_URL` environment variable points to a reachable MySQL server
- For **production**, commit your `prisma/migrations/` folder to git; entrypoint will use `migrate deploy`
- For **development**, use `prisma db push` (the entrypoint will auto-detect)
- Multi-stage build reduces final image size by ~70% vs single-stage

> Your production build is available on `dist` folder

## 🧭 Endpoints

- `POST` - For Creating New User
- `GET` - For Getting All Users
- `GET` - For Getting User By ID
- `PATCH` - For Updating User By ID
- `DELETE` - For Deleting User By ID

## 🃏 Examples

> 💡 Please install the Recommended VS Code Extensions and Check `api.rest` file for Examples

- Creating a New User

```
POST http://localhost:4000/users
Content-Type: application/json

{
  "name": "john",
  "email": "john@gmail.com"
}
```

- Getting All Users

```
GET http://localhost:4000/users
```

- Getting User By ID

```
GET http://localhost:4000/users/1
```

- Patching User By ID

```
PATCH http://localhost:4000/users/1
Content-Type: application/json

{
  "name": "newjohn",
  "email": "john@gmail.com"
}
```

- Deleting User By ID

```
DELETE http://localhost:4000/users/1
```

## ☑️ LICENSE
- MIT

---
### 💰 HELP ME WITH DEVELOPMENT COST

<a href="https://www.buymeacoffee.com/mcnaveen" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

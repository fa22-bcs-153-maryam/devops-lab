 # DevOps Report — Node Express Prisma Boilerplate

 This document explains the containerization and CI/CD work completed for the repo, describes the pipeline, secret strategy, testing approach, and lessons learned.

 ## 1. Technologies used

 - Node.js 20
 - TypeScript
 - Express.js
 - Prisma ORM (MySQL datasource)
 - MySQL 8.0 (docker-compose service / GitHub Actions service)
 - Docker (multi-stage Dockerfile)
 - Docker Compose (local development: `api`, `db`, `frontend` services)
 - GitHub Actions (CI pipeline)
 - Nginx (frontend static site)

 ## 2. Pipeline design

 The CI pipeline is implemented at `.github/workflows/ci.yml`. It has five logical stages (jobs) with the following responsibilities and dependencies:

 - Build & Install (job: `build_install`)
   - Checkout code, install dependencies (`npm ci`), build TypeScript

 - Lint & Security Scan (job: `lint_and_security`) — runs after build_install
   - Type-check (tsc) and `npm audit` (high severity report)

 - Test (job: `test`) — runs after lint_and_security
   - Uses GitHub Actions services: `mysql:8.0` to provide a real DB
   - Waits for DB health, sets `DATABASE_URL`, runs `npx prisma generate` and `npx prisma migrate deploy`, starts the built app and performs smoke tests (POST /users, GET /users)

 - Build Docker Image (job: `build_image`) — runs after test
   - Logs into Docker Hub (using repository secrets), builds and pushes a SHA-tagged image via `docker/build-push-action`

 - Deploy (job: `deploy`) — runs only on `main` and after build_image
   - Pulls the SHA image, retags as `latest`, and pushes `latest` to Docker Hub

 High-level diagram (Mermaid):

 ```mermaid
 flowchart LR
   A[Build & Install] --> B[Lint & Security]
   B --> C[Test w/ MySQL service]
   C --> D[Build Docker Image (push SHA tag)]
   D --> E[Deploy (main only) retag -> latest]
 ```

 Notes:
 - The `build_image` and `deploy` jobs require Docker Hub secrets; they are made conditional when secrets are not present to avoid spurious failures.
 - The test job runs an integration-style test against a short-lived MySQL service provided by Actions.

 ## 3. Secret management strategy

 Secrets are _not_ stored in the repository. The following repository secrets are required for full CI functionality (add via GitHub → Settings → Secrets → Actions):

 - `DOCKERHUB_USERNAME` — Docker Hub username (e.g. `fa22bcs153`)
 - `DOCKERHUB_TOKEN` — Docker Hub Personal Access Token (PAT) with push/write permission

 Optional/separate secrets for cloud deployments (if you enable automatic deploy to a PaaS):
 - `RENDER_API_KEY` or `RAILWAY_TOKEN` for Render / Railway deployments
 - `PROD_DATABASE_URL` for pointing to a production database (if needed)

 Local vs CI:
 - Local developers can use `docker login` to push images from their machine with their personal credentials; CI uses the repository secrets so credentials are never committed to git.
 - Use a dedicated CI PAT for Docker Hub with the minimal required scopes (push/write).

 Rotation and least privilege:
 - Keep PATs scoped and rotate periodically.
 - For org-level repos consider using organization secrets or deploy keys with least privilege.

 ## 4. Testing process

 Local testing:
 - Use `docker compose up -d` to start `db`, `api`, and `frontend` locally.
 - Run `npx prisma migrate dev` to create migrations (or run `npx prisma db push` for a fast sync). The repo now contains `prisma/migrations/` after running migrations locally.
 - Start the API and exercise the endpoints (e.g., POST /users, GET /users).

 CI testing (what the pipeline does):
 - Actions spins up a `mysql:8.0` service and exposes it to the job.
 - The job writes `DATABASE_URL` to the job environment and runs `npx prisma generate` and `npx prisma migrate deploy` to ensure the database schema is applied.
 - The built app is started and a small set of smoke tests are executed using `curl` (create a user and list users). These are integration-style tests and verify end-to-end behavior.

 Extending tests:
 - Add unit tests (Jest/Mocha) and run them inside the `test` job before or after the integration smoke tests.
 - Add more thorough API/contract tests and database assertions as needed.

 ## 5. Lessons learned and gotchas

 - Prisma shadow database permissions: `prisma migrate dev` needs to create a shadow DB during development. If the app user lacks privileges, run with a `SHADOW_DATABASE_URL` or grant the app user `CREATE` privileges in the DB. In CI we used the Actions-provided MySQL service and verified privileges.

 - `postinstall` scripts can break production builds: the `prisma generate` CLI was initially in `postinstall`, which caused `npm ci --omit=dev` in the runner stage to fail (Prisma CLI wasn't present). Fix: run `prisma generate` in the builder stage and remove `postinstall` or ensure the CLI is available when needed.

 - Docker build caching: copy package.json & package-lock.json first and run `npm ci` before copying source to take advantage of layer caching and speed up incremental builds.

 - Port conflicts on developer host: the frontend used host port 3000 by default; if the host already had 3000 in use the Compose startup failed. Solution: either free the host port, or remap the host port to another (e.g., 3001) in `docker-compose.yml`.

 - Secrets in CI: an `authentication required - access token has insufficient scopes` error surfaced when using an incorrectly scoped Docker token. Create a PAT with push/write scopes and store it in GitHub secrets.

 - Use a two-stage Dockerfile: build in the first stage (dev deps, Prisma client generation, TypeScript compile), copy only runtime artifacts and prod deps to the runner stage for a small final image.

 ## 6. How to run locally (quick commands)

 1. Start DB and services (detached):
 ```powershell
 cd "<repo>"
 docker compose up -d --build
 ```

 2. Create/Apply migration locally (development):
 ```powershell
 npx prisma migrate dev --name init
 ```

 3. Add test data (example):
 ```powershell
 curl -X POST http://localhost:4000/users -H "Content-Type: application/json" -d '{"name":"local","email":"local@example.com"}'
 ```

 4. Build image and push (if logged in locally):
 ```powershell
 docker build -t fa22bcs153/prismaboilerplate:latest .
 docker push fa22bcs153/prismaboilerplate:latest
 ```

 ## 7. Next recommended improvements

 - Add unit and integration tests (Jest) and run them in the Test job.
 - Add a security scanner (Trivy or Snyk) as a step in `lint_and_security` to catch container-level vulnerabilities.
 - Add a deploy step to a cloud host (Render / Railway) using repository secrets for service tokens.
 - Add healthchecks and graceful shutdown handling to the Node app for production robustness.

 ---

 Created on: 2025-10-28

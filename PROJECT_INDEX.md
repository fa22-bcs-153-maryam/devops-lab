# DevOps Lab - Complete Project Index

## Project Overview

This is a comprehensive DevOps lab that demonstrates containerization, infrastructure provisioning, and Kubernetes deployment of a full-stack application.

**Technology Stack:**
- **Frontend**: Nginx (port 3001)
- **API**: Node.js + Express (port 4000)
- **Database**: MySQL (local) / PostgreSQL RDS (AWS)
- **Cache**: Redis (port 6379)
- **Containerization**: Docker & Docker Compose
- **Infrastructure**: Terraform on AWS
- **Orchestration**: Kubernetes (EKS)
- **Configuration**: Ansible
- **CI/CD**: GitHub Actions

## Project Structure

```
devops-lab/
│
├── 📁 src/                          # Node.js + Express API
│   └── index.ts                     # Main application with Redis caching
│
├── 📁 frontend/                     # Nginx static site
│   ├── index.html
│   ├── Dockerfile
│   └── nginx.conf
│
├── 📁 prisma/                       # Database ORM
│   ├── schema.prisma               # Data models
│   └── migrations/                 # Database migrations
│
├── 📁 infra/                        # Terraform Infrastructure (NEW - Step 2)
│   ├── provider.tf                 # AWS provider
│   ├── variables.tf                # Variable definitions
│   ├── terraform.tfvars            # Default values
│   ├── vpc.tf                      # VPC + Networking
│   ├── security_groups.tf          # Security configuration
│   ├── eks.tf                      # EKS Cluster
│   ├── rds.tf                      # PostgreSQL Database
│   ├── s3.tf                       # S3 Storage
│   ├── outputs.tf                  # Output values
│   ├── backend.tf                  # Remote state (optional)
│   └── README.md                   # Terraform documentation
│
├── 📁 ansible/                      # Configuration Management (COMING - Step 3)
│   ├── playbook.yaml               # Main playbook
│   ├── inventory/                  # Host inventory
│   └── roles/                      # Ansible roles
│
├── 📁 k8s/                          # Kubernetes Manifests (COMING - Step 4)
│   ├── deployment.yaml             # Kubernetes deployment
│   ├── service.yaml                # Kubernetes service
│   ├── configmap.yaml              # Configuration
│   ├── secret.yaml                 # Secrets
│   ├── ingress.yaml                # Ingress controller
│   └── helm/                       # Helm charts (optional)
│
├── .github/workflows/               # CI/CD Pipelines (COMING - Step 5)
│   ├── build.yaml                  # Build workflow
│   ├── test.yaml                   # Test workflow
│   ├── deploy.yaml                 # Deploy workflow
│   └── monitor.yaml                # Monitoring workflow
│
├── 📄 docker-compose.yml            # Local development
├── 📄 Dockerfile                    # Multistage Node.js image
├── 📄 docker-entrypoint.sh         # Container entrypoint
├── 📄 package.json                  # Node.js dependencies
├── 📄 tsconfig.json                # TypeScript configuration
│
├── 📋 STEP1_COMPLETION.md           # Step 1 summary
├── 📋 STEP2_TERRAFORM_READY.md      # Step 2 overview
├── 📋 STEP2_DEPLOYMENT_CHECKLIST.md # Step 2 instructions
├── 📋 STEP3_ANSIBLE_SETUP.md        # Step 3 preview (COMING)
├── 📋 STEP4_K8S_DEPLOYMENT.md       # Step 4 preview (COMING)
├── 📋 STEP5_CI_CD_PIPELINE.md       # Step 5 preview (COMING)
│
├── .env                            # Environment variables (local)
├── .env.example                    # Environment template
├── .gitignore                      # Git ignore rules
├── README.md                       # Project README
└── api.rest                        # REST API testing

```

## Step-by-Step Completion

### ✅ Step 1: Containerization (COMPLETE)

**Objective**: Containerize the application with database and cache.

**Deliverables:**
- ✅ Optimized Multistage Dockerfile
- ✅ Docker-compose.yml with 4 services (Frontend, API, MySQL, Redis)
- ✅ Container networking verified
- ✅ Persistent volumes for database and cache
- ✅ No hardcoded secrets (using .env files)

**Files:**
- `Dockerfile` - Multistage build for Node.js
- `docker-compose.yml` - All services configured
- `.env` - Environment variables
- `docker-entrypoint.sh` - Container startup script

**Verification:**
```bash
docker-compose up -d
curl http://localhost:4000/health  # API health
curl http://localhost:3001         # Frontend
docker-compose ps                  # Service status
```

**Status**: ✅ COMPLETE - Database on 3306, Redis on 6379, API on 4000, Frontend on 3001

---

### ✅ Step 2: Infrastructure Provisioning (COMPLETE)

**Objective**: Automate AWS infrastructure with Terraform.

**Deliverables:**
- ✅ VPC with public/private subnets
- ✅ EKS cluster (Kubernetes 1.28)
- ✅ 2 worker nodes (t3.medium, auto-scaling)
- ✅ RDS PostgreSQL database
- ✅ S3 bucket with encryption
- ✅ Security groups and IAM roles

**Files:**
- `infra/provider.tf` - AWS provider setup
- `infra/variables.tf` - Input variables
- `infra/vpc.tf` - Networking
- `infra/eks.tf` - Kubernetes cluster
- `infra/rds.tf` - Database
- `infra/s3.tf` - Object storage
- `infra/security_groups.tf` - Security configuration
- `infra/outputs.tf` - Important values
- `STEP2_TERRAFORM_READY.md` - Overview
- `STEP2_DEPLOYMENT_CHECKLIST.md` - Step-by-step guide

**Quick Start:**
```bash
cd infra
terraform init
terraform plan
terraform apply
# Takes 15-20 minutes

# Configure kubectl
aws eks update-kubeconfig --name devops-lab --region us-east-1
kubectl get nodes
```

**Status**: ✅ COMPLETE - Ready for deployment to AWS

---

### ⏳ Step 3: Configuration Management (COMING)

**Objective**: Automate server and application configuration with Ansible.

**Preview:**
- [ ] Ansible playbook for server configuration
- [ ] Inventory management (static + dynamic AWS)
- [ ] Deploy app configs to EKS nodes
- [ ] Install dependencies automatically
- [ ] Security hardening

**Expected Files:**
- `ansible/playbook.yaml`
- `ansible/inventory/hosts.ini`
- `ansible/roles/`
- `STEP3_ANSIBLE_SETUP.md`

**Timeline**: Next to implement

---

### ⏳ Step 4: Kubernetes Deployment (COMING)

**Objective**: Deploy containerized app to Kubernetes (EKS).

**Preview:**
- [ ] Deployment manifest with replicas
- [ ] Service for load balancing
- [ ] ConfigMap for configuration
- [ ] Secret for sensitive data
- [ ] Ingress for external access
- [ ] Namespace organization (dev/prod)

**Expected Files:**
- `k8s/deployment.yaml`
- `k8s/service.yaml`
- `k8s/configmap.yaml`
- `k8s/secret.yaml`
- `k8s/ingress.yaml`
- `STEP4_K8S_DEPLOYMENT.md`

**Timeline**: Next to implement

---

### ⏳ Step 5: CI/CD Pipeline (COMING)

**Objective**: Automate testing, building, and deployment.

**Preview:**
- [ ] GitHub Actions workflows
- [ ] Automated testing on push
- [ ] Docker image building
- [ ] Image registry (ECR/DockerHub)
- [ ] Automated deployment to EKS
- [ ] Monitoring and alerting

**Expected Files:**
- `.github/workflows/build.yaml`
- `.github/workflows/test.yaml`
- `.github/workflows/deploy.yaml`
- `.github/workflows/monitor.yaml`
- `STEP5_CI_CD_PIPELINE.md`

**Timeline**: Next to implement

---

## Key Endpoints & Access Points

### Local Development (Step 1)
```
Frontend:  http://localhost:3001
API:       http://localhost:4000
API Health: http://localhost:4000/health
Database:  localhost:3306 (MySQL)
Redis:     localhost:6379
```

### AWS Deployment (Step 2)
```
EKS Cluster Endpoint: https://xxxxx.eks.us-east-1.amazonaws.com
RDS Database: devops-lab-db.xxxxx.us-east-1.rds.amazonaws.com:5432
S3 Bucket: devops-lab-app-data-{account-id}
kubectl: aws eks update-kubeconfig --name devops-lab --region us-east-1
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check (DB + Redis status) |
| GET | `/` | Welcome message |
| POST | `/users` | Create new user |
| GET | `/users` | Get all users (cached) |
| GET | `/users/:id` | Get single user (cached) |
| PATCH | `/users/:id` | Update user |
| DELETE | `/users/:id` | Delete user |

## Important Commands

### Docker (Step 1)
```bash
docker-compose up -d              # Start all services
docker-compose down               # Stop all services
docker-compose logs -f api        # View API logs
docker-compose ps                 # Service status
docker-compose exec db mysql ...  # Access MySQL
docker-compose exec redis redis-cli ping  # Test Redis
```

### Terraform (Step 2)
```bash
cd infra
terraform init                    # Initialize
terraform validate               # Validate syntax
terraform plan                   # Show changes
terraform apply                  # Deploy (20 min)
terraform output                 # Show values
terraform destroy                # Cleanup
```

### Kubernetes (Step 4)
```bash
kubectl get nodes                 # List worker nodes
kubectl get pods -A               # All pods
kubectl get services              # List services
kubectl describe pod <name>       # Pod details
kubectl logs <pod-name>           # Pod logs
kubectl port-forward <pod> 8080:80  # Port forward
```

## Environment Variables

### Local (.env)
```
DB_ROOT_PASSWORD=rootpassword
DB_NAME=express_db
DB_USER=appuser
DB_PASSWORD=apppassword
REDIS_URL=redis://redis:6379
NODE_ENV=production
```

### AWS (terraform.tfvars)
```
aws_region = "us-east-1"
vpc_cidr = "10.0.0.0/16"
rds_password = "DevOpsLab@123456"
s3_bucket_name = "devops-lab-app-data"
```

## Cost Estimation

### Local Development
- Free (using Docker Desktop)

### AWS Infrastructure (Step 2)
- **Monthly**: ~$220
  - EKS cluster: $73
  - EKS nodes (2x t3.medium): $50
  - RDS (db.t3.micro): $30
  - NAT Gateways (2x): $64
  - Other services: ~$3

## Security Best Practices

✅ Implemented:
- Environment variables for secrets
- Security groups restrict traffic
- RDS encryption at rest
- S3 public access blocked
- IAM roles with least privilege

⚠️ TODO for Production:
- [ ] AWS Secrets Manager for passwords
- [ ] MFA for AWS console
- [ ] VPC Flow Logs
- [ ] CloudTrail auditing
- [ ] RDS Multi-AZ
- [ ] Pod Security Policies
- [ ] Network policies in Kubernetes

## Troubleshooting Guide

### Docker Issues
```bash
# Clean up
docker-compose down -v
docker system prune -a

# Check logs
docker-compose logs <service-name>
```

### Terraform Issues
```bash
# Validate
terraform validate

# Check state
terraform show

# View specific resource
terraform state show aws_eks_cluster.main
```

### Kubernetes Issues
```bash
# Check cluster health
kubectl get nodes
kubectl get cs  # Component status

# Check pod issues
kubectl describe pod <name>
kubectl logs <pod-name>
```

## Documentation Reference

- **Step 1**: See `STEP1_COMPLETION.md`
- **Step 2**: See `STEP2_TERRAFORM_READY.md` and `STEP2_DEPLOYMENT_CHECKLIST.md`
- **Terraform**: See `infra/README.md`
- **API**: See `api.rest` file

## Next Actions

1. **For Step 3 (Ansible)**:
   ```bash
   mkdir ansible
   cd ansible
   # Create playbook.yaml and inventory
   ```

2. **For Step 4 (Kubernetes)**:
   ```bash
   mkdir k8s
   cd k8s
   # Create deployment, service, configmap manifests
   ```

3. **For Step 5 (CI/CD)**:
   ```bash
   mkdir -p .github/workflows
   # Create GitHub Actions workflows
   ```

## Quick Reference

| Step | Technology | Status | Time | Cost |
|------|-----------|--------|------|------|
| 1 | Docker | ✅ Complete | 2 hours | Free |
| 2 | Terraform | ✅ Complete | 20 min | $220/mo |
| 3 | Ansible | ⏳ Next | 1-2 hours | Free |
| 4 | Kubernetes | ⏳ Coming | 2-3 hours | Included |
| 5 | GitHub Actions | ⏳ Coming | 2-3 hours | Free |

---

**Last Updated**: December 13, 2025
**Project Status**: 2/5 steps complete (40%)
**Progress**: ████░░░░░░ 40%

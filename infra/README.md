# Step 2: Infrastructure Provisioning with Terraform

## Overview
This Terraform configuration provisions a complete AWS infrastructure for running a containerized application on EKS (Elastic Kubernetes Service) with PostgreSQL database and S3 storage.

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
3. **Terraform** installed (>= 1.0)
4. **kubectl** for Kubernetes management

### Installation

```bash
# Install Terraform (Windows)
choco install terraform

# Install AWS CLI
choco install awscli

# Install kubectl
choco install kubernetes-cli
```

### Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter default region: us-east-1
# Enter default output format: json
```

## Infrastructure Components

### 1. **VPC (Virtual Private Cloud)**
- CIDR: 10.0.0.0/16
- 2 Public Subnets (for NAT Gateway, ALB)
- 2 Private Subnets (for EKS nodes, RDS)
- Internet Gateway
- NAT Gateways for private subnet internet access
- Route tables for public and private subnets

### 2. **EKS Cluster (Kubernetes)**
- Version: 1.28
- 2 Worker Nodes (t3.medium, auto-scaling 2-4)
- High availability across availability zones
- Security groups configured
- IAM roles and policies

### 3. **RDS PostgreSQL Database**
- Engine: PostgreSQL 15.4
- Instance: db.t3.micro
- Allocated Storage: 20 GB
- Multi-AZ: Disabled (for dev)
- Automated backups: 7 days retention
- Encryption: Enabled

### 4. **S3 Bucket**
- Versioning enabled
- Server-side encryption (AES256)
- Lifecycle policies (Glacier transition after 30 days)
- Public access blocked

### 5. **Security Groups**
- EKS Control Plane
- EKS Worker Nodes
- RDS Database (port 5432)
- ALB (ports 80, 443)

## File Structure

```
infra/
├── provider.tf           # AWS provider configuration
├── variables.tf          # Variable definitions
├── terraform.tfvars      # Variable values
├── vpc.tf               # VPC, subnets, route tables
├── security_groups.tf   # Security groups
├── eks.tf               # EKS cluster and node groups
├── rds.tf               # RDS PostgreSQL database
├── s3.tf                # S3 bucket configuration
├── outputs.tf           # Output values
└── backend.tf           # Backend configuration (optional)
```

## Deployment Steps

### 1. Initialize Terraform

```bash
cd infra
terraform init
```

### 2. Plan the Infrastructure

```bash
terraform plan -out=tfplan
```

This will show you all resources that will be created.

### 3. Apply the Configuration

```bash
terraform apply tfplan
```

**This will take ~15-20 minutes to complete:**
- VPC and networking: ~2 minutes
- EKS cluster: ~10-15 minutes
- RDS database: ~3-5 minutes
- S3 bucket: ~1 minute

### 4. Get Output Values

```bash
terraform output

# Or specific outputs
terraform output eks_cluster_name
terraform output eks_cluster_endpoint
terraform output rds_endpoint
```

### 5. Configure kubectl

```bash
aws eks update-kubeconfig --name devops-lab --region us-east-1

# Verify connection
kubectl get nodes
kubectl get pods --all-namespaces
```

## Important Variables

Edit `terraform.tfvars` to customize:

| Variable | Default | Purpose |
|----------|---------|---------|
| `aws_region` | us-east-1 | AWS region |
| `environment` | dev | Environment name |
| `vpc_cidr` | 10.0.0.0/16 | VPC CIDR block |
| `eks_cluster_version` | 1.28 | Kubernetes version |
| `eks_node_desired_size` | 2 | Number of worker nodes |
| `rds_password` | DevOpsLab@123456 | **Change in production!** |
| `s3_bucket_name` | devops-lab-app-data | S3 bucket name |

## Destroy Infrastructure

⚠️ **This will delete all AWS resources**

```bash
terraform destroy
```

Confirm by typing `yes` when prompted.

## Cost Estimation

**Rough monthly costs (us-east-1):**
- EKS: $73 (cluster) + ~$50 (2x t3.medium nodes)
- RDS: ~$30 (db.t3.micro)
- S3: ~$1 (minimal storage)
- NAT Gateway: ~$45 (2x)
- Data transfer: ~$5-10

**Total: ~$200-250/month**

## Troubleshooting

### EKS Nodes not ready

```bash
# Check node status
kubectl get nodes

# Describe node for details
kubectl describe node <node-name>
```

### RDS Connection Timeout

```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id>

# Test from EKS node
kubectl run -it --image=postgres:15 psql -- \
  psql -h <rds-endpoint> -U dbadmin -d devopsdb
```

### S3 Access Issues

```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket <bucket-name>

# List bucket contents
aws s3 ls s3://<bucket-name>/
```

## Next Steps

1. **Deploy application to EKS** - Create Kubernetes manifests
2. **Configure RDS database** - Create tables, users, permissions
3. **Set up Monitoring** - Add Prometheus and Grafana
4. **Implement Logging** - CloudWatch or ELK stack
5. **Configure CI/CD** - Deploy pipeline

## Security Best Practices

- ✅ RDS encryption enabled
- ✅ S3 public access blocked
- ✅ Security groups restrict traffic
- ✅ IAM roles follow least privilege
- ⚠️ TODO: Enable MFA for AWS console
- ⚠️ TODO: Use Secrets Manager for RDS password
- ⚠️ TODO: Enable VPC Flow Logs for monitoring
- ⚠️ TODO: Configure CloudTrail for auditing

## References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices)

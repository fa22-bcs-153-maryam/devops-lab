# Step 2: Infrastructure Provisioning with Terraform - READY TO DEPLOY ✅

## What Has Been Created

A complete Terraform infrastructure-as-code setup for AWS with the following components:

### 📁 Terraform Files Structure

```
infra/
├── provider.tf              ✓ AWS provider configuration
├── variables.tf             ✓ Input variables definition
├── terraform.tfvars         ✓ Default values for all variables
├── vpc.tf                   ✓ VPC, subnets, NAT gateways, route tables
├── security_groups.tf       ✓ Security groups for all services
├── eks.tf                   ✓ EKS cluster + node groups + IAM roles
├── rds.tf                   ✓ PostgreSQL database with backups
├── s3.tf                    ✓ S3 bucket with encryption & versioning
├── outputs.tf               ✓ Output values for easy reference
├── backend.tf               ✓ Remote state configuration (optional)
└── README.md                ✓ Comprehensive documentation
```

## AWS Resources That Will Be Created

### VPC & Networking (2-5 minutes)
- **VPC**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24 (for NAT, ALB)
- **Private Subnets**: 10.0.10.0/24, 10.0.11.0/24 (for EKS nodes, RDS)
- **Internet Gateway**: For public subnet internet access
- **NAT Gateways**: For private subnet outbound internet access
- **Route Tables**: Separate routing for public/private traffic

### EKS Kubernetes Cluster (10-15 minutes)
- **EKS Cluster**: Kubernetes 1.28
- **Worker Nodes**: 2x t3.medium (auto-scaling 2-4)
- **IAM Roles**: For cluster and nodes with least privilege access
- **Security Group**: Restricts traffic to Kubernetes communication

### RDS PostgreSQL Database (3-5 minutes)
- **Engine**: PostgreSQL 15.4
- **Instance**: db.t3.micro
- **Storage**: 20 GB SSD (gp2)
- **Backups**: 7-day retention
- **Encryption**: Enabled at rest
- **Security**: Private subnet + security group

### S3 Bucket (1 minute)
- **Bucket**: devops-lab-app-data-{account-id}
- **Versioning**: Enabled for data recovery
- **Encryption**: AES256 server-side encryption
- **Lifecycle**: Auto-transition to Glacier after 30 days
- **Access**: Fully blocked from public

### Security Groups
- **EKS Control Plane**: Manages cluster communication
- **EKS Worker Nodes**: Inter-node and control plane communication
- **RDS Database**: PostgreSQL port 5432 from worker nodes only
- **ALB**: HTTP/HTTPS from internet (80, 443)

## Pre-Deployment Checklist ✅

- [x] AWS Account created and accessible
- [ ] AWS CLI installed and configured (`aws configure`)
- [ ] Terraform installed (>= 1.0)
- [ ] kubectl installed for Kubernetes management
- [ ] Sufficient AWS permissions (EC2, EKS, RDS, S3, IAM)

## Quick Start Guide

### Step 1: Prerequisites Setup

```bash
# Check if tools are installed
terraform --version      # Should be >= 1.0
aws --version            # Should be >= 2.0
kubectl version --client # Should be latest

# Configure AWS credentials
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output: json

# Verify AWS credentials
aws sts get-caller-identity
```

### Step 2: Initialize Terraform

```bash
cd infra
terraform init

# This will:
# - Download AWS provider plugins
# - Create .terraform directory
# - Initialize Terraform state
```

### Step 3: Review Configuration

```bash
# Validate Terraform files
terraform validate

# Review all changes before applying
terraform plan

# This shows all resources that will be created
# Output: Create 20+ AWS resources
```

### Step 4: Deploy Infrastructure

```bash
# Apply the Terraform configuration
terraform apply

# Confirm by typing: yes
# This will take 15-20 minutes

# Watch logs:
# VPC: ~2 min
# EKS: ~12-15 min (longest)
# RDS: ~3-5 min
# S3: ~1 min
```

### Step 5: Get Connection Details

```bash
# Show all outputs
terraform output

# Key outputs:
terraform output eks_cluster_name
terraform output eks_cluster_endpoint
terraform output rds_endpoint
terraform output s3_bucket_name
```

### Step 6: Configure kubectl

```bash
# Update kubeconfig
aws eks update-kubeconfig \
  --name devops-lab \
  --region us-east-1

# Verify connection
kubectl get nodes
kubectl get pods --all-namespaces
```

## Customization

Edit `terraform.tfvars` to change:

```hcl
# Example customizations:

# Change AWS region
aws_region = "eu-west-1"

# Scale up EKS nodes
eks_node_desired_size = 3
eks_node_max_size = 6

# Use larger RDS instance
rds_instance_class = "db.t3.small"

# Change database password (⚠️ for dev only!)
rds_password = "YourNewPassword123!"
```

## Important Outputs

After deployment, Terraform will show:

```
Outputs:

vpc_id = "vpc-xxxxxxxxx"
eks_cluster_name = "devops-lab"
eks_cluster_endpoint = "https://xxxxx.eks.us-east-1.amazonaws.com"
eks_cluster_arn = "arn:aws:eks:us-east-1:123456789:cluster/devops-lab"
eks_node_group_id = "devops-lab-node-group"

rds_endpoint = "devops-lab-db.xxxxxxxxx.us-east-1.rds.amazonaws.com:5432"
rds_address = "devops-lab-db.xxxxxxxxx.us-east-1.rds.amazonaws.com"
rds_database_name = "devopsdb"

s3_bucket_name = "devops-lab-app-data-123456789"

configure_kubectl = "aws eks update-kubeconfig --name devops-lab --region us-east-1"
```

## Cost Estimation

**Monthly AWS Costs (us-east-1, on-demand):**

| Service | Quantity | Unit Cost | Total |
|---------|----------|-----------|-------|
| EKS Cluster | 1 | $73/mo | $73 |
| EKS Nodes | 2x t3.medium | ~$25/mo each | $50 |
| RDS db.t3.micro | 1 | ~$30/mo | $30 |
| NAT Gateway | 2 | ~$32/mo each | $64 |
| S3 Storage | ~10 GB | $0.023/GB | $0.23 |
| Data Transfer | 100 GB | $0.02/GB | $2 |
| **TOTAL** | | | **~$220/month** |

**💡 Cost Optimization Tips:**
- Use t3.micro for both EKS and RDS (dev environment)
- Use AWS Savings Plans (30% discount)
- Set resource limits in Kubernetes
- Delete unused resources when not in use

## Verification

After deployment, verify everything is working:

```bash
# Check EKS cluster
kubectl get nodes
kubectl get pods -A

# Check RDS connectivity
kubectl run -it --image=postgres:15 --rm psql -- \
  psql -h <rds-endpoint> -U dbadmin -d devopsdb -c "SELECT 1"

# Check S3 access
aws s3 ls s3://devops-lab-app-data-{account-id}/
```

## Troubleshooting

### EKS nodes not ready
```bash
kubectl describe node <node-name>
kubectl logs -n kube-system <pod-name>
```

### RDS connection timeout
```bash
# Check security group
aws ec2 describe-security-groups --filters "Name=tag:Name,Values=devops-lab-rds"

# Verify RDS is publicly accessible (should be false)
aws rds describe-db-instances --db-instance-identifier devops-lab-db
```

### S3 bucket access denied
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket devops-lab-app-data-{account-id}

# Check IAM permissions
aws iam list-attached-user-policies --user-name <your-user>
```

## Next Steps

After Infrastructure Provisioning:

1. **Step 3**: Configuration Management with Ansible
   - Automate server configuration
   - Deploy app configs to EKS nodes

2. **Step 4**: Kubernetes Deployment
   - Deploy application containers
   - Create services and ingress

3. **Step 5**: Monitoring with Prometheus & Grafana
   - Monitor EKS cluster health
   - Track application metrics

4. **Step 6**: CI/CD Pipeline
   - Automated testing
   - Automated deployment

## Security Considerations

✅ **Already Configured:**
- RDS encryption at rest
- S3 server-side encryption
- Security group restrictions
- IAM least privilege access
- VPC isolation

⚠️ **TODO for Production:**
- [ ] Enable MFA for AWS console
- [ ] Use AWS Secrets Manager for RDS password
- [ ] Enable VPC Flow Logs
- [ ] Configure CloudTrail for audit logs
- [ ] Enable RDS Multi-AZ
- [ ] Use VPN for RDS access
- [ ] Implement Pod Security Policies
- [ ] Enable audit logging for Kubernetes

## Cleanup

⚠️ **To remove all AWS resources and stop paying:**

```bash
terraform destroy

# Confirm by typing: yes
# This will take 10-15 minutes
```

---

**Status**: ✅ Step 2 Ready - Terraform files created and documented
**Next**: Deploy to AWS by running `terraform init` → `terraform plan` → `terraform apply`

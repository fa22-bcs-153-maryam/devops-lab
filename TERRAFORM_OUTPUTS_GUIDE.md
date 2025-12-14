# Step 2: Terraform Outputs & Provisioned Resources

## Understanding Terraform Outputs

**`terraform output`** is a command that displays all the valuable information from your deployed infrastructure. These values are defined in `outputs.tf`.

### Why Outputs Matter?
- ✅ Get connection strings for databases
- ✅ Get cluster endpoints for kubectl configuration
- ✅ Get resource IDs for further configuration
- ✅ Get AWS resource information for automation
- ✅ Reference values for other tools (Ansible, monitoring, etc.)

---

## Provisioned AWS Resources

### 1. VPC & NETWORKING
```
Resource Type: aws_vpc
├── Name: devops-lab-vpc
├── CIDR Block: 10.0.0.0/16
├── DNS Hostnames: Enabled
└── DNS Support: Enabled

Output: vpc_id = "vpc-xxxxxxxxx"
        vpc_cidr = "10.0.0.0/16"
```

**Subnets Created:**
```
Public Subnets (for NAT Gateway, Load Balancer):
  ├── Subnet 1: 10.0.1.0/24 (AZ-a) - Maps public IPs
  └── Subnet 2: 10.0.2.0/24 (AZ-b) - Maps public IPs

Private Subnets (for EKS nodes, RDS):
  ├── Subnet 1: 10.0.10.0/24 (AZ-a) - Route through NAT
  └── Subnet 2: 10.0.11.0/24 (AZ-b) - Route through NAT

Outputs: public_subnet_ids = ["subnet-xxx", "subnet-yyy"]
         private_subnet_ids = ["subnet-aaa", "subnet-bbb"]
```

**Internet Connectivity:**
```
✓ Internet Gateway (IGW) for public subnets
✓ NAT Gateways (2x) for private subnets egress
✓ Elastic IPs (2x) for NAT Gateways
✓ Route Tables: Public & Private (2x)
```

---

### 2. EKS KUBERNETES CLUSTER
```
Resource Type: aws_eks_cluster
├── Cluster Name: devops-lab
├── Kubernetes Version: 1.28
├── IAM Role: eks-cluster-role
├── Subnet IDs: All 4 subnets (public + private)
└── Security Groups: eks-control-plane-sg

Outputs: 
  eks_cluster_name = "devops-lab"
  eks_cluster_endpoint = "https://abc123.eks.us-east-1.amazonaws.com"
  eks_cluster_version = "1.28"
  eks_cluster_arn = "arn:aws:eks:us-east-1:123456789:cluster/devops-lab"
```

**Node Group (Worker Nodes):**
```
Resource Type: aws_eks_node_group
├── Node Group Name: devops-lab-node-group
├── IAM Role: eks-node-role
├── Subnets: Private subnets (for security)
├── Instance Type: t3.medium
├── Desired Size: 2 nodes
├── Min Size: 2 nodes
├── Max Size: 4 nodes (auto-scaling)
└── Security Group: eks-worker-nodes-sg

Output: eks_node_group_id = "devops-lab-node-group-xxx"
```

**IAM Roles & Policies:**
```
Cluster Role:
  ├── AmazonEKSClusterPolicy
  └── AmazonEKSVPCResourceController

Node Role:
  ├── AmazonEKSWorkerNodePolicy
  ├── AmazonEKS_CNI_Policy (for networking)
  └── AmazonEC2ContainerRegistryReadOnly (for ECR)
```

---

### 3. RDS PostgreSQL DATABASE
```
Resource Type: aws_db_instance
├── Identifier: devops-lab-db
├── Engine: PostgreSQL
├── Engine Version: 15.4
├── Instance Class: db.t3.micro
├── Allocated Storage: 20 GB
├── Storage Type: gp2
├── Database Name: devopsdb
├── Master Username: dbadmin
├── Master Password: (from variables)
└── Multi-AZ: false (dev environment)

Outputs:
  rds_endpoint = "devops-lab-db.abc123.us-east-1.rds.amazonaws.com:5432"
  rds_address = "devops-lab-db.abc123.us-east-1.rds.amazonaws.com"
  rds_port = 5432
  rds_database_name = "devopsdb"
```

**RDS Configuration:**
```
Security:
  ├── Encryption: Enabled (at rest)
  ├── Security Group: rds-sg (port 5432 from EKS nodes only)
  └── Deletion Protection: false

Backups & Maintenance:
  ├── Automated Backups: 7 days retention
  ├── Backup Window: 03:00-04:00 UTC
  └── Maintenance Window: Monday 04:00-05:00 UTC

Storage:
  └── DB Subnet Group: private-subnets-only
```

**Connection String Example:**
```
postgresql://dbadmin:password@devops-lab-db.abc123.us-east-1.rds.amazonaws.com:5432/devopsdb
```

---

### 4. S3 BUCKET
```
Resource Type: aws_s3_bucket
├── Bucket Name: devops-lab-app-data-123456789 (unique)
├── Region: us-east-1
├── Versioning: Enabled
├── Encryption: AES256
└── Public Access: Blocked

Outputs:
  s3_bucket_name = "devops-lab-app-data-123456789"
  s3_bucket_arn = "arn:aws:s3:::devops-lab-app-data-123456789"
  s3_bucket_region = "us-east-1"
```

**S3 Lifecycle Policy:**
```
Rule 1: Delete old versions after 90 days
Rule 2: Transition to Glacier after 30 days
```

---

### 5. SECURITY GROUPS
```
1. EKS Control Plane SG (eks-control-plane-sg)
   ├── Ingress: None (AWS manages)
   └── Egress: All traffic allowed

2. EKS Worker Nodes SG (eks-worker-nodes-sg)
   ├── Ingress: From itself (node-to-node communication)
   ├── Ingress: From control plane
   └── Egress: All traffic allowed

3. RDS Database SG (rds-sg)
   ├── Ingress: Port 5432 from worker nodes only
   └── Egress: All traffic allowed

4. ALB SG (alb-sg)
   ├── Ingress: Port 80 (HTTP) from 0.0.0.0/0
   ├── Ingress: Port 443 (HTTPS) from 0.0.0.0/0
   └── Egress: All traffic allowed
```

---

## How to Get Terraform Outputs

### Method 1: View All Outputs
```bash
cd infra
terraform output
```

**Example Output:**
```
aws_region = "us-east-1"
configure_kubectl = "aws eks update-kubeconfig --name devops-lab --region us-east-1"
deployment_summary = {
  "eks_cluster_endpoint" = "https://abc123.eks.us-east-1.amazonaws.com"
  "eks_cluster_name" = "devops-lab"
  "rds_endpoint" = "devops-lab-db.abc123.us-east-1.rds.amazonaws.com:5432"
  "region" = "us-east-1"
  "s3_bucket_name" = "devops-lab-app-data-123456789"
  "vpc_id" = "vpc-0a1b2c3d4e5f"
}
eks_cluster_arn = "arn:aws:eks:us-east-1:123456789012:cluster/devops-lab"
eks_cluster_endpoint = "https://abc123.eks.us-east-1.amazonaws.com"
...
```

### Method 2: Get Specific Output
```bash
# Get EKS cluster name
terraform output eks_cluster_name

# Get RDS endpoint
terraform output rds_endpoint

# Get S3 bucket name
terraform output s3_bucket_name
```

### Method 3: Export as JSON
```bash
terraform output -json > outputs.json
```

### Method 4: Export Specific Output as JSON
```bash
terraform output -json eks_cluster_endpoint > cluster-endpoint.json
```

---

## Summary of Outputs (outputs.tf)

| Output Name | Description | Example |
|---|---|---|
| `vpc_id` | VPC identifier | vpc-0a1b2c3d4e5f |
| `vpc_cidr` | VPC CIDR block | 10.0.0.0/16 |
| `public_subnet_ids` | Public subnet IDs | ["subnet-xxx", "subnet-yyy"] |
| `private_subnet_ids` | Private subnet IDs | ["subnet-aaa", "subnet-bbb"] |
| `eks_cluster_name` | Kubernetes cluster name | devops-lab |
| `eks_cluster_endpoint` | Kubernetes API endpoint | https://abc123.eks... |
| `eks_cluster_version` | Kubernetes version | 1.28 |
| `eks_cluster_arn` | Cluster ARN | arn:aws:eks:... |
| `eks_node_group_id` | Node group identifier | devops-lab-node-group-xxx |
| `rds_endpoint` | Database endpoint:port | devops-lab-db.xxx:5432 |
| `rds_address` | Database hostname only | devops-lab-db.xxx |
| `rds_port` | Database port | 5432 |
| `rds_database_name` | Default database | devopsdb |
| `s3_bucket_name` | S3 bucket name | devops-lab-app-data-xxx |
| `s3_bucket_arn` | S3 bucket ARN | arn:aws:s3:::... |
| `configure_kubectl` | Command to setup kubectl | aws eks update-kubeconfig... |

---

## Complete Deployment Workflow

### Step 1: Initialize Terraform
```bash
cd infra
terraform init
```

### Step 2: Plan Deployment
```bash
terraform plan -out=tfplan
```
This shows all resources that will be created.

### Step 3: Apply (Deploy)
```bash
terraform apply tfplan
# Wait 15-20 minutes for full deployment
```

### Step 4: Get Outputs
```bash
terraform output
```

### Step 5: Configure kubectl
```bash
# Use the output from configure_kubectl
aws eks update-kubeconfig --name devops-lab --region us-east-1

# Verify connection
kubectl get nodes
```

### Step 6: Verify Resources in AWS Console
1. **VPC Dashboard**: Check VPC, Subnets, Route Tables
2. **EKS**: Check cluster status and nodes
3. **RDS**: Check database endpoint and status
4. **S3**: Check bucket existence and properties

---

## Cost Breakdown

| Resource | Type | Monthly Cost |
|---|---|---|
| EKS Cluster | Control Plane | $73 |
| EC2 Nodes | 2x t3.medium | ~$50 |
| RDS Database | db.t3.micro | ~$30 |
| NAT Gateway | 2x | ~$45 |
| S3 Storage | Minimal | ~$1 |
| **Total** | | **~$200-250** |

---

## Next Steps

1. ✅ Run `terraform init` in infra/ folder
2. ✅ Run `terraform plan` to preview resources
3. ✅ Run `terraform apply` to create infrastructure
4. ✅ Run `terraform output` to get resource details
5. → Configure kubectl with EKS cluster
6. → Deploy application to Kubernetes (Step 4)
7. → Configure Ansible (Step 3)
8. → Set up CI/CD (Step 5)

---

## Important Notes

⚠️ **Costs**: EKS is expensive for development. Consider:
- Reducing node count to 1 (or use Spot instances)
- Using smaller instance types (t3.small)
- Using dev environment settings
- Destroying resources when not in use

💾 **State Management**: 
- Local state file: `terraform.tfstate` (git-ignored)
- For production: Use S3 backend with DynamoDB locks

🔒 **Security**:
- Don't commit `.tfstate` files to git
- Use AWS Secrets Manager for passwords
- Enable MFA for AWS console access
- Regularly rotate RDS passwords

---

## Troubleshooting

### EKS cluster not ready
```bash
# Check cluster status
aws eks describe-cluster --name devops-lab --region us-east-1

# Check node status
kubectl get nodes
```

### RDS not accessible
```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids sg-xxx

# Test connection from pod
kubectl run -it --image=postgres:15 psql -- \
  psql -h <rds-endpoint> -U dbadmin -d devopsdb
```

### Terraform state issues
```bash
# Show current state
terraform show

# Show specific resource
terraform state show aws_eks_cluster.main

# Refresh state (sync with AWS)
terraform refresh
```

---

## References

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [Terraform Output Documentation](https://www.terraform.io/language/values/outputs)

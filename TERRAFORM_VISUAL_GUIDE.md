# AWS Terraform Deployment - Visual Guide

## Deployment Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    TERRAFORM DEPLOYMENT PROCESS                         │
└─────────────────────────────────────────────────────────────────────────┘

PHASE 1: Pre-Deployment
═════════════════════════════════════════════════════════════════════════
    
    AWS Account          AWS Credentials       Terraform       AWS CLI
    ✓ Created            aws configure         Installed       Installed
         ↓                    ↓                    ↓                ↓
    ┌──────────────────────────────────────────────────────────────────┐
    │ Verify: aws sts get-caller-identity → See Account ID            │
    └──────────────────────────────────────────────────────────────────┘
         ↓
    Ready for Deployment


PHASE 2: Initialize Terraform
═════════════════════════════════════════════════════════════════════════
    
    Command: terraform init
         ↓
    ┌──────────────────────────────────────────┐
    │ Downloads AWS Provider Plugins           │
    │ Creates .terraform/ folder               │
    │ Creates .terraform.lock.hcl              │
    └──────────────────────────────────────────┘
         ↓
    Ready to Plan


PHASE 3: Plan Infrastructure
═════════════════════════════════════════════════════════════════════════
    
    Command: terraform plan -out=tfplan
         ↓
    ┌──────────────────────────────────────────┐
    │ Parses *.tf files                        │
    │ Connects to AWS (read-only)              │
    │ Shows what WILL be created               │
    │ Plan: 63 to add, 0 to change             │
    └──────────────────────────────────────────┘
         ↓
    Review Plan (optional)
         ↓
    Ready to Deploy


PHASE 4: Deploy to AWS
═════════════════════════════════════════════════════════════════════════
    
    Command: terraform apply tfplan
         ↓
    ⏱️  TIMELINE: 18-20 MINUTES
    
    0:00-0:02
    ┌─ VPC & Networking
    │  ├─ VPC (10.0.0.0/16)
    │  ├─ Internet Gateway
    │  ├─ NAT Gateways (2)
    │  └─ Subnets (4)
    │
    0:02-0:05
    ├─ Security Groups (4)
    │
    0:05-15:00 ⏳⏳⏳
    ├─ EKS Cluster (10-12 minutes - LONGEST STEP)
    │  ├─ Control Plane
    │  ├─ IAM Roles
    │  └─ Cluster Endpoint
    │
    15:00-18:00
    ├─ EKS Node Group
    │  ├─ 2 Worker Nodes (t3.medium)
    │  ├─ Auto Scaling Group
    │  └─ Security Group
    │
    15:05-17:00
    ├─ RDS PostgreSQL Database
    │  ├─ Instance (db.t3.micro)
    │  ├─ Backup Configuration
    │  └─ Encryption
    │
    0:10-0:15
    └─ S3 Bucket
       ├─ Versioning
       ├─ Encryption
       └─ Lifecycle Policies
    
    18:00
    ✓ All Complete
         ↓
    Apply complete! Resources: 63 added


PHASE 5: Extract Outputs
═════════════════════════════════════════════════════════════════════════
    
    Command: terraform output
         ↓
    Get Critical Values:
    ┌──────────────────────────────────────────┐
    │ VPC ID: vpc-xxxxxxx                      │
    │ EKS Endpoint: https://abc123.eks...      │
    │ RDS Endpoint: devops-lab-db.xxx.rds...   │
    │ S3 Bucket: devops-lab-app-data-xxx       │
    │ + 20+ more outputs                       │
    └──────────────────────────────────────────┘
         ↓
    Save: terraform-outputs.txt


PHASE 6: Configure kubectl
═════════════════════════════════════════════════════════════════════════
    
    Command: aws eks update-kubeconfig --name devops-lab
         ↓
    ┌──────────────────────────────────────────┐
    │ Updates ~/.kube/config                   │
    │ Adds EKS cluster context                 │
    │ Enables kubectl to connect               │
    └──────────────────────────────────────────┘
         ↓
    kubectl is now connected to EKS


PHASE 7: Verify Deployment
═════════════════════════════════════════════════════════════════════════
    
    Test 1: kubectl get nodes
         ↓
    ┌─────────────────────────────────────┐
    │ NAME                    STATUS       │
    │ ip-10-0-10-123...      Ready   ✓    │
    │ ip-10-0-11-456...      Ready   ✓    │
    └─────────────────────────────────────┘
    
    Test 2: kubectl cluster-info
         ↓
    Control plane is running at https://xxx ✓
    
    Test 3: kubectl get pods -A
         ↓
    System pods running in kube-system ✓
         ↓
    Deployment Verified! ✓✓✓


PHASE 8: Document with Screenshots
═════════════════════════════════════════════════════════════════════════
    
    Take Screenshots from AWS Console:
    
    VPC Resources
    ├── VPC Dashboard (vpc-xxxxxxx)
    ├── Subnets (4 subnets)
    ├── Security Groups (4 SGs)
    └── Internet Gateway
    
    EKS Resources
    ├── EKS Cluster (devops-lab, ACTIVE)
    ├── EKS Nodes (2x t3.medium, Ready)
    └── Node Group (devops-lab-node-group)
    
    RDS Resources
    ├── RDS Databases (devopsdb, Available)
    ├── RDS Instance (t3.micro)
    └── RDS Endpoint (copy for later)
    
    S3 Resources
    ├── S3 Buckets (devops-lab-app-data-xxx)
    ├── Versioning (Enabled)
    └── Encryption (Enabled)
    
    → Save all screenshots to screenshots/ folder
```

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         AWS INFRASTRUCTURE                              │
│                        (Created by Terraform)                           │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                    REGION: us-east-1                                    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │              VPC: 10.0.0.0/16 (devops-lab-vpc)                 │  │
│  │                                                                 │  │
│  │  ┌──────────────────┐        ┌──────────────────┐              │  │
│  │  │  Availability    │        │  Availability    │              │  │
│  │  │  Zone: us-east-1a│        │  Zone: us-east-1b│              │  │
│  │  │                  │        │                  │              │  │
│  │  │ ┌──────────────┐ │        │ ┌──────────────┐ │              │  │
│  │  │ │ PUBLIC SUBNET│ │        │ │ PUBLIC SUBNET│ │              │  │
│  │  │ │ 10.0.1.0/24  │ │        │ │ 10.0.2.0/24  │ │              │  │
│  │  │ │              │ │        │ │              │ │              │  │
│  │  │ │ NAT Gateway  │ │        │ │ NAT Gateway  │ │              │  │
│  │  │ └──────────────┘ │        │ └──────────────┘ │              │  │
│  │  │ ┌──────────────┐ │        │ ┌──────────────┐ │              │  │
│  │  │ │ PRIVATE      │ │        │ │ PRIVATE      │ │              │  │
│  │  │ │ SUBNET       │ │        │ │ SUBNET       │ │              │  │
│  │  │ │ 10.0.10.0/24 │ │        │ │ 10.0.11.0/24 │ │              │  │
│  │  │ │              │ │        │ │              │ │              │  │
│  │  │ │ ┌──────────┐ │ │        │ │ ┌──────────┐ │ │              │  │
│  │  │ │ │ EKS Node │ │ │        │ │ │ EKS Node │ │ │              │  │
│  │  │ │ │t3.medium │ │ │        │ │ │t3.medium │ │ │              │  │
│  │  │ │ │ Ready ✓  │ │ │        │ │ │ Ready ✓  │ │ │              │  │
│  │  │ │ └──────────┘ │ │        │ │ └──────────┘ │ │              │  │
│  │  │ └──────────────┘ │        │ └──────────────┘ │              │  │
│  │  └──────────────────┘        └──────────────────┘              │  │
│  │                                                                 │  │
│  │  ┌──────────────────────────────────────────────────────────┐  │  │
│  │  │         EKS CONTROL PLANE (AWS Managed)                 │  │  │
│  │  │  Endpoint: https://abc123.eks.us-east-1.amazonaws.com   │  │  │
│  │  │  Kubernetes 1.28                                        │  │  │
│  │  └──────────────────────────────────────────────────────────┘  │  │
│  │                                                                 │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  ┌──────────────────────────────────────────────────────────┐   │  │
│  │  │  RDS POSTGRESQL DATABASE                                │   │  │
│  │  │  ├─ Name: devopsdb                                       │   │  │
│  │  │  ├─ Engine: PostgreSQL 15.4                             │   │  │
│  │  │  ├─ Instance: db.t3.micro                               │   │  │
│  │  │  ├─ Storage: 20 GB                                       │   │  │
│  │  │  ├─ Port: 5432                                           │   │  │
│  │  │  ├─ Endpoint: devops-lab-db.xxx.rds.amazonaws.com       │   │  │
│  │  │  ├─ Encryption: Enabled ✓                               │   │  │
│  │  │  └─ Backup: 7-day retention                              │   │  │
│  │  └──────────────────────────────────────────────────────────┘   │  │
│  │                                                                   │  │
│  │  ┌──────────────────────────────────────────────────────────┐   │  │
│  │  │  S3 BUCKET                                               │   │  │
│  │  │  ├─ Name: devops-lab-app-data-123456789012              │   │  │
│  │  │  ├─ Region: us-east-1                                    │   │  │
│  │  │  ├─ Versioning: Enabled ✓                               │   │  │
│  │  │  ├─ Encryption: AES256 ✓                                │   │  │
│  │  │  ├─ Public Access: Blocked ✓                            │   │  │
│  │  │  └─ Lifecycle Policies: Enabled ✓                       │   │  │
│  │  └──────────────────────────────────────────────────────────┘   │  │
│  │                                                                   │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─ Internet Gateway                                                  │
│  │  └─ NAT Gateways (2)                                               │
│  │  └─ Route Tables                                                   │
│  │  └─ Security Groups (4)                                            │
│  └─ VPC Endpoints (optional)                                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

        ↓ All Managed by Terraform

┌─────────────────────────────────────────────────────────────────────────┐
│  terraform.tfstate (Stores Infrastructure State)                        │
│  ├─ Resource IDs                                                        │
│  ├─ Attributes                                                          │
│  └─ Relationships                                                       │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Resource Creation Order (What Happens When You Apply)

```
1. VPC (VPC must exist first)
   └─ 1 minute

2. Internet Gateway (Attaches to VPC)
   └─ 30 seconds

3. NAT Gateway Elastic IPs (Needed for NAT Gateways)
   └─ 30 seconds

4. Public Subnets (2)
   └─ 1 minute

5. Private Subnets (2)
   └─ 1 minute

6. Route Tables (Public & Private)
   └─ 1 minute

7. Security Groups (4)
   └─ 2 minutes

8. EKS Cluster Role & Policy
   └─ 1 minute

9. EKS CLUSTER ⏳⏳⏳ (LONGEST STEP)
   └─ 10-12 minutes

10. EKS Node Role & Policy
    └─ 1 minute

11. EKS Node Group
    └─ 2-3 minutes

12. RDS Subnet Group
    └─ 30 seconds

13. RDS DATABASE (Parallel with Node Group)
    └─ 3-5 minutes

14. S3 Bucket (Parallel with RDS)
    └─ 1 minute

15. CloudWatch Log Group (For EKS logs)
    └─ 30 seconds

Total Time: ~18-20 minutes
(Some resources created in parallel)
```

---

## What Each File Does

```
provider.tf
└─ Configures AWS provider
   └─ Sets region to us-east-1
   └─ Adds default tags

variables.tf
└─ Defines all input variables
   └─ Can be overridden via tfvars
   └─ Provides descriptions & defaults

vpc.tf
└─ Creates VPC infrastructure
   ├─ 1 VPC (10.0.0.0/16)
   ├─ 4 Subnets (2 public, 2 private)
   ├─ Internet Gateway
   ├─ 2 NAT Gateways
   ├─ Route Tables
   └─ Route Associations

security_groups.tf
└─ Creates 4 Security Groups
   ├─ EKS Control Plane
   ├─ EKS Worker Nodes
   ├─ RDS Database
   └─ Application Load Balancer

eks.tf
└─ Creates EKS Kubernetes Cluster
   ├─ EKS Cluster
   ├─ Node Group (2-4 nodes, t3.medium)
   ├─ IAM Roles & Policies
   └─ Auto Scaling Configuration

rds.tf
└─ Creates RDS Database
   ├─ PostgreSQL 15.4 instance
   ├─ Backup configuration
   ├─ Encryption settings
   ├─ Multi-AZ disabled (cost savings)
   └─ Parameter groups

s3.tf
└─ Creates S3 Bucket
   ├─ Versioning enabled
   ├─ Encryption enabled
   ├─ Public access blocked
   ├─ Lifecycle policies
   └─ Bucket policies

outputs.tf
└─ Extracts important values
   ├─ VPC ID
   ├─ EKS endpoints
   ├─ RDS endpoints
   ├─ S3 bucket name
   └─ kubectl configuration command

terraform.tfvars
└─ Input values for variables
   └─ Can be modified for customization

backend.tf
└─ Remote state configuration
   └─ Currently commented (local state)
   └─ Uncomment for team usage
```

---

## Expected Output Structure

```
terraform.tfstate
└─ Binary state file
   └─ Contains all resource IDs
   └─ Keep SECURE!

.terraform/
└─ Local cache folder
   ├─ AWS provider plugins
   ├─ Terraform modules
   └─ Lock file

tfplan
└─ Plan file (binary)
   └─ Shows what will be created
   └─ Can be applied multiple times

terraform-outputs.txt
└─ Text export of outputs
   ├─ VPC ID: vpc-xxxxxxx
   ├─ EKS Endpoint: https://...
   ├─ RDS Endpoint: devops-lab-db...
   └─ S3 Bucket: devops-lab-app-data-...

.terraform.lock.hcl
└─ Locks provider version
   └─ Ensures consistency across team
```

---

## Cost Breakdown

```
AWS Monthly Costs (Approximate):

┌─────────────────────────────────────────┐
│  EKS Control Plane                      │
│  └─ $73.00/month (fixed)               │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  EC2 Worker Nodes (2x t3.medium)        │
│  └─ $0.0416/hour × 730 hours/month     │
│  └─ ~$60.00/month                       │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  RDS (db.t3.micro)                      │
│  └─ $0.017/hour × 730 hours/month      │
│  └─ ~$25.00/month                       │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  S3 Storage                             │
│  └─ <$1.00/month (with 20 GB)          │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  Data Transfer                          │
│  └─ <$5.00/month                        │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  TOTAL: ~$160-170/month                 │
│                                         │
│  To Stop Costs:                         │
│  terraform destroy                      │
│  (Deletes all resources)                │
└─────────────────────────────────────────┘
```

---

## Success Checklist After Deployment

```
Infrastructure Created:
✓ VPC with CIDR 10.0.0.0/16
✓ 2 Public Subnets (10.0.1.0/24, 10.0.2.0/24)
✓ 2 Private Subnets (10.0.10.0/24, 10.0.11.0/24)
✓ 2 NAT Gateways (one in each public subnet)
✓ Internet Gateway
✓ Public & Private Route Tables
✓ 4 Security Groups (control plane, nodes, RDS, ALB)

EKS Cluster:
✓ Cluster Name: devops-lab
✓ Cluster Status: ACTIVE
✓ Kubernetes Version: 1.28
✓ Endpoint: https://abc123.eks.us-east-1.amazonaws.com
✓ 1 Node Group: devops-lab-node-group
✓ 2 Worker Nodes: Ready status
✓ IAM Roles: EKSClusterRole, EKSNodeRole

RDS Database:
✓ Database Name: devopsdb
✓ Engine: PostgreSQL 15.4
✓ Instance Class: db.t3.micro
✓ Storage: 20 GB
✓ Port: 5432
✓ Status: Available
✓ Encryption: Enabled
✓ Backups: 7-day retention

S3 Bucket:
✓ Bucket Name: devops-lab-app-data-[account-id]
✓ Versioning: Enabled
✓ Encryption: AES256
✓ Public Access: All Blocked
✓ Lifecycle Policies: Enabled

kubectl Status:
✓ kubectl configured
✓ kubectl get nodes → 2 nodes in Ready state
✓ kubectl cluster-info → Control plane accessible
✓ kubectl get pods -a → System pods running
```

---

**Now you have a complete visual guide for the Terraform deployment!** 📊

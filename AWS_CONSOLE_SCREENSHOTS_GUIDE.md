# AWS Console Screenshots Guide - Step 2 Terraform Deployment

## Overview
This guide shows you how to:
1. Deploy Terraform infrastructure to AWS
2. Navigate AWS Console to view created resources
3. Take screenshots for documentation
4. Verify all resources are working

---

## Phase 1: Deploy Terraform Infrastructure

### Prerequisites
1. **AWS Account** - Created and verified
2. **AWS CLI** - Configured with credentials
3. **Terraform** - Installed on your computer
4. **AWS Console Access** - Ability to login

### Step 1: Check AWS Credentials

Open PowerShell/Terminal:

```bash
# Verify AWS credentials are configured
aws sts get-caller-identity
```

**Expected Output:**
```json
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-user-name"
}
```

### Step 2: Initialize Terraform

```bash
cd c:\Users\Dell\Documents\FinalLab1\devops-lab\infra

# Initialize Terraform
terraform init

# Validate configuration
terraform validate
```

**Expected Output:**
```
Terraform has been successfully initialized!

Success! The configuration is valid.
```

### Step 3: Plan Deployment

```bash
# Create plan file
terraform plan -out=tfplan

# This shows what will be created without actually creating it
```

**Output will show:**
- Resources to be added: ~60+ resources
- No changes to existing resources
- No resources to be destroyed

### Step 4: Apply Terraform (DEPLOY)

```bash
# Deploy to AWS (takes 15-20 minutes)
terraform apply tfplan

# When complete, you'll see:
# Apply complete! Resources: XX added, 0 changed, 0 destroyed.
```

**⏱️ This step takes TIME - Go grab coffee!**

Progress:
```
aws_vpc.main: Creating...              (1-2 min)
aws_security_group: Creating...        (2-3 min)
aws_eks_cluster.main: Creating...      (10-15 min)  ⏳ Longest step
aws_db_instance.main: Creating...      (3-5 min)
aws_s3_bucket: Creating...             (~1 min)
```

### Step 5: Get Terraform Outputs

Once deployment completes:

```bash
# Display all outputs
terraform output

# Save to file for reference
terraform output > terraform-outputs.txt

# Export as JSON
terraform output -json > terraform-outputs.json
```

**Save these values - you'll need them!**

---

## Phase 2: Navigate AWS Console & Take Screenshots

### Screenshots to Take (Create a `screenshots/` folder)

```
screenshots/
├── 01-VPC-Dashboard.png
├── 02-VPC-Details.png
├── 03-Subnets.png
├── 04-Security-Groups.png
├── 05-EKS-Clusters.png
├── 06-EKS-Cluster-Details.png
├── 07-EKS-Nodes.png
├── 08-RDS-Databases.png
├── 09-RDS-Database-Details.png
├── 10-RDS-Endpoint.png
├── 11-S3-Buckets.png
├── 12-S3-Bucket-Details.png
├── 13-CloudFormation-Stacks.png
└── 14-Resource-Summary.png
```

---

## Screenshot 1: VPC Dashboard

**Location:** AWS Console → VPC → Virtual Private Clouds

**What to Show:**
```
✓ VPC name: devops-lab-vpc
✓ VPC ID: vpc-xxxxxxxxx
✓ CIDR block: 10.0.0.0/16
✓ State: Available
```

**Steps:**
1. Go to: https://console.aws.amazon.com/vpc/
2. Click: "Virtual Private Clouds" in left menu
3. Search for: "devops-lab"
4. Take screenshot showing the VPC in the list

**Screenshot Content Should Show:**
- VPC ID starting with `vpc-`
- CIDR Block: `10.0.0.0/16`
- "Available" status in green

---

## Screenshot 2: Subnets

**Location:** AWS Console → VPC → Subnets

**What to Show:**
```
✓ 2 Public Subnets (10.0.1.0/24, 10.0.2.0/24)
✓ 2 Private Subnets (10.0.10.0/24, 10.0.11.0/24)
✓ All in devops-lab-vpc
```

**Steps:**
1. Go to: https://console.aws.amazon.com/vpc/
2. Click: "Subnets" in left menu
3. Filter by VPC: "devops-lab"
4. Take screenshot showing all 4 subnets

**Screenshot Should Show:**
- Subnet names with CIDR blocks
- Associated VPC ID
- Availability Zone (a, b, c)
- Routes (public/private)

---

## Screenshot 3: Security Groups

**Location:** AWS Console → EC2 → Security Groups

**What to Show:**
```
✓ devops-lab-eks-control-plane-sg
✓ devops-lab-eks-worker-nodes-sg
✓ devops-lab-rds-sg
✓ devops-lab-alb-sg
```

**Steps:**
1. Go to: https://console.aws.amazon.com/ec2/
2. Click: "Security Groups" in left menu
3. Filter by VPC: "devops-lab"
4. Take screenshot showing all security groups

**Click on RDS Security Group to Show Inbound Rules:**
- Protocol: TCP
- Port: 5432
- Source: devops-lab-eks-worker-nodes-sg (CIDR)

---

## Screenshot 4: EKS Clusters

**Location:** AWS Console → EKS → Clusters

**What to Show:**
```
✓ Cluster name: devops-lab
✓ Status: ACTIVE
✓ Kubernetes version: 1.28
✓ Endpoint: https://abc123.eks.us-east-1.amazonaws.com
```

**Steps:**
1. Go to: https://console.aws.amazon.com/eks/
2. Click: "Clusters" in left menu
3. Click on: "devops-lab"
4. Take screenshot of cluster overview page

**Screenshot Should Show:**
- Cluster Status: ACTIVE (green)
- Kubernetes Version: 1.28
- Cluster ARN
- API Server Endpoint
- Created time and Platform Version

---

## Screenshot 5: EKS Nodes

**Location:** AWS Console → EKS → Clusters → devops-lab → Compute

**What to Show:**
```
✓ Node Group: devops-lab-node-group
✓ Status: ACTIVE
✓ Nodes: 2 (in Ready state)
✓ Instance Type: t3.medium
✓ Min/Max: 2/4
```

**Steps:**
1. In EKS Cluster page, scroll down to "Node groups"
2. Click on: "devops-lab-node-group"
3. Take screenshot showing node group details

**Then Click Tab: "Nodes"**
4. Take another screenshot showing the 2 running nodes

**Screenshot Should Show:**
- Node Group Status: ACTIVE
- 2 Nodes listed
- Each node with Instance ID (i-xxxxxxxxx)
- Instance Type: t3.medium
- Health Status: OK

---

## Screenshot 6: RDS Database

**Location:** AWS Console → RDS → Databases

**What to Show:**
```
✓ Database: devops-lab-db
✓ Engine: PostgreSQL 15.4
✓ Status: Available
✓ Multi-AZ: No
✓ Storage: 20 GB
```

**Steps:**
1. Go to: https://console.aws.amazon.com/rds/
2. Click: "Databases" in left menu
3. Click on: "devops-lab-db"
4. Take screenshot of database overview

**Screenshot Should Show:**
- DB Identifier: devops-lab-db
- Status: Available (green)
- Engine: PostgreSQL 15.4
- DB Instance Class: db.t3.micro
- Allocated Storage: 20 GiB

---

## Screenshot 7: RDS Endpoint & Connection

**Location:** AWS Console → RDS → Databases → devops-lab-db → Connectivity & Security

**What to Show:**
```
✓ Writer Endpoint: devops-lab-db.c9d8e7f6g5h4.us-east-1.rds.amazonaws.com
✓ Port: 5432
✓ DB Name: devopsdb
✓ Master Username: dbadmin
```

**Steps:**
1. In RDS Database page, scroll to "Connectivity & security" section
2. Take screenshot showing:
   - Endpoint (the full hostname)
   - Port (5432)
   - Publicly accessible: No (secure!)

**This is Critical Info - Save it!**

---

## Screenshot 8: S3 Bucket

**Location:** AWS Console → S3 → Buckets

**What to Show:**
```
✓ Bucket: devops-lab-app-data-123456789012
✓ Region: us-east-1
✓ Creation Date: Today
```

**Steps:**
1. Go to: https://console.aws.amazon.com/s3/
2. Look for bucket starting with: "devops-lab-app-data"
3. Take screenshot of bucket in the list

**Then Click on the Bucket**
4. Take screenshot of bucket properties showing:
   - Versioning: Enabled
   - Default Encryption: Enabled
   - Block Public Access: All enabled

---

## Screenshot 9: CloudFormation Stacks

**Location:** AWS Console → CloudFormation → Stacks

**What to Show:**
```
✓ Stack created by Terraform for EKS
✓ Status: CREATE_COMPLETE
✓ Resources: 60+
```

**Steps:**
1. Go to: https://console.aws.amazon.com/cloudformation/
2. Look for stack named: "eks-"
3. Take screenshot showing stack status

**Then View Stack Resources:**
1. Click on stack
2. Click "Resources" tab
3. Take screenshot showing all created resources

---

## Phase 3: Configure kubectl & Verify Cluster

### Step 1: Configure kubectl

```bash
# Use the configure_kubectl output from terraform
aws eks update-kubeconfig --name devops-lab --region us-east-1

# Output:
# Added new context arn:aws:eks:us-east-1:123456789012:cluster/devops-lab to /Users/user/.kube/config
```

### Step 2: Verify Cluster Connection

```bash
# Get nodes
kubectl get nodes

# Output:
# NAME                                      STATUS   ROLES    AGE   VERSION
# ip-10-0-10-5.ec2.internal                Ready    <none>   5m    v1.28.x
# ip-10-0-11-8.ec2.internal                Ready    <none>   5m    v1.28.x
```

**Take screenshot of this output!**

### Step 3: Get Cluster Info

```bash
# Detailed cluster information
kubectl cluster-info

# Output:
# Kubernetes control plane is running at https://abc123.eks.us-east-1.amazonaws.com
# CoreDNS is running at https://abc123.eks.us-east-1.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

**Take screenshot of this output!**

---

## Phase 4: Create Documentation

### Create File: `TERRAFORM_DEPLOYMENT_PROOF.md`

```markdown
# Terraform Deployment Proof - Step 2

## Deployment Summary

**Date:** December 13, 2025
**Region:** us-east-1
**Duration:** 18 minutes

## Resources Deployed

### VPC & Networking
- VPC: vpc-xxxxxxxxx (10.0.0.0/16)
- Public Subnets: 2 (10.0.1.0/24, 10.0.2.0/24)
- Private Subnets: 2 (10.0.10.0/24, 10.0.11.0/24)
- NAT Gateways: 2
- Internet Gateway: 1

### EKS Kubernetes
- Cluster Name: devops-lab
- Kubernetes Version: 1.28
- Endpoint: https://abc123.eks.us-east-1.amazonaws.com
- Node Group: devops-lab-node-group
- Worker Nodes: 2x t3.medium
- Min/Max Nodes: 2/4

### RDS Database
- Database: devops-lab-db
- Engine: PostgreSQL 15.4
- Endpoint: devops-lab-db.c9d8e7f6g5h4.us-east-1.rds.amazonaws.com
- Port: 5432
- Database Name: devopsdb
- Instance Class: db.t3.micro
- Storage: 20 GB

### S3 Storage
- Bucket: devops-lab-app-data-123456789012
- Region: us-east-1
- Versioning: Enabled
- Encryption: AES256

## Terraform Outputs

[Copy terraform output here]

## AWS Console Screenshots

See screenshots/ folder:
1. VPC Dashboard
2. Subnets
3. Security Groups
4. EKS Cluster
5. EKS Nodes
6. RDS Database
7. RDS Endpoint
8. S3 Bucket
9. CloudFormation Stack

## Verification Results

✓ kubectl get nodes
- 2 nodes in Ready state

✓ kubectl cluster-info
- Control plane accessible

✓ AWS CLI Verification
- All resources accessible

## Cleanup Command

To destroy all resources:
```bash
cd infra
terraform destroy
```
```

---

## Phase 5: Organize Screenshots

### Create Folder Structure

```powershell
# Create screenshots directory
mkdir screenshots

# Create subdirectories
mkdir screenshots\01-VPC
mkdir screenshots\02-EKS
mkdir screenshots\03-RDS
mkdir screenshots\04-S3
```

### Take Organized Screenshots

**VPC Screenshots (01-VPC/):**
1. VPC-Dashboard.png - VPC in list
2. VPC-Details.png - VPC details page
3. Subnets.png - All 4 subnets
4. Security-Groups.png - All 4 SGs

**EKS Screenshots (02-EKS/):**
1. EKS-Cluster-List.png - devops-lab in list
2. EKS-Cluster-Details.png - Cluster overview
3. EKS-Node-Group.png - Node group details
4. EKS-Nodes.png - 2 running nodes

**RDS Screenshots (03-RDS/):**
1. RDS-Databases-List.png - devops-lab-db in list
2. RDS-Database-Details.png - Database overview
3. RDS-Endpoint.png - Connectivity & security section
4. RDS-Backups.png - Backup configuration

**S3 Screenshots (04-S3/):**
1. S3-Buckets-List.png - devops-lab bucket in list
2. S3-Bucket-Properties.png - Versioning & encryption
3. S3-Bucket-Policy.png - Bucket policy

---

## How to Take Screenshots on Windows

### Method 1: Windows Built-in
```
Press: Win + Shift + S
- Select area to capture
- Saves to clipboard
- Paste into image editor
```

### Method 2: Snipping Tool
```
Search: "Snipping Tool"
Click: "New"
Select area, then "Save"
```

### Method 3: PowerShell Script
```powershell
# Save as take-screenshot.ps1
Add-Type -AssemblyName System.Windows.Forms
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bitmap = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)
$bitmap.Save("screenshot_$(Get-Date -Format 'yyyyMMdd_HHmmss').png")
```

---

## Quick Checklist for Screenshots

```
✓ VPC Dashboard
  □ VPC visible in list
  □ VPC ID starts with vpc-
  □ CIDR: 10.0.0.0/16

✓ Subnets Page
  □ 4 subnets showing
  □ 2 public (10.0.1/2)
  □ 2 private (10.0.10/11)

✓ Security Groups
  □ 4 security groups visible
  □ Names start with devops-lab

✓ EKS Cluster
  □ Status: ACTIVE
  □ Version: 1.28
  □ Endpoint visible

✓ EKS Nodes
  □ 2 nodes in Ready state
  □ Instance type: t3.medium

✓ RDS Database
  □ Status: Available
  □ Engine: PostgreSQL 15.4
  □ Endpoint visible

✓ S3 Bucket
  □ Bucket name starts with devops-lab-app-data
  □ Versioning: Enabled
  □ Encryption: Enabled
```

---

## Summary Document Template

Create file: `STEP2_DEPLOYMENT_COMPLETE.md`

```markdown
# Step 2: Terraform Infrastructure Provisioning - COMPLETE ✅

## Deployment Execution

**Start Time:** [time]
**End Time:** [time]
**Duration:** 18 minutes
**Status:** SUCCESS ✅

## Resources Created

### VPC
[Paste terraform output for VPC]

### EKS
[Paste terraform output for EKS]

### RDS
[Paste terraform output for RDS]

### S3
[Paste terraform output for S3]

## Screenshots Captured

### VPC Resources
- [01-VPC-Dashboard.png] - VPC created with correct CIDR
- [02-Subnets.png] - 4 subnets in 2 AZs
- [03-Security-Groups.png] - 4 security groups configured

### Kubernetes Resources  
- [04-EKS-Cluster.png] - Cluster ACTIVE status
- [05-EKS-Nodes.png] - 2 worker nodes READY

### Database Resources
- [06-RDS-Database.png] - PostgreSQL 15.4 AVAILABLE
- [07-RDS-Endpoint.png] - Connection endpoint ready

### Storage Resources
- [08-S3-Bucket.png] - Bucket created with encryption

## Verification Tests

```bash
# Kubectl connectivity
kubectl get nodes
✓ PASSED - 2 nodes ready

# Cluster info
kubectl cluster-info
✓ PASSED - Control plane accessible

# AWS CLI verification
aws eks describe-cluster --name devops-lab
✓ PASSED - Cluster found and active
```

## Next Steps

→ Step 3: Configuration Management with Ansible
→ Step 4: Kubernetes Deployment
→ Step 5: CI/CD Pipeline

## Notes

[Add any issues encountered and how they were resolved]
```

---

## Important: Save Everything!

```powershell
# Create summary folder
mkdir deployment-step2

# Copy everything
copy TERRAFORM_DEPLOYMENT_PROOF.md deployment-step2/
copy TERRAFORM_OUTPUTS_GUIDE.md deployment-step2/
copy infra/terraform.tfvars deployment-step2/
copy screenshots/* deployment-step2/screenshots/
copy terraform-outputs.txt deployment-step2/
```

---

## Troubleshooting Screenshots

**If you don't see resources in AWS Console:**

```bash
# 1. Wait - EKS takes 15-20 minutes
# 2. Refresh browser (F5)
# 3. Check correct region: us-east-1
# 4. Verify Terraform apply completed successfully

terraform show | grep "Create complete"
```

**If nodes show as NotReady:**

```bash
# Wait 3-5 minutes for nodes to initialize
kubectl get nodes --watch

# Check node status
kubectl describe node <node-name>
```

**If RDS endpoint not visible:**

```bash
# Terraform might still be creating it
terraform show | grep rds

# Wait 3-5 minutes
```

---

**You're now ready to take AWS Console screenshots for documentation!** 📸

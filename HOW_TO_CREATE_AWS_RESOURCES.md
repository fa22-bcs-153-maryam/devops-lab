# 🚀 How to Create AWS Resources & Take Screenshots - COMPLETE GUIDE

## Quick Start (3 Steps)

### Step 1: Deploy Infrastructure
```powershell
cd infra
terraform init
terraform plan -out=tfplan
terraform apply tfplan
# Wait 18-20 minutes ⏳
```

### Step 2: Save Outputs
```powershell
terraform output > terraform-outputs.txt
aws eks update-kubeconfig --name devops-lab --region us-east-1
```

### Step 3: Take Screenshots
- Visit AWS Console (links below)
- Press Win+Shift+S to screenshot
- Save to `screenshots/` folder

---

## Detailed Walkthrough

### Prerequisites Check

```powershell
# 1. Check AWS CLI
aws --version
# Output: aws-cli/2.x.x...

# 2. Check Terraform  
terraform --version
# Output: Terraform v1.x.x...

# 3. Verify AWS Credentials
aws sts get-caller-identity
# Output: {Account: 123456789012, Arn: arn:aws:iam::..., UserId: AID...}
```

**If any command fails:**
- AWS CLI: Download from https://aws.amazon.com/cli/
- Terraform: Download from https://www.terraform.io/downloads.html
- AWS Credentials: Run `aws configure`

---

## Deployment Timeline

```
Total Time: ~18-20 minutes

0:00  │ START: terraform apply tfplan
      │
0:02  │ ✓ VPC created (10.0.0.0/16)
      │ ✓ Subnets created (4 subnets)
      │ ✓ Internet Gateway created
      │
0:05  │ ✓ NAT Gateways created (2)
      │ ✓ Security Groups created (4)
      │ ✓ Route Tables created
      │
0:08  │ ⏳ EKS Cluster creation starting...
      │    (This takes 10-12 minutes - LONGEST STEP)
      │
8:00  │ 🕐 Go make coffee! ☕
      │
15:00 │ ✓ EKS Cluster created
      │ ✓ EKS Node Group starting...
      │ ⏳ RDS Database creation starting...
      │
18:00 │ ✓ RDS Database created
      │ ✓ EKS Nodes created and starting...
      │
20:00 │ ✓ COMPLETE - All 63 resources created
      │   terraform output shows values
      │
```

---

## Step-by-Step Terraform Commands

### Command 1: Navigate to Infrastructure Folder

```powershell
cd c:\Users\Dell\Documents\FinalLab1\devops-lab\infra
ls  # Verify you see: provider.tf, vpc.tf, eks.tf, rds.tf, s3.tf, etc.
```

### Command 2: Initialize Terraform

```powershell
terraform init
```

**Output should show:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!

The following providers are required by this configuration, and are installed on this machine:
  - aws (~> 5.0)
```

✓ Check that `.terraform` folder was created

### Command 3: Validate Configuration

```powershell
terraform validate
```

**Output should show:**
```
Success! The configuration is valid.
```

### Command 4: Plan Deployment (Preview What Will Be Created)

```powershell
terraform plan -out=tfplan
```

**Output should show:**
```
aws_vpc.main will be created
aws_subnet.public[0] will be created
aws_subnet.public[1] will be created
aws_subnet.private[0] will be created
aws_subnet.private[1] will be created
aws_internet_gateway.main will be created
aws_eip.nat[0] will be created
aws_eip.nat[1] will be created
aws_nat_gateway.nat[0] will be created
aws_nat_gateway.nat[1] will be created
aws_security_group.eks_control_plane will be created
aws_security_group.eks_worker_nodes will be created
aws_security_group.rds will be created
aws_security_group.alb will be created
aws_iam_role.eks_cluster_role will be created
aws_eks_cluster.main will be created
aws_iam_role.eks_node_role will be created
aws_eks_node_group.main will be created
aws_db_subnet_group.main will be created
aws_db_instance.main will be created
aws_s3_bucket.main will be created
aws_s3_bucket_versioning.main will be created
aws_s3_bucket_server_side_encryption_configuration.main will be created
... and more

Plan: 63 to add, 0 to change, 0 to destroy.

Saved the plan to: tfplan
```

✓ Check that `tfplan` file was created

### Command 5: Deploy to AWS (⚠️ This Creates Real AWS Resources!)

```powershell
terraform apply tfplan
```

**After a few seconds, you'll see:**
```
aws_vpc.main: Creating...
aws_internet_gateway.main: Creating...
aws_eip.nat[0]: Creating...
aws_iam_role.eks_cluster_role: Creating...
aws_iam_role.eks_node_role: Creating...
aws_security_group.eks_control_plane: Creating...
...
```

**After 15-20 minutes, you'll see:**
```
Apply complete! Resources: 63 added, 0 changed, 0 destroyed.
```

✓ Deployment successful!

### Command 6: Extract Output Values

```powershell
terraform output
```

**You'll see values like:**
```
aws_account_id = "123456789012"
aws_region = "us-east-1"
cluster_endpoint = "https://abc123.eks.us-east-1.amazonaws.com"
cluster_name = "devops-lab"
configure_kubectl = "aws eks update-kubeconfig --name devops-lab --region us-east-1"
db_endpoint = "devops-lab-db.c9d8e7f6g5h4.us-east-1.rds.amazonaws.com"
db_port = 5432
rds_db_name = "devopsdb"
rds_master_username = "dbadmin"
s3_bucket_name = "devops-lab-app-data-123456789012"
vpc_id = "vpc-0a1b2c3d4e5f"
vpc_cidr = "10.0.0.0/16"
public_subnet_ids = ["subnet-xxxxxxx", "subnet-yyyyyyy"]
private_subnet_ids = ["subnet-zzzzzzz", "subnet-wwwwwww"]
```

**Save these values:**
```powershell
terraform output > terraform-outputs.txt
```

### Command 7: Configure kubectl

```powershell
# Copy the "configure_kubectl" value from above and run it:
aws eks update-kubeconfig --name devops-lab --region us-east-1
```

**Output:**
```
Added new context arn:aws:eks:us-east-1:123456789012:cluster/devops-lab to C:\Users\Dell\.kube\config
```

### Command 8: Verify Kubernetes Connection

```powershell
# Test 1: Get nodes
kubectl get nodes

# Test 2: Cluster info
kubectl cluster-info

# Test 3: Get all pods
kubectl get pods -A
```

---

## AWS Console Screenshot Locations

### Screenshot 1: VPC Dashboard

```
URL: https://console.aws.amazon.com/vpc/

Steps:
1. Click "Virtual Private Clouds" in left menu
2. Look for "devops-lab-vpc" in the table
3. Take screenshot showing:
   ✓ VPC ID: vpc-xxxxxxx
   ✓ CIDR Block: 10.0.0.0/16
   ✓ State: Available
```

**Pro Tip:** Search for "devops-lab" in the search box

---

### Screenshot 2: Subnets

```
URL: https://console.aws.amazon.com/vpc/

Steps:
1. Click "Subnets" in left menu
2. Filter by VPC ID: devops-lab-vpc
3. Take screenshot showing all 4 subnets:
   ✓ Subnet 1: 10.0.1.0/24 (Public, AZ-a)
   ✓ Subnet 2: 10.0.2.0/24 (Public, AZ-b)
   ✓ Subnet 3: 10.0.10.0/24 (Private, AZ-a)
   ✓ Subnet 4: 10.0.11.0/24 (Private, AZ-b)
```

---

### Screenshot 3: Security Groups

```
URL: https://console.aws.amazon.com/ec2/

Steps:
1. Click "Security Groups" in left menu
2. Filter by VPC: devops-lab-vpc
3. Take screenshot showing 4 security groups:
   ✓ devops-lab-eks-control-plane-sg
   ✓ devops-lab-eks-worker-nodes-sg
   ✓ devops-lab-rds-sg
   ✓ devops-lab-alb-sg
```

**Optional:** Click on "devops-lab-rds-sg" to show inbound rules:
```
Type: PostgreSQL (TCP 5432)
Source: devops-lab-eks-worker-nodes-sg
```

---

### Screenshot 4: EKS Cluster

```
URL: https://console.aws.amazon.com/eks/

Steps:
1. Click "Clusters" in left menu
2. Click on "devops-lab"
3. Take screenshot showing:
   ✓ Cluster Name: devops-lab
   ✓ Status: ACTIVE (green)
   ✓ Kubernetes Version: 1.28
   ✓ Cluster ARN: arn:aws:eks:...
   ✓ API Server Endpoint: https://abc123.eks.us-east-1.amazonaws.com
   ✓ Platform Version: eks.1
   ✓ Created: Date and Time
```

---

### Screenshot 5: EKS Worker Nodes

```
URL: https://console.aws.amazon.com/eks/

Steps:
1. In EKS Cluster page (from previous screenshot)
2. Scroll down to "Node groups"
3. Click on "devops-lab-node-group"
4. Click "Nodes" tab
5. Take screenshot showing:
   ✓ 2 Nodes listed (i-xxxxxxxx, i-yyyyyyyy)
   ✓ Instance Type: t3.medium
   ✓ Status: Ready ✓
   ✓ Health Status: OK
   ✓ Private IP addresses
   ✓ Launch template
```

---

### Screenshot 6: RDS Database

```
URL: https://console.aws.amazon.com/rds/

Steps:
1. Click "Databases" in left menu
2. Click on "devops-lab-db"
3. Take screenshot showing:
   ✓ DB Identifier: devops-lab-db
   ✓ Status: Available (green)
   ✓ Engine: PostgreSQL
   ✓ Engine Version: 15.4
   ✓ DB Instance Class: db.t3.micro
   ✓ Allocated Storage: 20 GiB
   ✓ Master Username: dbadmin
   ✓ Multi-AZ: No
   ✓ Created: Date
```

---

### Screenshot 7: RDS Endpoint

```
URL: https://console.aws.amazon.com/rds/

Steps:
1. In RDS Database page
2. Scroll to "Connectivity & security" section
3. Take screenshot showing:
   ✓ Writer Endpoint: devops-lab-db.c9d8e7f6g5h4.us-east-1.rds.amazonaws.com
   ✓ Port: 5432
   ✓ Publicly Accessible: No
   ✓ Security Groups: devops-lab-rds-sg
   ✓ Subnet Group: devops-lab

IMPORTANT: Copy this endpoint - you'll need it for Step 3 & 4
```

---

### Screenshot 8: S3 Bucket

```
URL: https://console.aws.amazon.com/s3/

Steps:
1. Look for bucket starting with "devops-lab-app-data-"
2. Click on the bucket name
3. Take screenshot showing:
   ✓ Bucket Name: devops-lab-app-data-123456789012
   ✓ Region: us-east-1
   ✓ Creation Date: Today
   ✓ Objects: (may be empty)
```

---

### Screenshot 9: S3 Properties

```
URL: https://console.aws.amazon.com/s3/

Steps:
1. In S3 Bucket page
2. Click "Properties" tab
3. Scroll to "Versioning"
4. Take screenshot showing:
   ✓ Versioning: Enabled
5. Scroll to "Default encryption"
6. Take screenshot showing:
   ✓ Server-side encryption: Enabled
   ✓ Encryption type: Amazon S3-managed keys (SSE-S3)
```

---

## How to Take Screenshots on Windows

### Method 1: Windows Built-in (Easiest)

```
1. Press: Win + Shift + S
2. Select the area on screen you want to capture
3. Screenshot appears in clipboard
4. Click notification to open in Snip & Sketch
5. Click "Save" button
6. Choose location and filename
```

**Pro Tip:** Paste directly into Word or Paint using Ctrl+V

### Method 2: Snipping Tool (If Win+Shift+S doesn't work)

```
1. Search for "Snipping Tool"
2. Click "New"
3. Select area to capture
4. Click "Save" icon
5. Choose location and name
```

### Method 3: PowerShell Script

```powershell
# Save as: Screenshot.ps1
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Screen]::PrimaryScreen | ForEach-Object {
    $bitmap = New-Object System.Drawing.Bitmap($_.Bounds.Width, $_.Bounds.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($_.Bounds.Location, [System.Drawing.Point]::Empty, $_.Bounds.Size)
    $bitmap.Save("Screenshot_$(Get-Date -Format 'yyyyMMdd_HHmmss').png")
}
```

---

## Organizing Screenshots

### Create Folder Structure

```powershell
mkdir screenshots
mkdir screenshots\VPC
mkdir screenshots\EKS
mkdir screenshots\RDS
mkdir screenshots\S3
```

### Save Screenshots

```
screenshots/
├── VPC/
│   ├── 01-VPC-Dashboard.png
│   ├── 02-Subnets.png
│   └── 03-Security-Groups.png
├── EKS/
│   ├── 04-EKS-Cluster.png
│   ├── 05-EKS-Cluster-Details.png
│   └── 06-EKS-Nodes.png
├── RDS/
│   ├── 07-RDS-Database.png
│   ├── 08-RDS-Details.png
│   └── 09-RDS-Endpoint.png
└── S3/
    ├── 10-S3-Bucket.png
    └── 11-S3-Properties.png
```

---

## Create Summary Document

Create file: `AWS_DEPLOYMENT_PROOF.md`

```markdown
# AWS Deployment - Proof of Resources Created

## Deployment Information

**Date Deployed:** [Your Date]
**Account ID:** [From terraform output]
**Region:** us-east-1
**Deployment Time:** 18-20 minutes
**Status:** ✅ SUCCESS

## Infrastructure Summary

### VPC Networking
- VPC ID: [paste from terraform output]
- CIDR Block: 10.0.0.0/16
- Public Subnets: 2
- Private Subnets: 2
- NAT Gateways: 2
- Internet Gateway: 1

### EKS Kubernetes
- Cluster Name: devops-lab
- Cluster Endpoint: [paste from terraform output]
- Kubernetes Version: 1.28
- Node Group: devops-lab-node-group
- Worker Nodes: 2 (t3.medium)
- Auto Scaling: Min=2, Max=4

### RDS Database
- Database Name: devopsdb
- Engine: PostgreSQL 15.4
- Endpoint: [paste from terraform output]
- Instance Type: db.t3.micro
- Storage: 20 GB
- Port: 5432

### S3 Storage
- Bucket Name: [paste from terraform output]
- Region: us-east-1
- Versioning: ✓ Enabled
- Encryption: ✓ Enabled

## Screenshots Evidence

- VPC Dashboard
- Subnets
- Security Groups
- EKS Cluster
- EKS Nodes
- RDS Database
- RDS Endpoint
- S3 Bucket
- S3 Properties

See screenshots/ folder for all images.

## Terraform Outputs

[Paste full terraform output here]

## Verification Commands

```bash
# Verify EKS Cluster
kubectl get nodes
kubectl cluster-info

# Verify RDS Connectivity
# (Will be tested in Step 3)

# Verify S3 Bucket
aws s3 ls
```

## Terraform State

Stored in: terraform.tfstate
Contains all resource details and relationships.
```

---

## Troubleshooting

### Problem: "terraform: command not found"
**Solution:**
```powershell
choco install terraform
# OR download from https://www.terraform.io/downloads.html
```

### Problem: AWS Credentials Not Found
**Solution:**
```powershell
aws configure
# Enter your Access Key, Secret Key, Region (us-east-1)
```

### Problem: "Error: InvalidUserID.NotFound"
**Solution:** Your AWS credentials might be wrong or expired
```powershell
aws sts get-caller-identity  # Check if credentials work
aws configure  # Re-enter credentials if needed
```

### Problem: Terraform Apply Takes Too Long
**Answer:** This is normal! EKS takes 10-12 minutes to create. Don't cancel!
```powershell
# Monitor progress in AWS Console:
# https://console.aws.amazon.com/cloudformation/
```

### Problem: Can't See Nodes in AWS Console
**Answer:** Nodes take 2-3 minutes to register. Wait and refresh.
```powershell
kubectl get nodes --watch  # Watch nodes come up
```

---

## Quick Reference Commands

```powershell
# Initialize
cd infra
terraform init

# Validate
terraform validate

# Plan
terraform plan -out=tfplan

# Apply (Deploy)
terraform apply tfplan

# View outputs
terraform output

# Save outputs
terraform output > terraform-outputs.txt

# Configure kubectl
aws eks update-kubeconfig --name devops-lab --region us-east-1

# Verify cluster
kubectl get nodes
kubectl cluster-info

# Destroy (if needed)
terraform destroy
```

---

## What's Next?

After taking screenshots:

✅ **Step 2: Complete**
- Infrastructure deployed to AWS
- Resources verified with screenshots
- Outputs documented

→ **Step 3:** Ansible Configuration Management
- Configure database connections
- Setup application configuration

→ **Step 4:** Kubernetes Deployment
- Deploy application to EKS
- Setup services and ingress

→ **Step 5:** CI/CD Pipeline
- Setup GitHub Actions
- Automate deployments

---

**You now have everything you need to create AWS resources and document them with screenshots!** 🎉

For detailed visual guides, see:
- [AWS_CONSOLE_SCREENSHOTS_GUIDE.md](AWS_CONSOLE_SCREENSHOTS_GUIDE.md)
- [TERRAFORM_DEPLOYMENT_QUICK_GUIDE.md](TERRAFORM_DEPLOYMENT_QUICK_GUIDE.md)
- [TERRAFORM_VISUAL_GUIDE.md](TERRAFORM_VISUAL_GUIDE.md)

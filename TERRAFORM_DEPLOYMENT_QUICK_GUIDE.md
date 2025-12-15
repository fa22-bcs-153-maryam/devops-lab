# Step 2: Terraform Deployment - Complete Checklist

## Phase 1: Pre-Deployment (5 minutes)

### Checklist

```
□ AWS Account created and verified
□ AWS CLI installed (check: aws --version)
□ AWS Credentials configured (check: aws sts get-caller-identity)
□ Terraform installed (check: terraform --version)
□ Navigate to infra folder (cd infra)
□ Review terraform.tfvars - confirm variables are correct
```

### Verify AWS Credentials

**Run in PowerShell:**

```powershell
aws sts get-caller-identity
```

**Expected Output:**
```json
{
    "UserId": "AIDxxxxxx",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-name"
}
```

✓ If you see Account number → You're ready!
✗ If error → Run `aws configure` first

---

## Phase 2: Terraform Init (2 minutes)

### Commands

```powershell
cd c:\Users\Dell\Documents\FinalLab1\devops-lab\infra

terraform init
```

### Expected Output
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

✓ Check: `.terraform` folder exists
✓ Check: `.terraform.lock.hcl` file created

---

## Phase 3: Terraform Validate (1 minute)

```powershell
terraform validate
```

### Expected Output
```
Success! The configuration is valid.
```

---

## Phase 4: Terraform Plan (5 minutes)

```powershell
terraform plan -out=tfplan
```

### Expected Output
```
Plan: 63 to add, 0 to change, 0 to destroy.
Saved the plan to: tfplan
```

**Review for:**
```
✓ aws_vpc.main: vpc
✓ aws_subnet.public: 2 subnets
✓ aws_subnet.private: 2 subnets
✓ aws_security_group: 4 security groups
✓ aws_eks_cluster.main: EKS cluster
✓ aws_eks_node_group.main: 2-4 nodes
✓ aws_db_instance.main: RDS database
✓ aws_s3_bucket: S3 bucket
```

---

## Phase 5: Terraform Apply (18-20 MINUTES) ⏰

### ⚠️ After This Point, AWS Costs Accumulate

```powershell
terraform apply tfplan
```

### Expected Timeline

```
0:00  - Run apply command
0:02  - VPC and networking created
0:03  - Security groups created
0:05  - EKS cluster starts creating ⏳
15:00 - EKS cluster created ✓
15:05 - RDS database starts creating
18:00 - All resources complete ✓

Apply complete! Resources: 63 added, 0 changed, 0 destroyed.
```

**While Waiting:**
- Monitor AWS Console: https://console.aws.amazon.com/cloudformation/
- Look for stack with "eks" in name
- Status should show "CREATE_IN_PROGRESS" → "CREATE_COMPLETE"

---

## Phase 6: Get Terraform Outputs (1 minute)

```powershell
terraform output

# Save to file
terraform output > terraform-outputs.txt

# Export as JSON
terraform output -json > terraform-outputs.json
```

### Critical Values to Save

```
AWS Account ID: _____________
VPC ID: _____________
EKS Cluster Name: devops-lab
EKS Endpoint: _____________
RDS Endpoint: _____________
RDS Port: 5432
RDS Username: dbadmin
RDS Database: devopsdb
S3 Bucket: _____________
```

---

## Phase 7: Configure kubectl (1 minute)

```powershell
aws eks update-kubeconfig --name devops-lab --region us-east-1
```

### Expected Output
```
Added new context arn:aws:eks:us-east-1:123456789012:cluster/devops-lab to C:\Users\Dell\.kube\config
```

---

## Phase 8: Verify Cluster (2 minutes)

### Test 1: Get Nodes

```powershell
kubectl get nodes
```

### Expected Output
```
NAME                                  STATUS   ROLES    AGE   VERSION
ip-10-0-10-123.ec2.internal          Ready    <none>   3m    v1.28.5
ip-10-0-11-456.ec2.internal          Ready    <none>   3m    v1.28.5
```

✓ Both nodes: `Ready` status

### Test 2: Cluster Info

```powershell
kubectl cluster-info
```

### Test 3: Get Pods

```powershell
kubectl get pods -A
```

✓ System pods running in kube-system namespace

---

## Phase 9: AWS Console Screenshots

Create `screenshots/` folder and capture:

### VPC Resources
```
https://console.aws.amazon.com/vpc/
→ Virtual Private Clouds
→ Search: devops-lab-vpc
[SCREENSHOT 1: VPC Dashboard]

→ Subnets
→ Filter by VPC: devops-lab
[SCREENSHOT 2: 4 Subnets (2 public, 2 private)]

→ Security Groups
→ Filter by VPC: devops-lab
[SCREENSHOT 3: 4 Security Groups]
```

### EKS Resources
```
https://console.aws.amazon.com/eks/
→ Clusters
→ Click: devops-lab
[SCREENSHOT 4: EKS Cluster Details (Status: ACTIVE)]

→ Scroll down to Node groups
→ Click: devops-lab-node-group
→ Click "Nodes" tab
[SCREENSHOT 5: 2 Worker Nodes (Ready status)]
```

### RDS Resources
```
https://console.aws.amazon.com/rds/
→ Databases
→ Click: devops-lab-db
[SCREENSHOT 6: RDS Database (Status: Available)]

→ Scroll to "Connectivity & security"
[SCREENSHOT 7: RDS Endpoint (copy for later use)]
```

### S3 Resources
```
https://console.aws.amazon.com/s3/
→ Look for: devops-lab-app-data-*
[SCREENSHOT 8: S3 Bucket in list]

→ Click on bucket
[SCREENSHOT 9: Bucket properties (Versioning: Enabled, Encryption: Enabled)]
```

---

## Phase 10: Create Summary Document

Create file: `TERRAFORM_DEPLOYMENT_COMPLETE.md`

```markdown
# Terraform Deployment - Step 2 Complete ✅

## Deployment Summary

**Date:** [Your Date]
**Duration:** ~18 minutes
**Status:** SUCCESS ✅

## Infrastructure Created

### VPC & Networking
- VPC ID: [paste from output]
- CIDR Block: 10.0.0.0/16
- Public Subnets: 2 (10.0.1.0/24, 10.0.2.0/24)
- Private Subnets: 2 (10.0.10.0/24, 10.0.11.0/24)
- NAT Gateways: 2
- Internet Gateway: 1

### EKS Kubernetes Cluster
- Cluster Name: devops-lab
- Kubernetes Version: 1.28
- Endpoint: [paste from output]
- Node Group: devops-lab-node-group
- Worker Nodes: 2x t3.medium
- Min/Max Nodes: 2/4
- Status: ACTIVE ✓

### RDS PostgreSQL Database
- Database Name: devopsdb
- Engine: PostgreSQL 15.4
- Instance Class: db.t3.micro
- Endpoint: [paste from output]
- Port: 5432
- Storage: 20 GB
- Status: Available ✓

### S3 Storage Bucket
- Bucket Name: [paste from output]
- Region: us-east-1
- Versioning: Enabled ✓
- Encryption: AES256 ✓
- Public Access: All Blocked ✓

### Security Groups (4 created)
- EKS Control Plane SG
- EKS Worker Nodes SG
- RDS Database SG (Port 5432)
- ALB Security Group

## Verification Results

### kubectl Tests
```
kubectl get nodes
✓ PASSED - 2 nodes in Ready state

kubectl cluster-info
✓ PASSED - Control plane accessible

kubectl get pods -A
✓ PASSED - System pods running
```

### AWS CLI Verification
```
aws eks describe-cluster --name devops-lab
✓ PASSED - Cluster found and active

aws rds describe-db-instances --db-instance-identifier devops-lab-db
✓ PASSED - Database accessible
```

## Screenshots Taken

```
screenshots/
├── 01-VPC-Dashboard.png
├── 02-Subnets.png
├── 03-Security-Groups.png
├── 04-EKS-Cluster.png
├── 05-EKS-Nodes.png
├── 06-RDS-Database.png
├── 07-RDS-Endpoint.png
├── 08-S3-Bucket.png
└── 09-S3-Properties.png
```

## Terraform Outputs
[Paste terraform output here]

## Cost Estimation

**Monthly AWS Costs (Approximate):**
- EKS Control Plane: $73/month
- EC2 Nodes (2x t3.medium): $60/month
- RDS Database (t3.micro): $30/month
- S3 Storage: <$5/month
- Data Transfer: <$5/month
- **Total: ~$170/month**

## Cleanup Command

To destroy all resources and stop costs:
```bash
cd infra
terraform destroy
```

## Next Steps

→ Step 3: Ansible Configuration Management
→ Step 4: Kubernetes Deployment on EKS
→ Step 5: CI/CD Pipeline with GitHub Actions
```

---

## Troubleshooting Guide

### Issue: "aws: command not found"
**Solution:**
```powershell
# Install AWS CLI
choco install awscli
# OR Download: https://aws.amazon.com/cli/
```

### Issue: "terraform: command not found"
**Solution:**
```powershell
# Install Terraform
choco install terraform
# OR Download: https://www.terraform.io/downloads.html
```

### Issue: AWS Credentials Error
**Solution:**
```powershell
aws configure
# Enter your:
# AWS Access Key ID
# AWS Secret Access Key
# Default region: us-east-1
# Default output format: json
```

### Issue: EKS Nodes Not Ready
**Solution:**
```powershell
# Wait 5 minutes - nodes initialize slowly
# Check status:
kubectl describe node <node-name>

# Check for errors:
kubectl logs -n kube-system <pod-name>
```

### Issue: terraform apply takes too long (>20 min)
**Solution:**
```powershell
# Don't cancel - EKS creation takes time
# Monitor progress:
terraform show

# OR check AWS CloudFormation:
# https://console.aws.amazon.com/cloudformation/
```

### Issue: "Error: error reading S3 Bucket Versioning"
**Solution:**
```powershell
# S3 bucket not fully created yet
# Wait 1 minute and re-run:
terraform apply tfplan
```

---

## Windows Screenshot Tips

### Built-in Method (Easiest)
```
Press: Win + Shift + S
- Select area to capture
- Image saved to clipboard
- Paste into folder or Paint
```

### Snipping Tool
```
Search: "Snipping Tool"
Click: "New"
Select area → "Save"
```

### PowerShell Script
```powershell
# Save as: screenshot.ps1
Add-Type -AssemblyName System.Windows.Forms
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bitmap = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)
$bitmap.Save("screenshot_$(Get-Date -Format 'yyyyMMdd_HHmmss').png")
```

---

## Quick Check List

```
Pre-Deployment:
□ AWS account set up
□ AWS CLI configured
□ Terraform installed
□ In infra/ folder

Deployment:
□ terraform init - SUCCESS
□ terraform validate - SUCCESS
□ terraform plan - Shows ~63 resources
□ terraform apply - COMPLETED (18-20 min)

Verification:
□ terraform output shows values
□ kubectl configured successfully
□ kubectl get nodes shows 2 Ready nodes
□ kubectl cluster-info accessible

AWS Console:
□ VPC created (vpc-xxxxxxx)
□ 4 Subnets visible
□ 4 Security Groups visible
□ EKS Cluster status: ACTIVE
□ 2 Worker Nodes visible
□ RDS Database status: Available
□ S3 Bucket created with encryption

Documentation:
□ terraform-outputs.txt saved
□ Screenshots captured (9 images)
□ TERRAFORM_DEPLOYMENT_COMPLETE.md created
□ Summary document complete
```

---

**Follow this checklist step by step. You're now ready to deploy Terraform to AWS!** 🚀

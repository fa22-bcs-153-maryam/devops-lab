# Terraform Deployment - Copy & Paste Commands

## Execute These Commands in Order

### Step 1: Verify Prerequisites

Open PowerShell and run:

```powershell
# Check AWS CLI
aws --version

# Check Terraform
terraform --version

# Verify AWS Credentials
aws sts get-caller-identity
```

**Expected Output for Step 3:**
```json
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-name"
}
```

✓ If Account ID shows → Continue to Step 2
✗ If error → Run `aws configure` first

---

### Step 2: Navigate to Infrastructure Folder

```powershell
cd c:\Users\Dell\Documents\FinalLab1\devops-lab\infra
```

**Verify you're in the right location:**
```powershell
ls
```

**You should see:**
```
provider.tf
variables.tf
vpc.tf
security_groups.tf
eks.tf
rds.tf
s3.tf
outputs.tf
terraform.tfvars
backend.tf
```

---

### Step 3: Initialize Terraform

```powershell
terraform init
```

**Wait for completion. You should see:**
```
Initializing the backend...
Initializing provider plugins...
...
Terraform has been successfully initialized!
```

✓ Check that `.terraform` folder was created

---

### Step 4: Validate Configuration

```powershell
terraform validate
```

**Expected Output:**
```
Success! The configuration is valid.
```

✗ If error → Review error message and check *.tf files

---

### Step 5: Plan Deployment

```powershell
terraform plan -out=tfplan
```

**Expected Output:**
```
Plan: 63 to add, 0 to change, 0 to destroy.
Saved the plan to: tfplan
```

**Review the plan to ensure it's creating:**
- 1 VPC
- 4 Subnets
- 4 Security Groups
- 1 EKS Cluster
- 1 Node Group (2-4 nodes)
- 1 RDS Database
- 1 S3 Bucket

---

### Step 6: Deploy to AWS (⚠️ Real Resources Created Here!)

```powershell
terraform apply tfplan
```

**This will start creating resources. You'll see:**
```
aws_vpc.main: Creating...
aws_security_group.eks_control_plane: Creating...
aws_db_subnet_group.main: Creating...
...
```

**⏱️ WAIT 18-20 MINUTES for completion**

**Final output:**
```
Apply complete! Resources: 63 added, 0 changed, 0 destroyed.
```

✅ Deployment successful!

---

### Step 7: Get Outputs

```powershell
terraform output
```

**You'll see values like:**
```
aws_account_id = "123456789012"
cluster_endpoint = "https://abc123.eks.us-east-1.amazonaws.com"
db_endpoint = "devops-lab-db.c9d8e7f6g5h4.us-east-1.rds.amazonaws.com"
s3_bucket_name = "devops-lab-app-data-123456789012"
vpc_id = "vpc-0a1b2c3d4e5f"
```

---

### Step 8: Save Outputs to File

```powershell
terraform output > terraform-outputs.txt
```

**Verify file was created:**
```powershell
type terraform-outputs.txt
```

---

### Step 9: Configure kubectl

Copy the `configure_kubectl` value from outputs and run it:

```powershell
aws eks update-kubeconfig --name devops-lab --region us-east-1
```

**Expected Output:**
```
Added new context arn:aws:eks:us-east-1:123456789012:cluster/devops-lab to C:\Users\Dell\.kube\config
```

---

### Step 10: Verify Kubernetes Cluster

```powershell
# Test 1: Get nodes
kubectl get nodes
```

**Expected Output:**
```
NAME                                      STATUS   ROLES    AGE   VERSION
ip-10-0-10-123.ec2.internal              Ready    <none>   3m    v1.28.5
ip-10-0-11-456.ec2.internal              Ready    <none>   3m    v1.28.5
```

✓ Both nodes show `Ready` status

---

### Step 11: Get Cluster Info

```powershell
kubectl cluster-info
```

**Expected Output:**
```
Kubernetes control plane is running at https://abc123.eks.us-east-1.amazonaws.com
CoreDNS is running at https://abc123.eks.us-east-1.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

---

### Step 12: Get System Pods

```powershell
kubectl get pods -A
```

**Expected Output shows pods in kube-system namespace running**

---

## Now Take Screenshots

### Screenshot 1: VPC

Open browser and go to:
```
https://console.aws.amazon.com/vpc/
```

1. Click "Virtual Private Clouds" in left menu
2. Search for "devops-lab"
3. **Press Win+Shift+S** to take screenshot
4. Save as `VPC_Dashboard.png`

---

### Screenshot 2: Subnets

In same VPC page:
1. Click "Subnets" in left menu
2. Filter by VPC: devops-lab-vpc
3. **Press Win+Shift+S** to screenshot
4. Save as `Subnets.png`

---

### Screenshot 3: Security Groups

In EC2 page:
```
https://console.aws.amazon.com/ec2/
```

1. Click "Security Groups" in left menu
2. Filter by VPC: devops-lab-vpc
3. **Press Win+Shift+S** to screenshot
4. Save as `Security_Groups.png`

---

### Screenshot 4: EKS Cluster

Go to:
```
https://console.aws.amazon.com/eks/
```

1. Click "Clusters" in left menu
2. Click "devops-lab"
3. **Press Win+Shift+S** to screenshot
4. Save as `EKS_Cluster.png`

---

### Screenshot 5: EKS Nodes

In same EKS Cluster page:
1. Scroll to "Node groups"
2. Click "devops-lab-node-group"
3. Click "Nodes" tab
4. **Press Win+Shift+S** to screenshot
5. Save as `EKS_Nodes.png`

---

### Screenshot 6: RDS Database

Go to:
```
https://console.aws.amazon.com/rds/
```

1. Click "Databases" in left menu
2. Click "devops-lab-db"
3. **Press Win+Shift+S** to screenshot
4. Save as `RDS_Database.png`

---

### Screenshot 7: RDS Endpoint

In same RDS page:
1. Scroll to "Connectivity & security"
2. **Press Win+Shift+S** to screenshot
3. Save as `RDS_Endpoint.png`

**Copy the Writer Endpoint - you'll need it later!**

---

### Screenshot 8: S3 Bucket

Go to:
```
https://console.aws.amazon.com/s3/
```

1. Look for bucket starting with "devops-lab-app-data-"
2. **Press Win+Shift+S** to screenshot
3. Save as `S3_Bucket.png`

---

### Screenshot 9: S3 Properties

In same S3 page:
1. Click on the bucket name
2. Click "Properties" tab
3. Scroll to "Versioning" and "Encryption"
4. **Press Win+Shift+S** to screenshot
5. Save as `S3_Properties.png`

---

## Create Summary Document

Create a new file called `DEPLOYMENT_SUMMARY.md`:

```markdown
# AWS Terraform Deployment - COMPLETE ✅

## Deployment Details

**Date:** [Your Date]
**Time to Deploy:** 18-20 minutes
**Total Resources:** 63
**Status:** SUCCESS ✅

## Resources Created

### VPC
- VPC ID: [copy from terraform output]
- CIDR: 10.0.0.0/16
- Public Subnets: 2
- Private Subnets: 2

### EKS
- Cluster Name: devops-lab
- Endpoint: [copy from terraform output]
- Version: 1.28
- Nodes: 2x t3.medium

### RDS
- Database: devopsdb
- Engine: PostgreSQL 15.4
- Endpoint: [copy from terraform output]
- Port: 5432

### S3
- Bucket: [copy from terraform output]
- Versioning: Enabled
- Encryption: Enabled

## Verification Results

✓ kubectl get nodes - 2 nodes ready
✓ kubectl cluster-info - Control plane accessible
✓ AWS CLI verification - All resources found
✓ Screenshots captured - 9 images

## Terraform Outputs

[Paste output of: terraform output]

## Next Steps

→ Step 3: Ansible Configuration Management
→ Step 4: Kubernetes Deployment
→ Step 5: CI/CD Pipeline
```

---

## If Something Goes Wrong

### Problem: Deployment Failed

**Option 1: Try Again**
```powershell
terraform apply tfplan
```

**Option 2: Check Error**
Read the error message carefully - it usually tells you what went wrong.

**Option 3: Destroy and Start Fresh**
```powershell
terraform destroy
# Type "yes" when prompted
# Wait for all resources to be deleted
# Then run: terraform apply tfplan
```

---

## If You Want to Stop (Delete All Resources)

```powershell
# Destroy all AWS resources
terraform destroy

# Type "yes" when prompted
# Wait for completion
# All costs will stop
```

---

## All Done! 🎉

You now have:
✅ 63 AWS resources created
✅ Terraform outputs saved
✅ kubectl configured and working
✅ 9 AWS Console screenshots
✅ Summary documentation created

**Total time spent:** ~25 minutes
(18-20 min for Terraform + 5-10 min for screenshots)

**Ready for Step 3: Ansible Configuration Management!**

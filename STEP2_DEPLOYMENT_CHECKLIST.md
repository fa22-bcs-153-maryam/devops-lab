# Step 2 Deployment Checklist

## Pre-Deployment Requirements

### ✅ AWS Account & Credentials
- [ ] AWS Account created (https://aws.amazon.com)
- [ ] IAM user with appropriate permissions created
- [ ] Access Key ID and Secret Access Key generated
- [ ] No AWS credentials in code (only .env files)

### ✅ Local Tools Installation
```bash
# Check versions (should return version numbers)
terraform --version        # >= 1.0
aws --version             # >= 2.0
kubectl version --client  # >= 1.20
```

- [ ] Terraform installed (https://www.terraform.io/downloads)
- [ ] AWS CLI installed (https://aws.amazon.com/cli)
- [ ] kubectl installed (https://kubernetes.io/docs/tasks/tools)

### ✅ AWS Credentials Configuration
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: us-east-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

- [ ] AWS credentials configured locally
- [ ] Verified with `aws sts get-caller-identity`

### ✅ IAM Permissions
Ensure your AWS user has permissions for:
- EC2 (for EKS nodes)
- EKS (for cluster management)
- RDS (for database)
- S3 (for bucket)
- IAM (for roles and policies)
- VPC (for networking)

- [ ] IAM permissions verified (use AWS IAM Policy Simulator if unsure)

## Deployment Steps

### Step 1: Navigate to Terraform Directory
```bash
cd devops-lab/infra
```
- [ ] Currently in `infra/` directory

### Step 2: Initialize Terraform
```bash
terraform init
```
**Expected output:**
```
Terraform has been successfully configured!
```
- [ ] `terraform init` completed successfully
- [ ] `.terraform/` directory created
- [ ] `.terraform.lock.hcl` created

### Step 3: Review Configuration
```bash
# Validate syntax
terraform validate

# Review planned changes
terraform plan

# Save plan to file
terraform plan -out=tfplan
```

**Expected output for `terraform validate`:**
```
Success! The configuration is valid.
```

**Expected output for `terraform plan`:**
```
Plan: 20 to add, 0 to change, 0 to destroy.
```

- [ ] Configuration validates successfully
- [ ] Plan shows ~20 resources to be created
- [ ] No validation errors

### Step 4: Apply Terraform Configuration
```bash
terraform apply tfplan
```

**⏱️ Timeline (15-20 minutes total):**
- 0-2 min: VPC resources
- 2-15 min: EKS cluster (longest step)
- 3-5 min: RDS database
- 1 min: S3 bucket
- 15-20 min: Total time

**Watch for:**
- No errors in Terraform output
- All resource creation succeeds
- No "Error" messages

- [ ] Terraform apply completed successfully
- [ ] All resources created without errors
- [ ] Completed within 20 minutes

### Step 5: Verify Deployment
```bash
# Show all outputs
terraform output

# Save outputs to file for reference
terraform output > ../aws-outputs.txt
```

**Key outputs to note:**
- `eks_cluster_name`: devops-lab
- `eks_cluster_endpoint`: https://xxxxx.eks.us-east-1.amazonaws.com
- `rds_endpoint`: devops-lab-db.xxxxx.us-east-1.rds.amazonaws.com
- `s3_bucket_name`: devops-lab-app-data-123456789

- [ ] `terraform output` shows all values
- [ ] Outputs saved for reference

### Step 6: Configure kubectl
```bash
aws eks update-kubeconfig \
  --name devops-lab \
  --region us-east-1

# Verify configuration
kubectl cluster-info
kubectl get nodes
```

**Expected output for `kubectl get nodes`:**
```
NAME                          STATUS   ROLES    AGE   VERSION
ip-10-0-10-xxx.ec2.internal   Ready    <none>   2m    v1.28.x
ip-10-0-11-xxx.ec2.internal   Ready    <none>   2m    v1.28.x
```

- [ ] kubectl configured successfully
- [ ] `kubectl cluster-info` shows cluster details
- [ ] `kubectl get nodes` shows 2 Ready nodes

### Step 7: Verify AWS Resources

#### Verify EKS Cluster
```bash
aws eks describe-cluster --name devops-lab --region us-east-1
```
- [ ] Cluster status is "ACTIVE"

#### Verify RDS Database
```bash
aws rds describe-db-instances --db-instance-identifier devops-lab-db
```
- [ ] Database status is "available"
- [ ] Endpoint is accessible

#### Verify S3 Bucket
```bash
aws s3 ls
```
- [ ] Bucket `devops-lab-app-data-xxxxx` is listed

#### Verify VPC & Networking
```bash
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=devops-lab-vpc"
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>"
```
- [ ] VPC exists with CIDR 10.0.0.0/16
- [ ] 4 subnets created (2 public, 2 private)

#### Verify Security Groups
```bash
aws ec2 describe-security-groups --filters "Name=tag-key,Values=Environment"
```
- [ ] 4 security groups created
- [ ] Correct inbound/outbound rules

### Step 8: Test Connectivity

#### Test EKS Cluster
```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test
    image: nginx:latest
    ports:
    - containerPort: 80
EOF

kubectl get pods
kubectl port-forward test-pod 8080:80
# Visit http://localhost:8080
```
- [ ] Pod created and running
- [ ] Can port-forward successfully

#### Test RDS Connection
```bash
# From EKS node
kubectl run -it --rm --image=postgres:15 psql -- \
  psql -h devops-lab-db.xxxxx.us-east-1.rds.amazonaws.com \
       -U dbadmin \
       -d devopsdb \
       -c "SELECT 1"
```
- [ ] Can connect to RDS database
- [ ] Returns "1"

#### Test S3 Access
```bash
aws s3 cp ~/test.txt s3://devops-lab-app-data-xxxxx/
aws s3 ls s3://devops-lab-app-data-xxxxx/
```
- [ ] Can upload to S3
- [ ] Can list S3 contents

### Step 9: Cost Review

Check AWS Console for estimated costs:
1. Go to AWS Console
2. Billing & Cost Management
3. Check estimated monthly charge
4. Should be around $200-250

- [ ] Reviewed AWS billing dashboard
- [ ] Cost is within expected range

### Step 10: Documentation

```bash
# Save important information
echo "EKS Cluster: $(terraform output -raw eks_cluster_name)" > ../deployment-info.txt
echo "RDS Endpoint: $(terraform output -raw rds_endpoint)" >> ../deployment-info.txt
echo "S3 Bucket: $(terraform output -raw s3_bucket_name)" >> ../deployment-info.txt
```

- [ ] Saved deployment information
- [ ] Documented all important endpoints

## Post-Deployment

### ✅ Backup Terraform State
```bash
# Copy terraform.tfstate to safe location
cp terraform.tfstate ../terraform.tfstate.backup
```
- [ ] Terraform state backed up

### ✅ Monitor Resources
```bash
# Set up CloudWatch alerts (optional)
# Monitor EKS cluster health
# Monitor RDS performance
```
- [ ] Monitoring configured (optional)

### ✅ Set Resource Limits
```bash
# Prevent runaway costs by setting:
# - EKS max node scale-up
# - RDS backup retention
# - S3 lifecycle policies
```
- [ ] Resource limits reviewed and appropriate

## Troubleshooting

### Issue: Terraform Init Fails
**Solution:**
- Check AWS credentials: `aws sts get-caller-identity`
- Check Terraform version: `terraform --version`
- Check internet connectivity: `ping -c 1 registry.terraform.io`

### Issue: EKS Cluster Creation Times Out
**Solution:**
- EKS creation takes 10-15 minutes, be patient
- Check AWS console for cluster status
- Review CloudFormation events for details

### Issue: RDS Connection Fails
**Solution:**
- Verify security group allows port 5432
- Ensure subnet is in same VPC as EKS nodes
- Test from EKS node: `telnet <rds-endpoint> 5432`

### Issue: kubectl Cannot Connect to Cluster
**Solution:**
```bash
# Reconfigure kubeconfig
aws eks update-kubeconfig --name devops-lab --region us-east-1

# Check kubeconfig
cat ~/.kube/config

# Verify IAM permissions
aws iam get-user
```

### Issue: AWS Costs Higher Than Expected
**Solution:**
- Check for unused Elastic IPs
- Review data transfer charges
- Consider using AWS Savings Plans
- Destroy unused resources: `terraform destroy`

## Cleanup (When Done)

⚠️ **To stop incurring AWS charges:**

```bash
# From infra/ directory
terraform destroy

# Confirm by typing: yes
# Wait 10-15 minutes for deletion

# Verify deletion in AWS Console
```

- [ ] All resources deleted
- [ ] AWS Console shows no resources

## Success Criteria ✅

You have successfully completed Step 2 when:

- [ ] All Terraform files created and validated
- [ ] AWS infrastructure deployed successfully
- [ ] EKS cluster has 2 ready worker nodes
- [ ] RDS database is accessible
- [ ] S3 bucket created with proper configuration
- [ ] kubectl can connect to cluster
- [ ] All networking properly configured
- [ ] Security groups restrict access appropriately
- [ ] Terraform outputs documented
- [ ] Terraform state backed up

## Next Steps

Once Step 2 is complete:

→ **Step 3**: Configuration Management with Ansible
→ **Step 4**: Kubernetes Deployment
→ **Step 5**: CI/CD with GitHub Actions

---

**Status**: ✅ Ready for Deployment
**Time to Complete**: 20-30 minutes (including AWS provisioning time)
**Cost**: ~$220/month while running

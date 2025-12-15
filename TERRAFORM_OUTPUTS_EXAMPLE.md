# Example: Actual Terraform Outputs (After Running terraform apply)

## Real Output Example

When you run `terraform output` after successful deployment, you'll see something like this:

```
aws_region = "us-east-1"

configure_kubectl = "aws eks update-kubeconfig --name devops-lab --region us-east-1"

deployment_summary = {
  "eks_cluster_endpoint" = "https://5A6B7C8D9E0F.eks.us-east-1.amazonaws.com"
  "eks_cluster_name"     = "devops-lab"
  "rds_endpoint"         = "devops-lab-db.c9d8e7f6g5h4.us-east-1.rds.amazonaws.com:5432"
  "region"               = "us-east-1"
  "s3_bucket_name"       = "devops-lab-app-data-123456789012"
  "vpc_id"               = "vpc-0a1b2c3d4e5f6g7h"
}

eks_cluster_arn = "arn:aws:eks:us-east-1:123456789012:cluster/devops-lab"

eks_cluster_endpoint = "https://5A6B7C8D9E0F.eks.us-east-1.amazonaws.com"

eks_cluster_name = "devops-lab"

eks_cluster_security_group_id = "sg-0123456789abcdef0"

eks_cluster_version = "1.28"

eks_node_group_id = "devops-lab-devops-lab-node-group-1234567890abcdef"

private_subnet_ids = [
  "subnet-0a1b2c3d4e5f6g7h",
  "subnet-0i1j2k3l4m5n6o7p",
]

public_subnet_ids = [
  "subnet-0q1r2s3t4u5v6w7x",
  "subnet-0y1z2a3b4c5d6e7f",
]

rds_address = "devops-lab-db.c9d8e7f6g5h4.us-east-1.rds.amazonaws.com"

rds_connection_string = "postgresql://<username>:<password>@devops-lab-db.c9d8e7f6g5h4.us-east-1.rds.amazonaws.com:5432/devopsdb"

rds_database_name = "devopsdb"

rds_endpoint = "devops-lab-db.c9d8e7f6g5h4.us-east-1.rds.amazonaws.com:5432"

rds_port = 5432

s3_bucket_arn = "arn:aws:s3:::devops-lab-app-data-123456789012"

s3_bucket_name = "devops-lab-app-data-123456789012"

s3_bucket_region = "us-east-1"

vpc_cidr = "10.0.0.0/16"

vpc_id = "vpc-0a1b2c3d4e5f6g7h"
```

---

## How to Use These Outputs

### 1. **Configure kubectl for EKS Access**
```bash
# Copy the configure_kubectl output value
aws eks update-kubeconfig --name devops-lab --region us-east-1

# Verify connection
kubectl get nodes
kubectl cluster-info
```

**Output:**
```
NAME                                      STATUS   ROLES    AGE   VERSION
ip-10-0-10-5.ec2.internal                Ready    <none>   2m    v1.28.x
ip-10-0-11-8.ec2.internal                Ready    <none>   2m    v1.28.x
```

---

### 2. **Connect to RDS Database**
```bash
# Use rds_endpoint to connect
psql -h devops-lab-db.c9d8e7f6g5h4.us-east-1.rds.amazonaws.com \
     -U dbadmin \
     -d devopsdb

# Or use the connection string
psql postgresql://dbadmin:password@devops-lab-db.c9d8e7f6g5h4.us-east-1.rds.amazonaws.com:5432/devopsdb
```

---

### 3. **Access S3 Bucket**
```bash
# List bucket contents
aws s3 ls s3://devops-lab-app-data-123456789012/

# Upload file
aws s3 cp myfile.txt s3://devops-lab-app-data-123456789012/

# Download file
aws s3 cp s3://devops-lab-app-data-123456789012/myfile.txt .
```

---

### 4. **Deploy Application to EKS**
```bash
# Update kubeconfig first
aws eks update-kubeconfig --name devops-lab --region us-east-1

# Create namespace
kubectl create namespace production

# Deploy your app
kubectl apply -f kubernetes/deployment.yaml -n production

# Check pods
kubectl get pods -n production
```

---

### 5. **Configure Ansible Inventory**
```ini
[kubernetes_cluster]
eks_endpoint = https://5A6B7C8D9E0F.eks.us-east-1.amazonaws.com

[databases]
rds_host = devops-lab-db.c9d8e7f6g5h4.us-east-1.rds.amazonaws.com
rds_port = 5432
rds_database = devopsdb

[storage]
s3_bucket = devops-lab-app-data-123456789012
```

---

### 6. **Create Environment File for Application**
```bash
# Create .env file for your app
cat > app.env << EOF
EKS_CLUSTER_NAME=devops-lab
EKS_ENDPOINT=https://5A6B7C8D9E0F.eks.us-east-1.amazonaws.com
DATABASE_HOST=devops-lab-db.c9d8e7f6g5h4.us-east-1.rds.amazonaws.com
DATABASE_PORT=5432
DATABASE_NAME=devopsdb
DATABASE_USER=dbadmin
DATABASE_PASSWORD=your_password_here
S3_BUCKET=devops-lab-app-data-123456789012
AWS_REGION=us-east-1
EOF
```

---

## Exporting Outputs for CI/CD

### Export as JSON
```bash
terraform output -json > terraform-outputs.json
```

**File contents:**
```json
{
  "aws_region": {
    "value": "us-east-1"
  },
  "eks_cluster_endpoint": {
    "value": "https://5A6B7C8D9E0F.eks.us-east-1.amazonaws.com"
  },
  "eks_cluster_name": {
    "value": "devops-lab"
  },
  "rds_endpoint": {
    "value": "devops-lab-db.c9d8e7f6g5h4.us-east-1.rds.amazonaws.com:5432"
  },
  "s3_bucket_name": {
    "value": "devops-lab-app-data-123456789012"
  }
}
```

### Use in GitHub Actions or Jenkins
```yaml
# GitHub Actions example
- name: Get Terraform Outputs
  run: |
    echo "EKS_CLUSTER_NAME=$(terraform output -raw eks_cluster_name)" >> $GITHUB_ENV
    echo "RDS_ENDPOINT=$(terraform output -raw rds_endpoint)" >> $GITHUB_ENV
    echo "S3_BUCKET=$(terraform output -raw s3_bucket_name)" >> $GITHUB_ENV

- name: Deploy to EKS
  run: |
    aws eks update-kubeconfig --name ${{ env.EKS_CLUSTER_NAME }}
    kubectl apply -f deployment.yaml
```

---

## Verifying Outputs in AWS Console

After `terraform apply`, verify resources:

### 1. **Check VPC**
- Go to VPC Dashboard → VPCs
- Find: `devops-lab-vpc`
- Verify: CIDR block is `10.0.0.0/16`

### 2. **Check EKS Cluster**
- Go to EKS Dashboard → Clusters
- Find: `devops-lab`
- Verify: Status = ACTIVE, Version = 1.28
- Check Nodes: Should see 2 nodes in Ready state

### 3. **Check RDS Database**
- Go to RDS Dashboard → Databases
- Find: `devops-lab-db`
- Verify: Status = Available, Engine = PostgreSQL 15.4
- Get Endpoint from Details tab

### 4. **Check S3 Bucket**
- Go to S3 Dashboard
- Find: `devops-lab-app-data-123456789012`
- Verify: Versioning enabled, Encryption enabled

### 5. **Check Security Groups**
- Go to EC2 Dashboard → Security Groups
- Find: `devops-lab-eks-control-plane-sg`, `devops-lab-eks-worker-nodes-sg`, `devops-lab-rds-sg`
- Verify: Rules are correctly configured

---

## Saving Outputs for Documentation

```bash
# Save all outputs to text file
terraform output > deployment-info.txt

# Save only important outputs
cat > DEPLOYMENT_SUMMARY.md << EOF
# Deployment Summary

## AWS Resources

**Cluster:**
- Name: $(terraform output -raw eks_cluster_name)
- Endpoint: $(terraform output -raw eks_cluster_endpoint)

**Database:**
- Endpoint: $(terraform output -raw rds_endpoint)
- Database: $(terraform output -raw rds_database_name)

**Storage:**
- Bucket: $(terraform output -raw s3_bucket_name)

## Configure kubectl

\`\`\`bash
$(terraform output -raw configure_kubectl)
\`\`\`

EOF
```

---

## Next Steps After Getting Outputs

1. ✅ Save all outputs (terraform output > outputs.txt)
2. ✅ Configure kubectl
3. ✅ Test EKS cluster connectivity (kubectl get nodes)
4. ✅ Test RDS connectivity (psql connection)
5. ✅ Test S3 access (aws s3 ls)
6. → Deploy application to EKS
7. → Set up monitoring (Prometheus/Grafana)
8. → Configure CI/CD pipeline

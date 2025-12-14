aws_region = "us-east-1"
environment = "dev"
project_name = "devops-lab"

# VPC Configuration
vpc_cidr              = "10.0.0.0/16"
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs  = ["10.0.10.0/24", "10.0.11.0/24"]

# EKS Configuration
eks_cluster_version       = "1.28"
eks_node_desired_size     = 2
eks_node_min_size         = 2
eks_node_max_size         = 4
eks_node_instance_types   = ["t3.medium"]

# RDS Configuration
rds_database_name = "devopsdb"
rds_username      = "dbadmin"
rds_password      = "DevOpsLab@123456"  # Change this in production!
rds_instance_class = "db.t3.micro"

# S3 Configuration
s3_bucket_name = "devops-lab-app-data"

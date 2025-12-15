# Terraform Backend Configuration (Optional - for remote state)
# Uncomment and configure if you want to use S3 for state management

# terraform {
#   backend "s3" {
#     bucket         = "devops-lab-terraform-state"
#     key            = "infra/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }

#!/bin/bash

# Step 2 Terraform Quick Start Script
# This script helps you manage Terraform operations

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INFRA_DIR="$SCRIPT_DIR/infra"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║        DevOps Lab - Step 2 Terraform Management          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Function to show menu
show_menu() {
    echo "Select an option:"
    echo "1. Initialize Terraform (terraform init)"
    echo "2. Validate configuration (terraform validate)"
    echo "3. Plan deployment (terraform plan)"
    echo "4. Apply deployment (terraform apply)"
    echo "5. Show outputs (terraform output)"
    echo "6. Destroy infrastructure (terraform destroy)"
    echo "7. Show state (terraform show)"
    echo "8. Exit"
    echo ""
    read -p "Enter choice [1-8]: " choice
}

# Function to initialize terraform
init_terraform() {
    echo "Initializing Terraform..."
    cd "$INFRA_DIR"
    terraform init
    echo "✓ Terraform initialized"
}

# Function to validate
validate_terraform() {
    echo "Validating Terraform configuration..."
    cd "$INFRA_DIR"
    terraform validate
    echo "✓ Configuration is valid"
}

# Function to plan
plan_terraform() {
    echo "Planning Terraform deployment..."
    cd "$INFRA_DIR"
    terraform plan -out=tfplan
    echo "✓ Plan saved to tfplan"
}

# Function to apply
apply_terraform() {
    echo "Applying Terraform configuration..."
    cd "$INFRA_DIR"
    
    if [ ! -f "tfplan" ]; then
        echo "ERROR: tfplan not found. Run 'terraform plan' first."
        return 1
    fi
    
    terraform apply tfplan
    echo "✓ Infrastructure deployed successfully"
    echo ""
    echo "To configure kubectl, run:"
    echo "aws eks update-kubeconfig --name devops-lab --region us-east-1"
}

# Function to show outputs
show_outputs() {
    echo "Terraform Outputs:"
    cd "$INFRA_DIR"
    terraform output
}

# Function to destroy
destroy_infrastructure() {
    echo "⚠️  WARNING: This will delete all AWS resources!"
    read -p "Are you sure you want to destroy? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        echo "Destruction cancelled"
        return
    fi
    
    cd "$INFRA_DIR"
    terraform destroy
    echo "✓ Infrastructure destroyed"
}

# Function to show state
show_state() {
    echo "Terraform State:"
    cd "$INFRA_DIR"
    terraform show | head -100
}

# Main loop
while true; do
    show_menu
    
    case $choice in
        1) init_terraform ;;
        2) validate_terraform ;;
        3) plan_terraform ;;
        4) apply_terraform ;;
        5) show_outputs ;;
        6) destroy_infrastructure ;;
        7) show_state ;;
        8) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
    clear
done

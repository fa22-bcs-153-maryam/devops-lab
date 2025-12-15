# Step 2 Terraform Quick Start Script (PowerShell)
# This script helps you manage Terraform operations

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        DevOps Lab - Step 2 Terraform Management          ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$infra_dir = "$(Get-Location)\infra"

function Show-Menu {
    Write-Host "Select an option:" -ForegroundColor Yellow
    Write-Host "1. Initialize Terraform (terraform init)"
    Write-Host "2. Validate configuration (terraform validate)"
    Write-Host "3. Plan deployment (terraform plan)"
    Write-Host "4. Apply deployment (terraform apply)"
    Write-Host "5. Show outputs (terraform output)"
    Write-Host "6. Destroy infrastructure (terraform destroy)"
    Write-Host "7. Show state (terraform show)"
    Write-Host "8. Exit"
    Write-Host ""
}

function Init-Terraform {
    Write-Host "Initializing Terraform..." -ForegroundColor Green
    Push-Location $infra_dir
    terraform init
    Pop-Location
    Write-Host "✓ Terraform initialized" -ForegroundColor Green
}

function Validate-Terraform {
    Write-Host "Validating Terraform configuration..." -ForegroundColor Green
    Push-Location $infra_dir
    terraform validate
    Pop-Location
    Write-Host "✓ Configuration is valid" -ForegroundColor Green
}

function Plan-Terraform {
    Write-Host "Planning Terraform deployment..." -ForegroundColor Green
    Push-Location $infra_dir
    terraform plan -out=tfplan
    Pop-Location
    Write-Host "✓ Plan saved to tfplan" -ForegroundColor Green
}

function Apply-Terraform {
    Write-Host "Applying Terraform configuration..." -ForegroundColor Green
    Push-Location $infra_dir
    
    if (-not (Test-Path "tfplan")) {
        Write-Host "ERROR: tfplan not found. Run 'terraform plan' first." -ForegroundColor Red
        Pop-Location
        return
    }
    
    terraform apply tfplan
    Pop-Location
    Write-Host "✓ Infrastructure deployed successfully" -ForegroundColor Green
    Write-Host ""
    Write-Host "To configure kubectl, run:" -ForegroundColor Cyan
    Write-Host "aws eks update-kubeconfig --name devops-lab --region us-east-1"
}

function Show-Outputs {
    Write-Host "Terraform Outputs:" -ForegroundColor Green
    Push-Location $infra_dir
    terraform output
    Pop-Location
}

function Destroy-Infrastructure {
    Write-Host "⚠️  WARNING: This will delete all AWS resources!" -ForegroundColor Red
    $confirm = Read-Host "Are you sure you want to destroy? (yes/no)"
    
    if ($confirm -ne "yes") {
        Write-Host "Destruction cancelled" -ForegroundColor Yellow
        return
    }
    
    Push-Location $infra_dir
    terraform destroy
    Pop-Location
    Write-Host "✓ Infrastructure destroyed" -ForegroundColor Green
}

function Show-State {
    Write-Host "Terraform State:" -ForegroundColor Green
    Push-Location $infra_dir
    $output = terraform show
    $output | Select-Object -First 100
    Pop-Location
}

# Main loop
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter choice [1-8]"
    
    switch ($choice) {
        "1" { Init-Terraform }
        "2" { Validate-Terraform }
        "3" { Plan-Terraform }
        "4" { Apply-Terraform }
        "5" { Show-Outputs }
        "6" { Destroy-Infrastructure }
        "7" { Show-State }
        "8" { Write-Host "Exiting..."; exit }
        default { Write-Host "Invalid option. Please try again." -ForegroundColor Red }
    }
    
    Write-Host ""
    Read-Host "Press Enter to continue..."
    Clear-Host
}

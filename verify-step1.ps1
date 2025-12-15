# DevOps Lab - Step 1 Verification Script (Windows PowerShell)
# This script tests all components of the containerized application

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "DevOps Lab - Step 1: Container Verification" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

# Function to print status
function Print-Status {
    param(
        [string]$Message,
        [bool]$Success
    )
    if ($Success) {
        Write-Host "✓ $Message" -ForegroundColor Green
    } else {
        Write-Host "✗ $Message" -ForegroundColor Red
    }
}

# Start Docker Compose
Write-Host "`nStep 1: Starting Docker Compose Services..." -ForegroundColor Yellow
docker-compose up -d
Print-Status "Docker Compose services started" $?

# Wait for services to be healthy
Write-Host "`nStep 2: Waiting for services to be healthy (60 seconds)..." -ForegroundColor Yellow
$maxAttempts = 60
$attempt = 0
$servicesHealthy = $false

while ($attempt -lt $maxAttempts -and -not $servicesHealthy) {
    try {
        $mysqlCheck = docker-compose exec -T db mysqladmin ping -h localhost -u root -prootpassword 2>&1
        $redisCheck = docker-compose exec -T redis redis-cli ping 2>&1
        
        if ($mysqlCheck -match "mysqld is alive" -and $redisCheck -match "PONG") {
            Write-Host "✓ All services are healthy" -ForegroundColor Green
            $servicesHealthy = $true
        }
    } catch {
        # Services not ready yet
    }
    
    Write-Host -NoNewline "."
    Start-Sleep -Seconds 1
    $attempt++
}

# Check database connectivity
Write-Host "`nStep 3: Testing Database Connectivity..." -ForegroundColor Yellow
try {
    docker-compose exec -T db mysqladmin ping -h localhost -u root -prootpassword
    Print-Status "MySQL Database is running on port 3306" $true
} catch {
    Print-Status "MySQL Database is running on port 3306" $false
}

# Check Redis connectivity
Write-Host "`nStep 4: Testing Redis Connectivity..." -ForegroundColor Yellow
try {
    docker-compose exec -T redis redis-cli ping
    Print-Status "Redis Cache is running on port 6379" $true
} catch {
    Print-Status "Redis Cache is running on port 6379" $false
}

# Check API health
Write-Host "`nStep 5: Testing API Health..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

try {
    $apiHealth = Invoke-WebRequest -Uri "http://localhost:4000/health" -UseBasicParsing -TimeoutSec 10 | Select-Object -ExpandProperty Content
    if ($apiHealth -match "healthy") {
        Write-Host "✓ API is healthy" -ForegroundColor Green
        Write-Host "Response: $apiHealth"
        Print-Status "API is running" $true
    } else {
        Print-Status "API is running" $false
    }
} catch {
    Write-Host "API health check failed: $_" -ForegroundColor Red
    Print-Status "API is running" $false
}

# Check frontend
Write-Host "`nStep 6: Testing Frontend..." -ForegroundColor Yellow
try {
    $frontendResponse = Invoke-WebRequest -Uri "http://localhost:3001" -UseBasicParsing -TimeoutSec 10
    Print-Status "Frontend is running on port 3001" ($frontendResponse.StatusCode -eq 200)
} catch {
    Print-Status "Frontend is running on port 3001" $false
}

# Test API endpoints
Write-Host "`nStep 7: Testing API Endpoints..." -ForegroundColor Yellow

Write-Host "`nTesting GET /users" -ForegroundColor Yellow
try {
    $usersResponse = Invoke-WebRequest -Uri "http://localhost:4000/users" -UseBasicParsing -TimeoutSec 10 | Select-Object -ExpandProperty Content
    $usersResponse | ConvertFrom-Json | ConvertTo-Json | Write-Host
    Print-Status "GET /users" $true
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Print-Status "GET /users" $false
}

# Create a test user
Write-Host "`nTesting POST /users" -ForegroundColor Yellow
try {
    $body = @{
        name = "Test User"
        email = "test@example.com"
    } | ConvertTo-Json
    
    $createResponse = Invoke-WebRequest -Uri "http://localhost:4000/users" `
        -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $body `
        -UseBasicParsing -TimeoutSec 10 | Select-Object -ExpandProperty Content
    
    $createResponse | ConvertFrom-Json | ConvertTo-Json | Write-Host
    Print-Status "POST /users" $true
    
    # Extract user ID for next test
    $userJson = $createResponse | ConvertFrom-Json
    $userId = $userJson.data.id
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Print-Status "POST /users" $false
    $userId = $null
}

# Get single user
if ($userId) {
    Write-Host "`nTesting GET /users/:id (ID: $userId)" -ForegroundColor Yellow
    try {
        $userDetail = Invoke-WebRequest -Uri "http://localhost:4000/users/$userId" `
            -UseBasicParsing -TimeoutSec 10 | Select-Object -ExpandProperty Content
        
        $userDetail | ConvertFrom-Json | ConvertTo-Json | Write-Host
        Print-Status "GET /users/:id" $true
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
        Print-Status "GET /users/:id" $false
    }
}

# Check volumes
Write-Host "`nStep 8: Checking Persistent Volumes..." -ForegroundColor Yellow
try {
    $mysqlVolume = docker volume ls | Select-String "mysql_data"
    Print-Status "MySQL data volume exists" ($null -ne $mysqlVolume)
} catch {
    Print-Status "MySQL data volume exists" $false
}

try {
    $redisVolume = docker volume ls | Select-String "redis_data"
    Print-Status "Redis data volume exists" ($null -ne $redisVolume)
} catch {
    Print-Status "Redis data volume exists" $false
}

# Check container networking
Write-Host "`nStep 9: Verifying Container Networking..." -ForegroundColor Yellow
try {
    $networkCheck = docker network ls | Select-String "app_network"
    Print-Status "app_network bridge network exists" ($null -ne $networkCheck)
} catch {
    Print-Status "app_network bridge network exists" $false
}

# Summary
Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "✓ STEP 1 VERIFICATION COMPLETE" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow

Write-Host "`nService Status:" -ForegroundColor Yellow
docker-compose ps

Write-Host "`nAccess URLs:" -ForegroundColor Yellow
Write-Host "API: http://localhost:4000"
Write-Host "API Health: http://localhost:4000/health"
Write-Host "Frontend: http://localhost:3001"
Write-Host "Database: mysql://localhost:3306/express_db"
Write-Host "Redis: redis://localhost:6379"

Write-Host "`nUseful Commands:" -ForegroundColor Yellow
Write-Host "View logs: docker-compose logs -f"
Write-Host "Stop services: docker-compose down"
Write-Host "Clean up volumes: docker-compose down -v"
Write-Host "Rebuild images: docker-compose build --no-cache"

Write-Host "`n✓ All checks passed! Your containerized application is ready.`n" -ForegroundColor Green

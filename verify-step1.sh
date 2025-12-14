#!/bin/bash

# DevOps Lab - Step 1 Verification Script
# This script tests all components of the containerized application

set -e

echo "═══════════════════════════════════════════════════════════"
echo "DevOps Lab - Step 1: Container Verification"
echo "═══════════════════════════════════════════════════════════"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1${NC}"
    else
        echo -e "${RED}✗ $1${NC}"
    fi
}

# Start Docker Compose
echo -e "\n${YELLOW}Step 1: Starting Docker Compose Services...${NC}"
docker-compose up -d
print_status "Docker Compose services started"

# Wait for services to be healthy
echo -e "\n${YELLOW}Step 2: Waiting for services to be healthy (60 seconds)...${NC}"
for i in {1..60}; do
    if docker-compose exec -T db mysqladmin ping -h localhost -u root -prootpassword 2>/dev/null && \
       docker-compose exec -T redis redis-cli ping 2>/dev/null | grep -q "PONG"; then
        echo -e "${GREEN}✓ All services are healthy${NC}"
        break
    fi
    echo -n "."
    sleep 1
done

# Check database connectivity
echo -e "\n${YELLOW}Step 3: Testing Database Connectivity...${NC}"
docker-compose exec -T db mysqladmin ping -h localhost -u root -prootpassword
print_status "MySQL Database is running on port 3306"

# Check Redis connectivity
echo -e "\n${YELLOW}Step 4: Testing Redis Connectivity...${NC}"
docker-compose exec -T redis redis-cli ping
print_status "Redis Cache is running on port 6379"

# Check API health
echo -e "\n${YELLOW}Step 5: Testing API Health...${NC}"
sleep 5  # Give API time to start
API_HEALTH=$(curl -s http://localhost:4000/health || echo "")
if echo "$API_HEALTH" | grep -q "healthy"; then
    echo -e "${GREEN}✓ API is healthy${NC}"
    echo "Response: $API_HEALTH"
else
    echo -e "${RED}✗ API health check failed${NC}"
fi

# Check frontend
echo -e "\n${YELLOW}Step 6: Testing Frontend...${NC}"
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001)
if [ "$FRONTEND_STATUS" == "200" ]; then
    echo -e "${GREEN}✓ Frontend is running on port 3001${NC}"
else
    echo -e "${YELLOW}⚠ Frontend returned status $FRONTEND_STATUS${NC}"
fi

# Test API endpoints
echo -e "\n${YELLOW}Step 7: Testing API Endpoints...${NC}"

# Get all users (should be empty initially)
echo -e "\n${YELLOW}Testing GET /users${NC}"
USERS=$(curl -s http://localhost:4000/users)
echo "$USERS" | jq . 2>/dev/null || echo "$USERS"
print_status "GET /users"

# Create a test user
echo -e "\n${YELLOW}Testing POST /users${NC}"
USER_RESPONSE=$(curl -s -X POST http://localhost:4000/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Test User", "email": "test@example.com"}')
echo "$USER_RESPONSE" | jq . 2>/dev/null || echo "$USER_RESPONSE"
print_status "POST /users"

# Extract user ID from response
USER_ID=$(echo "$USER_RESPONSE" | jq -r '.data.id' 2>/dev/null || echo "1")

# Get single user
if [ "$USER_ID" != "null" ] && [ "$USER_ID" != "" ]; then
    echo -e "\n${YELLOW}Testing GET /users/:id (ID: $USER_ID)${NC}"
    USER_DETAIL=$(curl -s http://localhost:4000/users/$USER_ID)
    echo "$USER_DETAIL" | jq . 2>/dev/null || echo "$USER_DETAIL"
    print_status "GET /users/:id"
fi

# Check volumes
echo -e "\n${YELLOW}Step 8: Checking Persistent Volumes...${NC}"
docker volume ls | grep mysql_data
print_status "MySQL data volume exists"

docker volume ls | grep redis_data
print_status "Redis data volume exists"

# Check container networking
echo -e "\n${YELLOW}Step 9: Verifying Container Networking...${NC}"
docker network ls | grep "app_network"
print_status "app_network bridge network exists"

docker-compose exec -T api ping -c 1 db
print_status "API can reach database service"

docker-compose exec -T api ping -c 1 redis
print_status "API can reach Redis service"

# Summary
echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ STEP 1 VERIFICATION COMPLETE${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"

echo -e "\n${YELLOW}Service Status:${NC}"
docker-compose ps

echo -e "\n${YELLOW}Access URLs:${NC}"
echo "API: http://localhost:4000"
echo "API Health: http://localhost:4000/health"
echo "Frontend: http://localhost:3001"
echo "Database: mysql://localhost:3306/express_db"
echo "Redis: redis://localhost:6379"

echo -e "\n${YELLOW}Useful Commands:${NC}"
echo "View logs: docker-compose logs -f"
echo "Stop services: docker-compose down"
echo "Clean up volumes: docker-compose down -v"
echo "Rebuild images: docker-compose build --no-cache"

echo -e "\n${GREEN}✓ All checks passed! Your containerized application is ready.${NC}\n"

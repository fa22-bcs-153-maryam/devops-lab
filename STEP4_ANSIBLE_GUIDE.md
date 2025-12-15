# Step 4: Ansible Configuration Management Guide

## Overview

This guide covers **Ansible Configuration Management** - the fourth step of your DevOps lab. Ansible automates the installation, configuration, and deployment of your application across infrastructure.

## What is Ansible?

**Ansible** is an agentless automation tool that:
- Installs software packages and dependencies
- Configures servers/containers
- Deploys applications
- Manages secrets and configurations
- Runs commands on multiple hosts
- **No agents needed** - uses SSH only

### Key Advantages:
✅ Agentless (only SSH required)  
✅ YAML syntax (easy to read)  
✅ Idempotent (safe to run multiple times)  
✅ Works with local or remote hosts  
✅ Integrates with Terraform outputs  

---

## Project Structure

```
ansible/
├── playbook.yaml              # Main playbook
├── ansible.cfg               # Ansible configuration
├── inventory/
│   └── hosts.ini            # Host inventory file
├── roles/                    # Reusable task collections
│   ├── dependencies/        # Install dependencies
│   ├── docker/             # Configure Docker
│   ├── kubernetes/         # Configure Kubernetes
│   └── app_config/         # Deploy app configuration
├── group_vars/
│   └── all.yaml           # Global variables
└── host_vars/             # Host-specific variables
```

## Components Explained

### 1. **playbook.yaml** - Main Orchestration
Defines what to run and in what order:
- Install dependencies (Node.js, npm, Python)
- Configure Docker (install, setup daemon)
- Configure Kubernetes (kubelet, kubeadm, kubectl)
- Deploy application config (env files, settings)
- Verify installation

### 2. **inventory/hosts.ini** - Define Your Hosts
Lists all machines to configure:
```ini
[all]
localhost ansible_connection=local

[docker_hosts]
# Hosts that need Docker

[kubernetes_hosts]
# K8s nodes

[api_servers]
# API servers

[prod_environment]
# Production hosts
```

### 3. **roles/** - Reusable Configuration
Four roles handle different parts:
- **dependencies**: Install base packages
- **docker**: Install & configure Docker
- **kubernetes**: Install kubelet, kubeadm, kubectl
- **app_config**: Deploy .env files, configs, secrets

### 4. **group_vars/all.yaml** - Global Settings
Variables used by all tasks:
```yaml
app_name: devops-lab
api_port: 4000
db_host: localhost
redis_port: 6379
```

---

## Setup Instructions

### Step 1: Install Ansible in WSL/Ubuntu

```bash
# Update apt
sudo apt update

# Install Ansible
sudo apt install -y ansible

# Verify installation
ansible --version
```

### Step 2: Verify Inventory Configuration

Edit [ansible/inventory/hosts.ini](inventory/hosts.ini):

**For testing locally:**
```ini
[all]
localhost ansible_connection=local

[docker_hosts]
localhost

[dev_environment]
localhost
```

**After AWS deployment (terraform apply):**
```ini
[all]
eks-node-1 ansible_host=10.0.1.100 ansible_user=ec2-user
eks-node-2 ansible_host=10.0.1.101 ansible_user=ec2-user

[kubernetes_hosts]
eks-node-1
eks-node-2

[prod_environment]
eks-node-1
eks-node-2
```

### Step 3: Test Ansible Connectivity

```bash
# Navigate to ansible directory
cd ansible

# Test connectivity to all hosts
ansible all -i inventory/hosts.ini -m ping

# Example output:
# localhost | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }
```

### Step 4: Run the Playbook

#### Option A: Full playbook run
```bash
cd ansible
ansible-playbook -i inventory/hosts.ini playbook.yaml
```

#### Option B: Run specific roles only
```bash
# Install dependencies only
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags dependencies

# Install Docker only
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags docker

# Configure Kubernetes only
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags kubernetes

# Deploy app config only
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags app_config
```

#### Option C: Run on specific host group
```bash
# Configure only Docker hosts
ansible-playbook -i inventory/hosts.ini playbook.yaml -l docker_hosts

# Configure only K8s hosts
ansible-playbook -i inventory/hosts.ini playbook.yaml -l kubernetes_hosts
```

#### Option D: Dry run (check mode)
```bash
# See what WILL change, without making changes
ansible-playbook -i inventory/hosts.ini playbook.yaml --check
```

#### Option E: Verbose output
```bash
# Get detailed output of all tasks
ansible-playbook -i inventory/hosts.ini playbook.yaml -v

# Extra verbose
ansible-playbook -i inventory/hosts.ini playbook.yaml -vvv
```

---

## What Each Role Does

### Role 1: Dependencies
**Location**: `roles/dependencies/tasks/main.yaml`

Installs base packages:
```bash
apt/yum:
  - curl, wget, git, vim
  - build-essential
  - Node.js 20, npm
  - Python 3
  - Docker, Kubernetes tools
```

**Run only this role:**
```bash
ansible-playbook playbook.yaml --tags dependencies
```

### Role 2: Docker
**Location**: `roles/docker/tasks/main.yaml`

Installs and configures Docker:
- Adds Docker repository
- Installs docker-ce, docker-cli, containerd
- Configures daemon.json
- Sets up log rotation
- Enables service

**Run only this role:**
```bash
ansible-playbook playbook.yaml --tags docker
```

### Role 3: Kubernetes
**Location**: `roles/kubernetes/tasks/main.yaml`

Prepares for Kubernetes:
- Disables swap
- Loads kernel modules
- Installs containerd (container runtime)
- Installs kubelet, kubeadm, kubectl
- Configures cgroup driver

**Run only this role:**
```bash
ansible-playbook playbook.yaml --tags kubernetes
```

### Role 4: App Config
**Location**: `roles/app_config/tasks/main.yaml`

Deploys application configuration:
- Creates .env file with variables
- Creates config.yaml settings
- Copies application source
- Installs npm dependencies
- Runs `npm run build`
- Sets up log rotation

**Run only this role:**
```bash
ansible-playbook playbook.yaml --tags app_config
```

---

## Configuration Variables

Edit [ansible/group_vars/all.yaml](group_vars/all.yaml):

```yaml
# Application
app_name: devops-lab
app_environment: development
api_port: 4000

# Database
db_host: localhost
db_port: 5432
db_name: devops_lab
db_user: postgres

# Redis
redis_host: localhost
redis_port: 6379

# Docker
docker_image_api: devops-lab-api
docker_image_tag: latest

# Kubernetes
kubernetes_cluster_name: devops-lab-prod
```

---

## Integration with Terraform

### Get Terraform Outputs and Use in Ansible

After running `terraform apply`:

```bash
# Get EKS node IPs
terraform output eks_node_ips

# Output example:
# eks_node_ips = ["10.0.1.100", "10.0.1.101"]
```

### Update Inventory with Terraform Outputs

```bash
# Method 1: Manual update
nano ansible/inventory/hosts.ini

# Add EKS nodes:
[kubernetes_hosts]
eks-node-1 ansible_host=10.0.1.100 ansible_user=ec2-user
eks-node-2 ansible_host=10.0.1.101 ansible_user=ec2-user
```

### Dynamic Inventory (Advanced)

Create `ansible/inventory/aws_ec2.yaml`:

```yaml
---
plugin: aws_ec2
regions:
  - us-east-1
keyed_groups:
  - key: placement.availability_zone
    prefix: az
  - key: tags.Role
    prefix: role
hostnames:
  - dns-name
  - private-ip-address
  - ip-address
filters:
  tag:Project: devops-lab
  instance-state-name: running
```

Run with dynamic inventory:
```bash
ansible-playbook -i inventory/aws_ec2.yaml playbook.yaml
```

---

## Step-by-Step Execution Guide

### Phase 1: Local Testing (Docker)

```bash
# 1. Verify local connectivity
cd ansible
ansible all -i inventory/hosts.ini -m ping

# 2. Check what will change
ansible-playbook -i inventory/hosts.ini playbook.yaml --check

# 3. Install dependencies
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags dependencies -v

# 4. Configure Docker
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags docker -v

# 5. Deploy app configuration
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags app_config -v

# 6. Full playbook run
ansible-playbook -i inventory/hosts.ini playbook.yaml -v
```

### Phase 2: AWS Deployment (After terraform apply)

```bash
# 1. Run Terraform to provision EKS
cd infra
terraform apply

# 2. Get EKS node IPs
terraform output eks_node_ips

# 3. Update Ansible inventory with node IPs
# Edit: ansible/inventory/hosts.ini

# 4. Configure SSH key for EC2 access
export SSH_KEY="/path/to/your/aws_key.pem"

# 5. Test connectivity to AWS nodes
cd ../ansible
ansible all -i inventory/hosts.ini -u ec2-user --private-key=$SSH_KEY -m ping

# 6. Run playbook on AWS infrastructure
ansible-playbook \
  -i inventory/hosts.ini \
  -u ec2-user \
  --private-key=$SSH_KEY \
  playbook.yaml -v

# 7. Verify installation
ansible all -i inventory/hosts.ini -u ec2-user --private-key=$SSH_KEY -m shell -a "docker --version"
ansible all -i inventory/hosts.ini -u ec2-user --private-key=$SSH_KEY -m shell -a "kubectl version --client"
```

---

## Example Playbook Runs

### Example 1: Install Only Dependencies (5 min)

```bash
ansible-playbook playbook.yaml --tags dependencies
```

**Output:**
```
PLAY [Configure DevOps Lab Infrastructure]

TASK [Install basic packages] ****
changed: [localhost]

TASK [Install Node.js and npm] ****
changed: [localhost]

TASK [Upgrade npm to latest version] ****
changed: [localhost]

TASK [Install Python packages] ****
changed: [localhost]

TASK [Create application directories] ****
changed: [localhost] => (item=/opt/devops-lab)

TASK [Display installed versions] ****
ok: [localhost] => {
    "msg": "Installed versions:\n- Node.js: v20.10.0\n- npm: 10.2.3\n- Python: Python 3.11.2\n"
}

PLAY RECAP ****
localhost : ok=8 changed=6 unreachable=0 failed=0
```

### Example 2: Configure Docker (3 min)

```bash
ansible-playbook playbook.yaml --tags docker
```

**Output:**
```
PLAY [Configure Docker]

TASK [Add Docker GPG key] ****
changed: [localhost]

TASK [Add Docker repository] ****
changed: [localhost]

TASK [Install Docker packages] ****
changed: [localhost]

TASK [Configure Docker daemon.json] ****
changed: [localhost]

TASK [Enable Docker service] ****
changed: [localhost]

TASK [Download Docker Compose binary] ****
changed: [localhost]

TASK [Run Docker hello-world test] ****
changed: [localhost]

TASK [Display Docker installation info] ****
ok: [localhost] => {
    "msg": "Docker Installation Successful!\n- Docker version 24.0.7\n- Docker Compose version v2.23.3\n"
}

PLAY RECAP ****
localhost : ok=8 changed=7 unreachable=0 failed=0
```

### Example 3: Configure Full Infrastructure (15 min)

```bash
ansible-playbook playbook.yaml -v
```

**Output:**
```
PLAY [Configure DevOps Lab Infrastructure]

PLAY [Install Dependencies]
TASK [Install basic packages] ****
changed: [localhost]

TASK [Install Node.js and npm] ****
changed: [localhost]

PLAY [Configure Docker]
TASK [Add Docker repository] ****
changed: [localhost]

TASK [Install Docker packages] ****
changed: [localhost]

PLAY [Configure Kubernetes]
TASK [Disable swap] ****
changed: [localhost]

TASK [Install containerd] ****
changed: [localhost]

TASK [Install kubelet, kubeadm, kubectl] ****
changed: [localhost]

PLAY [Deploy Application Configuration]
TASK [Create application directories] ****
changed: [localhost]

TASK [Create .env file] ****
changed: [localhost]

TASK [Create config.yaml] ****
changed: [localhost]

TASK [Copy application source] ****
changed: [localhost]

TASK [Install npm dependencies] ****
changed: [localhost]

TASK [Build application] ****
changed: [localhost]

PLAY RECAP ****
localhost : ok=32 changed=28 unreachable=0 failed=0
```

---

## Verification Steps

After playbook completes successfully:

### 1. Verify Packages Installed
```bash
# Check Node.js
node --version

# Check npm
npm --version

# Check Docker
docker --version

# Check Kubernetes
kubectl version --client
```

### 2. Check Services Running
```bash
# Docker service
sudo systemctl status docker

# Kubelet service
sudo systemctl status kubelet
```

### 3. Verify Configuration Files
```bash
# Check environment file
cat /etc/devops-lab/.env

# Check application config
cat /etc/devops-lab/config.yaml

# Check Docker daemon config
cat /etc/docker/daemon.json
```

### 4. Test Docker
```bash
# Run hello-world
docker run hello-world

# List Docker images
docker images

# Check Docker Compose
docker-compose --version
```

### 5. Verify Application Build
```bash
# Check if application built
ls -la /opt/devops-lab/dist/

# Check logs
cat /var/log/devops-lab/*.log
```

---

## Troubleshooting

### Issue 1: "Permission denied" running docker commands
**Solution:**
```bash
# Reset SSH connection after user added to docker group
exit
# Reconnect SSH

# Or add user to docker group manually
sudo usermod -aG docker $USER
newgrp docker
```

### Issue 2: "command not found: ansible"
**Solution:**
```bash
# Reinstall Ansible
sudo apt update
sudo apt install -y ansible

# Verify
ansible --version
```

### Issue 3: "Connection refused" on remote hosts
**Solution:**
```bash
# Check SSH connectivity
ssh -i /path/to/key.pem ec2-user@10.0.1.100

# Check security group allows SSH (port 22)
# Check instance is running and has public IP

# Update inventory with correct IP
nano ansible/inventory/hosts.ini
```

### Issue 4: "Failed to validate module with Ansible"
**Solution:**
```bash
# Update Ansible
sudo apt update
sudo apt install -y --upgrade ansible

# Or reinstall
sudo apt remove -y ansible
sudo apt install -y ansible
```

### Issue 5: Playbook takes too long
**Solution:**
```bash
# Run specific tags only
ansible-playbook playbook.yaml --tags docker

# Skip certain tasks
ansible-playbook playbook.yaml --skip-tags kubernetes

# Check what's hanging
ansible-playbook playbook.yaml -vvv
```

---

## Security Best Practices

### 1. Use Ansible Vault for Secrets
```bash
# Create vault file with passwords
ansible-vault create ansible/vars/secrets.yml

# Encrypt sensitive data
db_password: my_secure_password
redis_password: my_redis_pass

# Run playbook with vault
ansible-playbook playbook.yaml --ask-vault-pass
```

### 2. Use SSH Keys Instead of Passwords
```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_devops

# Use in inventory
[kubernetes_hosts]
eks-node-1 ansible_host=10.0.1.100 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/id_devops

# Run with key
ansible-playbook playbook.yaml -v
```

### 3. Limit Playbook Access
```bash
# Run playbook on specific hosts only
ansible-playbook playbook.yaml -l prod_environment

# Dry-run before applying
ansible-playbook playbook.yaml --check
```

### 4. Use Groups for Role-Based Control
```ini
[admins]
admin-node

[workers]
worker-1
worker-2

[prod_environment]
admin-node
worker-1
worker-2
```

---

## Next Steps

1. ✅ Review all files in `ansible/` directory
2. ✅ Test with `ansible all -m ping`
3. ✅ Run `ansible-playbook playbook.yaml --check` (dry-run)
4. ✅ Run `ansible-playbook playbook.yaml` (full execution)
5. ✅ Verify with: `docker --version`, `kubectl version --client`
6. ✅ Take screenshots of successful output
7. ✅ Document in deliverables:
   - Screenshot of playbook execution
   - Output showing successful configuration
   - Verification commands output

---

## Summary

| Component | Purpose |
|-----------|---------|
| **playbook.yaml** | Main orchestration (install, configure, deploy) |
| **inventory/hosts.ini** | Define hosts to configure |
| **roles/** | Reusable task sets (dependencies, docker, k8s, app) |
| **group_vars/all.yaml** | Global variables |
| **ansible.cfg** | Ansible settings |

| Command | Purpose |
|---------|---------|
| `ansible all -m ping` | Test connectivity |
| `ansible-playbook playbook.yaml` | Run full playbook |
| `ansible-playbook playbook.yaml --check` | Dry-run only |
| `ansible-playbook playbook.yaml --tags docker` | Run Docker role only |
| `ansible-playbook playbook.yaml -v` | Verbose output |

**Total Time**: 15-20 minutes for full execution on local machine  
**Estimated Time After AWS Deploy**: 10-15 minutes for 2 EKS nodes

---

## Documentation Files

- [playbook.yaml](playbook.yaml) - Main playbook
- [inventory/hosts.ini](inventory/hosts.ini) - Host definitions
- [roles/dependencies/tasks/main.yaml](roles/dependencies/tasks/main.yaml) - Install dependencies
- [roles/docker/tasks/main.yaml](roles/docker/tasks/main.yaml) - Configure Docker
- [roles/kubernetes/tasks/main.yaml](roles/kubernetes/tasks/main.yaml) - Configure Kubernetes
- [roles/app_config/tasks/main.yaml](roles/app_config/tasks/main.yaml) - Deploy app config
- [group_vars/all.yaml](group_vars/all.yaml) - Global variables
- [ansible.cfg](ansible.cfg) - Configuration

# Quick Start: Ansible Execution for DevOps Lab

## 5-Minute Quick Start

### 1. Verify Ansible is Installed in Ubuntu/WSL
```bash
# From your Ubuntu terminal (WSL)
ansible --version

# If not installed:
sudo apt update
sudo apt install -y ansible
```

### 2. Navigate to Ansible Directory
```bash
cd /path/to/devops-lab/ansible

# List files to verify setup
ls -la
# Should show:
# playbook.yaml
# ansible.cfg
# inventory/
# roles/
# group_vars/
```

### 3. Test Connectivity (Local)
```bash
# This tests if Ansible can reach localhost
ansible all -i inventory/hosts.ini -m ping

# Expected output:
# localhost | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }
```

### 4. Run Full Playbook (First Time)
```bash
# Dry-run first (safe, no changes)
ansible-playbook -i inventory/hosts.ini playbook.yaml --check -v

# If check passes, run actual playbook
ansible-playbook -i inventory/hosts.ini playbook.yaml -v
```

### 5. Verify Success
```bash
# Check if Docker installed
docker --version

# Check if Kubernetes tools installed
kubectl version --client

# Check if Node.js installed
node --version

# Check application config created
cat /etc/devops-lab/.env
```

---

## Commands Reference

### Run Full Playbook
```bash
ansible-playbook -i inventory/hosts.ini playbook.yaml
```

### Run Specific Role Only
```bash
# Dependencies only
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags dependencies

# Docker only
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags docker

# Kubernetes only
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags kubernetes

# App config only
ansible-playbook -i inventory/hosts.ini playbook.yaml --tags app_config
```

### Dry-Run (Check What Will Change)
```bash
ansible-playbook -i inventory/hosts.ini playbook.yaml --check
```

### Verbose Output
```bash
# More details
ansible-playbook -i inventory/hosts.ini playbook.yaml -v

# Extra verbose
ansible-playbook -i inventory/hosts.ini playbook.yaml -vvv
```

### Test Connectivity
```bash
ansible all -i inventory/hosts.ini -m ping
```

### Run on Specific Hosts
```bash
# Docker hosts only
ansible-playbook -i inventory/hosts.ini playbook.yaml -l docker_hosts

# Kubernetes hosts only
ansible-playbook -i inventory/hosts.ini playbook.yaml -l kubernetes_hosts
```

---

## Expected Execution Times

| Task | Time |
|------|------|
| Full playbook (local) | 15-20 minutes |
| Dependencies role | 5 minutes |
| Docker role | 3 minutes |
| Kubernetes role | 5 minutes |
| App config role | 2 minutes |
| **Total** | **~15-20 minutes** |

---

## Success Indicators

After playbook completes, you should see:

```
PLAY RECAP ****
localhost : ok=32 changed=28 unreachable=0 failed=0
```

Then verify:
```bash
# Check Docker
docker run hello-world

# Check Kubernetes
kubectl version --client

# Check Node.js
node --version
npm --version

# Check application
ls -la /opt/devops-lab/
cat /etc/devops-lab/.env
cat /etc/devops-lab/config.yaml
```

---

## Troubleshooting Quick Fixes

### Ansible not found
```bash
sudo apt install -y ansible
```

### Permission denied
```bash
sudo chmod 755 /etc/devops-lab
```

### SSH connection issues
```bash
# Test SSH connectivity
ssh localhost
# Should connect successfully
```

### Docker permission denied
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in
exit
```

---

## Files Created by Ansible

After successful run, you'll have:

```
/opt/devops-lab/
├── app/           (application source)
├── config/        (configs)
└── package.json

/etc/devops-lab/
├── .env           (environment variables)
├── config.yaml    (application config)

/var/log/devops-lab/
└── app/           (logs)

/etc/docker/
└── daemon.json    (Docker configuration)
```

---

## Taking Screenshots for Deliverables

### Screenshot 1: Playbook Execution
```bash
# Run playbook and capture output
ansible-playbook -i inventory/hosts.ini playbook.yaml -v | tee playbook_output.txt

# Screenshot the terminal output showing successful run
# Key lines to capture:
# - Task names
# - "ok" or "changed" status
# - Final "PLAY RECAP" showing 0 failed
```

### Screenshot 2: Verification Commands
```bash
# Run verification commands
echo "=== Docker ===" && docker --version
echo "=== Kubernetes ===" && kubectl version --client
echo "=== Node.js ===" && node --version
echo "=== npm ===" && npm --version
echo "=== App Config ===" && cat /etc/devops-lab/.env
echo "=== Services ===" && sudo systemctl status docker
```

### Screenshot 3: Docker Hello World Test
```bash
docker run hello-world
# Capture the output showing successful run
```

---

## Deliverables Checklist

- [ ] Ansible playbook created (`ansible/playbook.yaml`)
- [ ] Inventory file configured (`ansible/inventory/hosts.ini`)
- [ ] All roles created:
  - [ ] dependencies/tasks/main.yaml
  - [ ] docker/tasks/main.yaml
  - [ ] kubernetes/tasks/main.yaml
  - [ ] app_config/tasks/main.yaml
- [ ] Playbook executed successfully
- [ ] Screenshots taken:
  - [ ] Playbook execution output
  - [ ] Verification commands output
  - [ ] System information showing installed packages
  - [ ] Service status (docker running)
- [ ] Documentation:
  - [ ] STEP4_ANSIBLE_GUIDE.md (comprehensive guide)
  - [ ] This quick start guide

---

## Next: Integration with Terraform

When ready to deploy to AWS:

```bash
# 1. Deploy infrastructure
cd infra
terraform apply

# 2. Get node IPs
terraform output eks_node_ips

# 3. Update inventory
nano ../ansible/inventory/hosts.ini

# 4. Set SSH key
export SSH_KEY="/path/to/aws_key.pem"

# 5. Configure EKS nodes
cd ../ansible
ansible-playbook -i inventory/hosts.ini playbook.yaml \
  -u ec2-user \
  --private-key=$SSH_KEY \
  -v
```

---

## Getting Help

If stuck, check:
1. [STEP4_ANSIBLE_GUIDE.md](STEP4_ANSIBLE_GUIDE.md) - Full documentation
2. Run with verbose: `ansible-playbook playbook.yaml -vvv`
3. Check logs: `tail -f ansible.log`
4. Verify connectivity: `ansible all -m ping`

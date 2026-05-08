# Production-Ready Application Deployment

**DevOps Engineer Assessment Project**  
Automated deployment of a containerized Node.js microservice on AWS EC2 using Terraform and GitHub Actions.

---

## Architecture Overview

**[PLACEHOLDER: Insert architecture diagram here - see diagram section below]**

### Infrastructure Components

- **Application**: Node.js Express microservice
- **Containerization**: Docker
- **Cloud Provider**: AWS (eu-west-2)
- **Compute**: EC2 t2.micro instance
- **Networking**: VPC with public subnet, Internet Gateway, Security Group
- **CI/CD**: GitHub Actions
- **Container Registry**: Docker Hub
- **Monitoring**: AWS CloudWatch

### Architecture Flow
Developer Push (main branch)
↓
GitHub Actions CI/CD Pipeline
↓
├─→ Run Tests (Jest)
├─→ Build Docker Image
├─→ Push to Docker Hub
└─→ Deploy to EC2 via SSH
↓
EC2 Instance (eu-west-2)
↓
Docker Container (Node.js App)
↓
CloudWatch Monitoring

---

## Design Decisions

### Why EC2 over ECS/EKS?
- **Simplicity**: Direct control over deployment process
- **Cost-effective**: Single instance suitable for demo workload
- **Learning value**: Full control over container orchestration
- **Quick iteration**: Faster debugging during development

### Terraform Modular Structure
terraform/
├── main.tf                 # Root module
├── outputs.tf              # Infrastructure outputs
├── variables.tf            # Input variables
├── modules/
│   ├── networking/         # VPC, subnet, IGW, routes
│   └── ec2/                # Instance, security group, key pair

**Why modular?**
- Reusability across environments (dev/staging/prod)
- Easier testing and maintenance
- Clear separation of concerns

### CI/CD Pipeline Stages
1. **Test**: Jest with coverage reporting
2. **Build**: Docker image creation
3. **Push**: Image tagged with commit SHA + latest
4. **Deploy**: SSH into EC2, pull latest image, restart container

**Why GitHub Actions?**
- Native GitHub integration
- Free for public repos
- Clear YAML-based configuration
- Better suited for this assessment than Jenkins (simpler setup)

### Security Considerations
- SSH key pair managed via Terraform
- Secrets stored in GitHub Actions (not committed)
- Security group restricts inbound traffic:
  - Port 22 (SSH) - your IP only (best practice: use bastion)
  - Port 80 (HTTP) - public access
- Docker Hub credentials never exposed in logs

---

## Deployment Steps

### Prerequisites
- AWS account with IAM user credentials
- Terraform installed (>= 1.6.0)
- Docker Hub account
- GitHub repository

### 1. Clone Repository
```bash
git clone <your-repo-url>
cd <repo-name>
```

### 2. Configure AWS Credentials
```bash
aws configure
# Enter AWS_ACCESS_KEY_ID
# Enter AWS_SECRET_ACCESS_KEY
# Region: eu-west-2
```

### 3. Generate SSH Key Pair
```bash
ssh-keygen -t ed25519 -f ~/.ssh/devops-challenge
# Public key will be used by Terraform
# Private key stays local (never committed)
```

### 4. Terraform Provisioning
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

**Expected outputs:**
- EC2 public IP
- Instance ID
- SSH command

### 5. Configure GitHub Secrets
Navigate to: **GitHub → Settings → Secrets and variables → Actions**

Add these secrets:
| Secret | Value |
|--------|-------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key |
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token |
| `EC2_HOST` | EC2 public IP (from Terraform output) |
| `EC2_SSH_KEY` | Contents of `~/.ssh/devops-challenge` (private key) |

### 6. Trigger Deployment
```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

GitHub Actions will automatically:
- Run tests
- Build Docker image
- Push to Docker Hub
- Deploy to EC2

### 7. Verify Deployment
```bash
# Check application is running
curl http://<EC2_PUBLIC_IP>/health

# Expected response:
{
  "status": "healthy",
  "timestamp": "2025-05-08T...",
  "version": "1.0.0"
}
```

---

## Monitoring & Logging

### CloudWatch Configuration

**[PLACEHOLDER: Insert CloudWatch dashboard screenshot]**

#### 1. EC2 Instance Metrics (Automatic)
AWS CloudWatch automatically tracks:
- CPU Utilization
- Network In/Out
- Status Checks (System + Instance)

Access: **EC2 Console → Select Instance → Monitoring tab**

#### 2. CloudWatch Alarms

**CPU Utilization Alarm**  
**[PLACEHOLDER: Insert alarm configuration screenshot]**

- **Metric**: CPUUtilization > 70%
- **Period**: 5 minutes
- **Action**: SNS notification (optional)
- **Purpose**: Detect performance degradation

**Status Check Alarm**  
**[PLACEHOLDER: Insert status check alarm screenshot]**

- **Metric**: StatusCheckFailed_Instance
- **Purpose**: Detect EC2 instance failures

#### 3. Application Health Monitoring
The app exposes a `/health` endpoint:
```bash
curl http://<EC2_IP>/health
```

This can be used by:
- Load balancers (in production)
- External monitoring tools (Uptime Robot, Pingdom)
- CloudWatch Synthetics (advanced)

#### 4. Application Logs
Docker container logs are accessible via:
```bash
ssh -i ~/.ssh/devops-challenge ubuntu@<EC2_IP>
docker logs <container_name>
```

**[PLACEHOLDER: Insert sample log output screenshot]**

---

## Testing

### Local Testing
```bash
cd app
npm install
npm test
```

**Coverage Report:**  
**[PLACEHOLDER: Insert Jest coverage screenshot]**

### CI Testing
Tests run automatically on every push:
- All endpoints tested (/, /health, /api/info)
- Coverage threshold: 80%

---

## Technologies Used

| Component | Technology | Version |
|-----------|-----------|---------|
| Infrastructure | Terraform | 1.6.0 |
| Cloud Provider | AWS | eu-west-2 |
| Compute | EC2 | t2.micro |
| Containerization | Docker | 24.x |
| CI/CD | GitHub Actions | - |
| Container Registry | Docker Hub | - |
| Application | Node.js + Express | 18.x |
| Testing | Jest + Supertest | 29.x |
| Monitoring | AWS CloudWatch | - |

---

## Assumptions

1. **Single-region deployment**: Application runs in `eu-west-2` only
2. **No database**: Stateless microservice (no persistent storage)
3. **HTTP only**: No SSL/TLS (production would use HTTPS + ALB)
4. **Single instance**: No auto-scaling or load balancing
5. **Basic security**: Security group allows SSH from anywhere (production: use bastion host)
6. **GitHub Actions**: Used instead of Jenkins for simplicity
7. **Docker Hub**: Public registry (production: use ECR)

---

## Limitations & Future Improvements

### Current Limitations
1. **No HTTPS**: Application serves HTTP only
2. **No auto-scaling**: Single EC2 instance (no redundancy)
3. **No database**: Stateless application only
4. **Basic logging**: No centralized log aggregation (ELK, CloudWatch Logs)
5. **Manual secret management**: Secrets in GitHub (production: use AWS Secrets Manager)
6. **No blue-green deployment**: Downtime during updates

### Recommended Production Improvements

#### High Priority
- [ ] **HTTPS with Certificate Manager**: SSL/TLS encryption
- [ ] **Application Load Balancer**: Better traffic management
- [ ] **Auto Scaling Group**: Handle traffic spikes
- [ ] **RDS Database**: Persistent storage layer
- [ ] **CloudWatch Log Groups**: Centralized logging
- [ ] **AWS Secrets Manager**: Secure secret rotation

#### Medium Priority
- [ ] **Multi-AZ deployment**: High availability
- [ ] **CloudFront CDN**: Global content delivery
- [ ] **Route 53 DNS**: Custom domain management
- [ ] **Terraform remote state**: S3 + DynamoDB locking
- [ ] **CI/CD improvements**: Staging environment, rollback strategy
- [ ] **Container scanning**: Trivy/Snyk in pipeline

#### Nice-to-Have
- [ ] **ECS/EKS migration**: Better container orchestration
- [ ] **Infrastructure testing**: Terratest
- [ ] **Prometheus + Grafana**: Advanced metrics
- [ ] **WAF**: Web application firewall
- [ ] **Backup strategy**: Automated snapshots

---

## Project Screenshots

### 1. Terraform Apply Success
**[PLACEHOLDER]**

### 2. GitHub Actions Pipeline Success
**[PLACEHOLDER]**

### 3. Docker Hub Image
**[PLACEHOLDER]**

### 4. Application Running on EC2
**[PLACEHOLDER]**

### 5. CloudWatch Dashboard
**[PLACEHOLDER]**

### 6. Health Check Response
**[PLACEHOLDER]**

---

## Contact

**Engineer**: Sang David  
**GitHub**: [github.com/officialsangdavid](https://github.com/officialsangdavid)  
**Blog**: [Hashnode](https://hashnode.com/@sang)

---

## License

This project is for assessment purposes.

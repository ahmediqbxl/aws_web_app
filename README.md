# DevOps Web Application Project

A production-ready, scalable web application deployment with infrastructure as code, CI/CD pipeline, and monitoring.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │  GitHub Actions │    │   Docker Hub    │
│                 │────│   CI/CD Pipeline│────│  Container Reg  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Terraform     │    │   AWS VPC       │    │   EC2 Instance  │
│ Infrastructure  │────│   + Security    │────│  + Docker      │
│   as Code      │    │   Groups        │    │   Compose      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │   Load Balancer │    │   CloudWatch    │
│   (Node.js)    │────│   + Auto Scaling│────│   Monitoring    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Docker
- Git

### 1. Clone the Repository
```bash
git clone https://github.com/ahmediqbxl/aws_web_app.git
cd aws_web_app
```

### 2. Configure AWS
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region (ca-central-1)
```

### 3. Deploy Infrastructure
```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

### 4. Deploy Application
```bash
cd ..
docker-compose up -d
```

### 5. Access Your Application
- **Application URL**: http://your-load-balancer-dns.ca-central-1.elb.amazonaws.com
- **Monitoring**: AWS CloudWatch Console

## Project Structure

```
aws_web_app/
├── infrastructure/          # Terraform infrastructure code
│   ├── main.tf            # Main infrastructure configuration
│   ├── variables.tf       # Variable definitions
│   ├── outputs.tf         # Output values
│   └── user_data.sh       # EC2 instance bootstrap script
├── application/            # Node.js web application
│   ├── src/               # Application source code
│   │   └── app.js         # Main application file
│   ├── test/              # Test files
│   │   └── app.test.js    # Unit and integration tests
│   ├── Dockerfile         # Container definition
│   ├── package.json       # Node.js dependencies
│   └── jest.config.js     # Jest test configuration
├── .github/               # GitHub Actions CI/CD workflows
│   └── workflows/         # CI/CD pipeline configurations
│       └── deploy.yml     # Main deployment workflow
├── monitoring/            # CloudWatch configurations
│   └── cloudwatch-dashboard.json  # CloudWatch dashboard definition
├── docker-compose.yml     # Local development and EC2 deployment
└── PROJECT_SUMMARY.md     # High-level project overview
```

## Infrastructure Components

### VPC & Networking
- **VPC**: Custom VPC with public and private subnets across 2 AZs
- **Security Groups**: Restrictive security groups following least privilege
- **Internet Gateway**: For public internet access
- **NAT Gateway**: For private subnet internet access

### Compute
- **EC2 Instance**: t3.micro (free tier eligible) with auto-scaling
- **Load Balancer**: Application Load Balancer with health checks
- **Auto Scaling Group**: Scales based on CPU/memory metrics

### Storage & Database
- **EBS Volumes**: GP3 volumes for cost optimization
- **S3**: For static assets and backups

## Monitoring & Observability

### CloudWatch Metrics
- **Infrastructure**: CPU, Memory, Network, Disk I/O
- **Application**: Request count, Response time, Error rate
- **Custom Metrics**: Business-specific KPIs

### Dashboards
- **Infrastructure Dashboard**: System health and performance
- **Application Dashboard**: User experience and business metrics

### Logs
- **CloudWatch Logs**: Centralized logging for all components
- **Log Insights**: Query and analyze logs in real-time

## CI/CD Pipeline

### GitHub Actions Workflow
1. **Build**: Build Docker image and run tests
2. **Test**: Execute unit and integration tests
3. **Security Scan**: Scan for vulnerabilities
4. **Push**: Push to Docker Hub
5. **Deploy**: Deploy to EC2 instance
6. **Health Check**: Verify deployment success

### Pipeline Triggers
- **Push to main**: Automatic deployment
- **Pull Request**: Run tests only
- **Manual**: Trigger deployment manually

## Deployment Strategies

### Current: Simple Rolling Update
- Zero-downtime deployments
- Health check verification
- Automatic rollback on failure

## Cost Optimization

### Current Setup (Monthly Estimate)
- **EC2 t3.micro**: ~$8.50/month
- **Load Balancer**: ~$18/month
- **Data Transfer**: ~$5/month
- **CloudWatch**: ~$2/month
- **Total**: ~$33.50/month

## Scaling & Performance

### Auto Scaling
- **CPU Threshold**: 70% average CPU utilization
- **Memory Threshold**: 80% memory utilization
- **Scale Out**: Add instances when thresholds exceeded
- **Scale In**: Remove instances when load decreases

### Performance Optimization
- **Load Balancer**: Distributes traffic across instances
- **Health Checks**: Ensures only healthy instances receive traffic
- **Connection Pooling**: Efficient database connections
- **Caching**: Redis for session storage (future enhancement)

### Debug Commands
```bash
# Check application status
docker-compose ps
docker-compose logs

# Check infrastructure
terraform show
terraform output

# Check CloudWatch metrics
aws cloudwatch get-metric-statistics
```

## Future Enhancements

### Phase 2: Advanced Orchestration
- Migrate to EKS for better scalability
- Add distributed tracing to tracks requests as they flow through different services, helping to identify performance bottlenecks and troubleshoot issues

### Phase 3: Advanced Monitoring
- Prometheus + Grafana stack
- ELK stack for logs
- Custom alerting and notifications

### Phase 4: Security & Compliance
- HashiCorp Vault for secrets
- AWS WAF (Web Application Firewall) to protect against common web exploits
- Compliance monitoring and reporting
# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

# Load Balancer Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

# Auto Scaling Group Outputs
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.desired_capacity
}

output "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.min_size
}

output "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.max_size
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

# IAM Role Outputs
output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2_role.arn
}

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

# CloudWatch Outputs
output "cpu_high_alarm_arn" {
  description = "ARN of the CPU high utilization alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "cpu_low_alarm_arn" {
  description = "ARN of the CPU low utilization alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_low.arn
}

# S3 Bucket Outputs
output "terraform_state_bucket" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_state_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

# DynamoDB Outputs
output "terraform_lock_table" {
  description = "Name of the DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "terraform_lock_table_arn" {
  description = "ARN of the DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_state_lock.arn
}

# Application URLs
output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.main.dns_name}"
}

output "health_check_url" {
  description = "URL for health checks"
  value       = "http://${aws_lb.main.dns_name}/health"
}

output "metrics_url" {
  description = "URL for application metrics"
  value       = "http://${aws_lb.main.dns_name}/metrics"
}

# Monitoring URLs
output "cloudwatch_dashboard_url" {
  description = "URL for CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${var.project_name}-dashboard"
}

output "ec2_console_url" {
  description = "URL for EC2 console"
  value       = "https://${var.aws_region}.console.aws.amazon.com/ec2/v2/home?region=${var.aws_region}#Instances:tag:Name=${var.project_name}-instance"
}

output "alb_console_url" {
  description = "URL for ALB console"
  value       = "https://${var.aws_region}.console.aws.amazon.com/ec2/v2/home?region=${var.aws_region}#LoadBalancer:loadBalancerArn=${aws_lb.main.arn}"
}

# Cost Information
output "estimated_monthly_cost" {
  description = "Estimated monthly cost for the infrastructure"
  value = {
    ec2_instances = "${var.desired_capacity} x ${var.instance_type} = ~$${var.desired_capacity * 8.50}"
    load_balancer = "~$18.00"
    data_transfer = "~$5.00"
    cloudwatch    = "~$2.00"
    total         = "~$${var.desired_capacity * 8.50 + 25}"
  }
}

# Deployment Information
output "deployment_instructions" {
  description = "Instructions for deploying the application"
  value = <<-EOT
    Application Deployment Instructions:
    
    1. SSH to an EC2 instance:
       ssh -i your-key.pem ec2-user@<instance-ip>
    
    2. Install Docker and Docker Compose:
       sudo yum update -y
       sudo yum install -y docker
       sudo systemctl start docker
       sudo systemctl enable docker
       sudo usermod -a -G docker ec2-user
       sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
       sudo chmod +x /usr/local/bin/docker-compose
    
    3. Clone your repository:
       git clone <your-repo-url>
       cd aws_web_app
    
    4. Deploy the application:
       docker-compose up -d
    
    5. Verify deployment:
       curl http://localhost:3000/health
       curl http://localhost:3000/
    
    6. Access via Load Balancer:
       http://${aws_lb.main.dns_name}
    
    📊 Monitor your application:
    - CloudWatch: ${cloudwatch_dashboard_url}
    - Application: ${health_check_url}
    - Metrics: ${metrics_url}
    
    Estimated monthly cost: $${var.desired_capacity * 8.50 + 25}
  EOT
}

# Security Information
output "security_notes" {
  description = "Important security notes"
  value = <<-EOT
    Security Notes:
    
    IMPORTANT: The current SSH access is open to all IPs (0.0.0.0/0)
    For production, restrict SSH access to specific IP addresses by updating:
    - allowed_ssh_cidrs variable in terraform.tfvars
    
    IAM Roles:
    - EC2 instances have minimal required permissions
    - CloudWatch and SSM access only
    
    Network Security:
    - VPC with public/private subnet separation
    - Security groups with least privilege access
    - Load balancer in public subnets
    - Application instances in private subnets
    
    Recommendations:
    1. Enable AWS CloudTrail for API logging
    2. Set up AWS Config for compliance monitoring
    3. Implement AWS WAF for web application firewall
    4. Enable AWS GuardDuty for threat detection
    5. Regular security updates and patches
  EOT
} 
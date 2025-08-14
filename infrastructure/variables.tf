# AWS Configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ca-central-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-webapp"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "devops-team"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  validation {
    condition     = can(regex("^t3\\.", var.instance_type)) || can(regex("^t2\\.", var.instance_type))
    error_message = "Instance type should be t2 or t3 for cost optimization."
  }
}

# Auto Scaling Configuration
variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
  validation {
    condition     = var.desired_capacity >= 1 && var.desired_capacity <= 10
    error_message = "Desired capacity must be between 1 and 10."
  }
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
  validation {
    condition     = var.min_size >= 1 && var.min_size <= 5
    error_message = "Min size must be between 1 and 5."
  }
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 3
  validation {
    condition     = var.max_size >= 1 && var.max_size <= 10
    error_message = "Max size must be between 1 and 10."
  }
}

# Security Configuration
variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH to EC2 instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Warning: In production, restrict this to specific IPs
  validation {
    condition     = length(var.allowed_ssh_cidrs) > 0
    error_message = "At least one SSH CIDR block must be specified."
  }
}

# CloudWatch Configuration
variable "cloudwatch_log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 14
  validation {
    condition     = var.cloudwatch_log_retention_days >= 1 && var.cloudwatch_log_retention_days <= 3653
    error_message = "CloudWatch log retention must be between 1 and 3653 days."
  }
}

# Load Balancer Configuration
variable "alb_idle_timeout" {
  description = "Idle timeout for the Application Load Balancer (seconds)"
  type        = number
  default     = 60
  validation {
    condition     = var.alb_idle_timeout >= 1 && var.alb_idle_timeout <= 4000
    error_message = "ALB idle timeout must be between 1 and 4000 seconds."
  }
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Health check interval (seconds)"
  type        = number
  default     = 30
  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "Health check interval must be between 5 and 300 seconds."
  }
}

variable "health_check_timeout" {
  description = "Health check timeout (seconds)"
  type        = number
  default     = 5
  validation {
    condition     = var.health_check_timeout >= 2 && var.health_check_timeout <= 60
    error_message = "Health check timeout must be between 2 and 60 seconds."
  }
}

variable "healthy_threshold" {
  description = "Number of consecutive health checks to consider instance healthy"
  type        = number
  default     = 2
  validation {
    condition     = var.healthy_threshold >= 2 && var.healthy_threshold <= 10
    error_message = "Healthy threshold must be between 2 and 10."
  }
}

variable "unhealthy_threshold" {
  description = "Number of consecutive health checks to consider instance unhealthy"
  type        = number
  default     = 2
  validation {
    condition     = var.unhealthy_threshold >= 2 && var.unhealthy_threshold <= 10
    error_message = "Unhealthy threshold must be between 2 and 10."
  }
}

# Auto Scaling Policy Configuration
variable "scale_up_threshold" {
  description = "CPU utilization threshold to scale up"
  type        = number
  default     = 70
  validation {
    condition     = var.scale_up_threshold >= 50 && var.scale_up_threshold <= 90
    error_message = "Scale up threshold must be between 50 and 90."
  }
}

variable "scale_down_threshold" {
  description = "CPU utilization threshold to scale down"
  type        = number
  default     = 30
  validation {
    condition     = var.scale_down_threshold >= 10 && var.scale_down_threshold <= 50
    error_message = "Scale down threshold must be between 10 and 50."
  }
}

variable "scale_cooldown" {
  description = "Cooldown period for scaling actions (seconds)"
  type        = number
  default     = 300
  validation {
    condition     = var.scale_cooldown >= 60 && var.scale_cooldown <= 3600
    error_message = "Scale cooldown must be between 60 and 3600 seconds."
  }
}

# Tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "devops-webapp"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "devops-team"
    CostCenter  = "engineering"
    Backup      = "true"
  }
}

# Cost Optimization
variable "enable_cost_optimization" {
  description = "Enable cost optimization features"
  type        = bool
  default     = true
}

variable "use_spot_instances" {
  description = "Use spot instances for cost optimization (not recommended for production)"
  type        = bool
  default     = false
}

variable "spot_max_price" {
  description = "Maximum price for spot instances (as a percentage of on-demand price)"
  type        = string
  default     = "0.50"
  validation {
    condition     = can(regex("^0\\.[0-9]{1,2}$", var.spot_max_price))
    error_message = "Spot max price must be a decimal between 0.00 and 0.99."
  }
} 
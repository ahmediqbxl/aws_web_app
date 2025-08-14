#!/bin/bash

# User Data Script for EC2 Instance
# This script runs when the instance starts up

set -e

# Log all output to a file for debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "🚀 Starting user data script execution..."

# Update system packages
echo "📦 Updating system packages..."
yum update -y

# Install essential packages
echo "🔧 Installing essential packages..."
yum install -y \
    docker \
    git \
    curl \
    wget \
    unzip \
    jq \
    htop \
    tree \
    vim \
    amazon-cloudwatch-agent

# Start and enable Docker
echo "🐳 Starting Docker service..."
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
echo "👤 Adding ec2-user to docker group..."
usermod -a -G docker ec2-user

# Install Docker Compose
echo "📋 Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create application directory
echo "📁 Creating application directory..."
mkdir -p /opt/devops-webapp
cd /opt/devops-webapp

# Create a simple health check script
echo "🏥 Creating health check script..."
cat > /opt/devops-webapp/health_check.sh << 'EOF'
#!/bin/bash
# Health check script for the application

APP_URL="http://localhost:3000"
HEALTH_ENDPOINT="/health"

# Check if the application is responding
if curl -f -s "${APP_URL}${HEALTH_ENDPOINT}" > /dev/null; then
    echo "✅ Application is healthy"
    exit 0
else
    echo "❌ Application health check failed"
    exit 1
fi
EOF

chmod +x /opt/devops-webapp/health_check.sh

# Create application deployment script
echo "📝 Creating deployment script..."
cat > /opt/devops-webapp/deploy.sh << 'EOF'
#!/bin/bash
# Application deployment script

set -e

APP_DIR="/opt/devops-webapp"
REPO_URL="${REPO_URL:-https://github.com/yourusername/devops-webapp.git}"
BRANCH="${BRANCH:-main}"

echo "🚀 Starting application deployment..."

cd $APP_DIR

# Clone or pull the repository
if [ -d "devops-webapp" ]; then
    echo "📥 Pulling latest changes..."
    cd devops-webapp
    git pull origin $BRANCH
else
    echo "📥 Cloning repository..."
    git clone -b $BRANCH $REPO_URL
    cd devops-webapp
fi

# Build and start the application
echo "🐳 Building and starting application..."
docker-compose down || true
docker-compose build --no-cache
docker-compose up -d

# Wait for application to be ready
echo "⏳ Waiting for application to be ready..."
sleep 30

# Verify deployment
echo "🔍 Verifying deployment..."
if /opt/devops-webapp/health_check.sh; then
    echo "✅ Application deployed successfully!"
else
    echo "❌ Application deployment failed!"
    exit 1
fi
EOF

chmod +x /opt/devops-webapp/deploy.sh

# Create environment file
echo "⚙️ Creating environment configuration..."
cat > /opt/devops-webapp/.env << 'EOF'
# Application Environment Variables
NODE_ENV=production
PORT=3000
ALLOWED_ORIGINS=*

# Docker Compose Configuration
COMPOSE_PROJECT_NAME=devops-webapp
COMPOSE_FILE=docker-compose.yml

# Repository Configuration
REPO_URL=https://github.com/yourusername/devops-webapp.git
BRANCH=main
EOF

# Create systemd service for auto-restart
echo "🔄 Creating systemd service..."
cat > /etc/systemd/system/devops-webapp.service << 'EOF'
[Unit]
Description=DevOps Web Application
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/devops-webapp
ExecStart=/opt/devops-webapp/deploy.sh
ExecStop=/usr/local/bin/docker-compose down
User=ec2-user
Group=ec2-user
Environment=PATH=/usr/local/bin:/usr/bin:/bin
EnvironmentFile=/opt/devops-webapp/.env

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
systemctl enable devops-webapp.service

# Create CloudWatch agent configuration
echo "📊 Configuring CloudWatch agent..."
cat > /opt/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/user-data.log",
                        "log_group_name": "/ec2/devops-webapp/user-data",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/docker",
                        "log_group_name": "/ec2/devops-webapp/docker",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    }
                ]
            }
        }
    },
    "metrics": {
        "metrics_collected": {
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
systemctl start amazon-cloudwatch-agent
systemctl enable amazon-cloudwatch-agent

# Create log rotation configuration
echo "📋 Configuring log rotation..."
cat > /etc/logrotate.d/devops-webapp << 'EOF'
/var/log/user-data.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF

# Set up monitoring and alerting
echo "🔔 Setting up basic monitoring..."

# Create a simple monitoring script
cat > /opt/devops-webapp/monitor.sh << 'EOF'
#!/bin/bash
# Simple monitoring script

LOG_FILE="/var/log/devops-webapp-monitor.log"
APP_URL="http://localhost:3000"

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# Check application health
check_health() {
    if curl -f -s "${APP_URL}/health" > /dev/null; then
        log "✅ Health check passed"
        return 0
    else
        log "❌ Health check failed"
        return 1
    fi
}

# Check disk usage
check_disk() {
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ $DISK_USAGE -gt 80 ]; then
        log "⚠️  Disk usage is high: ${DISK_USAGE}%"
    else
        log "💾 Disk usage: ${DISK_USAGE}%"
    fi
}

# Check memory usage
check_memory() {
    MEM_USAGE=$(free | awk 'NR==2{printf "%.2f", $3*100/$2}')
    log "🧠 Memory usage: ${MEM_USAGE}%"
}

# Main monitoring loop
log "🚀 Starting monitoring..."
while true; do
    check_health
    check_disk
    check_memory
    sleep 60
done
EOF

chmod +x /opt/devops-webapp/monitor.sh

# Create a cron job for the monitoring script
echo "*/5 * * * * /opt/devops-webapp/monitor.sh" | crontab -

# Set proper permissions
echo "🔐 Setting proper permissions..."
chown -R ec2-user:ec2-user /opt/devops-webapp
chmod -R 755 /opt/devops-webapp

# Create a simple status page
echo "📄 Creating status page..."
cat > /opt/devops-webapp/status.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>DevOps WebApp Status</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .status { padding: 20px; margin: 10px 0; border-radius: 5px; }
        .healthy { background-color: #d4edda; color: #155724; }
        .unhealthy { background-color: #f8d7da; color: #721c24; }
        .info { background-color: #d1ecf1; color: #0c5460; }
    </style>
</head>
<body>
    <h1>🚀 DevOps WebApp Status</h1>
    <div class="status info">
        <h2>Instance Information</h2>
        <p><strong>Instance ID:</strong> <span id="instance-id">Loading...</span></p>
        <p><strong>Region:</strong> <span id="region">Loading...</span></p>
        <p><strong>Launch Time:</strong> <span id="launch-time">Loading...</span></p>
    </div>
    <div class="status" id="app-status">
        <h2>Application Status</h2>
        <p>Checking application health...</p>
    </div>
    <div class="status info">
        <h2>Quick Actions</h2>
        <p><a href="/health">Health Check</a> | <a href="/metrics">Metrics</a> | <a href="/">Application</a></p>
    </div>
    <script>
        // Simple status checking
        fetch('/health')
            .then(response => response.json())
            .then(data => {
                document.getElementById('app-status').className = 'status healthy';
                document.getElementById('app-status').innerHTML = '<h2>Application Status</h2><p>✅ Application is healthy</p><pre>' + JSON.stringify(data, null, 2) + '</pre>';
            })
            .catch(error => {
                document.getElementById('app-status').className = 'status unhealthy';
                document.getElementById('app-status').innerHTML = '<h2>Application Status</h2><p>❌ Application health check failed</p><p>Error: ' + error.message + '</p>';
            });
        
        // Get instance metadata
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => document.getElementById('instance-id').textContent = data);
        
        fetch('http://169.254.169.254/latest/meta-data/placement/region')
            .then(response => response.text())
            .then(data => document.getElementById('region').textContent = data);
        
        document.getElementById('launch-time').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

# Create a simple startup completion indicator
echo "🎯 Creating startup completion indicator..."
cat > /opt/devops-webapp/startup-complete << 'EOF'
DevOps WebApp startup completed successfully!
Timestamp: $(date)
Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)
Region: $(curl -s http://169.254.169.254/latest/meta-data/placement/region)
EOF

# Final setup steps
echo "🎉 User data script execution completed!"
echo "📋 Next steps:"
echo "   1. SSH to the instance: ssh -i your-key.pem ec2-user@<instance-ip>"
echo "   2. Navigate to: cd /opt/devops-webapp"
echo "   3. Deploy the application: ./deploy.sh"
echo "   4. Check status: ./health_check.sh"
echo "   5. View logs: tail -f /var/log/user-data.log"

# Mark startup as complete
touch /opt/devops-webapp/startup-complete

echo "✅ Startup process completed successfully!" 
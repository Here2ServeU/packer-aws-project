#!/bin/bash

# Wait for any pending system updates or processes to finish
sleep 10

# Kill any running yum processes
sudo pkill -9 yum || true

# Wait until the yum lock is released
while sudo fuser /var/run/yum.pid >/dev/null 2>&1; do 
    echo "Waiting for yum lock..."; 
    sleep 5; 
done

# Remove any lingering yum lock file
sudo rm -rf /var/run/yum.pid

# Stop and disable automatic yum updates (yum-cron)
sudo systemctl stop yum-cron || true
sudo systemctl disable yum-cron || true

# Clean yum cache and update the system
sudo yum clean all
sudo yum update -y

# Install Apache (httpd)
sudo yum install -y httpd

# Enable and start Apache service
sudo systemctl enable httpd
sudo systemctl start httpd

# Create a simple index.html page for verification
echo "<html><body><h1>Welcome to T2S Web Server</h1></body></html>" | sudo tee /var/www/html/index.html

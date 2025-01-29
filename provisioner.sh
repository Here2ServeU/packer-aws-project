#!/bin/bash
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

# Ensure the correct ownership and permissions
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# Now write the index.html file
echo "<h1>Welcome to My Web Server</h1>" | sudo tee /var/www/html/index.html

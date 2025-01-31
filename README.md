# Packer Project for Building AWS AMIs

This project demonstrates how to use **Packer** to automate the creation of custom Amazon Machine Images (AMIs) with the following steps:
1. Creating a Packer template file.
2. Creating a provisioner script.
3. Validating and building the image.

---

## **Step 1: Create a Packer Template File**

### 1. Pre-Requisites:
- Install **Packer**:
  - **Linux/MacOS**:
```bash
curl -fsSL https://releases.hashicorp.com/packer/1.8.6/packer_1.8.6_linux_amd64.zip -o packer.zip
unzip packer.zip
sudo mv packer /usr/local/bin/
```
  - **Windows**:
    Download Packer from the [official site](https://developer.hashicorp.com/packer/downloads) and follow the installation instructions.

- Verify installation:
```bash
packer version
```

- Configure AWS CLI with access credentials:
```bash
aws configure
```

### 2. Get the Packer Template:

- Download the project from the following repository:
```bash
git clone https://github.com/Here2ServeU/packer.git
cd packer/aws
```

## Step 2: Create the Provisioner Script

### 1. Define a Script to Install Required Packages:

Create a provisioner.sh file in the project directory with the following content:
```bash
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
```

### 2. Make the Script Executable:
```bash
chmod +x provisioner.sh
```

## Step 3: Validate and Build the Image

### 1. Validate the Packer Template:

Run the following command to ensure the Packer template is correctly configured:
```bash
packer validate aws-ami-packer.json
```

### 2. Build the Image:

Run the following command to build the AMI:
```bash
packer build aws-ami-packer.json
```

## Step 4: Verify the AMI
1.	Go to the AWS Management Console.

2.	Navigate to **EC2 Dashboard** > **AMIs**.

3.	Verify that your newly created AMI is listed.

Sample Packer Template (aws-ami-packer.json)
```json
{
  "builders": [
    {
      "type": "amazon-ebs",
      "region": "us-east-1",
      "source_ami": "ami-0c02fb55956c7d316", 
      "instance_type": "t2.micro",
      "ssh_username": "ec2-user",
      "ami_name": "t2s-demo-ami-{{timestamp}}"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "script": "provisioner.sh"
    }
  ]
}
```

4. Move to the web-app-create directory: 
- Change the variables.tf file to reflect the desired values:AMI, region, etc. 
- Run the following commands: 
```bash
terraform init
terraform plan
terraform apply
```
---
## Clean Up

To avoid incurring unnecessary charges, clean up resources:

### 1.	Delete the AMI:
```bash
aws ec2 deregister-image --image-id <ami-id>
```

### 2.	Terminate Any Instances:
- Run this command where your Terraform scripts reside (web-app-create directory).
```bash
terraform destroy
```

This project provides a comprehensive example of using Packer to automate the creation of AMIs with customized configurations. 


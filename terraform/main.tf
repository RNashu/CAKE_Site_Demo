provider "aws" {
  region = "ap-northeast-2" // Change to your desired AWS region
}

# Security Group
resource "aws_security_group" "devops_sg" {
  name        = "devops_sg"
  description = "Allow SSH, Jenkins, SonarQube, and App"

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SonarQube
  ingress {
    description = "SonarQube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application
  ingress {
    description = "App Port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance (Ubuntu)
resource "aws_instance" "devops_server" {
  ami                         = "ami-0662f4965dfc70aca"         # Replace with a valid Ubuntu AMI ID in your region
  instance_type               = "t3.medium"                     # You can change this as needed
  key_name                    = "Demo"                     # Replace with your existing EC2 key pair name
  vpc_security_group_ids      = [aws_security_group.devops_sg.id]

  user_data = <<-EOF
#!/bin/bash
apt update -y
apt upgrade -y

# Add 2GB swap (for SonarQube stability)
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
EOF

  tags = {
    Name = "DevOpsServer"
  }
}


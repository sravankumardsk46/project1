provider "aws" {
  region = "us-east-1"
}

# Security Group for Minikube
resource "aws_security_group" "minikube_sg" {
  name        = "minikube_sg"
  description = "Allow access for Minikube"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Minikube EC2 Instance
resource "aws_instance" "minikube" {
  ami           = "ami-08a52ddb321b32a8c"  # Ubuntu 22.04 AMI (Check latest in AWS)
  instance_type = "t2.medium"              # Minikube requires at least 2 CPUs & 2GB RAM
  key_name      = "your-key"                # Replace with your key pair name
  security_groups = [aws_security_group.minikube_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y curl wget apt-transport-https

    # Install Docker
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu

    # Install Minikube
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube /usr/local/bin/

    # Install Kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/

    # Start Minikube
    sudo minikube start --driver=docker

    # Configure kubectl
    sudo minikube kubectl -- get pods -A
  EOF

  tags = {
    Name = "Minikube-Server"
  }
}

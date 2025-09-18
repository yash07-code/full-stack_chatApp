provider "aws" {
  region = "us-east-1"
}

# ---------- Default VPC ----------
data "aws_vpc" "default" {
  default = true
}

# ---------- Security Group ----------
resource "aws_security_group" "docker_sg" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  # Allow SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP (for future containers/web apps)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- EC2 Instance ----------
resource "aws_instance" "my_ec2" {
  # Ubuntu 22.04 LTS AMI (for us-east-1)
  ami           = "ami-0e001c9271cf7f3b9"
  instance_type = "t2.micro"
  key_name      = "your-keypair-name"     # replace with your AWS key pair
  security_groups = [aws_security_group.docker_sg.name]

  tags = {
    Name = "MyUbuntuDockerEC2"
  }

  # Install Docker on Ubuntu
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable"
              apt-get update -y
              apt-get install -y docker-ce
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              EOF
}

# ---------- Outputs ----------
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.my_ec2.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.my_ec2.public_dns
}

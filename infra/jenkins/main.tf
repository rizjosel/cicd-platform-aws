resource "aws_security_group" "jenkins" {
  name   = "jenkins-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_instance" "jenkins" {
  ami                    = "ami-0df7a207adb9748c7" # Amazon Linux 2 (ap-southeast-1)
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name               = "cli-user"

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    # Update the system
    sudo apt update -y
    sudo apt upgrade -y

    # Install Java
    sudo apt install openjdk-11-jdk -y

    # Add Jenkins repo and key
    wget -O /etc/apt/sources.list.d/jenkins.list https://pkg.jenkins.io/debian-stable/jenkins.list
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc

    # Update and install Jenkins
    sudo apt update -y
    sudo apt install jenkins -y

    # Enable and start Jenkins service
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
  EOF


  tags = {
    Name = "jenkins-server"
  }
}
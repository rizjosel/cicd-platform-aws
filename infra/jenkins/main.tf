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
    yum update -y
    amazon-linux-extras install java-openjdk11 -y
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    yum install jenkins -y
    systemctl enable jenkins
    systemctl start jenkins
  EOF

  tags = {
    Name = "jenkins-server"
  }
}
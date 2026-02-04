resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow Jenkins access"
  vpc_id      = var.vpc_id 

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
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
  ami           = "ami-08d59269edddde222"
  instance_type = "t3.medium"
  subnet_id     = var.public_a_subnet_id
  associate_public_ip_address = true
  key_name      = "riz"

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = "jenkins"
  }
  user_data = <<-EOF
    #!/bin/bash
    set -eux

    DEVICE="/dev/nvme1n1"
    MOUNT_POINT="/var/lib/jenkins"

    # Wait for EBS
    while [ ! -b "$DEVICE" ]; do
    sleep 5
    done

    # Mount Jenkins home FIRST
    mkdir -p $MOUNT_POINT
    mount $DEVICE $MOUNT_POINT
    grep -q "$DEVICE" /etc/fstab || echo "$DEVICE $MOUNT_POINT xfs defaults,nofail 0 2" >> /etc/fstab

    # System deps
    apt-get update -y
    apt install -y openjdk-17-jdk

    # Jenkins repo (fixed key)
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
    | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/" \
    > /etc/apt/sources.list.d/jenkins.list

    apt-get update -y
    apt-get install -y jenkins

    # Permissions AFTER install
    chown -R jenkins:jenkins /var/lib/jenkins

    systemctl enable jenkins
    systemctl start jenkins
  EOF
}

data "aws_ebs_volume" "jenkins_data" {
  filter {
    name   = "volume-id"
    values = ["vol-0c181271c028452ee"]
  }
}

resource "aws_volume_attachment" "jenkins_attach" {
  device_name = "/dev/xvdf"
  volume_id   = data.aws_ebs_volume.jenkins_data.id
  instance_id = aws_instance.jenkins.id
}

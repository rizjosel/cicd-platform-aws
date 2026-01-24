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
  ami                    = "ami-08d59269edddde222" # Ubuntu Server 24.04 LTS (HVM)
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name               = "cli-user"

  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              sudo mkdir -p /jenkins-data

              # Check if volume is formatted
              if ! blkid /dev/nvme1n1; then
                sudo mkfs -t ext4 /dev/nvme1n1
              fi

              # Mount the volume
              sudo mount /dev/nvme1n1 /jenkins-data

              # Add to fstab if not already present
              grep -qxF '/dev/nvme1n1 /jenkins-data ext4 defaults,nofail 0 2' /etc/fstab || \
                echo '/dev/nvme1n1 /jenkins-data ext4 defaults,nofail 0 2' >> /etc/fstab
              EOF

  tags = {
    Name = "jenkins-server"
  }
}

resource "aws_ebs_volume" "jenkins_server_volume" {
  availability_zone = aws_instance.jenkins.availability_zone
  size              = 30
  type              = "gp3"
  tags = {
    Name = "jenkins-server-volume"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.jenkins_server_volume.id
  instance_id = aws_instance.jenkins.id
}
provider "aws" {
  region = "eu-west-1"
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins EC2"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Optional: Remove if using SSM
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"] # Or VPN CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami                    = "ami-0c94855ba95c71c99" # Amazon Linux 2
  instance_type          = "t3.small"
  subnet_id              = "your-private-subnet-id"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = false

  iam_instance_profile   = aws_iam_instance_profile.jenkins_ssm_profile.name

  tags = {
    Name = "jenkins-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker

              docker run -d \
                -p 8080:8080 \
                -p 50000:50000 \
                --name jenkins \
                -v jenkins_home:/var/jenkins_home \
                jenkins/jenkins:lts
            EOF
}

resource "aws_iam_role" "jenkins_ssm_role" {
  name = "jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_ssm_policy" {
  role       = aws_iam_role.jenkins_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jenkins_ssm_profile" {
  name = "jenkins-ec2-ssm-profile"
  role = aws_iam_role.jenkins_ssm_role.name
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a new VPC with public subnet and Internet Gateway
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "my-public-subnet"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my-route-table"
  }
}

resource "aws_route_table_association" "my_subnet_association" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}


# Create a security group
resource "aws_security_group" "my-sg" {
  name_prefix = "my-sg-"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create an EC2 instance in the public subnet
resource "aws_instance" "my_ec2_instance" {
  ami                    = "ami-006dcf34c09e50022" # Amazon Linux 2 AMI
  instance_type          = "t3.nano"
  subnet_id              = aws_subnet.my_public_subnet.id
  vpc_security_group_ids = [aws_security_group.my-sg.id]

  # Install Gunicorn using user data
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install python3 git -y
              sudo pip3 install gunicorn
              sudo pip3 install flask
              cd /opt
              git clone https://github.com/felipe284/desafio-devops-app.git
              cd desafio-devops-app/
              gunicorn --log-level debug -b 0.0.0.0:8000 api:app
              EOF

  tags = {
    Name = "gunicorn-app"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_instance_down" {
  alarm_name          = "EC2_Instance_Down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"

  dimensions = {
    InstanceId = "${aws_instance.my_ec2_instance.id}"
  }

  alarm_description = "Esta métrica monitora o status da instância EC2 e dispara um alarme se ela estiver inoperante."
  alarm_actions     = ["${aws_sns_topic.notification.arn}"]
}

resource "aws_sns_topic" "notification" {
  name = "EC2_Instance_Down_Notification"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.notification.arn
  protocol  = "email"
  endpoint  = "email@email.com"
}


output "ec2_global_ips" {
  value = ["Public IP:", "${aws_instance.my_ec2_instance.*.public_ip}"]
}

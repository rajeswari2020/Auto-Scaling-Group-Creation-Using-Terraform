provider "aws" {
  region = var.region
}

data "aws_vpc" "selected" {
  filter{
    name = "tag.Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "selected" {
  filter{
    name = "vpc_id"
    values = [data.aws_vpc.selected.id]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "Demo-Security-group"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.selected.id

  ingress{
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks   = ["0.0.0.0/0"]
  }

  ingress {
    from_port     = 80
    to_port       = 80
    protocol      = "tcp"
    cidr_blocks   = ["0.0.0.0/0"]
  }

  egress {
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    cidr_blocks         = ["0.0.0.0/0"]
  }
}


# Launch Template with Nginx installation
resource "aws_launch_template" "web_template" {
  name_prefix      = "web-template-"
  image_id         = var.ami_id
  instance_type    = var.instance_type
  key_name         = var.key_name

  user_data = base64encode(<<-EOF
     #!/bin/bash
     sudo apt update -y 
     sudo apt install nginx -y 
     sudo systemctl start nginx 
  EOF)

  block_device_mappings {
      device_name = "/dev/xvda"
      ebs{
        volume_size = var.volume_size
        volume_type = "gp2"
        deletion_on_termination = true
      }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.web_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-instance"
    }
  }

  update_default_version = true
}

# Auto Scaling group
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size
  vpc_zone_identifier = data.aws_subnets.selected.ids 

  launch_template {
    id = aws_launch_template.web_template.id
    version = "$Latest"
  }

  tag {
    key = "Name"
    value = "web-asg-instance"
    propagate_at_launch = true
  }

  health_check_type = "EC2"
  health_check_grace_period = 300
}
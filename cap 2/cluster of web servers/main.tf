terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.9.0"
    }
  }
}

# All resources will be created in this region
provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "ubuntu" {
  most_recent   = true

  filter {
    name        = "name"
    values      = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name        = "virtualization-type"
    values      = ["hvm"]
  }

  owners        = ["amazon"]
}

# Always looks up the latest Amazon Linux 2023 AMI
resource "aws_launch_template" "example" {
  image_id                  = data.aws_ami.ubuntu.id
  instance_type             = "t2.micro" 

  # For instance traffic       
  vpc_security_group_ids    = [aws_security_group.instance.id]

  # Same startup script as the single instance with base64encoding(required for launch template)
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "Hello, World from Apache!" > /var/www/html/index.html
    EOF

  # Ensure Terraform replaces old versions safely
  lifecycle {
    create_before_destroy   = true
  }

  tag_specifications {
    resource_type           = "instance"
    tags = {
      Name                  = "example"
    }
  }
}

# Default Virtual Private Cloud
data "aws_vpc" "default" {
  default = true 
}

# Default subnet
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_autoscaling_group" "example" {
  launch_template {
    id                    = aws_launch_template.example.id
  }

  # Deploys across all subnets in default VPC
  vpc_zone_identifier     = data.aws_subnets.default.ids 

  # Registers instances with Load Balancer target group
  target_group_arns       = [aws_lb_target_group.asg.arn] 

  #Health checks use ELB checks
  health_check_type       = "ELB"  

  min_size                = 2   
  max_size                = 10  

  tag {
    key                   = "Name"
    value                 = "terraform-asg-example"
    propagate_at_launch   = true
  }
}

resource "aws_lb" "example" {
  name               = "terraform-asg-example"
  load_balancer_type = "application" 

  # Spans all subnets in the default VPC
  subnets            = data.aws_subnets.default.ids  

  # Uses security group that allows HTTP traffic
  security_groups    = [aws_security_group.alb.id]  
}

# Configure listener for HTTP (port 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80   
  protocol          = "HTTP"

  # Default response
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

# Defines target group for ALB
resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  # Health check configuration
  health_check {
    path     = "/"              
    protocol = "HTTP"
    matcher  = "200"            
    interval = 15               
    timeout  = 3                
    healthy_threshold   = 2     
    unhealthy_threshold = 2     
  }
}

# Forward all HTTP requests (*) to ASG target group
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100  

  
  condition {
    path_pattern {
      values = ["*"]  
    }
  }

  
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

# Allows traffic on port 80
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"


  ingress {
    from_port   = var.server_port 
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]    
  }
}

# Allows HTTP in all outbound traffic out
resource "aws_security_group" "alb" {
  name = "terraform-example-alb"


  ingress {
    from_port   = 80          
    to_port     = 80
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

output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}
provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "test" {
  ami           = "ami-0169aa51f6faf20d5" # Amazon Linux 2023
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.test_group.id]

  # Script para instalar e configurar o servidor web Apache
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "Hello, World from Apache!" > /var/www/html/index.html
    EOF

  user_data_replace_on_change = true

  tags = {
    Name = "first-example"
  }
}

resource "aws_security_group" "test_group" {
  name = "terraform-example"

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
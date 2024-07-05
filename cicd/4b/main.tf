provider "aws" {
  region = "ap-south-1" # Specify your desired region
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Create Subnet
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "main-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Create Route Table
resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main-route-table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.routetable.id
}

# Create Security Group
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

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

  tags = {
    Name = "web-sg"
  }
}

# Create EC2 Instance
resource "aws_instance" "web" {
  ami             = "ami-0c2af51e265bd5e0e" # Ubuntu Server 20.04 LTS AMI for ap-south-1
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "nginx-server"
  }

  depends_on = [
    aws_internet_gateway.gw,
    aws_route_table_association.a,
    aws_security_group.web_sg
  ]
}

# Output the VPC ID
output "vpc_id" {
  value = aws_vpc.main.id
}

# Output the Subnet ID
output "subnet_id" {
  value = aws_subnet.subnet1.id
}

# Output the Security Group ID
output "security_group_id" {
  value = aws_security_group.web_sg.id
}

# Output the EC2 Instance Public IP
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

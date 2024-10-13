provider "aws" {
  region = var.aws_region # Change to your desired region
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create a subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a" # Change as necessary
}

# Create an internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Create a route table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Associate route table with the subnet
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Create a security group
resource "aws_security_group" "allow_http" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Change this to your IP for better security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "key_pair" {
  source             = "terraform-aws-modules/key-pair/aws"
  version            = "2.0.0"
  key_name           = "test-key-pair"
  create_private_key = true
}

resource "aws_ssm_parameter" "ssm_jumpbox_keypair" {
  name        = "/test"
  description = "Stores the private key of ec2 key pair"
  type        = "SecureString"
  value       = module.key_pair.private_key_pem
}

# Launch an EC2 instance
resource "aws_instance" "web" {
  ami           = var.ami_id # Change to the latest Amazon Linux 2 AMI ID
  instance_type = var.instance_type
  key_name      = "test-key-pair"
  subnet_id     = aws_subnet.main.id
  # security_groups = [aws_security_group.allow_http.name]
  vpc_security_group_ids      = [aws_security_group.allow_http.id]
  associate_public_ip_address = true
  user_data                   = file("nginx_user_data.sh")

  tags = {
    Name = "NginxServer"
  }
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}
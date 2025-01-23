terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-2"
}

resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "dev_vpc"
    Environment = "development"
  }
}

resource "aws_subnet" "dev_public_subnet" {
  vpc_id = aws_vpc.dev_vpc.id
  cidr_block = "10.1.0.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "dev_public_subnet"
    Environment = "development"
  }
}

resource "aws_subnet" "dev_private_subnet" {
  vpc_id = aws_vpc.dev_vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "dev_private_subnet"
    Environment = "development"
  }
}

resource "aws_internet_gateway" "dev_internet_gateway" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "dev_internet_gateway"
  }
}

resource "aws_route_table" "dev_route_table" {
  vpc_id = aws_vpc.dev_vpc.id

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_internet_gateway.id
  }

  tags = {
    Name = "dev_route_table"
  }
}

resource "aws_instance" "dev_ec2_instance_1" {
  ami = "ami-0cb91c7de36eed2cb" #Ubuntu 64-bit x86
  instance_type = "t2.micro"
  key_name = "webservers"
  security_groups = ["dev_security_group"]
  subnet_id = aws_subnet.dev_public_subnet.id
  associate_public_ip_address = true

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo systemctl enable apache2
                echo "Hello from Terraform!" > /var/www/html/index.html
              EOF

  tags = {
    Name = "EC2_Instance_1"
  }
}

resource "aws_instance" "dev_ec2_instance_2" {
  ami = "ami-0cb91c7de36eed2cb" #Ubuntu 64-bit x86
  instance_type = "t2.micro"
  key_name = "webservers"
  security_groups = ["dev_security_group"]
  subnet_id = aws_subnet.dev_public_subnet.id
  associate_public_ip_address = true

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo systemctl enable apache2
                echo "Hello from Terraform!" > /var/www/html/index.html
              EOF

  tags = {
    Name = "EC2_Instance_2"
  }
}

resource "aws_security_group" "dev_security_group" {
  name_prefix = "dev_security_group"

  ingress = {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress = {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "dev_db_subnet_group" {
  name = "dev_db_subnet_group"
  subnet_ids = [aws_subnet.dev_private_subnet.id]

  tags = {
    Name = "dev_db_subnet_group"
  }
}

resource "aws_security_group" "dev_db_security_group" {
  name = "dev_db_security_group"
  vpc_id = aws_vpc.dev_vpc.id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [
      "${aws_instance.dev_ec2_instance_1.private_ip}/32",
      "${aws_instance.dev_ec2_instance_2.private_ip}/32"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev_db_security_group"
  }
}

resource "aws_db_instance" "dev_postgres_instance" {
  allocated_storage = 1
  storage_type = "gp2"
  engine = "postgres"
  engine_version = "13.4"
  instance_class = "db.t3.micro"
  username = "admin"
  password = "yourpassword"
  parameter_group_name = "default.postgres13"

  db_subnet_group_name = aws_db_subnet_group.dev_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.dev_db_security_group.id]

  multi_az = false

  backup_retention_period = 7
  backup_window = "07:00-09:00"
  maintenance_window = "Mon:03:00-Mon:04:00"

  tags = {
    Name = "dev_postgres_instance"
  }
}
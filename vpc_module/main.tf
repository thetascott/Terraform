# VPC Creation
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name        = "${var.environment}_vpc"
    Environment = var.environment
  }
}

#declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

# Subnets (Public and Private)
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.environment}_public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidrs[1]
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.environment}_public_subnet_2"
  }
}

resource "aws_subnet" "private_subnet" {
  for_each = tomap({
    private_subnet_1 = var.private_subnet_cidrs[0]
    private_subnet_2 = var.private_subnet_cidrs[1]
  })

  vpc_id = aws_vpc.vpc.id
  cidr_block = each.value
  availability_zone = element(data.aws_availability_zones.available.names, index(var.private_subnet_cidrs, each.value))

  tags = {
    Name        = "${var.environment}_private_subnet_${each.key}"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}_internet_gateway"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "${var.environment}_nat_gateway"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  vpc = true

  tags = {
    Name = "${var.environment}_nat_gateway_eip"
  }
}

# EC2 Security Group
resource "aws_security_group" "ec2_security_group" {
  name_prefix = "${var.environment}_ec2_sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances
resource "aws_instance" "ec2_instance" {
  count = var.instance_count
  ami = "ami-0cb91c7de36eed2cb"
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  subnet_id = element(values(aws_subnet.private_subnet)[*].id, count.index)

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo systemctl enable apache2
                echo "Hello from Terraform!" > /var/www/html/index.html
              EOF

  tags = {
    Name = "${var.environment}_ec2_instance_${count.index + 1}"
  }
}

#EC2 jump server used to access instances in private subnets
resource "aws_instance" "ec2_instance_jump" {
  ami = "ami-0cb91c7de36eed2cb"
  instance_type = "t2.micro"
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  subnet_id = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true

  tags = {
    Name = "${var.environment}_ec2_instance_jump"
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "app_lb" {
  name = "${var.environment}-app-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.ec2_security_group.id]
  subnets = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "${var.environment}_app_alb"
  }
}

resource "aws_lb_target_group" "app_target_group" {
  name     = "${var.environment}-app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.environment}_app_target_group"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "target_group_attachment" {
  for_each = { for idx, instance in aws_instance.ec2_instance : idx => instance }

  target_group_arn = aws_lb_target_group.app_target_group.arn
  target_id        = each.value.id
  port             = 80
}

# RDS Database
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.environment}_db_subnet_group"
  subnet_ids = values(aws_subnet.private_subnet)[*].id

  tags = {
    Name = "${var.environment}_db_subnet_group"
  }
}

resource "aws_db_instance" "postgres_instance" {
  allocated_storage = 5
  storage_type      = "gp2"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  username          = var.db_username
  password          = var.db_password

  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name

  multi_az           = false
  skip_final_snapshot = true
  backup_retention_period = 7

  tags = {
    Name = "${var.environment}_postgres_instance"
  }
}
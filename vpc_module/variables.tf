variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, prod)"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDRs for the public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDRs for the private subnets"
}

variable "key_name" {
  type        = string
  description = "Name of the SSH key pair"
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 instances"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "db_instance_class" {
  type = string
  description = "Database instance class"
}

variable "db_username" {
  type        = string
  description = "RDS username"
}

variable "db_password" {
  type        = string
  description = "RDS password"
}
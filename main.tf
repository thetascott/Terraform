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

module "dev_vpc" {
  source            = "./vpc_module"
  environment       = "dev"
  region            = "us-east-2"
  vpc_cidr_block    = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
  key_name          = "webservers"
  instance_count    = 2
  instance_type     = "t2.micro"
  db_instance_class = "db.t3.micro"
  db_username       = "devadmin"
  db_password       = "devsecurepassword123"
}

module "prod_vpc" {
  source            = "./vpc_module"
  environment       = "prod"
  region            = "us-east-2"
  vpc_cidr_block    = "10.1.0.0/16"
  public_subnet_cidrs = ["10.1.0.0/24", "10.1.1.0/24"]
  private_subnet_cidrs = ["10.1.2.0/24", "10.1.3.0/24"]
  key_name          = "webservers"
  instance_count    = 2
  instance_type     = "t2.micro"
  db_instance_class = "db.t3.micro"
  db_username       = "prodadmin"
  db_password       = "prodsecurepassword123"
}
# AWS VPC Automation with Terraform 

This project was both fun to create! The Terraform module provisions a highly configurable AWS infrastructure, including:
* A VPC with public and private subnets.
* Two or more EC2 instances deployed in private subnets for enhanced security.
* An EC2 jump server in a public subnet to securely access private instances.
* An Application Load Balancer (ALB) to distribute traffic across instances.
* A PostgreSQL database hosted in private subnets, with a dedicated subnet group.

The infrastructure follows best practices for security and scalability, making it ideal for multi-environment setups like development and production.

## How to Run

### Prerequisites

1. Install Terraform (v1.2.0 or later).
2. Set up an AWS account and create a user with CLI access. Attach the necessary permissions.
3. Configure your AWS CLI with your credentials:
```
aws configure
```

### Steps

**1.	Clone the Repository:**
```
git clone https://github.com/thetascott/Terraform.git  
cd Terraform
```

**2.	Customize Variables:**
Update the variables.tf file or create a terraform.tfvars file to specify your desired configuration. For example:
```
environment = "dev"
region      = "us-east-2"
cidr_block  = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.0.0/24", "10.1.1.0/24"]
private_subnet_cidrs = ["10.1.2.0/24", "10.1.3.0/24"]
```

**3.	Initialize Terraform:**
Initialize the working directory to download the required providers and modules:
```
terraform init
```

**4.	Plan the Infrastructure:**
Review the resources that Terraform will create:
```
terraform plan
```

**5.	Apply the Configuration:**
Deploy the infrastructure by running:
```
terraform apply
```

### Clean Up

To tear down the infrastructure and avoid unnecessary charges, run:
```
terraform destroy
```

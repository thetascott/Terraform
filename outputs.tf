output "dev_vpc_id" {
  value = module.dev_vpc.vpc_id
}

output "prod_vpc_id" {
  value = module.prod_vpc.vpc_id
}

output "dev_public_subnet_1_id" {
  value = module.dev_vpc.public_subnet_1_id
}

output "prod_public_subnet_1_id" {
  value = module.prod_vpc.public_subnet_1_id
}

output "dev_public_subnet_2_id" {
  value = module.dev_vpc.public_subnet_2_id
}

output "prod_public_subnet_2_id" {
  value = module.prod_vpc.public_subnet_2_id
}

output "dev_instance_ids" {
  value = module.dev_vpc.instance_ids
}

output "prod_instance_ids" {
  value = module.prod_vpc.instance_ids
}

output "dev_instance_private_ips" {
  value = module.dev_vpc.instance_private_ips
}

output "prod_instance_private_ips" {
  value = module.prod_vpc.instance_private_ips
}

output "dev_jump_server_public_ip" {
  value = module.dev_vpc.jump_server_public_ip
}

output "prod_jump_server_public_ip" {
  value = module.prod_vpc.jump_server_public_ip
}

output "dev_alb_arn" {
  value = module.dev_vpc.alb_arn
}

output "prod_alb_arn" {
  value = module.prod_vpc.alb_arn
}

output "dev_alb_dns_name" {
  value = module.dev_vpc.alb_dns_name
}

output "prod_alb_dns_name" {
  value = module.prod_vpc.alb_dns_name
}

output "dev_db_instance_endpoint" {
  value = module.dev_vpc.db_instance_endpoint
}

output "prod_db_instance_endpoint" {
  value = module.prod_vpc.db_instance_endpoint
}
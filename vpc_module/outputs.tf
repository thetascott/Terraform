output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_1_id" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}

output "private_subnet_ids" {
  value = values(aws_subnet.private_subnet)[*].id
}

output "instance_ids" {
  value = aws_instance.ec2_instance[*].id
}

output "instance_private_ips" {
  value = aws_instance.ec2_instance[*].private_ip
}

output "jump_server_public_ip" {
  value = aws_instance.ec2_instance_jump.public_ip
}

output "alb_arn" {
  value = aws_lb.app_lb.arn
}

output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}

output "db_instance_endpoint" {
  value = aws_db_instance.postgres_instance.endpoint
}
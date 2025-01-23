output "dev_ec2_1_public_ip" {
  value = aws_instance.dev_ec2_instance_1.public_ip                                          # The actual value to be outputted
  description = "The public IP address of the EC2 instance" # Description of what this output represents
}

output "dev_ec2_2_public_ip" {
  value = aws_instance.dev_ec2_instance_2.public_ip                                          # The actual value to be outputted
  description = "The public IP address of the EC2 instance" # Description of what this output represents
}

output "dev_ec2_1_private_ip" {
  value = aws_instance.dev_ec2_instance_1.private_ip                                        # The actual value to be outputted
  description = "The public IP address of the EC2 instance" # Description of what this output represents
}

output "dev_ec2_2_private_ip" {
  value = aws_instance.dev_ec2_instance_2.private_ip                                      # The actual value to be outputted
  description = "The public IP address of the EC2 instance" # Description of what this output represents
}

output "dev_db_endpoint" {
  value = aws_db_instance.dev_postgres_instance.endpoint
  description = "Endpoint to the Postgres database"
}
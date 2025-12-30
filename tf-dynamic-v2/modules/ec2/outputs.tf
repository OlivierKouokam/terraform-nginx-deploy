output "ec2_id" {
  value = aws_instance.my_ec2.id
}

output "ec2_public_ip" {
  value = aws_instance.my_ec2.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.my_ec2.public_dns
}
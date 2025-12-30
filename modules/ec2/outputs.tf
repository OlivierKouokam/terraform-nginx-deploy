output "ec2_id" {
  description = "ec2 id"
  value = aws_instance.this.id
}
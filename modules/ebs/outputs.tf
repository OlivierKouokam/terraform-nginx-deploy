output "ebs_id" {
  description = "ebs id"
  value = aws_ebs_volume.this.id
}
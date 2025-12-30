output "eip_id" {
  description = "elastic ip id"
  value = aws_eip.this.id
}

output "eip_public_ip" {
  description = "eip public ip"
  value = aws_eip.this.public_ip
}

output "eip_public_dns" {
  description = "eip public dns"
  value = aws_eip.this.public_dns
}
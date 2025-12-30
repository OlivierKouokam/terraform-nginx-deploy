resource "aws_ebs_volume" "this" {
  availability_zone = var.ebs_az
  size              = var.ebs_size
  type = var.ebs_type
  encrypted = var.ebs_encrypted
  tags = var.ebs_tags
}
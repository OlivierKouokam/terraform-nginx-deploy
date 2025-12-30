
resource "aws_internet_gateway" "my_igw" {
  vpc_id = var.vpc_id

  tags = var.igw_tags
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "my_ec2" {
  subnet_id              = var.subnet_id
  ami                    = data.aws_ami.ubuntu.id
  availability_zone      = var.az
  instance_type          = var.instance_type
  vpc_security_group_ids = var.sg_ids
  key_name               = var.keypair_name
  tags = var.ec2_tags
  user_data = file(var.user_data_path)
}
data "aws_ami" "ubuntu_jammy" {
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

resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu_jammy.id
  # ami           = "ami-0aedf6b1cb669b4c7"
  # # ami           = "ami-0c1f3a8058fde8814"
  subnet_id     = var.ec2_subnet_id
  instance_type = var.ec2_instance_type
  vpc_security_group_ids = var.ec2_sg_ids
  key_name = var.ec2_key_name
  availability_zone = var.ec2_az
  tags = var.ec2_tags

  root_block_device {
    volume_type = "gp3"
    volume_size = var.ec2_root_volume_size  # ← Modifié de 30 à 50 GB
    throughput  = 125
    iops        = 3000
    encrypted   = true
  }
}
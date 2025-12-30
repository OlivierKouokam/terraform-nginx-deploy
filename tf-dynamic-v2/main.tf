module "dynamic_vpc" {
  source         = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  vpc_tags = {
    "Name" = "dynamic-vpc"
  }
}

module "dynamic_igw" {
  source = "./modules/igw"
  vpc_id = module.dynamic_vpc.vpc_id
  igw_tags = {
    "Name" = "dynamic-igw"
  }
}

module "dynamic_subnet" {
  source            = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  subnet_tags = {
    "Name" = "dynamic-public-subnet"
  }
  az     = var.dynamic_az
  vpc_id = module.dynamic_vpc.vpc_id
}

module "dynamic_rtb" {
  source = "./modules/rtb"
  vpc_id = module.dynamic_vpc.vpc_id
  rtb_tags = {
    "Name" = "dynamic-rtb"
  }
}

resource "aws_route" "my_route" {
  route_table_id         = module.dynamic_rtb.rtb_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.dynamic_igw.igw_id
}

resource "aws_route_table_association" "my_rta" {
  subnet_id      = module.dynamic_subnet.subnet_id
  route_table_id = module.dynamic_rtb.rtb_id
}

module "dynamic_eip" {
  source = "./modules/eip"
}

module "dynamic_sg" {
  source  = "./modules/sg"
  sg_name = var.sg_name
  vpc_id  = module.dynamic_vpc.vpc_id
  sg_tags = {
    "Name" = "dynamic-sg"
  }
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 1993
      to_port     = 1993
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "dynamic-ec2" {
  source         = "./modules/ec2"
  az             = var.dynamic_az
  instance_type  = var.instance_type
  keypair_name   = var.keypair_name
  user_data_path = var.user_data_path
  subnet_id      = module.dynamic_subnet.subnet_id
  sg_ids         = [module.dynamic_sg.sg_id]
  ec2_tags = {
    "Name" = "dynamic-ec2"
  }
}

resource "null_resource" "posts_apply" {
  depends_on = [aws_eip_association.eip_assoc]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(".secrets/tf-keypair.pem")
      host        = module.dynamic_eip.eip_public_ip
    }
    inline = [
      "sleep 60",
      "sudo docker run -d --name eazylabs --privileged -v /var/run/docker.sock:/var/run/docker.sock -p 1993:1993 eazytraining/eazylabs:latest",
      "sudo docker run -d --name nginx -p 80:80 nginx:1.28"
    ]
  }

  provisioner "local-exec" {
    command = "echo ELASTIC_IP: ${module.dynamic-ec2.ec2_public_ip} > public_ip.txt"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = module.dynamic-ec2.ec2_id
  allocation_id = module.dynamic_eip.eip_id
}
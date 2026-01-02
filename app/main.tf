module "nginx_vpc" {
  source         = "../modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  vpc_tags = {
    "Name" = "nginx-vpc"
  }
}

module "nginx_igw" {
  source = "../modules/igw"
  vpc_id = module.nginx_vpc.vpc_id
  igw_tags = {
    "Name" = "nginx-igw"
  }
}

module "nginx_subnet" {
  source            = "../modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  subnet_tags = {
    "Name" = "nginx-public-subnet"
  }
  az     = var.app_az
  vpc_id = module.nginx_vpc.vpc_id
}

module "nginx_rtb" {
  source = "../modules/rtb"
  vpc_id = module.nginx_vpc.vpc_id
  rtb_tags = {
    "Name" = "nginx-rtb"
  }
}

module "nginx_internet_route" {
  source = "../modules/route"
  route_table_id = module.nginx_rtb.rtb_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.nginx_igw.igw_id
}

resource "aws_route_table_association" "my_rta" {
  subnet_id      = module.nginx_subnet.subnet_id
  route_table_id = module.nginx_rtb.rtb_id
}


module "nginx_sg" {
  source = "../modules/sg"
  sg_vpc_id = module.nginx_vpc.vpc_id
  sg_name = "nginx_sg"
  sg_tags = {
    Name = "nginx-sg"
  }

  ingress_rules = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "allow SSH inbound traffic" },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "allow HTTP inbound traffic" },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "allow HTTPS inbound traffic" }
    # { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"], description = "allow all traffic" }
  ]
}

module "nginx_ec2" {
  source = "../modules/ec2"
  ec2_subnet_id = module.nginx_subnet.subnet_id
  ec2_az            = var.app_az
  ec2_instance_type = "t3.medium"
  ec2_key_name      = "app-keypair"
  ec2_sg_ids        = [module.nginx_sg.security_group_id]
  ec2_tags = {
    Name = "nginx-ec2"
  }
  ec2_root_volume_size = 50
}

module "nginx_ebs" {
  source = "../modules/ebs"

  ebs_az   = var.app_az
  ebs_size = 30
  ebs_tags = {
    Name = "nginx-ebs"
  }
}

module "nginx_eip" {
  source = "../modules/eip"

  eip_tags = {
    Name = "nginx-eip"
  }
}

resource "aws_volume_attachment" "nginx_ebs_attachment" {
  device_name = "/dev/sdh"
  volume_id   = module.nginx_ebs.ebs_id
  instance_id = module.nginx_ec2.ec2_id
}

resource "aws_eip_association" "nginx_eip_association" {
  instance_id   = module.nginx_ec2.ec2_id
  allocation_id = module.nginx_eip.eip_id
}

resource "null_resource" "output_metadata" {
  depends_on = [module.nginx_ec2, module.nginx_eip,
                module.nginx_ebs, aws_volume_attachment.nginx_ebs_attachment]
  
  provisioner "remote-exec" {
    on_failure = continue
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = module.nginx_eip.eip_public_ip
      timeout     = "2m"
    }

    inline = [
      "echo '1. Mise à jour et installation des paquets'",
      "sudo apt update -y",
      "sudo apt install -y nginx git",

      "echo '2. Recherche du volume EBS attaché'",
      # Attendre que le volume soit disponible et détecter son nom
      "DEVICE=''",
      "for i in {1..30}; do",
      "  if lsblk | grep -q 'xvdh'; then",
      "    DEVICE='/dev/xvdh'",
      "    break",
      "  elif lsblk | grep -q 'sdh'; then",
      "    DEVICE='/dev/sdh'",
      "    break",
      "  elif lsblk | grep -q 'nvme'; then",
      "    # Pour les instances modernes (t3, m5, etc.)",
      "    DEVICE=$(lsblk | grep 'disk' | tail -1 | awk '{print \"/dev/\"$1}')",
      "    break",
      "  fi",
      "  sleep 2",
      "  echo 'En attente du volume EBS... ($i/30)'",
      "done",
      
      "if [ -z \"$DEVICE\" ]; then echo 'Volume EBS non trouvé'; exit 1; fi",
      "echo \"Volume détecté: $DEVICE\"",
      
      # Formater si nécessaire
      "if ! sudo blkid $DEVICE; then",
      "  echo 'Formatage du volume...'",
      "  sudo mkfs -t ext4 $DEVICE",
      "fi",
      
      "sudo mkdir -p /mnt/ebs",
      "sudo mount $DEVICE /mnt/ebs",
      
      # Ajouter au fstab uniquement si pas déjà présent
      "if ! grep -qs '/mnt/ebs' /proc/mounts; then",
      "  echo 'Montage du volume...'",
      "  sudo mount $DEVICE /mnt/ebs",
      "fi",
      
      "if ! grep -qs '/mnt/ebs' /etc/fstab; then",
      "  echo '$DEVICE /mnt/ebs ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab",
      "fi",

      "echo '3. Cloner le site'",
      "rm -rf /tmp/site",
      "git clone https://github.com/diranetafen/static-website-example.git /tmp/site",

      "echo '4. Copier les fichiers dans le volume EBS'",
      "sudo cp -r /tmp/site/* /mnt/ebs/",

      "echo '5. Modifier le titre du site'",
      "sudo sed -i 's|<h1>Dimension</h1>|<h1>Terraform Mini-Project</h1>|' /mnt/ebs/index.html",

      "echo '6. Configurer les permissions'",
      "sudo chown -R www-data:www-data /mnt/ebs",
      "sudo chmod -R 755 /mnt/ebs",

      "echo '7. Configurer Nginx'",
      "sudo rm -rf /var/www/html",
      "sudo ln -s /mnt/ebs /var/www/html",

      # Vérifier la configuration Nginx avant redémarrage
      "sudo nginx -t",
      
      "echo '8. Redémarrer Nginx'",
      "sudo systemctl restart nginx",
      
      # Vérifier que Nginx fonctionne
      "sleep 5",
      "sudo systemctl is-active --quiet nginx && echo 'Nginx est en cours d\\'exécution' || echo 'Problème avec Nginx'"
    ]
  }

  provisioner "local-exec" {
    command = "echo NGINX EC2 PUBLIC_IP: ${module.nginx_eip.eip_public_ip} - NGINX EC2 PUBLIC_DNS: ${module.nginx_eip.eip_public_dns}  >> nginx_ec2.txt"
  }

  # provisioner "remote-exec" {
  #   connection {
  #     type        = "ssh"
  #     user        = "centos" # ou "ec2-user" selon ton AMI
  #     private_key = file(var.private_key_path)
  #     host        = module.nginx_eip.eip_public_ip
  #   }

  #   inline = [
  #     # Utiliser les archives vault
  #     "sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*",
  #     "sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*",

  #     # Installer les prérequis
  #     "sudo yum install -y yum-utils git",

  #     # Ajouter le dépôt Docker
  #     "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",

  #     # Installer Docker
  #     "sudo yum install -y docker-ce docker-ce-cli containerd.io",

  #     # Démarrer Docker
  #     "sudo systemctl start docker",
  #     "sudo systemctl enable docker",
  #     "sudo usermod -aG docker centos"
  #   ]
  # }
}
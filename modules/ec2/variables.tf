variable "ec2_instance_type" {
  type = string
  description = "name of the sg"
  default = "t3.nano"
}

variable "ec2_key_name" {
  type = string
  description = "key pair for the ec2"
  default = ""
}

variable "ec2_sg_ids" {
  description = "list of sg ids"
  type = list(string)
  default = []
}

variable "ec2_tags" {
  description = "some ec2 tags"
  type = map(string)
  default = {
  }
}

variable "ec2_az" {
  description = "az for ec2 isntance"
  type = string
  default = "us-east-1a"
}

variable "ec2_subnet_id" {
  description = "subnet id for ec2 isntance"
  type = string
}

variable "ec2_root_volume_size" {
  type = number
  description = "size of the root block device"
  default = 30
}
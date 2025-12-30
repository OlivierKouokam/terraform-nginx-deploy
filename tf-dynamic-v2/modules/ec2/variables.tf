variable "az" {
  type = string
  description = "ec2 az"
  default = "us-east-1a"
}

variable "instance_type" {
  type = string
  description = "ec2 instance type"
  default = "t2.nano"
}

variable "keypair_name" {
  type = string
  description = "key pair name"
  default = "default-kp"
}

variable "user_data_path" {
  type = string
  description = "path to user data script"
  default = "."
}

variable "ec2_tags" {
  type = map(string)
  description = "ec2 tags"
  default = {
    "Name" = "default-ec2"
  }
}

variable "subnet_id" {
  type = string
  description = "subnet id"
}

variable "sg_ids" {
  type = set(string)
  description = "sg ids"
}
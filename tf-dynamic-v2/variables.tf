variable "aws_profile" {
  type    = string
  default = "dynamic"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  type    = string
  default = "10.0.1.0/24"
}

variable "keypair_name" {
  type    = string
  default = "tf-keypair"
}

variable "instance_type" {
  type    = string
  default = "t3.nano"
}

variable "user_data_path" {
  type    = string
  default = "."
}

variable "dynamic_az" {
  type        = string
  description = "dynamic az"
  default     = "us-east-1a"
}

variable "sg_name" {
  type        = string
  description = "dynamic sg"
  default     = "dynamic-sg"
}
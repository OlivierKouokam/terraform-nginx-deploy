variable "app_region" {
  type        = string
  description = "region to use"
  default     = "us-east-1"
}

variable "private_key_path" {
  type        = string
  description = "path of the private key"
}

variable "app_az" {
  type = string
  description = "az to use for app"
}

variable "vpc_cidr_block" {
  type = string
  description = "cidr address for my vpc"
}

variable "subnet_cidr_block" {
  type = string
  description = "cidr address for my subnet"
}
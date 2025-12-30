variable "subnet_cidr_block" {
  type = string
  description = "subnet cidr block"
}

variable "subnet_tags" {
  type = map(string)
  description = "subnet tags"
  default = {
    "Name" = "my_subnet"
  }
}
variable "az" {
  type = string
  description = "subnet az"
  default = "us-east-1a"
}

variable "vpc_id" {
  type = string
  description = "vpc id"
}
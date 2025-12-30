variable "vpc_cidr_block" {
  type = string
  description = "vpc cidr block"
}

variable "vpc_tags" {
  type = map(string)
  description = "vpc tags"
  default = {
    "Name" = "my_vpc"
  }
}
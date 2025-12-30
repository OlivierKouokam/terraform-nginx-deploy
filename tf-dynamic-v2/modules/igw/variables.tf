variable "vpc_id" {
  type = string
  description = "the vpc id"
}

variable "igw_tags" {
  type = map(string)
  description = "igw tags"
  default = {
    "Name" = "my_igw"
  }
}
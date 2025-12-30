variable "sg_name" {
  type = string
  description = "name of the sg"
  default = "sg-module"
}

variable "sg_vpc_id" {
  type = string
  description = "vpc id for the sg"
}


variable "sg_description" {
  type = string
  description = "description of the sg"
  default = "security group module"
}

variable "sg_tags" {
  description = "some sg tags"
  type = map(string)
  default = {}
}

variable "ingress_rules" {
  description = "inbound traffic rules"
  type = list(object({
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}
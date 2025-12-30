variable "sg_name" {
  type = string
  description = "my sg name"
  default = "my_sg"
}

variable "vpc_id" {
  type = string
  description = "the vpc id"
}

variable "sg_tags" {
  type = map(string)
  description = "sg tags"
  default = {
    "Name" = "my_sg"
  }
}

variable "ingress_rules" {
  description = "ingress rules list"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
    description = optional(string)
  }))
  default = []
}

variable "egress_rules" {
  description = "egress rules list"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
    security_groups = optional(list(string))
    description = optional(string)
  }))
  default = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }]
}
variable "ebs_az" {
  type = string
  description = "az for the ebs volume"
  default = "us-east-1a"
}

variable "ebs_size" {
  type = number
  description = "siez of the ebs volume"
  default = 20
}

variable "ebs_type" {
  description = "ebs type"
  type = string
  default = "gp3"
}

variable "ebs_encrypted" {
  description = "ebs encryption"
  type = bool
  default = true
}

variable "ebs_tags" {
  description = "some ebs tags"
  type = map(string)
  default = {
  }
}
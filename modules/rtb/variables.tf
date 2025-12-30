variable "vpc_id" {
  type = string
  description = "the vpc id"
}

variable "rtb_tags" {
  type = map(string)
  description = "rtb tags"
  default = {
    "Name" = "my_rtb"
  }
}
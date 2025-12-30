variable "route_table_id" {
  type = string
  description = "the id of the route table to place it"
}

variable "destination_cidr_block" {
  type = string
  description = "the destination cidr block for request redirection"
}

variable "gateway_id" {
  type = string
  description = "the ressource which will get to request"
}
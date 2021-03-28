variable "name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnet_cidr_blocks_public" {
  type = list(string)
}

variable "subnet_cidr_blocks_private" {
  type = list(string)
}

variable "common_tags" {
  type = map(any)
}

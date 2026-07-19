variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "vault_version" {
  type    = string
  default = "1.6.0"
}

variable "consul_version" {
  type    = string
  default = "1.6.0"
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "key_name" {
  type    = string
  default = "fort-da"
}

variable "availability_zone" {
  type    = string
  default = "ap-northeast-2a"
}

variable "subnet_id" {
  type = list(any)
}

variable "vpc_id" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

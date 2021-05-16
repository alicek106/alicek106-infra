variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "plugin" {
  type    = string
  default = ""
}

variable "key_name" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "availability_zone" {
  type    = string
  default = "ap-northeast-2a"
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

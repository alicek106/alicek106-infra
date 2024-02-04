variable "cluster_name" {
  type = string
}

variable "oidc_provider" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "enable_cluster_autoscaler" {
  type    = bool
  default = true
}

variable "enable_aws_loadbalancer_controller" {
  type    = bool
  default = true
}

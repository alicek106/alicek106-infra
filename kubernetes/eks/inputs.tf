variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.28"
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "worker_groups" {}

variable "addon_cluster_autoscaler" {
  type = object({
    enabled                    = bool
    skip_local_storage         = bool
    chart_version              = string
    scale_down_delay_after_add = string
    scale_down_unneeded_time   = string
  })

  default = {
    enabled                    = true
    skip_local_storage         = false
    chart_version              = "9.29.2"
    scale_down_delay_after_add = "5m"
    scale_down_unneeded_time   = "5m"
  }
}

variable "addon_argocd" {
  type = object({
    enabled       = bool
    chart_version = string
    url           = string
    admin_enabled = bool
  })

  default = {
    enabled       = true
    chart_version = "5.51.4"
    url           = "http://localhost"
    admin_enabled = true
  }
}

variable "addon_argo_rollouts" {
  type = object({
    enabled       = bool
    chart_version = string
  })

  default = {
    enabled       = true
    chart_version = "2.32.4"
  }
}

variable "addon_nginx_ingress_controller" {
  type = object({
    enabled       = bool
    chart_version = string
    enable_nlb    = bool
  })

  default = {
    enabled       = true
    chart_version = "4.9.1"
    enable_nlb    = true
  }
}

variable "addon_aws_loadbalancer_controller" {
  type = object({
    enabled       = bool
    chart_version = string
  })

  default = {
    enabled       = true
    chart_version = "1.6.2"
  }
}

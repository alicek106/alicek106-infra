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

# Global tag
locals {
  common_tags = {
    "Owner"                                       = "alicek106",
    "ManagedBy"                                   = "Terraform"
    "kubernetes.io/cluster/${var.cluster_id_tag}" = var.cluster_id_value
  }
}

## Key Pair
variable "default_keypair_name" {
  default = "fort-da"
}


## cluster settings
variable "number_of_worker" {
  description = "The number of worker nodes"
  default     = 3
}

variable "cluster_id_tag" {
  description = "Cluster ID tag for kubeadm"
  default     = "alice"
}

variable "cluster_id_value" {
  description = "Cluster ID value, it can be shared or owned"
  default     = "owned"
}

variable "kubernetes_version" {
  default = "latest"
}

variable "kubernetes_cni_version" {
  default = "latest"
}

variable "initialize_kubeadm" {
  default = true
}


## Global settings
variable "region" {
  default = "ap-northeast-2"
}

variable "zone" {
  default = "ap-northeast-2a"
}


## Instance settings
variable "master_instance_type" {
  default = "t2.medium"
}
variable "worker_instance_type" {
  default = "t2.medium"
}

variable "instance_ami" {
  default = "ami-0d777f54156eae7d9" # ubuntu 18.04 bionic
}


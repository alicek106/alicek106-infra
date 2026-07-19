terraform {
  required_version = "1.7.1"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0.0, < 6.0.0"
      configuration_aliases = [aws]
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10.0, < 3.0.0"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2, < 3.0.0"
    }
  }
}

data "aws_caller_identity" "current" {}

provider "helm" {
  kubernetes {
    host                   = module.cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.cluster.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.cluster.cluster_name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = module.cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.cluster.cluster_name]
    command     = "aws"
  }
}

provider "kubectl" {
  load_config_file       = false
  host                   = module.cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.cluster.cluster_name]
    command     = "aws"
  }
}

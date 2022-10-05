terraform {
  required_version = "1.1.7"

  backend "s3" {
    bucket  = "alicek106-terraform-state"
    key     = "kubernetes/eks.tfstate"
    region  = "ap-northeast-2"
    encrypt = "true"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.20.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.12.0"
    }
  }
}

provider "aws" {
  region = local.current_region
}

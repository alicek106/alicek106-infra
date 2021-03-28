terraform {
  required_version = ">= 0.14.0"

  backend "s3" {
    bucket  = "alicek106-terraform-state"
    key     = "network-infra.tfstate"
    region  = "ap-northeast-2"
    encrypt = "true"
  }
}

locals {
  vpc_list = [
    "kubernetes",
    "general",
    "vpn"
  ]

  regions = {
    kubernetes = "ap-northeast-2"
    general    = "ap-northeast-2"
    vpn        = "ap-northeast-2"
  }

  vpc_cidr_blocks = {
    # 2020.10.05: 172.31.0.0/16 대역은 AWS 계정 생성할때 맨 처음 생성되었음
    kubernetes = "172.16.0.0/16"
    general    = "172.24.0.0/16"
    vpn        = "172.32.0.0/16"
  }

  subnet_cidr_blocks = {
    kubernetes = {
      public = [
        # each category : /16 cidr
        # 8192 IP available for each subnet
        "a:172.16.0.0/19",
        "b:172.16.32.0/19",
        "c:172.16.64.0/19",
        "d:172.16.96.0/19"
      ]
      private = [
        "a:172.16.128.0/19",
        "b:172.16.160.0/19",
        "c:172.16.192.0/19",
        "d:172.16.224.0/19"
      ]
    }
    general = {
      public = [
        "a:172.24.0.0/19",
        "b:172.24.32.0/19",
        "c:172.24.64.0/19",
        "d:172.24.96.0/19"
      ]
      private = []
    }
    vpn = {
      public = [
        "a:172.32.0.0/19",
        "b:172.32.32.0/19",
        "c:172.32.64.0/19",
        "d:172.32.96.0/19"
      ]
      private = []
    }
  }

  common_tags = {
    "Owner"     = "alicek106"
    "ManagedBy" = "Terraform"
  }

  current_region             = local.regions[terraform.workspace]
  current_vpc_cidr_block     = local.vpc_cidr_blocks[terraform.workspace]
  current_subnet_cidr_blocks = local.subnet_cidr_blocks[terraform.workspace]
}

provider "aws" {
  version = "~> 3.0"
  region  = local.current_region
}

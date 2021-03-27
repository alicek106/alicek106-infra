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

  public_vpc_list = [
    "kubernetes",
    "general",
    "vpn"
  ]

  subnet_cidr_blocks_public = {
    kubernetes = [
      # each category : /16 cidr
      # 8192 IP available for each subnet
      "a:172.16.0.0/19",
      "b:172.16.32.0/19",
      "c:172.16.64.0/19",
      "d:172.16.96.0/19"
    ]
    general = [
      "a:172.24.0.0/19",
      "b:172.24.32.0/19",
      "c:172.24.64.0/19",
      "d:172.24.96.0/19"
    ]
    vpn = [
      "a:172.32.0.0/19",
      "b:172.32.32.0/19",
      "c:172.32.64.0/19",
      "d:172.32.96.0/19"
    ]
  }

  subnet_cidr_blocks_private = {}

  common_tags = {
    "Owner" = "alicek106"
  }
}

provider "aws" {
  version = "~> 3.0"
  region  = "ap-northeast-2" # temp
}

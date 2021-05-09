terraform {
  required_version = "0.14.8"

  backend "s3" {
    bucket  = "alicek106-terraform-state"
    key     = "kubernetes/ssm.tfstate"
    region  = "ap-northeast-2"
    encrypt = "true"
  }

  required_providers {
    aws = {
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

terraform {
  required_version = ">= 1.10"

  backend "s3" {
    bucket  = "alicek106-terraform-state"
    key     = "general.tfstate"
    region  = "ap-northeast-2"
    encrypt = "true"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

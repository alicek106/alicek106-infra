terraform {
  required_version = ">= 1.10"
  backend "s3" {
    bucket  = "alicek106-terraform-state"
    key     = "all-in-one.tf"
    region  = "ap-northeast-2"
    encrypt = "true"
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

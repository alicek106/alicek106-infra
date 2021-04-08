provider "aws" {
  region = data.terraform_remote_state.network.outputs.region
}

terraform {
  backend "s3" {
    bucket = "alicek106-terraform-state"
    key    = "kubernetes/kubeadm.tfstate"
    region = "ap-northeast-2"
  }

  required_providers {
    aws = {
      version = "~> 3.0"
    }
  }

  required_version = "0.14.8"
}

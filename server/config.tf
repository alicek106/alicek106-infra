terraform {
  required_version = "0.14.8"

  backend "s3" {
    bucket  = "alicek106-terraform-state"
    key     = "network-infra.tfstate"
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
  region = local.current_region
}

module "minecraft" {
  source        = "./game/minecraft"
  instance_type = "t3.medium"
  plugin        = "twlight_forest"
  key_name      = "fort-da"

  region            = local.current_region
  availability_zone = local.availability_zone
  subnet_id         = data.terraform_remote_state.network.outputs.public_subnet[local.availability_zone].id
  vpc_id            = data.terraform_remote_state.network.outputs.vpc_id
}


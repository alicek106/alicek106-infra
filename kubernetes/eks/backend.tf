data "terraform_remote_state" "network" {
  backend   = "s3"
  workspace = "kubernetes"

  config = {
    bucket = "alicek106-terraform-state"
    key    = "network-infra.tfstate"
    region = "ap-northeast-2"
  }
}

module "minecraft" {
  source        = "./minecraft"
  instance_type = "t3.medium"
  plugin        = "twlight_forest"
  key_name      = "fort-da"

  availability_zone = local.availability_zone
  subnet_id         = data.terraform_remote_state.network.outputs.private_subnet[local.availability_zone].id
  vpc_id            = data.terraform_remote_state.network.outputs.vpc_id
}

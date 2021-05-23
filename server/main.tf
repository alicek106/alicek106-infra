module "minecraft" {
  source        = "./game/minecraft"
  instance_type = "t3.medium"
  plugin        = "twlight_forest"
  key_name      = "fort-da"

  availability_zone = local.availability_zone
  subnet_id         = data.terraform_remote_state.network.outputs.public_subnet[local.availability_zone].id
  vpc_id            = data.terraform_remote_state.network.outputs.vpc_id
}

module "vault" {
  source         = "./vault"
  vault_version  = "1.6.4"
  consul_version = "1.6.3"
  instance_type  = "t3.medium"
  instance_count = 2

  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_ids
  vpc_id    = data.terraform_remote_state.network.outputs.vpc_id
  ami_id    = data.aws_ami.ubuntu.id
}

module "consul" {
  source         = "./consul"
  consul_version = "1.6.3"
  instance_type  = "t3.medium"
  instance_count = 3

  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_ids
  vpc_id    = data.terraform_remote_state.network.outputs.vpc_id
  ami_id    = data.aws_ami.ubuntu.id
}

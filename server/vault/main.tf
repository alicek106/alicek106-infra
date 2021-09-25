module "vault" {
  source         = "./module"
  vault_version  = "1.6.4"
  consul_version = "1.6.3"
  instance_type  = "t3.medium"
  instance_count = 2

  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_ids
  vpc_id    = data.terraform_remote_state.network.outputs.vpc_id
  ami_id    = data.aws_ami.ubuntu.id
}

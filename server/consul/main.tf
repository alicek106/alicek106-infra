module "consul" {
  source         = "./module"
  consul_version = "1.6.3"
  instance_type  = "t3.medium"
  instance_count = 3

  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_ids
  vpc_id    = data.terraform_remote_state.network.outputs.vpc_id
  ami_id    = data.aws_ami.ubuntu.id
}

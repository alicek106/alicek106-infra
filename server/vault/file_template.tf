locals {
  vault_userdata_template = data.template_file.vault_userdata.rendered
}

data "template_file" "vault_userdata" {
  template = file("${path.module}/config/userdata.tpl.sh")

  vars = {
    vault_config   = data.template_file.vault_config.rendered
    vault_service  = data.template_file.vault_service.rendered
    vault_version  = var.vault_version
    consul_config  = data.template_file.consul_config.rendered
    consul_service = data.template_file.consul_service.rendered
    consul_version = var.consul_version
  }
}

data "template_file" "vault_config" {
  template = file("${path.module}/config/conf.hcl")

  vars = {
    kms_key_id = aws_kms_key.vault.key_id
    region     = var.region
  }
}

data "template_file" "vault_service" {
  template = file("${path.module}/config/vault.service")
}

data "template_file" "consul_config" {
  template = file("${path.module}/config/config.json")

  vars = {
    consul_version = var.consul_version
  }
}

data "template_file" "consul_service" {
  template = file("${path.module}/config/consul.service")
}

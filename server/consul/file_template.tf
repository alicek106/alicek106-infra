locals {
  consul_userdata_template = data.template_file.consul_userdata.rendered
}

data "template_file" "consul_userdata" {
  template = file("${path.module}/config/userdata.tpl.sh")

  vars = {
    consul_config  = data.template_file.consul_config.rendered
    consul_service = data.template_file.consul_service.rendered
    consul_version = var.consul_version
  }
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

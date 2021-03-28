resource "random_string" "token_id" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "token_secret" {
  length  = 16
  special = false
  upper   = false
}

locals {
  token           = "${random_string.token_id.result}.${random_string.token_secret.result}"
  master_template = data.template_file.master_userdata.rendered
  worker_template = data.template_file.worker_userdata.rendered
}


# Master node setting
resource "aws_instance" "master" {
  ami                  = var.instance_ami
  instance_type        = var.master_instance_type
  iam_instance_profile = aws_iam_instance_profile.master_instance_profile.id
  key_name             = var.default_keypair_name

  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet[var.zone].id
  private_ip                  = cidrhost(data.terraform_remote_state.network.outputs.public_subnet[var.zone].cidr, 10)
  vpc_security_group_ids      = [aws_security_group.kubeadm.id]
  associate_public_ip_address = true
  source_dest_check           = false

  availability_zone = var.zone

  root_block_device {
    volume_size = "20"
  }

  tags = merge(
    local.common_tags,
    map(
      "Name", "kubeadm_master",
    )
  )

  user_data = var.initialize_kubeadm ? local.master_template : ""
}

data "template_file" "master_userdata" {
  template = file("kubeadm-config/master_userdata.tpl.sh")

  vars = {
    kubernetes_version     = var.kubernetes_version
    kubernetes_cni_version = var.kubernetes_cni_version
    master_config          = data.template_file.master_config.rendered
  }
}

data "template_file" "master_config" {
  template = file("kubeadm-config/master.tpl.yaml")

  vars = {
    token = local.token
  }
}

# Worker node setting
resource "aws_instance" "worker" {
  count                = var.number_of_worker
  ami                  = var.instance_ami
  instance_type        = var.worker_instance_type
  iam_instance_profile = aws_iam_instance_profile.worker_instance_profile.id
  key_name             = var.default_keypair_name

  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet[var.zone].id
  private_ip                  = cidrhost(data.terraform_remote_state.network.outputs.public_subnet[var.zone].cidr, 30 + count.index)
  vpc_security_group_ids      = [aws_security_group.kubeadm.id]
  associate_public_ip_address = true
  source_dest_check           = false

  availability_zone = var.zone
  root_block_device {
    volume_size = "20"
  }

  tags = merge(
    local.common_tags,
    map(
      "Name", "kubeadm_worker${count.index}",
    )
  )

  user_data = var.initialize_kubeadm ? local.worker_template : ""
}

data "template_file" "worker_userdata" {
  template = file("kubeadm-config/worker_userdata.tpl.sh")

  vars = {
    kubernetes_version     = var.kubernetes_version
    kubernetes_cni_version = var.kubernetes_cni_version
    worker_config          = data.template_file.worker_config.rendered
    apiserver_ip           = aws_instance.master.private_ip
  }
}

data "template_file" "worker_config" {
  template = file("kubeadm-config/worker.tpl.yaml")

  vars = {
    token        = local.token
    apiserver_ip = aws_instance.master.private_ip
  }
}

resource "tls_private_key" "cluster_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "cluster_key_pair" {
  key_name   = var.cluster_name
  public_key = tls_private_key.cluster_key_pair.public_key_openssh
}

module "cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "= 19.21.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  subnet_ids = var.private_subnet_ids
  vpc_id     = var.vpc_id

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  aws_auth_roles = [
    {
      rolearn  = module.iam.node_group_default_role_arn
      groups   = ["system:bootstrappers", "system:nodes"]
      username = "system:node:{{EC2PrivateDNSName}}"
    }
  ]

  cluster_security_group_additional_rules = {
    allow_all_ingress = {
      description      = "Allow all ingress traffic"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "ingress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    allow_all_egress = {
      description      = "Allow all egress traffic"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  self_managed_node_groups = local.worker_groups
}


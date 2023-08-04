data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

locals {
  # worker group attributes
  common_attributes = {
    key_name                 = local.ssh_key_name
    pre_bootstrap_user_data  = local.pre_userdata
    post_bootstrap_user_data = local.additional_userdata

    protect_from_scale_in         = false
    additional_security_group_ids = aws_security_group.eks_all_allow.id
    # public_ip                     = true # temporary setting
  }

  common_tags = var.tags

  kubelet_instance_id_label = "aws/instance-id=$(curl --silent http://169.254.169.254/latest/meta-data/instance-id)"
}

module "eks" {
  source                    = "terraform-aws-modules/eks/aws"
  cluster_name              = local.cluster_name
  cluster_version           = "1.23"
  version                   = "= 18.26.0"
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  subnet_ids = data.terraform_remote_state.network.outputs.public_subnet_ids
  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Owner = "alicek106"
  }

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  self_managed_node_groups = {
    t3-small = merge({
      name             = "t3.small"
      max_size         = 5
      desired_size     = 1
      root_volume_size = 50

      bootstrap_extra_args = "--kubelet-extra-args --node-labels=${local.kubelet_instance_id_label},aws/instance-group=t3.small-common-spot"

      spot_instance_pools = 3
      tags = merge(local.common_tags, {
        "Purpose"   = "common",
        "Lifecycle" = "spot",
      })

      use_mixed_instances_policy = true
      instance_type              = "t3.small"
      subnet_ids                 = [data.terraform_remote_state.network.outputs.public_subnet["${local.current_region}a"].id] # Fix to a (for text purpose)
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 0
          spot_allocation_strategy                 = "lowest-price"
          spot_instance_pools                      = 3
          spot_max_price                           = ""
        }
        override = [
          {
            instance_type     = "t3.small"
            weighted_capacity = "1"
          }
        ]
      }
    }, local.common_attributes),
  }
}


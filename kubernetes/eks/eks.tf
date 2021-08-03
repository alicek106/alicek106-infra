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
    key_name            = local.ssh_key_name
    pre_userdata        = local.pre_userdata
    additional_userdata = local.additional_userdata

    autoscaling_enabled           = true
    protect_from_scale_in         = false
    subnets                       = [data.terraform_remote_state.network.outputs.private_subnet["${local.current_region}a"].id] # Fix to a (for text purpose)
    additional_security_group_ids = aws_security_group.eks_all_allow.id
    # public_ip                     = true # temporary setting
  }

  common_tags = [
    { propagate_at_launch = true, key = "k8s.io/cluster-autoscaler/enabled", value = "true" },
    { propagate_at_launch = true, key = "Owner", value = "alicek106" },
  ]

  kubelet_instance_id_label = "aws/instance-id=$(curl --silent http://169.254.169.254/latest/meta-data/instance-id)"
}

module "eks" {
  source                    = "terraform-aws-modules/eks/aws"
  cluster_name              = local.cluster_name
  cluster_version           = "1.19"
  version                   = "v17.1.0"
  manage_aws_auth           = true
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  subnets = data.terraform_remote_state.network.outputs.private_subnet_ids
  vpc_id  = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Owner = "alicek106"
  }

  worker_groups_launch_template = [
    merge(local.common_attributes, {
      name                    = "t3.small-common-spot"
      override_instance_types = ["t3.small"]
      root_volume_size        = 50
      asg_desired_capacity    = 0
      asg_max_size            = 100
      asg_min_size            = 0
      kubelet_extra_args      = "--node-labels=${local.kubelet_instance_id_label},aws/instance-group=t3.small-common-spot"

      spot_instance_pools = 3 # spot instance pool

      tags = concat(local.common_tags, [
        { propagate_at_launch = true, key = "Purpose", value = "common" },
        { propagate_at_launch = true, key = "Lifecycle", value = "spot" },
      ])
    }),
    merge(local.common_attributes, {
      name                 = "i3.large-registry"
      instance_type        = "i3.large"
      root_volume_size     = 50
      asg_desired_capacity = 1
      asg_min_size         = 0
      asg_max_size         = 4
      kubelet_extra_args   = "--node-labels=${local.kubelet_instance_id_label},aws/instance-group=registry-i3.large"

      tags = concat(local.common_tags, [
        { propagate_at_launch = true, key = "Purpose", value = "registry" },
        { propagate_at_launch = true, key = "Lifecycle", value = "ondemand" },
      ])
    }),
    merge(local.common_attributes, {
      name                    = "c5.xlarge-common-spot"
      override_instance_types = ["c5.xlarge"]
      root_volume_size        = 10
      asg_desired_capacity    = 0
      asg_min_size            = 0
      asg_max_size            = 100
      kubelet_extra_args      = "--node-labels=${local.kubelet_instance_id_label},aws/instance-group=c5.xlarge-common-spot"

      spot_instance_pools = 3 # spot instance pool

      tags = concat(local.common_tags, [
        { propagate_at_launch = true, key = "Purpose", value = "common" },
        { propagate_at_launch = true, key = "Lifecycle", value = "spot" },
      ])
    }),
    merge(local.common_attributes, {
      name                    = "c5.4xlarge-common-spot"
      override_instance_types = ["c5.4xlarge"]
      root_volume_size        = 50
      asg_desired_capacity    = 0
      asg_min_size            = 0
      asg_max_size            = 100
      kubelet_extra_args      = "--node-labels=${local.kubelet_instance_id_label},aws/instance-group=c5.4xlarge-common-spot"

      spot_instance_pools = 3 # spot instance pool

      tags = concat(local.common_tags, [
        { propagate_at_launch = true, key = "Purpose", value = "common" },
        { propagate_at_launch = true, key = "Lifecycle", value = "spot" },
      ])
    }),
  ]
}

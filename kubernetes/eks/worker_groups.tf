locals {
  post_userdata = <<EOFTF
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
EOFTF

  kubelet_instance_id_label = "aws/instance-id=\\\"$(curl --silent http://169.254.169.254/latest/meta-data/instance-id -H \"X-aws-ec2-metadata-token: $(curl --silent -X PUT http://169.254.169.254/latest/api/token -H \"X-aws-ec2-metadata-token-ttl-seconds: 21600\")\")\\\""

  common_attributes = {
    tags = {
      "k8s.io/cluster-autoscaler/enabled"             = "true",
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = var.cluster_name,
    }

    key_name   = var.cluster_name
    subnet_ids = var.private_subnet_ids
    min_size   = 1
    max_size   = 5

    autoscaling_enabled = true
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 50
          volume_type           = "gp3"
          delete_on_termination = true
        }
      }
    }

    post_bootstrap_user_data        = sensitive(local.post_userdata)
    create_iam_instance_profile     = false
    iam_instance_profile_arn        = module.iam.node_group_default_instance_profile_arn
    launch_template_use_name_prefix = true
    security_group_use_name_prefix  = true
  }

  # TODO: deep merge
  worker_groups = {
    for worker_group, attributes in var.worker_groups : worker_group => merge(
      local.common_attributes,
      attributes,
      {
        name                 = "${var.cluster_name}-${worker_group}"
        launch_template_name = "${var.cluster_name}-${worker_group}"
        bootstrap_extra_args = "--kubelet-extra-args --node-labels=${local.kubelet_instance_id_label},aws/instance-group=${worker_group}"
      }
    )
  }
}

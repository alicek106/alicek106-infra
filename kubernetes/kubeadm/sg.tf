resource "aws_security_group" "kubeadm" {
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  name   = "kubeadm"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    map(
      "Name", "kubeadm",
    )
  )
}

resource "aws_security_group" "eks_all_allow" {
  name   = "${local.cluster_name}-eks-allow-allow"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

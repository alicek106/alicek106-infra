resource "aws_instance" "consul" {
  count                       = var.instance_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id[count.index] # 4개 이하이기 때문에 이렇게 써도 됨
  monitoring                  = true
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.consul.id

  vpc_security_group_ids = [
    aws_security_group.consul.id
  ]

  root_block_device {
    delete_on_termination = false
    volume_size           = "10"
    volume_type           = "gp3"
  }

  tags = {
    Name = "consul"
  }
}


resource "aws_security_group" "consul" {
  vpc_id = var.vpc_id
  name   = "consul"

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

  tags = {
    "Name" = "consul"
  }
}

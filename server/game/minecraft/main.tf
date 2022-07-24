data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_network_interface" "minecraft" {
  subnet_id = var.subnet_id

  tags = {
    Name = "minecraft"
  }
}

resource "aws_instance" "minecraft" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  monitoring                  = true
  associate_public_ip_address = false

  vpc_security_group_ids = [
    aws_security_group.minecraft.id
  ]

  root_block_device {
    delete_on_termination = false
    volume_size           = "20"
    volume_type           = "gp3"
  }

  tags = {
    Name   = "minecraft"
    Plugin = var.plugin
  }
}


resource "aws_security_group" "minecraft" {
  vpc_id = var.vpc_id
  name   = "minecraft"

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
    "Name" = "minecraft"
  }
}

# resource "aws_volume_attachment" "ebs_attachment" {
#   device_name = "/dev/sdh"
#   volume_id   = aws_ebs_volume.minecraft.id
#   instance_id = aws_instance.minecraft.id
# }
# 
# resource "aws_ebs_volume" "minecraft" {
#   availability_zone = var.availability_zone
#   size              = 20
#   type              = "gp3"
# 
#   tags = {
#     "Name" = "minecraft"
#   }
# }
#
#
data "aws_route53_zone" "zone" {
  name = "alicek106.com"
}


resource "aws_route53_record" "minecraft" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "minecraft.alicek106.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.minecraft.private_ip]
}

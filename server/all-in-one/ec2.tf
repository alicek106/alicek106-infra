data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "wg_sg" {
  name        = "wireguard-sg"
  description = "Allow WireGuard"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "WireGuard"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "wireguard" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "m4"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.wg_sg.id]

  user_data = <<EOF
#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

apt update -y
apt install -y unzip curl
apt install -y wireguard iptables-persistent

curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install

WG_PRIVATE_CREDENTIAL=$(aws ssm get-parameter \
  --name "wireguard_server_credential" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text)

WG_NET="10.200.0.0/24"
OUT_IF=$(ip route get 8.8.8.8 | awk '{print $5; exit}')

mkdir -p /etc/wireguard
chmod 700 /etc/wireguard

cat <<WG >/etc/wireguard/wg0.conf
$WG_PRIVATE_CREDENTIAL
WG

chmod 600 /etc/wireguard/wg0.conf

# NAT rules
iptables -t nat -C POSTROUTING -s $WG_NET -o $OUT_IF -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -s $WG_NET -o $OUT_IF -j MASQUERADE

netfilter-persistent save

echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-wg.conf
sysctl --system
wg-quick up wg0
systemctl enable wg-quick@wg0

R53_ZONE_ID="${data.aws_route53_zone.main.zone_id}"
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

PUBLIC_IP=$(curl -s \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

aws route53 change-resource-record-sets \
  --hosted-zone-id "$R53_ZONE_ID" \
  --change-batch "{
    \"Comment\": \"Update wg A record\",
    \"Changes\": [{
      \"Action\": \"UPSERT\",
      \"ResourceRecordSet\": {
        \"Name\": \"wg.alicek106.com\",
        \"Type\": \"A\",
        \"TTL\": 300,
        \"ResourceRecords\": [{ \"Value\": \"$${PUBLIC_IP}\" }]
      }
    }]
  }"

apt-get install -y podman

PODMAN_NET_NAME="alicek106"
PODMAN_NET_SUBNET="172.100.0.0/16"

if ! podman network inspect "$PODMAN_NET_NAME" >/dev/null 2>&1; then
    podman network create \
        --subnet="$PODMAN_NET_SUBNET" \
        "$PODMAN_NET_NAME"
fi

DIARY_PASSWORD=$(aws ssm get-parameter \
  --name "diary_password" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
)

mkdir -p /root/diary/data
mkdir -p /root/diary/data/attachments

podman rm -f diary 2>/dev/null || true

podman run -d \
  --name diary \
  --user root \
  --network "$PODMAN_NET_NAME" \
  --ip 172.100.0.10 \
  -v /root/diary/data:/data \
  -e USERNAME="alicek106" \
  -e PASSWORD="$${DIARY_PASSWORD}" \
  -e PORT="80" \
  -e SECRET_KEY="7qiuLtX21xENJfdNR7ot" \
  -e DATA_FILESYSTEM_PATH="/data" \
  -e ATTACHMENT_FILESYSTEM_PATH="/data/attachments" \
  -e NOTES_PER_PAGE="10" \
  -e BACKUP_ENABLED="true" \
  -e S3_BUCKET_NAME="alicek106-diary-backup" \
  -e S3_BACKUP_PREFIX="backup/" \
  --label "io.containers.autoupdate=image" \
  public.ecr.aws/o5v4y7w2/diary:latest

mkdir -p /root/gitea
podman run -d \
  --name gitea \
  --user root \
  --network "$PODMAN_NET_NAME" \
  --ip 172.100.0.20 \
  -v /root/gitea:/data \
  docker.io/gitea/gitea:1.24.7

podman generate systemd \
  --new \
  --name diary \
  --files \
  --restart-policy=always

mkdir -p /etc/systemd/system/container-diary.service.d

mv container-diary.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now container-diary.service
systemctl enable --now podman-auto-update.timer

EOF

  tags = {
    Name = "all-in-one"
  }
}


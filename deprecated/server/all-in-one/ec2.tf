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

resource "aws_ebs_volume" "gitea" {
  availability_zone = aws_instance.wireguard.availability_zone
  size              = 20
  type              = "gp3"

  tags = {
    Name = "gitea-data"
  }
}

resource "aws_volume_attachment" "gitea" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.gitea.id
  instance_id = aws_instance.wireguard.id
}

resource "aws_instance" "wireguard" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "m4"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.wg_sg.id]
  availability_zone      = "ap-northeast-2c"

  user_data = <<EOF
#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

#######################################
# Global constants
#######################################
WG_NET="10.200.0.0/24"
PODMAN_NET_NAME="alicek106"
PODMAN_NET_SUBNET="172.100.0.0/16"
R53_ZONE_ID="${data.aws_route53_zone.main.zone_id}"
WG_SSM_PARAM_NAME="wireguard_server_credential"
DIARY_SSM_PARAM_NAME="diary_password"

#######################################
# Logging helper
#######################################
log() {
  echo "[$(date -Is)] $*"
}

#######################################
# 1. 초기 세팅: 패키지 / EBS / AWS CLI
#######################################
install_base_packages() {
  log "Updating apt and installing base packages..."
  apt-get update -y
  apt-get install -y \
    unzip \
    curl \
    wireguard \
    iptables-persistent \
    podman
}

setup_ebs_volume_for_gitea() {
  local device="/dev/xvdf"
  local mountpoint="/root/gitea"

  log "Waiting for EBS volume $device..."
  while [ ! -e "$device" ]; do
    sleep 2
  done

  if ! blkid "$device" >/dev/null 2>&1; then
    log "Formatting $device as ext4..."
    mkfs.ext4 "$device"
  fi

  log "Mounting $device to $mountpoint..."
  mkdir -p "$mountpoint"
  mount "$device" "$mountpoint"

  local uuid
  uuid=$(blkid -s UUID -o value "$device")
  log "Adding $device (UUID=$uuid) to /etc/fstab..."
  echo "UUID=$uuid $mountpoint ext4 defaults,nofail 0 2" >> /etc/fstab
}

install_aws_cli_v2() {
  if command -v aws >/dev/null 2>&1; then
    log "aws CLI already installed, skipping."
    return
  fi

  log "Installing AWS CLI v2..."
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  unzip -q /tmp/awscliv2.zip -d /tmp
  /tmp/aws/install
}

#######################################
# 2. WireGuard 서버 세팅 + 라우팅
#######################################
setup_wireguard() {
  log "Fetching WireGuard server credential from SSM..."
  local wg_credential
  wg_credential=$(aws ssm get-parameter \
    --name "$WG_SSM_PARAM_NAME" \
    --with-decryption \
    --query "Parameter.Value" \
    --output text)

  local out_if
  out_if=$(ip route get 8.8.8.8 | awk '{print $5; exit}')

  log "Writing /etc/wireguard/wg0.conf..."
  mkdir -p /etc/wireguard
  chmod 700 /etc/wireguard

  cat > /etc/wireguard/wg0.conf <<WG
$wg_credential
WG

  chmod 600 /etc/wireguard/wg0.conf

  log "Configuring NAT for WireGuard network ($WG_NET → $out_if)..."
  iptables -t nat -C POSTROUTING -s "$WG_NET" -o "$out_if" -j MASQUERADE 2>/dev/null || \
  iptables -t nat -A POSTROUTING -s "$WG_NET" -o "$out_if" -j MASQUERADE

  log "Saving iptables rules..."
  netfilter-persistent save

  log "Enabling IP forwarding..."
  echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-wg.conf
  sysctl --system

  log "Bringing up wg0 and enabling wg-quick@wg0..."
  wg-quick up wg0
  systemctl enable wg-quick@wg0
}

#######################################
# 3. Route53:
#   - wg.alicek106.com          → Public IP
#   - wg-private.alicek106.com  → Private IP
#######################################
update_route53_records() {
  log "Fetching instance public/private IP via IMDSv2..."
  local token
  token=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

  local PUBLIC_IP
  PUBLIC_IP=$(curl -s \
    -H "X-aws-ec2-metadata-token: $token" \
    http://169.254.169.254/latest/meta-data/public-ipv4)

  local PRIVATE_IP
  PRIVATE_IP=$(curl -s \
    -H "X-aws-ec2-metadata-token: $token" \
    http://169.254.169.254/latest/meta-data/local-ipv4)

  log "Updating Route53 A records:"
  log "  - wg.alicek106.com          → $PUBLIC_IP"
  log "  - wg-private.alicek106.com  → $PRIVATE_IP"

  aws route53 change-resource-record-sets \
    --hosted-zone-id "$R53_ZONE_ID" \
    --change-batch "{
      \"Comment\": \"Update wg and wg-private A records\",
      \"Changes\": [
        {
          \"Action\": \"UPSERT\",
          \"ResourceRecordSet\": {
            \"Name\": \"wg.alicek106.com\",
            \"Type\": \"A\",
            \"TTL\": 300,
            \"ResourceRecords\": [{ \"Value\": \"$PUBLIC_IP\" }]
          }
        },
        {
          \"Action\": \"UPSERT\",
          \"ResourceRecordSet\": {
            \"Name\": \"wg-private.alicek106.com\",
            \"Type\": \"A\",
            \"TTL\": 300,
            \"ResourceRecords\": [{ \"Value\": \"$PRIVATE_IP\" }]
          }
        }
      ]
    }"
}

#######################################
# 4. Podman 네트워크
#######################################
setup_podman_network() {
  log "Ensuring Podman network $PODMAN_NET_NAME ($PODMAN_NET_SUBNET) exists..."
  if ! podman network inspect "$PODMAN_NET_NAME" >/dev/null 2>&1; then
    podman network create \
      --subnet="$PODMAN_NET_SUBNET" \
      "$PODMAN_NET_NAME"
  fi
}

#######################################
# 5. 일기장 컨테이너 세팅
#######################################
setup_diary_container() {
  log "Fetching diary password from SSM..."
  local diary_password
  diary_password=$(aws ssm get-parameter \
    --name "$DIARY_SSM_PARAM_NAME" \
    --with-decryption \
    --query "Parameter.Value" \
    --output text)

  log "Preparing diary data directories..."
  mkdir -p /root/diary/data
  mkdir -p /root/diary/data/attachments

  log "Removing old diary container if exists..."
  podman rm -f diary 2>/dev/null || true

  log "Creating diary container..."
  podman create \
    --name diary \
    --user root \
    --network "$PODMAN_NET_NAME" \
    --ip 172.100.0.10 \
    -v /root/diary/data:/data \
    -e USERNAME="alicek106" \
    -e PASSWORD="$diary_password" \
    -e PORT="80" \
    -e SECRET_KEY="7qiuLtX21xENJfdNR7ot" \
    -e DATA_FILESYSTEM_PATH="/data" \
    -e ATTACHMENT_FILESYSTEM_PATH="/data/attachments" \
    -e NOTES_PER_PAGE="10" \
    -e BACKUP_ENABLED="true" \
    -e S3_BUCKET_NAME="alicek106-diary-backup" \
    -e S3_BACKUP_PREFIX="backup/" \
    public.ecr.aws/o5v4y7w2/diary:latest
}

setup_diary_systemd() {
  log "Generating systemd unit for diary container..."
  podman generate systemd \
    --new \
    --name diary \
    --files \
    --restart-policy=always

  mkdir -p /etc/systemd/system/container-diary.service.d

  log "Installing container-diary.service..."
  mv container-diary.service /etc/systemd/system/

  log "Reloading systemd and enabling diary + auto-update..."
  systemctl daemon-reload
  systemctl enable --now container-diary.service
  systemctl enable --now podman-auto-update.timer
}

#######################################
# 6. Gitea 컨테이너 세팅
#######################################
setup_gitea_container() {
  log "Removing old gitea container if exists..."
  podman rm -f gitea 2>/dev/null || true

  log "Starting gitea container..."
  podman run -d \
    --name gitea \
    --user root \
    --network "$PODMAN_NET_NAME" \
    --ip 172.100.0.20 \
    -v /root/gitea:/data \
    docker.io/gitea/gitea:1.24.7
}

#######################################
# main
#######################################
main() {
  log "=== Phase 1: Base setup (packages / EBS / AWS CLI) ==="
  install_base_packages
  setup_ebs_volume_for_gitea
  install_aws_cli_v2

  log "=== Phase 2: WireGuard setup ==="
  setup_wireguard

  log "=== Phase 3: DNS (Route53) ==="
  update_route53_records

  log "=== Phase 4: Podman network ==="
  setup_podman_network

  log "=== Phase 5: Diary (Podman + systemd) ==="
  setup_diary_container
  setup_diary_systemd

  log "=== Phase 6: Gitea (Podman) ==="
  setup_gitea_container

  log "Bootstrap completed."
}

main

EOF
  tags = {
    Name = "all-in-one"
  }
}


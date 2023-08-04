locals {
  current_region = "ap-northeast-2"
  cluster_name   = var.cluster_name
  ssh_key_name   = "fort-da"

  # Insert before original userdata
  pre_userdata = <<EOFTF
mkdir -p /etc/docker
cat <<'EOF' > /etc/docker/daemon.json
{
  "storage-driver": "overlay2",
  "max-concurrent-downloads": 10,
  "registry-mirrors": ["https://hub.alicek106.com"]
}
EOF
systemctl restart docker
EOFTF

  # Insert after original userdata
  additional_userdata = <<EOFTF
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

pushd /dev/ || exit
for dev in nvme*n1; do
  if /sbin/ebsnvme-id /dev/$dev; then
    continue
  fi
  if [ -d "/mnt/$dev" ]; then
    echo "$dev already mounted, skipping..."
  fi
  if [ ! -d "/mnt/$dev" ]; then
    echo "Setting up $dev"
    mkfs -t ext4 "$dev"
    mkdir -p "/mnt/$dev"
    mount -t ext4 "/dev/$dev" "/mnt/$dev"
    echo "/dev/$dev /mnt/$dev ext4 defaults,noatime 0 0" | tee -a /etc/fstab
  fi
done
popd || exit
EOFTF
}
